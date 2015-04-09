local image = {}

-- LuaClassGen pregenerated functions

function image.new(init)
  init = init or {}
  local self=vapor.class.download.new()
  self._release=init.release
  self.getRelease=image.getRelease
  self.setRelease=image.setRelease
  self._default=init.default
  self.getDefault=image.getDefault
  self.setDefault=image.setDefault
  return self
end

function image:getRelease()
  return self._release
end

function image:setRelease(val)
  self._release=val
end

function image:getDefault()
  return self._default
end

function image:setDefault(val)
  self._default=val
end

return image
