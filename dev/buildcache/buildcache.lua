#!/usr/bin/lua5.1

require("json")

if not jit then
  print("Not using LuaJIT. This may be really slow.")
end

function file_get_contents(file)
  local f = io.open(file, "rb")
  local content = f:read("*all")
  f:close()
  return content
end

function file_put_contents(file,data)
  local f = io.open(file, "w")
  f:write(data)
  f:close()
end

function lpad(str, len, char)
  if char == nil then char = ' ' end
  return str .. string.rep(char, len - #str)
end

function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

http = require("socket.http")

dir = "cache"

os.execute("mkdir -p "..dir)

if arg[1] == "--cache" then
  checkcache = true
  print "Checking cache first..."
else
  print "Downloading..."
  checkcache = false
end

require("lib.bslf.bit").lut()
hashlib = require("lib/hash")

data = json.decode(file_get_contents("games.json"))
for _,game in pairs(data.games) do
  io.write(lpad(game.name,32))
  base = game.id.."-"..game.stable
  io.write("IMAGE")
  if checkcache and file_exists(dir.."/"..base..".png") then
    io.write("(CACHE)")
    image = file_get_contents(dir.."/"..base..".png")
  else
    io.write("(NEW)  ")
    image = http.request(game.image)
  end
  if string.len(image) > 0 then
    io.write("[OK]")
    file_put_contents(dir.."/"..base..".png",image)
  else
    io.write("[ZERO]")
  end
  io.write(" LOVE")
  stable = game.stable
  if checkcache and file_exists(dir.."/"..base..".love") then
    io.write("(CACHE)")
    love = file_get_contents(dir.."/"..base..".love")
  else
    io.write("(NEW)  ")
    love = http.request(game.sources[stable])
  end
  if love then
    local sha1obj = hashlib.sha1()
    sha1obj:process(love)
    local hash = sha1obj:finish()
    if hash == game.hashes[stable] then
      io.write("[OK]")
      file_put_contents(dir.."/"..base..".love",love)
    else
      io.write("[HASH MISMATCH]")
    end
  else
    io.write("[NULL DATA]")
  end
  io.write("\n")
end
