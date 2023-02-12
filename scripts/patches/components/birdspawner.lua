return function(self)
	local BIRD_TYPES = UpvalueHacker.GetUpvalue(self.SpawnBird, "PickBird", "BIRD_TYPES")
	BIRD_TYPES[GROUND.INVALID] = {}   --Stop spawning birds in houses
end
