local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)

local ENTERDOOR = Action({priority = 2, distance = 1})
ENTERDOOR.id = "ENTERDOOR"
ENTERDOOR.str = "Enter"
HAMENV.AddAction(ENTERDOOR)

local BUILD_ROOM = Action({priority = 1, distance = 1})
BUILD_ROOM.id = "BUILD_ROOM"
BUILD_ROOM.str = "Build"
HAMENV.AddAction(BUILD_ROOM)

local DEMOLISH_ROOM = Action({priority = 1, distance = 1})
DEMOLISH_ROOM.id = "DEMOLISH_ROOM"
DEMOLISH_ROOM.str = "Demolish"
HAMENV.AddAction(DEMOLISH_ROOM)




ENTERDOOR.fn = function(act)
	if act.target:HasTag("secret_room") or act.target:HasTag("predoor") then
		return false
	end

	--if act.target.components.door and not act.target.components.door.disabled then
	if act.target:HasTag("door") and not act.target:HasTag("door_disabled") then
		act.target.components.door:Activate(act.doer)
		return true
	--elseif act.target.components.door and act.target.components.door.disabled then
	elseif act.target:HasTag("door") and act.target:HasTag("door_disabled") then
		return false, "LOCKED"
	end
end


-- ENTERDOOR.fn = function(act)
	-- if act.target:HasTag("activedoor") then --act.target.components.door then
		-- print("Door activation action go!")
		-- --act.target:PushEvent("usedoor", (act.doer))
		-- act.target.components.door:Activate(act.doer)
		-- return true
	-- else
		-- print("Failed door check, no door activation")
		-- return false
	-- end
-- end

BUILD_ROOM.fn = function(act)
	if act.invobject.components.roombuilder and act.target:HasTag("predoor") then
	-- if act.invobject:HasTag("roombuilder") and act.target:HasTag("predoor") then
		print("Detected room builder object")
		
		-- local interior_spawner = GetInteriorSpawner()
		local interior_spawner = TheWorld.components.interiorspawner		
		local current_interior = interior_spawner.current_interior

		local function CreateNewRoom(dir)
			local name = current_interior.dungeon_name
			local ID = interior_spawner:GetNewID()
			ID = "p" .. ID -- Added the "p" so it doesn't trigger FixDoors on the InteriorSpawner

            local floortexture = "levels/textures/noise_woodfloor.tex"
            local walltexture = "levels/textures/interiors/shop_wall_woodwall.tex"
            local minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
            local colorcube = "images/colour_cubes/pigshop_interior_cc.tex"

            local addprops = {
                { name = "deco_roomglow", x_offset = 0, z_offset = 0 }, 

                { name = "deco_antiquities_cornerbeam",  x_offset = -5, z_offset =  -15/2, rotation = 90, flip=true, addtags={"playercrafted"} },
                { name = "deco_antiquities_cornerbeam",  x_offset = -5, z_offset =   15/2, rotation = 90,            addtags={"playercrafted"} },      
                { name = "deco_antiquities_cornerbeam2", x_offset = 4.7, z_offset = -15/2, rotation = 90, flip=true, addtags={"playercrafted"} },
                { name = "deco_antiquities_cornerbeam2", x_offset = 4.7, z_offset =  15/2, rotation = 90,            addtags={"playercrafted"} },  

                { name = "swinging_light_rope_1", x_offset = -2, z_offset =  0, rotation = -90,                      addtags={"playercrafted"} },
            }

            local room_exits = {}
			
            local width = 15
            local depth = 10

			room_exits[player_interior_exit_dir_data[dir].opposing_exit_dir] = {
				target_room = current_interior.unique_name,
				bank =  "player_house_doors",
				build = "player_house_doors",
				room = ID,
				prefab_name = act.target.prefab,
				house_door = true,
			}

			-- Adds the player room def to the interior_spawner so we can find the adjacent rooms
			interior_spawner:AddPlayerRoom(name, ID, current_interior.unique_name, dir)
			
			local doors_to_activate = {}
			-- Finds all the rooms surrounding the newly built room
			local surrounding_rooms = interior_spawner:GetSurroundingPlayerRooms(name, ID, player_interior_exit_dir_data[dir].op_dir)

			if next(surrounding_rooms) ~= nil then
				-- Goes through all the adjacent rooms, checks if they have a pre built door and adds them to doors_to_activate
				for direction, room_id in pairs(surrounding_rooms) do
					local found_room = interior_spawner:GetInteriorByName(room_id)

					if found_room.visited then
						for _, obj in pairs(found_room.object_list) do

							local op_dir = player_interior_exit_dir_data[direction] and player_interior_exit_dir_data[direction].op_dir
							if obj:HasTag("predoor") and obj.baseanimname and obj.baseanimname == op_dir then
								room_exits[player_interior_exit_dir_data[op_dir].opposing_exit_dir] = {
									target_room = found_room.unique_name,
									bank =  "player_house_doors",
									build = "player_house_doors",
									room = ID,
									prefab_name = obj.prefab,
									house_door = true,
								}

								doors_to_activate[obj] = found_room
							end
						end
					end
				end
			end

			-- Actually creates the room
            interior_spawner:CreateRoom("generic_interior", width, nil, depth, name, ID, addprops, room_exits, walltexture, floortexture, minimaptexture, nil, colorcube, nil, true, "inside", "HOUSE","WOOD")

            -- Activates all the doors in the adjacent rooms
            for door_to_activate, found_room in pairs(doors_to_activate) do
            	print ("################## ACTIVATING FOUND DOOR")
            	door_to_activate.ActivateSelf(door_to_activate, ID, found_room)
            end

            -- If there are already built doors in the same direction as the door being used to build, activate them
            local pt = interior_spawner:getSpawnOrigin()
            local other_doors = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, {"predoor"}, {"INTERIOR_LIMBO", "INLIMBO"})
            for _, other_door in ipairs(other_doors) do
            	if other_door ~= act.target and other_door.baseanimname and other_door.baseanimname == act.target.baseanimname then
            		print ("############### ACTIVATING DOOR")
            		other_door.ActivateSelf(other_door, ID, current_interior)
            	end
            end

			act.target.components.door:checkDisableDoor(false, "house_prop")
			
	        local door_def =
	        {
	        	my_interior_name = current_interior.unique_name,
	        	my_door_id = current_interior.unique_name .. player_interior_exit_dir_data[dir].my_door_id_dir,
	        	target_interior = ID,
	        	target_door_id = ID .. player_interior_exit_dir_data[dir].target_door_id_dir
	    	}

	        interior_spawner:AddDoor(act.target, door_def)
	        act.target.InitHouseDoor(act.target, dir)
        end

		-- local dir = GetInteriorSpawner():GetExitDirection(act.target)
		local dir = interior_spawner:GetExitDirection(act.target)
        CreateNewRoom(dir)

        act.target:AddTag("interior_door")
		act.target:RemoveTag("predoor")
		act.invobject:Remove()
		return true
	end

	return false
end

DEMOLISH_ROOM.fn = function(act)
	if act.invobject.components.roomdemolisher and act.target:HasTag("house_door") and act.target:HasTag("interior_door") then
		

		local interior_spawner = TheWorld.components.interiorspawner --GetInteriorSpawner()
		local target_interior = interior_spawner:GetInteriorByName(act.target.components.door.target_interior)
		local index_x, index_y = interior_spawner:GetPlayerRoomIndex(target_interior.dungeon_name, target_interior.unique_name)
		
		-- inst.doorcanberemoved
		-- inst.roomcanberemoved

		if act.target.doorcanberemoved and act.target.roomcanberemoved and not (index_x == 0 and index_y == 0) then
			local total_loot = {}

			if target_interior.visited then
				for _, object in pairs(target_interior.object_list) do
				 	if object.components.inventoryitem then
				 		
				 		object:ReturnToScene()
				 		object.components.inventoryitem:ClearOwner()
					    object.components.inventoryitem:WakeLivingItem()
					    object:RemoveTag("INTERIOR_LIMBO")

				 		table.insert(total_loot, object)

				 	else
					 	if object.components.container then
					 		local container_objs = object.components.container:RemoveAllItems()
					 		for i,obj in ipairs(container_objs) do
					 			table.insert(total_loot, obj)
					 		end
					 	end

					 	if object.components.lootdropper then
					 		local smash_loot = object.components.lootdropper:GenerateLoot()
					 		for i,obj in ipairs(smash_loot) do
					 			table.insert(total_loot, SpawnPrefab(obj))
					 		end
					 	end
				 	end
				end

				-- Removes the found loot from the interior so it doesn't get deleted by the next for
				for _, loot in ipairs(total_loot) do
					print ("Removing ", loot.prefab)
					interior_spawner:removeprefab(loot, target_interior.unique_name)
				end

				-- Deletes all of the interior with a reverse for
				local obj_count = #target_interior.object_list
				for i = obj_count, 1, -1 do

					local current_obj = target_interior.object_list[i]
					if current_obj and current_obj.prefab ~= "generic_wall_back" and current_obj.prefab ~= "generic_wall_side" then
						
						if current_obj:HasTag("house_door") then
							local connected_door = interior_spawner:GetDoorInst(current_obj.components.door.target_door_id)
							if connected_door and connected_door ~= act.target then
								connected_door.DeactivateSelf(connected_door)
							end
						end

						current_obj:Remove()
					end
				end
			else
				table.insert(total_loot, SpawnPrefab("oinc"))
				if act.target.components.lootdropper then
					local smash_loot = act.target.components.lootdropper:GenerateLoot()
					for i,obj in ipairs(smash_loot) do
			 			table.insert(total_loot, SpawnPrefab(obj))
			 		end
				end
			end

			for _, loot in ipairs(total_loot) do
				local pos = Vector3(act.target.Transform:GetWorldPosition())
				loot.Transform:SetPosition(pos:Get())
				if loot.components.inventoryitem then
					loot.components.inventoryitem:OnDropped(true)
				end
			end

			act.target:DeactivateSelf(act.target)
			interior_spawner:RemoveInterior(target_interior.unique_name)
			interior_spawner:RemovePlayerRoom(target_interior.dungeon_name, target_interior.unique_name)

			SpawnPrefab("collapse_small").Transform:SetPosition(act.target.Transform:GetWorldPosition())
		    if act.target.SoundEmitter then
		        act.target.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
		    end

			TheWorld:PushEvent("roomremoved")
			act.invobject:Remove()

		else
			GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_ROOM_STUCK"))
		end

		return true
	end
end

HAMENV.AddComponentAction("SCENE", "door", function(inst, doer, actions, right)
    if inst:HasTag("door") then
	--if inst.components.door then
        if not right then
			-- print("Door tag detected, you should be able to attempt entering it")
            table.insert(actions, ACTIONS.ENTERDOOR)
        end
    end
end)

HAMENV.AddComponentAction("USEITEM", "roombuilder", function(inst, doer, target, actions, right)
	-- print("Interior test: Roombuilder parameters dump:")
	-- print("Inst:", inst)
	-- print("Doer:", doer)
	-- print("Target:", target)
	
    --if inst:HasTag("activedoor") then
	-- if inst.invobject.components.roombuilder then
    -- if inst:HasTag("roombuilder") then
	-- if doer.invobject.components.roombuilder then
	
		if target:HasTag("predoor") then
			print("Room builder detected for component action?")
			table.insert(actions, ACTIONS.BUILD_ROOM)
		end
    -- end
end)