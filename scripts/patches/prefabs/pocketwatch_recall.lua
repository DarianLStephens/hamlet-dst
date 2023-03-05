-- Needed to copy this from the original pocketwatch
local function DelayedMarkTalker(player)
	-- if the player starts moving right away then we can skip this
	if player.sg == nil or player.sg:HasStateTag("idle") then 
		player.components.talker:Say(GetString(player, "ANNOUNCE_POCKETWATCH_MARK"))
	end 
end

local function Recall_DoCastSpell(inst, doer, target, pos)
	local recallmark = inst.components.recallmark
	
	print("DS - TP - PWR - New recall function going")
	-- local interior = doer.interior
	
	local px,py,pz = doer.Transform:GetWorldPosition()
	-- local nearestInterior = GetClosestInterior(Vector3(px,py,pz), true)
	local nearestInterior = GetClosestInterior(Vector3(px,py,pz))
	local interior = nearestInterior
	-- if nearestInterior then
		-- interior = nearestInterior.interiornum
	-- end
	print("Recall mark, caster interior = ", interior)
	print("Dumping ClosestInterior table:")
	dumptable(nearestInterior, 1, 1, nil, 0)
	
	print("Trying to get the interior any way I can.")
	print("inst = ", inst)
	print("doer = ", doer)
	local playerInterior = doer.components.interiorplayer.roomid
	print("roomID of interiorplayer component: ", playerInterior)
	if playerInterior == "unknown" then
		print("Player interior is 'unknown', can't retrieve")
	else
		local interiorByName = TheWorld.components.interiorspawner:GetInteriorByName(playerInterior)
		print("Interior by name = ", interiorByName)
		local uniqueInteriorName = interiorByName.unique_name
		print("Unique name: ", uniqueInteriorName)
	end
	if nearestInterior then
		local wallName = nearestInterior.name:value()
		print("Wall name: ", wallName)
	end
	
	local finalInterior = playerInterior
	print("Final interior value: ", finalInterior)

	if recallmark:IsMarked() then
		if Shard_IsWorldAvailable(recallmark.recall_worldid) then
		
			if (recallmark.recall_x >= 1800) and (recallmark.interior) then
			
				inst.components.rechargeable:Discharge(TUNING.POCKETWATCH_RECALL_COOLDOWN)

				doer.sg.statemem.warpback = {dest_worldid = recallmark.recall_worldid, dest_x = recallmark.recall_x, dest_y = 0, dest_z = recallmark.recall_z, target = recallmark, warptype = "recall", interior = recallmark.interior, reset_warp = true}
				return true
			else
				-- The mark was placed in interior space, but the interior wasn't saved for some reason. Avoid teleporting
				return false
			end
		else
			return false, "SHARD_UNAVAILABLE"
		end
	else -- Need to replace the whole thing after all, to pass the interior to the recall point, I guess
		local x, y, z = doer.Transform:GetWorldPosition()
		inst.components.recallmark:MarkPosition(x, y, z, nil, finalInterior)
		inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/MarkPosition")

		doer:DoTaskInTime(12 * FRAMES, DelayedMarkTalker) 

		return true
	end
	-- else
		-- return inst.ActualSpell(inst, doer) -- If there was no mark set, leave it do its usual thing.
	-- end
end

return function(inst)
	if not TheWorld.ismastersim then return end -- Do not run on client

	inst.ActualSpell = inst.components.pocketwatch.DoCastSpell -- Backup the old function
	inst.components.pocketwatch.DoCastSpell = Recall_DoCastSpell -- Run our override

end