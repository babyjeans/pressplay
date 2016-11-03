-- vcrcomponent.lua
--	babyjeans
--
--	base class for VCR components
--	the VCRComponent heavily expects a VCRComponentBuilder to be creating it
---
local VCRComponent = class("VCRComponent")
local VCRComponentMod = require('script/game/vcr/vcrcomponentmod')

VCRComponent.drawHelper = class("DrawHelper")
local drawHelper = VCRComponent.drawHelper

function drawHelper:init(component, resource)
	self.name = component.name
	self.component = component
	self.resource = resource
	self.w = self.resource:getWidth()
	self.h = self.resource:getHeight()
end

function drawHelper:draw()
	if self.component.visible and self.component.enabled then
		local x, y = self.component:getAbsPos()
		love.graphics.draw(self.resource, x, y)
	end
end

VCRComponent.acceptHelper = class("AcceptHelper")
local acceptHelper = VCRComponent.acceptHelper
function acceptHelper:init(component, acceptTable)
	self.component = component
	self.acceptTable = acceptTable
end

function acceptHelper:draw()
	local attachment = self.acceptTable.attached 
	if attachment and not attachment.isDragging then
		attachment.x = self.acceptTable.x
		attachment.y = self.acceptTable.y
		attachment:draw()
	end
end

--
--	init / creation
---
function VCRComponent:init(name, x, y)
	self.name = name
	self.componentType = 'component'

	self.x = x
	self.y = y
	self.w = 0
	self.h = 0
	self.positioning = 'relative'
    
	self.layerThickness = { above=0, below=0 }
	self.drawList = { }
	self.accepts  = { }
	self.collisionFilter = { }
	self.tags    = { }
	self.modList = { }
	self.children = vector()
	
	self.draggable = true
	self.clickable = true
	self.visible = true
	self.enabled = true
    
    self.layer = { }
	self.tags = { }
end

function VCRComponent:setResources(resources)
	self.resources = resources
	self.w = 0
	self.h = 0
	self.drawList = { }
	for i, resource in ipairs(resources) do 
		local dh = VCRComponent.drawHelper(self, Resources.workBench[resource])

		self.w = math.max(self.w, dh.w)
		self.h = math.max(self.h, dh.h)

		self.drawList[i] = dh
	end

	-- re-add the previous accept drawhelpers
	for name, accept in pairs(self.accepts) do
		table.insert(self.drawList, accept.order, VCRComponent.acceptHelper(self, self.accepts[name]))
	end
end

function VCRComponent:setAccepts(accepts)
	if accepts then
		for name, accept in pairs(accepts) do
			self.accepts[name] = { x = accept.anchor.x, y = accept.anchor.y, order=accept.order }
			table.insert(self.drawList, accept.order, VCRComponent.acceptHelper(self, self.accepts[name]))
		end
	end
end

function VCRComponent:setLayerThickness(layerThickness)
	if layerThickness then
		self.layerThickness.above = layerThickness.above or 0
		self.layerThickness.below = layerThickness.below or 0
	end

end

function VCRComponent:setCollisionInfo(filter, tags)
	self.collisionFilter = filter or { }
	self.tags = tags or { }
end

function VCRComponent:setMods(modList)
	self.modList = { }
	for name, modFunc in pairs(modList) do
		self.modList[name] = modFunc
	end
end

--
-- accessors / mutators
---
function VCRComponent:getAbsPos()
	local x = self.x
	local y = self.y

	if self.parent then
		local px, py = self.parent:getAbsPos()
		x = x + px
		y = y + py
	end

	return x, y
end

function VCRComponent:setAbsPos(x, y)
	local px, py = self:getAbsPos()
	x = x - px
	y = y - py
	self.x = self.x + x
	self.y = self.y + y
end

function VCRComponent:rect(x, y)
	local ax, ay = self:getAbsPos()
	if x then ax = ax + (x - self.x) end
	if y then ay = ay + (y - self.y)  end
	return Rectangle(ax, ay, self.w, self.h)
end

--
---
function VCRComponent:attach(targetName, component) 
	if self.accepts[targetName] and not self.accepts[targetName].attached then
		self.accepts[targetName].attached = component
		self.children:add( self.accepts[targetName] )
		component.parent = self
		return true
	end
end

function VCRComponent:loadMod(modName)
	local modFunc = self.modList[modName]
	if modFunc then
		return VCRComponentMod(self, modFunc):begin()
	end
end

--
---
function VCRComponent:filterCollision(otherComponent)
    if self.visible == false or self.enabled == false then
        return true
    end

	local filtered = false
	for tagIndex, tag in ipairs(self.tags) do
		if tag == 'no_collide' then
			filtered = true
			break
		end
	end

	if not filtered then
		if #otherComponent.tags == 0 then
			for i, filter in ipairs(self.collisionFilter) do
				if filter == otherComponent.componentType then
					filtered = true
					break
				end
			end
		else
			for j, tag in ipairs(otherComponent.tags) do
				if tag == 'no_collide' then
					filtered = true 
				else
					for i, filter in ipairs(self.collisionFilter) do
						if filter == otherComponent.componentType or filter == tag then
							filtered = true
							break
						end
					end
				end

				if filtered then
					break
				end
			end
		end
	end

	return filtered
end

function VCRComponent:checkPoint(px, py)
    if not self.visible or not self.enabled then
        return false
    end

	local x, y = self:getAbsPos()
	local box = Rectangle(x, y, self.w, self.h)
	if box:contains(px, py) then 
		return self 
	end

	for i, child in ipairs(self.children.contents) do
		if child.attached then
			local ret = child.attached:checkPoint(px, py)
			if ret then
				return ret
			end
		end
	end
end

--
-- input handling
---
function VCRComponent:onClick(mouseX, mouseY, button, released)
	if self.visible and self.enabled then 
        if button == 1 then
    		if self.clickable then
    			if self.draggable and not released then
    				local absX, absY = self:getAbsPos()
    				self.preDrag = { 
    					x=absX, y=absY,
    					click = { x = mouseX, y = mouseY }, 
    				}
    				ClickGuy:queueDrag(self)
    			end

    			if released then
    				if self.clickFunc then self:clickFunc() end
    			end
    		end

    		return true
    	end
    end
	return false
end

function VCRComponent:beginDrag(mouseX, mouseY)
	if self.draggable and self.enabled and self.visible then
		--local click = self.preDrag.click
		--self.x = self.x + (mouseX - click.x)
		--self.y = self.y + (mouseY - click.y)
		love.mouse.setVisible(false)
		love.mouse.setRelativeMode(true)
	end
end

function VCRComponent:updateDrag(mouseX, mouseY, dx, dy)
	if self.draggable then
		local vcr = self.parentVCR
		local startVec = Vector2(self.x, self.y)
		local endVec = Vector2(self.x + dx, self.y + dy)

		local path = startVec - endVec
		local pathNorm = path:norm()
		local pathLen = path:magsq()
		local radius = math.min(self.w, self.h) * 0.5
	
		-- move in steps
		local collided = false
		local newPos = startVec
		
		local function sweep(speed)
			while true do
				self.x = newPos.x
				self.y = newPos.y

				newPos = Vector2(self.x, self.y) + (pathNorm * speed)
				
				if vcr:isInBounds(self, newPos) then
					collided = #self.parentVCR:collidesWith(self, newPos) > 0
					if collided then 
						break
					end

					if (newPos - startVec):magsq() >= pathLen then
						self.x = endVec.x
						self.y = endVec.y
						break
					end
				else
					break
				end
			end
		end

		sweep(radius)
		newPos.x = self.x
		newPos.y = self.y
		sweep(1)	
	end
end

function VCRComponent:cancelDrag()
	if self.draggable then
		self:setAbsPos(self.preDrag.x, self.preDrag.y)
	end
	love.mouse.setVisible(true)
	love.mouse.setRelativeMode(false)
	self.preDrag = {}
end

--
-- update / draw
---
function VCRComponent:draw()
	for i, dh in ipairs(self.drawList) do
		dh:draw()
	end
end

return VCRComponent