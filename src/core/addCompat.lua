require("love.filesystem")

local function unZipLove( fn )

	love.filesystem.mount( fn, string.gsub(fn, "%.([%w%-]+)$", "") )
	love.filesystem.createDirectory( "unziped-"..string.gsub(fn, "%.([%w%-]+)$", "") )

	local path = string.gsub(fn, "%.([%w%-]+)$", "")


	local function callback(folder)
		
	end 

	local folder = love.filesystem.getDirectoryItems( string.gsub(fn, "%.([%w%-]+)$", ""), callback )

	local function  recurseFolder( folder, path, prefix )

		for i,file in ipairs( folder ) do
			
			if love.filesystem.isDirectory( path .. "/".. file ) then

				local folder = love.filesystem.getDirectoryItems( path .. "/"..file, callback )

				love.filesystem.createDirectory(prefix..path.."/"..file)

				recurseFolder( folder, path .. "/".. file, prefix )

			elseif love.filesystem.isFile( path .."/" .. file ) then			

				local content = love.filesystem.read(path.."/"..file)

				love.filesystem.write(prefix..path.."/"..file, content)

			end

		end

		return prefix..path

	end

	return recurseFolder( folder, path, "unziped-")

end

local function overwriteFile( file, data, ln )

	local file = love.filesystem.newFile( file )
	local i = 0
	local newData = ''
	 for line in file:lines( ) do
	 	i = i + 1
	 	if i == ln then

	 		newData = newData.."\r\n"..data

	 	elseif i == 1 and ln == 0 then
	 	
	 		newData = data

	 	end
	 	
	 	newData = newData.."\r\n"..line		

	 end
	 file:open("w")
	 file:write( newData )

	 file:close()
	 

end

local function findAndWrite( file, find, data )

	local file = love.filesystem.newFile( file )
	local found = false
	local newData = ''
	 for line in file:lines( ) do
	 	if line == find then

	 		newData = newData.."\r\n"..line.."\r\n"..data

	 		found = true

	 	else
	 	
	 		newData = newData.."\r\n"..line	

	 	end	

	 end

	 file:open("w")
	 file:write( newData )

	 file:close()

	 return found
	 

end

local function addCompat( pathLove, pathCompat )

	local path = unZipLove( pathLove )

	overwriteFile( path.."/main.lua", "require 'compat'\r\n", 0 )

	love.filesystem.append(path.."/conf.lua", " local oldConf = love.conf\r\n love.conf = function (t) t.screen = t.window \r\n if oldConf then oldConf(t) end end")

	local file = love.filesystem.newFile( path.."/compat.lua" )

	local compat = love.filesystem.newFile( pathCompat )

	compat:open("r")

	compatData = compat:read()

	file:open("w")

	file:write(compatData)

	compat:close()

	file:close()

end

local function addCompatThread( fn, lib )

	local compat_thread = love.thread.newThread( "core/addCompatThread.lua" )
    local channel       = love.thread.getChannel( "lovePath" )
    print(fn,lib)
    channel:push( fn )
  	channel:push( lib )
  	vapor.currently_installing[fn] = compat_thread
  	print("starting to install"..fn)
  	compat_thread:start( )

end

return  { addCompatThread = addCompatThread ,addCompat = addCompat }