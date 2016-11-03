-- thesituation.lua
-- 	babyjeans
---
local Situation = class("Situation")
function Situation:init(situationRules)
	self.situationRules = situationRules	
end

function Situation:begin()
	local situationRules = self.situationRules
	Game:resetRound()
	Game:feedMrVHS(situationRules.instruction)
	
	self.vcr = Game.workBench:loadVCR(situationRules.VCR.base)
	self.mods = self.vcr:loadMods(situationRules.VCR.mods)

	Game:startIntro(situationRules.title, function() 
			Game:startWorkbench()
			Game.MrVHS:go()
		end)
end

return Situation