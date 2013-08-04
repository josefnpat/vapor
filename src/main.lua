require("lib/json")

local http = require("socket.http")

icons = {}
icons.play = love.graphics.newImage("assets/icons/go-next.png")
icons.view = love.graphics.newImage("assets/icons/applications-internet.png")
icons.download = love.graphics.newImage("assets/icons/emblem-web.png")
icons.favorite = love.graphics.newImage("assets/icons/help-about.png")

fonts = {}
fonts.basic = love.graphics.newFont("assets/fonts/Oswald-Regular.ttf",14)
fonts.title = love.graphics.newFont("assets/fonts/Oswald-Regular.ttf",28)

colors = {}
colors.selected = {0,255,0}
colors.unselected = {191,191,191}
colors.reset = {255,255,255}
colors.bareven = {47,47,47}
colors.barodd = {31,31,31}
colors.overlaybar = {0,0,0,159}
colors.active = {255,255,255}
colors.inactive = {255,255,255,31}

nogame = love.graphics.newImage("assets/nogame.png")
overlay = love.graphics.newImage("assets/overlay.png")

images = {}

settings = {}
settings.file = "settings.json"

padding = 22
offset = (love.graphics.getWidth()-padding*2) / (16/9) + padding -- 16:9

selectindex = nil

r,e = http.request("http://50.116.63.25/public/vapor/games.json")
if e == 200 then
  print("games.json successfully updated.")
  love.filesystem.write("games.json",r)
  data = json.decode(r)
else
  print("games.json failed to update.")
  local raw,_ = love.filesystem.read("games.json")
  data = json.decode(raw)
end

table.sort(data.games, function(a,b) return a.name < b.name end )

if love.filesystem.exists(settings.file) then
  local rawjson = love.filesystem.read(settings.file)
  settings.data = json.decode(rawjson)
else
  settings.data = {}
  settings.data.games = {}
  for i,v in ipairs(data.games) do
    settings.data.games[v.id] = {}
    settings.data.games[v.id].favorite = false
  end
end

love.graphics.setMode(love.graphics.getWidth(),padding*(#data.games+2)+offset,false,false,0)

function imgname(gameobj)
  return gameobj.id..".png"
end

function fname(gameobj,sourceindex)
  return gameobj.id.."-"..sourceindex..".love"
end

function dogame(gameobj)
  
  local fn = fname(gameobj,gameobj.stable)
    
  if love.filesystem.exists(fn) then
    print(fn .. " already exists.")
    local exe
    if love._os == "Windows" then
      exe = "start \""..binary.."\" \"".."%appdata%/LOVE/vapor-data".."/"..fname(gameobj,gameobj.stable).."\""
    else -- osx, linux, unknown, crazy
      exe = "\""..binary.."\" \""..love.filesystem.getSaveDirectory( ).."/"..fname(gameobj,gameobj.stable).."\""
    end
    os.execute(exe)
  else
    print(fn .. " is being downloaded.")
    r,e = http.request(gameobj.sources[gameobj.stable])
    if e == 200 then
      local success = love.filesystem.write(fn,r)
      if success then
        print(fn .. " downloaded successfully.")
      end
    end
  end
end

function love.load(args)
  love.graphics.setCaption("Vapor")
  binary = love.arg.getLow(args)
end

function love.update(dt)
  local current = math.floor( ( love.mouse.getY() - offset ) / padding )
  if current >= 1 and current <= #data.games then
    selectindex = current
  else
    selectindex = nil
  end
  
  if selectindex then  
  
    local imgn = imgname(data.games[selectindex])
    if not love.filesystem.exists(imgn) then
      r,e = http.request(data.games[selectindex].image)
      if e == 200 then
        local success = love.filesystem.write(imgn,r)
        if success then
          print(imgn .. " downloaded successfully.")
        end
      end
    end
    
    if not images[selectindex] then
      images[selectindex] = love.graphics.newImage(imgn)
    end

  end
  
  
end

function love.keypressed(key)
  if key == "return" or key == " " then
    if data.games[selectindex] then
      dogame(data.games[selectindex])
    end
  elseif key == "escape" then
    love.event.quit()
  elseif key == "delete" then
    local gameobj = data.games[selectindex]
    if gameobj then
      love.filesystem.remove(fname(gameobj,gameobj.stable))
      love.filesystem.remove(imgname(gameobj))
    end
  end
end

function love.mousepressed(x,y,button)
  local gameobj = data.games[selectindex]
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

function love.draw()

  love.graphics.setColor(colors.reset)
  if selectindex then
    love.graphics.draw(images[selectindex],padding,padding)
  else
    love.graphics.draw(nogame,padding,padding)
  end
  love.graphics.draw(overlay,padding,padding)

  love.graphics.setColor(colors.overlaybar)
  love.graphics.rectangle(
    "fill",
    padding,
    padding*2,
    love.graphics.getWidth()-padding*2,
    fonts.title:getHeight()+fonts.basic:getHeight())

  local gameobj = data.games[selectindex]

  love.graphics.setColor(colors.reset)
  love.graphics.setFont(fonts.title)
  if selectindex then
    love.graphics.print(gameobj.name,padding*2,padding*2)
  else
    love.graphics.print("Vapor",padding*2,padding*2)  
  end

  love.graphics.setFont(fonts.basic)
  local subline
  if selectindex then
    if love.filesystem.exists(fname(gameobj,gameobj.stable)) then
      subline = "CLICK TO PLAY"
    else
      subline = "CLICK TO INSTALL"
    end
  else
    subline = "LÖVE DISTRIBUTION CLIENT"
  end
  love.graphics.printf(
    subline,
    padding*2,
    padding*2+fonts.title:getHeight(),
    love.graphics.getWidth()-padding*4,"right")
  
  love.graphics.setFont(fonts.basic)

  for gi,gv in pairs(data.games) do
    local fn = fname(gv,gv.stable)
    local icon
    if love.filesystem.exists(fn) then
      icon = icons.play
    elseif love.filesystem.exists(imgname(gv)) then
      icon = icons.view
    else
      icon = icons.download
    end

    if gi%2==0 then
      love.graphics.setColor(colors.bareven)
    else
      love.graphics.setColor(colors.barodd)    
    end
    love.graphics.rectangle("fill",padding,padding*gi+offset,love.graphics.getWidth()-padding*2,padding)

    if settings.data.games[gv.id].favorite then
      love.graphics.setColor(colors.active)
    else
      love.graphics.setColor(colors.inactive)
    end
    love.graphics.draw(icons.favorite, padding, padding*gi+offset)
    love.graphics.setColor(colors.reset)

    love.graphics.draw(icon,padding*2,padding*gi+offset)

    if gi == selectindex then
      love.graphics.setColor(colors.selected)
    else
      love.graphics.setColor(colors.unselected)
    end
    love.graphics.print(gv.name,padding*3,padding*gi+offset)
    love.graphics.printf(gv.author,padding*3,padding*gi+offset,love.graphics.getWidth()-padding*4.5,"right")

  end
end

function love.quit()
  local raw = json.encode(settings.data)
  love.filesystem.write(settings.file, raw)
end
