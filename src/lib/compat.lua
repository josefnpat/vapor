--checked

local modulesNeeded = { 'filesystem', 'system', 'graphics', 'timer', 'thread', 'joystick', 'window', 'event','keyboard', 'audio' }

for i, module in ipairs(modulesNeeded) do
  require ('love.'..module)
end

local file = love.filesystem.newFile( 'compat.lua' )

file:open('r')

___compat___ = file:read()

file:close()

file = nil

-- https://love2d.org/wiki/love.system.getOS
love._os = love.system.getOS() 

-- https://love2d.org/wiki/love.graphics.getFont

love.graphics.getFont = love.graphics.getFont

--http://www.love2d.org/wiki/love.graphics.newStencil

function love.graphics.newStencil( stencilFunction )

    return stencilFunction

end

love.timer.getMicroTime = love.timer.getTime


--http://www.love2d.org/wiki/love.graphics.setLineo

function love.graphics.setLine( width, style )

    love.graphics.setLineWidth(width)
    love.graphics.setLineStyle(style)

end 

--http://www.love2d.org/wiki/love.graphics.setPoint


function love.graphics.setPoint( size, style )

    love.graphics.setPointSize(size)
    love.graphics.setPointStyle(style)

end    

--http://www.love2d.org/wiki/love.graphics.setDefaultImageFilter

function love.graphics.setDefaultImageFilter( min, mag, anisotropy )

    love.graphics.setDefaultFilter( min, mag )

end

--http://www.love2d.org/wiki/love.graphics.getDefaultImageFilter

function love.graphics.getDefaultImageFilter()

    return love.graphics.getDefaultFilter()

end

--http://www.love2d.org/wiki/love.graphics.drawq

function love.graphics.drawq( image, quad, x, y, r, sx, sy, ox, oy, kx, ky ) 

    love.graphics.draw(image, quad, x, y, r, sx, sy, ox, oy, kx, ky)

end    

--http://www.love2d.org/wiki/love.graphics.draw

--works

--http://www.love2d.org/wiki/love.graphics.quad

function love.graphics.quad(mode, x1, y1, x2, y2, x3, y3, x4, y4)

    love.graphics.polygon(mode, x1, y1, x2, y2, x3, y3, x4, y4)

end

local oldQuad = love.graphics.newQuad

function love.graphics.newQuad(...)
  local quad = oldQuad(...)
  local o = getmetatable( quad )
  function o:flip(  )
    
  end
  return quad
end

local oldSupported = love.graphics.isSupported

function love.graphics.isSupported( ... )
  local arg = {...}
  local t = {}
  for i,v in ipairs(arg) do
    if v == "pixeleffect" then
      table.insert(t,oldSupported('shader'))
    else
      table.insert(t,oldSupported(v))
    end
  end
  return unpack(t)
end

function love.graphics.newPixelEffect(...)
  local args = {...}
  return love.graphics.newShader(args[1])
end

function love.graphics.setPixelEffect(...)
  return love.graphics.setShader(...)
end

local oldSpriteBatch = love.graphics.newSpriteBatch

function love.graphics.newSpriteBatch( ... )
  local quad = oldSpriteBatch(...)
  local o = getmetatable(quad)

  function o:addq(...)
    self:add(...)
  end

  function o:setq(...)
    self:set(...)
  end

  return quad
end

--http://www.love2d.org/wiki/love.graphics.triangle

function love.graphics.triangle( mode, x1, y1, x2, y2, x3, y3 )

    love.graphics.polygon(mode, x1, y1, x2, y2, x3, y3)

end

local newParticle = love.graphics.newParticleSystem

function love.graphics.newParticleSystem( texture, buffer )
  local ps = newParticle( texture, buffer )

  local o = getmetatable( ps )

  function o:count()
    return self:getCount()
  end

  function o:getOffsetX()
    local x,y = self:getOffset( )
    return x
  end

  function o:getOffsetY()
    local x,y = self:getOffset( )
    return y
  end

  function o:getX()
    local x,y = self:getPosition()
    return x
  end

  function o:getY()
    local x,y = self:getPosition()
    return y
  end

  function o:isFull()
    return self:count() >= self:getBufferSize()
  end

  function o:isEmpty()
    return self:count() <= 0
  end

  function o:setGravity(ymin, ymax)
    local xmin, _ymin, xmax, _ymax = self:getLinearAcceleration()
    self:setLinearAcceleration( xmin, ymin, xmax, ymax )
  end

  function o:setLifetime( life )
    self:setEmitterLifetime(life)
  end

  function o:setParticleLife( life )
    self:setParticleLifetime(life)
  end

  function o:setSprite( image )
    self:setImage( image )
  end
  local old = o.setSizeVariation
  function o:setSizeVariation( n )
    if n > 1 then 
      n = 1
    elseif n < 0 then
      n = 0
    end
    old(self,n)

  end

  return ps

end


-- http://www.love2d.org/wiki/love.filesystem.enumerate

love.filesystem.enumerate = love.filesystem.getDirectoryItems


-- http://www.love2d.org/wiki/love.filesystem.mkdir

love.filesystem.mkdir = love.filesystem.createDirectory

-- The NamedThread class provides the Love 0.8.0
-- thread interface in Love 0.9.0

local oldThread = love.thread.newThread 

local NamedThread = {}
NamedThread.__index = NamedThread

function NamedThread:init(name, filedata)
  self.thread = oldThread(filedata)
  self.name = name
end

function NamedThread:start()
  return self.thread:start()
end

function NamedThread:wait()
  return self.thread:wait()
end

function NamedThread:set(name, value)
  local channel = love.thread.getChannel(name)
  while channel:pop() do
  end
  return channel:push(value) 
end

function NamedThread:peek(name)
  local channel = love.thread.getChannel(name)
  return channel:peek()
end

function NamedThread:get(name)
  if name == "error" then
    return self.thread:getError()
  end
  local channel = love.thread.getChannel(name)
  return channel:pop()
end

function NamedThread:getName( ... )
  return self.name
end


function NamedThread:demand(name)
  local channel = love.thread.getChannel(name)
  return channel:demand()
end

local _threads = {}

-- http://www.love2d.org/wiki/love.thread.newThread 
local function newThread(name, filedata)

  if filedata.typeOf and string.lower(filedata:typeOf()) == 'file'  then
    filedata:open('r')
    local string = filedata:read('a*')
    filedata:close()
    filedata:open('w')
    string = ___compat___..string
    filedata:write(string)
    filedata:close()
  elseif filedata.typeOf and string.lower(filedata:type()) == "filedata" then 
    local string = filedata:getString()
    filedata = love.filesystem.newFileData( ___compat___..string, 'file' )
  else
    local check = function (filename)
      for line in love.filesystem.lines(filename) do
        if line == "--checked" then
          return true
        end
      end
      return false
    end
    if not check(filedata) then
      filedata = love.filesystem.newFile(filedata)
      filedata:open('r')
      local string = filedata:read()
      filedata:close()
      filedata:open('w')
      string = ___compat___..string
      filedata:write(string)
      filedata:close()
    end
  end

  if _threads[name] then
    error("A thread with that name already exists.")
  end
  
  local thread = {}
  setmetatable(thread, NamedThread)
  thread:init(name, filedata)

  -- Mark this name as taken
  _threads[name] = true

  return thread
end

local function getThread()
  local thread = {}
  setmetatable(thread, NamedThread)
  return thread
end

love.thread.newThread = newThread
love.thread.getThread = getThread



  love.graphics.getCaption = love.window.getTitle

  function love.graphics.setCaption( title )
      return love.window.setTitle(title)
  end

  function love.graphics.checkMode( width, height, fullscreen )

      return true

  end

  function love.graphics.getMode( )

      local width, height, flags = love.window.getMode()

      local f = flags.fullscreen

      local v = flags.vsync

      local fsaa = flags.fsaa

      return width, height, f, v, fsaa 

  end

  love.graphics.getModes = love.window.getFullscreenModes

  love.graphics.hasFocus = love.window.hasFocus

  love.graphics.isCreated = love.window.isCreated

  function love.graphics.setIcon( image )

    return love.window.setIcon( image:getData())

  end

  function love.graphics.setMode( width, height, fullscreen, vsync, fsaa )

    return love.window.setMode( width, height, { fullscreen = fullscreen, vsync = vsync, fsaa = fsaa })

  end

  function love.graphics.toggleFullscreen()
    local fullscreen = love.window.getFullscreen( ) 
    return love.window.setFullscreen( not fullscreen )

  end


lovejoysticktable = {}

function love.joystickadded( joystick )

  table.insert( lovejoysticktable, joytick )

end  
  function love.joystick.close( )

  end

  function love.joystick.open( )

  end 

  function love.joystick.isOpen( i )

    return not not lovejoysticktable[i]

  end

  function love.joystick.getAxes( i )
    
    if lovejoysticktable[i] then

      return lovejoysticktable[i]:getAxes( )

    end

    return 0


  end 

  function love.joystick.getAxis( i, a )
    if lovejoysticktable[i] then

      return (lovejoysticktable[i]:getAxis( a ) or 0)

    end

    return 0

  end

  function love.joystick.getBall( )

  end

  function love.joystick.getHat( i, h )

    if lovejoysticktable[i] then

      return lovejoysticktable[ i ]:getHat( h )

    end

    return 'c'

  end

  function love.joystick.getName( i )

    if lovejoysticktable[i] then

      return lovejoysticktable[i]:getName()

    end

    return false

  end

  function love.joystick.getNumAxes( i )

    if lovejoysticktable[i] then

     return lovejoysticktable[i]:getAxisCount( )

   end

   return 0

  end

  function love.joystick.getNumButtons( i )
    if lovejoysticktable[i] then

      return lovejoysticktable[i]:getButtonCount()

    end

    return 0

  end

  function love.joystick.getNumHats( i )

    if lovejoysticktable[i] then

      return lovejoysticktable[i]:getHatCount( )

    end

    return 0

  end

  function love.joystick.getNumJoysticks( )

    return #lovejoysticktable


  end

  function love.joystick.isDown( i, b )

    if lovejoysticktable[i] then
      return lovejoysticktable[i]:isDown( b )
    else 
      return false
    end   

 end 

function love.joystick.getNumBalls( )
  return 0

end

local oldAudio = love.audio.newSource

function love.audio.newSource( file, type )
  if type == 'stream' or type == 'static' or type == nil then
   return oldAudio(file, type )
  else
    return oldAudio(file)
  end
end

local delayKB_compat, intervalKB_compat = 0,0

function love.keyboard.setKeyRepeat( delay, interval )
  delayKB_compat = delay
  intervalKB_compat = interval
end

function love.keyboard.getKeyRepeat(  )
  return delayKB_compat,intervalKB_compat
end



function love.graphics.setColorMode()

end
function love.graphics.getColorMode()
  return 'modulate'
end

if love.event and love.handlers then
  love.handlers.keypressed = function ( b, s, r )
    local unicode = string.byte(b)
    if love.keypressed then return love.keypressed(b,unicode) end
  end
end

love._version = "0.8.0"

local requireOld = require

function require( string )
  for i,v in ipairs(modulesNeeded) do
    if string == 'love'..v then
    else
      return requireOld(string)
    end
  end
end
