-- Why can't I access this normally? Whatever, it looks to be the same regardless.
local statue_symbols =
{
    "ww_head",
    "ww_limb",
    "ww_meathand",
    "ww_shadow",
    "ww_torso",
    "frame",
    "rope_joints",
    "swap_grown"
}


local plant_symbols = 
{
    "waterpuddle",
    "sparkle",
    "puddle",
    "plant",
    "lunar_mote3",
    "lunar_mote",
    "glow",
    "blink"
}

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local STATES = {
    -- State{
        -- name = "enterdoor",
        -- tags = {"canrotate", "busy", "nomorph", "nopredict"},
        -- onenter = function(inst)
            -- local BA = inst:GetBufferedAction()
            -- if BA.target and BA.target.components.sailable and not BA.target.components.sailable:IsOccupied() then
                -- BA.target.components.sailable.isembarking = true
                -- if inst.components.sailor and inst.components.sailor:IsSailing() then
                    -- inst.components.sailor:Disembark(nil, true)
                -- else
                    -- inst.sg:GoToState("jumponboatstart")
                -- end
			-- else
				-- --go to idle first so wilson can go to the talk state if desired -M
				-- --and in my defence, Klei does that too, in opengift state
				-- inst.sg:GoToState("idle")
				-- inst:PushEvent("actionfailed", { action = inst.bufferedaction, reason = "INUSE" })
				-- inst:ClearBufferedAction()
            -- end
        -- end,

        -- onexit = function(inst)
        -- end,
    -- }
-- }



    State{
        name = "pocketwatch_warpback_pst",
        tags = { "busy", "nopredict", "nomorph", "noattack", "nointerrupt", "jumping" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.DynamicShadow:Enable(false)
			
			
			-- DS - Need to selectively disable this so you don't get perma-invincibility thanks to the normal PlayTransition effect
			-- Otherwise, you gotta let it happen, or the Backstep Watch would be useless!
			if data.warpback_data.warptype ~= "recall" then
				print("Warp type wasn't recall, do invincibility")
				inst.components.health:SetInvincible(true)
			else
				-- Force the camera thing, it's needed for teleporting between interiors, because the game doesn't automatically do it since it's TECHNICALLY close enough to be on the same screen.
				-- print("Trying to force the camera snap and fade for recall warp")
				-- data.queued_snap_camera = true
				-- This didn't work. Need to look in to that more. Maybe something can be done with PlayTransition? It's too slow, though, way different from Backtrek teleporting. Maybe it's okay, though?
				-- The problem is that they BOTH do it, because you're now REALLY teleporting a large distance if going in/out, so the PlayTransition effect happens both times.
				-- Maybe I can check if you're moving to a different interior, AND are currently in an interior already?
			end

            inst.AnimState:PlayAnimation("pocketwatch_warp_pst")
            inst.sg:SetTimeout(8 * FRAMES)

			if data.queued_snap_camera then
				print("Do the snap, it should be here")
				inst:SnapCamera()
				inst:ScreenFade(true, 0.5)
			end

            if data.warpback_data ~= nil then
				print("DS - SG - TP - Just about to teleport with Wanda's thing")
				print("Warp target: ", data.warpback_data.target)
				local interior_override = data.warpback_data.interior
				print("Interior override: ", interior_override)
				print("Dumping warpback data table:")
				dumptable(data.warpback_data, 1, 1, nil, 0)
				
				if interior_override == "unknown" then
					interior_override = nil
				end
				

				local currentinterior = inst.components.interiorplayer.roomid
				-- ((inst.components.interiorplayer.roomid) and (inst.components.interiorplayer.roomid ~= "unknown")) or nil
				local ininterior = currentinterior ~= "unknown"
				-- if currentinterior ~= "unknown" then
					-- ininterior = true
				-- end
				
				local PTFade = not (data.warpback_data.warptype == "recall")
				-- ((data.warpback_data.warptype == "recall") or (ininterior and (inst.components.interiorplayer.roomid ~= interior_override))) or false
				print("Fade Logic. Starting value:",PTFade)
				-- if (ininterior and (inst.components.interiorplayer.roomid ~= interior_override))) then
					if ininterior then
						if currentinterior ~= interior_override then -- Moving to an interior while you're already in an interior
							if interior_override then
								print("Player going to a new interior from an interior")
								PTFade = true
							else -- Going outside, because there's no interior target set
								print("Player moving from interior to exterior")
								PTFade = false
							end
						else -- Moving to the same interior. Do a fade anyway, because it jitters currently because... I guess it's playing the transition again. I could probably fix that, actually...
							print("Moving to a recall spot in the same interior. Useless in normal play generally, but still possible")
							PTFade = false
						end
					elseif not interior_override then -- Not in an interior or going to an interior
						print("Not in an interior and not going to an interior, don't enable our extra-special fade")
						PTFade = false
					else
						if interior_override then
							print("Not in an interior, but going to one. The game will handle this naturally, but just in case...")
							print("This is getting activated wrongly. Value:",interior_override)
							PTFade = true
						end
						-- No more cases really needed, because all that's left is moving outside>outside
					end
				-- end
				
				print("Fade value:",PTFade)
				
				-- How this should work:
				-- Disable the PlayTransition fade if you're going from exterior>interior, or interior>exterior, since the Backtrek Watch has a built-in fade for long distances
				-- Force the PlayTransition fade if you're going interior>interior, because it's usually technically a short distance otherwise
				-- I might need to add even more logic to see if you're going to an already-loaded interior, because they could be placed a distance away and still trigger the Backtrek's in-built fade because of that
				
				if data.warpback_data.warptype == "recall" then
					
					-- Instead of screwing around with nonsense and the PlayTransition fade... just do it manually
					-- if PTFade and (not data.queued_snap_camera) then -- Don't do it if it's already done, though
					if PTFade then -- Ah, screw it
						print("Fade asked for and the snap camera wasn't already queued, do it manually")
						inst:SnapCamera()
						inst:ScreenFade(true, 0.5)
					end
					
					inst:Teleport(Vector3(data.warpback_data.dest_x, data.warpback_data.dest_y, data.warpback_data.dest_z), true, interior_override)
					
					-- (true or ((data.warpback_data.warptype == "recall") and nil))
					-- ((data.warpback_data.warptype == "recall") or nil)
					-- (not data.queued_snap_camera)
					-- (data.warpback_data.warptype == "recall")
				else
					print("Do normal teleport for the Backstep watch")
					inst.Physics:Teleport(data.warpback_data.dest_x, data.warpback_data.dest_y, data.warpback_data.dest_z)
				end
                -- inst:Teleport(data.warpback_data.target)
                if TheWorld and TheWorld.components.walkableplatformmanager then -- NOTES(JBK): Workaround for teleporting too far causing the client to lose sync.
                    TheWorld.components.walkableplatformmanager:PostUpdate(0)
                end
            end
            inst:PushEvent("onwarpback", data.warpback_data)

			local fx = SpawnPrefab("pocketwatch_warpbackout_fx")
			fx.Transform:SetPosition(data.warpback_data.dest_x, data.warpback_data.dest_y, data.warpback_data.dest_z)
			fx:SetUp(data.castfxcolour or { 1, 1, 1 })
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/recall")
            end),

            TimeEvent(3 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                ToggleOnPhysics(inst)
            end),
            TimeEvent(4 * FRAMES, function(inst)
				inst.components.health:SetInvincible(false)
                inst.sg:RemoveStateTag("noattack")
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
        end,
    },

    State{
        name = "rebirth2",
        
        onenter = function(inst)
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("rebirth2")
            
            inst.components.hunger:Pause()
            for k,v in pairs(plant_symbols) do
                inst.AnimState:OverrideSymbol(v, "lifeplant", v)
            end
        end,
        
        timeline=
        {
            TimeEvent(16*FRAMES, function(inst) 
             --   inst.SoundEmitter:PlaySound("dontstarve/common/dropwood")
            end),
            TimeEvent(45*FRAMES, function(inst) 
              --  inst.SoundEmitter:PlaySound("dontstarve/common/dropwood")
            end),
            TimeEvent(92*FRAMES, function(inst) 
               -- inst.SoundEmitter:PlaySound("dontstarve/common/rebirth")
            end),
        },
        
        onexit = function(inst)
            inst.components.hunger:Resume()
            for k,v in pairs(statue_symbols) do
                inst.AnimState:ClearOverrideSymbol(v)
            end
        
            inst.components.playercontroller:Enable(true)
        end,
        
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

    }, 

    State{
        name = "tap",
        tags = {"doing", "busy"},
        
        timeline=
        {
            TimeEvent(4*FRAMES, function( inst )
                inst.sg:RemoveStateTag("busy")
            end),
        },
        
        onenter = function(inst, timeout)

            inst.sg:SetTimeout(timeout or 1)
            inst.components.locomotor:Stop()    

            inst.AnimState:PlayAnimation("tamp_pre")    
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("tap_loop") end ),
        },
    },

    State{
        name = "charge",
        tags = {"busy", "doing", "waitforbutton"},
        
        onenter = function(inst)            
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("charge_pre")
            inst.AnimState:PushAnimation("charge_grow")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/charge_up_LP", "chargedup")    
        end,
        onexit = function(inst)
            inst.rightbuttonup = nil
            inst:ClearBufferedAction()
            inst.shoot=nil
            inst.readytoshoot = nil
        end,
        onupdate = function(inst)        
            if inst.rightbuttonup then
                inst.rightbuttonup = nil
                inst.shoot = true                
            end
            if inst.shoot and inst.readytoshoot then
                inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/smallshot", {timeoffset=math.random()})
                inst.SoundEmitter:KillSound("chargedup")
                inst.sg:GoToState("shoot")
            end

            local controller_mode = TheInput:ControllerAttached()
            if controller_mode then
                local reticulepos = Vector3(inst.livingartifact.components.reticule.reticule.Transform:GetWorldPosition())
                inst:ForceFacePoint(reticulepos)        
            else
                local mousepos = TheInput:GetWorldPosition()             
                inst:ForceFacePoint(mousepos)        
            end  
        end,        
        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.readytoshoot = true end),
            TimeEvent(20*FRAMES, function(inst) inst.sg:GoToState("chagefull") end),            
        },        
    },

    State{
        name = "chagefull",
        tags = {"busy", "doing","waitforbutton"},
        
        onenter = function(inst)           
            inst.rightbuttonup = nil 
            inst.components.locomotor:Stop()
            
            inst.AnimState:PlayAnimation("charge_super_pre")
            inst.AnimState:PushAnimation("charge_super_loop",true)
            inst.fullcharge = true

            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/electro")
            
        end,        

        onexit = function(inst)
            inst.rightbuttonup = nil
            inst:ClearBufferedAction()     
            if not inst.shooting then
                inst.fullcharge = nil
            end
            inst.shoot = nil
            inst.shooting = nil
            inst.SoundEmitter:KillSound("chargedup")
        end,

        onupdate = function(inst)
            if inst.rightbuttonup then
                inst.rightbuttonup = nil
                inst.shoot = true 
            end

            if inst.shoot and inst.readytoshoot then
                inst.shooting = true
                inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/creatures/boss/hulk_metal_robot/laser",  {intensity = math.random(0.7, 1)})---jason can i use a random number from .7 to 1 instead of a static number (.8)?

                inst.sg:GoToState("shoot")
            end

            local controller_mode = TheInput:ControllerAttached()
            if controller_mode then
                local reticulepos = Vector3(inst.livingartifact.components.reticule.reticule.Transform:GetWorldPosition())
                inst:ForceFacePoint(reticulepos)        
            else
                local mousepos = TheInput:GetWorldPosition()             
                inst:ForceFacePoint(mousepos)        
            end    
        end,  
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.readytoshoot = true end),      
        },  
	},

    State{
        name = "shoot",
        tags = {"busy"},
        
        onenter = function(inst)       
            inst.components.locomotor:Stop()
            if inst.fullcharge then
                inst.AnimState:PlayAnimation("charge_super_pst")
            else
                inst.AnimState:PlayAnimation("charge_pst")
            end
        end,
        
        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) shoot(inst)  end),   
            TimeEvent(5*FRAMES, function(inst) inst.sg:RemoveStateTag("busy")  end),   
            
        }, 
        
        onexit = function(inst)
            inst.fullcharge = nil   
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },             
    },

    State{
        name = "tap_loop",
        tags = {"doing"},

        onenter = function(inst, timeout)
            local targ = inst:GetBufferedAction() and inst:GetBufferedAction().target or nil
            inst.sg:SetTimeout(timeout or 1)
            inst.components.locomotor:Stop()         
            inst.AnimState:PushAnimation("tamp_loop",true)
        end,
        
        timeline=
        {
            TimeEvent(1*FRAMES, function( inst )
               inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/tamping_tool")
            end),
            TimeEvent(8*FRAMES, function( inst )
               inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/tamping_tool")
            end),            
            TimeEvent(16*FRAMES, function( inst )
               inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/tamping_tool")
            end),       
            TimeEvent(24*FRAMES, function( inst )
               inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/tamping_tool")
            end),       
            TimeEvent(32*FRAMES, function( inst )
               inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/tamping_tool")
            end),                   
        },
        
        ontimeout= function(inst)
            inst.AnimState:PlayAnimation("tamp_pst")
            inst.sg:GoToState("idle", false)
            inst:PerformBufferedAction()
        end,
    },
	
	State {
        name = "morph",
        tags = {"busy"},
        onenter = function(inst)

            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("morph_idle")
            inst.AnimState:PushAnimation("morph_complete",false)            
        end,
        
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/music/iron_lord")
            end),
            TimeEvent(15*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/morph")
            end),
            TimeEvent(105*FRAMES, function(inst) 
                -- inst.components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, .5, 40)
            end),

            TimeEvent(105*FRAMES, function(inst) 
                inst.AnimState:Hide("beard")
            end),

            TimeEvent(152*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/music/iron_lord_suit", "ironlord_music")
            end),
        },

        
        onexit = function(inst)
            inst.livingartifact.BecomeIronLord_post(inst.livingartifact)
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) 
                inst.sg:GoToState("idle")                                    
            end),
        },         
    },

    State{
        name = "revert",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("death")
            inst.sg:SetTimeout(3)
            --inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/death_beaver")
            -- inst.components.beaverness.doing_transform = true
        end,

        -- timeline =
        -- {
        --     TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams ("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intesity= .2}) end),
        --     TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intesity= .4}) end),
        --     TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intesity= .6}) end),
        --     TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intesity= 1}) end),
        --     TimeEvent(54*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/explosion") end),
        -- },
        
        ontimeout = function(inst) 
            -- TheFrontEnd:Fade(false,2)
            inst:DoTaskInTime(2, function() 
                
                -- GetClock():MakeNextDay()
                
                -- inst.components.beaverness.makeperson(inst)
                -- inst.components.sanity:SetPercent(.25)
                -- inst.components.health:SetPercent(.33)
                -- inst.components.hunger:SetPercent(.25)
                -- inst.components.beaverness.doing_transform = false
                inst.sg:GoToState("wakeup")
                -- TheFrontEnd:Fade(true,1)
            end)
        end
    },

    State{
        name = "transform_pst",
        tags = {"busy"},
        onenter = function(inst)
			inst.components.playercontroller:Enable(false)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("transform_pst")
            inst.components.health:SetInvincible(true)
            -- if TUNING.DO_SEA_DAMAGE_TO_BOAT and (inst.components.driver and inst.components.driver.vehicle and inst.components.driver.vehicle.components.boathealth) then
                -- inst.components.driver.vehicle.components.boathealth:SetInvincible(true)
            -- end
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            -- if TUNING.DO_SEA_DAMAGE_TO_BOAT and (inst.components.driver and inst.components.driver.vehicle and inst.components.driver.vehicle.components.boathealth) then
                -- inst.components.driver.vehicle.components.boathealth:SetInvincible(false)
            -- end
            -- inst.components.playercontroller:Enable(true)
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
				-- TheCamera:SetDistance(30)
				inst:SetCameraDistance(30)
				inst.sg:GoToState("idle")
			end ),
        },        
    },    

    State{
        name = "explode",
        tags = {"busy"},
        
        onenter = function(inst)     
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("suit_destruct")            
        end,
        
        timeline=
        {   ---- death explosion
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= .2}) end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= .4}) end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= .6}) end),
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= 1}) end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/electro",nil,.5) end),
            TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/electro",nil,.5) end),
            TimeEvent(54*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/explosion") end),
            
            TimeEvent(54*FRAMES, function(inst) inst.SoundEmitter:KillSound("ironlord_music") end), --- jason i put the music here and commented out the living_artifact.lua lines                           
            
            TimeEvent(52*FRAMES, function(inst) 
                local explosion = SpawnPrefab("living_suit_explode_fx")
                explosion.Transform:SetPosition(inst.Transform:GetWorldPosition())  
                inst.livingartifact.DoDamage(inst.livingartifact, 5)
            end),
        }, 
        
        onexit = function(inst)
             inst.livingartifact.Revert(inst.livingartifact)
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },             
    },    
}

return STATES