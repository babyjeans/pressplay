-- gamestate.lua
--	gamestate base class
--
---
local GameState = class("GameState")

function GameState:init() end
function GameState:update() end
function GameState:draw() end
function GameState:enter() end
function GameState:exit() end
function GameState:onKeyPressed() end
function GameState:onKeyReleased() end

return GameState