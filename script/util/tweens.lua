-- tweens.lua
--	babyjeans
--
--	a simple manager for tween.lua tweens
--
---
local Tweens = class("Tweens")
local tweens = { }
function Tweens:init()
	self.tweens = { }
	app:hookUpdate( {self, self.update} )
end

-- same params as tween.lua
function Tweens:newTween(duration, subject, target, callback, easing)
	if type(callback) == 'string' then easing = callback end		
	local tween = { _tween=Tween.new(duration, subject, target, easing), complete=false }
	if type(callback) == 'function' then tween.callback = callback end 
	
	function tween:restart() 
		local found = false
		for i, t in ipairs(tweens.tweens) do
			if tween == t then found = true end
		end

		if not found then self.tweens[#self.tweens + 1] = tween end
		tween.complete  = false
		tween._tween.set(0)
	end

	function tween:kill()
		for i, tween in ipairs(tweens.tweens) do
			if tween == tween then
				table.remove(tweens.tweens, i) 
				break
			end
		end
	end

	self.tweens[#self.tweens + 1] = tween
	return tween
end

function Tweens:update()
	local dt = love.timer.getDelta()
	local toRemove = { }
	for i, tween in ipairs(self.tweens) do
		tween.complete = tween._tween:update(dt)
		if tween.complete then
			if tween.callback then tween.callback(self) end
			toRemove[#toRemove + 1] = i
		end
	end

	for i, t in ipairs(toRemove) do table.remove(self.tweens, i) end
end
tweens = Tweens()
return tweens