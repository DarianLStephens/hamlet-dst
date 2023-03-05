

local function Interior_SpawnExit(inst, doer, worldid, x, y, z, recallInterior)
	print("DS - PortalWatch Exit - Edited SpawnExit running, with data:")
	print("doer = ", doer, "worldid = ", worldid, "x:", x, "y:",y,"z:",z,"recallInterior:",recallInterior)
	if worldid ~= nil and worldid ~= TheShard:GetShardId() then
		inst.components.teleporter:MigrationTarget(worldid, x, y, z)
	else
		local exit = SpawnPrefab("pocketwatch_portal_exit")
		exit.Transform:SetPosition(x, y, z)
		
		-- local playerInterior = doer.components.interiorplayer.roomid
		-- print("DS - Portal Watch - roomID of interiorplayer component: ", playerInterior)
		-- local closestInterior = 
		
		local interior = recallInterior
		print("Rift portal target interior is ", recallInterior)
		
		exit.interior_target = recallInterior
		print("Set exit's interior target to: ", exit.interior_target)

		inst.components.teleporter:Target(exit)

		-- if one is removed, then shutdown the other
		inst:ListenForEvent("onremove", function() if inst:IsValid() then inst.components.teleporter:Target(nil) end end, exit) -- if the exit is removed, then shutdown the entrance
		exit:ListenForEvent("onremove", function() CloseExit(exit) end, inst) -- if the entance is removed, then shutdown the entrance
	end

    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/portal_LP", "loop")
end

return function(inst)
	if not TheWorld.ismastersim then return end -- Do not run on client

	inst.OldSpawnExit = inst.SpawnExit -- Backup the old function
	inst.SpawnExit = Interior_SpawnExit -- Run our override

end