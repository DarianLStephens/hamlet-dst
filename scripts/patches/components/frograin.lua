return function(self)
	local _ScheduleSpawn = UpvalueHacker.GetUpvalue(self.SetSpawnTimes, "ToggleUpdate", "ScheduleSpawn")
	local function ScheduleSpawn(player, ...)
		if player and player.components.interiorplayer.interiormode then
			return
		end
		_ScheduleSpawn(player, ...)
	end
	UpvalueHacker.SetUpvalue(self.SetSpawnTimes, ScheduleSpawn, "ToggleUpdate", "ScheduleSpawn")
end
