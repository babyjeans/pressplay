-- workbench.lua
--	babyjeans
--
--	the workbench is the portion of the game where the player solves repair puzzles
--
---
local WorkBench = class("WorkBench")

function WorkBench:init()
	self.bench = Resources.workBench.bench
	self.visible = true
end
function WorkBench:reset() 
	self.vcr = nil
end

function WorkBench:loadVCR(vcr)
	self.vcr = VCRs[vcr]:Build()
	self.vcr.visible = false
	return self.vcr
end

function WorkBench:enter()
	self.visible = true
	local screenW, screenH, flags = love.window.getMode()
	local vcrW = (239 * 2)
 	local targetX = (screenW - vcrW) * 0.5
	
	self.vcr.x = -300
	self.vcr.y = 200
	self.vcr.clickable = true
	self.vcr.visible = true

	Tweens:newTween(1.3, self.vcr, { x = targetX }, 'outExpo')
end

function WorkBench:exit(nextActive)
	self.visible = false
	nextActive:enter()

	if self.vcr then
		self.vcr.clickable = false
	end
end

function WorkBench:draw()
	love.graphics.setColor(255,255,255,255)

	if self.visible then
		love.graphics.draw(self.bench, 0, 100)
		if self.vcr then
			self.vcr:draw()
		end
	end
end

return WorkBench