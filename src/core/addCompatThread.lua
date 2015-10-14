require("love.filesystem")
local addCompat = require( "core.addCompat" )
local lovePath = love.thread.getChannel("lovePath")
local love = lovePath:demand()
local compat = lovePath:demand()
print(love.." is being compatalized") --lol made up the word. Is the ok?
addCompat.addCompat( love, compat )
print(love.." should work now!!! :)")