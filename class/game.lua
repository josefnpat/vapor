local game = {}

function game:play()
  local framework = vapor:getFrameworkObject(self:getFramework())
  local framework_stable = framework:getRelease():getStableVersion()
  local binarypath = framework_stable:getPath().."/"..framework_stable:getExec()

  -- TODO: add local installed handlers
  if love._os == "Linux" then
    binarypath = "love"
  end

  local game_stable = self:getRelease():getStableVersion()
  local gamepath = game_stable:getFilename()

  local execstr
  if love._os == "Windows" then
    local fstr = [[start "" "%s" "%%APPDATA%%/LOVE/vapor1.x/%s"]]
    execstr = fstr:format(binarypath, gamepath)
  else
    -- OS X, Linux
    local fstr = [["%s" "%s/%s" &]]
    execstr = fstr:format(binarypath, love.filesystem.getSaveDirectory(), gamepath)
  end
  print(gamepath.." starting.")
  return os.execute(execstr)

end

function game:download()
  local stable = self:getRelease():getStableVersion()
  stable:download()
end

-- LuaClassGen pregenerated functions

function game.new(init)
  init = init or {}
  local self={}--vapor.class.download.new(init)
  self.play=game.play
  self.download=game.download
  self._name=init.name
  self.getName=game.getName
  self.setName=game.setName
  self._framework=init.framework
  self.getFramework=game.getFramework
  self.setFramework=game.setFramework
  self._image=init.image
  self.getImage=game.getImage
  self.setImage=game.setImage
  self._description=init.description
  self.getDescription=game.getDescription
  self.setDescription=game.setDescription
  self._author=init.author
  self.getAuthor=game.getAuthor
  self.setAuthor=game.setAuthor
  self._website=init.website
  self.getWebsite=game.getWebsite
  self.setWebsite=game.setWebsite
  self._release=vapor.class.release.new(init.release)
  self.getRelease=game.getRelease
  self.setRelease=game.setRelease
  self._identifier=init.identifier
  self.getIdentifier=game.getIdentifier
  self.setIdentifier=game.setIdentifier
  return self
end

function game:getName()
  return self._name
end

function game:setName(val)
  self._name=val
end

function game:getFramework()
  return self._framework
end

function game:setFramework(val)
  self._framework=val
end

function game:getImage()
  return self._image
end

function game:setImage(val)
  self._image=val
end

function game:getDescription()
  return self._description
end

function game:setDescription(val)
  self._description=val
end

function game:getAuthor()
  return self._author
end

function game:setAuthor(val)
  self._author=val
end

function game:getWebsite()
  return self._website
end

function game:setWebsite(val)
  self._website=val
end

function game:getRelease()
  return self._release
end

function game:setRelease(val)
  self._release=val
end

function game:getIdentifier()
  return self._identifier
end

function game:setIdentifier(val)
  self._identifier=val
end

return game
