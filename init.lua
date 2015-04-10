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

vapor.class = {
  game = require "class.game",
  framework = require "class.framework",
  image = require "class.image",
  release = require "class.release",
  mirror = require "class.mirror",
  source = require "class.source",
  download = require "class.download",
  collection = require "class.collection",
}

vapor.util = require "util"
vapor.status = {
  uninitialized = 0,
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
