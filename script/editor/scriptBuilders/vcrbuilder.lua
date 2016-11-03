-- vcrbuilder.lua
--	babyjeans
--
---
local VCRBuilder 	= class("VCRBuilder")

--
---
function VCRBuilder:init(vcrName, closed, flipped, open, lip, shadows)
	self.sections = { }

	self.vcrName = vcrName

	self.closed = closed
	self.flipped = flipped
	self.open = open
	self.lip = lip
	self.shadows = shadows

	self.currentSection = nil
	self.currentLayer   = nil

	self.layerIndex = 1
end

function VCRBuilder:Begin(sectionName)
	self.currentSection = nil
	self.currentLayer = nil
	
	if self.sections[sectionName] then
		self.currentSection = sectionName
	end

	if self.currentSection == nil then
		self.currentSection = vector()
	end

	if self.currentSection:empty() then
		self.currentSection:add(vector())
	end

	self.sections[sectionName] = self.currentSection
	self.currentLayer = self.currentSection.contents[1]
	self.layerIndex = 1
	return self
end

function VCRBuilder:Layer(num)
	while self.currentSection:count() < num do
		self.currentSection:add(vector())
	end

	self.currentLayer = self.currentSection.contents[num]
	self.layerIndex = num

	return self
end

function VCRBuilder:NextLayer()
	return self:Layer(self.layerIndex + 1)
end

function VCRBuilder:addComponent(componentBuilder, x, y, connection)
	if type(x) == 'string' then
		connection = x
		x = nil
		y = nil
	end

	self.currentLayer:add({ type='component', connection=connection, componentBuilder=componentBuilder, x=x, y=y})

--[[
	self.innards[#self.innards + 1] = clsTable(...)
	return self
]]

	return self
end

function VCRBuilder:addWire(from, to, x, y, resource)
	self.currentLayer:add({ type='wire', from=from, to=to, x=x,y=y, resource=resource})

	return self
end

function VCRBuilder:addScrew(x, y, resource)
	self.currentLayer:add({ type='screw', x=x, y=y, resource=resource})
	return self
end

function VCRBuilder:Build()
	--TODO: Return a VCR
	local vcr = VCR(self.vcrName, self.closed, self.flipped, self.open, self.lip, self.shadows)
	local builders = vector()
	local newComponents = vector()
	for sectionName, section in pairs(self.sections) do 
		for layerIndex, layer in ipairs(section.contents) do
			for instIndex, instruction in ipairs(layer.contents) do
				if instruction.type == 'component' then 
					local builder = instruction.componentBuilder
					local component = builder:Build(instruction.x, instruction.y, instruction.connection)
					vcr:addComponent(sectionName, layerIndex, component, instruction.connection)

					builders:addUnique(builder)
					newComponents:add(component)
				elseif instruction.type == 'screw' then
					vcr:addScrew(sectionName, instruction.x, instruction.y, instruction.resource)
				elseif instruction.type == 'wire' then
					vcr:addWire(sectionName, layerIndex, instruction.from, instruction.to, instruction.x, instruction.y, instruction.resource)
				end
			end
		end
	end

	for i, builder in ipairs(builders.contents) do
		builder:ReconcileConnections(newComponents)
	end

	return vcr
end

return VCRBuilder 