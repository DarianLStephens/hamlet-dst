return function(self)
	local isIAEnabled = KnownModIndex:IsModEnabled("workshop-1467214795")
	local BIRD_TYPES = nil
	if not isIAEnabled then
		BIRD_TYPES = UpvalueHacker.GetUpvalue(self.SpawnBird, "PickBird", "BIRD_TYPES")
	else 
		BIRD_TYPES = UpvalueHacker.GetUpvalue(self.SpawnBird, "birdvstile")
	end
	BIRD_TYPES[WORLD_TILES.INTERIOR] = {}   --Stop spawning birds in houses
end
