-- vcrs.lua
--	babyjeans
--
---
local VCR = class("VCR")
local benchStateHandlers = {
	closed = {
		onClick = function(self, x, y, button, released)
			if released and button == 1 then
				self.benchState = 'flipped'
			end					
	 	end,
	},
	flipped = {
		checkScrews = true,
		drawScrews = true,

		onClick = function(self, x, y, button, released)
			if released then
				if button == 1 and self:unscrewed('flipped') then 
					self.benchState = 'open'
				elseif button == 2 then
					self.benchState = 'closed'
				end
			end
		end,
	},
	open = {
		checkInnards = true,
		drawScrews = true,
		drawInnards = true,

		onClick = function(self, x, y, button, released)
			if released and button == 2 then
				self.benchState = 'flipped'
			end
		end,
		
		afterDraw = function(self)
			if self.panelLip ~= nil then
				love.graphics.draw(self.panelLip, self.x, self.y)
			end
		end,
	}
}

function VCR:init(name, closed, flipped, open, panelLip, shadows)
	self.name = name

	self.closed = Resources.workBench[closed]
	self.flipped = Resources.workBench[flipped]
	self.open = Resources.workBench[open]
	self.panelLip = Resources.workBench[panelLip]
	self.shadows = vector()
	for i, shadow in ipairs(shadows) do
		self.shadows:add({ resource=Resources.workBench[shadow[1]],x=shadow[2],y=shadow[3]	 })
	end

	self.screws = { }
	self.innards = { }
	self.wires = { }

	self.x = 0
	self.y = 0
	self.w = self.closed:getWidth()
	self.h = self.closed:getHeight()

	self.visible = true
	self.benchState = 'closed'

    ClickGuy:listenClick(function(x, y, button, pressed, released)
			self:handleClick(x, y, button, pressed, released)
	end)
end

function VCR:loadMods(modList)
	local mods = { }
	self.mods = mods
    self:forEachComponent(function(component) 
        for i, modName in ipairs(modList) do
            component:loadMod(modName)
        end
     end, true)
	
	return mods
end

function VCR:forEachComponent(func, inclChild, inclScrews)
	for sectionName, section in pairs(self.innards) do
		for layerIndex, layer in ipairs(section.contents) do
			for componentIndex, component in ipairs(layer.contents) do
				func(component)
                if inclChild and component.children then
                    local function _recursiveForChild(parent) 
                        if not parent or not parent.children then 
                            return
                        end

                        for i, child in ipairs(parent.children.contents) do
                            func(child.attached)
                            _recursiveForChild(child.attached)
                        end                                            
                    end
                    _recursiveForChild(component)
                end
			end
		end
	end

	if inclScrews then
		for k, screwSection in pairs(self.screws) do
			for i, screw in ipairs(screwSection.contents) do
				func(screw)
			end
		end
	end
end

function VCR:checkScrews(x, y, button, released)
	if not released then
		return
	end

	if button == 1 then
		for i, screw in ipairs(self.screws[self.benchState].contents) do
			if screw:checkPoint(x, y) and screw:onClick(x, y, button, released) then
				return true
			end
		end	
	end
end

function VCR:checkInnards(x, y, button, released)
	if not button==1 then return end

	local section = self.innards[self.benchState]
	local numLayers = section:count()

	for layerIndex=numLayers,1,-1 do 
		local layer = section.contents[layerIndex]
		local numInnards = layer:count()
		for innardIndex=numInnards,1,-1 do
			local innard = layer.contents[innardIndex]
			local checked = innard:checkPoint(x, y) 
			if checked and checked:onClick(x, y, button, released) then
				return true
			end
		end
	end
end

function VCR:handleClick(x, y, button, pressed, released)
	if not self.clickable then
		return
	end
	
	local box = Rectangle(self.x, self.y, self.w, self.h)
	if box:contains(x, y) then
		local handler = benchStateHandlers[self.benchState]

		if (handler.checkScrews and self:checkScrews(x, y, button, released)) or
		   (handler.checkInnards and self:checkInnards(x, y, button, release)) then
			return true;
		end
		
		handler.onClick(self, x, y, button, released)
		return true
	end
end

function VCR:collidesWith(component, newPos)
	local componentLayer = { top = component.layer.top, bottom = component.layer.bottom }
	local collisions = vector()

	local rect = component:rect(newPos.x, newPos.y)
	local section = self.innards[self.benchState]

	local function boundCheck(target, component)
		return  ( (target.layer.top >= component.layer.bottom and 
				   target.layer.top <= component.layer.top) 
				   or 
				  (target.layer.bottom  >= component.layer.bottom and 
				   target.layer.bottom <= component.layer.top) )
	end

	local function FILO(target, component)
		local above = component.layer.top <= target.layer.top or
			   		  component.layer.bottom <= target.layer.top
		return not above
	end

	-- for switching easier / quicker
	local layerFunction = FILO
	local collisionHelpers = {}


	collisionHelpers.checkCollision = function(target, component)
		local otherRect = target:rect()
		if otherRect:intersects(rect) and not layerFunction(target, component) then
			collisions:add(target) 
		else 
			collisionHelpers.checkChild(target, component)
		end
	end

	collisionHelpers.checkChild = function(parent, component)
		if parent.children then
			for i, child in ipairs(parent.children.contents) do
				if child.attached and child.attached ~= component then
					if not component:filterCollision(child.attached) then
						collisionHelpers.checkCollision(child.attached, component)
					end
				end
			end
		end
	end

	for layerIndex, layer in ipairs(section.contents) do
		for index, innard in ipairs(layer.contents) do
			if (component ~= innard) then
				local shouldFilter = component:filterCollision(innard)
				if not shouldFilter then
					collisionHelpers.checkCollision(innard, component)
				end
			end
		end
	end

--[[DEBUG: Show Collisions
	if collisions:count() > 0 then
		for i, collision in ipairs(collisions.contents) do
			print ("	"  .. collision.name)
		end
	end
	ENDDEBUG]]

	return collisions.contents
end

function VCR:isInBounds(component, newPos)
	local x, y = component:getAbsPos()
	x = (x + (newPos.x - component.x)) - self.x
	y = (y + (newPos.y - component.y)) - self.y
	
	return x >= 0 and x + component.w <= self.w and
		   y >= 0 and y + component.h <= self.h 
end

function VCR:moveInBounds(component)
	local x, y = component:getAbsPos()
	x = x - self.x
	y = y - self.y
	
	local newX = x
	local newY = y

	if x < 0 then 
		newX = 0 
	elseif x + component.w > self.w then 
		newX = self.w - component.w 
	end
	
	if y < 0 then 
		newY = 0 
	elseif y + component.h > self.h then 
		newY = self.h - component.h 
	end
	
	component:setAbsPos(self.x + newX, self.y + newY)
end

function VCR:drawScrews()
	local screws = self.screws[self.benchState]
	if screws then 
		for i, screw in ipairs(screws.contents) do
			screw:draw()
		end
	end
end

function VCR:drawInnards()
	local innards = self.innards[self.benchState]
	for layerIndex, layer in ipairs(innards.contents) do
		for index, innard in ipairs(layer.contents) do
			innard:draw()
		end
	end
end

function VCR:draw()
	if not self.visible then 
		return
	end

	love.graphics.setColor(20, 17, 20, 128)
	for shadowIndex, shadow in ipairs(self.shadows.contents) do
		love.graphics.draw(shadow.resource, self.x + shadow.x, self.y + shadow.y)
	end
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self[self.benchState], self.x, self.y)
	
	local handler = benchStateHandlers[self.benchState]
	if handler.preDraw then handler.preDraw(self) end
	if handler.drawScrews then self:drawScrews() end
	if handler.drawInnards then self:drawInnards() end
	if handler.afterDraw then handler.afterDraw(self) end	
end

function VCR:addScrew(sectionName, x, y, resource)
	local section = self.screws[sectionName] or vector()
	self.screws[sectionName] = section

	local screw = VCRComponent("Screw", x, y)
	screw:setResources({ resource })
	screw.componentType = 'screw'
	screw.parent = self
	screw.clickable = true
	screw.draggable = false
	screw.invisibleClick = true
	screw.clickFunc = function(self) self.visible = not self.visible end
	section:add(screw)	
end

function VCR:addWire(sectionName, layerNum, from, to, x, y, resource)
	if type(resource) ~= 'table' then resource = { resource } end
	local wire = VCRWire(from .. "2" .. to, from, to, x, y, resource)
	self:addComponent(sectionName, layerNum, wire)
end

function VCR:unscrewed(sectionName)
	for i, screw in ipairs(self.screws[sectionName].contents) do
		if screw.visible then return false end
	end

	return true
end

function VCR:addComponent(sectionName, layerNum, component, connection)
	component.parentVCR = self
	component.layer = { top = component.layerThickness.above + layerNum, bottom = layerNum - component.layerThickness.below }
	
	if connection == nil then
		local section = self.innards[sectionName] or vector()
		self.innards[sectionName] = section

		while section:count() < layerNum do
			section:add(vector())
		end

		local layer = section.contents[layerNum]
		layer:add(component)
		component.parent = self
	end
end

function VCR:getAbsPos()
	return self.x, self.y
end

return VCR