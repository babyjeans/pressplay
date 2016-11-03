-- toolbuilder.lua
--	babyjeans
--
---
local ToolBuilder = class('ToolBuilder')
function ToolBuilder:init()
end

function ToolBuilder:setResources(...)
	return self
end

function ToolBuilder:onTool()
	return self
end

function ToolBuilder:onAltTool()
	return self
end

return ToolBuilder