local InteriorPlayer = Class(function(self, inst)
    self.inst = inst
	self.oldcamera = TheCamera
	self.camX = 0
	self.camZ = 0
	self.camZoom = 0
	
	self.interiorMode = false
	
	self.ccupdatertask = nil
	
	self.forceupdatecamera = false
	
	-- Default dimensions for most interiors
	self.interiorWidth = 24
	self.interiorDepth = 16
	-- self.wallTexture = "pig_ruins_panel.tex"
	-- self.floorTexture = "ground_ruins_slab.tex"
	self.wallTexture = "levels/textures/interiors/pig_ruins_panel.tex"
	self.floorTexture = "levels/textures/interiors/ground_ruins_slab.tex"
	self.groundSound = "WOOD"

end)

local INTERIOR_COLOURCUBES =
{
    day = resolvefilepath("images/colour_cubes/pigshop_interior_cc.tex"),
    dusk = resolvefilepath("images/colour_cubes/pigshop_interior_cc.tex"),
    night = resolvefilepath("images/colour_cubes/pigshop_interior_cc.tex"),
    full_moon = resolvefilepath("images/colour_cubes/pigshop_interior_cc.tex"),
}

local function DisableCCTest()
	return self.interiorMode == false --and not CanEntitySeeInDark(self.inst)
end

function CCUpdater(inst, self)
	-- local playerhold = self.inst
	-- print("DS - replica thread test print stuff")
	-- print("Player: ",player)
	-- print("Self: ",self)
	-- print("Inst: ",inst)
	-- repeat
		if CanEntitySeeInDark(self.inst) then
			self.inst.components.playervision:SetCustomCCTable(nil)
		else
			self.inst.components.playervision:SetCustomCCTable(INTERIOR_COLOURCUBES)
		end
		
		-- self.inst.components.locomotor:PushTempGroundSpeedMultiplier(1, groundSound)
		
		-- Yield()
	-- until DisableCCTest()
end

function InteriorPlayer:ApplyColorCube(cc)
	-- StartThread(CCUpdater, self.inst.GUID, self.inst)
	-- StartThread(CCUpdater, self.inst, inst)
	self.ccupdatertask = self.inst:DoPeriodicTask(0.1, CCUpdater, 0, self)
	self.inst.components.playervision:SetCustomCCTable(INTERIOR_COLOURCUBES)
end

function InteriorPlayer:RemoveColorCube()
	if self.ccupdatertask ~= nil then -- Safety checking, mostly in case of load weirdness
		self.ccupdatertask:Cancel()
	end
	self.inst.components.playervision:SetCustomCCTable(nil)
end

function InteriorPlayer:ApplyInteriorLighting()
	if TheWorld.ismastersim == false then -- This is a replica, so it SHOULDN'T ever be master, but just to make sure
		TheWorld:PushEvent("overrideambientlighting", Vector3(0,0,0))
	end
end

function InteriorPlayer:RemoveInteriorLighting()
	if TheWorld.ismastersim == false then
		TheWorld:PushEvent("overrideambientlighting", nil)
	end
end

function InteriorPlayer:CleanInteriorSurfaces()
	c_removeallwithtags("interiorwall")
end

function InteriorPlayer:SetupInteriorSurfaces()
	if TheWorld.ismastersim == false then
	
		local AdjustedWidth = self.interiorWidth / 4
		local AdjustedHeight = self.interiorDepth / 4
	
		local interiorWall = SpawnPrefab("interior_wall_back")
		interiorWall.Transform:SetPosition((self.camX - (self.interiorDepth / 2)), 0, self.camZ)
		-- interiorWall.Transform:SetPosition(self.camX, 0, self.camZ)
		-- interiorWall.width = self.interiorWidth*.75
		-- -- interiorWall.height = self.interiorDepth
		interiorWall.SetWallData(interiorWall, self.wallTexture, AdjustedWidth, 1)
		-- interiorWall.SetTexture(interiorWall, "pig_ruins_panel.tex")
		
		-- Left
		local interiorWallSide = SpawnPrefab("interior_wall_side")
		-- -- interiorWallSide.Transform:SetPosition(self.camX, 0, self.camZ)
		interiorWallSide.Transform:SetPosition(self.camX, 0, (self.camZ - (self.interiorWidth / 2)))
		-- interiorWallSide.Transform:SetPosition(self.camX, 0, self.camZ)
		interiorWallSide.SetWallData(interiorWallSide, self.wallTexture, AdjustedHeight, 1)
		-- interiorWallSide.width = self.interiorDepth*.75
		-- -- interiorWallSide.height = self.interiorDepth
		-- interiorWallSide.SetTexture(interiorWallSide, self.wallTexture)
		
		-- Right
		local interiorWallSide2 = SpawnPrefab("interior_wall_side")
		interiorWallSide2.Transform:SetPosition(self.camX, 0, (self.camZ + (self.interiorWidth / 2)))
		-- interiorWallSide2.Transform:SetPosition(self.camX, 0, self.camZ)
		-- interiorWallSide2.width = self.interiorDepth
		-- interiorWallSide2.SetTexture(interiorWallSide2, self.wallTexture)
		interiorWallSide2.SetWallData(interiorWallSide2,self.wallTexture, AdjustedHeight, 1)
		
		local interiorFloor = nil
		-- if self.floorTexture == "levels/textures/interiors/ground_ruins_slab.tex" then
			-- print("Detected ruins slab, do big floor texture override")
			-- interiorFloor = SpawnPrefab("interior_wall_floor_big")
		-- else
			-- print("Regular floor size")
			interiorFloor = SpawnPrefab("interior_wall_floor")
		-- end
		interiorFloor.Transform:SetPosition(self.camX, 0, self.camZ)
		-- interiorFloor.Transform:SetPosition(self.camX - (self.interiorWidth), 0, self.camZ - (self.interiorDepth))
		-- interiorFloor.width = self.interiorWidth*1.25
		-- interiorFloor.height = self.interiorDepth*1.25
		-- interiorFloor.SetTexture(interiorFloor, self.floorTexture)
		interiorFloor.SetWallData(interiorFloor,self.floorTexture, self.interiorWidth, self.interiorWidth)
	end
end

function InteriorPlayer:UpdateCameraPositions()
	print("Updating camera data")
	print("Intended X: ", self.camX, "Z: ", self.camZ)
	TheCamera.interior_currentpos_original = Vector3(self.camX, 0, self.camZ)
	TheCamera.interior_currentpos = Vector3(self.camX, 0, self.camZ)
	TheCamera.interior_distance = self.camZoom
end

function InteriorPlayer:ForceUpdateCamera()
	print("Received force update function, rebuilding surfaces and updating camera data...")
	-- self.inst:DoTaskInTime(1, function()
		self:CleanInteriorSurfaces()
		self:UpdateCameraPositions()
		self:SetupInteriorSurfaces()
	-- end
	-- )
end

function InteriorPlayer:SetCamera()
	print("Client - SetCamera event received from server")
	if self.interiorMode == true then
		TheCamera = InteriorCamera()
		
		self:UpdateCameraPositions()
		
		self:ApplyColorCube(INTERIOR_COLOURCUBES) -- These are the only ones ever used, anyway. If I discover others, I'll change it to be proper
		self:ApplyInteriorLighting()
		self:SetupInteriorSurfaces()
	else
		print("Restoring original camera")
		TheCamera = self.oldcamera
		
		self:RemoveColorCube()
		self:RemoveInteriorLighting()
		self:CleanInteriorSurfaces()
	end
end

return InteriorPlayer