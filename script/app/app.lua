-- app.lua
--	babyjeans
--
--	convenience class for handling app stuff, keeping it out of love namespace
--
---
local App = class("App")
function App:init()
	self.states = { }
	self.updateHooks = vector()
	self.currentState = GameState()

    love.graphics.setDefaultFilter('nearest', 'nearest')
	love.mouse.setGrabbed(true)
end

function App:addState(name, state)
	self.states[name] = state
end

function App:hookUpdate( updateHook )
	self.updateHooks:addUnique(updateHook)
end

function App:setState(state)
	state = self.states[state]
	if state == self.currentState then
		return 
	end 
	
	if self.currentState then
		self.currentState:exit()
	end

	self.currentState = state

	if self.currentState then
		self.currentState:enter()
	end
end

function App:draw()
	self.currentState:draw()
end

function App:update()
	self.currentState:update()
	for i, updateHook in ipairs(self.updateHooks.contents) do
		updateHook[2](updateHook[1])
	end
end

function App:keyReleased(key)
	if key == 'escape' then
		love.event.quit()
	end
	self.currentState:onKeyReleased(key)
end

function App:keyPressed(key)
	self.currentState:onKeyPressed(key)
end

return App