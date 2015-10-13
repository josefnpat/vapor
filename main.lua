function love.update()
  require("lovebird.lovebird").update()
end

vaporlib = require "vapor"

-- Find games lists
-- e.g. adds vapor.love2d.org/api & vapor.itch.io/api
-- This will also use the vapor.sources.local file as a fallback (first cache, then mount)
vapor = vaporlib.new()

--vapor:getSourceCollection():add(
--  vapor.class.source.new({uri="vapor.sources.local"}))
--vapor:getSourceCollection():add(
--  vapor.class.source.new({uri="http://vapor.love2d.org/source"}))
vapor:getMirrorCollection():add(
  vapor.class.mirror.new({uri="http://api.myjson.com/bins/1qy6m"}):download()
)

-- Download all sources. Failure is not an option!
max_tries = 3

while not mirrors_done do

  max_tries = max_tries - 1
  if max_tries < 0 then
    print("Could not download mirrors")
    os.exit()
  else
    print("Tries remaining #"..max_tries)
  end

  vapor:update()

  mirrors_done = true
  for _,mirror in pairs(vapor:getMirrorCollection():all()) do
    if mirror:getStatus() ~= vapor.status.ready then
      mirrors_done = false
      break
    end
    if mirror:getStatus() == vapor.status.fail then
      print("Mirror failure.")
      return
    end
  end

end

-- Search for requested game with id matching arg[1]
local game = vapor:getGameObject(tonumber(arg[2]))

if not game then
  print("Game not found.")
  return
end

game_stable = game:getRelease():getStableVersion()

game:download()

print("Downloading '"..game:getName().."'")
print("Size: ",game_stable:getSize())
print("Hash: ",game_stable:getHash())

framework = vapor:getFrameworkObject(game:getFramework())

framework:download()

framework_stable = framework:getRelease():getStableVersion()

if framework:getStatus() ~= vapor.status.ready then
  print("Downloading '"..framework:getName().."'")
  print("Size: "..framework_stable:getSize())
  print("Hash: "..framework_stable:getHash())
end

-- Spin until it's done downloading
max_tries = 5

while not done do

  max_tries = max_tries - 1
  if max_tries < 0 then
    print("Could not download game")
    break
  else
    print("Tries remaining #"..max_tries)
  end

  vapor:update()

  local game_status = game_stable:getStatus()
  local framework_status = framework_stable:getStatus()

  if game_status == vapor.status.ready and framework_status == vapor.status.ready then
    game:play() -- ok, play the game!
    done = true
    print('[Game Played] SUCCESS')
    love.event.quit()
  elseif game_status == vapor.status.fail then
    print("[Game Error] "..vapor.lang.translate("en",game_message))
    done = true
  elseif framework_status == vapor.status.fail then
    print("[Framework Error] "..vapor.lang.translate("en",framework_message))
    done = true
  end

end
