local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)

HAMENV.AddStategraphPostInit("wilson", function(sg)

local actionhandlers = {
	ActionHandler(ACTIONS.ENTERDOOR, "dostandingaction"),
    ActionHandler(ACTIONS.BUILD_ROOM, "doshortaction"),
    ActionHandler(ACTIONS.DEMOLISH_ROOM, "doshortaction"),
	ActionHandler(ACTIONS.SHOP, "doshortaction"),
	
	-- ActionHandler(ACTIONS.RENOVATE, "dolongaction"),
    -- ActionHandler(ACTIONS.DISARM, "dolongaction"),
    -- ActionHandler(ACTIONS.REARM, "dolongaction"),   
    ActionHandler(ACTIONS.WEIGHDOWN, "doshortaction"),    
    ActionHandler(ACTIONS.HAMARTIFACTIVATE, "doshortaction"),    
    ActionHandler(ACTIONS.DISLODGE, "tap"), 
    ActionHandler(ACTIONS.SMELTER_HARVEST, "dolongaction"),
    ActionHandler(ACTIONS.CHARGE_UP, "charge"),
}

local states = {
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

for k, v in pairs(actionhandlers) do
    assert(v:is_a(ActionHandler), "Non-action handler added in mod actionhandler table!")
    sg.actionhandlers[v.action] = v
end

-- for k, v in pairs(events) do
    -- assert(v:is_a(EventHandler), "Non-event added in mod events table!")
    -- sg.events[v.name] = v
-- end

for k, v in pairs(states) do
    assert(v:is_a(State), "Non-state added in mod state table!")
    sg.states[v.name] = v
end

end)