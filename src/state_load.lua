local state_load = {}

state_load.fade_dt_t = 1
state_load.logo = love.graphics.newImage("assets/logo.png")

function state_load.start()

  require("lib/json/json")
  async = require("core/async") -- this needs to be required before "socket.http"

  require('lib/lf')
  loveframes.config["ACTIVESKIN"] = "Gray"

  http = require("socket.http")

  love.graphics.setCaption("Vapor - v"..git_count.." ["..git.."]")
  
  vapor = require 'core/vapor'
  icons = require("core/icons")
  fonts = require("core/fonts")
  colors = require("core/colors")
  settings = require("core/settings")
  remote = require("core/remote")
  ui = require("core/ui")

  if cliargs[2] == "clearcache" then
    love.filesystem.remove(settings.file)
    love.filesystem.remove(remote.file)
    print("Cleared "..settings.file.." and "..remote.file)
  elseif cliargs[2] == "force_local" then
    force_local = true
  end

  downloader = async.SocketQueue()
  downloader.dt = 0

  hasher = {}
  hasher.update = function()
    for i,v in pairs(vapor.currently_hashing) do

     local e = vapor.currently_hashing[i]:get("error")
     if e then print(e) end

     if love.filesystem.exists(i..".sha1") then
        vapor.currently_hashing[i] = nil
      end
    end
  end
  hasher.dt = 0

  remote.load(force_local)
  settings.load()

end

function state_load.draw(self)
  if not self.ready then
    love.graphics.printf("LOADING ...",0,0,love.graphics.getWidth(),"center")
  end
  if self.fade_dt and self.fade_dt >=0 then
    love.graphics.setColor(255,255,255,255*(self.fade_dt/state_load.fade_dt_t))
  else
    love.graphics.setColor(255,255,255)
  end
  love.graphics.draw(state_load.logo,0,0)
  state_load.ready = true
end

function state_load.update(self,dt)
  if self.ready and not self.fade_dt then
    state_load.start()
    self.fade_dt = self.fade_dt_t
  end
  if self.fade_dt then
    self.fade_dt = self.fade_dt - dt
    if self.fade_dt <= 0 then
      self.fade_dt = nil
      love.graphics.setColor(colors.reset)
      state.switch(require("state_vapor")) 
    end
  end
end

return state_load
