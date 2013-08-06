local draw = {}

function draw.everything()
  love.graphics.push()
  love.graphics.translate(settings.padding, settings.padding)

  local gameobj = remote.data.games[selectindex] or {name="Vapor"}
  
  -- Draw header
  draw.header(gameobj)
  -- Draw the subline
  draw.subline(gameobj)

  -- Draw all rows
  local row_y = settings.offset
  love.graphics.setFont(fonts.basic)
  for gi,gv in pairs(remote.data.games) do
    local data = {
      bg = (gi%2==1) and colors.bareven or colors.barodd,
      text = {
        color = (gi == selectindex) and colors.highlighted or colors.unhighlighted,
        name = gv.name
      },
      caption = gv.author,
      favorited = settings.data.games[gv.id] and settings.data.games[gv.id].favorite
    }

    local fn = fname(gv,gv.stable)
    if currently_downloading[fn] then
      data.icon = icons.downloading[math.floor(downloader.dt*10)%4+1]
    elseif love.filesystem.exists(fn) then
      data.icon = icons.play
    elseif love.filesystem.exists(imgname(gv)) then
      data.icon = icons.view
    else
      data.icon = icons.download
    end

    draw.row(data, row_y)
    row_y = row_y + settings.padding
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
  love.graphics.print(gameobj.name, settings.padding,settings.padding)  
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

function draw.row(data, row_y)
  local x = 0

  -- Draw row background
  love.graphics.setColor(data.bg)
  love.graphics.rectangle("fill",
    x,
    row_y,
    love.graphics.getWidth()-settings.padding*2,
    settings.padding
  )

  -- Draw favorite icon
  if data.favorited ~= nil then
    love.graphics.setColor(favorited and colors.active or colors.inactive)
    love.graphics.draw(icons.favorite, 0, row_y)
    x = x + settings.padding
  end
  

  -- Draw main icon
  if data.icon then
    love.graphics.setColor(colors.reset)
    love.graphics.draw(data.icon,x, row_y)
    x = x + settings.padding
  end

  -- Draw row title
  love.graphics.setColor(data.text.color)
  love.graphics.print(data.text.name,
    x,
    row_y
  )

  -- Draw caption (apps: author, headers: #items)
  love.graphics.printf(data.caption,
    x,
    row_y,
    love.graphics.getWidth()-settings.padding*4.5,
    "right"
  )
end

return draw.everything