local framework = {}

function framework:download()
  local stable = self:getRelease():getStableVersion()
  stable:download()
  print('framework start')
end

-- LuaClassGen pregenerated functions

function framework.new(init)
  init = init or {}
  local self=vapor.class.download.new(init)
  self.download=framework.download
  self._name=init.name
  self.getName=framework.getName
  self.setName=framework.setName
  self._image=init.image
  self.getImage=framework.getImage
  self.setImage=framework.setImage
  self._author=init.author
  self.getAuthor=framework.getAuthor
  self.setAuthor=framework.setAuthor
  self._website=init.website
  self.getWebsite=framework.getWebsite
  self.setWebsite=framework.setWebsite
  self._release=vapor.class.release.new(init.release)
  self.getRelease=framework.getRelease
  self.setRelease=framework.setRelease
  self._exec=init.exec
  self.getExec=framework.getExec
  self.setExec=framework.setExec
  self._execBasedir=init.execBasedir
  self.getExecBasedir=framework.getExecBasedir
  self.setExecBasedir=framework.setExecBasedir
  self._autoBinary=init.autoBinary
  self.getAutoBinary=framework.getAutoBinary
  self.setAutoBinary=framework.setAutoBinary
  return self
end

function framework:getName()
  return self._name
end

function framework:setName(val)
  self._name=val
end

function framework:getImage()
  return self._image
end

function framework:setImage(val)
  self._image=val
end

function framework:getAuthor()
  return self._author
end

function framework:setAuthor(val)
  self._author=val
end

function framework:getWebsite()
  return self._website
end

function framework:setWebsite(val)
  self._website=val
end

function framework:getRelease()
  return self._release
end

function framework:setRelease(val)
  self._release=val
end

function framework:getExec()
  return self._exec
end

function framework:setExec(val)
  self._exec=val
end

function framework:getExecBasedir()
  return self._execBasedir
end

function framework:setExecBasedir(val)
  self._execBasedir=val
end

function framework:getAutoBinary()
  return self._autoBinary
end

function framework:setAutoBinary(val)
  self._autoBinary=val
end

return framework
