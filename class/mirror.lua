local mirror = {}

-- LuaClassGen pregenerated functions

function mirror.new(init)
  init = init or {}
  local self=vapor.class.download.new()
  self._uri=init.uri
  self.getUri=mirror.getUri
  self.setUri=mirror.setUri
  return self
end

function mirror:getUri()
  return self._uri
end

function mirror:setUri(val)
  self._uri=val
end

return mirror
