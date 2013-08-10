local ui = {}

ui.images = {}

ui.nogame = love.graphics.newImage("assets/nogame.png")
ui.overlay = love.graphics.newImage("assets/overlay.png")

ui.headerindex = selectindex or 0

ui.snap = 0.01
ui.changespeed = 10

function ui.update(dt)
  if selectindex then
    if ui.headerindex < selectindex + ui.snap and ui.headerindex > selectindex - ui.snap then
      ui.headerindex = selectindex
    end
    local change = math.abs(ui.headerindex - selectindex)/2 + ui.changespeed
    if ui.headerindex < selectindex then
      ui.headerindex = ui.headerindex + change*dt
    elseif ui.headerindex > selectindex then
      ui.headerindex = ui.headerindex - change*dt
    end
  end
  
  local nearestindex = round(ui.headerindex)
  for index = nearestindex-2,nearestindex+2 do
    ui.updatecovers(index)
  end
  
end

function ui.header()

  local centerindex = math.floor(ui.headerindex)
  local percentoffset = ui.headerindex%1*2

  local xoff = (love.graphics.getWidth()-settings.heading.w*(1+percentoffset))/2
  local yoff = settings.padding
  
  local vapor = {name="Vapor"}
  
  for preload = -2,2 do
    local preload_gameobj = remote.data.games[centerindex+preload]
    if preload_gameobj then
      ui.cover(preload_gameobj,xoff+settings.heading.w*preload,yoff,centerindex+preload)
    else
      ui.cover(vapor,xoff+settings.heading.w*preload,yoff)
    end
  end
  
end

function ui.cover(gameobj,xoff,yoff,index)
  love.graphics.setColor(colors.reset)

  love.graphics.draw(ui.images[index] or ui.nogame,xoff,0)
  love.graphics.draw(ui.overlay,xoff,0)

  love.graphics.setColor(colors.overlaybar)
  love.graphics.rectangle(
    "fill",
    xoff,
    settings.padding,
    settings.heading.w,
    fonts.title:getHeight()+fonts.basic:getHeight())

  love.graphics.setColor(colors.reset)
  love.graphics.setFont(fonts.title)
  love.graphics.print(gameobj.name,xoff+settings.padding,settings.padding)

  love.graphics.setFont(fonts.basic)
  local subline
  if index then
    local game_filename = fname(gameobj,gameobj.stable)
    if currently_downloading[game_filename] then
      subline = "DOWNLOADING..."
    elseif love.filesystem.exists(game_filename) then
      subline = "CLICK TO PLAY"
    else
      subline = "CLICK TO INSTALL"
    end
  else
    subline = "DISTRIBUTION CLIENT FOR LÖVE"
  end
  love.graphics.printf(
    subline,
    xoff,
    settings.padding+fonts.title:getHeight(),
    settings.heading.w-settings.padding,
    "right"
  )
end

function ui.updatecovers(index)
  if not ui.images[index] and remote.data.games[index] then
    local imgn = imgname(remote.data.games[index])

    if not currently_downloading[imgn] then
      if love.filesystem.exists(imgn) then
        -- load the image
        ui.images[index] = love.graphics.newImage(imgn)
      else
        -- download it!
        print("downloading " .. imgn)
        currently_downloading[imgn] = true
        downloader:request(remote.data.games[index].image, async.love_filesystem_sink(imgn), function()
          currently_downloading[imgn] = nil
        end)
      end
    end
  end
end

return ui
