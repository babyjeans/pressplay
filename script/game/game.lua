-- game.lua
--	babyjeans
--
---
Game = { }
local WorkBench = require('script/game/workbench')
local Intro 	= require('script/game/intro')

-- game types
VCR 			= require('script/game/vcr/vcr')
VCRComponent  	= require('script/game/vcr/vcrcomponent')
VCRWire 		= require('script/game/vcr/vcrwire')

GameClass = GameState:extend("GameClass")

--
-- init / appstate
---
function GameClass:init()

	Resources.loadStage('game')
	Resources.loadStage('workBench')
	Resources.loadStage('intro')
	
	self.gameFont = Resources.game.gameFont
	self.gameFontHuge = Resources.game.gameFontHuge
	self.situations = require('script/game/situations')

	self.intro = Intro()
	self.workBench = WorkBench()

	self.MrVHS = TypingText(2, 2, self.gameFont)
	self.MrVHS.drawWhenPaused = false
	self.checkWin = winConditions['sandbox']
end

function GameClass:enter()
	self.situations:start()
end


--
-- mutation
---
function GameClass:feedMrVHS(linesTable, go)
	self.MrVHS:parseTable(linesTable)
	if go then
		self.MrVHS:go()
	end
end

-- 
-- round / scene management
---
function GameClass:resetRound()
	self.intro:reset()
	self.workBench:reset()
	self.MrVHS:reset()
end

function GameClass:startIntro(label, onComplete)
	self.active = self.intro;
	self.intro.label = label
	self.intro.onComplete = onComplete
	self.intro:enter()
end

function GameClass:startWorkbench()
	Game.active = Game.workBench
	Game.active:enter()
end

--
--
---
function GameClass:onKeyReleased(key) 
	----
	-- DEBUG / CHEAT KEYS
	--
	if key == 'o' then
		self.intro:kill()
		self.workBench.vcr.benchState = 'open'
	end
	--]]
	---
end

--
---
function GameClass:update()
	self.MrVHS:update()
	self.situations:update()
end

--
-- drawing functions
---
function GameClass:drawUI()
	love.graphics.setColor(22, 188, 29, 255)
	self.MrVHS:draw()

	if ClickGuy.dragging then
		love.graphics.setColor(255, 230, 180, 255)
		ClickGuy.dragging:draw()
	end
end

function GameClass:draw()	
	love.graphics.setColor(255,255,255,255)
	
	if self.active == self.intro then
		self.intro:draw()
	end

	self.workBench:draw()
	self:drawUI()
end

Game = GameClass()
return Game