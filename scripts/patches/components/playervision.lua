local cc = resolvefilepath("images/colour_cubes/pigshop_interior_cc.tex")
local INTERIOR_COLOURCUBES = { day = cc, dusk = cc, night = cc, full_moon = cc }
cc = resolvefilepath("images/colour_cubes/mole_vision_on_cc.tex")
local INTERIOR_NIGHT_COLOURCUBES = { day = cc, dusk = cc, night = cc, full_moon = cc }

return function(self)
	self.ininterior = false
	function self:SetInteriorColourcube()
		self.ininterior = true
		self:UpdateCCTable()
	end
	
	function self:ClearInteriorColourcube()
		self.ininterior = false
		self:UpdateCCTable()
		TheWorld:PushEvent("overrideambientlighting", nil)
	end

	local _UpdateCCTable = self.UpdateCCTable
	function self:UpdateCCTable(...)
		_UpdateCCTable(self, ...)
		if self.ininterior then
			if self.nightvision then
				self.currentcctable = INTERIOR_NIGHT_COLOURCUBES
				self.inst:PushEvent("ccoverrides", INTERIOR_NIGHT_COLOURCUBES)
				TheWorld:PushEvent("overrideambientlighting", nil)
				return
			end
			self.currentcctable = INTERIOR_COLOURCUBES
			self.inst:PushEvent("ccoverrides", INTERIOR_COLOURCUBES)
			TheWorld:PushEvent("overrideambientlighting", Vector3(0,0,0))
		end
	end
end
