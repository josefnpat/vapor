require("love.filesystem")

require("lib.bslf.bit").lut()
hashlib = require("lib.hash")

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

thisThread = love.thread.getThread()

fname = thisThread:demand("fname")

print(fname .. " is hashing.")
socket = require "socket"
local data = love.filesystem.read(fname)
local start = socket.gettime()

local sha1obj = hashlib.sha1()
sha1obj:process(data)
local hash = sha1obj:finish()

local stop = socket.gettime()

local sizemb,time = #data/(1024^2),stop-start
local mbps = sizemb/time

print(("%s MiB/s (%s MiB in %s s)"):format(
  round(mbps,4),
  round(sizemb,4),
  round(time,4)
))

love.filesystem.write(fname..".sha1",hash)
print(fname .. " hashed.")
