local InteriorPlayer = Class(function(self, inst)
    self.inst = inst
	self.oldcamera = TheCamera
	self._camX = 0
	self._camZ = 0
	self._camZoom = 0
	
	self._interiorMode = false
	self._lastMode = false -- Specifically don't save this
	
	self._interiorWidth = 0
	self._interiorDepth = 0
	self._wallTexture = nil
	self._floorTexture = nil
	self._groundSound = "WOOD"
	
	self.soundupdatertask = nil
	
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

local function SoundUpdater(inst, self)
	-- self.inst.components.locomotor:PushTempGroundSpeedMultiplier(1, self._groundSound)
	self.inst.components.locomotor:PushTempGroundSpeedMultiplier(1, WORLD_TILES.WOOD)
	-- self.inst.components.locomotor:PushTempGroundSpeedMultiplier(1, WORLD_TILES[self._groundSound])
end

function InteriorPlayer:UpdateCamera()

	print("DS - Main interiorplayer component, attempting to send data via net to replica...")
	print("X ", self._camX, "Z ", self._camZ, "Zoom ", self._camZoom, "Interior mode ", self._interiorMode)
	
	self.inst.player_classified.net_roomx:set(self._camX)
	self.inst.player_classified.net_roomz:set(self._camZ)
	self.inst.player_classified.net_roomzoom:set(self._camZoom)
	self.inst.player_classified.net_intcamera:set(self._interiorMode)
		
	if self._interiorMode then
		self.inst.player_classified.net_roomwidth:set(self._interiorWidth)
		self.inst.player_classified.net_roomdepth:set(self._interiorDepth)
		self.inst.player_classified.net_roomtexturewall:set(self._wallTexture)
		self.inst.player_classified.net_roomtexturefloor:set(self._floorTexture)
		self.inst.player_classified.net_roomgroundsound:set(self._groundSound)
		
		if self._lastMode == self._interiorMode then
			print("Detected same interior mode, force-update camera position")
			self.inst.player_classified.net_forceupdatecamera:set(true)
		end
		
		self.soundupdatertask = self.inst:DoPeriodicTask(0, SoundUpdater, 0, self)
	else
		if self.soundupdatertask ~= nil then -- Safety checking, mostly in case of load weirdness
			self.soundupdatertask:Cancel()
		end
	end
	
	self._lastMode = self._interiorMode
	
end

function InteriorPlayer:OnSave()
	local data = {
		_camX = self._camX,
		_camZ = self._camZ,
		_camZoom = self._camZoom,
		_interiorMode = self._interiorMode,
		
		_interiorWidth = self._interiorWidth,
		_interiorDepth = self._interiorDepth,
		_wallTexture = self._wallTexture,
		_floorTexture = self._floorTexture,
		_groundSound = self._groundSound,
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
		
		self._interiorWidth = data._interiorWidth
		self._interiorDepth = data._interiorDepth
		self._wallTexture = data._wallTexture
		self._floorTexture = data._floorTexture
		self._groundSound = data._groundSound
	else
		print("Got no data from load, nothing should happen")
	end
end

function InteriorPlayer:LoadPostPass(data)
	print("DS - InteriorPlayer load POST pass")
	if data._interiorMode then
		print("Interiormode is true, update camera")
		self:UpdateCamera() -- Moving it a bit later in init so it can hopefully wait for the client to fully load
	else
		print("Interior mode was false, you (probably) weren't in an interior, don't do the thing")
	end
	
end

return InteriorPlayer