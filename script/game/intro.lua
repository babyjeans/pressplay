-- intro.lua
--	babyjeans
--
---
local Intro = class('Intro')

Intro.fadeSpeedIn = 1.25
Intro.fadeSpeedOut = 0.25

function Intro:init()
	self.alpha = 0
	self.y = 10
	self.introFont = Resources.intro.hugeFont
end

function Intro:reset()
end

function Intro:enter()
	self.tween = Tweens:newTween(Intro.fadeSpeedIn, self, { alpha=255 }, function() 
		Tweens:newTween(Intro.fadeSpeedOut, self, { alpha=0 }, function()
			self.onComplete()
		end)	
	end)

	local screenW, screenH, mode = love.window.getMode()
	self.x = (screenW - self.introFont:getWidth(self.label)) / 2
end

function Intro:draw()
	love.graphics.setFont(self.introFont)
	love.graphics.setColor(255,255,255,self.alpha)
	love.graphics.print(self.label, self.x, self.y)
end

function Intro:kill()
	self.tween:kill()
	self.onComplete()
end

return Intro