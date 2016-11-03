-- resources.lua
--	babyjeans
--
--	a wrapper / manager of sorts to keep shit.
--
---
local loadedStages = { }
resources = { }

function resources.loadStage(stage)
	resources[stage] = { }
	for key, resource in pairs(ResourceList[stage]) do
		if resource[1] == 'font' then
			resources[stage][key] = love.graphics.newFont(resource[2], resource[3])
		elseif resource[1] == 'image' then
			resources[stage][key] = love.graphics.newImage(resource[2])
		end
	end

	loadedStages[#loadedStages + 1] = stage
end

function resources.unloadStage(stage)
	for i, stageName in ipairs(loadedStages) do
		if stageName == stage then
			table.remove(loadedStages, i)
			resources[stage] = { } -- anything with a reference to resources still has them at this point though
			return
		end
	end
end

return resources