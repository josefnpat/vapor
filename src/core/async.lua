local socket = require("socket")
local ltn12 = require("ltn12")

-- don't protect anything
socket.protect = function(fn)
  return fn
end

local http = require("socket.http")

local function non_blocking_tcp()
  local sock = socket.tcp()
  sock:settimeout(0)

  return setmetatable({
    sock = sock,

    -- don't allow timeout to be changed
    settimeout = function()
      return true
    end,

    send = function(self, ...)
      while true do
        local byte, err, partial = self.sock:send(...)
        if err == "timeout" then
          -- TODO: this might lock up when using i,j args
          if partial and partial > 0 then
            return partial
          else
            coroutine.yield("timeout", sock)
          end
        else
          return byte, err, partial
        end
      end
    end,

    connect = function(self, ...)
      local status, err = self.sock:connect(...)
      if err == "timeout" then
        coroutine.yield("timeout", sock)
        return 1
      end
      return status, err
    end,

    receive = function(self, ...)
      while true do
        local msg, err, partial = self.sock:receive(...)
        if err == "timeout" then
          if partial and #partial > 0 then
            return partial
          else
            coroutine.yield("timeout", sock)
          end
        else
          return msg, err, partial
        end
      end
    end
  }, {
    __index = function(self, name)
      self[name] = function(self, ...)
        return self.sock[name](self.sock, ...)
      end
      return self[name]
    end
  })
end

local socket_queue_mt = {
  __index = {
    request = function(self, url, sink, callback)
      local sock = non_blocking_tcp()
      local co = coroutine.create(function()
        http.request({
          url = url,
          sink = sink,
          create = non_blocking_tcp
        })
        self.coroutines[coroutine.running()] = nil
        if callback then
          return "callback", callback
        end
      end)
      self.coroutines[co] = true
    end,

    requeue = function(self, sock)
      local i
      for oi, other in ipairs(self.sockets) do
        if other == sock then
          i = oi
          break
        end
      end
      if i then
        sock = table.remove(self.sockets, i)
        local co = self.sockets[sock]
        self.coroutines[co] = true
      end
    end,

    update = function(self)
      for co in pairs(self.coroutines) do
        local success, status, param = coroutine.resume(co)
        if not success then
          if type(status) == "table" then
            status = unpack(status)
          end
          error(("Failed to resume coroutine: %s\n%s"):format(
            tostring(status),
            debug.traceback(co)
          ))
        end

        if status == "timeout" then
          table.insert(self.sockets, param)
          self.sockets[param] = co
          self.coroutines[co] = nil
        end

        if status == "callback" then
          param()
        end
      end
      if self.sockets[1] then
        local read, write = socket.select(self.sockets, self.sockets, 0)
        for _index_0 = 1, #read do
          local sock = read[_index_0]
          self:requeue(sock)
        end
        for _index_0 = 1, #write do
          local sock = write[_index_0]
          self:requeue(sock)
        end
      end
    end
  }
}


local function SocketQueue()
  return setmetatable({
    coroutines = { },
    sockets = { }
  }, socket_queue_mt)
end


local function callback_sink(fn)
  local buffer = { }
  return function(chunk, err)
    if chunk == nil then
      if err then
        fn(nil, err)
      else
        fn(table.concat(buffer))
      end
    elseif chunk ~= "" then
      table.insert(buffer, chunk)
    end
    return true
  end
end

local function love_filesystem_sink(fname,hash_download)
  local file
  return function(chunk, err)
    if chunk then
      if not file then
        file = love.filesystem.newFile(fname)
        file:open("w")
      end
      return file:write(chunk)
    else
      file:close()
      if hash_download then
        print("Hashing thread starting.")
        local t = love.thread.newThread("hash_"..fname,"core/hash_thread.lua")
        vapor.currently_hashing[fname] = t
        t:start()
        t:set("fname",fname)
      end
    end
  end
end


return {
  SocketQueue = SocketQueue,
  love_filesystem_sink = love_filesystem_sink,
  callback_sink = callback_sink
}
