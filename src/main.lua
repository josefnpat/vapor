git,git_count = "missing git.lua",0
pcall(require, "git");

require("lib/json")
async = require("core/async") -- this needs to be required before "socket.http"

http = require("socket.http")

currently_downloading = {}

function imgname(gameobj)
  return gameobj.id..".png"
end

function fname(gameobj,sourceindex)
  return gameobj.id.."-"..sourceindex..".love"
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
        local exe
        if love._os == "Windows" then
        exe = "start \""..binary.."\" \"".."%appdata%/LOVE/vapor-data".."/"..fname(gameobj,gameobj.stable).."\""
        else -- osx, linux, unknown, crazy
        exe = "\""..binary.."\" \""..love.filesystem.getSaveDirectory( ).."/"..fname(gameobj,gameobj.stable).."\" &"
        end
        print(fn .. " starting.")
        os.execute(exe)
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

function love.load(args)

  love.graphics.setCaption("Vapor - v"..git_count.." ["..git.."]")
  binary = love.arg.getLow(args)
  
  icons = require("core/icons")
  fonts = require("core/fonts")
  colors = require("core/colors")
  settings = require("core/settings")
  remote = require("core/remote")
  love.draw = require("core/draw")

  if args[2] == "clearcache" then
    love.filesystem.remove(settings.file)
    love.filesystem.remove(remote.file)
    print("Cleared "..settings.file.." and "..remote.file)
  end

  downloader = async.SocketQueue()
  downloader.dt = 0

  remote.load()
  settings.load()

  nogame = love.graphics.newImage("assets/nogame.png")
  overlay = love.graphics.newImage("assets/overlay.png")

  images = {}

  selectindex = nil

  love.graphics.setMode(love.graphics.getWidth(),settings.padding*(settings.rows+3)+settings.offset,false,false,0)
  
end

function love.update(dt)
  downloader:update()
  downloader.dt = downloader.dt + dt

  local current = math.floor( ( love.mouse.getY() - settings.offset ) / settings.padding ) - 1
  if current >= 1 and current <= #remote.data.games then
    selectindex = current
  else
    selectindex = nil
  end
  
  if selectindex then  
    if not images[selectindex] then
      local current_index = selectindex
      local imgn = imgname(remote.data.games[selectindex])

      if not currently_downloading[imgn] then
        if love.filesystem.exists(imgn) then
          -- load the image
          images[current_index] = love.graphics.newImage(imgn)
        else
          -- download it!
          print("downloading " .. imgn)
          currently_downloading[imgn] = true
          downloader:request(remote.data.games[selectindex].image, async.love_filesystem_sink(imgn), function()
            currently_downloading[imgn] = nil
          end)
        end
      end
    end
  end


end

function love.keypressed(key)
  if key == "return" or key == " " then
    if remote.data.games[selectindex] then
      dogame(remote.data.games[selectindex])
    end
  elseif key == "escape" then
    love.event.quit()
  elseif (key == "delete") or (key == "backspace") then
    local gameobj = remote.data.games[selectindex]
    if gameobj then
      love.filesystem.remove(fname(gameobj,gameobj.stable))
      love.filesystem.remove(fname(gameobj,gameobj.stable)..".sha1")
      love.filesystem.remove(imgname(gameobj))
      images[selectindex] = nil
    end
  end
end

function love.mousepressed(x,y,button)
  local gameobj = remote.data.games[selectindex]
  if button == "l" then
    if gameobj then
      dogame(gameobj)
    end
  elseif button == "r" then
    if gameobj then
      settings.data.games[gameobj.id].favorite = not settings.data.games[gameobj.id].favorite
    end
  end
end

function love.quit()
  local raw = json.encode(settings.data)
  love.filesystem.write(settings.file, raw)
end
