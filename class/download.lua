local download = {}

function download:download()
  self:setStatus(vapor.status.download)
  return self
end

function download:update()

  if self:getStatus() == vapor.status.downloaded then 
    -- TODO: perhform hash check
    self:setStatus(vapor.status.ready)
  end

  if self:getStatus() == vapor.status.download then

    if self._uri then

      if self._uri:sub(0,7) == "http://" then
        -- TODO: make async
        self:setStatus(vapor.status.downloading)
        print("Downloading URI: "..self._uri)
        local b, c, h = vapor.util.http.request(self._uri)
        if c == 200 then
          self:setStatus(vapor.status.downloaded)
          self._data = b
        else
          self:setStatus(vapor.status.fail)
        end
      elseif self._uri:sub(0,8) == "https://" then
        -- TODO: add https support
        self:setStatus(vapor.status.fail)
      elseif self._uri:sub(0,7) == "file://" then
        -- TODO: add local file support
        self:setStatus(vapor.status.fail)
      else -- uh, wat
        self:setStatus(vapor.status.fail)
      end

    else
      print("download does not have uri set.")
    end

  end

end

function download:clear()
end

-- LuaClassGen pregenerated functions

function download.new(init)
  init = init or {}
  local self={}
  self.download=download.download
  self.update=download.update
  self.clear=download.clear
  self._identifier=init.identifier
  self.getIdentifier=download.getIdentifier
  self.setIdentifier=download.setIdentifier
  self._state=init.state
  self.getState=download.getState
  self.setState=download.setState
  self._hash=init.hash
  self.getHash=download.getHash
  self.setHash=download.setHash
  self._size=init.size
  self.getSize=download.getSize
  self.setSize=download.setSize
  self._data=init.data
  self.getData=download.getData
  self.setData=download.setData
  self._unzip=init.unzip
  self.getUnzip=download.getUnzip
  self.setUnzip=download.setUnzip
  self._location=init.location
  self.getLocation=download.getLocation
  self.setLocation=download.setLocation
  self._status=init.status or vapor.status.uninitialized
  self.getStatus=download.getStatus
  self.setStatus=download.setStatus
  self._uri=init.uri
  self.getUri=download.getUri
  self.setUri=download.setUri
  return self
end

function download:getIdentifier()
  return self._identifier
end

function download:setIdentifier(val)
  self._identifier=val
end

function download:getState()
  return self._state
end

function download:setState(val)
  self._state=val
end

function download:getHash()
  return self._hash
end

function download:setHash(val)
  self._hash=val
end

function download:getSize()
  return self._size
end

function download:setSize(val)
  self._size=val
end

function download:getData()
  return self._data
end

function download:setData(val)
  self._data=val
end

function download:getUnzip()
  return self._unzip
end

function download:setUnzip(val)
  self._unzip=val
end

function download:getLocation()
  return self._location
end

function download:setLocation(val)
  self._location=val
end

function download:getStatus()
  return self._status
end

function download:setStatus(val)
  assert(type(val)=="number")
  -- TODO: remove for release
  --[[
  for i,v in pairs(vapor.status) do
    if v == val then
      print("Setting status: "..i)
    end
  end
  --]]
  self._status=val
end

function download:getUri()
  return self._uri
end

function download:setUri(val)
  self._uri=val
end

return download
