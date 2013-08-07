--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- util library
loveframes.util = {}

--[[---------------------------------------------------------
	- func: SetActiveSkin(name)
	- desc: sets the active skin
--]]---------------------------------------------------------
function loveframes.util.SetActiveSkin(name)
	
	loveframes.config["ACTIVESKIN"] = name

end

--[[---------------------------------------------------------
	- func: GetActiveSkin()
	- desc: gets the active skin
--]]---------------------------------------------------------
function loveframes.util.GetActiveSkin()
	
	local index = loveframes.config["ACTIVESKIN"]
	local skin = loveframes.skins.available[index]
	
	return skin

end

--[[---------------------------------------------------------
	- func: BoundingBox(x1, x2, y1, y2, w1, w2, h1, h2)
	- desc: checks for a collision between two boxes
	- note: i take no credit for this function
--]]---------------------------------------------------------
function loveframes.util.BoundingBox(x1, x2, y1, y2, w1, w2, h1, h2)

	if x1 > x2 + w2  or y1 > y2 + h2  or x2 > x1 + w1  or y2 > y1 + h1  then
		return false
	else
		return true
	end
	
end

--[[---------------------------------------------------------
	- func: loveframes.util.GetCollisions(object, table)
	- desc: gets all objects colliding with the mouse
--]]---------------------------------------------------------
function loveframes.util.GetCollisions(object, t)

	local x, y = love.mouse.getPosition()
	local curstate = loveframes.state
	local object = object or loveframes.base
	local visible = object.visible
	local children = object.children
	local internals = object.internals
	local objectstate = object.state
	local t = t or {}
	
	if objectstate == curstate and visible then
		local objectx = object.x
		local objecty = object.y
		local objectwidth = object.width
		local objectheight = object.height
		local col = loveframes.util.BoundingBox(x, objectx, y, objecty, 1, objectwidth, 1, objectheight)
		local collide = object.collide
		if col and collide then
			local clickbounds = object.clickbounds
			if clickbounds then
				local cx = clickbounds.x
				local cy = clickbounds.y
				local cwidth = clickbounds.width
				local cheight = clickbounds.height
				local clickcol = loveframes.util.BoundingBox(x, cx, y, cy, 1, cwidth, 1, cheight)
				if clickcol then
					table.insert(t, object)
				end
			else
				table.insert(t, object)
			end
		end
		if children then
			for k, v in ipairs(children) do
				loveframes.util.GetCollisions(v, t)
			end
		end
		if internals then
			for k, v in ipairs(internals) do
				local type = v.type
				if type ~= "tooltip" then
					loveframes.util.GetCollisions(v, t)
				end
			end
		end
	end
	
	return t

end

--[[---------------------------------------------------------
	- func: loveframes.util.GetAllObjects(object, table)
	- desc: gets all active objects
--]]---------------------------------------------------------
function loveframes.util.GetAllObjects(object, t)
	
	local object = object or loveframes.base
	local internals = object.internals
	local children = object.children
	local t = t or {}
	
	table.insert(t, object)
	
	if internals then
		for k, v in ipairs(internals) do
			loveframes.util.GetAllObjects(v, t)
		end
	end
	
	if children then
		for k, v in ipairs(children) do
			loveframes.util.GetAllObjects(v, t)
		end
	end
	
	return t
	
end

--[[---------------------------------------------------------
	- func: GetDirectoryContents(directory, table)
	- desc: gets the contents of a directory and all of
			its subdirectories
--]]---------------------------------------------------------
function loveframes.util.GetDirectoryContents(dir, t)

	local dir = dir
	local t = t or {}
	local files = love.filesystem.enumerate(dir)
	local dirs = {}
	
	for k, v in ipairs(files) do
		local isdir = love.filesystem.isDirectory(dir.. "/" ..v)
		if isdir == true then
			table.insert(dirs, dir.. "/" ..v)
		else
			local parts = loveframes.util.SplitString(v, "([.])")
			local extension = parts[#parts]
			parts[#parts] = nil
			local name = table.concat(parts)
			table.insert(t, {path = dir, fullpath = dir.. "/" ..v, requirepath = dir .. "." ..name, name = name, extension = extension})
		end
	end
	
	if #dirs > 0 then
		for k, v in ipairs(dirs) do
			t = loveframes.util.GetDirectoryContents(v, t)
		end
	end
	
	return t
	
end


--[[---------------------------------------------------------
	- func: Round(num, idp)
	- desc: rounds a number based on the decimal limit
	- note: i take no credit for this function
--]]---------------------------------------------------------
function loveframes.util.Round(num, idp)

	local mult = 10^(idp or 0)
	
    if num >= 0 then 
		return math.floor(num * mult + 0.5) / mult
    else 
		return math.ceil(num * mult - 0.5) / mult 
	end
	
end

--[[---------------------------------------------------------
	- func: SplitString(string, pattern)
	- desc: splits a string into a table based on a given pattern
	- note: i take no credit for this function
--]]---------------------------------------------------------
function loveframes.util.SplitString(str, pat)

	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	
	if pat == " " then
		local fpat = "(.-)" .. pat
		local last_end = 1
		local s, e, cap = str:find(fpat, 1)
		while s do
			if s ~= #str then
				cap = cap .. " "
			end
			if s ~= 1 or cap ~= "" then
				table.insert(t,cap)
			end
			last_end = e+1
			s, e, cap = str:find(fpat, last_end)
		end
		if last_end <= #str then
			cap = str:sub(last_end)
			table.insert(t, cap)
		end
	else
		local fpat = "(.-)" .. pat
		local last_end = 1
		local s, e, cap = str:find(fpat, 1)
		while s do
			if s ~= 1 or cap ~= "" then
				table.insert(t,cap)
			end
			last_end = e+1
			s, e, cap = str:find(fpat, last_end)
		end
		if last_end <= #str then
			cap = str:sub(last_end)
			table.insert(t, cap)
		end
	end
	
	return t
	
end

--[[---------------------------------------------------------
	- func: RemoveAll()
	- desc: removes all gui elements
--]]---------------------------------------------------------
function loveframes.util.RemoveAll()

	loveframes.base.children = {}
	loveframes.base.internals = {}
	
end

--[[---------------------------------------------------------
	- func: loveframes.util.TableHasKey(table, key)
	- desc: checks to see if a table has a specific key
--]]---------------------------------------------------------
function loveframes.util.TableHasKey(table, key)

	local haskey = false
	
	for k, v in pairs(table) do
		if k == key then
			haskey = true
			break
		end
	end
	
	return haskey
	
end

--[[---------------------------------------------------------
	- func: loveframes.util.Error(message)
	- desc: displays a formatted error message
--]]---------------------------------------------------------
function loveframes.util.Error(message)

	error("[Love Frames] " ..message)
	
end

--[[---------------------------------------------------------
	- func: loveframes.util.GetCollisionCount()
	- desc: gets the total number of objects colliding with
			the mouse
--]]---------------------------------------------------------
function loveframes.util.GetCollisionCount()

	local collisioncount = loveframes.collisioncount
	return collisioncount

end

--[[---------------------------------------------------------
	- func: loveframes.util.GetHover()
	- desc: returns loveframes.hover, can be used to check
			if the mouse is colliding with a visible
			Love Frames object
--]]---------------------------------------------------------
function loveframes.util.GetHover()

	return loveframes.hover
	
end
	