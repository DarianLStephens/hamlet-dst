local quakelevels =
{
	pillarshake=
    { -- quake during tentacle pillar death throes
		prequake = -3,                                                           --the warning before the quake
		quaketime = function() return GetRandomWithVariance(1,.5) end, 	        --how long the quake lasts
		debrispersecond = function() return math.random(5, 6) end, 	--how much debris falls every second
		debrisbreakchance = 0.75,
		quakeintensiy = 0.6,
		nextquake = function() return TUNING.TOTAL_DAY_TIME * 100 end, 	        --how long until the next quake
		mammals = 0,
	},	

	cavein=
	{
		prequake = 3, 
		quaketime = function() return math.random(5, 8) + 5 end,
		debrispersecond = function() return math.random(9,10) end,
		debrisbreakchance = 0.95,
		quakeintensiy = 0.8,
		nextquake =  function() return TUNING.TOTAL_DAY_TIME * 0.5 + math.random() * TUNING.TOTAL_DAY_TIME end,
		mammals = 4,
	},

	queenattack =
	{
		prequake = 0,
		quaketime = function() return math.random(4, 8) end,
		debrispersecond = function() return math.random(15, 20) end,
		debrisbreakchance = 0.99,
		quakeintensiy = 0.1,
		nextquake =  function() return TUNING.TOTAL_DAY_TIME * 1000 end,
		mammals = 1,
		mammal_spawn_offset = {x = 2.5},
	},
}

local Interior_Quaker = Class(function(self,inst)
	self.inst = inst
	self.timetospawn = 0
	self.spawntime = 0.5
	self.quake = false
	self.inst:StartUpdatingComponent(self)
	self.emittingsound = false
	self.quakelevel = quakelevels["pillarshake"]
	self.prequake = self.quakelevel.prequake
	self.quaketime = self.quakelevel.quaketime()
	self.debrispersecond = self.quakelevel.debrispersecond()
	self.debrisbreakchance = 0.75
	self.quakeintensiy = 0.3
	self.debrisbreakchancedefault = 0.75
	self.nextquake = self.quakelevel.nextquake()
	self.mammals_per_quake = self.quakelevel.mammals
	self.doNextQuakes = true
	self.quakeentity = nil

	self.inst:ListenForEvent("explosion", function(inst, data)
		if not self.quake and self.nextquake > self.prequake + 1 then
			self.nextquake = self.nextquake - data.damage

			if self.nextquake < self.prequake then
				self.nextquake = self.prequake + 1
			end
		end
	 end)
end)

local debris =
{
	common = 
	{
		"rocks",
		"flint",
	},
	rare = 
	{
		"mole",
		"molebat",
		"spider",
		"nitre",
		--"rabid_beetle",
		"scorpion",
	},
	veryrare =
	{
		"goldnugget",
		"bluegem",
	},
	ultrarare =
	{
		"bluegem",
		"bluegem",
		"bluegem",
	},	
}


function Interior_Quaker:OnSave()
	if not self.noserial then
		return
		{
			quaketime = self.quaketime,
			debrispersecond = self.debrispersecond,
			debrisbreakchance = self.debrisbreakchance,
			quakeintensiy = self.quakeintensiy,
			mammals = self.mammals_per_quake,
			mammal_spawn_offset = self.mammal_spawn_offset,
		}
	end
	self.noserial = false
end

function Interior_Quaker:OnLoad(data)
	
	self.quaketime = data.quaketime or self.quakelevel.quaketime()
	self.debrispersecond = data.debrispersecond or self.quakelevel.debrispersecond()
	self.debrisbreakchance = data.debrisbreakchance or self.quakelevel.debrisbreakchance
	self.quakeintensiy = data.quakeintensiy
	self.mammals_per_quake = data.mammals or self.quakelevel.mammals
	self.mammal_spawn_offset = data.mammal_spawn_offset
end

function Interior_Quaker:OnProgress()
	self.noserial = true
end

function Interior_Quaker:GetDebugString()
	if self.nextquake > 0 then
		return string.format("%2.2f debris will drop every second. It will last for %2.2f seconds",
		 self.debrispersecond, self.quaketime)
	else
		return string.format("QUAKING")
	end
end

function Interior_Quaker:GetTimeForNextDebris()
	return 1/self.debrispersecond
end

function Interior_Quaker:GetMammalSpawnPoint()
	local basept = self.quakeentity:GetPosition()
	local interior = GetClosestInterior(self.quakeentity) 
	local interiordata
	
	if interior then
		basept = interior:GetPosition()
		interiordata = TheWorld.components.interiormanager:GetInteriorData(interior.interiornum)
	end
	
    local depth = 16
    local width = 24
	
	if interiordata then
		depth = interiordata.interiordata.depth
		width = interiordata.interiordata.width
	end
	
	if self.mammal_spawn_offset and self.mammal_spawn_offset.x then
		basept.x = basept.x + (self.mammal_spawn_offset.x + math.random() * ( (depth - self.mammal_spawn_offset.x)  /2))
	else
		basept.x = basept.x + (math.random()*depth - depth/2)
	end

	if self.mammal_spawn_offset and self.mammal_spawn_offset.z then
		basept.z = basept.z + (self.mammal_spawn_offset.z + math.random() * ( (width - self.mammal_spawn_offset.z)/2))
	else
		basept.z = basept.z + (math.random()*width - width/2)
	end

	return basept	
end

function Interior_Quaker:GetSpawnPoint(pt, rad)
	local basept = self.quakeentity:GetPosition()
	local interior = GetClosestInterior(self.quakeentity) 
	local interiordata
	
	if interior then
		basept = interior:GetPosition()
		interiordata = TheWorld.components.interiormanager:GetInteriorData(interior.interiornum)
	end
	
    local depth = 16
    local width = 24
	
	if interiordata then
		depth = interiordata.interiordata.depth
		width = interiordata.interiordata.width
	end
	
	basept.x = basept.x + (math.random()*depth - depth/2)
	basept.z = basept.z + (math.random()*width - width/2)

	return basept
end

function Interior_Quaker:StartQuake()
	self.inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "earthquake")
	self.inst.SoundEmitter:SetParameter("earthquake", "intensity", 1)
	self.quake = true
	self.inst:PushEvent("startquake")
end

function Interior_Quaker:EndQuake()
	self.quake = false
	self.inst:PushEvent("endquake")
	self.emittingsound = false
	self.inst.SoundEmitter:KillSound("earthquake")
	self.quakeintensiy = 0.3
end

function Interior_Quaker:IsQuaking()
	return self.quake
end

-- 
function Interior_Quaker:ForceQuake(level, inst)
	--print("FORCE QUAKE")
	self.quakeentity = inst
	--if self.quake then return false end  
	local templevel = quakelevels[level]
	local quaketime = self.quaketime
	local testquaketime = templevel.quaketime()
	if testquaketime > quaketime then
		quaketime = testquaketime
	end

	local debrispersecond = self.debrispersecond
	local testdebrispersecond = templevel.debrispersecond()
	if testdebrispersecond > debrispersecond then
		debrispersecond = testdebrispersecond
	end

	local debrisbreakchance = self.debrisbreakchance
	local testdebrisbreakchance = templevel.debrisbreakchance
	if testdebrisbreakchance > debrisbreakchance then
		debrisbreakchance = testdebrisbreakchance
	end

	local quakeintensiy = self.quakeintensiy
	local testquakeintensiy = templevel.quakeintensiy
	if testquakeintensiy > quakeintensiy then
		quakeintensiy = testquakeintensiy
	end

    if level and quakelevels[level] then
 	    self.quakelevel = quakelevels[level]
        self.quaketime = quaketime
        self.debrispersecond = debrispersecond
        self.debrisbreakchance = debrisbreakchance
        self.quakeintensiy = quakeintensiy
        self.nextquake = self.quakelevel.nextquake()
        self.mammals_per_quake  = self.quakelevel.mammals
        self.mammal_spawn_offset = self.quakelevel.mammal_spawn_offset
    end

	self:StartQuake()

    return true
end

local function UpdateShadowSize(inst, height)

	if inst and inst.shadow and inst.shadow:IsValid() then
		local scaleFactor = Lerp(0.5, 1.5, height/35)
		inst.shadow.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)
	end
end

local function GiveDebrisShadow(inst)
	local pt = Vector3(inst.Transform:GetWorldPosition())
	inst.shadow = SpawnPrefab("warningshadow")
	UpdateShadowSize(inst, 35)
	inst.shadow.Transform:SetPosition(pt.x, 0, pt.z)
end

function Interior_Quaker:GetDebris()
	local rng = math.random()
	local todrop = nil
	if rng < 0.75 then
		todrop = debris.common[math.random(1, #debris.common)]
	elseif rng >= 0.75 and rng < 0.95 then
--		if self.mammals_per_quake > 0 and GetWorld():IsRuins() then self.mammals_per_quake = 0 end -- Don't allow mammals to spawn from quakes in the ruins
		if self.mammals_per_quake > 0 then self.mammals_per_quake = 0 end
		todrop = debris.rare[math.random(1, #debris.rare)]
		-- Make sure we don't spawn a ton of mammals per quake
		local attempts = 0
		while self.mammals_per_quake <= 0 and (todrop == "mole" or todrop == "rabbit" or todrop == "scorpion" or todrop == "rabid_beetle") do
			todrop = debris.rare[math.random(1, #debris.rare)]
			attempts = attempts + 1
			if attempts > 10 then break end
		end
	elseif rng >= 0.95 and rng < 0.99 then
		todrop = debris.veryrare[math.random(1, #debris.veryrare)]
	else
		todrop = debris.ultrarare[math.random(1, #debris.ultrarare)]
	end
	return todrop
end

function Interior_Quaker:SpawnDebris(spawn_point)

    local prefab = self:GetDebris()
	if prefab then
	    local db = SpawnPrefab(prefab)
		
		if db then
			if (prefab == "rabbit" or prefab == "mole" or prefab == "scorpion" or prefab == "rabid_beetle") and db.sg then
				self.mammals_per_quake = self.mammals_per_quake - 1
				spawn_point = self:GetMammalSpawnPoint()
				db.sg:GoToState("fall")
			end
			
			if math.random() < .5 then
				db.Transform:SetRotation(180)
			end

			spawn_point.y = 35
			db.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)
		end
		
	    return db
	end
end

local function PlayFallingSound(inst, volume)
	volume = volume or 1
    local sound = inst.SoundEmitter
    if sound then
        local tile, tileinfo = inst:GetCurrentTileType()
        if tile and tileinfo then
			local x, y, z = inst.Transform:GetWorldPosition()
			local size_affix = "_small"
			sound:PlaySound(tileinfo.walksound .. size_affix, nil, volume)
        end
    end
end

local function grounddetection_update(inst)
	--print ("CALLING THE DETECTION")

	local pt = Point(inst.Transform:GetWorldPosition())
	
	if not inst.shadow then
		GiveDebrisShadow(inst)
	else
		UpdateShadowSize(inst, pt.y)
	end

	if pt.y < 2 then
		inst.fell = true
		inst.Physics:SetMotorVel(0,0,0)
    end

	if pt.y <= .2 then
		PlayFallingSound(inst)
		if inst.shadow then
			inst.shadow:Remove()
			inst.shadow = nil
		end

		local ents = TheSim:FindEntities(pt.x, 0, pt.z, 2, nil, {'INLIMBO','smashable'})
	    for k,v in pairs(ents) do
	    	if v and v.components.combat and not v.components.combat.debris_immune and v ~= inst then  -- quakes shouldn't break the set dressing
	    		v.components.combat:GetAttacked(inst, 20, nil)
	    	end
	   	end
	   	--play hit ground sound


	   	inst.Physics:SetDamping(0.9)

	    if inst.updatetask then
			inst.updatetask:Cancel()
			inst.updatetask = nil
		end

		local quaker = TheWorld.components.quaker_interior

		local breakchance = quaker.debrisbreakchance or quaker.debrisbreakchancedefault
		--print(breakchance)
		if math.random() < breakchance and not (inst.prefab == "mole" or inst.prefab == "rabbit" or inst.prefab == "scorpion" or inst.prefab == "rabid_beetle") then
			--spawn break effect
			inst.entity:AddSoundEmitter()
			inst.SoundEmitter:PlaySound("dontstarve/common/stone_drop")
			local pt = Vector3(inst.Transform:GetWorldPosition())
			local breaking = SpawnPrefab("ground_chunks_breaking")
			breaking.Transform:SetPosition(pt.x, 0, pt.z)
			inst:Remove()
		end
	end

	-- Failsafe: if the entity has been alive for at least 1 second, hasn't changed height significantly since last tick, and isn't near the ground, remove it and its shadow
	if inst.last_y and pt.y > 2 and inst.last_y > 2 and (inst.last_y - pt.y  < 1) and inst:GetTimeAlive() > 1 and not inst.fell then
		if inst.shadow then
			inst.shadow:Remove()
			inst.shadow = nil
		end
		inst:Remove()
	end
	inst.last_y = pt.y
end

local function start_grounddetection(inst)
	inst.updatetask = inst:DoPeriodicTask(0.1, grounddetection_update, 0.05)
end


function Interior_Quaker:MiniQuake(rad, num, duration, target)
	self.inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "miniearthquake")
	self.inst.SoundEmitter:SetParameter("miniearthquake", "intensity", 1)

    local time = 0
    for i=1,num do

    	self.inst:DoTaskInTime(time, function()
			local char_pos = Vector3(target.Transform:GetWorldPosition())
			local spawn_point = self:GetSpawnPoint(char_pos, rad)
			if spawn_point then
				local db = self:SpawnDebris(spawn_point)
				if db then
					start_grounddetection(db)
				end
			end
		end)

		time = time + duration/num
    end

    self.inst:DoTaskInTime(duration, function() self.inst.SoundEmitter:KillSound("miniearthquake") end)
end

function Interior_Quaker:SetNextQuakes( setting ) -- turn off the periodic quaking.
	self.doNextQuakes = setting
end

function Interior_Quaker:OnUpdate( dt )
--[[
	if self.doNextQuakes then
		if self.nextquake > 0 then
			self.nextquake = self.nextquake - dt

			if self.nextquake < self.prequake and not self.emittingsound then
				self:WarnQuake()
			end

		elseif self.nextquake <= 0 and not self.quake then		
			self:StartQuake()
		end
	end
]]

	if self.quake then
		if self.quaketime > 0 then
			self.quaketime = self.quaketime - dt
				if self.timetospawn > 0 then
					self.timetospawn = self.timetospawn - dt
				end

				if self.timetospawn <= 0 then
					local spawn_point = self:GetSpawnPoint()
					if spawn_point then
						local db = self:SpawnDebris(spawn_point)
						ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 1, self.quakeentity, 40)
						start_grounddetection(db)
						if self.spawntime then
							self.timetospawn = self:GetTimeForNextDebris()
						end
					end
				end
		else
			self:EndQuake()
		end
	end    
end

return Interior_Quaker
