require "prefabutil"
require "recipes"
--require "cameras/interiorcamera"

local assets =
{
	Asset("ANIM", "anim/pig_house.zip"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs = 
{
	"pigman",
}

local function LightsOn(inst)
    if not inst:HasTag("burnt") then
        inst.Light:Enable(true)
        --inst.AnimState:PlayAnimation("lit", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
        inst.lightson = true
    end
end

local function LightsOff(inst)
    if not inst:HasTag("burnt") then
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
        inst.lightson = false
    end
end

local function onfar(inst) 
    if not inst:HasTag("burnt") then
        if inst.components.spawner and inst.components.spawner:IsOccupied() then
            LightsOn(inst)
        end
    end
end

local function getstatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.components.spawner and inst.components.spawner:IsOccupied() then
        if inst.lightson then
            return "FULL"
        else
            return "LIGHTSOUT"
        end
    end
end

local function onnear(inst) 
    if not inst:HasTag("burnt") then
        if inst.components.spawner and inst.components.spawner:IsOccupied() then
            LightsOff(inst)
        end
    end
end

local function onwere(child)
    if child.parent and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/werepig_in_hut", "pigsound")
    end
end

local function onnormal(child)
    if child.parent and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/city_pig/pig_in_house_LP", "pigsound")
    end
end

local function onoccupied(inst, child)
    if not inst:HasTag("burnt") then
    	inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/city_pig/pig_in_house_LP", "pigsound")
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
    	
        if inst.pig_task then
            inst.pig_task:Cancel()
            inst.pig_task = nil
        end
    	inst.pig_task = inst:DoTaskInTime(1, function() if not inst.components.playerprox:IsPlayerClose() then LightsOn(inst) end end)
    	if child then
    	    inst:ListenForEvent("transformwere", onwere, child)
    	    inst:ListenForEvent("transformnormal", onnormal, child)
    	end
    end
end

local function onvacate(inst, child)
    if not inst:HasTag("burnt") then
        if inst.pig_task then
            inst.pig_task:Cancel()
            inst.pig_task = nil
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        inst.SoundEmitter:KillSound("pigsound")
    	
    	if child then
    	    inst:RemoveEventCallback("transformwere", onwere, child)
    	    inst:RemoveEventCallback("transformnormal", onnormal, child)
            if child.components.werebeast then
    		    child.components.werebeast:ResetTriggers()
    		end
    		if child.components.health then
    		    child.components.health:SetPercent(1)
    		end
    	end    
    end
end
        
        
local function onhammered(inst, worker)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    if inst.pig_task then
        inst.pig_task:Cancel()
        inst.pig_task = nil
    end
	if inst.components.spawner then inst.components.spawner:ReleaseChild() end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function ongusthammerfn(inst)
    onhammered(inst, nil)
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
    	--inst.AnimState:PlayAnimation("hit")
    	inst.AnimState:PushAnimation("idle")
    end
end

local function OnDay(inst)
    --print(inst, "OnDay")
    if not inst:HasTag("burnt") then
        if inst.components.spawner:IsOccupied() then
            LightsOff(inst)
            if inst.pig_task then
                inst.pig_task:Cancel()
                inst.pig_task = nil
            end
            inst.pig_task = inst:DoTaskInTime(1 + math.random()*2, function() inst.components.spawner:ReleaseChild() end)
        end
    end
end

local function onbuilt(inst)
	--inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local light = inst.entity:AddLight()
    inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "pighouse.png" )
--{anim="level1", sound="dontstarve/common/campfire", radius=2, intensity=.75, falloff=.33, colour = {197/255,197/255,170/255}},
    light:SetFalloff(1)
    light:SetIntensity(.5)
    light:SetRadius(1)
    light:Enable(false)
    light:SetColour(180/255, 195/255, 50/255)
    
    MakeObstaclePhysics(inst, 1)

    anim:SetBank("pig_house")
    anim:SetBuild("pig_house")
    anim:PlayAnimation("idle", true)

    inst:AddTag("structure")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:AddComponent( "spawner" )
    inst.components.spawner:Configure( "pigman", TUNING.TOTAL_DAY_TIME*4)
    inst.components.spawner.onoccupied = onoccupied
    inst.components.spawner.onvacate = onvacate
    inst:ListenForEvent( "daytime", function() OnDay(inst) end, GetWorld())    
    
	inst:AddComponent( "playerprox" )
    inst.components.playerprox:SetDist(10,13)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)
    
	local interiors = GetWorld().components.interiorspawner
	local interior_def = {
		unique_name = "The Shop",
		width = 15,
		height = 12, --10,
        zoom = 20,
		prefabs = {
			{ name = "generic_interior", x_offset = -2, z_offset = 0 },
            { name = "shop_spawner", x_offset = 0, z_offset = 0 },
            { name = "pigman_shopkeep", x_offset = 0, z_offset = 0 },
			{ name = "side_door", x_offset = 6.8, z_offset = 0, type = "bottom" },
		}
	}	
	interiors:Add(inst, interior_def)
		
    inst:AddComponent("inspectable")
    
    inst.components.inspectable.getstatus = getstatus
	
	MakeSnowCovered(inst, .01)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)
    inst:ListenForEvent("burntup", function(inst)
        if inst.pig_task then
            inst.pig_task:Cancel()
            inst.pig_task = nil
        end
    end)
    inst:ListenForEvent("onignite", function(inst)
        if inst.components.spawner then
            inst.components.spawner:ReleaseChild()
        end
    end)

    --inst:AddComponent("blowinwindgust")
    --inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.PIGHOUSE_WINDBLOWN_SPEED)
    --inst.components.blowinwindgust:SetDestroyChance(TUNING.PIGHOUSE_WINDBLOWN_FALL_CHANCE)
    --inst.components.blowinwindgust:SetDestroyFn(ongusthammerfn)
    --inst.components.blowinwindgust:Start()

    inst.OnSave = onsave 
    inst.OnLoad = onload

	inst:ListenForEvent( "onbuilt", onbuilt)
    inst:DoTaskInTime(math.random(), function() 
        --print(inst, "spawn check day")
        if GetClock():IsDay() then 
            OnDay(inst)
        end 
    end)

    return inst
end

return Prefab( "common/objects/shop_test", fn, assets, prefabs ),
	   MakePlacer("common/shop_test_placer", "pig_house", "pig_house", "idle")  
