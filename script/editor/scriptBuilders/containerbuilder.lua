-- containerbuilder.lua
--	babyjeans
--
---
local ContainerBuilder = class("ContainerBuilder")
function ContainerBuilder:init()
	self.area = Rectangle()
end

function ContainerBuilder:setResources(...)
	return self
end

function ContainerBuilder:setArea(x, y, w, h)
	self.area = Rectangle(x, y, w, h)
	return self
end

return ContainerBuilder