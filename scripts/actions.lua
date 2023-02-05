-----------------------------------------------------------------------------------------
local ENTERDOOR = AddAction("ENTERDOOR", "ENTERDOOR", function(act)
	if act.target:HasTag("secret_room") or act.target:HasTag("predoor") then
		return false
	end

	if act.target.components.door and not act.target.components.door.disabled then
	-- if act.target:HasTag("door") and not act.target:HasTag("door_disabled") then
		act.target.components.door:Activate(act.doer)
		return true
	elseif act.target.components.door and act.target.components.door.disabled then
	-- elseif act.target:HasTag("door") and act.target:HasTag("door_disabled") then
		return false, "LOCKED"
	end
end)
ENTERDOOR.priority = 2
ENTERDOOR.distance = 1

AddStategraphActionHandler("wilson", ActionHandler(ENTERDOOR, "dostandingaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ENTERDOOR, "dostandingaction"))

AddComponentAction("SCENE", "door", function(inst, doer, actions, right)
    if inst:HasTag("door") then
	--if inst.components.door then
        if not right then
            table.insert(actions, ACTIONS.ENTERDOOR)
        end
    end
end)
-----------------------------------------------------------------------------------------

local BUILD_ROOM = AddAction("BUILD_ROOM", "BUILD_ROOM", function(act)
	if act.invobject.components.roombuilder and act.target:HasTag("predoor") then
	-- if act.invobject:HasTag("roombuilder") and act.target:HasTag("predoor") then
		print("Detected room builder object")
		
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

		local dir = interior_spawner:GetExitDirection(act.target)
		CreateNewRoom(dir)

		act.target:AddTag("interior_door")
		act.target:RemoveTag("predoor")
		act.invobject:Remove()
		return true
	end

	return false
end)

BUILD_ROOM.priority = 1
BUILD_ROOM.distance = 1

AddStategraphActionHandler("wilson", ActionHandler(BUILD_ROOM, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(BUILD_ROOM, "doshortaction"))

AddComponentAction("USEITEM", "roombuilder", function(inst, doer, target, actions, right)
	-- print("Interior test: Roombuilder parameters dump:")
	-- print("Inst:", inst)
	-- print("Doer:", doer)
	-- print("Target:", target)
	
    --if inst:HasTag("activedoor") then
	-- if inst.invobject.components.roombuilder then
    -- if inst:HasTag("roombuilder") then
	-- if doer.invobject.components.roombuilder then
	
		if target:HasTag("predoor") then
			-- print("Room builder detected for component action?")
			table.insert(actions, ACTIONS.BUILD_ROOM)
		end
    -- end
end)
-----------------------------------------------------------------------------------------
local DEMOLISH_ROOM = AddAction("DEMOLISH_ROOM", "DEMOLISH_ROOM", function(act)
	if act.invobject.components.roomdemolisher and act.target:HasTag("house_door") and act.target:HasTag("interior_door") then
		

		local interior_spawner = TheWorld.components.interiorspawner
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
			act.doer.components.talker:Say(GetString(act.doer.prefab, "ANNOUNCE_ROOM_STUCK"))
		end

		return true
	end
end)
DEMOLISH_ROOM.priority = 1
DEMOLISH_ROOM.distance = 1

AddStategraphActionHandler("wilson", ActionHandler(DEMOLISH_ROOM, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(DEMOLISH_ROOM, "doshortaction"))
-----------------------------------------------------------------------------------------
local SHOP = AddAction("SHOP", "SHOP", function(act)
	if act.doer.components.inventory then
		print("SHOP - Doer has inventory")
		if act.doer:HasTag("player") and act.doer.components.shopper then 
			print("SHOP - Doer is a shoppable player")
			if act.doer.components.shopper:IsWatching(act.target) then 
				print("SHOP - Doer is... watching something? I dunno")
				local sell = true
				local reason = nil

				if act.target:HasTag("shopclosed") or TheWorld.state.isnight then
					reason = "closed"
					sell = false
				elseif not act.doer.components.shopper:CanPayFor(act.target) then 
					local prefab_wanted = act.target.costprefab
					if prefab_wanted == "oinc" then
						reason = "money"
					else
						reason = "goods"
					end
					sell = false
				end
				
				if sell then
					act.doer.components.shopper:PayFor(act.target)

					if act.target and act.target.shopkeeper_speech then
						act.target.shopkeeper_speech(act.target,STRINGS.CITY_PIG_SHOPKEEPER_SALE[math.random(1,#STRINGS.CITY_PIG_SHOPKEEPER_SALE)])
					end

					return true 
				else 
					if reason == "money" then
						if act.target and act.target.shopkeeper_speech then
							act.target.shopkeeper_speech(act.target,STRINGS.CITY_PIG_SHOPKEEPER_NOT_ENOUGH[math.random(1,#STRINGS.CITY_PIG_SHOPKEEPER_NOT_ENOUGH)])
						end
					elseif reason == "goods" then
						if act.target and act.target.shopkeeper_speech then
							act.target.shopkeeper_speech(act.target,STRINGS.CITY_PIG_SHOPKEEPER_DONT_HAVE[math.random(1,#STRINGS.CITY_PIG_SHOPKEEPER_DONT_HAVE)])
						end						
					elseif reason == "closed" then
						if act.target and act.target.shopkeeper_speech then
							act.target.shopkeeper_speech(act.target,STRINGS.CITY_PIG_SHOPKEEPER_CLOSING[math.random(1,#STRINGS.CITY_PIG_SHOPKEEPER_CLOSING)])
						end						
					end
					return true
				end		
			else
				act.doer.components.shopper:Take(act.target)
				-- THIS IS WHAT HAPPENS IF ISWATCHING IS FALSE
				return true 
			end 
		end
	end
end)
SHOP.priority = 1
SHOP.distance = 1

ACTIONS.SHOP.stroverridefn = function(act)
	if not act.target or not act.target.costprefab or not act.target.components.shopdispenser:GetItem() then
		return nil
	else

		local blueprint = false

		local item = act.target.components.shopdispenser:GetItem()
		local blueprintstart= string.find(item,"_blueprint")
		if blueprintstart then
			item = string.sub(item,1,blueprintstart-1)
			blueprint = true
		end

		local wantitem = STRINGS.NAMES[string.upper(item)]
		if blueprint then
			wantitem = string.format(STRINGS.BLUEPRINT_ITEM,wantitem)
		end
		if not wantitem then
			local temp = SpawnPrefab(item)
			if temp.displaynamefn then
				wantitem = temp.displaynamefn(temp)
			else
				wantitem = item
			end
			temp:Remove()
		end
		local payitem = STRINGS.NAMES[string.upper(act.target.costprefab)]
		local qty = ""
		if act.target.costprefab == "oinc" then		
			qty = act.target.cost		
			if act.target.cost > 1 then
				payitem = STRINGS.NAMES.OINC_PL
			end
		end

		if act.doer.components.shopper:IsWatching(act.target) then		
			return subfmt(STRINGS.ACTIONS.SHOP_LONG, { wantitem = wantitem, qty=qty, payitem = payitem })
		else
			return subfmt(STRINGS.ACTIONS.SHOP_TAKE, { wantitem = wantitem })
		end
	end
end 

AddStategraphActionHandler("wilson", ActionHandler(SHOP, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(SHOP, "doshortaction"))

AddComponentAction("SCENE", "shopdispenser", function(inst, doer, actions, right)
    if inst:HasTag("shop_pedestal") then
	--if inst.components.door then
        if not right then
			-- print("Door tag detected, you should be able to attempt entering it")
            table.insert(actions, ACTIONS.SHOP)
        end
    end
end)
-----------------------------------------------------------------------------------------
local WEIGHDOWN = AddAction("WEIGHDOWN", "WEIGHDOWN", function(act)
	local pos = Vector3(act.target.Transform:GetWorldPosition())
	-- if act.doer.components.inventory then	
	return act.doer.components.inventory ~= nil
		and act.doer.components.inventory:DropItem(act.invobject, false, false, pos) 
		-- return true
	-- end
end)
WEIGHDOWN.priority = 1
WEIGHDOWN.distance = 1

AddStategraphActionHandler("wilson", ActionHandler(WEIGHDOWN, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(WEIGHDOWN, "doshortaction"))

AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
    if target:HasTag("weighdownable") then
        if not right then
            table.insert(actions, ACTIONS.WEIGHDOWN)
        end
    end
end)
-----------------------------------------------------------------------------------------
local DISLODGE = AddAction("DISLODGE", "DISLODGE", function(act)
	if act.target.components.dislodgeable then
		act.target.components.dislodgeable:Dislodge(act.doer)
		-- action with inventory object already explicitly calls OnUsedAsItem
		if not act.invobject and act.doer and act.doer.components.inventory and act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
			local invobject = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if invobject.components.finiteuses then
				invobject.components.finiteuses:OnUsedAsItem(ACTIONS.DISLODGE)
			end
		end
		return true
	end
end)
DISLODGE.priority = 1
DISLODGE.distance = 1

AddStategraphActionHandler("wilson", ActionHandler(DISLODGE, "tap"))
AddStategraphActionHandler("wilson_client", ActionHandler(DISLODGE, "tap"))

AddComponentAction("EQUIPPED", "dislodger", function(inst, doer, target, actions, right)
    -- if target.components.dislodgeable then
    if target:HasTag("dislodgeable") then
        if not right then
            table.insert(actions, ACTIONS.DISLODGE)
        end
    end
end)

-- AddComponentAction("SCENE", "dislodgable", function(inst, doer, actions, right)
    -- -- if target.components.dislodgeable then
        -- if not right then
            -- table.insert(actions, ACTIONS.DISLODGE)
        -- end
    -- -- end
-- end)
-----------------------------------------------------------------------------------------
local STOCK = AddAction("STOCK", "", function(act)
	if act.target then		
		act.target.restock(act.target,true)
		act.doer.changestock = nil
		return true
	end
end)
STOCK.priority = 1
STOCK.distance = 1
-----------------------------------------------------------------------------------------
local FIX = AddAction("FIX", "", function(act)
	if act.target then
		local target = act.target
		local numworks = 1
		target.components.workable:WorkedBy(act.doer, numworks)
	--	return target:fix(act.doer)		
	end
end)
FIX.priority = 1
FIX.distance = 1
-----------------------------------------------------------------------------------------
local SPECIAL_ACTION = AddAction("SPECIAL_ACTION", "", function(act)
	if act.doer.special_action then
		act.doer.special_action(act)
		return true
	end
end)
SPECIAL_ACTION.priority = 1
SPECIAL_ACTION.distance = 1
-----------------------------------------------------------------------------------------
local SPECIAL_ACTION2 = AddAction("SPECIAL_ACTION2", "", function(act)
	if act.doer.special_action2 then
		act.doer.special_action2(act)
		return true
	end
end)
SPECIAL_ACTION2.priority = 1
SPECIAL_ACTION2.distance = 1
-----------------------------------------------------------------------------------------
local HAMARTIFACTIVATE = AddAction("HAMARTIFACTIVATE", "HAMARTIFACTIVATE", function(act)
	if act.target.components.hamlivingartifact then
		act.target.components.hamlivingartifact:Activate(act.doer)
		return true
	else
		return false
	end
end)
HAMARTIFACTIVATE.priority = 1
HAMARTIFACTIVATE.distance = 1

AddStategraphActionHandler("wilson", ActionHandler(HAMARTIFACTIVATE, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(HAMARTIFACTIVATE, "doshortaction"))

AddComponentAction("SCENE", "hamlivingartifact", function(inst, doer, actions, right)
	--if inst.components.door then
        if right then
			-- print("Door tag detected, you should be able to attempt entering it")
            table.insert(actions, ACTIONS.HAMARTIFACTIVATE)
        end
    -- end
end)

AddComponentAction("INVENTORY", "hamlivingartifact", function(inst, doer, actions, right)
	--if inst.components.door then
        if right then
			-- print("Door tag detected, you should be able to attempt entering it")
            table.insert(actions, ACTIONS.HAMARTIFACTIVATE)
        end
    -- end
end)
-----------------------------------------------------------------------------------------
local SMELTER_HARVEST = AddAction("SMELTER_HARVEST", "SMELTER_HARVEST", function(act)
	if act.target.components.melter then
		-- if act.target.components.melter.done then
			act.target.components.melter:Harvest(act.doer)
			return true
		-- end
	end
end)
SMELTER_HARVEST.priority = 1
SMELTER_HARVEST.distance = 1

AddStategraphActionHandler("wilson", ActionHandler(SMELTER_HARVEST, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(SMELTER_HARVEST, "dolongaction"))

AddComponentAction("SCENE", "melter", function(inst, doer, actions, right)
	if inst:HasTag("donecooking") then
        if not right then
			-- print("Door tag detected, you should be able to attempt entering it")
            table.insert(actions, ACTIONS.SMELTER_HARVEST)
        end
    end
end)
-----------------------------------------------------------------------------------------
local CHARGE_UP = AddAction("CHARGE_UP", "CHARGE_UP", function(act)
	act.doer:PushEvent("beginchargeup")
end)
CHARGE_UP.priority = ACTIONS.HIGH_ACTION_PRIORITY
CHARGE_UP.distance = 10
CHARGE_UP.rmb = true

AddStategraphActionHandler("wilson", ActionHandler(CHARGE_UP, "charge"))
AddStategraphActionHandler("wilson_client", ActionHandler(CHARGE_UP, "charge"))
-----------------------------------------------------------------------------------------
