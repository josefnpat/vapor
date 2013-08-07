love.draw = require("events.draw")

local function gui()
  local list = loveframes.Create("list")
  list:SetPos(settings.padding, settings.offset + settings.padding)
  list:SetSize(love.graphics.getWidth()-settings.padding*2, settings.padding*15)
  list:SetDisplayType("vertical")
   
  for i,v in ipairs(remote.data.games) do
      local panel = loveframes.Create("panel")
      list:AddItem(panel)
  end
end

function love.update(dt)
  downloader:update()
  downloader.dt = downloader.dt + dt

  --[[local current = math.floor( ( love.mouse.getY() - settings.offset ) / settings.padding ) - 1
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
  end]]

  loveframes.update(dt)
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
      gameobj.invalid = nil
    end
  end
  loveframes.keypressed(key)
end

function love.keyreleased(key)
  loveframes.keyreleased(key) 
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

  loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  loveframes.mousereleased(x, y, button)
end

function love.quit()
  local raw = json.encode(settings.data)
  love.filesystem.write(settings.file, raw)
end

return gui