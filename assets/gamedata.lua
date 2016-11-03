-- gamedata.lua
--	babyjeans
--
--	location for tables / scripts to build gameplay data
--
---
VCRComponents = {}
VCRs = {} 
GameRules = {}
ResourceList = { }

local VCRComponentBuilder 	= require('script/editor/scriptbuilders/vcrcomponentbuilder')
local VCRBuilder 			= require('script/editor/scriptbuilders/vcrbuilder')
local ToolBuilder			= require('script/editor/scriptbuilders/toolbuilder')
local ContainerBuilder		= require('script/editor/scriptbuilders/containerbuilder')

function initGameData()

	-- Game Resource List, arranged by 'stage' to load
	---
	ResourceList = {
		mainMenu = {
			font 	   = { 'font', 'assets/fonts/VCR_OSD_MONO_1.001.ttf', 40 },
			hugeFont = { 'font', 'assets/fonts/VCR_OSD_MONO_1.001.ttf', 96 },
			arrow    = { 'image', 'assets/gfx/MainMenu_Arrow.png' }
		},

		game = {
			gameFont  	 = { 'font', 'assets/fonts/04B_03__.ttf', 16 },
			gameFontHuge = { 'font', 'assets/fonts/04B_03__.ttf', 64 }
		},

   	intro 	  = { },

		workBench = { 
			bench = { 'image', 'assets/gfx/WorkBench_Bench.png' },

			-- Tools and Bins and Bins and Tools
			bin_smallPlastic = { 'image', 'assets/gfx/WorkBench_Bin_SmallPlastic.png'},

			-- VCR Chasises
			vcrA1_Closed        = { 'image', 'assets/gfx/WorkBench_VCR_A1_Closed.png' },
			vcrA1_Flipped       = { 'image', 'assets/gfx/WorkBench_VCR_A1_Flipped.png' },
			vcrA1_Open          = { 'image', 'assets/gfx/WorkBench_VCR_A1_Open.png' },
			vcrA1_PanelLip      = { 'image', 'assets/gfx/Workbench_VCR_A1_PanelLip.png'},
			vcrA1_Shadow        = { 'image', 'assets/gfx/WorkBench_VCR_A1_Shadow.png'},
			vcrA1_Tape          = { 'image', 'assets/gfx/WorkBench_VCR_A1_HeadUnit_Tape.png'},
			vcrA1_WireHU2HUC    = { 'image', 'assets/gfx/WorkBench_VCR_A1_WireHU2HUC.png' },
			vcrA1_WireHU2VHSPU  = { 'image', 'assets/gfx/WorkBench_VCR_A1_WireHU2VHSPU.png' },
			vcrA1_WireVHSPU2HBP = { 'image', 'assets/gfx/WorkBench_VCR_A1_WireHU2HUC.png' },

			-- VCR Guts
			vcr_screw                   = { 'image', 'assets/gfx/WorkBench_VCR_Screw.png' },
			vcr_portTop                 = { 'image', 'assets/gfx/WorkBench_VCR_Guts_PortT.png'},
			vcr_portBottom              = { 'image', 'assets/gfx/WorkBench_VCR_Guts_PortB.png'},
			vcr_vhs                     = { 'image', 'assets/gfx/WorkBench_VCR_VHS.png'},
			vcr_vhspu                   = { 'image', 'assets/gfx/WorkBench_VCR_VHSPU.png'}, -- cause VCRs have those, right?
			vcr_headUnit                = { 'image', 'assets/gfx/WorkBench_VCR_HeadUnit.png'},
			vcr_videoProcessingBoard    = { 'image', 'assets/gfx/WorkBench_VCR_VideoProcessingBoard.png'},
			vcr_videoProcessingBoardTop = { 'image', 'assets/gfx/WorkBench_VCR_VideoProcessingBoardPortTop.png' },
			vcr_headUnitController      = { 'image', 'assets/gfx/WorkBench_VCR_HeadUnitController.png' },
			vcr_heatSink                = { 'image', 'assets/gfx/WorkBench_VCR_HeatSink.png' },
			vcr_backPanel               = { 'image', 'assets/gfx/WorkBench_VCR_BackPanel.png' },

            vcr_vhs_pbj                 = { 'image', 'assets/gfx/WorkBench_VCR_VHS_Sandwich.png'},

			component_med_cap_base		= { 'image', 'assets/gfx/WorkBench_Component_MediumCapacitor_Base.png' },
			component_med_cap 			= { 'image', 'assets/gfx/WorkBench_Component_MediumCapacitor.png' },
			component_med_burnt_1		= { 'image', 'assets/gfx/WorkBench_Component_MediumCapacitor_Burnt1.png' },
		},
	}

	-- they're the same for now
	ResourceList.intro = ResourceList.mainMenu

	VCRComponentBuilder.defaultCollisionFilter = { 'wire' }

	---
	--	VCR Component designs and data
	--
	VCRComponents = {
		VHSPUPort 				= VCRComponentBuilder('VHSPUPort')
									:setResources('vcr_portBottom', 'vcr_portTop')
									:accepts('VHSPUPort-VHSPU', 2, 0, 0)
									:addCollisionTag('no_collide')
									:setDraggable(false),
		HeadUnit				= VCRComponentBuilder('HeadUnit')
									:setResources('vcr_headUnit')
									:accepts('HeadUnit-Cassette', 2, 45*2, 0),
		HeatSink 				= VCRComponentBuilder('HeatSink')
									:setResources('vcr_heatSink'),
		VHSPU 					= VCRComponentBuilder('VHSPU')
									:setResources('vcr_vhspu'),
		VideoProcessingBoard 	= VCRComponentBuilder('VideoProcessingBoard')
									:setResources('vcr_videoProcessingBoard', 'vcr_videoProcessingBoardTop')
									:accepts('VideoProcessingBoard-Backpanel', 	2, 11*2, -6*2)
									:accepts('VideoProcessingBoard-HUC', 		2, 44*2, 33*2)
									:addMod('BlownThinger', function(modBuilder) 
										local resources = { 
											'component_med_cap_base', 
											'component_med_cap', 
											'component_med_cap_burnt_1' 
										}		
										modBuilder:addMicroComponent('mediumCapacitor', 19, 63, resources)
									end),
		HeadUnitController 	 	= VCRComponentBuilder('HeadUnitController')
									:setResources('vcr_headUnitController'),
		VHSCassette				= VCRComponentBuilder('VHSCassette')
									:setResources('vcr_vhs')
									:addMod('PBJintheShell', function(modBuilder)
										local resources={'vcr_vhs_pbj'}
										modBuilder:setResources(resources)
									end)
									:accepts('VHSCassette-TapeA001',			2, -40*2, 4*2),
		BackPanel 				= VCRComponentBuilder('BackPanel')
									:setResources('vcr_backPanel')
									:addMod('NoPower'),
		VHSTapeA001				= VCRComponentBuilder('VHSTapeA001')
									:setResources('vcrA1_Tape')
									:addMod('UnrulyTape', function(modBuilder)
										local resources={ 'vcr_A1_tape_unruly'}
										modBuilder:setResources(resources)
										modBuilder:removeOnWin(true)
									end)
									:addMod('PBJintheShell', function(modBuilder)
										modBuilder:setVisible(false)
										modBuilder:setEnabled(false)
									end)
	}
	---
	--

	--
	-- VCR Models, made of the above components
	---
	VCRs = {
		A001 = 	VCRBuilder("A001", 
							'vcrA1_Closed', 
							'vcrA1_Flipped',
							'vcrA1_Open', 
							'vcrA1_PanelLip', 
							{ { 'vcrA1_Shadow', -18, -20 } })
					:Begin('flipped')
						:addScrew(3*2, 	 3*2,	'vcr_screw')
						:addScrew(3*2, 	 104*2,	'vcr_screw')
						:addScrew(195*2, 3*2,	'vcr_screw')
						:addScrew(195*2, 104*2,	'vcr_screw')
					:Begin('open') -- things on bottom
						:addWire('VHSPUPort', 'BackPanel', 	   				37*2,  12*2, 'vcrA1_WireVHSPU2HBP')
						:addComponent(VCRComponents.VHSPUPort, 				145*2, 12*2)
						:addComponent(VCRComponents.HeadUnit,  				109*2, 50*2)
						:NextLayer()
							:addComponent(VCRComponents.HeatSink,  				74*2, 15*2)
							:addComponent(VCRComponents.VideoProcessingBoard,   20*2, 16*2)
							:addComponent(VCRComponents.VHSPU, 	   				'VHSPUPort-VHSPU')	-- add component to port named VHSPU
						:NextLayer()
							:addComponent(VCRComponents.HeadUnitController, 	'VideoProcessingBoard-HUC')
						:NextLayer()
							:addComponent(VCRComponents.VHSTapeA001,			'VHSCassette-TapeA001')
						:NextLayer()
							:addComponent(VCRComponents.VHSCassette, 			'HeadUnit-Cassette')
						:NextLayer()
							:addWire('HeadUnit', 'HeadUnitController', 			104*2, 95*2, 'vcrA1_WireHU2HUC')
							:addWire('HeadUnit', 'VHSPU', 						132*2, 36*2, 'vcrA1_WireHU2VHSPU')
							:addComponent(VCRComponents.BackPanel, 				'VideoProcessingBoard-Backpanel')
	}
	---
	--

	Tools = {
		Hand = ToolBuilder("Hand")
			:setResources()
			:onTool(function(self, component)
					if component.type == 'wire' then
						self.toolBox:show('WireBin'):makeDragTarget()
						ClickGuy.queueDrag(component):listenDragCancel(function()
								self.toolBox:hide('WireBin')
							end)
					end
				end),
		ScrewDriver = ToolBuilder("Hand")
			:setResources()
			:onTool(function(self, component)

				end),


		SolderingIron = ToolBuilder("SolderingIron")
			:setResources()
			:onTool(function()
				end)
			:onAltTool(function()
				end),
		WireCutter = ToolBuilder("SolderingIron")
			:setResources(),
		Tweezer = ToolBuilder("Tweezer"),
		WireBin = ContainerBuilder("WireBin")
			:setResources('bin_smallPlastic')
			:setArea(3*2, 3*2, 63*2, 42*2),

	}

	--
	--	how the game presents issues
	---
	GameRules = {
		
		--	various 'problems' to solve
		---
		--	Situation {
		--		title = title to show, not sure how used yet
		--		instruction = Mr VHS will read this
		--		VCR = {
		--			base = VCR Object to build for this situation
		--			mods = List of mods to apply, any components in the VCR with a mod matching any of these names will activate
		--		Win = the win condition, 'AllModRepaired' is the default (valid: 'sandbox', 'AllModRepaired')
		---
		Situations = {
			-- Test Situation
			--[[{
				title="Test Test Test",
				instruction = {
					{ 'addline', "Hello", 0.1 }, { 'addline', ".", 0.2 }, { 'addline', ".. ", 0.3 }, { 'pause', 2 }, 
					{ 'addline', "Mr. VHS", 0.15}, { 'addline', ".", 0.4 }, { 'newline' },
					{ 'pause', 0.5 }, 
					{ 'addline', "How long am I going to sit here", 0.08 }, { 'pause', 0.5 }, { 'addline', " watching you not do", 0.06 }, 
					{ 'pause', 0.5 }, { 'addline', " what I told you to do?", 0.08 }, { 'pause', 0.5 }, { 'newline' }, 
					{ 'addline', "Just tryin' to plan my day here.", 0.05 },
				},

				VCR = { 
					base = 'A001'
				},

				Win = 'sandbox',				-- no win condition	
			},]]
			
			-- Unruly Tape
			---
			{	
				title="Unruly Tape",			-- Title to use 
				instruction = { 
					{ 'addline', "It seems we've come across some unruly tape, and this machine refuses to play." },
					{ 'pause', 0.6 },
					{ 'newline' },
					{ 'addline', "Make it play." }
				},

				-- VCR for this situation
				VCR = {
					base = 'A001',
					mods = { 'UnrulyTape' },
				},
			},

			-- PB IN THE SHELL
			---
			{	
				title="PBJintheShell",			
				instruction = { 
					{ 'addline', "There's a place for tapes" },
					{ 'addline', "...", 0.08 },
					{ 'pause', 0.25 },
					{ 'addline', " And a place for sandwiches." },
					{ 'pause', 0.5 },
					{ 'newline' },
					{ 'addline', "This is not the latter." }
				},

				-- VCR for this situation
				VCR = {
					base = 'A001',				-- use the A001 VCR model
					mods = { 'PBJintheShell' },	
				},
			},

			-- BLOWNTHINGERMABOB
			---
			{
				title="BlownThinger",
				instruction = { 
					{ 'addline', "The card attached does not say thank you for being a friend. "},
					{ 'pause', 0.25 },
					{ 'newline'},
					{ 'addline', "No... rather it doesn't say much at all." },
					{ 'pause', 0.5 },
					{ 'newline' },
					{ 'addline', "Something about a thinger. The smell of burnt plastic is telling though." }
				},

				-- VCR for this situation
				VCR = {
					base = 'A001',				-- use the A001 VCR model
					mods = { 'BlownThinger' },	
				},
			},
		},
		----
		---
		--

	}
end