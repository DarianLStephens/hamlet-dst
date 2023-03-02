-- local HAMENV = env
-- _G.setfenv(1, GLOBAL)

local function teleport_end(teleportee, locpos, loctarget, staff)
    if loctarget ~= nil and loctarget:IsValid() and loctarget.onteleto ~= nil then
        loctarget:onteleto()
    end

    if teleportee.components.inventory ~= nil and teleportee.components.inventory:IsHeavyLifting() then
        teleportee.components.inventory:DropItem(
            teleportee.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end

    --#v2c hacky way to prevent lightning from igniting us
    local preventburning = teleportee.components.burnable ~= nil and not teleportee.components.burnable.burning
    if preventburning then
        teleportee.components.burnable.burning = true
    end
    TheWorld:PushEvent("ms_sendlightningstrike", locpos)
    if preventburning then
        teleportee.components.burnable.burning = false
    end

    if teleportee:HasTag("player") then
        teleportee.sg.statemem.teleport_task = nil
        teleportee.sg:GoToState(teleportee:HasTag("playerghost") and "appear" or "wakeup")
        teleportee.SoundEmitter:PlaySound(staff.skin_castsound or "dontstarve/common/staffteleport")
    else
        teleportee:Show()
        if teleportee.DynamicShadow ~= nil then
            teleportee.DynamicShadow:Enable(true)
        end
        if teleportee.components.health ~= nil then
            teleportee.components.health:SetInvincible(false)
        end
        teleportee:PushEvent("teleported")
    end
end

local function teleport_continue(teleportee, locpos, loctarget, staff)
    if teleportee.Physics ~= nil then
		-- if teleportee:HasTag("player") then -- Don't teleport the player like this, they're being handled by the EntityScript teleport earlier on
			teleportee:Teleport(loctarget)
		-- else
			-- teleportee.Physics:Teleport(locpos.x, 0, locpos.z)
		-- end
    else
        teleportee.Transform:SetPosition(locpos.x, 0, locpos.z)
    end

    if teleportee:HasTag("player") then
        teleportee:SnapCamera()
        teleportee:ScreenFade(true, 1)
        teleportee.sg.statemem.teleport_task = teleportee:DoTaskInTime(1, teleport_end, locpos, loctarget, staff)
    else
        teleport_end(teleportee, locpos, loctarget, staff)
    end
end

local function new_tele_full(teleportee, staff, caster, loctarget, target_in_ocean)
    local ground = TheWorld
	
	print("DS - STAFF - Doing the full teleport, should load the interior and stuff successfully")

    --V2C: Gotta do this RIGHT AWAY in case anything happens to loctarget or caster
    local locpos = teleportee.components.teleportedoverride ~= nil and teleportee.components.teleportedoverride:GetDestPosition()
				or loctarget == nil and getrandomposition(caster, teleportee, target_in_ocean)
				or loctarget.teletopos ~= nil and loctarget:teletopos()
				or loctarget:GetPosition()

    if teleportee.components.locomotor ~= nil then
        teleportee.components.locomotor:StopMoving()
    end

    staff.components.finiteuses:Use(1)

    if ground:HasTag("cave") then
        -- There's a roof over your head, magic lightning can't strike!
        ground:PushEvent("ms_miniquake", { rad = 3, num = 5, duration = 1.5, target = teleportee })
        return
    end

    local isplayer = teleportee:HasTag("player")
    if isplayer then
        teleportee.sg:GoToState("forcetele")
    else
        if teleportee.components.health ~= nil then
            teleportee.components.health:SetInvincible(true)
        end
        if teleportee.DynamicShadow ~= nil then
            teleportee.DynamicShadow:Enable(false)
        end
        teleportee:Hide()
    end

    --#v2c hacky way to prevent lightning from igniting us
    local preventburning = teleportee.components.burnable ~= nil and not teleportee.components.burnable.burning
    if preventburning then
        teleportee.components.burnable.burning = true
    end
    ground:PushEvent("ms_sendlightningstrike", teleportee:GetPosition())
    if preventburning then
        teleportee.components.burnable.burning = false
    end

    if caster ~= nil then
        if caster.components.staffsanity then
            caster.components.staffsanity:DoCastingDelta(-TUNING.SANITY_HUGE)
        elseif caster.components.sanity ~= nil then
            caster.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
        end
    end

    ground:PushEvent("ms_deltamoisture", TUNING.TELESTAFF_MOISTURE)

    if isplayer then
        teleportee.sg.statemem.teleport_task = teleportee:DoTaskInTime(3, teleport_continue, locpos, loctarget, staff)
    else
        teleport_continue(teleportee, locpos, loctarget, staff)
    end
	
end

local function new_teleport_func(inst, target, ...)
	-- Copied right from the original prefab
    local caster = inst.components.inventoryitem.owner or target
    if target == nil then
        target = caster
    end

    local x, y, z = target.Transform:GetWorldPosition()
	local target_in_ocean = target.components.locomotor ~= nil and target.components.locomotor:IsAquatic()

	local loctarget = target.components.minigame_participator ~= nil and target.components.minigame_participator:GetMinigame()
						or target.components.teleportedoverride ~= nil and target.components.teleportedoverride:GetDestTarget()
                        or target.components.hitchable ~= nil and target:HasTag("hitched") and target.components.hitchable.hitched
						or nil

	if loctarget == nil and not target_in_ocean then
		loctarget = FindNearestActiveTelebase(x, y, z, nil, 1)
	end
    -- teleport_start(target, inst, caster, loctarget, target_in_ocean)

	if loctarget then
		local x, y, z = loctarget.Transform:GetWorldPosition()
		local xinst = inst.Transform:GetWorldPosition()
		print("DS - STAFF - Pos: ", x, y, z)
		if x > 1800 or xinst > 1800 then -- In interior space, either the target or the caster
			print("DS - STAFF - Would teleport to interior space?")
			-- caster:Teleport(loctarget)
			-- return new_tele_full(inst, target, ...)
			return new_tele_full(target, inst, caster, loctarget, target_in_ocean)
		else
			print("DS - STAFF - Target wasn't in interior space, do the original tele")
			return inst.OldTele(inst, target, ...)
		end
	end
	
end

-- local function tele_fn(inst)
return function(inst)
	if not TheWorld.ismastersim then return end
	
	print("DS - STAFF - Tele overriding stuff")
	
	inst.OldTele = inst.components.spellcaster.spell
	inst.components.spellcaster.spell = new_teleport_func
end

-- AddPrefabPostInit("telestaff", tele_fn) -- Telelocator staff, the purple one