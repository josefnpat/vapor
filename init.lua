--- Vapor - LÖVE Distribution Client
-- @module Vapor
-- @author Josef N Patoprsty <seppi@josefnpat.com>
-- @copyright 2015
-- @license <a href="http://www.opensource.org/licenses/zlib-license.php">zlib/libpng</a>

local vapor = {
  _VERSION = "Vapor 1.x",
  _DESCRIPTION = "LÖVE Distribution Client",
  _URL = "http://vapor.love2d.org",
  _LICENSE = [[
    The zlib/libpng License
    Copyright (c) 2015 Josef N Patoprsty
    This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
    Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
  ]]
}

local cwd = (...):gsub('%.[^%.]+$', '')

vapor.class = {
  game =       require (cwd..".class.game"),
  framework =  require (cwd..".class.framework"),
  image =      require (cwd..".class.image"),
  release =    require (cwd..".class.release"),
  mirror =     require (cwd..".class.mirror"),
  source =     require (cwd..".class.source"),
  download =   require (cwd..".class.download"),
  collection = require (cwd..".class.collection"),
}

vapor.util =   require (cwd..".util")
vapor.status = {
  fail = -1,
  uninitialized = 0,
  ready = 1,
  download = 2,
  downloading = 3,
  downloaded = 4,
  hashing = 5,
  processing = 6,
  processed = 7,
}
vapor.lang =   require (cwd..".lang")

function vapor:getGameCollection()
  return self._gameCollection
end

function vapor:getGameObject(id)
  assert(type(id) == "number")
  local games = self._gameCollection:find(
    function(g) 
      return g:getIdentifier() == id
    end)
  return games[1]
end

function vapor:getFrameworkCollection()
  return self._frameworkCollection
end

function vapor:getFrameworkObject(id)
  assert(type(id) == "number")
  local frameworks = self._frameworkCollection:find(
    function(f) 
      return f:getIdentifier() == id
    end)
  return frameworks[1]
end

function vapor:getMirrorCollection()
  return self._mirrorCollection
end

function vapor:getSourceCollection()
  return self._sourceCollection
end

function vapor:update()
  for _,v in pairs(self._gameCollection:all()) do
    v:update()
    for _,w in pairs(v:getRelease():getVersionCollection():all()) do
      w:update()
    end
  end
  for _,v in pairs(self._frameworkCollection:all()) do
    v:update()
    for _,w in pairs(v:getRelease():getVersionCollection():all()) do
      w:update()
    end
  end
  for _,v in pairs(self._mirrorCollection:all()) do
    v:update()
    if v:getStatus() == vapor.status.processed then
      for _,game in pairs(v._processedData.games) do
        local g = self._gameCollection:add( vapor.class.game.new(game) )
        for _,version in pairs(game.release.versions) do
          g:getRelease():getVersionCollection():add( vapor.class.download.new(version) )
        end
      end
      for _,framework in pairs(v._processedData.frameworks) do
        local f = self._frameworkCollection:add( vapor.class.framework.new(framework) )
        for _,version in pairs(framework.release.versions) do
          f:getRelease():getVersionCollection():add( vapor.class.download.new(version) )
        end
      end
      v:setStatus(vapor.status.ready)
    end
  end
  for _,v in pairs(self._sourceCollection:all()) do
    v:update()
  end
end

-- LuaClassGen pregenerated functions

function vapor.new(init)
  init = init or {}
  local self={}

  self._gameCollection = vapor.class.collection.new()
  self.getGameCollection=vapor.getGameCollection
  self.getGameObject=vapor.getGameObject

  self._frameworkCollection = vapor.class.collection.new()
  self.getFrameworkCollection=vapor.getFrameworkCollection
  self.getFrameworkObject=vapor.getFrameworkObject

  self._mirrorCollection = vapor.class.collection.new()
  self.getMirrorCollection=vapor.getMirrorCollection

  self._sourceCollection = vapor.class.collection.new()
  self.getSourceCollection=vapor.getSourceCollection

  self._cacheDir=init.cacheDir
  self.getCacheDir=vapor.getCacheDir
  self.setCacheDir=vapor.setCacheDir

  self.update = vapor.update

  self.class=vapor.class
  self.util = vapor.util
  self.status = vapor.status
  self.labg = vapor.lang

  return self
end

function vapor:getCacheDir()
  return self._cacheDir
end

function vapor:setCacheDir(val)
  self._cacheDir=val
end

return vapor
