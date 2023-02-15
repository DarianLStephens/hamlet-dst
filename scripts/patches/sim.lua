local PLACE_OFFSET = 6
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

return function()
	local _GetTile = Map.GetTile
	function Map:GetTile(tilex, tiley, ...)
		local w, h = self:GetSize()
		if tilex > w then
			return WORLD_TILES.INTERIOR
		end
		
		return _GetTile(self, tilex, tiley, ...)
	end
	
	local _GetTileAtPoint = Map.GetTileAtPoint
	function Map:GetTileAtPoint(x, y, z, ...)
		if x >= 1800 then
			return WORLD_TILES.INTERIOR
		end
		
		return _GetTileAtPoint(self, x, y, z, ...)
	end
	
	local _IsVisualGroundAtPoint = Map.IsVisualGroundAtPoint
	function Map:IsVisualGroundAtPoint(x, y, z, ...)
		if x >= 1800 then
			return true
		end
		
		return _IsVisualGroundAtPoint(self, x, y, z, ...)
	end

	local _GetTileCenterPoint =	Map.GetTileCenterPoint
	function Map:GetTileCenterPoint(x, y, z)
			if x and  x > 1800 then
			return math.floor(x/4)*4+ 2,0,math.floor(z/4)*4 + 2
		end
		if z then
			return _GetTileCenterPoint(self, x, y, z)
		else
			return _GetTileCenterPoint(self, x, y)
		end
	end

	local _CanDeployRecipeAtPoint =	Map.CanDeployRecipeAtPoint
	function Map:CanDeployRecipeAtPoint(pt, recipe, rot, ...)
        local interior = ThePlayer and ThePlayer.replica.interiorplayer
        if interior and interior.interiormode:value() and not recipe.wallitem then
            local width = interior.interiorwidth:value()
            local depth = interior.interiordepth:value()
            local originpt = {x = interior.camx:value(), z = interior.camz:value()}
            local dMax = originpt.x + (depth + (PLACE_OFFSET-1))/2
            local dMin = originpt.x - (depth - (PLACE_OFFSET-1))/2 

			local wMax = originpt.z + width/2
			local wMin = originpt.z - width/2 
			
			local dist = 1

			if pt.x < dMin+dist or pt.x > dMax -dist or pt.z < wMin+dist or pt.z > wMax-dist then
				return false
			end
		end
		if recipe.decor then
            return true
		end
		return _CanDeployRecipeAtPoint(self, pt, recipe, rot, ...)
	end
	
	-- looks for ground, when it finds a point, checks a radius around that point to make sure they're all ground as well
	-- (pathfinding isn't granular enough, and chamfered corners can return the tiletype they belong to, but technically player will be outside it)
	function Map:FindValidExitPoint(position, start_angle, radius, attempts, subradius)
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
			if IsOceanTile(tile) then
				return false
			end

			for i, attempt in ipairs(angles) do
				local check_angle = theta + attempt
				if check_angle > 2*PI then check_angle = check_angle - 2*PI end

				local offset = Vector3(subradius * math.cos( check_angle ), 0, -subradius * math.sin( check_angle ))
				local subtest = run_point+offset

				local tile = ground.Map:GetTileAtPoint(run_point:Get())
				if IsOceanTile(tile) then
					return false
				end
			end

			return true

		end

		return FindValidPositionByFan(start_angle, radius, attempts, test)
	end
	Physics.SetRectangle = function(self, depth, height, width)-- Ported from "engine" :D
		local vertexes = {
			Vector3(width, 0, -depth),
			Vector3(-width, 0, -depth),
			Vector3(-width, 0, depth),
			Vector3(width, 0, depth),
		}
		self:SetTriangleMesh(BuildMesh(vertexes, height))
	end
end
