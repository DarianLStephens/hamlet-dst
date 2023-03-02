local function ShouldWarp(inst, doer, ininterior)
	local recallmark = inst.components.recallmark
	local PlayerInInterior = doer.components.interiorplayer.interiormode
	local TargetInInterior = ininterior
	local x, y, z = nil
	
	-- While I'd kinda like you let you teleport through doors, you could easily trap yourself in or out of rooms permanently
	-- Maybe technically possible anyway, but this would utterly trivialize it
	-- Plus, the positional warp history is all in actual positions, which would be a nightmare to replace and update to support storing the interior
	-- Even now, it's a little jank because it remembers the position you were in with previous rooms, but we just kinda have to deal with it. Unless we can maybe erase the clock's previous positions when going between rooms?

	if recallmark ~= nil then
		x, y, z = recallmark.recall_x, recallmark.recall_y, recallmark.recall_z
	else
		x, y, z = doer.components.positionalwarp:GetHistoryPosition(false)
	end
	
	if PlayerInInterior then
		
		if not TargetInInterior then
			return false
		else
			local PlayerInterior = GetClosestInterior(doer:GetPosition())
			local TargetInterior = GetClosestInterior(Vector3(x, y, z))
			if not TargetInterior == PlayerInterior then
				print("DS - Backstep - Trying to teleport in to or out of an interior, disallowed")
				return false
			else
				return true
			end
		end
	else
		if not TargetInInterior then
			return true
		end
	end
	
end


local function Warp_DoCastSpell(inst, doer, target, pos)
	local tx, ty, tz = doer.components.positionalwarp:GetHistoryPosition(false)
	
	if tx ~= nil then
		local TargetInInterior = ((tx > 1800) == true and true) or false
		
		local suc = ShouldWarp(inst, doer, TargetInInterior)
		if suc then
			return inst.ActualSpell(inst, doer)
		else
			return suc
		end
	else
		return inst.ActualSpell(inst, doer) -- This should fail due to there being no warp points left, so I'll just let the usual stuff run in case a mod uses that.
	end
end

return function(inst)
	if not TheWorld.ismastersim then return end
	
	print("DS - Backstep - Tele overriding stuff")
	
	inst.ActualSpell = inst.components.pocketwatch.DoCastSpell -- Backup the old function
	inst.components.pocketwatch.DoCastSpell = Warp_DoCastSpell -- Run our override
end