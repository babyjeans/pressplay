-- pressplay
-- 	a game wonderfully created by babyjeans
--
-- 3rdparty fonts used:
--		http://www.dafont.com/vcr-osd-mono.font
--		http://www.dafont.com/04b-03.font    -- seriously, who doesnt
-- 3rd party library:
--		https://github.com/Yonaba/30log
--
---
--	TODO
--	*	Snap Components into ports when installing
--	*	Do not allow components to collide
--	*	Core Gameplay
--		*	Receive VCR with issue
--		*	Repair issue
--		*	Reward / Loop back
--	*	Tools
--		*	Screwdriver
--		*	Parts Drawer
--	*	Board Components as individual sprites
--	*	More screws. Screw everything
--
--	POST-LD36 Wishlist:
--	*	SpriteBatching
--
---

-- core
class 			= require('ext/30log-clean')
baby            = require('script/baby/baby')

-- types
vector 			= require('script/util/vector')
Vector2 		= require('script/util/vector2')
Rectangle 		= require('script/util/rectangle')
Circle 		    = require('script/util/circle')
TypingText 		= require('script/util/typingtext')
GameState 		= require('script/app/gamestate')

-- global systems
Timers 			= { }
Draggy 			= { } 
ClickGuy 		= { }
Resources 		= { } 

-- external types
Tween 			= require('ext/tween')

-- game specific
require('assets/gamedata')

-- app definition
app = { }

---
-- love2d callbacks
function love.load()
	local App = require('script/app/app')

	Resources = require('script/app/resources')
	initGameData()

	app = App()
	Timers 	 = require('script/util/timers')
	ClickGuy = require('script/util/clickguy')
	Tweens   = require('script/util/tweens')

	app:addState('mainMenu', require('script/game/mainmenu'))
	app:addState('game', 	 require('script/game/game'))

	app:setState('mainMenu')
end

function love.update()
	app:update()
end
	
function love.draw()
	app:draw()
end

function love.keyreleased(key, scancode)
	app:keyReleased(key)
end

function love.keypressed(key, scancode, isrepeat)
	app:keyPressed(key)
end