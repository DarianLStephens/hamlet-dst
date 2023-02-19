local function SetIntCamDirty(inst)
	inst.replica.interiorplayer:SetCamera()
end

local function ForceUpdateCameraDirty(inst, val)
	local rep = inst.replica.interiorplayer
	if rep.forceupdatecamera:value() then
		rep:ForceUpdateCamera()
	end
end

local function DynamicMusicToneDirty(inst, val)
	inst:DoTaskInTime(0, function()
		local rep = inst.replica.interiorplayer
		if rep.dynamicmusictone:value() == "" then
			inst:PushEvent("exitedinterior")
		else
			inst:PushEvent("enteredinterior", rep.dynamicmusictone:value())
		end
	end)
end

local InteriorPlayer = Class(function(self, inst)
    self.inst = inst

    self.camx = net_float(self.inst.GUID, "roomx")
	self.camz = net_float(self.inst.GUID, "roomz")
	self.camzoom = net_float(self.inst.GUID, "roomzoom")
	self.camoffset = net_float(self.inst.GUID, "roomoffset")
	
	self.interiorwidth = net_float(self.inst.GUID, "roomwidth")
	self.interiordepth = net_float(self.inst.GUID, "roomdepth")
	self.interiorheight = net_float(self.inst.GUID, "roomheight")
	self.floortexture = net_string(self.inst.GUID, "roomtexturefloor")
	self.walltexture = net_string(self.inst.GUID, "roomtexturewall")
	self.groundsound = net_string(self.inst.GUID, "roomgroundsound")
	self.reverb = net_string(self.inst.GUID, "roomreverb")
	self.ambsnd = net_string(self.inst.GUID, "roomambsnd")
	
	self.roomid = net_string(self.inst.GUID, "roomid")
	self.dynamicmusictone = net_string(self.inst.GUID, "dynamicmusictone", "dynamicmusictonedirty")

	self.interiormode = net_bool(self.inst.GUID, "setintcam", "setintcamdirty")

	self.forceupdatecamera = net_bool(self.inst.GUID, "forceupdatecam", "forceupdatecamdirty")
	
	-- Default dimensions for most interiors
	self.camx:set(0)
	self.camz:set(0)
	self.camzoom:set(0)
	self.interiorwidth:set(0)
	self.interiordepth:set(0)
	self.interiorheight:set(0)
	self.floortexture:set("levels/textures/interiors/ground_ruins_slab.tex")
	self.walltexture:set("levels/textures/interiors/ground_ruins_slab.tex")
	self.groundsound:set("WOOD")
	self.reverb:set("default")
	self.ambsnd:set("")
	self.interiormode:set(false)
	
	self.inst:ListenForEvent("setintcamdirty", SetIntCamDirty)
	self.inst:ListenForEvent("forceupdatecamdirty", ForceUpdateCameraDirty)
	self.inst:ListenForEvent("dynamicmusictonedirty", DynamicMusicToneDirty)
end)

function InteriorPlayer:GetGroundSound()
	return self.interiormode:value() and self.groundsound:value()
end

function InteriorPlayer:ApplyColorCube(cc)
	self.inst.components.playervision:SetInteriorColourcube()
end

function InteriorPlayer:RemoveColorCube()
	self.inst.components.playervision:ClearInteriorColourcube()
end

function InteriorPlayer:ApplyInteriorEnv()
	if self.inst == ThePlayer then 
		TheWorld.components.ambientsound:SetInteriorAmbient(self.ambsnd:value(), self.reverb:value())
		local oceancolor = TheWorld.components.oceancolor
		if oceancolor then
			TheWorld:StopWallUpdatingComponent(oceancolor)
			oceancolor:Initialize(false)
		end
	end
end

function InteriorPlayer:RemoveInteriorEnv()
	if self.inst == ThePlayer then 
		TheWorld.components.ambientsound:ClearInteriorAmbient()
		local oceancolor = TheWorld.components.oceancolor
		if oceancolor then
			oceancolor:Initialize(TheWorld.has_ocean)
		end
	end
end

function InteriorPlayer:CleanInteriorSurfaces()
	if self.interior then
		self.interior:Remove()
		self.interior = nil
	end
end

function InteriorPlayer:SetupInteriorSurfaces()
	self:CleanInteriorSurfaces()
	if self.inst == ThePlayer then 
		self.interior = CreateRoom({
			id = self.roomid:value(), 
			width = self.interiorwidth:value(), 
			depth = self.interiordepth:value(),
			height = self.interiorheight:value(),
			floortex = self.floortexture:value(),
			walltex = self.walltexture:value(),
			offset = self.camoffset:value(),
		})
		self.interior.Transform:SetPosition(self.camx:value(), 0, self.camz:value())
	end
end

function InteriorPlayer:UpdateCameraPositions()
	print("Updating camera data")
	print("Intended X: ", self.camx:value(), "Z: ", self.camz:value())
	TheCamera.interior_currentpos_original = Vector3(self.camx:value(), 0, self.camz:value())
	TheCamera.interior_currentpos = Vector3(self.camx:value(), 0, self.camz:value())
	TheCamera.interior_distance = self.camzoom:value()
end

function InteriorPlayer:ForceUpdateCamera()
	print("Received force update function, rebuilding surfaces and updating camera data...")
	self:CleanInteriorSurfaces()
	self:UpdateCameraPositions()
	self:SetupInteriorSurfaces()
end

local headingtarget = 0
function InteriorPlayer:SetCamera()
	print("Client - SetCamera event received from server")
	if self.interiormode:value() == true then
		self.inst:DoTaskInTime(0, function()
			headingtarget = TheCamera.headingtarget
			TheCamera.headingtarget = 0
			TheCamera.controllable = false
			TheCamera.paused = true 
		end)
		self:UpdateCameraPositions()
		
		self:ApplyColorCube() -- These are the only ones ever used, anyway. If I discover others, I'll change it to be proper
		self:ApplyInteriorEnv()
		self:SetupInteriorSurfaces()
	else
		print("Restoring original camera")

		TheCamera.headingtarget = headingtarget
		TheCamera.interior_distance = nil
        TheCamera.controllable = true
		TheCamera.paused = false 
		TheCamera:Apply()

		self:RemoveColorCube()
		self:RemoveInteriorEnv()
		self:CleanInteriorSurfaces()
	end
end

return InteriorPlayer