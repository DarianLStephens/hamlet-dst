local InteriorPlayer = Class(function(self, inst)
    self.inst = inst
	self.oldcamera = TheCamera
	self.camX = 0
	self.camZ = 0
	self.camZoom = 0
	
	self.interiorMode = false
	
	self.ccupdatertask = nil

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
		-- Yield()
	-- until DisableCCTest()
end

function InteriorPlayer:ApplyColorCube(cc)
	-- StartThread(CCUpdater, self.inst.GUID, self.inst)
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


function InteriorPlayer:SetCamera()
	if self.interiorMode == true then
		print("Intended X: ", self.camX, "Z: ", self.camZ)
		TheCamera = InteriorCamera()
		TheCamera.interior_currentpos_original = Vector3(self.camX, 0, self.camZ)
		TheCamera.interior_currentpos = Vector3(self.camX, 0, self.camZ)
		TheCamera.interior_distance = self.camZoom
		
		self:ApplyColorCube(INTERIOR_COLOURCUBES) -- These are the only ones ever used, anyway. If I discover others, I'll change it to be proper
		self:ApplyInteriorLighting()
	else
		print("Restoring original camera")
		TheCamera = self.oldcamera
		
		self:RemoveColorCube()
		self:RemoveInteriorLighting()
	end
end

return InteriorPlayer