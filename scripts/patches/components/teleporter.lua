return function(self)


local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function NoPlayersOrHoles(pt)
    return not (IsAnyPlayerInRange(pt.x, 0, pt.z, 2) or TheWorld.Map:IsPointNearHole(pt))
end

function self:Teleport(obj)
    if self.targetTeleporter ~= nil then
        local target_x, target_y, target_z = self.targetTeleporter.Transform:GetWorldPosition()
        local offset = self.targetTeleporter.components.teleporter ~= nil and self.targetTeleporter.components.teleporter.offset or 0
		
		local target_interior = self.targetTeleporter.interior_target
		print("Teleporter getting interior target of the target teleporter as: ", target_interior)

        local is_aquatic = obj.components.locomotor ~= nil and obj.components.locomotor:IsAquatic()
		local allow_ocean = is_aquatic or obj.components.amphibiouscreature ~= nil or obj.components.drownable ~= nil

		if self.targetTeleporter.components.teleporter ~= nil and self.targetTeleporter.components.teleporter.trynooffset then
            local pt = Vector3(target_x, target_y, target_z)
			if FindWalkableOffset(pt, 0, 0, 1, true, false, NoPlayersOrHoles, allow_ocean) ~= nil then
				offset = 0
			end
		end

        if offset ~= 0 then
            local pt = Vector3(target_x, target_y, target_z)
            local angle = math.random() * 2 * PI

            if not is_aquatic then
                offset =
                    FindWalkableOffset(pt, angle, offset, 8, true, false, NoPlayersOrHoles, allow_ocean) or
                    FindWalkableOffset(pt, angle, offset * .5, 6, true, false, NoPlayersOrHoles, allow_ocean) or
                    FindWalkableOffset(pt, angle, offset, 8, true, false, NoHoles, allow_ocean) or
                    FindWalkableOffset(pt, angle, offset * .5, 6, true, false, NoHoles, allow_ocean)
            else
                offset =
                    FindSwimmableOffset(pt, angle, offset, 8, true, false, NoPlayersOrHoles) or
                    FindSwimmableOffset(pt, angle, offset * .5, 6, true, false, NoPlayersOrHoles) or
                    FindSwimmableOffset(pt, angle, offset, 8, true, false, NoHoles) or
                    FindSwimmableOffset(pt, angle, offset * .5, 6, true, false, NoHoles)
            end

            if offset ~= nil then
                target_x = target_x + offset.x
                target_z = target_z + offset.z
            end
        end

        local ocean_at_point = TheWorld.Map:IsOceanAtPoint(target_x, target_y, target_z, false)
        if ocean_at_point then
			if not allow_ocean then
				local terrestrial = obj.components.locomotor ~= nil and obj.components.locomotor:IsTerrestrial()
				if terrestrial then
					return
				end
			end
        else
            if is_aquatic then
                return
            end
        end

        if obj.Physics ~= nil then
			if obj:HasTag("player") then
				obj:Teleport(Vector3(target_x, target_y, target_z), nil, target_interior) -- Forgot the nil, HAH
			else
				obj.Physics:Teleport(target_x, target_y, target_z)
			end
        elseif obj.Transform ~= nil then
            obj.Transform:SetPosition(target_x, target_y, target_z)
        end
    end
end

end