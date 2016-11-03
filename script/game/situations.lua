-- situations.lua
--	babyjeans
--
--	manage situations from the gamedata, and handle mods
--
--	[DEP: < scripts/game.lua]
---
situations = { }
winConditions = {
	sandbox 		= function(self) return false end,	-- always sandbox. always.
	AllModRepaired  = function(self) return false end,
}

local Situations = class("Situations")
local Situation = require('script/game/thesituation')

--
---

function Situations:init()
end 

function Situations:start(startSituation)
	-- don't trample an existing situation
	if self.situation then 
		return
	end

	-- Pick a new situation
	local situationList = GameRules.Situations
	local numSituations = #situationList
	local situationRules = situationList[love.math.random(1, numSituations)] 
    situationRules = situationList[2]
	local winCond = situationRules.Win or 'AllModRepaired'

	self.situation = Situation(situationRules)
	self.checkWin = winConditions[winCond]

	self.situation:begin()
end

function Situations:update()
	if self:checkWin() then
		self.winCallback()
	end
end

situations = Situations()
return situations