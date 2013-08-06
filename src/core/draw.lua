local draw = {}

function draw.everything()
  love.graphics.push()
  love.graphics.translate(settings.padding, settings.padding)

  local gameobj = remote.data.games[selectindex]
  
  -- Draw header
  draw.header(gameobj)
  -- Draw the subline
  draw.subline(gameobj)

  -- Draw all rows
  love.graphics.setFont(fonts.basic)
  for gi,gv in pairs(remote.data.games) do
    draw.row(gi, gv)
  end

  love.graphics.pop()
end

function draw.header(gameobj)
  love.graphics.setColor(colors.reset)
  
  love.graphics.draw(images[selectindex] or nogame,0,0)
  love.graphics.draw(overlay,0,0)

  love.graphics.setColor(colors.overlaybar)
  love.graphics.rectangle(
    "fill",
    0,
    settings.padding,
    love.graphics.getWidth()-settings.padding*2,
    fonts.title:getHeight()+fonts.basic:getHeight())

  love.graphics.setColor(colors.reset)
  love.graphics.setFont(fonts.title)
  if selectindex then
    love.graphics.print(gameobj.name,settings.padding,settings.padding)
  else
    love.graphics.print("Vapor",settings.padding,settings.padding)  
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
    settings.padding,
    settings.padding+fonts.title:getHeight(),
    love.graphics.getWidth()-settings.padding*4,
    "right"
  )
end

function draw.row(gi, gv)  
  local fn = fname(gv,gv.stable)
  local row_y = settings.padding*gi+settings.offset-settings.padding
  
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
  love.graphics.rectangle("fill",
    0,
    row_y,
    love.graphics.getWidth()-settings.padding*2,
    settings.padding
  )

  -- Draw favorite icon
  local favorited = settings.data.games[gv.id] and settings.data.games[gv.id].favorite
  love.graphics.setColor(favorited and colors.active or colors.inactive)
  love.graphics.draw(icons.favorite, 0, row_y)
  
  -- Draw main icon
  love.graphics.setColor(colors.reset)
  love.graphics.draw(icon,settings.padding, row_y)

  -- Draw "app" title
  love.graphics.setColor((gi == selectindex) and colors.highlighted or colors.unhighlighted)
  love.graphics.print(gv.name,
    settings.padding*2,
    row_y
  )

  -- Draw author
  love.graphics.printf(gv.author,
    settings.padding*2,
    row_y,
    love.graphics.getWidth()-settings.padding*4.5,
    "right"
  )
end

return draw.everything