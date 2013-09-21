git,git_count = "missing git.lua",0
pcall(require, "git");

require("lib/json/json")
async = require("core/async") -- this needs to be required before "socket.http"

require('lib/lf')
loveframes.config["ACTIVESKIN"] = "Gray"

http = require("socket.http")

function love.load(args)

  love.graphics.setCaption("Vapor - v"..git_count.." ["..git.."]")
  binary = love.arg.getLow(args)
  
  vapor = require 'core/vapor'
  icons = require("core/icons")
  fonts = require("core/fonts")
  colors = require("core/colors")
  settings = require("core/settings")
  remote = require("core/remote")
  ui = require("core/ui")

  if args[2] == "clearcache" then
    love.filesystem.remove(settings.file)
    love.filesystem.remove(remote.file)
    print("Cleared "..settings.file.." and "..remote.file)
  elseif args[2] == "force_local" then
    force_local = true
  end

  downloader = async.SocketQueue()
  downloader.dt = 0

  love.graphics.setMode(love.graphics.getWidth(),settings.padding*(settings.gameshow+3)+settings.heading.h,false,false,0)

  remote.load(force_local)
  settings.load()
  ui.load()

  selectindex = 1
  
end

function love.update(dt)

  downloader:update()
  downloader.dt = downloader.dt + dt
  
  ui.update(dt)
  loveframes.update(dt)
  
end

function love.draw()

  ui.header()
  ui.info()
  loveframes.draw()
  
end

function love.keypressed(key, unicode)  
  if key == "return" or key == " " then
    if remote.data.games[selectindex] then
      vapor.dogame(remote.data.games[selectindex])
    end
  elseif key == "escape" then
    love.event.quit()
  elseif (key == "delete") or (key == "backspace") then
    vapor.deletegame(selectindex)
  elseif key == "f" then
    vapor.favoritegame(selectindex)
  end
  
  loveframes.keypressed(key, unicode)  
end

function love.keyreleased(key)
  loveframes.keyreleased(key)
end

function love.mousepressed(x,y,button)
  loveframes.mousepressed(x,y,button)
end

function love.mousereleased(x,y,button)
  loveframes.mousereleased(x,y,button)
end

function love.quit()
  local raw = json.encode(settings.data)
  love.filesystem.write(settings.file, raw)
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function openURL(url)
  if love._os == 'OS X' then
    os.execute('open "' .. url .. '" &')
  elseif love._os == 'Windows' then
    os.execute('start "' .. url .. '"')
  elseif love._os == 'Linux' then
    os.execute('xdg-open "' .. url .. '" &')
  end
end
