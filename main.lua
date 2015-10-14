if not arg[2] then
  print("usage:\n"..
  "vapor p gameid\n"..
  "vapor l\n")
end

vaporlib = require "vapor"

vapor = vaporlib.new()

vapor:getMirrorCollection():add(
  vapor.class.mirror.new({uri="http://api.myjson.com/bins/18lrw"}):download()
)

max_tries = 5
while not mirrors_done do

  if max_tries < 0 then
    print("[error] Mirror(s) could not be downloaded.")
    os.exit()
  else
    --print("Tries remaining #"..max_tries)
  end

  vapor:update()

  mirrors_done = true
  for _,mirror in pairs(vapor:getMirrorCollection():all()) do
    if mirror:getStatus() ~= vapor.status.ready then
      mirrors_done = false
      break
    end
    if mirror:getStatus() == vapor.status.fail then
      print("[error] Mirror has failed.")
      os.exit()
    end
  end

  max_tries = max_tries - 1

end

if arg[2] == "l" then

  for _,g in pairs(vapor:getGameCollection():all()) do
    print("game["..g:getIdentifier().."] "..g:getName())
  end

  for _,f in pairs(vapor:getFrameworkCollection():all()) do
    print("framework["..f:getIdentifier().."] "..f:getName())
  end


elseif arg[2] == "p" then

  -- Search for requested game with id matching arg[3]
  local game = vapor:getGameObject(tonumber(arg[3]))

  if not game then
    print("[error] No game with id "..arg[3]..".")
    os.exit()
  end

  game_stable = game:getRelease():getStableVersion()

  game:download()

  print("Targeting game '"..game:getName().."' ["..game:getIdentifier().."]")
  print("Size: ",game_stable:getSize())
  print("Hash: ",game_stable:getHash())

  framework = vapor:getFrameworkObject(game:getFramework())

  framework:download()

  framework_stable = framework:getRelease():getStableVersion()

  print("Targeting framework '"..framework:getName().."' ["..framework:getIdentifier().."]")
  print("Size: ",framework_stable:getSize())
  print("Hash: ",framework_stable:getHash())

  max_tries = 5

  while not done do

    if max_tries < 0 then
      print("[error] Game(s)/Framework(s) could not be downloaded.")
      break
    else
      --print("Tries remaining #"..max_tries)
    end

    vapor:update()

    local game_status = game_stable:getStatus()
    local framework_status = framework_stable:getStatus()

    if game_status == vapor.status.ready and framework_status == vapor.status.ready then
      game:play() -- ok, play the game!
      done = true
      print('[Game Played] SUCCESS')
    elseif game_status == vapor.status.fail then
      print("[Game Error] "..vapor.lang.translate("en",game_message))
      done = true
    elseif framework_status == vapor.status.fail then
      print("[Framework Error] "..vapor.lang.translate("en",framework_message))
      done = true
    end

    max_tries = max_tries - 1

  end
else
  print("unknown command: "..tostring(arg[2]))
end

love.event.quit()
