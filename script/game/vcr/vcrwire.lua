-- vcrwire.lua
--	babyjeans
--
---
local VCRWire = VCRComponent:extend('VCRWire')

function VCRWire:init(name, from, to, x, y, resources)
	self.super.init(self, name, x, y, resources)
	self.componentType = 'wire'
end

return VCRWire