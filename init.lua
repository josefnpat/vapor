local vapor = {}

vapor.class = {
  game = require "gameclass",
  framework = require "frameworkclass",
  image = require "imageclass",
  release = require "releaseclass",
  mirror = require "mirrorclass",
  source = require "sourceclass",
  download = require "downloadclass",
  collection = require "collectionclass",
}

vapor.util = require "util"
vapor.status = {
  ready = 1,
  downloading = 2,
  hashing = 3,
  processing = 4,
  fail = 5,
}
vapor.lang = require "lang"

function vapor:getGameCollection()
  -- TODO (vaporclass.getGameCollection.lcg.lua)
end

function vapor:getFrameworkCollection()
  -- TODO (vaporclass.getFrameworkCollection.lcg.lua)
end

function vapor:getMirrorCollection()
  -- TODO (vaporclass.getMirrorCollection.lcg.lua)
end

function vapor:getSourceCollection()
  -- TODO (vaporclass.getSourceCollection.lcg.lua)
end

-- LuaClassGen pregenerated functions

function vapor.new(init)
  init = init or {}
  local self={}
  self.getGameCollection=vapor.getGameCollection
  self.getFrameworkCollection=vapor.getFrameworkCollection
  self.getMirrorCollection=vapor.getMirrorCollection
  self.getSourceCollection=vapor.getSourceCollection
  self._cacheDir=init.cacheDir
  self.getCacheDir=vapor.getCacheDir
  self.setCacheDir=vapor.setCacheDir
  return self
end

function vapor:getCacheDir()
  return self._cacheDir
end

function vapor:setCacheDir(val)
  self._cacheDir=val
end

return vapor
