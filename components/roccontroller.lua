local easing = require("easing")

local SCREEN_DIST = 50
local HEAD_ATTACK_DIST = 0.1 -- 1.5
local SCALERATE = 1/(30 *2)  -- 2 seconds to go from 0 to 1

local HEADDIST = 17
local HEADDIST_TARGET = 15
local BODY_DIST_TOLLERANCE = 2

local TAILDIST = 13

local LEGDIST = TUNING.ROC_LEGDSIT
local LEG_WALKDIST = 4
local LEG_WALKDIST_BIG = 6
local LAND_PROX = 15 --7

local RocController = Class(function(self, inst)
    self.inst = inst    
    self.speed = 10	
    self.stages = 3
    self.startscale = 0.35   

    self.head_vel = 0
    self.head_acc = 3
    self.head_vel_max = 6
	self.body_vel = {x=0,z=0}
    self.body_acc = 0.3
    self.body_dec = 1
    self.body_vel_max = 10 --6

    self.tail_vel =  {x=0,z=0}
    self.tail_acc = 3
    self.tail_dec = 6
    self.tail_vel_max = self.speed

    self.turn_threshold = 20

    self.dungtime = 3

    self.angular_body_acc =  5  

    self.inst.sounddistance = 0  

    self.player_was_invincible = false
end)

function RocController:Setup(speed, scale, stages)
	if speed then
		self.speed = speed
	end
	if scale then	
		self.startscale = scale
	end
	if stages then
		self.stages = stages		
	end

	self.inst:ListenForEvent("liftoff", function() 
			self.busy = true
			local head = self.head
			head:PushEvent("taunt")

			head:ListenForEvent("animover", function() 			
					if head.AnimState:IsCurrentAnimation("taunt") then
						self.busy = false
						self:doliftoff() 
					end
				end)
			
		end, self.inst) 
	
	self:setscale(self.startscale)
	
	self.inst:DoTaskInTime(0,function() 
		if not self.landed or self.liftoff then 
			self.inst:PushEvent("fly") 
		end 
	end)

	--self.inst:DoPeriodicTask(30+(math.random()*30), function() self:CheckScale() end )
	self:CheckScale()
	self.inst:DoPeriodicTask(1, function() self:CheckScale() end )
end

function RocController:Start()
	self.inst:StartUpdatingComponent(self)
end

function RocController:Stop()
	self.inst:StopUpdatingComponent(self)
end

function RocController:CheckScale()
--	print("CHECKING SCALE",self.inst.Transform:GetScale())
	if self.inst.Transform:GetScale() ~= 1 then

		local delta = (1-self.startscale) / self.stages

		self.scaleup = {
			targetscale = math.min(self.inst.Transform:GetScale() + delta, 1)
		}
	end
end

function RocController:setscale(scale)
	self.inst.Transform:SetScale(scale,scale,scale)
	if self.scalefn then
		self.scalefn(self.inst,scale)
	end
	self.inst.sounddistance = Remap(scale, self.startscale, 1, 0, 1)	
end

function RocController:doliftoff()
	if self.inst.bodyparts and #self.inst.bodyparts > 0 then
		for i,part in ipairs(self.inst.bodyparts) do
			part:PushEvent("exit")
		end
		self.inst.bodyparts = nil
		self.head = nil
		self.tail = nil
		self.leg1 = nil
		self.leg2 = nil
		self.liftoff = true
		self.landed = nil
		self.currentleg = nil

		self.inst:PushEvent("takeoff")
	end
end

function RocController:Spawnbodyparts()

	if not self.inst.bodyparts then
		self.inst.bodyparts = {}
	end

	local angle = self.inst.Transform:GetRotation()*DEGREES
	local pos = Vector3(self.inst.Transform:GetWorldPosition())

	local offset = nil

	offset = Vector3(LEGDIST * math.cos( angle+(PI/2) ), 0, -LEGDIST * math.sin( angle+(PI/2) ))
	local leg1 = SpawnPrefab("roc_leg")
	leg1.Transform:SetPosition(pos.x + offset.x,0,pos.z + offset.z)
	leg1.Transform:SetRotation(self.inst.Transform:GetRotation())
	leg1.sg:GoToState("enter")
	leg1.body = self.inst
	leg1.legoffsetdir = PI/2
	table.insert(self.inst.bodyparts,leg1)
	self.leg1 = leg1
	self.currentleg = self.leg1

	offset = Vector3(LEGDIST * math.cos( angle-(PI/2) ), 0, -LEGDIST * math.sin( angle-(PI/2) ))	
	local leg2 = SpawnPrefab("roc_leg")
	leg2.Transform:SetPosition(pos.x + offset.x,0,pos.z + offset.z)
	leg2.Transform:SetRotation(self.inst.Transform:GetRotation())
	leg2.sg:GoToState("enter")			
	leg2.body = self.inst
	leg2.legoffsetdir = -PI/2
	table.insert(self.inst.bodyparts,leg2)
	self.leg2 = leg2

	self.inst:DoTaskInTime(0.5,function()								
		offset = Vector3(HEADDIST * math.cos( angle ), 0, -HEADDIST * math.sin( angle ))
		local head = SpawnPrefab("roc_head")
		head.Transform:SetPosition(pos.x + offset.x,0,pos.z + offset.z)
		head.Transform:SetRotation(self.inst.Transform:GetRotation())
		head.sg:GoToState("enter")
		head.body = self.inst
		table.insert(self.inst.bodyparts,head)
		self.head = head
		head.controller = self
	end)	

	offset = Vector3(TAILDIST * math.cos( angle -PI ), 0, -TAILDIST * math.sin( angle -PI ))
	local tail = SpawnPrefab("roc_tail")
	tail.Transform:SetPosition(pos.x + offset.x,0,pos.z + offset.z)
	tail.Transform:SetRotation(self.inst.Transform:GetRotation())
	tail.sg:GoToState("enter")
	self.tail = tail
	table.insert(self.inst.bodyparts,tail)

end

function RocController:EatSomething(food)
	food:Remove()
	print("FOOD EATEN")
end

function RocController:GetTarget()

	if not self.target or not self.target:IsValid() or self.target == GetPlayer() then		
		-- look for items.. 
		local pos = Vector3(self.inst.Transform:GetWorldPosition())
		local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 20, {"structure"})
		for i=#ents,1, -1 do
			if not ents[i].components.workable then			
				table.remove(ents,i)
			end
		end

		local sorted = {}
		if #ents > 0 then
			for i, ent in ipairs(ents)do
				if ent then
					local x,y,z = ent.Transform:GetWorldPosition()
					local ground = GetWorld()

					local tile = ground.Map:GetTileAtPoint(x, y, z)

					if tile ~= GROUND.FOUNDATION and tile ~= GROUND.COBBLEROAD and tile ~= GROUND.LAWN and tile ~= GROUND.LILYPOND then --  tile ~= GROUND.FIELDS and 
						table.insert(sorted, {ent, ent:GetDistanceSqToInst(self.head)})
					end
				end
			end
			if #sorted > 0 then
				table.sort( sorted, function( a, b ) return a[2] > b[2] end )				
				self.target = sorted[#sorted][1]
			end
		end		
		-- look for structures..
		-- look for player		
	end

	if self.target and self.target:IsValid() then
		return self.target
	end

	self.target = GetPlayer()
	return GetPlayer()
end

function RocController:OnUpdate(dt)

	local function getanglepointtopoint(x1,z1,x2,z2)			    
	    local dz = z1 - z2
	    local dx = x2 - x1
	    local angle = math.atan2(dz, dx) / DEGREES
	    return angle				
	end	

	local player = GetPlayer()
	local px,py,pz = player.Transform:GetWorldPosition()
	
	local ground = GetWorld()
	local tile = GetVisualTileType(px, py, pz)
	local onvalidtiles = true
	if tile == GROUND.FOUNDATION or tile == GROUND.COBBLEROAD or tile == GROUND.LAWN or tile == GROUND.LILYPOND or tile == GROUND.DEEPRAINFOREST or tile == GROUND.GASJUNGLE then	 --  tile == GROUND.FIELDS or
		onvalidtiles = false
	end

	if player.sg:HasStateTag("scary_to_predator") then
		onvalidtiles = false
	end

	-- Roc doesnt like the living artifact.
	if player.livingartifact then
		onvalidtiles = false
	end

	if TheCamera.interior then
		onvalidtiles = false
	end

	local onvaliddungtiles = false	

	local cx,cy,cz = self.inst.Transform:GetWorldPosition()
	local roctile = ground.Map:GetTileAtPoint(cx,cy,cz)

	if roctile == GROUND.RAINFOREST or roctile == GROUND.PLAINS then	 
		onvaliddungtiles = true
	end


	local disttoplayer = self.inst:GetDistanceSqToInst(player)
	if disttoplayer > SCREEN_DIST*SCREEN_DIST then
		-- has landed and is flying again, should leave now
		if self.liftoff and not self.inst.teleporting then
			print("FLY AWAY")
			self.inst:Remove()
		elseif not self.landed then			
			self.inst.Transform:SetRotation(self.inst:GetAngleToPoint(px, py, pz))
		end
	end

	if self.scaleup then
		local currentscale = self.inst.Transform:GetScale()
		if currentscale ~= self.scaleup.targetscale then
			local setscale = math.min( currentscale + (SCALERATE*dt), self.scaleup.targetscale )
			self:setscale(setscale)			
		else 
			self.scaleup = nil
		end
	end

	if self.inst.Transform:GetScale() == 1 and not self.landed and not self.liftoff then					
		if disttoplayer < LAND_PROX*LAND_PROX and onvalidtiles then
			self.landed = true
			self.inst:PushEvent("land")
		end			
	end

	local dungok = true
	if GetWorld().getworldgenoptions(GetWorld())["dungpile"] then
		if GetWorld().getworldgenoptions(GetWorld())["dungpile"] == "never" then
			dungok = false
		end
	end

	if not self.landed and onvaliddungtiles and dungok then				

		if self.dungtime > 0 then
			self.dungtime = math.max(self.dungtime - dt,0)
		else
			local pos = Vector3(self.inst.Transform:GetWorldPosition())
			local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 50, {"dungpile"})
			if #ents < 2 then
				
				self.inst:DoTaskInTime(1 + Remap(self.inst.Transform:GetScale(), 0.35, 1,2,0), function()
					local crap = SpawnPrefab("dungpile")
					crap.Transform:SetPosition(cx,cy,cz)
					crap.fall(crap)
				end)
			end
			self.dungtime = math.random()*10 + 2
		end		
	end

	if not self.busy then
		if self.landed and self.head and self.tail and self.leg1 and self.leg2 then
			if onvalidtiles and not GetClock():IsNight() and not player.components.health:IsDead() then

				local target = self:GetTarget()
				
				-- HEAD
				if not self.head.sg:HasStateTag("busy") then
					local targetpos =Vector3(target.Transform:GetWorldPosition())	
					local headdistsq = self.head:GetDistanceSqToInst(target) 
					if headdistsq > HEAD_ATTACK_DIST*HEAD_ATTACK_DIST then			
						self.head_vel = math.min(self.head_vel + (self.head_acc *dt), self.head_vel_max)
					else					
						if self.target:HasTag("isinventoryitem") or self.target == GetPlayer() then							
							if self.target == GetPlayer() and not self.target.sg:HasStateTag("cower") then
								GetPlayer():PushEvent("cower")
							end																
							if headdistsq < 0.2 then
								self.head:PushEvent("gobble")				
							end
						else
							self.head:PushEvent("bash")				
						end
						self.head_vel = math.max(self.head_vel - (self.head_acc *dt), 0)
					end
					local HEAD_VEL = self.head_vel *dt

					local angle = self.head:GetAngleToPoint(targetpos)*DEGREES
					local offset = Vector3(HEAD_VEL * math.cos( angle ), 0, -HEAD_VEL * math.sin( angle ))
					local pos = Vector3(self.head.Transform:GetWorldPosition())
					self.head.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)
				end

				-- BODY
				local bodistsq = self.inst:GetDistanceSqToInst(self.head) 
				local pos = Vector3(self.inst.Transform:GetWorldPosition())
				
				local BOD_VEL_MAX = self.speed
				local BOD_ACC_MAX = 0.5 --5
				local targetpos = Vector3(self.head.Transform:GetWorldPosition())
				local angle = self.head:GetAngleToPoint(pos)*DEGREES
				local offset = Vector3(1 * math.cos( angle ), 0, -1 * math.sin( angle ))
				offset.x = offset.x*HEADDIST_TARGET
				offset.z = offset.z*HEADDIST_TARGET
				targetpos = targetpos + Vector3(offset.x,0,offset.z)

				local bodistsq = self.inst:GetDistanceSqToPoint(targetpos) 

				if bodistsq > BODY_DIST_TOLLERANCE * BODY_DIST_TOLLERANCE then
					local cpbv = pos + Vector3(self.body_vel.x,0,self.body_vel.z)
					local angle = getanglepointtopoint(cpbv.x,cpbv.z,targetpos.x,targetpos.z)*DEGREES			
					local offset = Vector3(BOD_ACC_MAX * math.cos( angle ), 0, -BOD_ACC_MAX * math.sin( angle ))			
					local cpbvtv = cpbv + Vector3(offset.x,0,offset.z)
					local finalangle = self.inst:GetAngleToPoint(cpbvtv)*DEGREES
					local finalvel = math.min(BOD_VEL_MAX, math.sqrt(self.inst:GetDistanceSqToPoint(cpbvtv))    )
					self.body_vel = Vector3(finalvel * math.cos( finalangle ), 0, -finalvel * math.sin( finalangle ))
				else

					local angle = self.inst:GetAngleToPoint(targetpos)*DEGREES			
					local vel = math.max( math.sqrt((self.body_vel.x * self.body_vel.x) + (self.body_vel.z * self.body_vel.z)) - (BOD_ACC_MAX*dt) , 0)
					self.body_vel = Vector3(vel * math.cos( angle ), 0, -vel * math.sin( angle ))
				end
				self.inst.Transform:SetPosition(pos.x+(self.body_vel.x * dt),0,pos.z+(self.body_vel.z *dt)	)

				--TAIL
				local angle = (self.inst.Transform:GetRotation()*DEGREES) + PI
				local tailtarget =  Vector3(TAILDIST * math.cos( angle ), 0, -TAILDIST * math.sin( angle ))
				tailtarget =Vector3(self.inst.Transform:GetWorldPosition()) + tailtarget
				local taildistsq = self.tail:GetDistanceSqToPoint(tailtarget)
				local pos = Vector3(self.tail.Transform:GetWorldPosition())
				local TAIL_VEL_MAX = self.speed 
				local TAIL_ACC_MAX = 0.3 --5

				if taildistsq > 1 * 1 then
					local cpbv = pos + Vector3(self.tail_vel.x,0,self.tail_vel.z)
					local angle = getanglepointtopoint(cpbv.x,cpbv.z,tailtarget.x,tailtarget.z)*DEGREES			
					local offset = Vector3(TAIL_ACC_MAX * math.cos( angle ), 0, -TAIL_ACC_MAX * math.sin( angle ))			
					local cpbvtv = cpbv + Vector3(offset.x,0,offset.z)
					local finalangle = self.tail:GetAngleToPoint(cpbvtv)*DEGREES
					local finalvel = math.min(TAIL_VEL_MAX, math.sqrt(self.tail:GetDistanceSqToPoint(cpbvtv))    )
					self.tail_vel = Vector3(finalvel * math.cos( finalangle ), 0, -finalvel * math.sin( finalangle ))
				else

					local angle = self.tail:GetAngleToPoint(tailtarget)*DEGREES			
					local vel = math.max( math.sqrt((self.tail_vel.x * self.tail_vel.x) + (self.tail_vel.z * self.tail_vel.z)) - (TAIL_ACC_MAX*dt) , 0)
					self.tail_vel = Vector3(vel * math.cos( angle ), 0, -vel * math.sin( angle ))
				end
				self.tail.Transform:SetPosition(pos.x+(self.tail_vel.x * dt),0,pos.z+(self.tail_vel.z *dt)	)

				-- set rotations
				local headpos =Vector3(self.head.Transform:GetWorldPosition())

						-- body rotation has velocity. 
						local body_angular_vel_max = 36/3
						if not self.body_angle_vel then
							self.body_angle_vel = 0
						end
						
						local targetAngle = self.inst:GetAngleToPoint(headpos)
						local currentAngle = self.inst.Transform:GetRotation()
					
						if math.abs(anglediff( currentAngle, targetAngle)) < 20 then

							if self.body_angle_vel > 0 then
								self.body_angle_vel = math.max(0, self.body_angle_vel - (self.angular_body_acc *dt))
							elseif self.body_angle_vel < 0 then
								self.body_angle_vel = math.min(0, self.body_angle_vel + (self.angular_body_acc *dt))
							end
							
						else
							if targetAngle > currentAngle then
								if targetAngle - currentAngle < 180 then
									self.body_angle_vel = math.min(body_angular_vel_max, self.body_angle_vel + (self.angular_body_acc *dt))
								else
									self.body_angle_vel = math.max(-body_angular_vel_max, self.body_angle_vel - (self.angular_body_acc *dt))
								end
							else
								if currentAngle - targetAngle < 180 then
									self.body_angle_vel = math.max(-body_angular_vel_max, self.body_angle_vel - (self.angular_body_acc *dt))							
								else
									self.body_angle_vel = math.min(body_angular_vel_max, self.body_angle_vel + (self.angular_body_acc *dt))
								end						
							end
						end 

						--print("self.body_angle_vel",self.body_angle_vel)
						currentAngle = currentAngle + (self.body_angle_vel*dt)			
						self.inst.Transform:SetRotation( currentAngle )
				
				if not self.head.sg:HasStateTag("busy") then
					local targetpos =Vector3(target.Transform:GetWorldPosition())
					local angle = self.head:GetAngleToPoint(targetpos.x,targetpos.y,targetpos.z)
					self.head.Transform:SetRotation(angle)
				end

				--self.head.Transform:SetRotation(self.inst.Transform:GetRotation())	
				self.tail.Transform:SetRotation(self.inst.Transform:GetRotation())	

				-- LEGS
				if not self.leg1.sg:HasStateTag("walking") and not self.leg2.sg:HasStateTag("walking") then

					local legdir = PI/2
					if self.currentleg == 2 then
						legdir = legdir * -1
					end

					local angle = self.inst.Transform:GetRotation()*DEGREES

					local currentlegtargetpos = Vector3(self.inst.Transform:GetWorldPosition()) + Vector3(LEGDIST * math.cos( angle+legdir ), 0, -LEGDIST * math.sin( angle+legdir ))
					local legdistsq = self.currentleg:GetDistanceSqToPoint(currentlegtargetpos)
					local anglediff =  anglediff(self.currentleg.Transform:GetRotation(), self.inst.Transform:GetRotation())
					if legdistsq > LEG_WALKDIST * LEG_WALKDIST or anglediff > self.turn_threshold then

						if legdistsq < LEG_WALKDIST_BIG*LEG_WALKDIST_BIG  or (anglediff > self.turn_threshold and legdistsq <= LEG_WALKDIST_BIG*LEG_WALKDIST_BIG ) then
							self.currentleg:PushEvent("walkfast")
						else
							self.currentleg:PushEvent("walk")
						end
															
						if self.currentleg == self.leg1 then
							self.currentleg = self.leg2
						else
							self.currentleg = self.leg1
						end
					end			
				end
			else
				self.inst:PushEvent("liftoff")
			end
			-- move tail to point in position like head. 
		end
	end
end

function RocController:OnEntitySleep()
	self:Stop()
end

function RocController:OnEntityWake()
	self:Start()
end

function RocController:FadeInFinished()
    -- Last step in transition
    local player = GetPlayer()

    player.components.health:SetInvincible(self.player_was_invincible) 

    player.components.playercontroller:Enable(true)
    self.inst.teleporting = nil
end 

function RocController:FadeOutFinished()
	self.inst:DoTaskInTime( 2 , function()
	    for k, v in pairs(Ents) do
	        if v:HasTag("roc_nest") then
	            local pt = Vector3(v.Transform:GetWorldPosition())
	            GetPlayer().Transform:SetPosition(pt.x,pt.y,pt.z)
	            GetPlayer().components.sanity:DoDelta(-TUNING.SANITY_MED)
	            self.inst.Transform:SetPosition(pt.x,pt.y,pt.z)
	            TheCamera:Snap()

	            TheFrontEnd:SetFadeLevel(1)
	            GetPlayer():Show()
	            GetPlayer().HUD:Show()
	            GetPlayer():PushEvent("wakeup")
	            GetPlayer().DynamicShadow:Enable(true)
	            TheFrontEnd:Fade(true, 2, function() self:FadeInFinished() end)
	            break
	        end
	    end     
	end)
end

function RocController:teleport()
    TheFrontEnd:Fade(false, 2, function() self:FadeOutFinished() end)
end

function RocController:playergrabbed()
	 
	GetPlayer():PushEvent("grabbed")
	self.head:AddChild(GetPlayer())
	self.head:AddTag("HasPlayer")
	GetPlayer().Transform:SetRotation(self.head.Transform:GetRotation())
	GetPlayer().AnimState:SetFinalOffset(-10)

	GetPlayer().Transform:SetPosition(0,0,0)

	self.player_was_invincible = GetPlayer().components.health:IsInvincible()

    GetPlayer().components.health:SetInvincible(true)
    GetPlayer().components.playercontroller:Enable(false)
    GetPlayer().HUD:Hide()
    GetPlayer().DynamicShadow:Enable(false)
    
    self.inst:DoTaskInTime(2.5,function() self:teleport() end)
    self.inst.teleporting = true
end

function RocController:UnchildPlayer(inst)

	if not inst then
		inst = self.head
	end
    inst:RemoveChild(GetPlayer())
    GetPlayer().Transform:SetPosition(inst.Transform:GetWorldPosition())
    GetPlayer():Hide()
    inst:RemoveTag("HasPlayer")	
end

function RocController:OnSave()	
	local refs = {}
	local data = {}

	data.head_vel = self.head_vel

	data.body_vel_x = self.body_vel.x
	data.body_vel_z = self.body_vel.z

	data.tail_vel_x = self.tail_vel.x
	data.tail_vel_z = self.tail_vel.z

	data.dungtime = self.dungtime

	if self.currentleg then
		data.currentleg = self.currentleg.GUID
	end
	if self.scaleup then
		data.scaleup = self.scaleup.targetscale
	end
	if self.landed then
		data.landed = self.landed
	end
	if self.liftoff then
		data.liftoff = self.liftoff
	end

	data.scale = self.inst.Transform:GetScale()

	if self.head then
		data.head = self.head.GUID
		table.insert(refs,self.head.GUID)
	end
	if self.tail then
		data.tail = self.tail.GUID
		table.insert(refs,self.tail.GUID)
	end	
	if self.leg1 then
		data.leg1 = self.leg1.GUID
		table.insert(refs,self.leg1.GUID)
	end	
	if self.leg2 then
		data.leg2 = self.leg2.GUID
		table.insert(refs,self.leg2.GUID)
	end	

	return data, refs
end 

function RocController:OnLoad(data)

	data.body_vel_x = self.body_vel.x
	data.body_vel_z = self.body_vel.z

	data.tail_vel_x = self.tail_vel.x
	data.tail_vel_z = self.tail_vel.z

	self.head_vel = data.head_vel
	self.body_vel = {x=data.body_vel_x,z=data.body_vel_z}
	self.tail_vel = {x=data.tail_vel_x,z=data.tail_vel_z}
	self.dungtime = data.dungtime


	if data.currentleg then
		self.currentleg = data.currentleg
	end
	if data.scaleup then
		self.scaleup = {targetscale = data.scaleup}
	end
	if data.landed then
		self.landed = data.landed
	end
	if data.liftoff then
		self.liftoff = data.liftoff
	end
	
	self:setscale(data.scale)
end 

function RocController:LoadPostPass(ents, data)

	self.inst.bodyparts = {}
	if data.currentleg then
		self.currentleg = ents[data.currentleg].entity
	end
	if data.head then
		self.head = ents[data.head].entity
		self.head.body = self.inst
		self.head.controller = self
		table.insert(self.inst.bodyparts,self.head)
	end
	if data.tail then
		self.tail = ents[data.tail].entity
		self.tail.body = self.inst
		table.insert(self.inst.bodyparts,self.tail)
	end
	if data.leg1 then
		self.leg1 = ents[data.leg1].entity
		self.leg1.body = self.inst
		self.leg1.legoffsetdir = PI/2
		table.insert(self.inst.bodyparts,self.leg1)
	end
	if data.leg2 then
		self.leg2 = ents[data.leg2].entity
		self.leg2.body = self.inst
		self.leg2.legoffsetdir = - PI/2
		table.insert(self.inst.bodyparts,self.leg2)
	end

end

return RocController