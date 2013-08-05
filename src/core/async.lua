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

  local function run_nonblock(func, ...)
    while true do
      local res = {
        func(...)
      }
      if res[1] == nil and res[2] == "timeout" then
        coroutine.yield("timeout", sock)
      else
        return unpack(res)
      end
    end
  end

  return setmetatable({
    sock = sock,

		-- don't allow timeout to be changed
    settimeout = function()
      return true
    end,

    send = function(self, ...)
      return run_nonblock(self.sock.send, self.sock, ...)
    end,

    connect = function(self, ...)
      return run_nonblock(self.sock.connect, self.sock, ...)
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
    request = function(self, url, sink)
      local sock = non_blocking_tcp()
      local co = coroutine.create(function()
        http.request({
          url = url,
          sink = sink,
          create = non_blocking_tcp
        })
        self.coroutines[coroutine.running()] = nil
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
        local success, status, sock = coroutine.resume(co)
        if not success then
          if type(status) == "table" then
            status = unpack(status)
          end
          error("Failed to resume coroutine: " .. tostring(status) .. "\n" .. debug.traceback(co))
        end
        if status == "timeout" then
          table.insert(self.sockets, sock)
          self.sockets[sock] = co
          self.coroutines[co] = nil
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

local function love_filesystem_sink(fname, callback)
  local file
  return function(chunk, err)
    if chunk then
      if not file then
        print("opening", fname)
        file = love.filesystem.newFile(fname)
        file:open("w")
      end
      print("writing", #chunk, "bytes")
      return file:write(chunk)
    else
      file:close()
      if callback then
        return callback()
      end
    end
  end
end


return {
  SocketQueue = SocketQueue,
  love_filesystem_sink = love_filesystem_sink,
  callback_sink = callback_sink
}
