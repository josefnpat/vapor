local download = {}

function download:updateData()
  -- TODO (downloadclass.updateData.lcg.lua)
end

function download:clearData()
  -- TODO (downloadclass.clearData.lcg.lua)
end

-- LuaClassGen pregenerated functions

function download.new(init)
  init = init or {}
  local self={}
  self.updateData=download.updateData
  self.clearData=download.clearData
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

return download
