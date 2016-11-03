-- vector.lua
--	babyjeans
--
---
local vector = class("vector")
function vector:init()
	self.contents = { }
end

function vector:empty() return #self.contents == 0 end
function vector:count() return #self.contents end
function vector:clear() self.contents = { } end

function vector:add(item)
	local count = #self.contents
	self.contents[count + 1] = item
end

function vector:addUnique(item)
	for i, val in ipairs(self.contents) do
		if val == item then return end	
	end

	self:add(item)
end

function vector:remove(iteM)
	for i, val in ipairs(self.contents) do
		if val == item then table.remove(self.contents, i) end
	end
end

return vector