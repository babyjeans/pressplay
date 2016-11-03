-- typingtext.lua
--	babyjeans
--
--	a simple class to animate text typing
--
---
local TypingText = class("TypingText")
function TypingText:init(x, y, font)
	self.font = font 
	
	self.origin = { x=x,y=y }
	self.cursor = { 
		show = true, 
		blink = false,
		timer = Timers:newTimer(0.3, function() self.cursor.blink = not self.cursor.blink end)
	}
	self.drawWhenPaused = true
	self:reset()
end

function TypingText:reset()
	self.lines = { "" }
	self.currentLine = 1
	self.currentStep = { }
	self.steps = { }
	self.paused = true
end

--	
-- chaining commands
---
function TypingText:addLine(text, speed)
	speed = speed or 0.1
	self.steps[#self.steps + 1] = { type='addLine', text=text, speed=speed }
	return self
end

function TypingText:newLine()
	self.steps[#self.steps + 1] = { type='newLine' }
	return self
end

function TypingText:pause(delay)
	self.steps[#self.steps + 1] = { type='pause', delay=delay }
	return self
end

function TypingText:go()
	self.paused = nil
	return self
end

--
---
function TypingText:parseTable(typeTextTable)
	for i, cmd in ipairs(typeTextTable) do
		local command = string.lower(cmd[1])

		if command == 'addline' then
			self:addLine(cmd[2], cmd[3])
		elseif command == 'newline' then
			self:newLine()
		elseif command == 'pause' then
			self:pause(cmd[2])
		end
	end
end

--
---
function TypingText:update()
	if self.paused then
		return
	end

	local function advanceStep() 
		table.remove(self.steps, 1)
		self.currentStep = { }
		if self.timer then
			self.timer:stop()
			self.timer = nil
		end
	end

	if #self.steps > 0 then
		local step = self.steps[1]
		if self.currentStep.step ~= step then 
			self.currentStep.step = step
			if step.type == 'addLine' then
				if step.text:len() == 0 then
					advanceStep()
				else
					self.currentStep.char = 1
					self.timer = Timers:newTimer(step.speed, function()
						local line = self.lines[self.currentLine]
						line = line .. string.sub(step.text, self.currentStep.char, self.currentStep.char)
						self.lines[self.currentLine] = line
						self.currentStep.char = self.currentStep.char + 1
						if self.currentStep.char > step.text:len() then 
							advanceStep()
						end
					end)
				end
			elseif step.type == 'pause' then
				self.timer = Timers:newTimer(step.delay, function() advanceStep() end, false)
			elseif step.type == 'newLine' then
				advanceStep();
				self.lines[#self.lines + 1] = ""
				self.currentLine = #self.lines
			end
		end
	end
end

function TypingText:draw()
	if self.paused and not self.drawWhenPaused then
		return
	end

	love.graphics.setFont(self.font)

	for i, line in ipairs(self.lines) do
		love.graphics.print(line, self.origin.x, self.origin.y + ( (i-1) * self.font:getHeight()))
	end

	if self.cursor.show and not self.cursor.blink then
		local cursorX = self.origin.x + self.font:getWidth(self.lines[self.currentLine])
		local cursorY = self.origin.y + ((self.currentLine - 1) * self.font:getHeight())

		love.graphics.rectangle("fill", cursorX, cursorY + self.font:getHeight() - 4, 10, 4)
	end
end


return TypingText