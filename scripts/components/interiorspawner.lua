local wallWidth = 7
local wallLength = 24

local function GetVerb(inst, doer)
	return STRINGS.ACTIONS.JUMPIN.ENTER
end

local InteriorSpawner = Class(function(self, inst)
    self.inst = inst

    self.interiors = {}
	
	self.loaded_interiors = {} 
	-- A step towards multiplayer compat.
	-- The idea is to store a list of currently-loaded interiors in different starting positions for each player, and move people to the same room if they try to go in one.
	self.interior_players = {}
	-- A list of all players in interiors. Format is interior_players.player.interiorID
	-- Not anymore, format is now:
	-- id:
	--		playerID = player.userID
	--		interiorID = ... the interior ID

	self.doors = {}

	self.next_interior_ID = 0

	self.getverb = GetVerb

	self.interior_spawn_origin = nil

	self.current_interior = nil

	-- true if we're considered inside an interior, which is also during transition in/out of
	self.considered_inside_interior = {}

	self.from_inst = nil		
	self.to_inst = nil	
	self.to_target = nil
	
	self.prev_player_pos_x = 0.0
	self.prev_player_pos_y = 0.0
	self.prev_player_pos_z = 0.0
	
	self.interiorEntryPosition = Vector3()

	self.dungeon_entries = {}

	-- self.homeprototyper = SpawnPrefab("home_prototyper")
	
	--self.homeprototyper.Transform:SetPosition(interior_spawn_storage_origin:Get())
	-- self.homeprototyper.Transform:SetPosition(2000,0,2000)
	
	-- for debugging the black room issue
	self.alreadyFlagged = {}
	self.was_invincible = false

	self.player_homes = {}
	
end)

local NO_INTERIOR = -1

function InteriorSpawner:ConfigureWalls(interior)
	self.walls = self.walls or self:CreateWalls()

	-- local spawnOrigin = self:GetSpawnOrigin()
	-- local x,y,z = spawnOrigin.x, spawnOrigin.y, spawnOrigin.z
	local spawnStorage = self:GetSpawnStorage(nil, interior)
	local x,y,z = spawnStorage.x, spawnStorage.y, spawnStorage.z

	local origwidth = 1
	local delta = (2 * wallWidth - 2 * origwidth) / 2

	local depth = interior.depth
	local width = interior.width
	local height = interior.height

	-- Collision
	print("Doing configuration for collision, should match with interior's actual size now")
	self:Teleport(self.walls, Vector3(x,y,z)) -- Center, maybe?
	self.walls:SetVerticles(depth, width, height)
	self.walls:SetName(interior.unique_name)
	
	self.walls:ReturnToScene()
	self.walls:RemoveTag("INTERIOR_LIMBO")

	-- stomp out the walls for pathfinding
	self:SetUpPathFindingBarriers(x,y,z,width, depth)
end

function InteriorSpawner:SetUpPathFindingBarriers(x,y,z,width, depth)
    local ground = TheWorld
	self.pathfindingBarriers = {}
    if ground then
		for r = -width/2, width/2 do
			table.insert(self.pathfindingBarriers, Vector3(x+(depth/2)+0.5, y, z+r))
			table.insert(self.pathfindingBarriers, Vector3(x-(depth/2)-0.5, y, z+r))
		end
		for r = -depth/2, depth/2 do
			table.insert(self.pathfindingBarriers, Vector3(x+r,y,z-(width / 2)-0.5))
			table.insert(self.pathfindingBarriers, Vector3(x+r,y,z+(width / 2)+0.5))
		end
	end
	for i,pt in pairs(self.pathfindingBarriers) do
		ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
		--local r = SpawnPrefab("acorn")
		--RemovePhysicsColliders(r)
		--r.Transform:SetPosition(pt.x, pt.y, pt.z)
	end
end

function InteriorSpawner:ClearPathfindingBarriers()
    local ground = TheWorld
	for i,pt in pairs(self.pathfindingBarriers) do
		ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
	end
	self.pathfindingBarriers = {}
end

local EAST  = { x =  1, y =  0, label = "east" }
local WEST  = { x = -1, y =  0, label = "west" }
local NORTH = { x =  0, y =  1, label = "north" }
local SOUTH = { x =  0, y = -1, label = "south" }

local dir_str =
{
	"north",
	"east",
	"south",
	"west",
}

local op_dir_str =
{
	["north"] = "south",
	["east"]  = "west",
	["south"] = "north",
	["west"]  = "east",
}

local dir =
{
    EAST,
    WEST,
    NORTH,
    SOUTH,
}

local dir_opposite =
{
    WEST,
    EAST,
    SOUTH,
    NORTH,
}

function InteriorSpawner:GetNewID()
	self.next_interior_ID = self.next_interior_ID + 1
	print("Interior Spawner - Generated new ID as ", self.next_interior_ID)
	return self.next_interior_ID
end

function InteriorSpawner:GetDir()
	return dir
end

function InteriorSpawner:GetNorth()
	return NORTH
end
function InteriorSpawner:GetSouth()
	return SOUTH
end
function InteriorSpawner:GetWest()
	return WEST
end
function InteriorSpawner:GetEast()
	return EAST
end

function InteriorSpawner:GetDirOpposite()
	return dir_opposite
end

function InteriorSpawner:GetOppositeFromDirection(direction)
	if direction == NORTH then
		return self:GetSouth()
	elseif direction == EAST then
		return self:GetWest()
	elseif direction == SOUTH then
		return self:GetNorth()
	else
		return self:GetEast()
	end
end

function InteriorSpawner:GetInteriorsByDungeonName(dungeonname)
	if dungeonname == nil then
		return nil
	else
		local tempinteriors = {}
		for i,interior in pairs(self.interiors)do
			if interior.dungeon_name == dungeonname then
				table.insert(tempinteriors,interior)
			end
		end
		return tempinteriors
	end
end

function InteriorSpawner:GetInteriorsByDungeonNameStart(dungeonnameStart)
	if dungeonnameStart == nil then
		return nil
	else
		local tempinteriors = {}
		local len = #dungeonnameStart
		for i,interior in pairs(self.interiors)do
			if string.sub(interior.dungeon_name, 1, len) == dungeonnameStart then
				table.insert(tempinteriors,interior)
			end
		end
		return tempinteriors
	end
end

function InteriorSpawner:GetInteriorByName(name)
	if name == nil then
		return nil
	else
		local interior = self.interiors[name]
		if interior == nil then
			print("!!ERROR: Unable To Find Interior Named:"..name)
		end
		
		return interior
	end
end

function InteriorSpawner:GetSpawnOrigin()
	print("DS - Getting spawn origin...")
	return Vector3(2000,0,2000) -- Because I need testing
end

function InteriorSpawner:GetSpawnStorage(interiorID, forcedOffset)
	-- local pt = nil
	-- if not self.interior_spawn_storage_origin then
		-- for k, v in pairs(Ents) do
			-- if v:HasTag("interior_spawn_storage") and not v.fixedInteriorLocation then
				-- v.fixedInteriorLocation = true
				-- self:FixupSpawnStorage(v:GetPosition(), interior_spawn_storage_origin)
			-- end
		-- end
		-- self.interior_spawn_storage_origin = Vector3(interior_spawn_storage_origin:Get())
		-- --InteriorManager:SetDormantCenterPos2d( self.interior_spawn_storage_origin.x, self.interior_spawn_storage_origin.z )
	-- end	
	--return Vector3(2000,0,2000)

	--Vector3(self.interior_spawn_storage_origin:Get())
	local pt = nil
	local x = 2000
	local y = 0
	local z = 0
	--local 
	
	if type(forcedOffset) == "table" then -- We've been sent an interior table instead, try to convert to a storage offset
		print("Forced offset was table, try to convert to storage coordinates")
		if forcedOffset.unique_name then -- It has a name, meaning it's a valid interior type
			print("Table has unique name of ", forcedOffset.unique_name, ", get loaded index...")
			local index = self:GetLoadedInteriorIndex(forcedOffset.unique_name)
			if self.loaded_interiors[index].storage_offset then
				print("Found interior at index ", index, " of loaded interiors, change forcedOffset")
				forcedOffset = self.loaded_interiors[index].storage_offset
				print("Forced offset updated to ", forcedOffset)
				print("Also dump both that interior and the full loaded_interiors list, for safety:")
				dumptable(self.loaded_interiors[index],1, 1, nil, 0)
				print("The full 'loaded_interiors' list, now:")
				dumptable(self.loaded_interiors,1, 1, nil, 0)
				
			end
		end
	end
	
	print("Interior ID: ", interiorID, " Forced Offset: ", forcedOffset)
	if interiorID or forcedOffset then
		-- print("DS - GetSpawnOrigin got an Interior ID, find...")
		print("DS - GetSpawnStorage got an Interior ID, find...") -- Why did this say origin? Did I swap the functions at some point or something?
		local combinedValue = 0
		if interiorID then
			if self:IsInteriorLoaded(interiorID) then
				local interiorIndex = self:GetLoadedInteriorIndex(interiorID)
				if interiorIndex then
					combinedValue = combinedValue + interiorIndex
				end
			end
		end
		if forcedOffset then
			combinedValue = combinedValue + forcedOffset
		end
		-- if self:IsInteriorLoaded(interiorID) or forcedOffset then
			-- local interiorIndex = self:GetLoadedInteriorIndex(interiorID) or forcedOffset
			-- if interiorIndex then
				-- if forcedOffset then
					-- interiorIndex = interiorIndex + forcedOffset
				-- end
			-- else
				-- interiorIndex = forcedOffset
			-- end
		if combinedValue then
			-- if interiorIndex then -- For when more than one interior is loaded, get the position of this one's origin
				-- interiorIndex = interiorIndex - 1
				print("Interior Index before math:", combinedValue)
				-- combinedValue = math.max(combinedValue - 1, 0)
				combinedValue = math.max(combinedValue, 0)
				print("Interior Index AFTER max math stuff:", combinedValue)
				local zOffset = (combinedValue * 100) % 1000 -- To give 100 'units' of space between interior origins, and only let them go out to 1000
				print("zOffset:",zOffset)
				local xOffset = (math.floor (combinedValue / 10)) * 100 -- Every 10 interior IDs, move up 100 units. Should give us somewhere between 100 and ~10,000 concurrently-loaded interior IDs to work with
				print("xOffset:",xOffset)
				x = x + xOffset
				z = z + zOffset
				print("DS - Got interior spawn offset. X = ", x, ", Z = ", z)
			-- else
				-- print("DS - ERROR: Interior ID ", interiorID, " was detected as loaded, but its ID couldn't be found in the loaded list!")
				-- print("Dumping list...")
				-- dumptable(destination,1, 1, nil, 0)
			-- end
		else
			print("Combined Value of interiorIndex and forcedOffset was:",combinedValue)
		end
	else
		print("DS - GetSpawnOrigin got call without an interior ID, will return default position")
	end
	if not self.interior_spawn_origin then
		--self.interior_spawn_origin = Vector3(interior_spawn_origin:Get())
		self.interior_spawn_origin = Vector3(1000,0,0)
		--InteriorManager:SetCurrentCenterPos2d( self.interior_spawn_origin.x, self.interior_spawn_origin.z )
		for k, v in pairs(Ents) do
			if v:HasTag("interior_spawn_origin") and not v.fixedInteriorLocation then
				v.fixedInteriorLocation = true
				--self:FixupSpawnOrigin(v:GetPosition(),  interior_spawn_origin)
			end
		end		
		--self.inst:DoTaskInTime(2, function() self:CleanUpOldStorageLocation() end)
	end	
	--return Vector3(self.interior_spawn_origin:Get())
	--return Vector3(2000,0,0)
	print("Returning storage coordinates as X", x, ", Y", y, ", Z", z)
	-- return Vector3(1000,0,100)
	return Vector3(x,y,z)
end

function InteriorSpawner:RefreshDoorsNotInLimbo()
	print("Refreshing doors...")
	local pt = self:GetSpawnOrigin()

	--collect all the things in the "interior area" minus the interior_spawn_origin and the player
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO"})
--		dumptable(ents,1,1,1)
	local south_door = nil
	local shadow = nil
	print(#ents)
	for i = #ents, 1, -1 do
		if ents[i] then				
			print(i)
			
			if ents[i]:HasTag("door_south") then
				south_door = ents[i]
			end

			if ents[i].prefab == "prop_door_shadow" then
				shadow = ents[i]
			end
		end
	end

	if south_door and shadow then
		south_door.shadow = shadow
	end

	for i = #ents, 1, -1 do
		if ents[i] then
			if ents[i].components.door then
				ents[i].components.door:updateDoorVis()
			end
		end
	end

	return ents
	
end

function InteriorSpawner:SetPropToInteriorLimbo(prop,interior,ignoredisplacement)
	print("Removing prop from scene and adding to interior list...")
	if not prop.persists then
		prop:Remove()
	else
		if interior then
			table.insert(interior.object_list, prop)
		end
		prop:AddTag("INTERIOR_LIMBO")
		prop.interior = interior.unique_name

		if prop.components.playerprox and prop.components.playerprox.onfar then 
			prop.components.playerprox.onfar(prop)			
		end

	    if prop.SoundEmitter then
	        prop.SoundEmitter:OverrideVolumeMultiplier(0)
	    end
	    
		if prop.Physics and not prop.Physics:IsActive() then
			prop.dissablephysics = true			
		end
		if prop.removefrominteriorscene then
			prop.removefrominteriorscene(prop)
		end
		prop:RemoveFromScene(true)
	end
end

function InteriorSpawner:MovePropToInteriorStorage(prop,interior,ignoredisplacement,interiorOffset)
	if prop:IsValid() then
		local pt1 = self:GetSpawnOrigin()		
		print("DS - MovePropToInteriorStorage - Attempting to add the index offset")
		-- local index = self:GetLoadedInteriorIndex(interior.unique_name)
		local index = interior.storage_offset
		
		print("Index = ",index)
		
		-- Never mind about the 'changed it' thing, apparently this is what was in Hamlet. I probably changed it at some point and then changed it back without realizing that's what I did.
		print("Changed it out for the stored storage offset, which is ", index)
		
		-- local pt2 = self:GetSpawnStorage(index)	
		-- local pt2 = self:GetSpawnStorage(nil, index)	
		local pt2 = self:GetSpawnStorage(nil, interiorOffset)	
		-- local ptdebug = self:GetSpawnStorage(nil, interior)	-- Feeding it the interior to see if the automated detection can handle it
		-- It couldn't, because this was the actual interior ref and I'd need to do a lot more in there to automatically detect it
		local ptdebug = self:GetSpawnStorage(nil, interiorOffset) -- Instead, I'm just passing the offset straight from the unload function
		print("ptdebug = ",ptdebug)
		-- local pt2 = self:GetSpawnStorage(index, nil)	
		print(" DS - MovePropToInteriorStorage - PT2 = ", pt2)
		
		local pt3 = self:GetSpawnStorage(0, nil)
		print("PT3 = ",pt3)
		

		if pt2 and not prop.parent and not ignoredisplacement then			
			local diffx = pt2.x - pt1.x 
			local diffz = pt2.z - pt1.z
			-- local offsetCancelX = pt3.x - pt2.x
			-- local offsetCancelZ = pt3.z - pt2.z
			local offsetCancelX = pt3.x - pt2.x
			local offsetCancelZ = pt3.z - pt2.z
			
			print("Complicated position stuff, gotta do it right. Need to cancel the storage offset from the loaded interior:")
			print("DiffX = ", diffx)
			print("DiffZ = ", diffz)
			print("OffsetCancelX = ", offsetCancelX)
			print("OffsetCancelZ = ", offsetCancelZ)

			local proppt = Vector3(prop.Transform:GetWorldPosition())
			print("Prop original position: ", proppt)
			prop.Transform:SetPosition(proppt.x + diffx, proppt.y, proppt.z +diffz)
		end
	end
end

function InteriorSpawner:PutPropIntoInteriorLimbo(prop,interior,ignoredisplacement)
	self:SetPropToInteriorLimbo(prop, interior, ignoredisplacement)
	self:MovePropToInteriorStorage(prop, interior, ignoredisplacement)
end

function InteriorSpawner:GetCurrentInteriorEntities(doer, storageOffset)
	-- local index = self:GetLoadedInteriorIndex(interiorID) -- unused, apparently
	-- local pt = self:GetSpawnOrigin(interiorID)
	local pt = self:GetSpawnStorage(nil, storageOffset) --interiorID)

	-- collect all the things in the "interior area" minus the interior_spawn_origin and the player
	print("GetCurrentInteriorEntities - pt = X", pt.x, "Y", pt.y, "Z", pt.z)

	-- Multiplying Z by -1 because, for some reason, we end up at negative coordinates in the main interior, and I have no idea why yet. I just want to see if the theory is sound.
	-- local ents = TheSim:FindEntities(pt.x, pt.y, (pt.z * -1), 20, nil, {"INTERIOR_LIMBO","interior_spawn_storage"})
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 20, nil, {"INTERIOR_LIMBO","interior_spawn_storage"})
	assert(ents ~= nil)
	print("Got some sort of list of entities, I think. Take a dump:")
	dumptable(ents, 1, 1, nil, 0)
	assert(#ents > 0)

	--local deleteents = {}
	local prev_ents = ents
	for i = #ents, 1, -1 do
		local following = self:CheckIsFollower(ents[i], doer)
		if not ents[i] then
			print("entry", i, "was null for some reason?!?")
		end

		if following or ents[i]:HasTag("interior_spawn_origin") or (ents[i] == doer) or ents[i]:IsInLimbo() or ents[i]:HasTag("INTERIOR_LIMBO_IMMUNE") then
			table.remove(ents, i)		
		end		
	end

	return ents
end

function InteriorSpawner:UnloadInterior(doer, interiorID)
	print("UnloadInterior - Start")
	self:SanityCheck("Pre UnloadInterior")
	local doerID = doer.userid
	print("UnloadInterior - User ID is :", doerID)
	print("UnloadInterior - interiorID is:", interiorID)
	for k, v in ipairs(self.interior_players) do
		if v.playerID == doerID then
			print("UnloadInterior - detected playerID in list")
		end
	end
	-- if self.current_interior then
	
	print("DS - THE PROBLEM SHOULD BE AROUND HERE")
	local loadedInteriorIndex = self:GetLoadedInteriorIndex(interiorID)
	print("Interior index of supposedly-loaded interior ", interiorID, " is ", loadedInteriorIndex)
	if loadedInteriorIndex then
		-- print("Dumping loaded interior index...")
		local interior = self.loaded_interiors[loadedInteriorIndex].interior_ref
		local interiorOffset = self.loaded_interiors[loadedInteriorIndex].storage_offset
		-- print("Unload interior "..self.current_interior.unique_name.."("..self.current_interior.dungeon_name..")")
		print("Unload interior "..interior.unique_name.."("..interior.dungeon_name..")")
		-- THIS UNLOADS THE CURRENT INTERIOR IN THE WORLD
		-- local interior = self.current_interior
		print("UnloadInterior - Got an interior off the 'loaded interior' list. Dumping...")
		dumptable(interior, 1, 1, nil, 0)
		print("===============")
		print("Compared to self.current_interior:")
		dumptable(self.current_interior, 1, 1, nil, 0)

		local ents = self:GetCurrentInteriorEntities(doer, interiorOffset) -- Doer added to propogate the interacting player through

		-- whipe the rooms object list, then fill it with all the stuff found at this place, 
		-- then remove them from the scene
		interior.object_list = {}
		-- this is done in two passes, since entities may rely on the sleep event and query other objects' locations
		-- pass one - put everyone to sleep
		for k, v in ipairs(ents) do
			if v.prefab == "antman" then
				local target = v.components.combat.target
				if target and IsCompleteDisguise(target) then
					v.combatTargetWasDisguisedOnExit = true
				end
			end
			self:SetPropToInteriorLimbo(v, interior)
		end
		-- pass two, teleport everyone
		for k, v in ipairs(ents) do
			self:MovePropToInteriorStorage(v, interior, false, interiorOffset)
		end

		-- self:ConsiderPlayerNotInside(self.current_interior.unique_name)
		self.current_interior = nil
		print("DS - SHOULD be removing the interior, now that unload is finished. Dump to make sure...")
		print("Prior-to-removal dump:")
		dumptable(self.loaded_interiors, 1, 1, nil, 0)
		table.remove(self.loaded_interiors, loadedInteriorIndex)
		print("Post-removal dump:")
		dumptable(self.loaded_interiors, 1, 1, nil, 0)
		self:ClearPathfindingBarriers()
	else		
		print("COMING FROM OUTSIDE, NO INTERIOR TO UNLOAD")
	end
	self:SanityCheck("Post UnLoadInterior")
end

function InteriorSpawner:ReturnItemToScene(entity, doors_in_limbo)
	entity:ReturnToScene()
	entity.interior = nil
	entity:RemoveTag("INTERIOR_LIMBO")

    if entity.SoundEmitter then
        entity.SoundEmitter:OverrideVolumeMultiplier(1)
    end

	if entity.dissablephysics then
		entity.dissablephysics = nil
		entity.Physics:SetActive(false)
	end

	-- I am really not pleased with this function. TODO: Use callbacks to entities/components for this
	if entity.prefab == "antman" then
		if IsCompleteDisguise(GetPlayer()) and not entity.combatTargetWasDisguisedOnExit then
			entity.components.combat.target = nil
		end
		entity.combatTargetWasDisguisedOnExit = false
	end

	if entity.Light and entity.components.machine and not entity.components.machine.ison then
    	entity.Light:Enable(false)
	end	    

	if entity:HasTag("interior_door") and doors_in_limbo then
		table.insert(doors_in_limbo, entity)
	end
	if entity.returntointeriorscene then
		entity.returntointeriorscene(entity)
	end
	if not entity.persists then
		entity:Remove()
	end			
end

function InteriorSpawner:Teleport(obj, destination, dontRotate)
	-- at this point destination can be a prefab or just a pt. 
	local pt = nil
	if destination.prefab then
		pt = destination:GetPosition()
	else
		pt = destination
	end

	if not obj:IsValid() then return end


	if obj.Physics then
		if obj.Transform then 
			local displace = Vector3(0,0,0)
			if destination.prefab and destination.components.door and destination.components.door.outside then
				local down = TheCamera:GetDownVec()	
				local angle = math.atan2(down.z, down.x)
				obj.Transform:SetRotation(angle)

			elseif destination.prefab and destination.components.door and destination.components.door.angle then
				obj.Transform:SetRotation(destination.components.door.angle)
				print("destination.components.door.angle",destination.components.door.angle)
				--displace.x = math.cos(
				local angle = (destination.components.door.angle * 2 * PI) / 360
				local magnitude = 1
				local dx = math.cos(angle) * magnitude
				local dy = math.sin(angle) * magnitude
				print("dx,dy",dx,dy)
				displace.x = dx
				displace.z = -dy
			else
				if not dontRotate then
					obj.Transform:SetRotation(180)	
				end
			end			
			obj.Physics:Teleport(pt.x + displace.x, pt.y + displace.y, pt.z + displace.z)
		end 
	elseif obj.Transform then
		obj.Transform:SetPosition(pt.x, pt.y, pt.z)
	end
end


function InteriorSpawner:FadeInFinished(was_invincible, doer)
	-- Last step in transition
	local player = doer--GetPlayer()
	if TheWorld.ismastersim then
		player.components.health:SetInvincible(was_invincible)
	
		player.components.playercontroller:Enable(true)
		--doer.sg:GoToState(doer.sg.statemem.teleportarrivestate) -- Trying to fix some weirdness that happens after teleporting
	end
	TheWorld:PushEvent("enterroom")
end	

local function GetTileType(pt)
	local ground = TheWorld
	local tile
	if ground and ground.Map then
		tile = ground.Map:GetTileAtPoint(pt:Get())
	end
	local groundstring = "unknown"
	for i,v in pairs(GROUND) do
		if tile == v then
			groundstring = i
		end
	end
	return groundstring
end

function InteriorSpawner:GetDoor(door_id)
	return self.doors[door_id]
end

function InteriorSpawner:ApplyInteriorCamera(player, destination, intOffset)
	-- Gonna need some net stuff to make this work per-player, I think
	-- local pt = self:GetSpawnOrigin()
	
	-- local pt = self:GetSpawnStorage(nil, destination)
	local pt = self:GetSpawnStorage(nil, intOffset)
	self:ApplyInteriorCameraWithPosition(player, destination, pt)
end

function InteriorSpawner:ApplyInteriorCameraWithPosition(player, destination, pt)
	local cameraoffset = -2.5 		--10x15
	local zoom = 23
		
	if destination.cameraoffset and destination.zoom then
		cameraoffset = destination.cameraoffset
		zoom = destination.zoom
	elseif destination.depth == 12 then    --12x18
		cameraoffset = -2
		zoom = 25
	elseif destination.depth == 16 then --16x24
		cameraoffset = -1.5
		zoom = 30
	elseif destination.depth == 18 then --18x26
		cameraoffset = -2 -- -1
		zoom = 35
	end
	
	-- local coords = Vector3(pt.x+cameraoffset, 0, pt.z)
	
	print("DS - Getting interior position for client")
	local playerint = self:GetPlayerInterior(player)
	print("PlayerInt = ",playerint)
	
	-- local pt1 = self:GetSpawnStorage((playerint), nil)
	-- print("pt1 = ", pt1)
	print("pt = ", pt)
	local pt2 = self:GetSpawnOrigin()
	print("pt2 = ",pt2)
	local diffx = pt2.x - pt.x
	print("diffx = ",diffx)
	-- local diffz = pt2.z - (pt.z *-1)
	local diffz = pt2.z - pt.z
	-- local diffz = pt2.z - ((math.abs (pt.z)) * -1) -- Trying some stinky hacks to make the camera reliable
	print("diffz = ",diffz)
	
	-- local camx = pt.x+cameraoffset
	-- local camz = pt.z
	
	local camx = pt2.x+diffx+cameraoffset
	local camz = pt2.z-diffz
	print("CamX = ",camx," Cam Z = ",camz)
	
	local walltexture = destination.walltexture
	local floortexture = destination.floortexture
	
	if player.components.interiorplayer then
		print("DS - NETWORK - Detected classified, set netvars")
		local plint = player.components.interiorplayer
		plint.camx = camx
		plint.camz = camz
		plint.camzoom = zoom
		plint.camoffset = cameraoffset
		
		plint.interiorwidth = destination.width
		plint.interiordepth = destination.depth
		plint.interiorheight = destination.height
		plint.walltexture = walltexture
		plint.floortexture = floortexture
		plint.groundsound = destination.groundsound

		plint.roomid = destination.unique_name

		plint.interiormode = true
		plint:UpdateCamera()
	else
		print("DS - NETWORK - Player classified component missing?")
	end
		
	-- TheCamera.interior_currentpos_original = Vector3(pt.x+cameraoffset, 0, pt.z)
	-- TheCamera.interior_currentpos = Vector3(pt.x+cameraoffset, 0, pt.z)

	-- TheCamera.interior_distance = zoom
end

function InteriorSpawner:FadeOutFinished(dont_fadein, doer, target, to_target, interiorID)
	-- THIS ASSUMES IT IS THE PLAYER WHO MOVED
	local player = doer --GetPlayer()

	local x, y, z = player.Transform:GetWorldPosition()
	self.prev_player_pos_x = x
	self.prev_player_pos_y = y
	self.prev_player_pos_z = z

	-- Now that we are faded to black, perform transition
	--TheFrontEnd:SetFadeLevel(1)
	--current_inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door") 
	
	local wasinterior = TheCamera.interior
	
	local destinationID = nil
	if target then
		destinationID = target.components.door.target_interior
		print("Print new destination ID gotten inside FadeOutFinished: ", destinationID)
	end

	--if the door has an interior name, then we are going to a room, otherwise we are going out
	-- if self.to_interior then -- This seems to be relating to first-time entry? Not moving between rooms in the same interior?
	if destinationID then
		print("DS - Got Destination ID in FadeOutFinished: ", destinationID)
		-- print("DS - EXPERIMENT - dumping destinationID...")
		-- dumptable(destinationID, 1, 1, nil, 0)
		print("DS - EXPERIMENT - testing data type of destinationID:", type(destinationID))
		-- TheCamera = self.interiorCamera		
		
		-- player.TheCamera = self.interiorCamera -- Don't need this anymore, it's all done client-side via netvars
		
	--	TheCamera:SetTarget( self.interior_spawn_origin )
		-- self:AddPlayerToInteriorList(player, destinationID)
	else		
		print("DS - Didn't get Destination ID, going to exterior?")
		-- self:RemovePlayerFromInteriorList(player)
		if player.components.interiorplayer then
			print("DS - NETWORK - Detected classified, set netvars")
			-- player.player_classified.net_intcamera:set(false)
			player.components.interiorplayer.interiormode = false
		else
			print ("DS - WARNING: Player didn't have classified?!?!")
		end
		-- player.TheCamera = self.exteriorCamera -- Unneeded now, and only ever worked in single-shard for the host
	end
	
	local camerainterior = TheCamera.interior

	local direction = nil
	if wasinterior and not camerainterior then		
		direction = "out"		
		-- if going outside, blank the interior color cube setting.
		--TheWorld.components.colourcubemanager:SetInteriorColourCube(nil)
		player.replica.interiorplayer:RemoveColorCube() -- This line might crash the game, but I think it can't be called because of the above 'local camerainterior' thing? Maybe? No idea, because this function doesn't seem to exist in the interiorplayer component. Or, is this even for the component?
		-- player.components.playervision:SetCustomCCTable(nil)
	end
	if not wasinterior and camerainterior then
		-- If the user is the player, then the perspective of things will move inside
		direction = "in"		

		local x, y, z = player.Transform:GetWorldPosition()
		-- if there happens to be a door into this dungeon then use that instead
		self:SetInteriorEntryPosition(doer, x,y,z)
	end

	local from_interior = self.current_interior

	local targetInteriorName = target.components.door.target_interior
	-- local destination = self:GetInteriorByName(self.to_interior) 
	local destination = self:GetInteriorByName(targetInteriorName)  --targetInteriorID
	print("DESTINATION TEST - 'destination' value is:", destination, ". It's okay if this is nil")
	print("Dumping destination table...")
	dumptable(destination,1, 1, nil, 0)
	
	print("Interior table is ", self.interiors)
	print("Dumping interior table...")
	dumptable(self.interiors,1, 1, nil, 0)
	
	-- if IsInteriorPlayerLoaded(
	-- local interiorID = GetLoadedInteriorIndex(
	local previousInterior = self:GetPlayerInterior(player)
	-- print("Saved previous interior as ", previousInterior)
	print("DS - TEST - just got previousInterior as ", previousInterior, " of player with ID ", player.userid)
	-- local playerIndex = GetInteriorPlayerIndex(player)
	-- local playerdata = self.interior_players[playerIndex]
	-- local playerIn
	if destination then
		print("Detected destination, updating player interior to ", targetInteriorName)
		if self:IsPlayerInInterior(player) then
			self:UpdatePlayerInterior(player, targetInteriorName)
		else
			self:AddPlayerToInteriorList(player, destinationID)
		end
	else -- Either update the player's interior, or remove them from the interior list altogether
		print("Detected no destination, removing player from interior list...")
		self:RemovePlayerFromInteriorList(player)
	end
	
	if self:IsInteriorPlayerLoaded(previousInterior) then
		print("The interior to unload was detected as having another player loading it, don't unload")
		print("Meaning, the interior player list had a player entry with a value equal to the interior")
	else
		print("Disabled some checks around here, to hopefully be more logically in-line with what should happen.")
		print("Namely, that the interior unloads if it's no longer in any player's entry in the interior player list")
		-- if previousInterior then
			print("Detected previous interior is no longer loaded by a player, check if it was loaded at all...")
			if self:IsInteriorLoaded(previousInterior) then
				print("Previous interior was loaded, and shouldn't have a player inside, unload")
				self:UnloadInterior(player, previousInterior)
			
		else
			print("Previous interior wasn't loaded, and was ", previousInterior, "don't try to unload anything")
			print("I believe this is where the saving problem lies. Dumping loaded interior list...")
			dumptable(self.loaded_interiors,1, 1, nil, 0)
		end
	end

	--TheWorld.components.ambientsoundmixer:SetReverbPreset("default")
	
	if destination then -- It seems that, if it's nil, then you're going outside

		if destination.reverb then
			--TheWorld.components.ambientsoundmixer:SetReverbPreset(destination.reverb)			
		end

		-- set the interior color cube
		--TheWorld.components.colourcubemanager:SetInteriorColourCube( destination.cc )
		-- player.interiorplayer:ApplyColorCube(destination.cc)
		-- player.components.playervision:SetCustomCCTable(destination.cc)
		
		local intOffset = 0
		
		if not self:IsInteriorLoaded(destination.unique_name) then
			print("Interior isn't loaded already, load it")
			print("POSSIBLY CRITICAL ERROR: Dumping 'destination' that we're giving LoadInterior:")
			dumptable(destination,1, 1, nil, 0)
			intOffset = self:LoadInterior(doer, destination) -- Added the return to make camera stuff easier
		else
			print("Interior was already loaded. This is where you'd move the player to another player's interior bubble")
			
		end
		
		
		print ("DS - NETWORK TESTS - About to send a room update thing.")
		-- player.player_classified

		-- Configure The Camera	
		local liveOffset = self:GetLiveInteriorOffset(targetInteriorName)
		self:ApplyInteriorCamera(player, destination, liveOffset)
		-- self:ApplyInteriorCamera(player, destination, intOffset)
	else
		print("FadeOutFinished - Player SHOULD be going outside, so remove them from the interior list")
		-- self:RemovePlayerFromInteriorList(player) -- Removed because it's done higher up, now
		--TheWorld.Map:SetInterior( NO_INTERIOR )		
	end

    if direction == "in" then
		local x, y, z = player.Transform:GetWorldPosition()
		self:SetInteriorEntryPosition(doer, x,y,z)
	end


	local to_target_position
	if not to_target and self.from_inst.components.door then
		-- by now the door we want to spawn at should be created and/or placed.	
		to_target = self.doors[self.from_inst.components.door.target_door_id].inst
		if direction == "out" then
			local radius = 1.75
			if to_target and to_target:IsValid() then
				if to_target and to_target.Physics then
					radius = to_target.Physics:GetRadius() + player.Physics:GetRadius()
				end
				-- make sure this is a walkable spot
				local pt = to_target:GetPosition()

				local cameraAngle = TheCamera:GetHeadingTarget()
				local angle = cameraAngle * 2 * PI / 360
				local offset = Map:FindValidExitPoint(pt,-angle,radius,8, 0.75)
				if offset then
					to_target = pt + offset
				end
			else
				local cameraAngle = TheCamera:GetHeadingTarget()
				local angle = cameraAngle * 2 * PI / 360
				local pt = Vector3(self:GetInteriorEntryPosition(from_interior))
				to_target = pt
				local offset = Map:FindValidExitPoint(pt,-angle,radius,8, 0.75)
				if offset then
					to_target = pt + offset
				end
			end
		end
	end


	self:ExecuteTeleport(player, to_target, direction)
	-- Log some info for debugging purposes
	if destination then
		local pt1 = self:GetSpawnOrigin()
		local pt2 = self:GetSpawnStorage()
		print("SpawnOrigin:",pt1,GetTileType(pt1))
		print("SpawnStorage:",pt2,GetTileType(pt2))
		print("SpawnDelta:",pt2-pt1)
		local ppt = player:GetPosition() --GetPlayer():GetPosition()
		print("Player at ",ppt, GetTileType(ppt))
	end

	--GetPlayer().components.locomotor:UpdateUnderLeafCanopy() 

	if direction =="out" then
		TheWorld:PushEvent("exitinterior", {to_target = self.to_target})
	elseif direction == "in" then
		TheWorld:PushEvent("enterinterior", {to_target = self.to_target})
	end

	--TheWorld:PushEvent("onchangecanopyzone", {instant=true})
	--local ColourCubeManager = TheWorld.components.colourcubemanager
	--ColourCubeManager:StartBlend(0)

	if player:HasTag("wanted_by_guards") then
		player:RemoveTag("wanted_by_guards")
		local x, y, z = player.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 35, {"guard"})
		if #ents> 0 then
			for i, guard in ipairs(ents)do
				guard:PushEvent("attacked", {attacker = player, damage = 0, weapon = nil})
			end
		end
	end
	if self.from_inst and self.from_inst.components.door then
		TheWorld:PushEvent("doorused", {door = self.to_target, from_door = self.from_inst})
	end

	if self.from_inst and self.from_inst:HasTag("ruins_entrance") and not self.to_interior then
		player:PushEvent("exitedruins")
	end

	if to_target.prefab then

		if to_target:HasTag("ruins_entrance") then
			player:PushEvent("enteredruins")
			-- unlock all doors
			self:UnlockAllDoors(to_target)
		end

		if to_target:HasTag("shop_entrance") then
			player:PushEvent("enteredshop")
		end	

		if to_target:HasTag("anthill_inside") then
			player:PushEvent("entered_anthill")
		end

		if to_target:HasTag("anthill_outside") then
			player:PushEvent("exited_anthill")
		end
	end

	if player:HasTag("player") then
		--TheCamera:SetTarget(GetPlayer())
		--TheCamera:Snap()
		if TheWorld.ismastersim then
			player:SnapCamera() -- Why does this not work? It should, all other instances of it in the game do
			-- omigosh it was the client thing somehow! I think?
		end
	end

	TheWorld:PushEvent("endinteriorcam")

	self.from_inst = nil

	self.to_target = nil
	--if self.HUDon == true then
	--	GetPlayer().HUD:Show()
	--	self.HUDon = nil
	--end
	
	if TheWorld.ismastersim then
		if doer:IsHUDVisible() == false then
			-- doer:ShowHUD(true)
		end
	end
		
	

	if dont_fadein then
		self:FadeInFinished(self.was_invincible)
	else
		--TheFrontEnd:Fade(true, 1, function() self:FadeInFinished(self.was_invincible, doer) end)
		if TheWorld.ismastersim then
			doer:ScreenFade(true, 0.5, false) -- Temporarily disabled to test boat problems
		end
		self.inst:DoTaskInTime(0.5, function() self:FadeInFinished(self.was_invincible, doer) end)
	end
	TheWorld.doorfreeze = nil
end

function InteriorSpawner:PushDirectionEvent(target, direction)
	if target.UpdateIsInInterior then -- DS - Adding a check, because... maybe it's needed? I don't know
		target:UpdateIsInInterior()
	end
end

function InteriorSpawner:CheckIsFollower(inst, doer)
	local isfollower = false
	-- CURRENT ASSUMPTION IS THAT ONLY THE PLAYER USES DOORS!!!!
	local player = doer--GetPlayer()
	
	if not player then
		print("DS - WARNING: CheckIsFollower didn't have a player! Returning false to prevent a crash, at least temporarily")
		return false
	end

	local eyebone = nil

	for follower, v in pairs(player.components.leader.followers) do					
		if follower == inst then
			isfollower = true
		end
	end

	if player.components.inventory then
		for k, item in pairs(player.components.inventory.itemslots) do

			if item.components.leader then
				if item:HasTag("chester_eyebone") then
					eyebone = item
				end
				for follower, v in pairs(item.components.leader.followers) do
					if follower == inst then
						isfollower = true
					end
				end
			end
		end
		-- special special case, look inside equipped containers
		for k, equipped in pairs(player.components.inventory.equipslots) do
			if equipped and equipped.components.container then

				local container = equipped.components.container
				for j, item in pairs(container.slots) do
					
					if item.components.leader then
						if item:HasTag("chester_eyebone") then
							eyebone = item
						end
						for follower, v in pairs(item.components.leader.followers) do
							if follower == inst then
								isfollower = true
							end
						end
					end
				end
			end
		end
		-- special special special case: if we have an eyebone, then we have a container follower not actually in the inventory. Look for inventory items with followers there.
		if eyebone and eyebone.components.leader then
			for follower, v in pairs(eyebone.components.leader.followers) do
				
				if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) and follower.components.container then					
					for j,item in pairs(follower.components.container.slots) do

						if item.components.leader then
							for follower, v in pairs(item.components.leader.followers) do
								if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
									if follower == inst then
										isfollower = true
									end
								end
							end
						end
					end
				end
			end
		end
	end

	-- spells that are targeting the player are...followers too
	if inst.components.spell and inst.components.spell.target == player then --GetPlayer() then
		isfollower = true
	end
	
	-- DS - To deal with lights and stuff. Whatever method they used before doesn't seem to work.
	if inst.entity:GetParent() then
		if inst.entity:GetParent():HasTag("player") then
			print("FOUND A CHILD",inst.prefab)
			isfollower = true
		end
	end
	-- Oh dang, that's it below, isn't it? To get stuff attached to the player?

	-- DS - No idea what 'GetGrandParent' is. It's in entityscript.lua, and I have no idea how to put stuff in to that.
	-- if inst and not isfollower and inst:GetGrandParent() == GetPlayer() then
		-- print("FOUND A CHILD",inst.prefab)
		-- isfollower = true
	-- end

	return isfollower
end

function InteriorSpawner:ExecuteTeleport(doer, destination, direction)	
	self:Teleport(doer, destination)

	if direction then
		self:PushDirectionEvent(doer, direction)
	end

	if doer.components.leader then
		for follower, v in pairs(doer.components.leader.followers) do			
			self:Teleport(follower, destination)
			if direction then
				self:PushDirectionEvent(follower, direction)
			end
		end
	end

	local eyebone = nil

	--special case for the chester_eyebone: look for inventory items with followers
	if doer.components.inventory then
		for k, item in pairs(doer.components.inventory.itemslots) do

			if direction then
				self:PushDirectionEvent(item, direction)
			end

			if item.components.leader then
				if item:HasTag("chester_eyebone") then
					eyebone = item
				end
				for follower,v in pairs(item.components.leader.followers) do
					self:Teleport(follower, destination)
				end
			end
		end
		-- special special case, look inside equipped containers
		for k, equipped in pairs(doer.components.inventory.equipslots) do
			if equipped and equipped.components.container then

				if direction then
					self:PushDirectionEvent(equipped, direction)
				end

				local container = equipped.components.container
				for j, item in pairs(container.slots) do
					
					if direction then
						self:PushDirectionEvent(item, direction)
					end

					if item.components.leader then
						if item:HasTag("chester_eyebone") then
							eyebone = item
						end
						for follower,v in pairs(item.components.leader.followers) do
							self:Teleport(follower, destination)
						end
					end
				end
			end
		end
		-- special special special case: if we have an eyebone, then we have a container follower not actually in the inventory. Look for inventory items with followers there.
		if eyebone and eyebone.components.leader then
			for follower, v in pairs(eyebone.components.leader.followers) do

				if direction then
					self:PushDirectionEvent(follower, direction)
				end
				
				if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) and follower.components.container then					
					for j, item in pairs(follower.components.container.slots) do

						if direction then
							self:PushDirectionEvent(item, direction)
						end

						if item.components.leader then
							for follower, v in pairs(item.components.leader.followers) do
								if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
									self:Teleport(follower, destination)
								end
							end
						end
					end
				end
			end
		end
	end


	-- if doer == GetPlayer() and GetPlayer().components.kramped then
	if doer:HasTag("player") and doer.components.kramped then
		
		local kramped = GetPlayer().components.kramped
		kramped:TrackKrampusThroughInteriors(destination)
end
end


function InteriorSpawner:GetInteriorPlayerIndex(player)
	print("DS - GetInteriorPlayerIndex")
	local playerID = player.userid
	print("Player ID gotten as ", playerID)
	if self.interior_players then
		print("Interior Player list recognized as existing, dump then check for player")
		dumptable(self.interior_players,1, 1, nil, 0)
		for k, v in ipairs(self.interior_players) do
			-- if v == playerID then
				-- return k
			-- end
			
			if v.playerID == playerID then
				print("Found player ID in the list, return its index (",k,")")
				return k
			else
				print("Didn't find player on iteration ", k, ", found ", v.playerID, " instead")
			end
		end
	end
	print("Never found player in list, return as nil")
	return nil
end
-- DS - Added this
function InteriorSpawner:GetPlayerInterior(player)
	local playerID = player.userid
	
	print("DS - GetPlayerInterior - Attempting to find the interior a player of ID ", playerID)
	
	if self.interior_players then
		for k, v in ipairs(self.interior_players) do
			-- if v == playerID then
				-- return v.interiorID
			-- end
			if v.playerID == playerID then
				return v.interiorID
			end
		end
	end
	return nil
end

function InteriorSpawner:IsPlayerInInterior(player)
	local playerID = player.userid
	
	if self.interior_players then
		for k, v in ipairs(self.interior_players) do
			-- if v == playerID then
				-- return true
			-- end
			if v.playerID == playerID then
				return true
			end
		end
	end
	return false
end



function InteriorSpawner:AddPlayerToInteriorList(player, interiorID)
	if player:HasTag("player") then
		if self:IsPlayerInInterior(player) then
			print("DS - AddPlayerToInteriorList - WARNING: Player was already detected in list when adding!")
		end
		
		local playerid = player.userid
		local data = 
		{
			playerID = playerid,
			interiorID = interiorID
		}
		-- self.interior_players[playerID] = interiorID --data
		--self.interior_players[playerID] = data
		print("Prior to adding the player to the list, let's dump the data we're about to add:")
		dumptable(data, 1, 1, nil, 0)
		table.insert(self.interior_players, data)
		print("DS - Added player to Interior Player list. Dumping to be sure...")
		dumptable(self.interior_players, 1, 1, nil, 0)
	else
		print("DS - WARNING: Entity passed to 'AddPlayerToInteriorList' was missing player tag!")
	end
end

function InteriorSpawner:RemovePlayerFromInteriorList(player)
	print("DS - RemovePlayerFromInteriorList - about to try getting player interior index, you should get some prints from that function")
	local k = self:GetInteriorPlayerIndex(player)
	if k then
		print("Removing player from list. First, dumping list...")
		dumptable(self.interior_players, 1, 1, nil, 0)
		table.remove(self.interior_players, k)
		print("Now dumping table AFTER removing the player from entry ",k)
		dumptable(self.interior_players, 1, 1, nil, 0)
	else
		print("Player not detected in interior list when trying to remove?!?! K was ",k)
	end
end

function InteriorSpawner:UpdatePlayerInterior(player, interiorID)
	local k = self:GetInteriorPlayerIndex(player)
	if k then
		print("Updated player interior ID, now ", interiorID)
		self.interior_players[k].interiorID = interiorID
		print("Dumping to be sure the change stuck:")
		dumptable(self.interior_players, 1, 1, nil, 0)
	end
end

function InteriorSpawner:IsInteriorPlayerLoaded(interiorID)
	print("DS - IsInteriorPlayerLoaded running with interiorID of ", interiorID)
	if self.interior_players then
		for k, v in ipairs(self.interior_players) do
			print("DS - IsInteriorPlayerLoaded - dumping v...")
			dumptable(v, 1, 1, nil, 0)
			if v.interiorID == interiorID then
				print("Found interior at index ", k)
				return true
			else
				print("Interior not located at index ", k, ", instead got", v.interiorID)
			end
		end
	end
	-- print("Never found interior, presumably unloaded already") -- Darn misleading/old prints
	print("DS - IsInteriorPlayerLoaded - Didn't detect interior ID in player list, so it isn't player-loaded")
	return false
end

function InteriorSpawner:LoadInteriorByPlayer(player, interior)
	-- DS - Just an idea I had, but ended up unused
end

-- Just returns how many interiors are already loaded. Useful for things like creating a new interior space offset
-- Although, I've since discovered that #table works, also.
function InteriorSpawner:GetLoadedInteriorCount()
	local count = 0
	if self.loaded_interiors then
		for k, v in ipairs(self.loaded_interiors) do
			count = count + 1
		end
	end
	return count
end

function InteriorSpawner:GetLiveInteriorOffset(interiorID)
	local index = self:GetLoadedInteriorIndex(interiorID)
	local offset = self.loaded_interiors[index].storage_offset
	print("DS - Got loaded interior of ID ", interiorID," offset, returning as ", offset)
	return offset
end

-- DS - and this. Comments so I can keep track
-- This is meant to tell you if the given interiorID is already in the list of loaded interiors, intended to help with letting players visit the same interior at the same time.
-- Still need a method to actually have different interior storage locations. I'm thinking that, if all interiors get added to the 'loaded interiors' list, then we can edit the 'interior origin' function to return an offset based on that interior's position in the list. With a single player, it should only use the original location
function InteriorSpawner:IsInteriorLoaded(interiorID)
	print("DS - IsInteriorLoaded - Attempting to figure out if interior ID ", interiorID, " is loaded")
	if self.loaded_interiors then
		for k, v in ipairs(self.loaded_interiors) do
			if v.interior_ref.unique_name == interiorID then
				print("Determined ID was already loaded!")
				return true
			end
		end
	end
	print("ID was apparently not loaded")
	return false
end

--Returns the position in the 'loaded interiors' list by the interior's ID, or 'unique name'
function InteriorSpawner:GetLoadedInteriorIndex(interiorID) -- Doubles as an 'isloaded' check
	print("DS - GetLoadedInteriorIndex running with interiorID of ", interiorID)
	if self.loaded_interiors then
		print("loaded_interiors is valid, dump then find index...") 
		dumptable(self.loaded_interiors, 1, 1, nil, 0)
		for k, v in ipairs(self.loaded_interiors) do
			print("Inside loop ", k, ", dump V:")
			dumptable(v, 1, 1, nil, 0)
			if v.interior_ref.unique_name == interiorID then
				print("Found interior ID at index ",k," of loaded_interiors!")
				return k
			else
				print("Loop ", k, " didn't return interiorID of ",interiorID,". Instead got ", v.unique_name)
			end
		end
	end
	print("Didn't find interior ID in the loaded interiors list, returning nil...")
	return nil
end

-- -- Half's alteration of stuff
-- function InteriorSpawner:GetLoadedInteriorIndex(interiorID) -- Doubles as an 'isloaded' check
    -- print("DS - GetLoadedInteriorIndex running with interiorID of ", interiorID)
    -- if self.loaded_interiors then
        -- print("loaded_interiors is valid, dump then find index...") 
        -- for k, v in ipairs(self.loaded_interiors) do
            -- print("Inside loop ", k, ", dump V, Half-style:")
            -- for g, h in pairs(v) do
                -- print(g, h)
            -- end
            -- if v.unique_name == interiorID then
                -- print("Found interior ID at index ",k," of loaded_interiors!")
                -- return k
            -- else
                -- print("Loop ", k, " didn't return interiorID of ",interiorID,". Instead got ", v.unique_name)
            -- end
        -- end
    -- end
    -- print("Didn't find interior ID in the loaded interiors list, returning nil...")
    -- return nil
-- end


--function InteriorSpawner:GetInteriorSpawnOrigin

function InteriorSpawner:GatherAllRooms(from_room, allrooms)
	if allrooms[from_room] then 
		-- already did this room
		return
	end
	allrooms[from_room] = true
	local interior = self:GetInteriorByName(from_room) 
	if interior then		
		--print("interior = ",interior)		
		--print("prefabs:",interior.prefabs)
		if interior.prefabs then
			-- room was never spawned
			--assert(false)
			for k, prefab in ipairs(interior.prefabs) do
				if prefab.name == "prop_door" then
					if  prefab.door_closed then
						prefab.door_closed["door"] = nil
					end
					local target_interior = prefab.target_interior	
					print("target_interior:",target_interior)
					if target_interior then
						self:GatherAllRooms(target_interior, allrooms)
					end
				end
			end
		else
			-- go through the object list and see what entities are doors
			if interior.object_list and #interior.object_list > 0 then
				--print("Room has been spawned but was unspawned")
				-- room was spawned but is unspawned
				for i,v in pairs(interior.object_list) do
					--print(i,v)
					if v.prefab == "prop_door" then
						if v.components.door then
							--v.components.door:checkDisableDoor(nil, "door")
							v:PushEvent("open", {instant=true})
							local target_interior = v.components.door.target_interior	
							--print("target_interior:",target_interior)
							if target_interior then
								self:GatherAllRooms(target_interior, allrooms)
							end
						end
					end
				end
			else
				-- we're in the room
				print("Inside the room")
				local ents = self:GetCurrentInteriorEntities()
				for i,v in pairs(ents) do
					if v.prefab == "prop_door" then
						--print(v)
						if v.components.door then
							--v.components.door:checkDisableDoor(nil, "door")
							v:PushEvent("open", {instant=true})
							local target_interior = v.components.door.target_interior	
							--print("target_interior:",target_interior)
							if target_interior then
								self:GatherAllRooms(target_interior, allrooms)
							end
						end
					end
				end
			end
		end
	else
		assert(false)
	end

end

function InteriorSpawner:UnlockAllDoors(from_door)
	-- gather all rooms that can be reached from this room
	local allrooms = {}
	local target_interior
	if from_door then
		target_interior = from_door.components.door and from_door.components.door.interior_name
	else
		target_interior = self.current_interior and self.current_interior.unique_name
	end
	if target_interior then
		print("Unlocking all doors coming from", target_interior)
		self:GatherAllRooms(target_interior, allrooms)
    else
		print("Nothing to unlock")
	end
	--for i,v in pairs(allrooms) do
	--	print(i,v)
	--end
end

function InteriorSpawner:PlayTransition(doer, inst, interiorID, to_target, dont_fadeout, dont_fadein)	
	-- the usual use of this function is with doer and inst.. where inst has the door component.

	-- but you can provide an interiorID and a to_target instead and bypass the door stuff.

	-- to_target can be a pt or an inst

	-- DS - doer is the player

	self.from_inst = inst
	
	self.to_interior = nil
	
	if interiorID then
		self.to_interior = interiorID
	else
		if inst then
			self.to_interior = inst.components.door.target_interior
		end
	end
	
	-- if self:IsInteriorLoaded(interiorID)
	-- -- local playerInteriorID = self:GetPlayerInterior(doer)
	-- -- if playerInteriorID then
		-- -- if not self:GetLoadedInteriorIndex(playerInteriorID) == nil then
			-- -- This interior is already loaded, just teleport to its location
		-- -- end
		
	-- end


	if to_target then		
		self.to_target = to_target
	end
	
	if doer:HasTag("player") then
		if self.to_interior then
			self:ConsiderPlayerInside(self.to_interior)
		end

		TheWorld.doorfreeze = true		

		if TheWorld.ismastersim then
			self.was_invincible = doer.components.health:IsInvincible()
			doer.components.health:SetInvincible(true)
			doer.components.playercontroller:Enable(false)
		
		-- if GetPlayer().HUD and GetPlayer().HUD.shown then
			-- self.HUDon = true
			-- GetPlayer().HUD:Hide()
		-- end
		-- DS - This stuff doesn't seem to be necessary, as the fade effect also seems to fade the hud.
			if doer:IsHUDVisible() then
				-- doer:ShowHUD(false)
			end
		end

		if dont_fadeout then
			--self:FadeOutFinished(dont_fadein)
			self:FadeOutFinished(dont_fadein, doer, inst, to_target, interiorID)
		else
			--TheFrontEnd:Fade(false, 0.5, function() self:FadeOutFinished(dont_fadein) end)
			--TheFrontEnd:Fade(false, 0.5, function() self:FadeOutFinished(dont_fadein, doer) end)
			if TheWorld.ismastersim then
				doer:ScreenFade(false, 0.5, false) -- Adjusting it slightly to see if it helps with the black screen getting stuck on boats
			end
			self.inst:DoTaskInTime(0.5, function() self:FadeOutFinished(dont_fadein, doer, inst, to_target, interiorID) end)
		end
	else
		print("!!ERROR: Tried To Execute Transition With Non Player Character")
	end
end

function InteriorSpawner:CreateRoom(interior, width, height, depth, dungeon_name, roomindex, addprops, exits, walltexture, floortexture, minimaptexture, cityID, cc, batted, playerroom, reverb, ambsnd, groundsound, cameraoffset, zoom, forceInteriorMinimap)
    if not interior then
        interior = "generic_interior"
    end
    if not width then            
        width = 15
    end
    if not depth then
        depth = 10
    end        
	if not height then
		height = 5
	end
    assert(roomindex)

	-- SET A DEFAULT CC FOR INTERIORS
    if not cc then
    	cc = "images/colour_cubes/day05_cc.tex"
    end       
	
    local interior_def =
    {
        unique_name = roomindex,
        dungeon_name = dungeon_name,
        width = width,
        height = height,
        depth = depth,
        prefabs = {},
        walltexture = walltexture,
        floortexture = floortexture,
        minimaptexture = minimaptexture,
        cityID = cityID,
        cc = cc,
        visited = false,
        batted = batted,
        playerroom = playerroom,
        enigma = false,
        reverb = reverb,
        ambsnd = ambsnd,
        groundsound = groundsound,
        cameraoffset = cameraoffset,
        zoom = zoom,
		forceInteriorMinimap = forceInteriorMinimap
    }

    local prefab = {}

    for i, prefab  in ipairs(addprops) do
        table.insert(interior_def.prefabs, prefab)           
    end

	print("About to loop through exits")
    for t, exit in pairs(exits) do
		print("Loop ",t)

    	if not exit.house_door then
	        if     t == NORTH then
	            prefab = { name = "prop_door", x_offset = -depth/2, z_offset = 0, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "north", background = true },
	                        my_door_id = roomindex.."_NORTH", target_door_id = exit.target_room.."_SOUTH", target_interior = exit.target_room, rotation = -90, hidden = false, angle=0, addtags = { "lockable_door", "door_north" } }
	        
	        elseif t == SOUTH then
	            prefab = { name = "prop_door", x_offset = (depth/2), z_offset = 0, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "south", background = false },
	                        my_door_id = roomindex.."_SOUTH", target_door_id = exit.target_room.."_NORTH", target_interior = exit.target_room, rotation = -90, hidden = false, angle=180, addtags = { "lockable_door", "door_south" } }
	            
	            if not exit.secret then
	            	table.insert(interior_def.prefabs, { name = "prop_door_shadow", x_offset = (depth/2), z_offset = 0, animdata = { bank = exit.bank, build = exit.build, anim = "south_floor" } })
	            end

	        elseif t == EAST then
	            prefab = { name = "prop_door", x_offset = 0, z_offset = width/2, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "east", background = true },
	                        my_door_id = roomindex.."_EAST", target_door_id = exit.target_room.."_WEST", target_interior = exit.target_room, rotation = -90, hidden = false, angle=90, addtags = { "lockable_door", "door_east" } }
	        
	        elseif t == WEST then
	            prefab = { name = "prop_door", x_offset = 0, z_offset = -width/2, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "west", background = true },
	                        my_door_id = roomindex.."_WEST", target_door_id = exit.target_room.."_EAST", target_interior = exit.target_room, rotation = -90, hidden = false, angle=270, addtags = { "lockable_door", "door_west" } }
	        end
	    else
			local doordata = player_interior_exit_dir_data[t.label]
	            prefab = { name = exit.prefab_name, x_offset = doordata.x_offset, z_offset = doordata.z_offset, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = exit.prefab_name .. "_open_"..doordata.anim, background = doordata.background },
	                        my_door_id = roomindex..doordata.my_door_id_dir, target_door_id = exit.target_room..doordata.target_door_id_dir, target_interior = exit.target_room, rotation = -90, hidden = false, angle=doordata.angle, addtags = { "lockable_door", doordata.door_tag } }

	    end

        if exit.vined then
        	prefab.vined = true
        end

        if exit.secret then
        	prefab.secret = true
        	prefab.hidden = true
        end

        table.insert(interior_def.prefabs, prefab)
    end
	print("Exit loop finished")

    self:AddInterior(interior_def)
end

function InteriorSpawner:AddInterior(interior_definition)	
	 print("CREATING ROOM", interior_definition.unique_name)
	local spawner_definition = self.interiors[interior_definition.unique_name]

	assert(not spawner_definition, "THIS ROOM ALREADY EXISTS: "..interior_definition.unique_name)

	spawner_definition = interior_definition
	spawner_definition.object_list = {}
	--spawner_definition.handle = createInteriorHandle(spawner_definition)
	self.interiors[spawner_definition.unique_name] = spawner_definition
	
	--print("Attempting to force-load an interior by the name of ", spawner_definition.unique_name)
	print("This is where the force-load would be, but we're skipping that to try and get the real deal going")
	--local interior = interior_definition
	print("Attempting to retrieve interior def entries...")
	for k, v in ipairs(interior_definition) do
		print("Retrieving interior def entry...")
		print("Def entry ", k, ": ", v)
	end
	print("Finished loop")
	local interior =
	{
		interior_definition.unique_name
	}
	--interior.target_interior = 1
	--self.inst:DoTaskInTime(2, function() self:LoadInterior(self.interiors[spawner_definition.unique_name]) end)
	
	-- The last force-load attempt was just this line
	--self.inst:DoTaskInTime(2, function() self:LoadInterior(interior_definition) end)

	-- if batcave, register with the batted component.
	if spawner_definition.batted then
		if TheWorld.components.batted then
			TheWorld.components.batted:RegisterInterior(spawner_definition.unique_name)
		end
	end
end

function InteriorSpawner:CreatePlayerHome(house_id, interior_id)
	print("CreatePlayerHome - House ID: ", house_id, "Interior ID: ", interior_id)
	self.player_homes[house_id] = 
	{
		[interior_id] = { x = 0, y = 0}
	}
end

function InteriorSpawner:GetPlayerHome(house_id)
	return self.player_homes[house_id]
end

function InteriorSpawner:GetPlayerRoomIndex(house_id, interior_id)
	if self.player_homes[house_id] and self.player_homes[house_id][interior_id] then
		return self.player_homes[house_id][interior_id].x, self.player_homes[house_id][interior_id].y
	end
end

function InteriorSpawner:GetCurrentPlayerRoomConnectedToExit(exclude_dir, exclude_room_id)
	if self.current_interior then
		return self:PlayerRoomConnectedToExit(self.current_interior.dungeon_name, self.current_interior.unique_name, exclude_dir, exclude_room_id)
	end
end

function InteriorSpawner:PlayerRoomConnectedToExit(house_id, interior_id, exclude_dir, exclude_room_id)
	if not self.player_homes[house_id] then
		print ("NO HOUSE FOUND WITH THE PROVIDED ID")
		return false
	end

	local checked_rooms = {}

	local function DirConnected(current_interior_id, dir)

		if current_interior_id == exclude_room_id then
			return false
		end

		checked_rooms[current_interior_id] = true

		local index_x, index_y = self:GetPlayerRoomIndex(house_id, current_interior_id)
		if index_x == 0 and index_y == 0 then
			return true
		end

		local surrounding_rooms = self:GetConnectedSurroundingPlayerRooms(house_id, current_interior_id, dir)

		if next(surrounding_rooms) == nil then
			return false
		end

		for next_dir, room_id in pairs(surrounding_rooms) do
			if not checked_rooms[room_id] then
				local dir_connected = DirConnected(room_id, op_dir_str[next_dir])
				if dir_connected then
					return true
				elseif not dir_connected and next(surrounding_rooms, next_dir) == nil then
					return false
				end
			end
		end
	end

	return DirConnected(interior_id, exclude_dir)
end

function InteriorSpawner:CreateWalls()
	-- create 4 walls will be reconfigured for each room
	local origWidth = 1
	local delta = (2 * wallWidth - 2 * origWidth) / 2

	local spawnStorage = self:GetSpawnStorage()

	print("DS - Making interior collision triangle thing")
	local collision = SpawnPrefab("interior_collision")
	collision.Transform:SetPosition(spawnStorage.x-2.5, spawnStorage.y, spawnStorage.z) -- I forgot to do this and was wondering why it did nothing
	
	self.walls = collision -- This could get it automatically done with saves and stuff, let's find out
	-- It might also be bad, because this stuff doesn't seem to have been redone with multiplayer in mind yet, only having the same walls reused for every interior. I suppose I can either make these again for every interior, or spawn and despawn them as needed depending on how many interiors are currently loaded?

	return self.walls
end

-- DS - This is MAYBE impossible, I think?

-- When we have an old save where we exited this world from inside an interior 
-- and we come back another way (eg house on volcano), come back through main island and seaworthy)
-- we would be be stuck in interior mode but we really are not in interior mode
function InteriorSpawner:CheckIfPlayerIsInside()
	--local player = ThePlayer
	--ThePlayer:UpdateIsInInterior()
	if self.current_interior then --and not ThePlayer:CheckIsInInterior() then
		print("DS WARNING - Hamlet code trying to do some interior fix thing, but the code is disabled!")
		-- Play an instant transition out of this interior (no fades)
		--self:PlayTransition(GetPlayer(), nil, nil, GetPlayer():GetPosition(), true, true)
	end
end

function InteriorSpawner:GetInteriorDoors(interiorID)
	local found_doors = {}

	for k, door in pairs(self.doors) do
		if door.my_interior_name == interiorID then
			table.insert(found_doors, door)
		end
	end

	return found_doors

end

function InteriorSpawner:GetDoorInst(door_id)
	local door_data = self.doors[door_id]
	if door_data then
		if door_data.my_interior_name then
			local interior = self.interiors[door_data.my_interior_name]
			for k, v in ipairs(interior.object_list) do
				if v.components.door and v.components.door.door_id == door_id then
					return v
				end
			end
		else
			return door_data.inst
		end
	end
	return nil
end

function InteriorSpawner:AddDoor(inst, door_definition)
	print("ADDING DOOR", door_definition.my_door_id)
	-- this sets some properties on the door component of the door object instance
	-- this also adds the door id to a list here in interiorspawner so it's easier to find what room needs to load when a door is used
	self.doors[door_definition.my_door_id] = { my_interior_name = door_definition.my_interior_name, inst = inst, target_interior = door_definition.target_interior }

	if inst ~= nil then
		print("Door is valid, setting data...")
		if inst.components.door == nil then
			print("Door was missing door component, add it")
			inst:AddComponent("door")
		end
		inst.components.door.door_id = door_definition.my_door_id
		inst.components.door.interior_name = door_definition.my_interior_name
		inst.components.door.target_door_id = door_definition.target_door_id
		inst.components.door.target_interior = door_definition.target_interior
		
		print("Double-checking door data: ")
		print("Door ID: ", inst.components.door.door_id )
		print("Interior Name: ", inst.components.door.interior_name )
		print("Target Door ID: ", inst.components.door.target_door_id )
		print("Target Interior: ", inst.components.door.target_interior )
		
	end
end


function InteriorSpawner:SpawnInterior(interior, storageOffset)

	-- this function only gets run once per room when the room is first called. 
	-- if the room has a "prefabs" attribute, it means the prefabs have not yet been spawned.
	-- if it does not have a prefab attribute, it means they have bene spawned and all the rooms
	-- contents will now be in object_list

	print("SPAWNING INTERIOR, FIRST TIME ONLY")

	-- This does nothing right now
	local loadingInterior = self:GetLoadedInteriorIndex(interior.unique_name)

	-- local pt = self:GetSpawnStorage(loadingInterior, 1)
	-- local pt = self:GetSpawnStorage(loadingInterior)
	
	-- local pt = self:GetSpawnStorage(nil, interior.storage_space)
	-- local pt = self:GetSpawnStorage(nil, interior) -- Trying to fix concurrent interiors, because apparently that broke
	
	-- local pt = self:GetSpawnStorage((self:FindFreeStorageSpace()), nil)
	local pt = self:GetSpawnStorage(nil, storageOffset)
	
	print("DS - SpawnInterior - Got PT as ", pt)
	

	for k, prefab in ipairs(interior.prefabs) do

		-- Disabled check because who needs it, eh? For now, at least
		-- if TheWorld.getworldgenoptions(TheWorld)[prefab.name] and TheWorld.getworldgenoptions(TheWorld)[prefab.name] == "never" then
			-- print("CANCEL SPAWN ITEM DUE TO WORLD GEN PREFS", prefab.name)
	 	-- else

			print("SPAWN ITEM", prefab.name)

			local object = SpawnPrefab(prefab.name)
			object.Transform:SetPosition(pt.x + prefab.x_offset, 0, pt.z + prefab.z_offset)	

			-- sets the initial roation of an object, NOTE: must be manually saved by the item to survive a save
			if prefab.rotation and not prefab.flip then
				object.Transform:SetRotation(prefab.rotation)
				if prefab.rotation > 0 then
					object.flipped = true
					object.AnimState:SetScale(-1,1,1)
				end
			end

			-- adds tags to the object
			if prefab.addtags then
				for i, tag in ipairs(prefab.addtags) do
					object:AddTag(tag)
				end			
			end

			if prefab.hidden then
				object.components.door.hidden = true			
			end
			if prefab.angle then
				object.components.door.angle = prefab.angle			
			end

			-- saves the roomID on the object
			if object.components.shopinterior or object.components.shopped or object.components.shopdispenser then
				object.interiorID = interior.unique_name
			end

			-- sets an anim to start playing
			if prefab.startAnim then
				object.AnimState:PlayAnimation(prefab.startAnim)
				object.startAnim = prefab.startAnim
			end	

			if prefab.usesounds then
				object.usesounds = prefab.usesounds
			end	

			if prefab.saleitem then
				object.saleitem = prefab.saleitem
			end

			if prefab.justsellonce then
				object:AddTag("justsellonce")
			end	

			if prefab.startstate then
				object.startstate = prefab.startstate
				if object.sg == nil then
					object:SetStateGraph(prefab.sg_name)
					object.sg_name = prefab.sg_name
				end

				object.sg:GoToState(prefab.startstate)

				if prefab.startstate == "forcesleep" then
					object.components.sleeper.hibernate = true
					object.components.sleeper:GoToSleep()
				end
			end

			if prefab.shelfitems then
				object.shelfitems = prefab.shelfitems
			end		

			-- this door should have vines
			--if prefab.vined and object.components.vineable then
			--	object.components.vineable:SetUpVine()
			--end


			-- this function processes the extra data that the prefab has attached to it for interior stuff. 
			if object.initInteriorPrefab then
				print("SpawnInterior - Initializing interior prefab")
				object.initInteriorPrefab(object, ThePlayer, prefab, interior)
			end

			-- should the door be closed for some reason?
			-- needs to happen after the object initinterior so the door info is there. 
			if prefab.door_closed then
				for cause,setting in pairs(prefab.door_closed)do
					object.components.door:checkDisableDoor(setting, cause)
				end
			end

			if prefab.secret then
				object:AddTag("secret")
				object:RemoveTag("lockable_door")
				object:Hide()

				self.inst:DoTaskInTime(0, function()
					local crack = SpawnPrefab("wallcrack_ruins")
					crack.SetCrack(crack, object)
				end)
			end

			-- needs to happen after the door_closed stuff has happened.
			if object.components.vineable then
				object.components.vineable:InitInteriorPrefab()
			end

			if interior.cityID then
	    		object:AddComponent("citypossession")
	    		object.components.citypossession:SetCity(interior.cityID)
			end

			if object.decochildrenToRemove then
				for i, child in ipairs(object.decochildrenToRemove) do
					if child then          
						local ptc = Vector3(object.Transform:GetWorldPosition())
	                	child.Transform:SetPosition( ptc.x ,ptc.y, ptc.z )
	                	child.Transform:SetRotation( object.Transform:GetRotation() )
	            	end
				end
			end
		--end
	end
	print("SpawnInterior finished!")

	interior.visited = true
end

function InteriorSpawner:FindFreeStorageSpace()
	
	print("About to try and find a free storage space")
	local storageOffset = 0
	for k, v in ipairs(self.loaded_interiors) do
		if v.storage_offset == storageOffset then
			print("Found occupied storage space at ", storageOffset)
			storageOffset = storageOffset + 1
		else
			print("Located free space inside loop as ", storageOffset)
			break
		end
	end
	print("Found? Got ", storageOffset)
	return storageOffset
	
end

function InteriorSpawner:LoadInterior(doer, interior)
	self:SanityCheck("Pre LoadInterior")
	assert(interior, "No interior was set to load")
	
	print("DS - LoadInterior - Dumping interior...")
	dumptable(interior, 1, 0, nil, 0)

	-- THIS IS WHERE THE INTERIOR SHOULD BE SET
	print("Loading Interior "..interior.unique_name.. " with no handle, because that engine stuff doesn't exist")--With Handle "..interior.handle)
	--TheWorld.Map:SetInterior( interior.handle )

	-- Can't use the length, need to actually find unused storage offsets.
	
	local storageOffset = self:FindFreeStorageSpace()
	
	-- interior.storage_offset = (storageOffset)
	
	local loadedInteriorCount = #self.loaded_interiors -- SHOULD be the length, I think?
	print("Interior count gotten directly with LUA's hash symbol:", loadedInteriorCount)
	-- print("Loaded interior count according to hash: 
	
	local hasdoors = false
	-- when an interior is called, it will either need to spawn all of it's contents the first time (prefabs attribute)
	-- or move its contents from limbo. (object_list attribute)
	print("About to do load interior prefab stuff...")
	if interior.prefabs then
		print("Interior has prefabs, load them")
		print("LoadInterior - running SpawnInterior")
		self:SpawnInterior(interior, storageOffset)
		print("LoadInterior - SpawnInterior finished")
		print("LoadInterior - running RefreshDoorsNotInLimbo")
		self:RefreshDoorsNotInLimbo()
		print("LoadInterior - Doors refreshed")
		print("LoadInterior - Nilling prefabs...")
		interior.prefabs = nil
		print("LoadInterior - Done!")
	else
		print("No prefabs in interior, do something")
		local prop_door_shadow = nil
		local doors_in_limbo = {}

		-- Need the forced offset because the interior isn't loaded yet, so normal + 1 would just be 1 with no interiors, 2 with 1 interior already loaded, etc.
		
		print("LoadInterior - Getting index of loaded interior...")
		-- local loadingInterior = self:GetLoadedInteriorIndex(interior.unique_name)

		-- local pt1 = self:GetSpawnStorage(loadingInterior, 1)
		-- local pt1 = self:GetSpawnStorage(nil, (loadedInteriorCount + 1))
		
		-- local pt1 = self:GetSpawnStorage(nil, (storageOffset))
		-- local pt1 = self:GetSpawnStorage(nil, storageOffset)
		local pt1 = self:GetSpawnStorage(nil, storageOffset)
		
		-- local pt1 = self:GetSpawnStorage(loadingInterior)
		-- local pt2 = self:GetSpawnOrigin()
		local pt2 = self:GetSpawnOrigin()
		
		print("DS - LoadInterior - PT1 = ", pt1)
		print("PT2 = ", pt2)

		local objects_to_return	= {}	-- make a copy, as it can be modified during iteration
		for k, v in ipairs(interior.object_list) do
			objects_to_return[k] = v
		end
		-- bring the items back in two passes, first move everytone, then wake them up, in case awake relies on position of another entity
		for k, v in ipairs(objects_to_return) do
			if v:IsValid() then
				
				if pt1 and not v.parent then
					local diffx = pt2.x - pt1.x 
					local diffz = pt2.z - pt1.z
					print("DS - LoadInterior - Object diffs:")
					print("DiffX = ", diffx)
					print("DiffZ = ", diffz)
					

					local proppt = Vector3(v.Transform:GetWorldPosition())
					print("Prop vector:", proppt)
					v.Transform:SetPosition(proppt.x + diffx, proppt.y, proppt.z +diffz)
					print("Final position:", v.Transform:GetWorldPosition())
					-- dumptable(v.Transform:GetWorldPosition(), 1, 1, nil, 0)
				end

				if v.prefab == "prop_door_shadow" then
					prop_door_shadow = v
				end
			end
		end
		-- pass two, wake everyone up
		for k, v in ipairs(objects_to_return) do
			if v:IsValid() then
				self:ReturnItemToScene(v, doors_in_limbo)
			end
		end
		for k, v in ipairs(doors_in_limbo) do
			print("Limbo door loop",k)
			hasdoors = true
			v:ReturnToScene()
			v:RemoveTag("INTERIOR_LIMBO")
			if (v.sg == nil) and (v.sg_name ~= nil) then
				v:SetStateGraph(v.sg_name)
				v.sg:GoToState(v.startstate)
			end			

			if v:HasTag("door_south") then
				v.shadow = prop_door_shadow
			end

			v.components.door:updateDoorVis()
		end

		interior.object_list = {}
	end
	print("Finished interior prefab stuff, detected doors: ", hasdoors)

	interior.enigma = false
	self.current_interior = interior
	-- table.insert(self.loaded_interiors.interior_ref, interior)
	local interiorData = {
		interior_ref = interior,
		storage_offset = storageOffset,
	}
	table.insert(self.loaded_interiors, interiorData)
	-- interior.storage_offset = (storageOffset)
	self:ConsiderPlayerInside(self.current_interior.unique_name)

	if not hasdoors then
		print("*** Warning *** InteriorSpawner:LoadInterior - no doors for interior "..interior.unique_name.." ("..interior.dungeon_name..")")
	end

	-- Loaded interior, configure the walls
	print("Interior wall configuration")
	self:ConfigureWalls(interior)

	self:SanityCheck("Post LoadInterior")
	
	return storageOffset
	
end

function InteriorSpawner:insertprefab(interior, prefab, offset, prefabdata)
	if interior == self.current_interior then
		print("CURRENT")
		local pt = self:GetSpawnOrigin()
		local object = SpawnPrefab(prefab)	
		object.Transform:SetPosition(pt.x + offset.x_offset, 0, pt.z + offset.z_offset)
		if prefabdata and prefabdata.startstate then
			object.sg:GoToState(prefabdata.startstate)
			if prefabdata.startstate == "forcesleep" then
				object.components.sleeper.hibernate = true
				object.components.sleeper:GoToSleep()
			end
		end		
	elseif interior.visited then
		print("VISITED")
		local pt = self:GetSpawnOrigin()
		local object = SpawnPrefab(prefab)	
		object.Transform:SetPosition(pt.x + offset.x_offset, 0, pt.z + offset.z_offset)			
		if prefabdata and prefabdata.startstate then
			object.sg:GoToState(prefabdata.startstate)
			if prefabdata.startstate == "forcesleep" then
				object.components.sleeper.hibernate = true
				object.components.sleeper:GoToSleep()
			end
		end
		self:PutPropIntoInteriorLimbo(object,interior)
	else
		local data = {name = prefab, x_offset = offset.x_offset, z_offset = offset.z_offset }
		if prefabdata then
			for arg, param in pairs(prefabdata) do
				data[arg] = param
			end
		end
		table.insert(interior.prefabs, data)
	end
end

function InteriorSpawner:InsertHouseDoor(interior, door_data)

	if interior.visited then
		local pt = self:GetSpawnOrigin()

		local object = SpawnPrefab(door_data.name)
		object.Transform:SetPosition(pt.x + door_data.x_offset, 0, pt.z + door_data.z_offset)
		object.Transform:SetRotation(door_data.rotation)
		object.initInteriorPrefab(object, nil, door_data, interior) -- DS - The 'nil' was GetPlayer(), but I don't want to pass it down all the way, and it doesn't seem to be used regardless

		self:AddDoor(object, door_data)
		self:PutPropIntoInteriorLimbo(object, interior)

	else
		local data = door_data
		table.insert(interior.prefabs, data)
	end
end

-- find the world entry points into dungeons. For multipe entries into one dungeon this is non-deterministic
function InteriorSpawner:CheckForInvalidSpawnOrigin()
	-- Trying to detect the issue with clouds in rooms/unplacable items
	local xo, yo, zo = self:GetSpawnOrigin()
	local pt1 = self:GetSpawnOrigin()
	local x, y = TheWorld.Map:GetTileCoordsAtPoint(1000,0,0)
    local ground = TheWorld.Map:GetTile(x, y)
	print("SpawnOrigin:",pt1,GetTileInfo(pt1))
	if ground == WORLD_TILES.IMPASSABLE then
	--if (GetTileType(pt1) == "IMPASSABLE") then
		print("World has suspicious SpawnOrigin")
	end
end

-- Sanity check. If we are in a room, that room has no prefabs nor object_list
-- all other rooms need either object_list (when stored) or prefabs (when never instantiated)
function InteriorSpawner:SanityCheck(reason)
	print("Begin sanity check")
	assert(reason)
	self:CheckForInvalidSpawnOrigin()
	for k, room in pairs(self.interiors) do
		local interior = self:GetInteriorByName(room.unique_name)
		if interior and not self.alreadyFlagged[room.unique_name] then 
			local hasObjects = (#interior.object_list > 0)
			local hasPrefabs = (interior.prefabs ~= nil)
			if interior == self.current_interior then
				if (hasObjects or hasPrefabs) then
					self.alreadyFlagged[room.unique_name] = true
					print("*** Error *** InteriorSpawner ("..reason..")  Error: current interior "..room.unique_name.." ("..room.dungeon_name..") has objects or prefabs")
					print(debugstack())
				end
				--assert(not hasObjects and not hasPrefabs)
			else
				if (not (hasObjects or hasPrefabs)) then
					self.alreadyFlagged[room.unique_name] = true
					print("*** Error *** InteriorSpawner ("..reason..")  Error: non-current interior "..room.unique_name.." ("..room.dungeon_name..") has neither objects nor prefabs")
					print(debugstack())
				elseif (hasObjects and hasPrefabs) then
					self.alreadyFlagged[room.unique_name] = true
					print("*** Error *** InteriorSpawner ("..reason..") Error: non-current interior "..room.unique_name.." ("..room.dungeon_name..") has objects and prefabs")
					print(debugstack())
				end
				--assert(hasObjects or hasPrefabs)
				--assert(not (hasObjects and hasPrefabs))
			end
		end
	end
	print("End sanity check")
end

function InteriorSpawner:GetCurrentInterior()
	return self.current_interior
end

function InteriorSpawner:GetCurrentInteriors()
	local relatedInteriors = {}

	if self.current_interior then
		for key, interior in pairs(self.interiors) do
			if self.current_interior.dungeon_name == interior.dungeon_name then
				table.insert(relatedInteriors, interior)
			end
		end
	end

	return relatedInteriors
end

function InteriorSpawner:GetPlayerRoomIdByIndex(house_id, x, y)
	if self.player_homes[house_id] then
		for id, interior in pairs(self.player_homes[house_id]) do
			if interior.x == x and interior.y == y then
				return id
			end
		end
	end
end

function InteriorSpawner:GetPlayerRoomInDirection(house_id, id, dir)
	local x, y = self:GetPlayerRoomIndex(house_id, id)

	if x and y then
		if dir == "north" then
		    y = y + 1
		elseif dir == "east" then
		    x = x + 1
		elseif dir == "south" then
			y = y - 1
		elseif dir == "west" then
		    x = x - 1
		end
	end

    return self:GetPlayerRoomIdByIndex(house_id, x, y)
end

function InteriorSpawner:GetSurroundingPlayerRooms(house_id, id, exclude_dir)
	local found_rooms = {}
	for _, dir in ipairs(dir_str) do
		local room = self:GetPlayerRoomInDirection(house_id, id, dir)
		if room and dir ~= exclude_dir then
			found_rooms[dir] = room
		end
	end

	return found_rooms
end

function InteriorSpawner:GetConnectedSurroundingPlayerRooms(house_id, id, exclude_dir)
	local found_doors = {}
	local doors = self:GetInteriorDoors(id)
	local curr_x, curr_y = self:GetPlayerRoomIndex(house_id, id)

	for _, door in ipairs(doors) do
		if door.inst.prefab ~= "prop_door" then
			local target_x, target_y = self:GetPlayerRoomIndex(house_id, door.target_interior)

			if target_y > curr_y and exclude_dir ~= "north" then -- North door
				found_doors["north"] = door.target_interior
			elseif target_y < curr_y and exclude_dir ~= "south" then -- South door
				found_doors["south"] = door.target_interior
			elseif target_x > curr_x and exclude_dir ~= "east" then -- East Door
				found_doors["east"] = door.target_interior
			elseif target_x < curr_x and exclude_dir ~= "west" then -- West Door
				found_doors["west"] = door.target_interior
			end
		end
	end

	return found_doors
end

function InteriorSpawner:AddPlayerRoom(house_id, id, from_id, dir)
	if self.player_homes[house_id] then
		local x, y = self:GetPlayerRoomIndex(house_id, from_id)

		if x and y then
			if dir == "north" then
		        y = y + 1
		    elseif dir == "south" then
		        y = y - 1
		    elseif dir == "east" then
		        x = x + 1
		    elseif dir == "west" then
		        x = x - 1
		    end

		    self.player_homes[house_id][id] = {x = x, y = y}
		end
	end
end

function InteriorSpawner:RemovePlayerRoom(house_id, id)
	if self.player_homes[house_id] then
		if self.player_homes[house_id][id] then
			self.player_homes[house_id][id] = nil
		else
			print ("TRYING TO REMOVE INEXISTENT PLAYER ROOM WITH ID", id)
		end
	else
		print ("NO PLAYER HOME FOUND WITH ID", house_id)
	end
end

function InteriorSpawner:GetCurrentPlayerRoomIndex()
	if self.current_interior then
		return self:GetPlayerRoomIndex( self.current_interior.dungeon_name , self.current_interior.unique_name )
	end
end

function InteriorSpawner:getPropInterior(inst)
	if inst.interior then
		return inst.interior
	end

	for room, data in pairs(self.interiors)do
		for p, prop in ipairs(data.object_list)do
			if inst == prop then
				return room
			end
		end 
	end
end

function InteriorSpawner:removeprefab(inst,interiorID)
	print("trying to remove",inst.prefab,interiorID)
	local interior = self.interiors[interiorID]
	if interior then
		for i, prop in ipairs(interior.object_list) do
			if prop == inst then
				print("REMOVING",prop.prefab)
				table.remove(interior.object_list, i)
				inst.interior = nil
				break
			end
		end
	end
end

function InteriorSpawner:injectprefab(inst,interiorID)
	local interior = self.interiors[interiorID]
	inst:RemoveFromScene(true)
	inst:AddTag("INTERIOR_LIMBO")
	inst.interior = interiorID
	table.insert(interior.object_list, inst)
end

-- almost the same as injectprefab but this goes to the dance of calling relevant events
function InteriorSpawner:AddPrefabToInterior(inst,destInterior)
	if destInterior then
		local interior = self.interiors[destInterior]
		if interior then
			-- add the new entity. The position should already be of an object in interior space
			self:PutPropIntoInteriorLimbo(inst,interior,true)
		end
	end
end

function InteriorSpawner:SwapPrefab(inst,replacement)
	if inst.interior then
		local interior = self.interiors[inst.interior]
		if interior then
			-- remove the old entity
			self:removeprefab(inst, inst.interior)
			self:AddPrefabToInterior(inst, destInterior)
		end
	end
end

function InteriorSpawner:OnSave()
	-- print("InteriorSpawner:OnSave")
	self:SanityCheck("Pre Save")

	local data =
	{ 
		interiors = {}, 
		doors = {}, 
		next_interior_ID = self.next_interior_ID, 	
		current_interior = self.current_interior and self.current_interior.unique_name or nil,
		player_homes = self.player_homes,
		--loaded_interiors = deepcopy(self.loaded_interiors),
		loaded_interiors = {},
		interior_players  = self.interior_players,
		-- interior_players = {},
	}	

	local refs = {}
	
	for k, room in pairs(self.interiors) do
		
		local prefabs = nil
		if room.prefabs then
			prefabs = {}
			for k, prefab in ipairs(room.prefabs) do
				local prefab_data = prefab
				table.insert(prefabs, prefab_data)
			end
		end

		local object_list = {}
		for k, object in ipairs(room.object_list) do
			local save_data = object.GUID
			table.insert(object_list, save_data)
			table.insert(refs, object.GUID)
		end

		local interior_data =
		{
			unique_name = k, 
			z = room.z, 
			x = room.x, 
			dungeon_name = room.dungeon_name,
			width = room.width, 
			height = room.height, 
			depth = room.depth, 
			object_list = object_list, 
			prefabs = prefabs,
			walltexture = room.walltexture,
			floortexture = room.floortexture,
			minimaptexture = room.minimaptexture,
			cityID = room.cityID,
			cc = room.cc,
			visited = room.visited,
			batted = room.batted,
			playerroom = room.playerroom,
			enigma = room.enigma,
			reverb = room.reverb,
			ambsnd = room.ambsnd,
			groundsound = room.groundsound,
			zoom = room.zoom,
			cameraoffset = room.cameraoffset,
			forceInteriorMinimap = room.forceInteriorMinimap,
		}

		table.insert(data.interiors, interior_data)		
	end

	for k, door in pairs(self.doors) do
		local door_data =
		{
			name = k, 
			my_interior_name = door.my_interior_name,
			target_interior = door.target_interior,
			secret = door.secret,
		}						
		if door.inst then
			door_data.inst_GUID = door.inst.GUID
			table.insert(refs, door.inst.GUID)
		end
		table.insert(data.doors, door_data)
	end
	
	for k, int in ipairs(self.loaded_interiors) do
		
		-- local prefabs = nil
		-- if int.prefabs then
			-- prefabs = {}
			-- for k, prefab in ipairs(int.prefabs) do
				-- local prefab_data = prefab
				-- table.insert(prefabs, prefab_data)
			-- end
		-- end

		-- print("About to save object data for loaded interiors...")
		-- local object_list = {}
		-- for k, object in ipairs(int.object_list) do
			-- local save_data = object.GUID
			-- table.insert(object_list, save_data)
			-- table.insert(refs, object.GUID)
		-- end
		-- print("Got object data, dump...")
		-- dumptable(object_list, 1, 1, nil, 0)
		-- print("For comparison, dumping real list:")
		-- dumptable(int.object_list, 1, 1, nil, 0)

		-- local interior_data =
		-- {
			-- unique_name = int.unique_name, 
			-- z = int.z, 
			-- x = int.x, 
			-- dungeon_name = int.dungeon_name,
			-- width = int.width, 
			-- height = int.height, 
			-- depth = int.depth, 
			-- object_list = {}, 
			-- -- object_list = object_list, 
			-- prefabs = prefabs,
			-- walltexture = int.walltexture,
			-- floortexture = int.floortexture,
			-- minimaptexture = int.minimaptexture,
			-- cityID = int.cityID,
			-- cc = int.cc,
			-- visited = int.visited,
			-- batted = int.batted,
			-- playerroom = int.playerroom,
			-- enigma = int.enigma,
			-- reverb = int.reverb,
			-- ambsnd = int.ambsnd,
			-- groundsound = int.groundsound,
			-- zoom = int.zoom,
			-- cameraoffset = int.cameraoffset,
			-- forceInteriorMinimap = int.forceInteriorMinimap,
			-- storage_offset = int.storage_offset,
		-- }
		
		local interior_data =
		{
			unique_name = int.interior_ref.unique_name,
			storage_offset = int.storage_offset,
		}
		print("DS - OnSave interior name gotten as:", interior_data.unique_name)

		table.insert(data.loaded_interiors, interior_data)		
		
	end
	
	--Store camera details 
	if TheCamera.interior_distance then
		data.interior_x = TheCamera.interior_currentpos.x
		data.interior_y = TheCamera.interior_currentpos.y
		data.interior_z = TheCamera.interior_currentpos.z
		data.interior_distance = TheCamera.interior_distance
	end
	
	data.prev_player_pos = {x = self.prev_player_pos_x, y = self.prev_player_pos_y, z = self.prev_player_pos_z}

	local x,y,z = self.interiorEntryPosition:Get()
	data.interiorEntryPosition = {x=x, y=y, z=z}
	return data, refs
end

function InteriorSpawner:OnLoad(data)
	print("Interior OnLoad ran")
	self.interiors = {}
	for k, int_data in ipairs(data.interiors) do		
		-- Create placeholder definitions with saved locations
		
		self.interiors[int_data.unique_name] =
		{ 
			unique_name = int_data.unique_name,
			z = int_data.z, 
			x = int_data.x, 
			dungeon_name = int_data.dungeon_name,
			width = int_data.width, 
			height = int_data.height,
			depth = int_data.depth,			
			object_list = {}, 
			prefabs = int_data.prefabs, 			
			walltexture = int_data.walltexture,
			floortexture = int_data.floortexture,
			minimaptexture = int_data.minimaptexture,
			cityID = int_data.cityID,
			cc = int_data.cc,
			visited = int_data.visited,
			batted = int_data.batted,
			playerroom = int_data.playerroom,
			enigma = int_data.enigma,
			reverb = int_data.reverb,
			ambsnd = int_data.ambsnd,
			groundsound = int_data.groundsound,
			zoom = int_data.zoom,
			cameraoffset = int_data.cameraoffset,
			forceInteriorMinimap = int_data.forceInteriorMinimap,
		}

		--self.interiors[int_data.unique_name].handle = createInteriorHandle(self.interiors[int_data.unique_name])

		-- if batcave, register with the batted component.
		if int_data.batted then
			if TheWorld.components.batted then
				TheWorld.components.batted:RegisterInterior(int_data.unique_name)
			end
		end
	end

	for k, door_data in ipairs(data.doors) do
		self.doors[door_data.name] =  { my_interior_name = door_data.my_interior_name, target_interior = door_data.target_interior, secret = door_data.secret } 			
	end	

	--TheWorld.components.colourcubemanager:SetInteriorColourCube(nil)
	
	-- player.replica.interiorplayer:RemoveColorCube()
	-- player.components.playervision:SetCustomCCTable(nil)

	if data.current_interior then
		self.current_interior = self:GetInteriorByName(data.current_interior)
		self:ConsiderPlayerInside(self.current_interior.unique_name)
		--TheWorld.components.colourcubemanager:SetInteriorColourCube( self.current_interior.cc )		
	end

	if data.loaded_interiors then
		for k, interior in pairs(data.loaded_interiors) do
			-- local interiorData = self:GetInteriorByName(interior.unique_name)
			-- self.current_interior = self:GetInteriorByName(data.loaded_interiors)
			-- self:ConsiderPlayerInside(self.current_interior.unique_name)
			--TheWorld.components.colourcubemanager:SetInteriorColourCube( self.current_interior.cc )	
			local data = {
				-- interior_ref = interiorData
				interior_ref = self:GetInteriorByName(interior.unique_name),
				storage_offset = interior.storage_offset,
			}
			table.insert(self.loaded_interiors, data)
		end
	end

	if data.prev_player_pos then
		self.prev_player_pos_x, self.prev_player_pos_y, self.prev_player_pos_z = data.prev_player_pos.x, data.prev_player_pos.y, data.prev_player_pos.z
	end
	if data.interiorEntryPosition then
		local vec = data.interiorEntryPosition
		self.interiorEntryPosition = Vector3(vec.x, vec.y, vec.z)
	end
	self.next_interior_ID = data.next_interior_ID
	
	if data.player_homes then
		self.player_homes = data.player_homes
	end
	
	-- if data.loaded_interiors then
		-- print ("OnLoad - Detected loaded interiors in data storage, retrieve...")
		-- self.loaded_interiors = data.loaded_interiors
		-- print("Interiors loaded, dumping...")
		-- dumptable(self.loaded_interior, 1, 1, nil, 0)
	-- else
		-- print("Didn't detect loaded interiors in save data, do nothing")
	-- end
	
	-- print("About to load the 'loaded interiors' list")
	-- self.loaded_interiors = {}
	-- for k, int_data in ipairs(data.loaded_interiors) do		
		-- print("Loading 'loaded interiors' list, iteration ", k)
		-- print("Dump data, for safety:")
		-- dumptable(int_data, 1, 1, nil, 0)
		-- -- Create placeholder definitions with saved locations
		-- -- self.loaded_interiors[int_data.unique_name] =
		
		-- -- print("About to try loading object list?")
		-- -- local object_list = {}
		-- -- for k, object in ipairs(int_data.object_list) do
			-- -- print("Iteration ",k,", object ",object)
			-- -- local load_data = object.GUID
			-- -- print("GUID stuff about to be inserted: ", load_data)
			-- -- table.insert(object_list, load_data)
			-- -- -- table.insert(refs, object.GUID)
		-- -- end
		
		-- local interiordata =
		-- { 
			-- unique_name = int_data.unique_name,
			-- z = int_data.z, 
			-- x = int_data.x, 
			-- dungeon_name = int_data.dungeon_name,
			-- width = int_data.width, 
			-- height = int_data.height,
			-- depth = int_data.depth,			
			-- object_list = {}, 
			-- -- object_list = object_list, 
			-- prefabs = int_data.prefabs, 			
			-- walltexture = int_data.walltexture,
			-- floortexture = int_data.floortexture,
			-- minimaptexture = int_data.minimaptexture,
			-- cityID = int_data.cityID,
			-- cc = int_data.cc,
			-- visited = int_data.visited,
			-- batted = int_data.batted,
			-- playerroom = int_data.playerroom,
			-- enigma = int_data.enigma,
			-- reverb = int_data.reverb,
			-- ambsnd = int_data.ambsnd,
			-- groundsound = int_data.groundsound,
			-- zoom = int_data.zoom,
			-- cameraoffset = int_data.cameraoffset,
			-- forceInteriorMinimap = int_data.forceInteriorMinimap,
			-- storage_offset = int_data.storage_offset,
		-- }
		-- print("Dump Loaded Interior data about to be inserted in to the real list:")
		-- dumptable(interiordata, 1, 1, nil, 0)
		-- -- print("Dump object list of interior data:")
		-- -- dumptable(interiordata.object_list, 1, 1, nil, 0)
		
		-- table.insert(self.loaded_interiors, interiordata)
	-- end
	print("All loaded interiors should have been fully loaded, dump it...")
	dumptable(self.loaded_interiors, 1, 1, nil, 0)
	
	
	if data.interior_players then
		print ("OnLoad - Detected interior players in data storage, retrieve...")
		self.interior_players = data.interior_players
		print("Player list loaded, dumping...")
		dumptable(self.interior_players, 1, 1, nil, 0)
	else
		print("Didn't detect loaded players in save data, do nothing")
	end
	
	--self.inst:DoTaskInTime(2, function() self:LoadPostPass(interior_definition) end)
end

function InteriorSpawner:CleanUpMessAroundOrigin()
	local function removeStray(ent)
		print("Removing stray "..ent.prefab)
		ent:Remove()
	end
	for i,v in pairs(Ents) do
		if v.Transform then
			local pos = v:GetPosition()
			if v.prefab == "window_round_light" and pos == Vector3(0,0,0) then
				removeStray(v)
			end
			if v.prefab == "window_round_light_backwall" and pos == Vector3(0,0,0) then
				removeStray(v)
			end
			if v.prefab == "home_prototyper" and v ~= self.homeprototyper then
				removeStray(v)
			end
		end
	end
end

function InteriorSpawner:LoadPostPass(ents, data)
	self:CleanUpMessAroundOrigin()

	self:RefreshDoorsNotInLimbo()

	-- fill the object list
	for k, room in pairs(data.interiors) do
		local interior = self:GetInteriorByName(room.unique_name)
		if interior then 
			for i, object in pairs(room.object_list) do
				if object and ents[object] then										
					local object_inst = ents[object].entity
					table.insert(interior.object_list, object_inst)	
					object_inst.interior = room.unique_name
				else
					print("*** Warning *** InteriorSpawner:LoadPostPass object "..tostring(object).." not found for interior "..interior.unique_name)
				end
			end
		else
			print("*** Warning *** InteriorSpawner:LoadPostPass Could not fetch interior "..room.unique_name)			
		end
	end

	-- fill the inst of the doors. 
	for k, door_data in pairs(data.doors) do
		if door_data.inst_GUID then		
			if 	ents[door_data.inst_GUID] then
				self.doors[door_data.name].inst =  ents[door_data.inst_GUID].entity 
			end
		end
	end

	-- DS - Fill the loaded interior object list with the data we just got
	-- In its current state, I'm probably just gonna mess up the table more than it already is
	-- for k, loadedroom in pairs(self.loaded_interiors) do
		-- local interior = self:GetInteriorByName(loadedroom.unique_name)
		-- if interior then 
			-- for i, object in pairs(interior.object_list) do
				-- if object and ents[object] then										
					-- local object_inst = ents[object].entity
					-- table.insert(loadedroom.object_list, object_inst)	
					-- object_inst.interior = loadedroom.unique_name
				-- else
					-- print("*** Warning *** InteriorSpawner:LoadPostPass object "..tostring(object).." not found for interior "..interior.unique_name)
				-- end
			-- end
		-- else
			-- print("*** Warning *** InteriorSpawner:LoadPostPass Could not fetch interior "..room.unique_name)			
		-- end
	-- end
	-- for k, loadedroom in pairs(self.loaded_interiors) do
		-- local interior = self:GetInteriorByName(loadedroom.unique_name)
		-- if interior then 
			-- self.loaded_interiors[k].object_list = interior.object_list
			-- print("DS - Tried to insert object list to loaded interior, dumping...")
			-- dumptable(self.loaded_interiors[k].object_list, 1, 1, nil, 0)
			-- print("DS - Dumping the interior...")
			-- dumptable(self.loaded_interiors[k], 1, 1, nil, 0)
			-- print("DS - Dumping the object list we tried to add:")
			-- dumptable(interior.object_list, 1, 1, nil, 0)
				-- -- if object and ents[object] then										
					-- -- local object_inst = ents[object].entity
					-- -- table.insert(loadedroom.object_list, object_inst)	
					-- -- object_inst.interior = loadedroom.unique_name
				-- -- else
					-- -- print("*** Warning *** InteriorSpawner:LoadPostPass object "..tostring(object).." not found for interior "..interior.unique_name)
				-- -- end
			-- -- end
		-- else
			-- print("*** Warning *** InteriorSpawner:LoadPostPass Could not fetch interior "..room.unique_name)			
		-- end
	-- end

	-- print("Interior Postload - Dumping data tables:")
	-- print("Dumping ents:")
	-- dumptable(ents, 1, 0, nil, 0)
	-- print("Dumping data:")
	-- dumptable(data, 1, 1, nil, 0)
	
	print("Dumping player list:")
	dumptable(AllPlayers, 1, 0, nil, 0)

	if data.interior_x then
		--local player = GetPlayer()
		local interior_pos = Vector3(data.interior_x, data.interior_y, data.interior_z)
		if self.spawnOriginDelta then
			interior_pos = interior_pos + self.spawnOriginDelta
		end
		if InteriorSpawner.deltaForSpawnOriginMigration then
			-- Again: this is horrific, see comment at InteriorSpawner.FixForSpawnOriginMigration
			interior_pos = interior_pos + InteriorSpawner.deltaForSpawnOriginMigration
		end

		--TheCamera.interior_currentpos = interior_pos
		--TheCamera.interior_distance = data.interior_distance
		--TheCamera:SetTarget(player)
	end

	if self.current_interior then		
		local pt_current = self:GetSpawnOrigin()
		local pt_dormant = self:GetSpawnStorage()
		--InteriorManager:SetCurrentCenterPos2d( pt_current.x, pt_current.z )
		--InteriorManager:SetDormantCenterPos2d( pt_dormant.x, pt_dormant.z )
		--TheWorld.Map:SetInterior( self.current_interior.handle )		
		-- ensure the interior is loaded
		self:ConfigureWalls(self.current_interior)
	end	

	self:SanityCheck("Post Load")

	self:CheckIfPlayerIsInside()
end

-- find the world entry points into dungeons. For multipe entries into one dungeon this is non-deterministic
function InteriorSpawner:CheckForInvalidSpawnOrigin()
	-- Trying to detect the issue with clouds in rooms/unplacable items
	local pt1 = self:GetSpawnOrigin()
	print("SpawnOrigin:",pt1,GetTileType(pt1))
	if (GetTileType(pt1) == "IMPASSABLE") then
		print("World has suspicious SpawnOrigin")
	end
end

function InteriorSpawner:ClampPosition(vec, origin, w, h)
	local work = Vector3(vec:Get())

	local dx = work.x - origin.x
	local dz = work.z - origin.z

	if dx > w then
		work.x = origin.x + w
	elseif dx < -w then
		work.x = origin.z - w
	end

	if dz > h then
		work.z = origin.z + h
	elseif dz < -h then
		work.z = origin.z - h
	end
	return work			
end

function InteriorSpawner:ConsiderPlayerInside(interior)
	self.considered_inside_interior[interior] = true
end

function InteriorSpawner:ConsiderPlayerNotInside(interior)
	self.considered_inside_interior[interior] = nil
end

function InteriorSpawner:InPlayerRoom()
    return self.current_interior and self.current_interior.playerroom or false
end


function InteriorSpawner:getOriginForInteriorInst(inst)
	-- it's either in interior storage or in interior spawn, return the right origin to work relative to
	local spawnStorage = self:GetSpawnStorage()
	local spawnOrigin = self:GetSpawnOrigin()

	local pos = inst:GetPosition()
	local storageDist = (pos - spawnStorage):Length()
	local spawnDist = (pos - spawnOrigin):Length()
	local origin = (storageDist < spawnDist) and spawnStorage or spawnOrigin
	return origin, pos
end

function InteriorSpawner:GetExitDirection(inst)
	local origin = self:getOriginForInteriorInst(inst)
	local position = inst:GetPosition()
	local delta = position - origin
	if math.abs(delta.x) > math.abs(delta.z) then
		-- north or south
		if delta.x > 0 then
			return "south"
		else
			return "north"
		end
	else
		-- east or west
		if delta.z < 0 then
			return "west"
		else
			return "east"
		end
	end

end

function InteriorSpawner:SetInteriorEntryPosition(doer, x,y,z)
	local id = doer.userid
	print ("Interior entry pos got player ID ", id)
	--self.interior_players
	self.interiorEntryPosition = Vector3(x,y,z)
end

return InteriorSpawner