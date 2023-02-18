return function(self)
	local _ReleaseSpawn = UpvalueHacker.GetUpvalue(self.ForceReleaseSpawn, "ReleaseSpawn")
	local function ReleaseSpawn(target, ...)
		if target and target.components.interiorplayer and target.components.interiorplayer.interiormode then
			return
		end
		_ReleaseSpawn(target, ...)
	end
	UpvalueHacker.SetUpvalue(self.ForceReleaseSpawn, ReleaseSpawn, "ReleaseSpawn")
end
