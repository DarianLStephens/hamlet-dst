require "prefabutil"
local interiorspawner = require "components/interiorspawner"
-- if TheWorld.ismastersim then
	-- -- -return inst
	-- -- local TheWorld.components.interiorspawner = TheWorld.components.TheWorld.components.interiorspawner
-- end

local assets =
{
	Asset("ANIM", "anim/player_house_doors.zip"),
}

local prefabs =
{
}

local depth = 10
local width = 15


local EAST  = { x =  1, y =  0, label = "east" }
local WEST  = { x = -1, y =  0, label = "west" }
local NORTH = { x =  0, y =  1, label = "north" }
local SOUTH = { x =  0, y = -1, label = "south" }

-- not local, this is used in other places
player_interior_exit_dir_data =
{
	["north"] = {
		anim = "north",
		door_tag = "door_north",
		my_door_id_dir = "_NORTH",
		target_door_id_dir = "_SOUTH",
		x_offset = -depth/2,
		z_offset = 0,
		opposing_exit_dir = SOUTH,
		op_dir = "south",
		angle = 0,
		background = true,
	},

	["south"] = {
		anim = "south",
		door_tag = "door_south",
		my_door_id_dir = "_SOUTH",
		target_door_id_dir = "_NORTH",
		x_offset = depth/2,
		z_offset = 0,
		opposing_exit_dir = NORTH,
		op_dir = "north",
		angle = 180,
		background = false,
	},

	-- Note that the anims for east and west are reversed. 
	-- If we clean up the source assets we should only need to change these
	["east"] = {
		anim = "west",
		door_tag = "door_east",
		my_door_id_dir = "_EAST",
		target_door_id_dir = "_WEST",
		x_offset = 0,
		z_offset = width/2,
		opposing_exit_dir = WEST,
		op_dir = "west",
		angle = 90,
		background = true,
	},

	["west"] = {
		anim = "east",
		door_tag = "door_west",
		my_door_id_dir = "_WEST",
		target_door_id_dir = "_EAST",
		x_offset = 0,
		z_offset = -width/2,
		opposing_exit_dir = EAST,
		op_dir = "east",
		angle = 270,
		background = true,
	}
}

local function CheckForShadow(inst)
	inst:DoTaskInTime(0, function() 
		--if TheWorld.ismastersim then
			if inst.baseanimname == "south" and not inst.hasshadow then --not inst:HasChildPrefab("house_door_shadow") then
				inst:AddChild(SpawnPrefab("house_door_shadow")) 
				inst.hasshadow = true
			end
		--end
	end)
end

local function GetBaseAnimName(inst)
	--return GetTheWorld.components.interiorspawner():GetExitDirection(inst)
	return TheWorld.components.interiorspawner:GetExitDirection(inst)
end

local function InitHouseDoorInteriorPrefab(inst, doer, prefab_definition, interior_definition)
	--If we are spawned inside of a building, then update our door to point at our interior

	local door_definition =
	{
		my_interior_name = interior_definition.unique_name,
		my_door_id = prefab_definition.my_door_id,
		target_door_id = prefab_definition.target_door_id,
		target_interior = prefab_definition.target_interior,
	}

	--GetTheWorld.components.interiorspawner():AddDoor(inst, door_definition)
	TheWorld.components.interiorspawner:AddDoor(inst, door_definition)
	if prefab_definition.animdata then

		if prefab_definition.animdata.bank then
	    	inst.AnimState:SetBank(prefab_definition.animdata.bank)
	    	inst.door_data_bank = prefab_definition.animdata.bank
		end

	    if prefab_definition.animdata.build then
	    	inst.AnimState:SetBuild(prefab_definition.animdata.build)
	    	inst.door_data_build = prefab_definition.animdata.build
		end

		if prefab_definition.animdata.anim then
	    	inst.AnimState:PlayAnimation(prefab_definition.animdata.anim, true)
	    	inst.door_data_animstate = prefab_definition.animdata.anim

		end		

		inst.baseanimname = GetBaseAnimName(inst)
		if prefab_definition.animdata.background then
			inst.AnimState:SetLayer( LAYER_WORLD_BACKGROUND )
		
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.RotatingBillboard)
			--inst.AnimState:SetOrientation(ANIM_ORIENTATION.Billboard)
			inst.AnimState:SetSortOrder( 3 )

			inst.door_data_background = prefab_definition.animdata.background
		else
			inst.AnimState:SetLayer( LAYER_WORLD )
		end
	end

	if inst.components.door then
		inst.components.door:updateDoorVis()
	end
	inst.components.door:checkDisableDoor(false, "house_prop")
    inst:AddTag("interior_door")
	inst:RemoveTag("predoor")

	CheckForShadow(inst)
end


local function InitHouseDoor(inst, dir)
	inst.door_data_animstate = inst.prefab .. "_open_" .. player_interior_exit_dir_data[dir].anim
	inst.baseanimname = GetBaseAnimName(inst)

	inst.AnimState:PlayAnimation(inst.prefab .. "_opening_" .. player_interior_exit_dir_data[dir].anim, false)
	inst.AnimState:PushAnimation(inst.door_data_animstate, true)

	if inst.baseanimname ~= "south" then
		inst.AnimState:SetLayer( LAYER_WORLD_BACKGROUND )
		inst.AnimState:SetSortOrder( 3 )
	else
		inst.AnimState:SetLayer( LAYER_WORLD )
	end

	inst.initialized = true
end

local function onsave(inst, data)

	if inst.door_data_animstate then
		data.door_data_animstate = inst.door_data_animstate
	end
	
	if inst.door_data_background then
		data.door_data_background = inst.door_data_background
	end	

	data.rotation = inst.Transform:GetRotation()
    
    if inst.flipped then
        data.flipped = inst.flipped
    end

    if inst.minimapicon then
    	data.minimapicon = inst.minimapicon
    end

    if inst.startstate then
    	data.startstate = inst.startstate
    end

    if inst.usesounds then
    	data.usesounds = inst.usesounds
    end

    if inst.checked_obstruction then
    	data.checked_obstruction = inst.checked_obstruction
    end

end



local function onload(inst, data)

	inst.baseanimname = GetBaseAnimName(inst)

	if data.door_data_animstate then
    	inst.AnimState:PlayAnimation(data.door_data_animstate, true)
    	inst.door_data_animstate = data.door_data_animstate
	else
   		inst.AnimState:PlayAnimation(inst.prefab .. "_close_" .. player_interior_exit_dir_data[inst.baseanimname].anim, true)
	end	

    if data.rotation then
        inst.Transform:SetRotation(data.rotation)
    end	

	-- alas, the background flag wasn't correctly set on old doors
	data.door_data_background = inst.baseanimname ~= "south"

	if data.door_data_background then
		inst.AnimState:SetLayer( LAYER_WORLD_BACKGROUND )
		inst.AnimState:SetSortOrder( 3 )
		inst.door_data_background = data.door_data_background
	else
		inst.AnimState:SetLayer( LAYER_WORLD )
	end


    if data.minimapicon then
    	inst.minimapicon = data.minimapicon
		local minimap = inst.entity:AddMiniMapEntity()
	    minimap:SetIcon(inst.minimapicon)
    end

    if data.startstate then
    	inst.startstate = data.startstate
    end

    if data.sg_name then
    	inst.sg_name = data.sg_name
    end

    if data.usesounds then
    	inst.usesounds = data.usesounds
    end

    if data.checked_obstruction then
    	inst.checked_obstruction = data.checked_obstruction
    end
end

local function usedoor(inst, data)
    if inst.usesounds then
    	if data and data.doer and data.doer.SoundEmitter then
	        for i,sound in ipairs(inst.usesounds)do
	            data.doer.SoundEmitter:PlaySound(sound)
	        end
    	end
    end
end

local function ActivateSelf(inst, target_interior, door_interior)
	inst.components.door:checkDisableDoor(false, "house_prop")
		        
    local door_def =
    {
    	my_interior_name = door_interior.unique_name,
    	my_door_id = door_interior.unique_name .. player_interior_exit_dir_data[inst.baseanimname].my_door_id_dir,
    	target_interior = target_interior,
    	target_door_id =  target_interior .. player_interior_exit_dir_data[inst.baseanimname].target_door_id_dir
	}

    --GetTheWorld.components.interiorspawner():AddDoor(inst, door_def)
	TheWorld.components.interiorspawner:AddDoor(inst, door_def)
    inst.InitHouseDoor(inst, inst.baseanimname)

    inst:AddTag("interior_door")
	inst:RemoveTag("predoor")
	inst:AddTag(player_interior_exit_dir_data[inst.baseanimname].door_tag)

	inst:RemoveComponent("inspectable")
	inst.checked_obstruction = true
end

local function DeactivateSelf(inst)
	inst.components.door:checkDisableDoor(true, "house_prop")
	--GetTheWorld.components.interiorspawner():RemoveDoor(inst.components.door.door_id)
	TheWorld.components.interiorspawner:RemoveDoor(inst.components.door.door_id)
	inst:AddTag("predoor")
	inst:RemoveTag("interior_door")
	inst:RemoveTag(player_interior_exit_dir_data[inst.baseanimname].door_tag)

	inst:AddComponent("inspectable")
	inst.AnimState:PlayAnimation(inst.prefab .. "_close_" .. player_interior_exit_dir_data[inst.baseanimname].anim)

	-- also remove the door on the other end
	-- if the target interior exists then remove the target door from it
	local target_interior = inst.components.door.target_interior
	local target_door = inst.components.door.target_door_id

	-- clear door connectivity....
	inst.components.door.door_id = nil
	inst.components.door.interior_name = nil
	inst.components.door.target_door_id = nil
	inst.components.door.target_interior = nil
	-- ...and anim
   	inst.door_data_animstate = nil
end

local function common_on_built( inst )
	local interior_spawner = TheWorld.components.interiorspawner
	local current_interior = interior_spawner:GetCurrentInterior()

	local baseanimname = GetBaseAnimName(inst)
	inst.baseanimname = baseanimname
    CheckForShadow(inst)

	local wasExistingDoor = false
	local doors = interior_spawner:GetInteriorDoors(current_interior.unique_name)
    for index, door in ipairs(doors) do
    	if door.inst and door.inst.baseanimname then

    		-- Built a new door in the same direction of a previously built door (Multiple doors on a single wall)
    		if door.inst.baseanimname == baseanimname then
    			ActivateSelf(inst, door.inst.components.door.target_interior, current_interior)
				door.inst:Remove() -- Deletes an old door
				wasExistingDoor = true
				break
    		end
    	end
    end

	if not wasExistingDoor then
		local connecting_room = interior_spawner:GetPlayerRoomInDirection(current_interior.dungeon_name, current_interior.unique_name, baseanimname)
		if connecting_room then
			local found_interior = interior_spawner:GetInteriorByName(connecting_room)
			ActivateSelf(inst, found_interior.unique_name, current_interior)

			local opposing_exit = player_interior_exit_dir_data[baseanimname].op_dir
			local door_data = 
			{ 
				name = inst.prefab, 
				x_offset = player_interior_exit_dir_data[opposing_exit].x_offset,
				z_offset = player_interior_exit_dir_data[opposing_exit].z_offset,
				sg_name = nil,
				startstate = nil,
				animdata = { 
								bank = "player_house_doors", 
								build = "player_house_doors", 
								anim = inst.prefab .. "_open_" .. player_interior_exit_dir_data[opposing_exit].anim, 
								background = player_interior_exit_dir_data[opposing_exit].background 
							},
				my_interior_name = found_interior.unique_name,
               	my_door_id = found_interior.unique_name .. player_interior_exit_dir_data[baseanimname].target_door_id_dir,
               	target_door_id = current_interior.unique_name..player_interior_exit_dir_data[baseanimname].my_door_id_dir, 
              	target_interior = current_interior.unique_name,
               	rotation = -90,
               	hidden = false,
               	angle=0,
              	addtags = { "door_" .. opposing_exit },
            }

            interior_spawner:InsertHouseDoor(found_interior, door_data)
                    
            if baseanimname == "north" then
              	local prefabdata = { name = "house_door_shadow", x_offset = (depth/2), z_offset = 0, animdata = { bank = "player_house_doors", build = "player_house_doors", anim = inst.prefab .. "_south_floor" } }
               	interior_spawner:insertprefab(found_interior, prefabdata.name, {x_offset = prefabdata.x_offset, z_offset = prefabdata.z_offset}, prefabdata)
            end
        else
		end
	end

	inst.components.door.angle = player_interior_exit_dir_data[baseanimname].angle

    -- Replaces a door that hasn't been activated yet
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 3, {"wallsection"})
    if #ents >= 1 then
    	for _, ent in pairs(ents) do
    		if ent:HasTag("predoor") and ent ~= inst then
    			ent:Remove()
    			break
    		end
    	end
    end	
end

-- Used to remove things on the wall on the other side of a recently built door
-- Can also be used when hammering a door
local function ClearObstruction(inst)
    if inst.components.lootdropper then
    	local pt = Vector3(inst.Transform:GetWorldPosition())
    	local modifiedPos = nil
    	--local roomID = GetTheWorld.components.interiorspawner():getPropInterior(inst)
    	local roomID = TheWorld.components.interiorspawner:getPropInterior(inst)
    	if roomID then  
    		-- local room = GetTheWorld.components.interiorspawner().interiors[roomID]	
    		-- local origin = GetTheWorld.components.interiorspawner():getOriginForInteriorInst(inst)
    		-- modifiedPos = GetTheWorld.components.interiorspawner():ClampPosition(pt, origin, room.depth/2 - 1, room.width/2 - 1)
    		local room = TheWorld.components.interiorspawner.interiors[roomID]	
    		local origin = TheWorld.components.interiorspawner:getOriginForInteriorInst(inst)
    		modifiedPos = TheWorld.components.interiorspawner:ClampPosition(pt, origin, room.depth/2 - 1, room.width/2 - 1)
    	end
        inst.components.lootdropper:DropLoot(modifiedPos)
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    if inst.SoundEmitter then
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    end

    if inst.shelves and #inst.shelves > 0 then
        for i, v in ipairs(inst.shelves) do
            v.empty(v)
            v:Remove()
        end
    end

    inst:Remove()
end

local function common_house_door_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	

	inst.AnimState:SetBank("doorway_ruins")
	inst.AnimState:SetBuild("pig_ruins_door")

    inst.AnimState:SetLayer( LAYER_WORLD_BACKGROUND )
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.RotatingBillboard)
	-- inst.AnimState:SetOrientation(ANIM_ORIENTATION.Billboard)
	inst.AnimState:SetSortOrder( 3 )

   	inst:AddTag("predoor")
   	inst:AddTag("NOBLOCK")
   	inst:AddTag("wallsection")
   	inst:AddTag("house_door")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

   	local function CheckForRemoval()
   		inst:DoTaskInTime(0, function() 
   			inst.doorcanberemoved = TheWorld.components.interiorspawner:GetCurrentPlayerRoomConnectedToExit(inst.baseanimname)
            inst.roomcanberemoved = TheWorld.components.interiorspawner:GetCurrentPlayerRoomConnectedToExit(inst.baseanimname, inst.components.door.target_interior)
   		end)
   	end

   	inst:ListenForEvent("usedoor", function(inst,data) usedoor(inst,data) end)

   	-- Finds obstructions on the way of the new door and deconstructs them
   	inst:ListenForEvent("exitlimbo", function()
   		if not inst.checked_obstruction then
   			local x, y, z = inst.Transform:GetWorldPosition()
   			local ents = TheSim:FindEntities(x, y, z, 3, {"wallsection"})
		    if #ents >= 1 then
		    	for _, ent in pairs(ents) do
		    		if ent ~= inst then
		    			ClearObstruction(ent)
		    			ent:Remove()   
		    		end
		    	end
		    end
		    inst.checked_obstruction = true
   		end

   		CheckForShadow(inst)
   		CheckForRemoval()
   	end)

   	inst:ListenForEvent("doorremoved", function() 
   		if not inst:IsInLimbo() then
   			CheckForRemoval()
   		end
   	end, TheWorld)

   	inst:ListenForEvent("roomremoved", function() 
   		if not inst:IsInLimbo() then
   			CheckForRemoval()
   		end
   	end, TheWorld)

   	inst.InitHouseDoor = InitHouseDoor
   	inst.initInteriorPrefab = InitHouseDoorInteriorPrefab
   	inst.OnBuilt = common_on_built
    inst.ActivateSelf = ActivateSelf
    inst.DeactivateSelf = DeactivateSelf

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnLoadPostPass = function() 
    	if inst.components.door.target_door_id then
    		inst:AddTag("interior_door")
			inst:RemoveTag("predoor")
			inst:RemoveComponent("inspectable")

			inst.baseanimname = GetBaseAnimName(inst)

			inst:AddTag(player_interior_exit_dir_data[inst.baseanimname].door_tag)
    	end
    end

    inst:AddComponent("inspectable")
    --inst.components.inspectable:SetDescription(function() return GetString(GetPlayer().prefab, "ANNOUNCE_HOUSE_DOOR") end)

    inst:AddComponent("door")
    inst.components.door:checkDisableDoor(true, "house_prop")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable.canbeworkedbyfn = function(worker, numworks)
    	return worker == GetPlayer()
   	end
   	
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(
        function(inst, worker, workleft)
            if workleft <= 0 and worker == GetPlayer() then

            	-- local interior_spawner = GetTheWorld.components.interiorspawner()
            	local interior_spawner = TheWorld.components.interiorspawner
            	local otherdoor = interior_spawner:GetDoorInst(inst.components.door.target_door_id)
                if otherdoor then
            	   otherdoor:Remove() -- Remove door instance on the other side
                end
				-- Remove the door from the target interior
				interior_spawner:RemoveDoorFromInterior(inst.components.door.target_interior, inst.components.door.target_door_id)

            	interior_spawner:RemoveDoor(inst.components.door.target_door_id) 
            	interior_spawner:RemoveDoor(inst.components.door.door_id) -- Remove self from interior_spawner
                ClearObstruction(inst) -- Destroy self and drop loot
            end
        end)

    CheckForRemoval()

   	return inst
end

local function place_door_test_fn(inst, pt)
    inst.Transform:SetRotation(-90)

    local interior_spawner = TheWorld.components.TheWorld.components.interiorspawner
    if interior_spawner.current_interior then

        local originpt = interior_spawner:GetSpawnOrigin()
        local width = interior_spawner.current_interior.width
        local depth = interior_spawner.current_interior.depth

        local dist = 2
        local newpt = {}
        local backdiff =  pt.x < (originpt.x - depth/2 + dist)
        local frontdiff = pt.x > (originpt.x + depth/2 - dist)
        local rightdiff = pt.z > (originpt.z + width/2 - dist)
        local leftdiff =  pt.z < (originpt.z - width/2 + dist)

        local name = string.gsub(inst.prefab, "_placer", "")

        local canbuild = true
        local rot = -90
        if backdiff and not rightdiff and not leftdiff then
            --newpt = {x= originpt.x - depth/2, y=0, z=pt.z}
            newpt = { x = originpt.x - depth/2, y = 0, z = originpt.z }
            inst.AnimState:PlayAnimation(name .. "_open_north")

        elseif frontdiff and not rightdiff and not leftdiff then
        	newpt = { x = originpt.x + depth/2, y = 0, z = originpt.z }
            inst.AnimState:PlayAnimation(name .. "_open_south")

        elseif rightdiff and not backdiff and not frontdiff then
            --newpt = {x= pt.x, y=0, z= originpt.z + width/2}
            newpt = { x = originpt.x, y = 0, z = originpt.z + width/2 }
            inst.AnimState:PlayAnimation(name .. "_open_west")

        elseif leftdiff and not backdiff and not frontdiff then
            --newpt = {x=pt.x, y=0, z= originpt.z - width/2}
            newpt = { x = originpt.x, y = 0, z = originpt.z - width/2 }
            inst.AnimState:PlayAnimation(name .. "_open_east")
        else
			newpt = pt
            canbuild = false
        end

        if inst.parent then
            inst.parent:RemoveChild(inst)
        end

        if canbuild then
            inst.Transform:SetPosition(newpt.x, newpt.y, newpt.z)
            inst.Transform:SetRotation(rot)
        else
            inst.Transform:SetPosition(pt.x, pt.y, pt.z)
        end

        inst.Transform:SetRotation(rot)


        local index_x, index_y = interior_spawner:GetCurrentPlayerRoomIndex()
        if backdiff and not rightdiff and not leftdiff and index_x == 0 and index_y == -1 then
        	return false
        end

        local ents = TheSim:FindEntities(newpt.x, newpt.y, newpt.z, 3, {}, {}, {"wallsection", "interior_door", "predoor"})
        if #ents >= 1 then
        	for _, ent in pairs(ents) do
        		if (ent:HasTag("predoor") or ent:HasTag("interior_door")) and ent.prefab ~= name and ent.prefab ~= "prop_door" then
        			return true
        		end
        	end
        end

        if #ents < 1 and canbuild then
            return true
        end
    end
    
    return false
end

local function modify_house_door(inst)
	local data = {}

    local x,y,z = inst.Transform:GetWorldPosition()

    -- local interior_spawner = GetTheWorld.components.interiorspawner()
    local interior_spawner = TheWorld.components.interiorspawner

    local originpt = interior_spawner:GetSpawnOrigin()
    local width = interior_spawner.current_interior.width
    local depth = interior_spawner.current_interior.depth

    local dist = 2
    local backdiff =  x < (originpt.x - depth/2 + dist)
    local frontdiff = x > (originpt.x + depth/2 - dist)
    local rightdiff = z > (originpt.z + width/2 - dist)
    local leftdiff =  z < (originpt.z - width/2 + dist)

    local canbuild = true
	local dir = GetBaseAnimName(inst)
	-- data.anim = "close_"..player_interior_exit_dir_data[dir].anim
	inst.animdata.anim = "close_"..player_interior_exit_dir_data[dir].anim

    return data
end

local function MakeHouseDoor(name, build, bank)
	local function house_fn()
		local inst = common_house_door_fn()

		inst.AnimState:SetBank("player_house_doors")
		inst.AnimState:SetBuild("player_house_doors")

		--"iron_door",    "player_house_doors", "player_house_doors"

		-- Temporary hardcoding to see if this can work at all
		inst.animdata = {}
		inst.animdata.bank = "player_house_doors"--bank
		inst.animdata.build = "player_house_doors"--build
		-- inst.animdata.anim = "iron_door" .. "_open_north" --"_placer"--anim
		inst.animdata.anim = "close_north" --"_placer"--anim
			
		if not TheWorld.ismastersim then
			return inst
		end
		
		inst.OnBuilt = function()
			common_on_built(inst)
			modify_house_door(inst)
			inst.animdata.anim = inst.prefab .. "_" .. inst.animdata.anim
			inst.AnimState:PlayAnimation(inst.animdata.anim)

			local background = player_interior_exit_dir_data[inst.baseanimname].background
			if background then
				inst.AnimState:SetLayer( LAYER_WORLD_BACKGROUND )
			else
				inst.AnimState:SetLayer( LAYER_WORLD )
			end
		end

		return inst
	end
	return Prefab(name, house_fn, assets, prefabs )
end

local function InitInteriorPrefab_shadow(inst, doer, prefab_definition, interior_definition)
	--If we are spawned inside of a building, then update our door to point at our interior
	if prefab_definition.animdata then
		if prefab_definition.animdata.bank then
	    	inst.AnimState:SetBank(prefab_definition.animdata.bank)
	    	inst.door_data_bank = prefab_definition.animdata.bank
		end
	    if prefab_definition.animdata.build then
	    	inst.AnimState:SetBuild(prefab_definition.animdata.build)
	    	inst.door_data_build = prefab_definition.animdata.build
		end
		if prefab_definition.animdata.anim then
	    	inst.AnimState:PlayAnimation(prefab_definition.animdata.anim, true)
	    	inst.door_data_animstate = prefab_definition.animdata.anim
	    	-- this is for finding the right open and closed door animation.
	    	inst.baseanimname = inst.door_data_animstate
		end		
	end
end

local function shadowfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

    inst.AnimState:SetBank("player_house_doors")
    inst.AnimState:SetBuild("player_house_doors")
    inst.AnimState:PlayAnimation("wood_door_south_floor")
    inst:AddTag("NOCLICK")  -- Note for future self: Was commented out, but not sure why.. if it's not there, the shadow eats the click on the door.
    inst:AddTag("NOBLOCK")
	inst.initInteriorPrefab = InitInteriorPrefab_shadow

    inst:AddTag("SELECT_ME")

    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
    return inst
end

return MakeHouseDoor("wood_door",    "pig_ruins_door", "doorway_ruins"),
	   MakeHouseDoor("stone_door",   "pig_ruins_door", "doorway_ruins"),
	   MakeHouseDoor("organic_door", "pig_ruins_door", "doorway_ruins"),
	   MakeHouseDoor("iron_door", 	 "pig_ruins_door", "doorway_ruins"),
	   MakeHouseDoor("pillar_door",  "pig_ruins_door", "doorway_ruins"),
	   MakeHouseDoor("curtain_door", "pig_ruins_door", "doorway_ruins"),
	   MakeHouseDoor("round_door", 	 "pig_ruins_door", "doorway_ruins"),
	   MakeHouseDoor("plate_door", 	 "pig_ruins_door", "doorway_ruins"),

	   Prefab("house_door_shadow", shadowfn, assets, prefabs)