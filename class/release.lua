local release = {}

function release:getVersionCollection()
  return self._versionCollection
end

function release:getStableVersion()
  local stable = self:getStable()
  local stable_versions = self._versionCollection:find(
    function(o)
      return o:getIdentifier() == stable
    end)
  return stable_versions[1]
end

-- LuaClassGen pregenerated functions

function release.new(init)
  init = init or {}
  local self={}
  self._versionCollection = vapor.class.collection.new()
  self.getVersionCollection=release.getVersionCollection
  self.getStableVersion=release.getStableVersion
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
