local draw = {}

function draw.everything()
  love.graphics.setColor(colors.reset)
  if selectindex and images[selectindex] then
    love.graphics.draw(images[selectindex],settings.padding,settings.padding)
  else
    love.graphics.draw(nogame,settings.padding,settings.padding)
  end
  love.graphics.draw(overlay,settings.padding,settings.padding)

  love.graphics.setColor(colors.overlaybar)
  love.graphics.rectangle(
    "fill",
    settings.padding,
    settings.padding*2,
    love.graphics.getWidth()-settings.padding*2,
    fonts.title:getHeight()+fonts.basic:getHeight())

  local gameobj = remote.data.games[selectindex]

  love.graphics.setColor(colors.reset)
  love.graphics.setFont(fonts.title)
  if selectindex then
    love.graphics.print(gameobj.name,settings.padding*2,settings.padding*2)
  else
    love.graphics.print("Vapor",settings.padding*2,settings.padding*2)  
  end

  -- Draw the subline
  draw.subline(gameobj)

  -- Draw all rows
  love.graphics.setFont(fonts.basic)
  for gi,gv in pairs(remote.data.games) do
    draw.row(gi, gv)
  end
end

function draw.subline(gameobj)
  love.graphics.setFont(fonts.basic)
  local subline
  if selectindex then
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
    settings.padding*2,
    settings.padding*2+fonts.title:getHeight(),
    love.graphics.getWidth()-settings.padding*4,"right"
  )
end

function draw.row(gi, gv)
  local fn = fname(gv,gv.stable)
  local icon
  if currently_downloading[fn] then
    icon = icons.downloading[math.floor(downloader.dt*10)%4+1]
  elseif love.filesystem.exists(fn) then
    icon = icons.play
  elseif love.filesystem.exists(imgname(gv)) then
    icon = icons.view
  else
    icon = icons.download
  end

  -- Draw row background
  love.graphics.setColor((gi%2==1) and colors.bareven or colors.barodd)
  love.graphics.rectangle("fill",settings.padding,settings.padding*gi+settings.offset,love.graphics.getWidth()-settings.padding*2,settings.padding)

  -- Draw favorite icon
  local favorited = settings.data.games[gv.id] and settings.data.games[gv.id].favorite
  love.graphics.setColor(favorited and colors.active or colors.inactive)
  love.graphics.draw(icons.favorite, settings.padding, settings.padding*gi+settings.offset)
  
  -- Draw main icon
  love.graphics.setColor(colors.reset)
  love.graphics.draw(icon,settings.padding*2,settings.padding*gi+settings.offset)

  -- Draw row text
  love.graphics.setColor((gi == selectindex) and colors.selected or colors.unselected)
  love.graphics.print(gv.name,settings.padding*3,settings.padding*gi+settings.offset)
  love.graphics.printf(gv.author,settings.padding*3,settings.padding*gi+settings.offset,love.graphics.getWidth()-settings.padding*4.5,"right")
end
return draw.everything