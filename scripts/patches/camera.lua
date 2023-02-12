
local interior_heading = 0
local interior_pitch = 35
local interior_fov = 35

return function(self)
	function self:ApplyInterior()
			if not self.interior_currentpos then
			self.interior_currentpos = Vector3(0,0,0)
		end

		self.followPlayer = true
		local dx = -math.cos(interior_pitch*DEGREES)*math.cos(interior_heading*DEGREES)
		local dy = -math.sin(interior_pitch*DEGREES)
		local dz = -math.cos(interior_pitch*DEGREES)*math.sin(interior_heading*DEGREES)
		--pos
		local px = dx*(-self.interior_distance) + self.interior_currentpos.x 
		local py = dy*(-self.interior_distance) + self.interior_currentpos.y 
		local pz = dz*(-self.interior_distance) + self.interior_currentpos.z 

		--right
		local rx = math.cos((interior_heading+90)*DEGREES)
		local ry = 0
		local rz = math.sin((interior_heading+90)*DEGREES)

		--up
		local ux, uy, uz =  dy * rz - dz * ry,
							dz * rx - dx * rz,
							dx * ry - dy * rx

		TheSim:SetCameraPos(px,py,pz)
		TheSim:SetCameraDir(dx, dy, dz)
		TheSim:SetCameraUp(ux, uy, uz)
		TheSim:SetCameraFOV(interior_fov)
		
		--listen dist
		local lx = 0.5*dx*(-self.interior_distance*.1) + self.interior_currentpos.x
		local ly = 0.5*dy*(-self.interior_distance*.1) + self.interior_currentpos.y
		local lz = 0.5*dz*(-self.interior_distance*.1) + self.interior_currentpos.z
		
		if self.followPlayer and ThePlayer then
			local target = Vector3(ThePlayer.Transform:GetWorldPosition())
			local source = Vector3(px,py,pz)
			local dir = target - source	
			dir:Normalize()
			local pos = target - dir * self.distance * 0.1
			lx,ly,lz = pos.x,pos.y,pos.z
		end
		TheSim:SetListener(lx, ly, lz, dx, dy, dz, ux, uy, uz)
	end

	local _Update = self.Update
	function self:Update(dt, ...)
		if self.interior_distance then
			if self.shake then
				local shakeOffset = self.shake:Update(dt)
				
				if shakeOffset then
					local upOffset = Vector3(0, shakeOffset.y, 0)
					local rightOffset = self:GetRightVec() * shakeOffset.x
					self.interior_currentpos.x = self.interior_currentpos_original.x + upOffset.x + rightOffset.x
					self.interior_currentpos.y = self.interior_currentpos_original.y + upOffset.y + rightOffset.y
					self.interior_currentpos.z = self.interior_currentpos_original.z + upOffset.z + rightOffset.z
				else
					self.interior_currentpos.x = self.interior_currentpos_original.x
					self.interior_currentpos.y = self.interior_currentpos_original.y
					self.interior_currentpos.z = self.interior_currentpos_original.z 
					self.shake:StopShaking()
					self.shake = nil
				end
			end
			
			TheCamera:ApplyInterior()
		end
		
		return _Update(self, dt, ...)
	end
end
