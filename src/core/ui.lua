local ui = {}

ui.images = {}

ui.nogame = love.graphics.newImage("assets/nogame.png")
ui.overlay = love.graphics.newImage("assets/overlay.png")

ui.headerindex = selectindex or 0

ui.snap = 0.01
ui.changespeed = 10
ui.buttonwidth = 210

ui.gameselect_w = (settings.gameshow)*settings.padding
ui.gameselect_h = (settings.gameshow+1)*settings.padding

ui.conditions = {}
ui.conditions.all = function(g) return true end
ui.conditions.favorites = function(g)
  return settings.data.games[g.id].favorite
end
ui.conditions.downloaded = function(g)
  return love.filesystem.exists(vapor.fname(g,g.stable)..".sha1")
end

function ui.create_list(condition)
  local list = loveframes.Create("columnlist")

  list.OnRowSelected = function(parent, row, data)
    for gi,gv in pairs(remote.data.games) do
      if data[1] == gv.name then
        selectindex = gi
      end
    end
  end

  return ui.update_list(list,condition)
  
end

function ui.update_list(list,condition)
  list:Clear()

  for gi,gv in pairs(remote.data.games) do
    if condition(gv) then
      list:AddRow(gv.name)
    end
  end
  
  return list  
end

function ui.update_buttons()
  local gameobj = remote.data.games[selectindex]
  if gameobj then
    local fn = vapor.fname(gameobj,gameobj.stable)
    if vapor.currently_downloading[fn] then
      ui.mainbutton:SetText("Downloading ...")
      ui.mainbutton.icon = icons.downloading[math.floor(downloader.dt*10)%4+1]
      ui.mainbutton_tooltip:SetText("Your game is downloading.")
    elseif vapor.currently_hashing[fn] then
      ui.mainbutton:SetText("Hashing ...")
      ui.mainbutton.icon = icons.hash[math.floor(hasher.dt*10)%4+1]
      ui.mainbutton_tooltip:SetText("Your game is hashing.")
    elseif gameobj.invalid then
      ui.mainbutton:SetText("Error")
      ui.mainbutton.icon = icons.delete
      ui.mainbutton_tooltip:SetText("There has been an error. Click to delete this game.")
    elseif love.filesystem.exists(fn) then
      ui.mainbutton:SetText("Play")
      ui.mainbutton.icon = icons.play
      ui.mainbutton_tooltip:SetText("This game is ready to play.")
    else
      ui.mainbutton:SetText("Download")
      ui.mainbutton.icon = icons.view
      ui.mainbutton_tooltip:SetText("Download this game now.")
    end

    if ui.conditions.favorites(gameobj) then
      ui.buttons.favorite:SetImage(icons.favorite)
    else
      ui.buttons.favorite:SetImage(icons.favorite_off)
    end

    if gameobj.website then
      ui.buttons.visitwebsite:SetImage(icons.website)
    else
      ui.buttons.visitwebsite:SetImage(icons.website_off)
    end

  else
    ui.mainbutton.icon = icons.download
  end
end

function ui.load()

  -- Button
  ui.mainbutton = loveframes.Create("button")
  ui.mainbutton:SetSize(100, 22)
  ui.mainbutton:SetPos(ui.gameselect_w+settings.padding*3, settings.heading.h+settings.padding*3)
  ui.mainbutton:SetText("Download")
  ui.mainbutton.OnClick = function(object)
    if remote.data.games[selectindex] then
      vapor.dogame(remote.data.games[selectindex])
    end
  end

  ui.mainbutton_tooltip = loveframes.Create("tooltip")
  ui.mainbutton_tooltip:SetObject(ui.mainbutton)
  ui.mainbutton_tooltip:SetPadding(4)

  -- tabs

  local tabs = loveframes.Create("tabs")
  tabs:SetPos(settings.padding, settings.heading.h+settings.padding)

  tabs:SetSize(ui.gameselect_w,ui.gameselect_h)

  ui.list = {}

  ui.list.all = ui.create_list(ui.conditions.all)
  tabs:AddTab("All",ui.list.all,"All games")

  ui.list.favorites = ui.create_list(ui.conditions.favorites)
  tabs:AddTab("Favorites",ui.list.favorites,"Your favorite games")

  ui.list.downloaded = ui.create_list(ui.conditions.downloaded)
  tabs:AddTab("Downloaded",ui.list.downloaded,"Downloaded games.")
  
  ui.buttons = {}
  
  local x = ui.gameselect_w+settings.padding*2
  local y = love.graphics.getHeight()-settings.padding*2
  
  ui.buttons.favorite = loveframes.Create("imagebutton")
  ui.buttons.favorite:SetImage(icons.favorite)
  ui.buttons.favorite:SizeToImage()
  ui.buttons.favorite:SetText("")
  ui.buttons.favorite:SetPos(x,y)
  ui.buttons.favorite.OnClick = function(object)
    vapor.favoritegame(selectindex)
    ui.update_buttons()
  end
  
  local favorite_tooltip = loveframes.Create("tooltip")
  favorite_tooltip:SetObject(ui.buttons.favorite)
  favorite_tooltip:SetPadding(4)
  favorite_tooltip:SetText("Mark this game as a favorite.")
  
  x = x + settings.padding
  
  ui.buttons.delete = loveframes.Create("imagebutton")
  ui.buttons.delete:SetImage(icons.delete)
  ui.buttons.delete:SizeToImage()
  ui.buttons.delete:SetText("")
  ui.buttons.delete:SetPos(x,y)
  ui.buttons.delete.OnClick = function(object)
    vapor.deletegame(selectindex)
  end

  local delete_tooltip = loveframes.Create("tooltip")
  delete_tooltip:SetObject(ui.buttons.delete)
  delete_tooltip:SetPadding(4)
  delete_tooltip:SetText("Delete this game.")

  x = x + settings.padding

  ui.buttons.visitwebsite = loveframes.Create("imagebutton")
  ui.buttons.visitwebsite:SetImage(icons.website)
  ui.buttons.visitwebsite:SizeToImage()
  ui.buttons.visitwebsite:SetText("")
  ui.buttons.visitwebsite:SetPos(x,y)
  ui.buttons.visitwebsite.OnClick = function(object)
    vapor.visitwebsitegame(selectindex)
    ui.update_buttons()
  end
  
  local visitwebsite_tooltip = loveframes.Create("tooltip")
  visitwebsite_tooltip:SetObject(ui.buttons.visitwebsite)
  visitwebsite_tooltip:SetPadding(4)
  visitwebsite_tooltip:SetText("Visit the author's website.")
  
  ui.update_buttons()

end

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
  
  if selectindex then
    for index = selectindex-1,selectindex+1 do
      ui.updatecovers(index)
    end
  end
  
  ui.update_buttons()

  if ui.download_change then
    ui.download_change = nil
    ui.list.downloaded = ui.update_list(ui.list.downloaded,ui.conditions.downloaded)
  end

end

function ui.header()

  local centerindex = math.floor(ui.headerindex)
  local percentoffset = ui.headerindex%1*2

  local xoff = (love.graphics.getWidth()-settings.heading.w*(1+percentoffset))/2
  local yoff = 0
  
  local vapor = {name="Vapor"}
  
  for preload = -2,2 do
    love.graphics.setColor(255,255,255,255-191*math.abs(preload))
    local preload_gameobj = remote.data.games[centerindex+preload]
    if preload_gameobj then
      ui.cover(preload_gameobj,xoff+settings.heading.w*preload,yoff,centerindex+preload)
    else
      ui.cover(vapor,xoff+settings.heading.w*preload,yoff)
    end
  end

  love.graphics.setColor(colors.reset)
  
end

function ui.info()

  local x = ui.gameselect_w + settings.padding*2
  local y = settings.heading.h + settings.padding
  local w = love.graphics.getWidth()-x-settings.padding
  local h = love.graphics.getHeight()-y-settings.padding*3
  --love.graphics.rectangle("line",x,y,w,h)
  local gameobj = remote.data.games[selectindex]
  love.graphics.setFont(fonts.title)
  love.graphics.print(gameobj and gameobj.name or "Vapor",x,y)
  love.graphics.setFont(fonts.basic)
  love.graphics.printf(gameobj and gameobj.description or "No description available.",x,y+settings.padding*3,w,"left")
  
  if gameobj then
    love.graphics.draw(ui.mainbutton.icon,ui.gameselect_w+settings.padding*2, settings.heading.h+settings.padding*3)
    love.graphics.printf(gameobj.author,x,y+h+settings.padding,w,"right")
    if gameobj.link then
      love.graphics.printf(gameobj.author,x,y+h+settings.padding,w,"right")
    end
  end
end

function ui.cover(gameobj,xoff,yoff,index)
  love.graphics.draw(ui.images[index] or ui.nogame,xoff,yoff)
  love.graphics.draw(ui.overlay,xoff,yoff)
end

function ui.updatecovers(index)
  if not ui.images[index] and remote.data.games[index] then
    local imgn = vapor.imgname(remote.data.games[index])

    if not vapor.currently_downloading[imgn] then
      if love.filesystem.exists(imgn) then
        -- load the image
        ui.images[index] = love.graphics.newImage(imgn)
      else
        -- download it!
        print("downloading " .. imgn)
        vapor.currently_downloading[imgn] = true
        downloader:request(remote.data.games[index].image, async.love_filesystem_sink(imgn), function()
          vapor.currently_downloading[imgn] = nil
        end)
      end
    end
  end
end

return ui
