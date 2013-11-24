git,git_count = "missing git.lua",0
pcall(require, "git");

vapor_icon = love.graphics.newImage("assets/vapor_icon.png")
love.graphics.setIcon(vapor_icon)

state = require("lib/gamestate")

function love.load(args)
  love.graphics.setCaption("Vapor - v"..git_count.." ["..git.."]")
  binary = love.arg.getLow(args)
  state.registerEvents()
  state.switch(require("state_load"))
  cliargs = args
end

function love.quit()
  local raw = json.encode(settings.data)
  love.filesystem.write(settings.file, raw)
end

function love.keypressed(key)
  if key == "f4" and love.keyboard.isDown("lalt","ralt") then
    love.event.quit()
  end
end

function openURL(url)
  if love._os == 'OS X' then
    os.execute('open "' .. url .. '" &')
  elseif love._os == 'Windows' then
    os.execute('start ' .. url )
  elseif love._os == 'Linux' then
    os.execute('xdg-open "' .. url .. '" &')
  end
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
