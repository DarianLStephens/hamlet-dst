require "prefabutil"
require "recipes"

local assets =
{
    Asset("ANIM", "anim/pig_house_sale.zip"),
    Asset("ANIM", "anim/player_small_house1.zip"),
    Asset("ANIM", "anim/player_large_house1.zip"),

    Asset("ANIM", "anim/player_large_house1_manor_build.zip"),
    Asset("ANIM", "anim/player_large_house1_villa_build.zip"),
    Asset("ANIM", "anim/player_small_house1_cottage_build.zip"),
    Asset("ANIM", "anim/player_small_house1_tudor_build.zip"),
    Asset("ANIM", "anim/player_small_house1_gothic_build.zip"),
    Asset("ANIM", "anim/player_small_house1_brick_build.zip"),
    Asset("ANIM", "anim/player_small_house1_turret_build.zip"),

    Asset("MINIMAP_IMAGE", "player_house_brick"),
    Asset("MINIMAP_IMAGE", "player_house_cottage"),
    Asset("MINIMAP_IMAGE", "player_house_gothic"),
    Asset("MINIMAP_IMAGE", "player_house_manor"),
    Asset("MINIMAP_IMAGE", "player_house_tudor"),
    Asset("MINIMAP_IMAGE", "player_house_turret"),
    Asset("MINIMAP_IMAGE", "player_house_villa"),

    Asset("MINIMAP_IMAGE", "pig_house_sale"),
    
    Asset("SOUND", "sound/pig.fsb"),
    Asset("INV_IMAGE", "playerhouse_city"),
}

local prefabs =
{
    "renovation_poof_fx",
}

local function setScale(inst,build)
    inst.AnimState:SetScale(0.75,0.75,0.75)
end

local function getScale(inst,build)
    return {0.75,0.75,0.75}
end

local function LightsOn(inst)
    if not inst:HasTag("burnt") then
        inst.Light:Enable(true)
        inst.AnimState:PlayAnimation("lit", true)
        -- inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
        inst.lightson = true
    end
end

local function LightsOff(inst)
    if not inst:HasTag("burnt") then
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation("idle", true)
        -- inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
        inst.lightson = false
    end
end

local function onfar(inst)
    --[[
    if not inst:HasTag("burnt") then
        if inst.components.spawner and inst.components.spawner:IsOccupied() then
            LightsOn(inst)
        end
    end
    ]]
end

local function getstatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.unboarded then
        return "SOLD"
    else
        return "FORSALE"
    end
end

local function onnear(inst)
    --[[
    if not inst:HasTag("burnt") then
        if inst.components.spawner and inst.components.spawner:IsOccupied() then
            LightsOff(inst)
        end
    end
    ]]
end

local function onwere(child)
    if child.parent and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        -- child.parent.SoundEmitter:PlaySound("dontstarve/pig/werepig_in_hut", "pigsound")
    end
end

local function onnormal(child)
    if child.parent and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        -- child.parent.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/city_pig/pig_in_house_LP", "pigsound")
    end
end

local function onoccupied(inst, child)
    if not inst:HasTag("burnt") then
    	-- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/city_pig/pig_in_house_LP", "pigsound")
        -- inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
    	
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
    	--inst.doortask = inst:DoTaskInTime(1, function() if not inst.components.playerprox:IsPlayerClose() then LightsOn(inst) end end)
        inst.doortask = inst:DoTaskInTime(1, function() LightsOn(inst) end)
    	if child then
    	    inst:ListenForEvent("transformwere", onwere, child)
    	    inst:ListenForEvent("transformnormal", onnormal, child)
    	end
    end
end

local function onhammered(inst, worker)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end

    inst.reconstruction_project_spawn_state = {
        bank = "pig_house",
        build = "pig_house",
        anim = "unbuilt",
    }

    if inst.doortask then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
    
    if not inst.components.fixable then
        inst.components.lootdropper:DropLoot()
    end

	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function ongusthammerfn(inst)
    onhammered(inst, nil)
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
    	inst.AnimState:PlayAnimation("hit")
    	inst.AnimState:PushAnimation("idle")
    end
end

local function onbuilt(inst)
	print("City house detected as built, do special stuff, whatever, to let you use it right away?")
	inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/pighouse/wood_1")
	inst.AnimState:PushAnimation("idle")
    inst.buyhouse(inst)
end

local function setcolor(inst,num)
    if not num then
        num = math.random()
    end
    local color = 0.5 + num * 0.5
    inst.AnimState:SetMultColour(color, color, color, 1)
    return num
end

local function buyhouse(inst)
    inst.AnimState:Hide("boards")
    inst.unboarded = true
    inst.components.door.disabled = false
    
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 6)
    for i, ent in ipairs(ents) do
        if ent.components.citypossession and not ent:HasTag("pig") then
            ent.components.citypossession:Disable()
        end
    end
end

local function reconstructed(inst)
    print("RECONSTRUCTED")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/pighouse/wood_1")
    if GetPlayer().homeowner or not inst:HasTag("citypossession") then
        inst.unboarded = true
        inst.AnimState:Hide("boards")
        inst.components.door.disabled = false 
    end
end

local function onsave(inst, data)

    if inst:HasTag("burnt") then
        data.burnt = true
    end
    if inst:HasTag("fire") then
        -- if the player is inside we gotta keep burning
        local interior_spawner = TheWorld.components.interiorspawner
        if not interior_spawner:IsPlayerConsideredInside(inst.interiorID) then
            data.burnt = true
        else
            data.burning = true
        end	
    end
    data.build = inst.build
    data.animset = inst.animset
    --data.colornum = inst.colornum
    data.unboarded = inst.unboarded
    data.interiorID = inst.interiorID
    data.prefabname = inst.prefabname
    data.minimapicon = inst.minimapicon
end

local function onload(inst, data)
    if data and data.interiorID then
        inst.interiorID = data.interiorID
    end

    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end

    if data and data.burning == true then
        inst:DoTaskInTime(0, function() inst.components.burnable:Ignite(true) end)
    end

    if data and data.build then
        inst.build = data.build
        inst.AnimState:SetBuild(inst.build)
        setScale(inst,inst.build)
    end

    if data and data.animset then
        inst.animset = data.animset
        inst.AnimState:SetBank(inst.animset )
    end    
    --if data and data.colornum then
    --    inst.colornum = setcolor(inst, data.colornum)
    --end
    if data then
        if data.unboarded then
            inst.unboarded = data.unboarded
            inst.AnimState:Hide("boards")
            inst.components.door.disabled = false
        else
            inst.components.door.disabled = true
        end
    end

    if data and data.prefabname then
        inst.prefabname = data.prefabname
        inst.name = STRINGS.NAMES[string.upper( data.prefabname)]
    end

    if data and data.minimapicon then
        inst.minimapicon = data.minimapicon
        inst.MiniMapEntity:SetIcon( inst.minimapicon )
    end

end

local function creatInterior(inst, name)
    if not inst:HasTag("spawned_shop") then

        --local interior_spawner = GetWorld().components.interiorspawner
		local interior_spawner = TheWorld.components.interiorspawner
        local ID = inst.interiorID

        if not ID then
			print("House doesn't already have ID, get a new one")
            ID = interior_spawner:GetNewID()
        end

        -- ID = "p" .. ID 
        -- inst.interiorID = ID

        local exterior_door_def = {
            my_door_id = name..ID.."_door",
            target_door_id = name..ID.."_exit",
            target_interior = ID
        }
		print("Player House - About to add door with data:")
		print("Door ID: ", exterior_door_def.my_door_id)
		print("Target Door ID: ", exterior_door_def.target_door_id)
		print("Target Interior ID: ", exterior_door_def.target_interior)
		
        interior_spawner:AddDoor(inst, exterior_door_def)
		
		--print("Player House - Post-AddDoor data:")
		

        if not inst.interiorID then

            local addprops = {}

            local floortexture = "levels/textures/interiors/noise_woodfloor.tex"
            local walltexture = "levels/textures/interiors/shop_wall_woodwall.tex"
            local minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
            local colorcube = "images/colour_cubes/pigshop_interior_cc.tex"

            addprops = {
                { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_old", background=true}, 
                    my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={"dontstarve_DLC003/common/objects/store/door_close"} },

                { name = "deco_roomglow", x_offset = 0, z_offset = 0 }, 

                { name = "shelves_cinderblocks",      x_offset = -4.5, z_offset = -15/3.5, rotation= -90, addtags={"playercrafted"} },
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
end

-- local function find_interior_index(inst, id)
--     for _, interior in pairs(inst.interiors) do
--         if interior.id == id then
--             return interior.x, interior.y
--         end
--     end
-- end

-- local function find_interior_id(inst, x, y)
--    for _, interior in pairs(inst.interiors) do
--         if interior.x == x and interior.y == y then
--             return interior
--         end
--     end 
-- end

-- local function register_interior(inst, id, from_id, dir)
--     local x,y = find_interior_index(inst, from_id)

--     if dir == "north" then
--         y = y + 1
--     elseif dir == "east" then
--         x = x + 1
--     elseif dir == "west" then
--         x = x - 1
--     end

--     table.insert(inst.interior, {id = id, x = x, y = y})
-- end

local function usedoor(inst,data)
    if inst.usesounds then
        if data and data.doer and data.doer.SoundEmitter then
            for i,sound in ipairs(inst.usesounds)do
                data.doer.SoundEmitter:PlaySound(sound)
            end
        end
    end
end

local function canburn(inst)
    local interior_spawner = TheWorld.components.interiorspawner
	if inst.components.door then
		local interior = inst.components.door.target_interior
		if interior_spawner:IsPlayerConsideredInside(interior) then
			-- try again in 2-5 seconds
			return false, 2 + math.random() * 3
		end
	end
	return true
end


local function makefn()

	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local light = inst.entity:AddLight()
		inst.entity:AddSoundEmitter()

		local minimap = inst.entity:AddMiniMapEntity()
		minimap:SetIcon( "pig_house_sale.png" )
		
		inst.entity:AddNetwork() -- Scary networking master/client stuff

		light:SetFalloff(1)
		light:SetIntensity(.5)
		light:SetRadius(1)
		light:Enable(false)
		light:SetColour(180/255, 195/255, 50/255)
		
		MakeObstaclePhysics(inst, 1)

		inst.unboarded = false

		inst:AddTag("playerhouse")
		inst:AddTag("renovatable")

		inst.build = "pig_house_sale"
		anim:SetBuild(inst.build) 

		inst.animset = "pig_house_sale"
		anim:SetBank(inst.animset)

		setScale(inst,inst.build)

		anim:PlayAnimation("idle", true)
		--[[
		inst.colornum = setcolor(inst)
		local color = 0.5 + math.random() * 0.5
		anim:SetMultColour(color, color, color, 1)
		]]

		inst:AddTag("structure")
		inst:AddTag("city_hammerable")

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
		
		inst:AddComponent("door")
		inst.components.door.disabled = true

		inst:AddComponent("inspectable")
		
		inst.components.inspectable.getstatus = getstatus
		
		MakeSnowCovered(inst, .01)

		MakeMediumBurnable(inst, nil, nil, true)
		MakeLargePropagator(inst)

		--inst.components.burnable:SetCanActuallyBurnFunction(canburn)
		
		inst:AddComponent("fixable")
		inst.components.fixable:AddRecinstructionStageData("rubble","pig_townhouse",inst.build,nil,getScale(inst,inst.build))
		inst.components.fixable:AddRecinstructionStageData("unbuilt","pig_townhouse",inst.build,nil,getScale(inst,inst.build))

		inst:ListenForEvent("burntup", function(inst)
			inst.components.fixable:AddRecinstructionStageData("burnt","pig_townhouse",inst.build,1,getScale(inst,inst.build))
			if inst.doortask then
				inst.doortask:Cancel()
				inst.doortask = nil
			end
			inst:Remove()
		end)

		inst:ListenForEvent("onignite", function(inst)
			if inst.components.spawner then
				inst.components.spawner:ReleaseChild()
			end
		end)
		
		inst.buyhouse = buyhouse
		
		TheWorld:ListenForEvent("deedbought", function()
			inst.buyhouse(inst)
			end, TheWorld)

		inst.interiors = {}
		inst:DoTaskInTime(0, function() 
			 creatInterior(inst, "playerhouse")
		end)

		inst.OnSave = onsave 
		inst.OnLoad = onload

		inst:ListenForEvent("usedoor", function(inst,data) usedoor(inst,data) end)

		TheWorld.playerhouse = inst
		inst.reconstructed = reconstructed

		inst:ListenForEvent( "onbuilt", onbuilt)

		inst.usesounds = {"dontstarve_DLC003/common/objects/store/door_open"}
		
		inst.RevealFog = function(inst)
			--print("house fog revealed")
			local x, y, z = inst.Transform:GetLocalPosition()
			local minimap = TheWorld.minimap.MiniMap
			local map = TheWorld.Map
			local cx, cy, cz = map:GetTileCenterPoint(x, 0, z)
			minimap:ShowArea(cx, cy, cz, 30)
			map:VisitTile(map:GetTileCoordsAtPoint(cx, cy, cz))
		end

		inst.FocusMinimap = function(inst, bottle)
			local px, py, pz = GetPlayer().Transform:GetWorldPosition()
			local x, y, z = inst.Transform:GetLocalPosition()
			local minimap = TheWorld.minimap.MiniMap
			print("Find house on minimap (" .. x .. ", "  .. z .. ")")
			GetPlayer().HUD.controls:ToggleMap()
			minimap:Focus(x - px, z - pz, -minimap:GetZoom()) --Zoom in all the way
		end


		return inst
    end
    return fn
end

local function placetestfn(inst)
    local pt = inst:GetPosition()
    local tile = TheWorld.Map:GetTileAtPoint(pt.x,pt.y,pt.z)
    if tile == WORLD_TILES.INTERIOR then
        return false
    end

    return true
end

return Prefab("playerhouse_city", makefn(), assets, prefabs),
    MakePlacer("playerhouse_city_placer", "pig_house_sale", "pig_house_sale", "idle")

--return Prefab( "playerhouse_city", makefn(), assets, prefabs),
--       MakePlacer("playerhouse_city_placer", "pig_house_sale", "pig_house_sale", "idle")