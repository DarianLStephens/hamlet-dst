local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    -- Asset("ANIM", "anim/living_suit_build.zip"),
}

local prefabs =
{
    
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WILSON
end

prefabs = FlattenTree({ prefabs, start_inv }, true)


local function shoot(inst, fullcharge)
	print("DS - Inside prefab's Shooting function")
	
	local player = inst
	local rotation = player.Transform:GetRotation()
    local pt = Vector3(player.Transform:GetWorldPosition())
	local angle = rotation * DEGREES
	
    if fullcharge then
		print("Full charge, do big ball?")
        -- local player = GetPlayer()
        local beam = SpawnPrefab("ancient_hulk_orb")
        beam.components.complexprojectile.yOffset = 1
        -- local pt = Vector3(player.Transform:GetWorldPosition())
        local radius = 2.5
        local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
        local newpt = pt+offset

        beam.Transform:SetPosition(newpt.x,newpt.y,newpt.z)
        beam.host = player
        beam.AnimState:PlayAnimation("spin_loop",true)

        local targetpos = TheInput:GetWorldPosition()
        local controller_mode = TheInput:ControllerAttached()
        if controller_mode then
            targetpos = Vector3(player.livingartifact.components.reticule.reticule.Transform:GetWorldPosition())     
        end  
    
        local speed =  60 --  easing.linear(rangesq, 15, 3, maxrange * maxrange)
        beam.components.complexprojectile:SetHorizontalSpeed(speed)
        beam.components.complexprojectile:SetGravity(-1)
        beam.components.complexprojectile:Launch(targetpos, player)
        beam.components.combat.proxy = inst
        beam.owner = inst    
    else
		print("Not full charge, small ball it is!")
        -- local player = GetPlayer()
		-- local player = inst
		-- local rotation = player.Transform:GetRotation()
		-- local pt = Vector3(player.Transform:GetWorldPosition())
        local beam = SpawnPrefab("ancient_hulk_orb_small")
        -- local angle = rotation * DEGREES
        local radius = 2.5
        local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
        local newpt = pt+offset

        beam.Transform:SetPosition(newpt.x,1,newpt.z)
        beam.host = player
        beam.Transform:SetRotation(rotation)
        beam.AnimState:PlayAnimation("spin_loop",true) 
        beam.components.combat.proxy = inst
    end
	print("Either ball should have fired by now")
end



local function setfires(x,y,z, rad)
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, rad, nil, { "laser", "DECOR", "INLIMBO" })) do 
        if v.components.burnable then
            v.components.burnable:Ignite()
        end
    end
end

local function applydamagetoent(inst,ent, targets, rad, hit)
    local x, y, z = inst.Transform:GetWorldPosition()
    if hit then 
        targets = {}
    end    
    if not rad then 
        rad = 0
    end
    local v = ent
    if not targets[v] and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and not v:HasTag("laser_immune") then            
        local vradius = 0
        if v.Physics then
            vradius = v.Physics:GetRadius()
        end

        local range = rad + vradius
        if hit or v:GetDistanceSqToPoint(Vector3(x, y, z)) < range * range then
            local isworkable = false
            if v.components.workable ~= nil then
                local work_action = v.components.workable:GetWorkAction()
                --V2C: nil action for campfires
                isworkable =
                    (   work_action == nil and v:HasTag("campfire")    ) or
                    
                        (   work_action == ACTIONS.CHOP or
                            work_action == ACTIONS.HAMMER or
                            work_action == ACTIONS.MINE or   
                            work_action == ACTIONS.DIG or
                            work_action == ACTIONS.BLANK
                        )
            end
            if isworkable then
                targets[v] = true
                v:DoTaskInTime(0.6, function() 
                    if v.components.workable then
                        v.components.workable:Destroy(inst) 
                        local vx,vy,vz = v.Transform:GetWorldPosition()
                        v:DoTaskInTime(0.3, function() setfires(vx,vy,vz,1) end)
                    end
                 end)
                if v:IsValid() and v:HasTag("stump") then
                   -- v:Remove()
                end
            elseif v.components.pickable ~= nil
                and v.components.pickable:CanBePicked()
                and not v:HasTag("intense") then
                targets[v] = true
                local num = v.components.pickable.numtoharvest or 1
                local product = v.components.pickable.product
                local x1, y1, z1 = v.Transform:GetWorldPosition()
                v.components.pickable:Pick(inst) -- only calling this to trigger callbacks on the object
                if product ~= nil and num > 0 then
                    for i = 1, num do
                        local loot = SpawnPrefab(product)
                        loot.Transform:SetPosition(x1, 0, z1)
                        targets[loot] = true
                    end
                end

            elseif v.components.health then            
                inst.components.combat:DoAttack(v)                                    
                if v:IsValid() then
                    if not v.components.health or not v.components.health:IsDead() then
                        if v.components.freezable ~= nil then
                            if v.components.freezable:IsFrozen() then
                                v.components.freezable:Unfreeze()
                            elseif v.components.freezable.coldness > 0 then
                                v.components.freezable:AddColdness(-2)
                            end
                        end
                        if v.components.temperature ~= nil then
                            local maxtemp = math.min(v.components.temperature:GetMax(), 10)
                            local curtemp = v.components.temperature:GetCurrent()
                            if maxtemp > curtemp then
                                v.components.temperature:DoDelta(math.min(10, maxtemp - curtemp))
                            end
                        end
                    end
                end                   
            end
            if v:IsValid() and v.AnimState then
                SpawnPrefab("laserhit"):SetTarget(v)
            end
        end
    end 
    return targets   
end

local function DoDamage(inst, rad, startang, endang, spawnburns)
    local targets = {}
    -- local x, y, z = GetPlayer().Transform:GetWorldPosition()
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = nil
    if startang and endang then
        startang = startang + 90
        endang = endang + 90
        
        local down = TheCamera:GetDownVec()             
        angle = math.atan2(down.z, down.x)/DEGREES
    end

    setfires(x,y,z, rad)
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, rad, nil, { "laser", "DECOR", "INLIMBO" })) do  --  { "_combat", "pickable", "campfire", "CHOP_workable", "HAMMER_workable", "MINE_workable", "DIG_workable" }
        local dodamage = true
        if startang and endang then
            local dir = inst:GetAngleToPoint(Vector3(v.Transform:GetWorldPosition())) 

            local dif = angle - dir         
            while dif > 450 do
                dif = dif - 360 
            end
            while dif < 90 do
                dif = dif + 360
            end                       
            if dif < startang or dif > endang then                
                dodamage = nil
            end
        end
        if dodamage then
            targets = applydamagetoent(inst,v, targets, rad)
        end
    end
end

local function RightClickPicker(inst, target_ent, pos)
    if not inst.sg:HasStateTag("charging") then
        return inst.components.playeractionpicker:SortActionList({ACTIONS.CHARGE_UP}, nil, nil)
    end    
    return {}
end
-- local function IronLordhurt(inst, delta)
local function IronLordhurt(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    if amount < 0 then
        inst.sg:PushEvent("attacked")
    end
	return 0 -- This might be needed to make it take no real damage
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right then
        return { ACTIONS.CHARGE_UP }
    end
    return {}
end

local function OnSetOwner(inst)
	print("DS - Waterbot owner set thing running, attempting to make the charge action")
    if inst.components.playeractionpicker ~= nil then
		print("Charge action picker being set...")
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
	else
		print("Failed to find the action picker component")
    end
	inst.AnimState:SetBuild("living_suit_build")
end

local function getnewflashtime(inst)
    local time = 0
    local nextflash = 0
    local intensity = 0

    local per = inst.timeremaining/inst.timemax
    if per > 0.5 then
        time = 1
        nextflash = 2
        intensity = 0
    elseif per > 0.3 then
        time = 0.5
        nextflash = 1    
        intensity = 0.25
    elseif per > 0.05 then
        time = 0.3
        nextflash = 0.6
        intensity = 0.5
    else
        time = 0.13
        nextflash = 0.26    
        intensity = 0.8
    end

    -- GetPlayer():PushEvent("livingartifactoverpulse",{time=time}) 
    inst:PushEvent("livingartifactoverpulse",{time=time})
    inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/pulse", {intensity=intensity})
    inst.flash = inst:DoTaskInTime(nextflash, function() inst.getnewflashtime(inst) end)
end

local function BecomeIronLord_post(inst, player)
    -- local player = inst
    -- local player = inst.ironlord_player
    local player = inst
	if player.components.seamlessplayerswapper then
		player.components.seamlessplayerswapper:_StartSwap("waterbot")
	end
    -- player.AnimState:SetBuild("living_suit_build")
	
	if inst.components.playeractionpicker ~= nil then
		print("Charge action picker being set...")
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
	end
	

    local controller_mode = TheInput:ControllerAttached()
    if controller_mode and inst.components.reticule and not inst.components.reticule.reticule then
        inst.components.reticule:CreateReticule()
        inst.components.reticule.reticule:Show()
    end
	
	if not TheWorld.ismastersim then
		TheWorld:PushEvent("enabledynamicmusic", false) -- Trying to turn the special music off only for the players who are waterbots
	end

end

local function Revert(inst)    
    inst.nightlight:Remove()
    inst.flash:Cancel()
    inst.flash = nil
    inst.ironlord = false

    -- inst.components.reticule:DestroyReticule() -- Nill value?

    local player = inst
    -- local player = inst.ironlord_player

    -- player.components.vision.nearsighted = inst.wasnearsighted

    -- player.components.poisonable:SetBlockAll(nil)

    player.ActionStringOverride = nil
	
	if player.components.seamlessplayerswapper then
		player.components.seamlessplayerswapper:SwapBackToMainCharacter()
	end
	
    -- player.AnimState:SetBank("wilson")
    -- player.AnimState:SetBuild(player.prefab)
    -- player:SetStateGraph("SGwilson")
    player:RemoveTag("ironlord")
    player:RemoveTag("laser_immune")
    player:RemoveTag("mech")    
    player:RemoveTag("has_gasmask")    

    player:RemoveComponent("worker")
    -- player.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    -- player.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    
    -- player.components.playercontroller.actionbuttonoverride = nil
    -- player.components.playeractionpicker.leftclickoverride = nil
    -- player.components.playeractionpicker.rightclickoverride = nil

    player.components.hunger:Resume()
    player.components.sanity.ignore = false
    -- player.components.health.redirect = nil -- Might not need this? It should be contained in the new waterbot character, after all

    -- player.components.dynamicmusic:Enable()
	-- player:PushEvent("enabledynamicmusic", true)
	TheWorld:PushEvent("enabledynamicmusic", false)

    player.components.temperature:SetTemp(nil)
    player:DoTaskInTime(0, function() SetHUDState(inst, player) end)
    player.livingartifact = nil 
    player:PushEvent("livingartifactoveroff")
    inst:Remove()    

    player.components.locomotor:Stop()
    player:ClearBufferedAction()
    player:DoTaskInTime(0,function()player.sg:GoToState("bucked_post") end)

    player.SoundEmitter:KillSound("chargedup")
    player.AnimState:Show("beard")
end

local function OnOutoftime(inst)
    -- local player = inst
    -- local player = inst.ironlord_player
    -- player.sg:GoToState("explode")
    inst.sg:GoToState("explode")
end

local function testtimeleft(dt,inst)
    inst.timeremaining = inst.timeremaining - dt
    if inst.timeremaining <= 0 then
        OnOutoftime(inst)
        inst.timelimit:Cancel()
        inst.timelimit = nil        
    end
    inst:PushEvent("ironlorddelta")
end

local function common_postinit(inst)
	inst:ListenForEvent("setowner", OnSetOwner)
	-- inst:AddTag("invincible")
end


local function master_postinit(inst)

	inst:SetStateGraph("SGironlord")

    inst:AddComponent("worker")
    inst.components.worker:SetAction(ACTIONS.DIG, 1)
    inst.components.worker:SetAction(ACTIONS.CHOP, 4)
    inst.components.worker:SetAction(ACTIONS.MINE, 3)
    inst.components.worker:SetAction(ACTIONS.HAMMER, 3)
    -- inst.components.worker:SetAction(ACTIONS.HACK, 2)   
	
	inst.music = inst.SoundEmitter:PlaySound("dontstarve_DLC003/music/iron_lord_suit", "ironlord_music")

    -- inst:AddTag("umbrella")
	-- inst:AddTag("waterproofer")
	-- inst:AddComponent("waterproofer")
	-- inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

    inst:AddTag("ironlord")
    inst:AddTag("has_gasmask")
	
	-- inst:AddComponent("playeractionpicker") -- Probably jank and dangerous, but I want this working dangit!
	
	-- inst.components.playercontroller.actionbuttonoverride = ArtifactActionButton
    -- inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
    -- inst.components.playeractionpicker.rightclickoverride = RightClickPicker

    inst.components.combat:SetDefaultDamage(TUNING.IRON_LORD_DAMAGE)
    inst.getnewflashtime = getnewflashtime

    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*1.3 -- Maybe make this a tuning value of its own?
	
    inst.components.sanity:SetPercent(1)
    inst.components.health:SetPercent(1)
    inst.components.hunger:SetPercent(1)

    inst.components.hunger:Pause()
    inst.components.sanity.ignore = true
    inst.components.health.redirect = IronLordhurt
    -- inst.components.health.redirect_percent = 0
	inst.components.health.canheal = false

    inst:AddTag("laser_immune")
    inst:AddTag("mech")
	
	inst.nightlight = SpawnPrefab("living_artifact_light")
    inst:AddChild(inst.nightlight)
	
    if inst:HasTag("lightsource") then       
        inst:RemoveTag("lightsource")    
    end    

    inst:AddTag("notslippery")
    inst:AddTag("cantdrop")      
    inst.flash = inst:DoTaskInTime(1, function() getnewflashtime(inst) end)
	
    inst.livingartifact = inst 
	inst.DoDamage = DoDamage
	inst.Revert = Revert
	
	inst.Shoot = shoot
	
	

    if not inst.useloaddata then
        inst.timemax = TUNING.IRON_LORD_TIME
        inst.timeremaining = inst.timemax    
    end
    
    local dt = 0.5

    inst.timelimit = inst:DoPeriodicTask(dt,function() 
        testtimeleft(dt,inst)
    end)
	
	if not TheWorld.ismastersim then
		TheWorld:PushEvent("enabledynamicmusic", false) -- Trying to turn the special music off only for the players who are waterbots
	end
	
end

return MakePlayerCharacter("waterbot", prefabs, assets, common_postinit, master_postinit)
