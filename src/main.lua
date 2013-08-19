git,git_count = "missing git.lua",0
pcall(require, "git");

require("lib/json/json")
async = require("core/async") -- this needs to be required before "socket.http"

require('lib/loveframes')
loveframes.config["ACTIVESKIN"] = "gray"

http = require("socket.http")

currently_downloading = {}

function imgname(gameobj)
  return gameobj.id..".png"
end

function fname(gameobj,sourceindex)
  return gameobj.id.."-"..sourceindex..".love"
end

local function execgame(binarypath, gamepath)
  local execstr
  if love._os == "Windows" then
    local fstr = [[start "" "%s" "%%APPDATA%%/LOVE/vapor-data/%s"]]
    execstr = fstr:format(binarypath, gamepath)
  else
    -- OS X, Linux
    local fstr = [["%s" "%s/%s"]]
    execstr = fstr:format(binarypath, love.filesystem.getSaveDirectory(), gamepath)
  end
  print(gamepath.." starting.")
  return os.execute(execstr)
end

function dogame(gameobj)

  local fn = fname(gameobj,gameobj.stable)
  if not currently_downloading[fn] then
    
    if love.filesystem.exists(fn) then
      print(fn .. " exists.")
      
      local hash
      if love.filesystem.exists(fn..".sha1") then
        hash = love.filesystem.read(fn..".sha1")
      end
      if gameobj.hashes[gameobj.stable] == hash then
        print(fn .. " hash validated.")
        local status = execgame(binary, fn)
      else
        if gameobj.invalid then
          gameobj.invalid = nil
          love.filesystem.remove(fn)
          love.filesystem.remove(fn..".sha1")
        else
          gameobj.invalid = true
          print(fn .. " hash not validated.")
        end
      end
    else
      print(fn .. " is being downloaded.")
      local url = gameobj.sources[gameobj.stable]
      currently_downloading[fn] = true
      downloader:request(url, async.love_filesystem_sink(fn,true), function()
        currently_downloading[fn] = nil
      end)
    end
  
  end
end

function deletegame(index)
  local gameobj = remote.data.games[index]
  if gameobj and not currently_downloading[fname(gameobj,gameobj.stable)] then
    love.filesystem.remove(fname(gameobj,gameobj.stable))
    love.filesystem.remove(fname(gameobj,gameobj.stable)..".sha1")
    love.filesystem.remove(imgname(gameobj))
    ui.images[index] = nil
    gameobj.invalid = nil
  end
end

function favoritegame(index)
  local gameobj = remote.data.games[index]
  if gameobj then
    settings.data.games[gameobj.id].favorite = 
      not settings.data.games[gameobj.id].favorite
  end
  ui.list.favorites = ui.update_list(ui.list.favorites,ui.conditions.favorites)
end

function visitwebsitegame(index)
  local gameobj = remote.data.games[index]
  if gameobj and gameobj.website then
    openURL(gameobj.website)
  end
end

function love.load(args)

  love.graphics.setCaption("Vapor - v"..git_count.." ["..git.."]")
  binary = love.arg.getLow(args)
  
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
  end

  downloader = async.SocketQueue()
  downloader.dt = 0

  love.graphics.setMode(love.graphics.getWidth(),settings.padding*(settings.gameshow+3)+settings.heading.h,false,false,0)

  remote.load()
  settings.load()
  ui.load()

  selectindex = nil

  
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
      dogame(remote.data.games[selectindex])
    end
  elseif key == "escape" then
    love.event.quit()
  elseif (key == "delete") or (key == "backspace") then
    deletegame(selectindex)
  elseif key == "f" then
    favoritegame(selectindex)
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
