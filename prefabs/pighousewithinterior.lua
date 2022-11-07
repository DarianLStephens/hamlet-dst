require("worldsettingsutil")
require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/pig_house.zip"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs =
{
    "pigman",
    "splash_sink",
}

local destination = nil

local function Teleport(obj, target_x, target_y, target_z)
	--local target_x, target_y, target_z = destpos
	if obj.Physics ~= nil then
		obj.Physics:Teleport(target_x, target_y, target_z)
	elseif obj.Transform ~= nil then
		obj.Transform:SetPosition(target_x, target_y, target_z)
	end
	TheCamera:Snap()
end

local function Activate(inst, doer)
	print("Door activated!")
	--doer.transform:SetPosition(0,0,0)
	--local x, y, z = Vector3(2000,0,2000) --destination.Transform:GetWorldPosition()
	--Teleport(doer, x, y, z)
	Teleport(doer, 2000,0,2000) -- For easier testing
end

local function usedoor(inst,data)
	print("UseDoor Activated, prefab-side")
    if inst.usesounds then
        if data and data.doer and data.doer.SoundEmitter then
            for i,sound in ipairs(inst.usesounds)do
                data.doer.SoundEmitter:PlaySound(sound)
            end
        end
    end
	Activate(inst,data.doer)
end

local function createInterior(inst, name)
    if not inst:HasTag("spawned_shop") then

        --local interior_spawner = GetWorld().components.interiorspawner
		local interior_spawner = TheWorld.components.interiorspawner
        local ID = inst.interiorID
		--local name = nil

        if not ID then
            ID = interior_spawner:GetNewID()
        end

        -- ID = "p" .. ID 
        -- inst.interiorID = ID

        local exterior_door_def = {
            my_door_id = name..ID.."_door",
            target_door_id = name..ID.."_exit",
            target_interior = ID
        }
        interior_spawner:AddDoor(inst, exterior_door_def)

        if not inst.interiorID then

            local addprops = {}

            local floortexture = "levels/textures/noise_woodfloor.tex"
            local walltexture = "levels/textures/interiors/shop_wall_woodwall.tex"
            local minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
            local colorcube = "images/colour_cubes/pigshop_interior_cc.tex"

            addprops = {
                { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_old", background=true}, 
                    my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={"dontstarve_DLC003/common/objects/store/door_close"} },

                { name = "deco_roomglow", x_offset = 0, z_offset = 0 }, 

                -- { name = "shelves_cinderblocks",      x_offset = -4.5, z_offset = -15/3.5, rotation= -90, addtags={"playercrafted"} },
                { name = "deco_antiquities_wallfish", x_offset = -5,   z_offset =  3.9,    rotation = 90, addtags={"playercrafted"} },

                { name = "deco_antiquities_cornerbeam",  x_offset = -5,  z_offset =  -15/2, rotation =  90, flip=true, addtags={"playercrafted"} },
                { name = "deco_antiquities_cornerbeam",  x_offset = -5,  z_offset =   15/2, rotation =  90,            addtags={"playercrafted"} },
                { name = "deco_antiquities_cornerbeam2", x_offset = 4.7, z_offset =  -15/2, rotation =  90, flip=true, addtags={"playercrafted"} },
                { name = "deco_antiquities_cornerbeam2", x_offset = 4.7, z_offset =   15/2, rotation =  90,            addtags={"playercrafted"} },
                { name = "swinging_light_rope_1",        x_offset = -2,  z_offset =  0,     rotation = -90,            addtags={"playercrafted"} },

                { name = "charcoal", x_offset = -3, z_offset = -2 },
                { name = "charcoal", x_offset =  2, z_offset =  3 },

                { name = "window_round_curtains_nails", x_offset = 0, z_offset = 15/2, rotation = 90, addtags={"playercrafted"} },
            }

            interior_spawner:CreateRoom("generic_interior", 15, nil, 10, name..ID, ID, addprops, {}, walltexture, floortexture, minimaptexture, nil, colorcube, nil, true, "inside", "HOUSE","WOOD")
            interior_spawner:CreatePlayerHome(name..ID, ID)
        elseif not interior_spawner:GetPlayerHome(name..ID) then
            interior_spawner:CreatePlayerHome(name..ID, ID)
        end
		inst.interiorID = ID
        inst:AddTag("spawned_shop")
    end
	
	-- print("IST - Creating interior?")
	-- destination = (SpawnPrefab("generic_door"))
	-- destination.link = inst
	-- local size = (TheWorld.Map:GetSize()) * 2 -- This works best for some reason
	-- print(size)
	
	-- local globalbuffer = 50
	-- local roombuffer = 5
	-- local roomsize = 3
	-- local maxrooms = 5
	
	-- local roomarea = size + globalbuffer + roombuffer
	
	-- local roomx = 0 -- I've learned that the map goes from negative to positive, with the middle being 0
	-- local roomy = roomarea
	-- local roompos = {roomx, roomy}
	-- --local roompos = Vector3(roomx, 0, roomy)
	-- print("Calculated room pos:")
	-- print(roompos[1])
	-- print(roompos[2])
	
	-- destination.Transform:SetPosition(roompos[1],0,roompos[2])
	
	-- inst:AddTag("activedoor")
	
	
	-- --inst.components.Teleporter.targetTeleporter = destination
end



--Client update
local function OnUpdateWindow(window, inst, snow)
    if inst:HasTag("burnt") then
        inst._windowsnow = nil
        inst._window = nil
        snow:Remove()
        window:Remove()
    elseif inst.Light:IsEnabled() and inst.AnimState:IsCurrentAnimation("lit") then
        local build_name = inst.AnimState:GetSkinBuild()
        if build_name ~= inst._last_skin_build then
            inst._last_skin_build = build_name
            if build_name ~= "" then
                window.AnimState:SetSkin(build_name)
                snow.AnimState:SetSkin(build_name)
            else
                window.AnimState:SetBuild("pig_house")
                snow.AnimState:SetBuild("pig_house")
            end
        end

        if not window._shown then
            window._shown = true

            window:Show()
            snow:Show()
        end
    elseif window._shown then
        window._shown = false
        window:Hide()
        snow:Hide()
    end
end

local function LightsOn(inst)
    if not inst:HasTag("burnt") and not inst.lightson then
        inst.Light:Enable(true)
        inst.AnimState:PlayAnimation("lit", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
        inst.lightson = true

        local build_name = inst.AnimState:GetSkinBuild()
        if inst._window ~= nil then
            if build_name ~= "" then
                inst._window.AnimState:SetSkin(build_name)
            end
            inst._window.AnimState:PlayAnimation("windowlight_idle", true)
            inst._window:Show()
        end
        if inst._windowsnow ~= nil then
            if build_name ~= "" then
                inst._windowsnow.AnimState:SetSkin(build_name)
            end
            inst._windowsnow.AnimState:PlayAnimation("windowsnow_idle", true)
            inst._windowsnow:Show()
        end
    end
end

local function LightsOff(inst)
    if not inst:HasTag("burnt") and inst.lightson then
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
        inst.lightson = false
        if inst._window ~= nil then
            inst._window:Hide()
        end
        if inst._windowsnow ~= nil then
            inst._windowsnow:Hide()
        end
    end
end

local function onfar(inst)
    if not inst:HasTag("burnt") then --and inst.components.spawner:IsOccupied() then
        LightsOn(inst)
    end
end

local function getstatus(inst)
    -- return (inst:HasTag("burnt") and "BURNT")
        -- or (inst.components.spawner ~= nil and
            -- inst.components.spawner:IsOccupied() and
            -- (inst.lightson and "FULL" or "LIGHTSOUT"))
        -- or nil
	return "True"--(inst.lightson)
end

local function onnear(inst)
    if not inst:HasTag("burnt") then --and inst.components.spawner:IsOccupied() then
        LightsOff(inst)
    end
end

local function onwere(child)
    if child.parent ~= nil and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/werepig_in_hut", "pigsound")
    end
end

local function onnormal(child)
    if child.parent ~= nil and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/pig_in_hut", "pigsound")
    end
end

local function onoccupieddoortask(inst)
    inst.doortask = nil
    if not inst.components.playerprox:IsPlayerClose() then
        LightsOn(inst)
    end
end

local function onoccupied(inst, child)
    if not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("dontstarve/pig/pig_in_hut", "pigsound")
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")

        if inst.doortask ~= nil then
            inst.doortask:Cancel()
        end
        inst.doortask = inst:DoTaskInTime(1, onoccupieddoortask)
        if child ~= nil then
            inst:ListenForEvent("transformwere", onwere, child)
            inst:ListenForEvent("transformnormal", onnormal, child)
        end
    end
end

local function onvacate(inst, child)
    if not inst:HasTag("burnt") then
        if inst.doortask ~= nil then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        inst.SoundEmitter:KillSound("pigsound")
        LightsOff(inst)

        if child ~= nil then
            inst:RemoveEventCallback("transformwere", onwere, child)
            inst:RemoveEventCallback("transformnormal", onnormal, child)
            if child.components.werebeast ~= nil then
                child.components.werebeast:ResetTriggers()
            end

            local child_platform = TheWorld.Map:GetPlatformAtPoint(child.Transform:GetWorldPosition())
            if (child_platform == nil and not child:IsOnValidGround()) then
                local fx = SpawnPrefab("splash_sink")
                fx.Transform:SetPosition(child.Transform:GetWorldPosition())

                child:Remove()
            else
                if child.components.health ~= nil then
                    child.components.health:SetPercent(1)
                end
			    child:PushEvent("onvacatehome")
            end
        end
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.doortask ~= nil then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
    -- if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        -- inst.components.spawner:ReleaseChild()
    -- end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.lightson then
            inst.AnimState:PushAnimation("lit")
            if inst._window ~= nil then
                inst._window.AnimState:PlayAnimation("windowlight_hit")
                inst._window.AnimState:PushAnimation("windowlight_idle")
            end
            if inst._windowsnow ~= nil then
                inst._windowsnow.AnimState:PlayAnimation("windowsnow_hit")
                inst._windowsnow.AnimState:PushAnimation("windowsnow_idle")
            end
        else
            inst.AnimState:PushAnimation("idle")
        end
    end
end

local function onstartdaydoortask(inst)
    inst.doortask = nil
    -- if not inst:HasTag("burnt") then
        -- inst.components.spawner:ReleaseChild()
    -- end
end

local function onstartdaylighttask(inst)
    if inst:IsLightGreaterThan(0.8) then -- they have their own light! make sure it's brighter than that out.
        LightsOff(inst)
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaydoortask)
    elseif TheWorld.state.iscaveday then
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaylighttask)
    else
        inst.doortask = nil
    end
end

local function OnStartDay(inst)
    --print(inst, "OnStartDay")
    if not inst:HasTag("burnt") then
        --and inst.components.spawner:IsOccupied() then

        if inst.doortask ~= nil then
            inst.doortask:Cancel()
        end
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaylighttask)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
	createInterior(inst, "playerhouse")
end

local function onburntup(inst)
    if inst.doortask ~= nil then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
    if inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil
    end
    if inst._window ~= nil then
        inst._window:Remove()
        inst._window = nil
    end
    if inst._windowsnow ~= nil then
        inst._windowsnow:Remove()
        inst._windowsnow = nil
    end
end

local function onignite(inst)
    -- if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        -- inst.components.spawner:ReleaseChild()
    -- end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
	data.interiorID = inst.interiorID
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
	inst.interiorID = data.interiorID
end

-- local function spawncheckday(inst)
    -- inst.inittask = nil
    -- inst:WatchWorldState("startcaveday", OnStartDay)
    -- if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        -- if TheWorld.state.iscaveday or
            -- (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            -- inst.components.spawner:ReleaseChild()
        -- else
            -- inst.components.playerprox:ForceUpdate()
            -- onoccupieddoortask(inst)
        -- end
    -- end
-- end

local function oninit(inst)
    -- inst.inittask = inst:DoTaskInTime(math.random(), spawncheckday)
    -- if inst.components.spawner ~= nil and
        -- inst.components.spawner.child == nil and
        -- inst.components.spawner.childname ~= nil and
        -- not inst.components.spawner:IsSpawnPending() then
        -- local child = SpawnPrefab(inst.components.spawner.childname)
        -- if child ~= nil then
            -- inst.components.spawner:TakeOwnership(child)
            -- inst.components.spawner:GoHome(child)
        -- end
    -- end
end

local function MakeWindow()
    local inst = CreateEntity("Pighouse.MakeWindow")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.AnimState:SetBank("pig_house")
    inst.AnimState:SetBuild("pig_house")
    inst.AnimState:PlayAnimation("windowlight_idle")
    inst.AnimState:SetLightOverride(.6)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)

    inst:Hide()

    return inst
end

local function MakeWindowSnow()
    local inst = CreateEntity("Pighouse.MakeWindowSnow")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.AnimState:SetBank("pig_house")
    inst.AnimState:SetBuild("pig_house")
    inst.AnimState:PlayAnimation("windowsnow_idle")
    inst.AnimState:SetFinalOffset(2)

    inst:Hide()

    MakeSnowCovered(inst)

    return inst
end


local function OnPreLoad(inst, data)
    WorldSettings_Spawner_PreLoad(inst, data, TUNING.PIGHOUSE_SPAWN_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	
	inst.usesounds = {"dontstarve_DLC003/common/objects/store/door_open"}

    MakeObstaclePhysics(inst, 1)

    inst.MiniMapEntity:SetIcon("pighouse.png")
--{anim="level1", sound="dontstarve/common/campfire", radius=2, intensity=.75, falloff=.33, colour = {197/255,197/255,170/255}},
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1)
    inst.Light:Enable(false)
    inst.Light:SetColour(180/255, 195/255, 50/255)

    inst.AnimState:SetBank("pig_house")
    inst.AnimState:SetBuild("pig_house")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")

    MakeSnowCoveredPristine(inst)

    if not TheNet:IsDedicated() then
        inst._window = MakeWindow()
        inst._window.entity:SetParent(inst.entity)
        inst._windowsnow = MakeWindowSnow()
        inst._windowsnow.entity:SetParent(inst.entity)
        if not TheWorld.ismastersim then
            inst._window:DoPeriodicTask(FRAMES, OnUpdateWindow, nil, inst, inst._windowsnow)
        end
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -- inst:AddComponent("spawner")
    -- WorldSettings_Spawner_SpawnDelay(inst, TUNING.PIGHOUSE_SPAWN_TIME, TUNING.PIGHOUSE_ENABLED)
    -- inst.components.spawner:Configure("pigman", TUNING.PIGHOUSE_SPAWN_TIME)
    -- inst.components.spawner.onoccupied = onoccupied
    -- inst.components.spawner.onvacate = onvacate
    -- inst.components.spawner:SetWaterSpawning(false, true)
    -- inst.components.spawner:CancelSpawning()

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 13)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)
	
	-- inst:AddComponent("activatable")
	-- inst.components.activatable.standingaction = true
	-- inst.components.activatable.OnActivate = Activate
	
	--inst:AddComponent("teleporter")
	--inst.teleporter.targetTeleporter = (SpawnPrefab 
	
	inst:AddTag("activedoor")
	inst:AddComponent("door")
	inst.components.door.disabled = false
	inst.interiorID = 

    inst:AddComponent("inspectable")

    inst.components.inspectable.getstatus = getstatus

    MakeSnowCovered(inst)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)
    inst:ListenForEvent("burntup", onburntup)
    inst:ListenForEvent("onignite", onignite)
	
	inst:ListenForEvent("usedoor", function(inst,data) usedoor(inst,data) end)
	--inst.usesounds = {"dontstarve_DLC003/common/objects/store/door_open"}
	

	inst.FocusMinimap = function(inst, bottle)
		local px, py, pz = GetPlayer().Transform:GetWorldPosition()
		local x, y, z = inst.Transform:GetLocalPosition()
		local minimap = TheWorld.minimap.MiniMap
		print("Find house on minimap (" .. x .. ", "  .. z .. ")")
		GetPlayer().HUD.controls:ToggleMap()
		minimap:Focus(x - px, z - pz, -minimap:GetZoom()) --Zoom in all the way
	end
	

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst.inittask = inst:DoTaskInTime(0, oninit)

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("pighousewithinterior", fn, assets, prefabs),
    MakePlacer("interiorhouse_placer", "pig_house", "pig_house", "idle")
