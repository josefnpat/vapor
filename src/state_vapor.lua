local state_vapor = {}

function state_vapor.init(self)
  love.graphics.setMode(love.graphics.getWidth(),settings.padding*(settings.gameshow+3)+settings.heading.h,false,false,0)
  ui.load()
end

function state_vapor.update(self,dt)

  downloader:update()
  downloader.dt = downloader.dt + dt
  
  ui.update(dt)
  loveframes.update(dt)
  
end

function state_vapor.draw(self)

  ui.header()
  ui.info()
  loveframes.draw()
  
end

function state.keypressed(self,key)  
  if key == "return" or key == " " then
    if remote.data.games[selectindex] then
      vapor.dogame(remote.data.games[selectindex])
    end
  elseif key == "escape" then
    love.event.quit()
  elseif (key == "delete") or (key == "backspace") then
    vapor.deletegame(selectindex)
  elseif key == "f" then
    vapor.favoritegame(selectindex)
  end
  
  loveframes.keypressed(key, unicode)  
end

function state_vapor.keyreleased(self,key)
  loveframes.keyreleased(key)
end

function state_vapor.mousepressed(self,x,y,button)
  loveframes.mousepressed(x,y,button)
end

function state_vapor.mousereleased(self,x,y,button)
  loveframes.mousereleased(x,y,button)
end

return state_vapor
