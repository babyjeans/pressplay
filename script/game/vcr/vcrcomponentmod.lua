-- vcrcomponentmod.lua
-- 	babyjeans
--
---
local VCRComponentMod = class("VCRComponentMod")

-- enum
VCRComponentMod.State = { 
	Begin = 1, 
	Win = 2 
}

function VCRComponentMod:init(component, modFunc)
	self.component = component
	self.states = { }
    print ("doin the mod: " .. component.name)
	for stateName, stateIndex in pairs(VCRComponentMod.State) do
		self.states[stateIndex] = {
			prevResources = { },
			resources =  { },
			microComponents = vector(),
		}	
	end
    self.modFunc = modFunc
    self.state = VCRComponentMod.State.Begin
	self.modFunc(self)
end

function VCRComponentMod:setResources(newResources)
	local stateData = self.states[self.state]
	stateData.prevResource = self.component.resources
	stateData.resources = newResources
	self.component:setResources(newResources)
end

function VCRComponentMod:removeOnWin(shouldRemove)
	self.removeOnWin = shouldRemove
end

function VCRComponentMod:setVisible(isVisible)
	self.component.visible = isVisible
end

function VCRComponentMod:setEnabled(isEnabled)
	self.component.enabled = isEnabled
end

function VCRComponentMod:addMicroComponent(name, x, y, resources)

end

function VCRComponentMod:begin()

	return self
end

function VCRComponentMod:remove()

end

function VCRComponentMod:win()
	self.state = VCRComponentMod.State.End
	if self.onWin then self.onWin(self) end

	return self
end

return VCRComponentMod