local InteriorPlayer = Class(function(self, inst)
    self.inst = inst
	self.oldcamera = TheCamera
	self._camX = 0
	self._camZ = 0
	self._camZoom = 0
	
	self._interiorMode = false
	
	-- self.intccmode

end)

-- local INTERIOR_COLOURCUBES =
-- {
    -- day = "images/colour_cubes/pigshop_interior_cc.tex",
    -- dusk = "images/colour_cubes/pigshop_interior_cc.tex",
    -- night = "images/colour_cubes/pigshop_interior_cc.tex",
    -- full_moon = "images/colour_cubes/pigshop_interior_cc.tex",
-- }

-- function InteriorPlayer:ApplyColorCube(cc)
	-- inst.components.playervision:SetCustomCCTable(INTERIOR_COLOURCUBES)
-- end

-- function InteriorPlayer:RemoveColorCube()
	-- inst.components.playervision:SetCustomCCTable(nil)
-- end

function InteriorPlayer:UpdateCamera()

	print("DS - Main interiorplayer component, attempting to send data via net to replica...")
	print("X ", self._camX, "Z ", self._camZ, "Zoom ", self._camZoom, "Interior mode ", self._interiorMode)
	self.inst.player_classified.net_roomx:set(self._camX)
	self.inst.player_classified.net_roomz:set(self._camZ)
	self.inst.player_classified.net_roomzoom:set(self._camZoom)
	self.inst.player_classified.net_intcamera:set(self._interiorMode)
		
end

function InteriorPlayer:OnSave()
	local data = {
		_camX = self._camX,
		_camZ = self._camZ,
		_camZoom = self._camZoom,
		_interiorMode = self._interiorMode,
	}
	if self._interiorMode == true then
		return data
	end
end

function InteriorPlayer:OnLoad(data)
	print("DS - InteriorPlayer load pass")
	if data ~= nil then
		print("Got data from load, dumping...")
		dumptable(data, 1, 1, nil, 0)
		self._camX = data._camX
		self._camZ = data._camZ
		self._camZoom = data._camZoom
		self._interiorMode = data._interiorMode
		self:UpdateCamera() -- Moving it a bit later in init so it can hopefully wait for the client to fully load
	else
		print("Got no data from load, nothing should happen")
	end
end

function InteriorPlayer:LoadPostPass(data)
	print("DS - InteriorPlayer load POST pass")
	if data._interiorMode then
		print("Interiormode is true, update camera")
	else
		print("Interior mode was false, you (probably) weren't in an interior, don't do the thing")
	end
	
end

return InteriorPlayer