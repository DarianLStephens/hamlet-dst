require("camerashake")


InteriorCamera = Class(function(self, inst)
    self.inst = inst
    self.target = nil
    self.currentpos = Vector3(0,0,0)
	self.distance = 30
    self:SetDefault()
	
	--Init Interior Variables
	self.interior_pitch = 35 -- 40
	self.interior_heading = 0
	self.interior_distance = 25
	self.interior_currentpos = Vector3(0,0,0)
	self.interior_fov = 35

    self.interior = true

    self.followPlayer = true
    -- I'm not sure what this does.. it doesn't seem to break things when I comment it out. But it is causing 8 faced thigns to mess up.
--    self:Snap()
    self.time_since_zoom = nil
end)

function InteriorCamera:SetDefault()

	--Legacy Variables To Maintain Interface With Game
    self.targetpos = Vector3(0,0,0)
    --self.currentpos = Vector3(0,0,0)
    self.targetoffset = Vector3(0,1.5,0)

    if self.headingtarget == nil then
        self.headingtarget = 45
    end

    self.fov = 35
    self.pangain = 4
    self.headinggain = 20
    self.distancegain = 1
	self.heading = 0

    self.zoomstep = 4
    self.distancetarget = 30

    self.mindist = 15
    self.maxdist = 50 --40
   
    self.mindistpitch = 30
    self.maxdistpitch = 60--60 
    self.paused = false
    self.shake = nil
    self.controllable = true
    self.cutscene = false


	-- DS - Possibly meant to be cave, as in the clefts and stuff you can explore in Hamlet?
    if TheWorld and TheWorld.state.iscaveday then
        self.mindist = 15
        self.maxdist = 35
        self.mindistpitch = 25
        self.maxdistpitch = 40
        self.distancetarget = 25
    end

    if self.target then
        self:SetTarget(self.target)
    end
end

function InteriorCamera:GetRightVec()
    return Vector3(math.cos((self.interior_heading + 90)*DEGREES), 0, math.sin((self.interior_heading + 90)*DEGREES))
end

function InteriorCamera:GetDownVec()
    return Vector3(math.cos((self.interior_heading)*DEGREES), 0, math.sin((self.interior_heading)*DEGREES))
end

function InteriorCamera:SetPaused(val)
	self.paused = val
end

function InteriorCamera:SetMinDistance(distance)
    self.mindist = distance
end

function InteriorCamera:SetGains(pan, heading, distance)
    self.distancegain = distance
    self.pangain = pan
    self.headinggain = heading
end

function InteriorCamera:IsControllable() --Whoops looks like this is a dupe of the CanControl function 
    return self.controllable
end

function InteriorCamera:SetControllable(val)
    self.controllable = val
end

function InteriorCamera:CanControl()
    return self.controllable
end

function InteriorCamera:SetOffset(offset)
    self.targetoffset.x, self.targetoffset.y, self.targetoffset.z = offset.x, offset.y, offset.z
end

function InteriorCamera:GetDistance()
    return self.distancetarget
end

function InteriorCamera:SetDistance(dist)
    self.distancetarget = dist
end

function InteriorCamera:Shake(type, duration, speed, scale)
    local intcam_shakeType = type or ShakeType.FULL
    local intcam_duration = duration or 1
    local intcam_speed = speed or 0.05
    local intcam_scale = scale or 1

    if Profile:IsScreenShakeEnabled() then
        self.shake = CameraShake(intcam_shakeType, intcam_duration, intcam_speed, intcam_scale)
    end
    local shake_scale = math.max(0, math.min(intcam_scale/4, 1))
    TheInputProxy:AddVibration(VIBRATION_CAMERA_SHAKE, intcam_duration, shake_scale, false)    
end

function InteriorCamera:SetTarget(inst)
    self.target = inst
    self.targetpos.x, self.targetpos.y, self.targetpos.z = self.target.Transform:GetWorldPosition()
end

function InteriorCamera:Apply()
    
    --dir
    local dx = -math.cos(self.interior_pitch*DEGREES)*math.cos(self.interior_heading*DEGREES)
    local dy = -math.sin(self.interior_pitch*DEGREES)
    local dz = -math.cos(self.interior_pitch*DEGREES)*math.sin(self.interior_heading*DEGREES)

    --pos
    local px = dx*(-self.interior_distance) + self.interior_currentpos.x 
    local py = dy*(-self.interior_distance) + self.interior_currentpos.y 
    local pz = dz*(-self.interior_distance) + self.interior_currentpos.z 

    --right
    local rx = math.cos((self.interior_heading+90)*DEGREES)
    local ry = 0
    local rz = math.sin((self.interior_heading+90)*DEGREES)

    --up
    local ux, uy, uz =  dy * rz - dz * ry,
                        dz * rx - dx * rz,
                        dx * ry - dy * rx

    TheSim:SetCameraPos(px,py,pz)
    TheSim:SetCameraDir(dx, dy, dz)
    TheSim:SetCameraUp(ux, uy, uz)
    TheSim:SetCameraFOV(self.interior_fov)
	
    --listen dist
    local lx = 0.5*dx*(-self.interior_distance*.1) + self.interior_currentpos.x
    local ly = 0.5*dy*(-self.interior_distance*.1) + self.interior_currentpos.y
    local lz = 0.5*dz*(-self.interior_distance*.1) + self.interior_currentpos.z
    
    if self.followPlayer then
	    local target = Vector3(ThePlayer.Transform:GetWorldPosition())
	    local source = Vector3(px,py,pz)
	    local dir = target - source	
	    dir:Normalize()
	    local pos = target - dir * self.distance * 0.1
	    lx,ly,lz = pos.x,pos.y,pos.z
    end
    TheSim:SetListener(lx, ly, lz, dx, dy, dz, ux, uy, uz)
    
end

local lerp = function(lower, upper, t)
   if t > 1 then t = 1 elseif t < 0 then t = 0 end
   return lower*(1-t)+upper*t 
end

function InteriorCamera:GetHeading()
    return self.heading
end
function InteriorCamera:GetHeadingTarget()
    return self.headingtarget
end

function InteriorCamera:SetHeadingTarget(r)
    self.headingtarget = r
end

function InteriorCamera:ZoomIn()
    -- self.distancetarget = self.distancetarget - self.zoomstep
    -- if self.distancetarget < self.mindist then
    --     self.distancetarget = self.mindist
        
    -- end
    -- self.time_since_zoom = 0
    
end

function InteriorCamera:ZoomOut()
 --    self.distancetarget = self.distancetarget + self.zoomstep
 --    if self.distancetarget > self.maxdist then
 --        self.distancetarget = self.maxdist
 --    end    
	-- self.time_since_zoom = 0
end

function InteriorCamera:GetTimeSinceZoom()
    return self.time_since_zoom
end 

function InteriorCamera:Snap()
    if self.target then
        self.targetpos = Vector3(self.target.Transform:GetWorldPosition()) + self.targetoffset
    else
        self.targetpos.x,self.targetpos.y,self.targetpos.z = self.targetoffset.x,self.targetoffset.y,self.targetoffset.z
    end

    self.currentpos.x, self.currentpos.y, self.currentpos.z = self.targetpos.x, self.targetpos.y, self.targetpos.z
    self.heading = self.headingtarget
    self.distance = self.distancetarget

    local percent_d = (self.distance - self.mindist)/ (self.maxdist - self.mindist)
    self.pitch = lerp(self.mindistpitch, self.maxdistpitch, percent_d)
    
    self:Apply()
end

function InteriorCamera:CutsceneMode(b)
    self.cutscene = b
end

function InteriorCamera:SetCustomLocation(loc)
    self.targetpos.x,self.targetpos.y,self.targetpos.z  = loc.x,loc.y,loc.z
end

function InteriorCamera:Update(dt)
	if self.paused then
		return
	end

	--Legacy functionality, in case external systems are waiting on these things
    if self.cutscene then

        self.currentpos.x = lerp(self.currentpos.x, self.targetpos.x + self.targetoffset.x, dt*self.pangain)
        self.currentpos.y = lerp(self.currentpos.y, self.targetpos.y + self.targetoffset.y, dt*self.pangain)
        self.currentpos.z = lerp(self.currentpos.z, self.targetpos.z + self.targetoffset.z, dt*self.pangain)


        if self.shake then
            local shakeOffset = self.shake:Update(dt)
            if shakeOffset then
                local upOffset = Vector3(0, shakeOffset.y, 0)
                local rightOffset = self:GetRightVec() * shakeOffset.x
                self.currentpos.x = self.currentpos.x + upOffset.x + rightOffset.x
                self.currentpos.y = self.currentpos.y + upOffset.y + rightOffset.y
                self.currentpos.z = self.currentpos.z + upOffset.z + rightOffset.z
            else
                self.shake = nil
            end
        end

        if math.abs(self.heading - self.headingtarget) > .01 then
            self.heading = lerp(self.heading, self.headingtarget, dt*self.headinggain)    
        end

        if math.abs(self.distance - self.distancetarget) > .01 then
            self.distance = lerp(self.distance, self.distancetarget, dt*self.distancegain)    
        end

        local percent_d = (self.distance - self.mindist)/ (self.maxdist - self.mindist)
        self.pitch = lerp(self.mindistpitch, self.maxdistpitch, percent_d)

    else
        
    --	if self.time_since_zoom then
   -- 		self.time_since_zoom = self.time_since_zoom + dt
   -- 	
   -- 		if self.should_push_down and self.time_since_zoom > .25 --[[ and self:IsControllable() ]] then --Dave added InControllable to keep this code from fighting when trying to zoom way out 
    --            self.distancetarget = self.distance - self.zoomstep
     --           self.time_since_zoom = 0
    --		end
   -- 	end
        

        local pan_speed = self.pangain

    
        if self.target then
            --self.targetpos = Vector3(self.target.Transform:GetWorldPosition()) + self.targetoffset
            local x, y, z = self.target.Transform:GetWorldPosition()
            self.targetpos.x = x + self.targetoffset.x
            self.targetpos.y = y + self.targetoffset.y
            self.targetpos.z = z + self.targetoffset.z

            if self.target.components.locomotor then
                --This assumes the target is the player...
                local base_move_speed = 6
                local base_pan_speed = self.pangain
                local actual_move_speed = (self.target.components.locomotor.wantstorun and self.target.components.locomotor:GetRunSpeed()) or self.target.components.locomotor:GetWalkSpeed()

                local scale = actual_move_speed/base_move_speed
                pan_speed = pan_speed * scale
            end

        else
            self.targetpos.x, self.targetpos.y, self.targetpos.z = self.targetoffset.x, self.targetoffset.y, self.targetoffset.z
        end

        if not self.interior_currentpos_original then
            self.interior_currentpos_original = {}
            self.interior_currentpos_original.x = self.interior_currentpos.x
            self.interior_currentpos_original.y = self.interior_currentpos.y
            self.interior_currentpos_original.z = self.interior_currentpos.z                
        end     

        self.interior_currentpos.x = lerp(self.interior_currentpos.x, self.interior_currentpos_original.x, dt * pan_speed)
        self.interior_currentpos.y = lerp(self.interior_currentpos.y, self.interior_currentpos_original.y, dt * pan_speed)
        self.interior_currentpos.z = lerp(self.interior_currentpos.z, self.interior_currentpos_original.z, dt * pan_speed)

        if self.shake then

            local shakeOffset = self.shake:Update(dt)
       
            if shakeOffset then
                local upOffset = Vector3(0, shakeOffset.y, 0)
                local rightOffset = self:GetRightVec() * shakeOffset.x
                self.interior_currentpos.x = self.interior_currentpos.x + upOffset.x + rightOffset.x
                self.interior_currentpos.y = self.interior_currentpos.y + upOffset.y + rightOffset.y
                self.interior_currentpos.z = self.interior_currentpos.z + upOffset.z + rightOffset.z
            else
                self.shake = nil
            end
        end
        
        if math.abs(self.heading - self.headingtarget) > .01 then
            self.heading = lerp(self.heading, self.headingtarget, dt*self.headinggain)    
        else
            self.heading = self.headingtarget
        end

        if math.abs(self.distance - self.distancetarget) > .01 then
            self.distance = lerp(self.distance, self.distancetarget, dt*self.distancegain)    
        else
            self.distance = self.distancetarget
        end
        
        local percent_d = (self.distance - self.mindist)/ (self.maxdist - self.mindist)
        self.pitch = lerp(self.mindistpitch, self.maxdistpitch, percent_d)
    end
    self:Apply()

    
end


return InteriorCamera
