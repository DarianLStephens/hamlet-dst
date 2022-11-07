local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)
HAMENV.AddSimPostInit(function()

	
	-- local _IsPassableAtPointWithPlatformRadiusBias = Map.IsPassableAtPointWithPlatformRadiusBias
	-- function Map:IsPassableAtPointWithPlatformRadiusBias(...)
		-- if TheWorld.components.interiorspawner.current_interior then
			-- return true
		-- else
			-- return _IsPassableAtPointWithPlatformRadiusBias(self, ...)
		-- end
	-- end
	
	local _GetTileCoordsAtPoint = Map.GetTileCoordsAtPoint
	function Map:GetTileCoordsAtPoint(x,y,z, ...)
		if x > 990 then
			x = 0
			y = 0
			z = 0
		end
		return _GetTileCoordsAtPoint(self, x,y,z, ...)
	end
	
	-- I have to override this, otherwise there are crashes with things like poop, the digamajig, or other farming-related stuff, because Klei doesn't null check it.
	local _GetTileCenterPoint = Map.GetTileCenterPoint
	function Map:GetTileCenterPoint(x,y,z, ...)
		--local x,y,z = pt:Get()
		if x > 990 then -- Gotta get as close as possible to the edge, without hitting the actual world
			--local newpos = Vector3(0,0,0)
			--return _GetTileCenterPoint(self, newpos, ...)
			--return (Vector3(0,0,0))
			-- Half suggested I make it return the original coordinates, but I'm not sure how well that will work.
			x = 0
			y = 0
			z = 0
		end
		return _GetTileCenterPoint(self, x,y,z, ...)
	end
	
	local _GetTileAtPoint = Map.GetTileAtPoint
	function Map:GetTileAtPoint(x, y, z, ...)
		---local arg = {...}
		---local x = arg[1]
		---local z = arg[3]
		--if x >= intx and z >= intz then -- Interior space, beginnings of multiplayer compat
		--local intx, inty, intz = TheWorld.components.interiorspawner:getSpawnOrigin():Get()
		if x >= 990 then
		--if TheWorld.components.interiorspawner.current_interior then
			--print("Interior - Forcing tile type to dirt on the inside")
			return WORLD_TILES.DIRT --GROUND.INTERIOR
			
		else
			return _GetTileAtPoint(self, x, y, z, ...)
		end
	end
	
	local _IsVisualGroundAtPoint = Map.IsVisualGroundAtPoint
	function Map:IsVisualGroundAtPoint(x, y, z, ...)
		-- local arg = {...}
		-- local x = arg[1]
		-- local z = arg[3]
		--local intx, inty, intz = TheWorld.components.interiorspawner:getSpawnOrigin():Get()
		--if x >= intx and z >= intz then
		if x >= 990 then
		--if TheWorld.components.interiorspawner.current_interior then
			return true
		else
			return _IsVisualGroundAtPoint(self, x, y, z, ...)
		end
	end
	
	-- looks for ground, when it finds a point, checks a radius around that point to make sure they're all ground as well
	-- (pathfinding isn't granular enough, and chamfered corners can return the tiletype they belong to, but technically player will be outside it)
	function Map:FindValidExitPoint(position, start_angle, radius, attempts, subradius)
		--print("FindWalkableOffset:")
		local theta = start_angle -- radians

		attempts = attempts or 8

		local attempt_angle = (2*PI)/attempts
		local tmp_angles = {}
		for i=0,attempts-1 do
			local a = i*attempt_angle
			if a > PI then
				a = a-(2*PI)
			end
			table.insert(tmp_angles, a)
		end

		-- Make the angles fan out from the original point
		local angles = {}
		for i=1,math.ceil(attempts/2) do
			table.insert(angles, tmp_angles[i])
			local other_end = #tmp_angles - (i-1)
			if other_end > i then
				table.insert(angles, tmp_angles[other_end])
			end
		end

		local test = function(offset)
			local run_point = position+offset
			local ground = GetWorld()
			local tile = ground.Map:GetTileAtPoint(run_point:Get())
			-- local tile = GetVisualTileType(run_point.x, run_point.y, run_point.z)
			-- if tile == GROUND.IMPASSABLE or tile == GROUND.OCEAN_SHORE or tile >= GROUND.UNDERGROUND or
			-- tile == GROUND.OCEAN_SHALLOW or tile == GROUND.OCEAN_MEDIUM or tile == GROUND.OCEAN_DEEP or
			-- tile == GROUND.OCEAN_CORAL or tile == GROUND.MANGROVE or tile == GROUND.OCEAN_CORAL_SHORE or
			-- tile == GROUND.MANGROVE_SHORE or tile == GROUND.OCEAN_SHIPGRAVEYARD or tile == GROUND.LILYPOND then
			if IsOceanTile(tile) then
				--print("\tfailed, unwalkable ground.")
				return false
			end

			for i, attempt in ipairs(angles) do
				local check_angle = theta + attempt
				if check_angle > 2*PI then check_angle = check_angle - 2*PI end

				local offset = Vector3(subradius * math.cos( check_angle ), 0, -subradius * math.sin( check_angle ))

				--print(string.format("    %2.2f", check_angle/DEGREES))
				local subtest = run_point+offset

				local tile = ground.Map:GetTileAtPoint(run_point:Get())
				-- local tile = GetVisualTileType(subtest.x, subtest.y, subtest.z)
				-- if tile == GROUND.IMPASSABLE or tile == GROUND.OCEAN_SHORE or tile >= GROUND.UNDERGROUND or
					-- tile == GROUND.OCEAN_SHALLOW or tile == GROUND.OCEAN_MEDIUM or tile == GROUND.OCEAN_DEEP or
					-- tile == GROUND.OCEAN_CORAL or tile == GROUND.MANGROVE or tile == GROUND.OCEAN_CORAL_SHORE or
					-- tile == GROUND.MANGROVE_SHORE or tile == GROUND.OCEAN_SHIPGRAVEYARD or tile == GROUND.LILYPOND then
					--print("\tfailed, unwalkable ground.")
				if IsOceanTile(tile) then
					return false
				end
			end

			return true

		end

		return FindValidPositionByFan(start_angle, radius, attempts, test)
	end

end)
