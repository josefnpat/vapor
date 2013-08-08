--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2013 Kenny Shields --
--]]------------------------------------------------

-- button class
local newobject = loveframes.NewObject("button", "loveframes_object_button", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()
	
	self.type = "button"
	self.text = "Button"
	self.width = 80
	self.height = 25
	self.internal = false
	self.down = false
	self.clickable = true
	self.enabled = true
	self.OnClick = nil
	
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
	
	self:CheckHover()
	
	local hover = self.hover
	local down = self.down
	local hoverobject = loveframes.hoverobject
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	
	if not hover then
		self.down = false
		if hoverobject == self then
			self.hover = true
		end
	else
		if hoverobject == self then
			self.down = true
		end
	end
	
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
	local drawfunc = skin.DrawButton or skins[defaultskin].DrawButton
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
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover = self.hover
	
	if hover and button == "l" then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
		self.down = true
		loveframes.hoverobject = self
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)
	
	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover = self.hover
	local down = self.down
	local clickable = self.clickable
	local enabled = self.enabled
	local onclick = self.OnClick
	
	if hover and down and clickable and button == "l" then
		if enabled then
			if onclick then
				onclick(self, x, y)
			end
		end
	end
	
	self.down = false

end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function newobject:SetText(text)

	self.text = text
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function newobject:GetText()

	return self.text
	
end

--[[---------------------------------------------------------
	- func: SetClickable(bool)
	- desc: sets whether the object can be clicked or not
--]]---------------------------------------------------------
function newobject:SetClickable(bool)

	self.clickable = bool
	
end

--[[---------------------------------------------------------
	- func: GetClickable(bool)
	- desc: gets whether the object can be clicked or not
--]]---------------------------------------------------------
function newobject:GetClickable()

	return self.clickable
	
end

--[[---------------------------------------------------------
	- func: SetClickable(bool)
	- desc: sets whether or not the object is enabled
--]]---------------------------------------------------------
function newobject:SetEnabled(bool)

	self.enabled = bool
	
end

--[[---------------------------------------------------------
	- func: GetEnabled()
	- desc: gets whether or not the object is enabled
--]]---------------------------------------------------------
function newobject:GetEnabled()

	return self.enabled
	
end