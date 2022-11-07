local MysteryDoor = Class(function(self, inst)
    self.inst = inst
end)

function MysteryDoor:IsActionValid(action, right)
    return self.inst:HasTag("secret_room") and action == ACTIONS.SPY
end

function MysteryDoor:Investigate(doer)
	-- local player = GetPlayer()
	local player = doer -- Is this right?
	
	if self.inst.door then
		player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_MYSTERY_DOOR_FOUND"))
	else
		player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_MYSTERY_DOOR_NOT_FOUND"))
	end
end

return MysteryDoor