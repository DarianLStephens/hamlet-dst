return function(self)
    local AMBIENT_SOUNDS = UpvalueHacker.GetUpvalue(self.OnUpdate, "AMBIENT_SOUNDS")
    AMBIENT_SOUNDS[ "STORE" ] = { sound = "dontstarve_DLC003/amb/inside/store" }
    AMBIENT_SOUNDS[ "HOUSE" ] = { sound = "dontstarve_DLC003/amb/inside/house" }
    AMBIENT_SOUNDS[ "PALACE" ] = { sound = "dontstarve_DLC003/amb/inside/palace" }
    AMBIENT_SOUNDS[ "ANT_HIVE" ] = { sound = "dontstarve_DLC003/amb/inside/ant_hive" }
    AMBIENT_SOUNDS[ "BAT_CAVE" ] = { sound = "dontstarve_DLC003/amb/inside/bat_cave" }
    AMBIENT_SOUNDS[ "RUINS" ] = { sound = "dontstarve_DLC003/amb/inside/ruins" }

	function self:SetInteriorAmbient(ambsnd, reverb)
		TheWorld:PushEvent("overrideambientsound", { tile = WORLD_TILES.INTERIOR, override = ambsnd })
		self:SetReverbOverride(reverb)
	end
	
	function self:ClearInteriorAmbient()
		TheWorld:PushEvent("overrideambientsound", { tile = WORLD_TILES.INTERIOR, override = nil })
		self:ClearReverbOveride()
	end

	local _SetReverbPreset = self.SetReverbPreset
	function self:SetReverbPreset(preset, ...)
		if not self.reverboverride then
			_SetReverbPreset(self, preset, ...)
		end
		self.reverbpreset = preset
	end
	
	function self:SetReverbOverride(override)
		self.reverboverride = override
		TheSim:SetReverbPreset(self.reverboverride)
	end
	
	function self:ClearReverbOveride()
		self.reverboverride = nil	
		if self.reverbpreset then
			TheSim:SetReverbPreset(self.reverbpreset)
		else
			TheSim:SetReverbPreset("default")
		end
	end
end
