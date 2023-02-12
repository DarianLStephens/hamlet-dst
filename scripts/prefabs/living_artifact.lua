local Badge = require "widgets/badge"

local assets =
{
	Asset("ANIM", "anim/living_artifact.zip"),
}

local ironlord_player = nil

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

local function CanInteract(inst,doer)
    if doer and not doer.were and (not doer.components.rider or not doer.components.rider:IsRiding()) and (not doer.components.driver or not doer.components.driver:GetIsDriving()) then
        return true
    end
end

local function ironactionstring(inst, action)
    if action.action.id == "CHARGE_UP" then
        return action.action.str
    end
    return STRINGS.ACTIONS.PUNCH
end

local function IronLordhurt(inst, delta)
    if delta < 0 then
        inst.sg:PushEvent("attacked")
    end
end

local function ArtifactActionButton(inst)

    local action_target = FindEntity(inst, 6, function(guy) return (guy.components.door and not guy.components.door.disabled and (not guy.components.burnable or not guy.components.burnable:IsBurning())) or                                                             
                                                             (guy.components.workable and guy.components.workable.workable and inst.components.worker:CanDoAction(guy.components.workable.action)) or 
                                                             (guy.components.hackable and guy.components.hackable:CanBeHacked() and inst.components.worker:CanDoAction(ACTIONS.HACK)) end)

    if not inst.sg:HasStateTag("busy") and action_target then
        if action_target.components.door and not action_target.components.door.disabled and (not action_target.components.burnable or not action_target.components.burnable:IsBurning()) then
            return BufferedAction(inst, action_target, ACTIONS.USEDOOR)
        elseif action_target.components.workable and action_target.components.workable.workable and action_target.components.workable.workleft > 0 then
            return BufferedAction(inst, action_target, action_target.components.workable.action)
        elseif action_target.components.hackable and action_target.components.hackable:CanBeHacked() and action_target.components.hackable.hacksleft > 0 then
            return BufferedAction(inst, action_target, ACTIONS.HACK)
        end         
    end

end

local function LeftClickPicker(inst, target_ent, pos)

    if target_ent and target_ent.components.door and not target_ent.components.door.disabled and (not target_ent.components.burnable or not target_ent.components.burnable:IsBurning()) then   
        return inst.components.playeractionpicker:SortActionList({ACTIONS.USEDOOR}, target_ent, nil)
    end

    if inst.components.combat:CanTarget(target_ent) then
        return inst.components.playeractionpicker:SortActionList({ACTIONS.ATTACK}, target_ent, nil)
    end

    if target_ent and target_ent.components.workable and target_ent.components.workable.workable and target_ent.components.workable.workleft > 0 and inst.components.worker:CanDoAction(target_ent.components.workable.action) then
        return inst.components.playeractionpicker:SortActionList({target_ent.components.workable.action}, target_ent, nil)
    end
    
    if target_ent and target_ent.components.hackable and target_ent.components.hackable:CanBeHacked() and target_ent.components.hackable.hacksleft > 0 and inst.components.worker:CanDoAction(ACTIONS.HACK) then
        return inst.components.playeractionpicker:SortActionList({ACTIONS.HACK}, target_ent, nil)
    end
end

local function RightClickPicker(inst, target_ent, pos)
    if not inst.sg:HasStateTag("charging") then
        return inst.components.playeractionpicker:SortActionList({ACTIONS.CHARGE_UP}, nil, nil)
    end    
    return {}
end

local IronlordBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, "livingartifact_meter", owner)
end)

local function SetHUDState(inst, player)
    -- local player = inst
    -- local player = ThePlayer
    if player.HUD then
        if inst.ironlord and not player.HUD.controls.ironlordbadge then
            -- player.HUD.controls.ironlordbadge = GetPlayer().HUD.controls.sidepanel:AddChild(IronlordBadge(player))
            player.HUD.controls.ironlordbadge = player.HUD.controls.sidepanel:AddChild(IronlordBadge(player))
            player.HUD.controls.ironlordbadge:SetPosition(0,-100,0)
            player.HUD.controls.ironlordbadge:SetPercent(1)

            player.HUD.controls.ironlordbadge.inst:ListenForEvent("ironlorddelta", function(_, data) 
                local percent =  inst.timeremaining/inst.timemax
                player.HUD.controls.ironlordbadge:SetPercent(percent, inst.timemax  )
            end, player)

            player.HUD.controls.crafttabs:Hide()
            player.HUD.controls.inv:Hide()
            player.HUD.controls.status:Hide()
            player.HUD.controls.mapcontrols.minimapBtn:Hide()
        
        elseif not inst.ironlord and player.HUD.controls.ironlordbadge then
            if player.HUD.controls.ironlordbadge then
                player.HUD.controls.ironlordbadge:Kill()
                player.HUD.controls.ironlordbadge = nil
            end

            player.HUD.controls.crafttabs:Show()
            player.HUD.controls.inv:Show()
            player.HUD.controls.status:Show()
            player.HUD.controls.mapcontrols.minimapBtn:Show()
        end
    end
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
    -- inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/pulse", {intensity=intensity})
    inst.flash = inst:DoTaskInTime(nextflash, function() inst.getnewflashtime(inst) end)
end

local function BecomeIronLord(inst,instant,player)

    inst:AddComponent("equippable")

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function()
        local pc = inst.components.playercontroller
        local offset = pc:GetWorldControllerVector()
        if offset then
            local newpt = Vector3(inst.Transform:GetWorldPosition())
            newpt.x = newpt.x + (offset.x *8)
            newpt.z = newpt.z + (offset.z *8)
            return newpt
        end
    end

    -- local player = inst
    -- local player = ThePlayer
    player.AnimState:AddOverrideBuild("player_living_suit_morph")
    -- player.components.poisonable:SetBlockAll(true)

	inst.ironlord_player = player
    player.livingartifact = inst
    
    player.ActionStringOverride = ironactionstring
    player:AddTag("ironlord")
    player:AddTag("has_gasmask")
    

    -- player:SetStateGraph("SGironlord")

    player.components.combat:SetDefaultDamage(TUNING.IRON_LORD_DAMAGE)

    -- player.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*1.3
    player.components.inventory:DropEverything()
    
    player.components.playercontroller.actionbuttonoverride = ArtifactActionButton
    player.components.playeractionpicker.leftclickoverride = LeftClickPicker
    player.components.playeractionpicker.rightclickoverride = RightClickPicker

    player:AddComponent("worker")
    player.components.worker:SetAction(ACTIONS.DIG, 1)
    player.components.worker:SetAction(ACTIONS.CHOP, 4)
    player.components.worker:SetAction(ACTIONS.MINE, 3)
    player.components.worker:SetAction(ACTIONS.HAMMER, 3)
    -- player.components.worker:SetAction(ACTIONS.HACK, 2)    

    player.components.sanity:SetPercent(1)
    player.components.health:SetPercent(1)
    player.components.hunger:SetPercent(1)

    player.components.hunger:Pause()
    player.components.sanity.ignore = true
    player.components.health.redirect = IronLordhurt
    player.components.health.redirect_percent = 0

    player:AddTag("laser_immune")
    player:AddTag("mech")

    inst.nightlight = SpawnPrefab("living_artifact_light")
    player:AddChild(inst.nightlight)

    -- player.components.dynamicmusic:Disable()
	-- player:PushEvent("enabledynamicmusic", false)
	TheWorld:PushEvent("enabledynamicmusic", false)
    -- player.SoundEmitter:PlaySound("dontstarve_DLC003/music/fight_epic_2", "ironlordmusic")    
    player.components.temperature:SetTemp(20)
    player:DoTaskInTime(0, function() SetHUDState(inst, player) end)
    
    -- inst.wasnearsighted = player.components.vision.nearsighted

    -- player.components.vision.nearsighted = false

    if player:HasTag("lightsource") then       
        player:RemoveTag("lightsource")    
    end    

    inst:AddTag("notslippery")
    inst:AddTag("cantdrop")      
    inst.flash = inst:DoTaskInTime(1, function() getnewflashtime(inst) end)

    if not instant and not inst.useloaddata then 
        player.sg:GoToState("morph")
        player:DoTaskInTime(2, function()
            player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_SUITUP"))
        end)        
    else 
        inst.BecomeIronLord_post(inst, player)
    end     
    player:PushEvent("livingartifactoveron")
    inst.useloaddata = nil
end

local function BecomeIronLord_post(inst, player)
    -- local player = inst
    local player = inst.ironlord_player
	if player.components.seamlessplayerswapper then
		player.components.seamlessplayerswapper:_StartSwap("waterbot")
	end
	-- inst.SoundEmitter:PlaySound("dontstarve_DLC003/music/iron_lord_suit", "ironlord_music") -- Moved from Stategraph, because it stops as a side-effect of the seamless swap.
	-- Changes the timing of the music my a second, maybe, which should be fine
	
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

end

local function Revert(inst)    
    inst.nightlight:Remove()
    inst.flash:Cancel()
    inst.flash = nil
    inst.ironlord = false

    inst.components.reticule:DestroyReticule()

    -- local player = inst
    local player = inst.ironlord_player

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
    player.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    player.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    
    player.components.playercontroller.actionbuttonoverride = nil
    player.components.playeractionpicker.leftclickoverride = nil
    player.components.playeractionpicker.rightclickoverride = nil

    player.components.hunger:Resume()
    player.components.sanity.ignore = false
    player.components.health.redirect = nil

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

-- DS - Doesn't seem to really work, unfortunately. The seamless swap is probably better
local function GetPointSpecialActions(inst, pos, useitem, right)
    if right then
        return { ACTIONS.CHARGE_UP }
    end
    return {}
end

local function OnOutoftime(inst)
    -- local player = inst
    local player = inst.ironlord_player
    player.sg:GoToState("explode")
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

local function OnActivate(inst, data)

	local player = data.doer
	
	if player:HasTag("player") then
		print("DS - Living Artifact activated by player")
		-- local player = inst
	else
		print("DS - Living Artifact was activated, but inst wasn't a player. Instead was", inst)
		-- return false
	end
	
	-- print("DS - Skipping player checks right now to get to the meat")
	
    if player.components.inventory:FindItem(function(item) if inst == item then return true end end) then
        player.components.inventory:RemoveItem(inst)   
        local x,y,z = player.Transform:GetWorldPosition()
        inst.Transform:SetPosition(x,y,z)
    end 

    if not inst.useloaddata then
        inst.timemax = TUNING.IRON_LORD_TIME
        inst.timeremaining = inst.timemax    
    end
    
    local dt = 0.5

    inst.timelimit = inst:DoPeriodicTask(dt,function() 
        testtimeleft(dt,inst)
    end)

    inst.ironlord = true
    inst.AnimState:PlayAnimation("activate")
    inst:ListenForEvent("animover",function() 
        if inst.AnimState:IsCurrentAnimation("activate") then
            inst:Hide()
        end
    end)
    BecomeIronLord(inst, nil, player)
end

local function OnSave(inst, data)
    local refs = {}
    
    if inst.timemax then
        data.timemax = inst.timemax
    end
    if inst.timeremaining then
        data.timeremaining = inst.timeremaining
    end
    if inst.wasnearsighted then
        data.wasnearsighted = inst.wasnearsighted
    end
    if inst.ironlord then
        print("SAVING IRON LORD")
        data.ironlord = inst.ironlord
    end    
    return refs
end

local function OnLoad(inst, data)

    print("DOING POST PASS")
	
	if data == nil then -- Safety checking, mostly for debug stuff
		return inst
	end

    if data.timemax then
        inst.timemax = data.timemax
    end
    if data.timeremaining then
        inst.timeremaining = data.timeremaining
    end
    if data.wasnearsighted then
        inst.wasnearsighted = data.wasnearsighted
    end    
    if data.ironlord then
        inst:Hide()
        print("IS IRON LORD")
        inst.useloaddata = true
    end

    -- GetPlayer().AnimState:Hide("beard")
end

local function returntointeriorscene(inst)
    if inst.ironlord then
        inst:Hide()
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddNetwork()
    -- MakeInventoryFloatable(inst, "idle_water", "idle")
    -- MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

    inst.AnimState:SetBank("living_artifact")
    inst.AnimState:SetBuild("living_artifact")
    inst.AnimState:PlayAnimation("idle")
	
	inst:AddComponent("hamlivingartifact")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
    
    inst:AddComponent("inspectable")

    -- inst:AddComponent("machine")
    -- inst.components.machine.turnonfn = OnActivate
    -- inst.components.machine.caninteractfn = CanInteract
	
	inst:ListenForEvent("activatesuit", function(inst,data)
		OnActivate(inst,data)
	end)	
	
    inst.Revert = Revert
    inst.DoDamage = DoDamage

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.ANCIENT_HULK_MINE_DAMAGE)

    inst:AddComponent("inventoryitem")

    inst.OnSave = OnSave 
    inst.OnLoad = OnLoad

    inst.getnewflashtime = getnewflashtime
    inst.BecomeIronLord_post = BecomeIronLord_post

    inst.returntointeriorscene = returntointeriorscene

    return inst
end

local function displaynamefn(inst)
	return ""
end

local function lightfn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

	inst.displaynamefn = displaynamefn

    inst.entity:AddLight()
    inst.Light:Enable(true)
    inst.Light:SetRadius(5)
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.6)
    inst.Light:SetColour(245/255,150/255,0/255)
    inst:DoTaskInTime(0,function()
        if inst:HasTag("lightsource") then       
            inst:RemoveTag("lightsource")    
        end
    end)   

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
    return inst
end

return Prefab( "living_artifact", fn, assets),
       Prefab( "living_artifact_light", lightfn, assets)

