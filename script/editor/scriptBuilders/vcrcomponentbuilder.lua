-- vcrcomponentbuilder.lua
--	babyjeans
--
---
local VCRComponentBuilder = class("VCRComponentBuilder")
function VCRComponentBuilder:init(name)
	-- definition of the component
	self.name = name
	self.resources = vector()
	self.targets = { }
	self.mods = { }
	self.collisionFilter = vector()
	self.collisionTags = vector()
	self.draggable = true

	-- building the component
	self.connectionList = vector()

	if VCRComponentBuilder.defaultCollisionFilter then
		for i, filter in ipairs(VCRComponentBuilder.defaultCollisionFilter) do
			self.collisionFilter:add(filter)
		end
	end
end

function VCRComponentBuilder:setResources(...)
	local args = {...}
	for i, arg in ipairs(args) do
		self.resources:add(arg)
	end

	return self
end

function VCRComponentBuilder:accepts(targetName, drawOrderInsert, xAnchor, yAnchor)
	self.targets[targetName] = { order=drawOrderInsert, anchor = { x=xAnchor or 0, y=yAnchor or 0 } }
	return self
end

function VCRComponentBuilder:addMod(modName, modFunction)
	self.mods[modName] = modFunction
	return self
end

function VCRComponentBuilder:setLayerThickness(above, below)
	self.layerThickness = { above=above, below=below }	-- above the 'connection' point and below the 'connection' point. 
    return self
end

function VCRComponentBuilder:setDraggable(canDrag)
	self.draggable = canDrag
	return self
end

function VCRComponentBuilder:addCollisionFilter(...)
	local args = {...}
	for i, excludeCollision in ipairs(args) do
		self.collisionFilter:addUnique(excludeCollision)
	end
	return self
end

function VCRComponentBuilder:addCollisionTag(...)
	local args = {...}
	for i, arg in ipairs(args) do
		self.collisionTags:addUnique(arg)
	end
	return self
end

function VCRComponentBuilder:Build(x, y, connection)
	local component = VCRComponent(self.name, x or 0, y or 0)

	component:setResources(self.resources.contents)
	component:setAccepts(self.targets)
	component:setCollisionInfo(self.collisionFilter.contents, self.collisionTags.contents)
	component:setLayerThickness(self.layerThickness)
	component:setMods(self.mods)
	component.draggable = self.draggable

	if connection then
		self.connectionList:add( { component, connection } )
	end

	return component
end

function VCRComponentBuilder:ReconcileConnections(componentList)
 	for i, connection in ipairs(self.connectionList.contents) do
		for i, component in ipairs(componentList.contents) do
			component:attach(connection[2], connection[1])
		end
	end
end

return VCRComponentBuilder