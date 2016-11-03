-- mainmenu.lua
--	babyjeans
--
---
local MainMenu = GameState:extend("MainMenu")

local menuOptions = { }

local function addOption(optionName, callback)
	local num = #menuOptions + 1
	local y = 30
	y = y + (43 * num - 1)

	menuOptions[num] = { optionName, y, callback }
end

function MainMenu:init()
	Resources.loadStage('mainMenu')
	self.font = Resources.mainMenu.font
	self.hugeFont = Resources.mainMenu.hugeFont
	self.arrow = Resources.mainMenu.arrow
	
	self.arrowTimer = Timers:newTimer(1.0, function() self.arrowBlink = not self.arrowBlink	end)
	self.arrowBlink = false

	self.selectedOption = 1

	addOption("NEW GAME", function(mainMenu) mainMenu:onNewGame() end)
	addOption("QUIT", function(mainMenu) mainMenu:onQuit() end)
end

function MainMenu:onNewGame() 
	app:setState('game')
end

function MainMenu:onQuit()
	love.event.quit()
end

function MainMenu:onKeyPressed(key)
	local moved = false
	if key == 'down' then
		self.selectedOption = self.selectedOption + 1
		if self.selectedOption > #menuOptions then
			self.selectedOption = 1
		end
		moved = true
	elseif key == 'up' then
		self.selectedOption = self.selectedOption - 1
		if self.selectedOption < 1 then
			self.selectedOption = #menuOptions
		end
		moved = true
	elseif key == 'return' then
		menuOptions[self.selectedOption][3](self)
	end

	if moved then
		self.arrowTimer:reset()
		self.arrowBlink = false
	end
end

function MainMenu:draw()
	love.graphics.clear(0, 0, 255, 255)
    love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(self.font)

	love.graphics.print("PRESS PLAY", 500, 25)
	for i, menuOption in ipairs(menuOptions) do
		love.graphics.print(menuOption[1], 36, menuOption[2])
	end

	if not self.arrowBlink then 
		love.graphics.draw(self.arrow, 4, menuOptions[self.selectedOption][2] + 5)
	end	
end

return MainMenu()