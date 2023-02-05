require "brains/ancientrobotbrain"
require "stategraphs/SGAncientRobot"

local UPDATETIME = 5

local assets=
{
	Asset("ANIM", "anim/metal_spider.zip"),
    Asset("ANIM", "anim/metal_claw.zip"),
    Asset("ANIM", "anim/metal_leg.zip"),
    Asset("ANIM", "anim/metal_head.zip"),
    Asset("MINIMAP_IMAGE", "metal_spider"),
    Asset("MINIMAP_IMAGE", "metal_leg"),
    Asset("MINIMAP_IMAGE", "metal_head"),
    Asset("MINIMAP_IMAGE", "metal_claw"),    
}

local prefabs =
{
    "iron",
    "sparks_fx",
    "sparks_green_fx",
    "laser_ring",
}

SetSharedLootTable( 'anchientrobot',
{
    {'iron',  1.00},
    {'iron',  1.00},
    {'iron',  1.00},
    {'iron',  0.33},
    {'iron',  0.33},
    {'iron',  0.33},
    {'gears', 1.00},
    {'gears', 0.33},
})

local function removemoss(inst)
    if inst:HasTag("mossy") then           
        inst:RemoveTag("mossy")
        local x, y, z = inst.Transform:GetWorldPosition()
        for i=1,math.random(12,15) do
            inst:DoTaskInTime(math.random()*0.5,function()                
                local fx = SpawnPrefab("robot_leaf_fx")
                fx.Transform:SetPosition(x + (math.random()*4) -2 ,y,z + (math.random()*4) -2)
            end)
        end
    end    
end

local function Retarget(inst)
    return FindEntity(inst, TUNING.ROBOT_TARGET_DIST, function(guy)
            return not guy:HasTag("ancient_robot") and
					inst.components.combat:CanTarget(guy) and
					not guy:HasTag("wall")
        end)
end

local function KeepTarget(inst, target)
    return true
end

local function periodicupdate(inst)
    if TheWorld.components.aporkalypse and TheWorld.components.aporkalypse:IsActive() then
        return
    end

    if inst.lifetime and inst.lifetime > 0 then
        inst.lifetime = inst.lifetime - UPDATETIME
    else       
        inst.wantstodeactivate = true
        inst.updatetask:Cancel()
        inst.updatetask = nil
    end
end

local function OnLightning(inst, data)
    inst.lifetime = 90
    if inst:HasTag("dormant") then
        inst.wantstodeactivate = nil
        inst:RemoveTag("dormant")
        inst:PushEvent("shock")
        if not inst.updatetask then
            inst.updatetask = inst:DoPeriodicTask(UPDATETIME, periodicupdate)
        end
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)

    local fx = SpawnPrefab("sparks_green_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y+1,z)
end

local function GetStatus(inst)

end

local function OnSave(inst,data)
    local refs = {}
    if inst.hits then
        data.hits = inst.hits
    end
    if inst:HasTag("dormant") then
        data.dormant = true
    end
    if inst:HasTag("mossy") then
        data.mossy = true
    end
    if inst.lifetime then
        data.lifetime = inst.lifetime
    end
    if inst.spawned then
        data.spawned = true
    end
    if refs and #refs >0 then
        return refs
    end
end

local function OnLoad(inst,data)
    if data then
        if data.hits then
            inst.hits = data.hits
        end
        if data.dormant then
            inst:AddTag("dormant")
        end
        if data.mossy then
            inst:AddTag("mossy")
        end
        if data.spawned then
            inst.spawned = true
        end
        if data.lifetime then
            inst.lifetime = data.lifetime
            inst.updatetask = inst:DoPeriodicTask(UPDATETIME, periodicupdate)
        end
    end
    if inst:HasTag("dormant") then
        inst.sg:GoToState("idle_dormant")
    end
end

local function OnLoadPostPass(inst,data)
    if inst.spawned then
        if inst.spawntask then
            inst.spawntask:Cancel()
            inst.spawntask = nil
        end
    end
end

local function mergeaction(act)
    if act.target then
        local target = act.target
        if not target:HasTag("ancient_robots_assembly") then
            local hulk = SpawnPrefab("ancient_robots_assembly")
            local x,y,z = act.doer.Transform:GetWorldPosition()
            hulk.Transform:SetPosition(x,y,z)
            target.mergefunction(target,hulk)
            target = hulk
            act.target:Remove()
        end
        act.doer.mergefunction(act.doer,target)
        target:PushEvent("merge")
        act.doer:Remove()
    end
end

local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("metal_spider.png")
    inst.collisionradius = 1.2
    MakeCharacterPhysics(inst, 99999, inst.collisionradius)

    inst:AddTag("lightningrod")

    inst:AddTag("laser_immune")
    inst:AddTag("ancient_robot")
    inst:AddTag("mech")
    inst:AddTag("monster")

    anim:SetBank("metal_spider")
    anim:SetBuild("metal_spider")
    anim:PlayAnimation("idle", true)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    
    inst:AddComponent("timer")
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body01"
    inst.components.combat:SetDefaultDamage(TUNING.ROBOT_RIBS_DAMAGE)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(
        function(inst, worker, workleft)
            OnAttacked(inst, {attacker=worker})
            inst.components.workable:SetWorkLeft(1)
            inst:PushEvent("attacked")
        end)
    inst.components.workable.undestroyable = true

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('anchientrobot')
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("knownlocations")
    
    inst.lightningpriority = 1
    inst:ListenForEvent("lightningstrike", OnLightning)

    inst.entity:AddLight()
    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(5)
    inst.Light:SetFalloff(3)
    inst.Light:SetColour(1, 0, 0)
    inst.Light:Enable(false)
    
    inst.periodicupdate = periodicupdate
    inst.UPDATETIME = UPDATETIME
    inst.hits = 0

    inst.special_action = mergeaction
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
    inst.removemoss = removemoss

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 2
    
    local brain = require "brains/ancientrobotbrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGAncientRobot")

    inst.spawntask = inst:DoTaskInTime(0,function()
            if not inst.spawned then
                inst:AddTag("mossy")
                inst:AddTag("dormant")
                inst.sg:GoToState("idle_dormant")
                inst.spawned = true
            end            
        end)

    inst:ListenForEvent("beginaporkalypse", function(world) OnLightning(inst) end, GetWorld())

    return inst
end

local function ribsfn(Sim)
    local inst = commonfn(Sim)
    local shadow = inst.entity:AddDynamicShadow()
    inst.collisionradius = 2
    shadow:SetSize( 6, inst.collisionradius )

	if not TheWorld.ismastersim then
		return inst
	end

    inst:AddTag("beam_attack")
    inst:AddTag("robot_ribs")

    inst.AnimState:SetBank("metal_spider")
    inst.AnimState:SetBuild("metal_spider")
    inst.AnimState:PlayAnimation("idle", true)

    inst.mergefunction = function(inst,hulk)
        hulk.spine = 1
    end

    return inst
end

local function armfn(Sim)

    local inst = commonfn(Sim)
    inst.MiniMapEntity:SetIcon( "metal_claw.png" )
    inst.collisionradius = 1.2
    MakeCharacterPhysics(inst, 99999, inst.collisionradius)
    
    inst:AddTag("IsSixFaced")
    inst:AddTag("noeightfaced")
    inst.Transform:SetSixFaced()

	if not TheWorld.ismastersim then
		return inst
	end
    
    inst:AddTag("beam_attack")
    inst:AddTag("robot_arm")

    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 3

    inst.AnimState:SetBank("metal_claw")
    inst.AnimState:SetBuild("metal_claw")
    inst.AnimState:PlayAnimation("idle", true)

    inst.mergefunction = function(inst,hulk)
        hulk.arms = hulk.arms + 1
    end    

    return inst
end


local function legfn(Sim)

    local inst = commonfn(Sim)
    inst.MiniMapEntity:SetIcon( "metal_leg.png" )
    inst.collisionradius = 1.2
    MakeCharacterPhysics(inst, 99999, inst.collisionradius)

    inst:AddTag("IsSixFaced")
    inst:AddTag("noeightfaced")
    inst.Transform:SetSixFaced()
    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize( 4, 2 )

    inst:AddTag("jump_attack")
    inst:AddTag("lightning_taunt")
    inst:AddTag("robot_leg")

	if not TheWorld.ismastersim then
		return inst
	end

    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 4

    inst.AnimState:SetBank("metal_leg")
    inst.AnimState:SetBuild("metal_leg")
    inst.AnimState:PlayAnimation("idle", true)

    inst.mergefunction = function(inst,hulk)
        hulk.legs = hulk.legs + 1
    end 

    inst.components.combat:SetDefaultDamage(TUNING.ROBOT_LEG_DAMAGE)

    return inst
end

local function headfn(Sim)

    local inst = commonfn(Sim)
    inst.MiniMapEntity:SetIcon( "metal_head.png" )
    inst.collisionradius = 2
    MakeCharacterPhysics(inst, 99999, inst.collisionradius)

    inst:AddTag("IsSixFaced")
    inst:AddTag("noeightfaced")
    inst.Transform:SetSixFaced()
    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize( 4, 2 )

	if not TheWorld.ismastersim then
		return inst
	end

    inst:AddTag("jump_attack")
    inst:AddTag("robot_head")

    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 4

    inst.AnimState:SetBank("metal_head")
    inst.AnimState:SetBuild("metal_head")
    inst.AnimState:PlayAnimation("idle", true)

    inst.components.combat:SetDefaultDamage(TUNING.ROBOT_LEG_DAMAGE)

    inst.mergefunction = function(inst,hulk)
        hulk.head = 1
    end    

    return inst
end

return Prefab( "forest/animals/ancient_robot_ribs", ribsfn, assets, prefabs),
       Prefab( "forest/animals/ancient_robot_claw", armfn, assets, prefabs),
       Prefab( "forest/animals/ancient_robot_leg", legfn, assets, prefabs),
       Prefab( "forest/animals/ancient_robot_head", headfn, assets, prefabs)