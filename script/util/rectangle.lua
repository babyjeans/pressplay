-- Rectangle.lua
--	babyjeans
--
---
Rectangle = class("Rectangle")

function Rectangle:init(x, y, w, h)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
end

function Rectangle:min() 
	return { x=self.x, y=self.y }
end

function Rectangle:max()
	return { x=self.x+self.w, y=self.y+self.h }
end

function Rectangle:contains(x, y)
	return x >= self.x and x <= self.x + self.w and
	       y >= self.y and y <= self.y + self.h 
end

function Rectangle:intersects(otherRect)
	local min = self:min()
	local max = self:max()

	local otherMin = otherRect:min()
	local otherMax = otherRect:max()

	if min.x > otherMax.x or max.x < otherMin.x or min.y > otherMax.y or max.y < otherMin.y then
		return false
	end
	return true
end

return Rectangle