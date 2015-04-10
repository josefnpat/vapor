local release = {}

function release:getVersionCollection()
  -- TODO (releaseclass.getVersionCollection.lcg.lua)
end

-- LuaClassGen pregenerated functions

function release.new(init)
  init = init or {}
  local self=vapor.class.download.new()
  self.getVersionCollection=release.getVersionCollection
  self._stable=init.stable
  self.getStable=release.getStable
  self.setStable=release.setStable
  return self
end

function release:getStable()
  return self._stable
end

function release:setStable(val)
  self._stable=val
end

return release
