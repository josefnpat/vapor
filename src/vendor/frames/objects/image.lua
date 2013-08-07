--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- progressbar class
local newobject = loveframes.NewObject("image", "loveframes_object_image", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()

	self.type = "image"
	self.width = 0
	self.height = 0
	self.orientation = 0
	self.scalex = 1
	self.scaley = 1
	self.offsetx = 0
	self.offsety = 0
	self.shearx = 0
	self.sheary = 0
	self.internal = false
	self.image = nil
	self.imagecolor = nil
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	
	self:CheckHover()
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	if update then
		update(self, dt)
	end
	
end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function newobject:draw()
	
	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local skins = loveframes.skins.available
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	local drawfunc = skin.DrawImage or skins[defaultskin].DrawImage
	local draw = self.Draw
	local drawcount = loveframes.drawcount
	
	-- set the object's draw order
	self:SetDrawOrder()
		
	if draw then
		draw(self)
	else
		drawfunc(self)
	end
	
end

--[[---------------------------------------------------------
	- func: SetImage(image)
	- desc: sets the object's image
--]]---------------------------------------------------------
function newobject:SetImage(image)

	if type(image) == "string" then
		self.image = love.graphics.newImage(image)
	else
		self.image = image
	end
	
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	
end

--[[---------------------------------------------------------
	- func: GetImage()
	- desc: gets the object's image
--]]---------------------------------------------------------
function newobject:GetImage()

	return self.image
	
end

--[[---------------------------------------------------------
	- func: SetColor(r, g, b, a)
	- desc: sets the object's color 
--]]---------------------------------------------------------
function newobject:SetColor(r, g, b, a)

	self.imagecolor = {r, g, b, a}
	
end

--[[---------------------------------------------------------
	- func: GetColor()
	- desc: gets the object's color 
--]]---------------------------------------------------------
function newobject:GetColor()

	return unpack(self.imagecolor)
	
end

--[[---------------------------------------------------------
	- func: SetOrientation(orientation)
	- desc: sets the object's orientation
--]]---------------------------------------------------------
function newobject:SetOrientation(orientation)

	self.orientation = orientation
	
end

--[[---------------------------------------------------------
	- func: GetOrientation()
	- desc: gets the object's orientation
--]]---------------------------------------------------------
function newobject:GetOrientation()

	return self.orientation
	
end

--[[---------------------------------------------------------
	- func: SetScaleX(scalex)
	- desc: sets the object's x scale
--]]---------------------------------------------------------
function newobject:SetScaleX(scalex)

	self.scalex = scalex
	
end

--[[---------------------------------------------------------
	- func: GetScaleX()
	- desc: gets the object's x scale
--]]---------------------------------------------------------
function newobject:GetScaleX()

	return self.scalex
	
end

--[[---------------------------------------------------------
	- func: SetScaleY(scaley)
	- desc: sets the object's y scale
--]]---------------------------------------------------------
function newobject:SetScaleY(scaley)

	self.scaley = scaley
	
end

--[[---------------------------------------------------------
	- func: GetScaleY()
	- desc: gets the object's y scale
--]]---------------------------------------------------------
function newobject:GetScaleY()

	return self.scaley
	
end

--[[---------------------------------------------------------
	- func: SetScale(scalex, scaley)
	- desc: sets the object's x and y scale
--]]---------------------------------------------------------
function newobject:SetScale(scalex, scaley)

	self.scalex = scalex
	self.scaley = scaley
	
end

--[[---------------------------------------------------------
	- func: GetScale()
	- desc: gets the object's x and y scale
--]]---------------------------------------------------------
function newobject:GetScale()

	return self.scalex, self.scaley
	
end

--[[---------------------------------------------------------
	- func: SetOffsetX(x)
	- desc: sets the object's x offset
--]]---------------------------------------------------------
function newobject:SetOffsetX(x)

	self.offsetx = x
	
end

--[[---------------------------------------------------------
	- func: GetOffsetX()
	- desc: gets the object's x offset
--]]---------------------------------------------------------
function newobject:GetOffsetX()

	return self.offsetx
	
end

--[[---------------------------------------------------------
	- func: SetOffsetY(y)
	- desc: sets the object's y offset
--]]---------------------------------------------------------
function newobject:SetOffsetY(y)

	self.offsety = y
	
end

--[[---------------------------------------------------------
	- func: GetOffsetY()
	- desc: gets the object's y offset
--]]---------------------------------------------------------
function newobject:GetOffsetY()

	return self.offsety
	
end

--[[---------------------------------------------------------
	- func: SetOffset(x, y)
	- desc: sets the object's x and y offset
--]]---------------------------------------------------------
function newobject:SetOffset(x, y)

	self.offsetx = x
	self.offsety = y
	
end

--[[---------------------------------------------------------
	- func: GetOffset()
	- desc: gets the object's x and y offset
--]]---------------------------------------------------------
function newobject:GetOffset()

	return self.offsetx, self.offsety
	
end

--[[---------------------------------------------------------
	- func: SetShearX(shearx)
	- desc: sets the object's x shear
--]]---------------------------------------------------------
function newobject:SetShearX(shearx)

	self.shearx = shearx
	
end

--[[---------------------------------------------------------
	- func: GetShearX()
	- desc: gets the object's x shear
--]]---------------------------------------------------------
function newobject:GetShearX()

	return self.shearx
	
end

--[[---------------------------------------------------------
	- func: SetShearY(sheary)
	- desc: sets the object's y shear
--]]---------------------------------------------------------
function newobject:SetShearY(sheary)

	self.sheary = sheary
	
end

--[[---------------------------------------------------------
	- func: GetShearY()
	- desc: gets the object's y shear
--]]---------------------------------------------------------
function newobject:GetShearY()

	return self.sheary
	
end

--[[---------------------------------------------------------
	- func: SetShear(shearx, sheary)
	- desc: sets the object's x and y shear
--]]---------------------------------------------------------
function newobject:SetShear(shearx, sheary)

	self.shearx = shearx
	self.sheary = sheary
	
end

--[[---------------------------------------------------------
	- func: GetShear()
	- desc: gets the object's x and y shear
--]]---------------------------------------------------------
function newobject:GetShear()

	return self.shearx, self.sheary
	
end

--[[---------------------------------------------------------
	- func: GetImageSize()
	- desc: gets the size of the object's image
--]]---------------------------------------------------------
function newobject:GetImageSize()

	local image = self.image
	
	if image then
		return image:getWidth(), image:getHeight()
	end
	
end

--[[---------------------------------------------------------
	- func: GetImageWidth()
	- desc: gets the width of the object's image
--]]---------------------------------------------------------
function newobject:GetImageWidth()

	local image = self.image
	
	if image then
		return image:getWidth()
	end
	
end

--[[---------------------------------------------------------
	- func: GetImageWidth()
	- desc: gets the height of the object's image
--]]---------------------------------------------------------
function newobject:GetImageHeight()

	local image = self.image
	
	if image then
		return image:getHeight()
	end
	
end