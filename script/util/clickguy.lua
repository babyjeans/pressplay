-- clickGuy
--	handle click listening
--
---
local ClickGuy = class("ClickGuy")
function ClickGuy:init()
	self.clickHandlers = vector()
	app:hookUpdate({self, self.update})

	self.lastClick = love.timer.getTime()
	self.dragCancelHandlers = vector()
end
	
function ClickGuy:listenClick(handler)
	self.clickHandlers:add(handler)
end

function ClickGuy:listenDragCancel(func, permanent)
	local listener = { func, permanent or false }
	self.dragCancel:add(listener)
	return listener
end

function ClickGuy:remove(handler)
	return self.clickHandlers:remove(handler)
end

function ClickGuy:handleClick(x, y, button, isTouch, pressed, released)
	if released then
		self:endDrag()
	end

	for i, h in ipairs(self.clickHandlers.contents) do
		if h(x, y, button, pressed, released) then
			return
		end
	end
end

function ClickGuy:onMouseMoved(x, y, dx, dy, isTouch)
	if self.dragging then
		self.dragging:updateDrag(x, y, dx, dy)
	end	
end

function ClickGuy:update()
	if self.pendingDraggable and self.dragTriggerTime then
		local currentTime = love.timer.getTime()
		if currentTime >= self.dragTriggerTime then
			self:startDrag()
		end
	end

	if not love.mouse.isDown(1) then
		self:endDrag()
	end
end

function ClickGuy:queueDrag(draggable, dragDelay)
	if self.pandingDraggable or self.dragging then return end
	self.pendingDraggable = draggable
	self.dragTriggerTime = love.timer.getTime() + (dragDelay or 0.25)
	return self
end

function ClickGuy:startDrag()
	if not self.dragging then
		self.dragging = self.pendingDraggable
		self.dragging.isDragging = true
		self.dragging:beginDrag(love.mouse.getPosition())
	end

	self.pendingDraggable = nil
	self.dragTriggerTime = nil
end

function ClickGuy:endDrag()
	if self.dragging then 
		self.dragging:cancelDrag()
		self.dragging.isDragging = false
		self.dragging = nil		
	end
	
	if self.pendingDraggable then
		self.pendingDraggable =  nil
		self.dragTriggerTime = nil
	end
end

local clickGuy = ClickGuy()
function love.mousepressed(x, y, button, isTouch)
	clickGuy:handleClick(x, y, button, isTouch, true, false)
end

function love.mousereleased(x, y, button, isTouch)
	clickGuy:handleClick(x, y, button, isTouch, false, true)
end

function love.mousemoved(x, y, dx, dy, istouch)
	clickGuy:onMouseMoved(x, y, dx, dy, istouch)
end

return clickGuy