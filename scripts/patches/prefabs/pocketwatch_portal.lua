
local NOTENTCHECK_CANT_TAGS = { "FX", "INLIMBO" }

local function noentcheckfn(pt)
    return not TheWorld.Map:IsPointNearHole(pt) and #TheSim:FindEntities(pt.x, pt.y, pt.z, 1, nil, NOTENTCHECK_CANT_TAGS) == 0
end

local function Portal_DoCastSpell(inst, doer, target, pos)
	print("DS - PortalWatch - New spell cast running")
	local recallmark = inst.components.recallmark

	if recallmark:IsMarked() then
		local pt = inst:GetPosition()
		local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 3 + math.random(), 16, false, true, noentcheckfn, true, true)
						or FindWalkableOffset(pt, math.random() * 2 * PI, 5 + math.random(), 16, false, true, noentcheckfn, true, true)
						or FindWalkableOffset(pt, math.random() * 2 * PI, 7 + math.random(), 16, false, true, noentcheckfn, true, true)
		if offset ~= nil then
			pt = pt + offset
		end

		if not Shard_IsWorldAvailable(recallmark.recall_worldid) then
			return false, "SHARD_UNAVAILABLE"
		end

		local portal = SpawnPrefab("pocketwatch_portal_entrance")
		portal.Transform:SetPosition(pt:Get())
		portal:SpawnExit(doer, recallmark.recall_worldid, recallmark.recall_x, recallmark.recall_y, recallmark.recall_z, recallmark.interior)
		inst.SoundEmitter:PlaySound("wanda1/wanda/portal_entrance_pre")

        local new_watch = SpawnPrefab("pocketwatch_recall")
		new_watch.components.recallmark:Copy(inst)

		local x, y, z = inst.Transform:GetWorldPosition()
        new_watch.Transform:SetPosition(x, y, z)
		new_watch.components.rechargeable:Discharge(TUNING.POCKETWATCH_RECALL_COOLDOWN)

        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
        if holder ~= nil then
            local slot = holder:GetItemSlot(inst)
            inst:Remove()
            holder:GiveItem(new_watch, slot, Vector3(x, y, z))
        else
            inst:Remove()
        end

		return true
	else
		local x, y, z = doer.Transform:GetWorldPosition()
		recallmark:MarkPosition(x, y, z)
		inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/MarkPosition")

		doer:DoTaskInTime(12 * FRAMES, DelayedMarkTalker) 

		return true
	end
end


return function(inst)
	if not TheWorld.ismastersim then return end -- Do not run on client

	inst.ActualSpell = inst.components.pocketwatch.DoCastSpell -- Backup the old function
	inst.components.pocketwatch.DoCastSpell = Portal_DoCastSpell -- Run our override

end