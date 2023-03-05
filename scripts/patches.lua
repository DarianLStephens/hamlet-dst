local GenericPlayerFn = require("patches/prefabs/player")
local SimFn = require("patches/sim")
local CamFn = require("patches/camera")
local unpack = _G.unpack

local PATCHES = 
{
	COMPONENTS = {
		"inventoryitem",
		"birdspawner",
		"playercontroller",
		"ambientsound",
		"dynamicmusic",
		"playervision",
		"frograin",
		"hounded",
		"kramped",
		"sheltered",
		"recallmark",
	},
	
	PREFABS = {
		world = "world",
		player_classified = "player_classified",
		telestaff = "telestaff",
		pocketwatch_warp = "pocketwatch_warp",
		pocketwatch_recall = "pocketwatch_recall",
	},
	
	SCREENS = {
	},

	WIDGETS = {
		"redux/craftingmenu_widget",	
		"redux/craftingmenu_hud",	
	},

	STATEGRAPHS = { --To patch existing states
		--"SGwilson", 
	},
	STATES = {--To add new states
		"wilson", 
		"wilson_client", 
	},
}

local function patch(prefab, fn)
	AddPrefabPostInit(prefab, fn)
end
	
for path, data in pairs(PATCHES.PREFABS) do
	local fn = require("patches/prefabs/"..path)
	
	if type(data) == "string" then
		patch(data, function(inst) fn(inst, data) end)
	else
		for _, pref in ipairs(data) do
			patch(pref, function(inst) fn(inst, pref) end)
		end
	end
end

AddPlayerPostInit(GenericPlayerFn)
AddSimPostInit(SimFn)
AddClassPostConstruct("cameras/followcamera", CamFn)

for _, name in ipairs(PATCHES.STATEGRAPHS) do
	AddStategraphPostInit(name, require("patches/stategraphs/"..name))
end

for _, file in ipairs(PATCHES.STATES) do
	local states = require("patches/states/"..file)
	for i, state in ipairs(states) do
		AddStategraphState(file, state)
	end
end

for _, file in ipairs(PATCHES.COMPONENTS) do
	local fn = require("patches/components/"..file)
	AddComponentPostInit(file, fn)
end

for _, file in ipairs(PATCHES.SCREENS) do
	local fn = require("patches/screens/"..file)
	AddClassPostConstruct("screens/"..file, fn)
end

for _, file in ipairs(PATCHES.WIDGETS) do
	local fn = require("patches/widgets/"..file)
	AddClassPostConstruct("widgets/"..file, fn)
end

function EntityScript:Teleport(EntityOrPosition, instant, interior_override)
	print("DS - TP - Starting entityscript interior-accounting teleportation...")
	local px,py,pz = self.Transform:GetWorldPosition()
	print("originating point:",px,py,pz)
	
	print("DS - ES TP - Recieved data. EorP: ", EntityOrPosition, "instant: ", instant)
	print("DS - ES TP - Interior override: ", interior_override)

	-- is the entity in an interior
	-- is the destination in an interior
	-- special case - are we the player? then we may need a transition
	local loctarget
	local t_loc
	if EntityOrPosition:is_a(Vector3) then
		t_loc = EntityOrPosition
	else
		loctarget = EntityOrPosition
        t_loc = loctarget:GetPosition()
	end
	
	print("Tested for location: ", t_loc)

	local sourceInterior = self.interior
	if not sourceInterior then
		print("DS - TP - No source interior specified, do special stuff")
	    -- local tile = TheWorld.Map:GetTileAtPoint(px,py,pz)
		-- local sourceInInterior = (tile == WORLD_TILES.INTERIOR)
		-- local sourceInInterior = ()
		-- if the object is in an interior but doesn't have an interior set then it must be in the current interior
		-- if sourceInInterior then
		   	-- local interiorSpawner = TheWorld.components.interiorspawner
			-- sourceInterior = interiorSpawner.current_interior and interiorSpawner.current_interior.unique_name
			
			-- local nearestInterior = GetClosestInterior(Vector3(px,py,pz))
			-- if nearestInterior then sourceInterior = nearestInterior.interiornum end
			sourceInterior = GetClosestInterior(Vector3(px,py,pz))
		-- end
	else
		print("DS - TP - Source was in interior, we know where it's from")
	end

	local destInterior = (loctarget and loctarget.interior) or interior_override
	if not destInterior then
		print("Couldn't find destination interior, do... other stuff, I guess?")
	    local tile = GetWorld().Map:GetTileAtPoint(t_loc.x,t_loc.y,t_loc.z)
		local destInInterior = (tile == WORLD_TILES.INTERIOR)
		-- if the object is in an interior but doesn't have an interior set then it must be in the current interior
		-- technically for a point (rather than an entity) this logic would not work, but then we'd have no way to discern the interior either
		if destInInterior then
			print("Destination is in interior tile space")
			-- I guess this is meant to do something? A fallback? It can't work like this now, though, and doesn't even make sense. We're not teleporting FROM an interior in this case; there isn't even one loaded.
		   	local interiorSpawner = TheWorld.components.interiorspawner
			-- destInterior = interiorSpawner.current_interior.unique_name
		end
	else
		print("Target has interior, ", destInterior)
	end


	-- if self == GetPlayer() then
	if self:HasTag("player") then
		print("DS - TP - The player is teleporting, do the stuff")
	    local snapcam = true
    	if loctarget then
			print("DS - TP - The player is going to a specific target?")
        	-- if TheCamera.interior or loctarget.interior then
        	if self.components.interiorplayer.interiormode or loctarget.interior then
            	-- local interiorSpawner = GetWorld().components.interiorspawner
	            -- interiorSpawner:PlayTransition(GetPlayer(), nil, destInterior, loctarget, true)   
            	local interiorSpawner = TheWorld.components.interiorspawner
	            interiorSpawner:PlayTransition(self, loctarget, destInterior, loctarget, true)   
    	        snapcam = false
	        end
			-- re-grab the position, the target may have come out of interior storage
			t_loc = loctarget:GetPosition()
	    else
			local intFailure
			if t_loc then
				if destInterior ~= "unknown" then
					print("Got a teleport location and destination interior, do the interior transition")
					print("Location: ", t_loc, "Dest interior: ", destInterior)
					local interiorSpawner = TheWorld.components.interiorspawner
					interiorSpawner:PlayTransition(self, loctarget, destInterior, t_loc, true)   
					snapcam = false
				else
					print("destInterior's check failed")
					intFailure = true
				end
			else
				print("t_loc's check failed")
				intFailure = true
			end

			if intFailure then
				print("DS - TP - Gotta take the player outside, I believe")
				print("This means t_loc of ", t_loc, " is nil, or destInterior of ", destInterior, " is the string 'unknown'")
				print("DS - TP - Their interior mode: ", self.components.interiorplayer.interiormode)
				-- we may have to transition outside if we're currently inside
				-- if TheCamera.interior and t_loc then
				if self.components.interiorplayer.interiormode and t_loc then
					-- local interiorSpawner = GetWorld().components.interiorspawner
					-- interiorSpawner:PlayTransition(GetPlayer(), nil, nil, t_loc, true)   
					local interiorSpawner = TheWorld.components.interiorspawner
					interiorSpawner:PlayTransition(self, nil, nil, t_loc, true)  
					snapcam = false
				end
			end
	    end

	    self.Transform:SetPosition(t_loc.x, 0, t_loc.z)

	    if snapcam then
    	    -- TheCamera:Snap()
			if not instant then
	        	-- TheFrontEnd:DoFadeIn(1)
		        -- Sleep(1)
			end
    	end
	else
	   	local interiorSpawner = TheWorld.components.interiorspawner
	    self.Transform:SetPosition(t_loc.x, 0, t_loc.z)
		if sourceInterior then
			-- remove us from the source room
			if interiorSpawner.current_interior and sourceInterior == interiorSpawner.current_interior.unique_name then
				-- nothing to do. The object is moved
			else
				interiorSpawner:removeprefab(self,sourceInterior)
				interiorSpawner:ReturnItemToScene(self)
			end
		end
		if destInterior then
			-- add us to the dest room
		   	if interiorSpawner.current_interior and destInterior == interiorSpawner.current_interior.unique_name then
				-- nothing to do, we're moved
			else
				interiorSpawner:injectprefab(self,destInterior)
			end
		end
	end
end

-- local PhysicsTable = {}

-- local _AddPhysics = Entity.AddPhysics
-- function Entity:AddPhysics(...)
	-- print("Entity added physics: ", self)
	-- print("Attempting to retrieve prefab...")
	-- local guid = self:GetGUID()
	-- local inst = Ents[guid]
	-- print("Retrieved? ", inst)
	
	-- -- if inst:HasTag("player") then
		-- -- print("Detected player added physics!")
	-- -- end
	
	
	-- -- print("Dumping entity table to know what's what:")
	-- -- dumptable(self, 1, 1, nil, 0)
	-- local rets = {_AddPhysics(self, ...)}
	-- print("Got 'rets'?", rets)
	-- dumptable(rets, 1, 1, nil, 0)
	-- -- local phys = rets[1]
	-- -- PhysicsTable[phys] = inst
	-- PhysicsTable[rets[1]] = inst
	-- print("Added physics to association table? Dumping...")
	-- -- dumptable(PhysicsTable, 1, 1, nil, 0)
	-- return unpack(rets) -- _AddPhysics(self, ...)
-- end

local function round(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end

local _GetPosition = EntityScript.GetPosition

-- function EntityScript:GetPosition(...)
	-- -- print("GetPosition, self: ", self)
	-- local pos = _GetPosition(self, ...)
	-- local myinterior = self.interior
	-- if myinterior then
		-- print("GetPosition self", self, "has interior: ", myinterior)
		-- print("Got pos: ", pos)
		-- local ByName = TheWorld.components.interiorspawner:GetInteriorByName(myinterior)
		-- print("Interior by name: ", ByName)
	-- end
	-- return pos
-- end

-- local _Teleport = Physics.Teleport
-- function Physics:Teleport(destx, desty, destz, ...)
	-- print("Hooked teleport go!")
	
	-- destx = round(destx, 1)
	-- desty = round(desty, 1)
	-- destz = round(destz, 1)
	
	-- local TeleEnt = PhysicsTable[self]
	-- if TeleEnt then
		-- print("Teleporting entity: ", TeleEnt)
	-- else
		-- print("Couldn't associate physics with entity!")
	-- end
	
	-- local destvector = Vector3(destx, desty, destz)
	-- -- print("Intended destination: ", destx, desty, destz)
	-- print("Intended destination: ", destvector)
	
	-- local interiorSpawner = TheWorld.components.interiorspawner
	
	-- local interior = GetClosestInterior(destvector)
	-- if interior then
		-- print("DS - TP Object is teleporting to a loaded interior, no problem")
		-- -- We're going to an already-loaded interior, all's good. If this is a player, then maybe update their camera, but otherwise it's fine; we'll get added to the interior when it unloads
	-- else
		-- print("Need to check if entity is going to interior space...")
		-- if TeleEnt then
			-- -- Need to do some yucky all-ent loop to find a match, otherwise this doesn't work because we don't have a way to tell what interior it's going to
			-- for i,v in pairs(Ents) do
				-- if v.Transform then
					-- local pos = v:GetPosition()
					
					-- local posx, posy, posz = pos.x, pos.y, pos.z
					
					-- posx = round(posx, 1)
					-- posy = round(posy, 1)
					-- posz = round(posz, 1)
					
					-- pos = Vector3(posx, posy, posz)
					
					-- -- print("Looped object ", v, " pos: ", pos)
					-- if pos.x == destvector.x and pos.z == destvector.z then
						-- print("Looped object's position is equal to teleport destination, should be in interior?")
						-- if v.interior then
							-- if TeleEnt:HasTag("player") then
								-- print("DS - TP - Detected player teleporting to interior, load it")
								-- interiorSpawner:PlayTransition(self, nil, v.interior, destvector, true) 
							-- else
								-- print("DS - TP - Detected non-player teleported to unloaded interior, add to object list")
								-- interiorSpawner:injectprefab(self,interior)
							-- end
							-- break -- Break on both, because we found the target
						-- end
					-- end
				-- end
			-- end
		-- else
			-- print("Cannot detect entity, can't do interior association")
		-- end
	-- end
    -- _Teleport(self, destx, desty, destz, ...)
-- end

EmitterManager._updatefuncs = {snow = nil, rain = nil, pollen = nil}
local _PostUpdate = EmitterManager.PostUpdate
local function PostUpdate(self,...)
	for inst, data in pairs( self.awakeEmitters.infiniteLifetimes ) do
		if inst.prefab == "pollen" or inst.prefab == "snow" or inst.prefab == "rain" then
			if not self._updatefuncs[inst.prefab] then
				self._updatefuncs[inst.prefab] = data.updateFunc
			end
			local x,y,z = inst.Transform:GetWorldPosition()
			if x > 1800 then
				data.updateFunc = function() end 
			else
				data.updateFunc = self._updatefuncs[inst.prefab] and self._updatefuncs[inst.prefab] or function() end
			end
		end
	end
	if _PostUpdate then
		return _PostUpdate(self,...)
	end
end
EmitterManager.PostUpdate = PostUpdate

local _PlayFootstep = _G.PlayFootstep
function _G.PlayFootstep(inst, volume, ispredicted, ...)
	local sound = inst.SoundEmitter
	if sound then
		local size_inst = inst
        if inst:HasTag("player") then
            local rider = inst.components.rider or inst.replica.rider
            if rider  and rider:IsRiding() then
                size_inst = rider:GetMount() or inst
            end
        end
		local x,y,z = inst.Transform:GetWorldPosition()
		local groundsound = inst.replica.interiorplayer and inst.replica.interiorplayer:GetGroundSound()--GetClosestInterior(inst)
		
		if TheWorld.components.interiorspawner then
			-- local dungeon, unique = TheWorld.Map:GetInteriorAtPoint(x,y,z)
			-- local data = TheWorld.components.interiorspawner:GetInteriorsByDungeonName()
			local data = TheWorld.components.interiorspawner:GetInteriorsByDungeonName(TheWorld.Map:GetInteriorAtPoint(x,y,z))
			-- groundsound = data and data[1].groundsound -- This is crashing the server now. Why?
		end

		if not groundsound  then
			return _PlayFootstep(inst, volume, ispredicted, ...)
		end
		groundsound = groundsound == "STONE" and "dirt" or groundsound
		sound:PlaySound(
			(inst.sg and inst.sg:HasStateTag("running") and "dontstarve/movement/run_"..groundsound or "dontstarve/movement/walk_"..groundsound
			)..
			(   (size_inst:HasTag("smallcreature") and "_small") or
				(size_inst:HasTag("largecreature") and "_large" or "")
			),
			nil,
			volume or 1,
			ispredicted)	
	end
end

local _MakeSnowCovered = _G.MakeSnowCovered
function _G.MakeSnowCovered(inst)
	inst:DoTaskInTime(0, function()
		-- local interior = GetClosestInterior(inst)
		local interior = GetClosestInterior(inst:GetPosition())
		if interior then
			inst.AnimState:Hide("snow")
			return
		end
		return _MakeSnowCovered(inst)
	end)
end

AddGlobalClassPostConstruct("recipe", "Recipe", function(self, name, ingredients, tab, level, placer_or_more_data, ...)
	self.wallitem = placer_or_more_data.wallitem
	self.decor = placer_or_more_data.decor
	self.flipable = placer_or_more_data.flipable
end)

local function BuildMesh(vertices, height)
    local triangles = {}
    local y0 = 0
    local y1 = height
 
    local idx0 = #vertices
    for idx1 = 1, #vertices do
        local x0, z0 = vertices[idx0].x, vertices[idx0].z
        local x1, z1 = vertices[idx1].x, vertices[idx1].z
 
        table.insert(triangles, x0)
        table.insert(triangles, y0)
        table.insert(triangles, z0)
 
        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)
 
        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)
 
        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)
 
        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)
 
        table.insert(triangles, x1)
        table.insert(triangles, y1)
        table.insert(triangles, z1)
 
        idx0 = idx1
    end
    return triangles
end

--Physics
Physics.SetRectangle = function(self, depth, height, width)-- Ported from "engine" :D
	local vertexes = {
		Vector3(width, 0, -depth),
		Vector3(-width, 0, -depth),
		Vector3(-width, 0, depth),
		Vector3(width, 0, depth),
	}
	self:SetTriangleMesh(BuildMesh(vertexes, height))
end
