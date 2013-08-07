love.draw = require("events.draw")

local function gui()
  local list = loveframes.Create("list")
  list:SetPos(settings.padding, settings.offset + settings.padding)
  list:SetSize(love.graphics.getWidth()-settings.padding*2, settings.padding*15)
  list:SetDisplayType("vertical")
   
  for gi,gv in ipairs(remote.data.games) do
    local hovered
    local function hovercheck(me)
      if me.hover then
        selectindex = gi
        hovered = true
      end
    end

    local row = loveframes.Create("panel")
    row.bgcolor = (gi%2==1) and colors.bareven or colors.barodd
    row:SetHeight(settings.padding)
    row.Update = function()
      hovercheck(row)
    end
    
    -- Favorited icon
    local favorited = settings.data.games[gv.id] and settings.data.games[gv.id].favorite or false
    local favbtn = loveframes.Create("imagebutton", row)
    favbtn:SetSize(22, 22)
    favbtn.color = favorited and colors.active or colors.inactive
    favbtn:SetPos(0, 0)
    favbtn:SetText("")
    favbtn:SetImage(icons.favorite)
    favbtn.OnClick = function(object)
        local favorited = settings.data.games[gv.id].favorite
        settings.data.games[gv.id].favorite = not favorited
        print(("Application '%s' %sfavorited"):format( gv.name, (not favorited) and "" or "un"))
    end
    favbtn.Update = function()
      local favorited = settings.data.games[gv.id] and settings.data.games[gv.id].favorite or false
      favbtn.color = favorited and colors.active or colors.inactive
      hovercheck(favbtn)
    end

    -- Main icon
    local mainbtn = loveframes.Create("imagebutton", row)
    local function getMainIcon()
      local fn, icon = fname(gv,gv.stable)
      if currently_downloading[fn] then
        icon = icons.downloading[math.floor(downloader.dt*10)%4+1]
      elseif gv.invalid then
        icon = icons.delete
      elseif love.filesystem.exists(fn) then
        icon = icons.play
      elseif love.filesystem.exists(imgname(gv)) then
        icon = icons.view
      else
        icon = icons.download
      end
      return icon
    end
    mainbtn:SetSize(22, 22)
    mainbtn:SetPos(settings.padding, 0)
    mainbtn:SetText("")
    mainbtn:SetImage(getMainIcon())
    mainbtn.Update = function()
      mainbtn:SetImage(getMainIcon())
      hovercheck(mainbtn)
    end
    mainbtn.OnClick = function()
      dogame(gv)
    end

    local text = loveframes.Create("text", row)
    text:SetPos(settings.padding*2, 0)
    text:SetMaxWidth(love.graphics.getWidth()-settings.padding*3.5)
    text:SetText(gv.name)
    text.Update = function()
      hovercheck(text)
    end

    if (not hovered) and (selectindex == gi) then
      selectindex = nil
    end

    list:AddItem(row)
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
  end]]
  
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