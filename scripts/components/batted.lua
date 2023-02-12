local BAT_SPAWN_DIST = 5

local Batted = Class(function(self, inst)
    self.inst = inst
    self.phase = BATS.EMPTY
    self.neverattack = false

    self.timetoaddbat = self:GetAddTime()
    self.timetoattack = self:GetAttackTime()
    self.batstoattack = {}

    self.batcaves = {}
    self.inst:StartUpdatingComponent(self)
    self.caves_spawned = false
    self.diffmod = 1
end)

function Batted:OnSave()
	local refs = {}
	local data = {}
	data.neverattack = self.neverattack
	data.caves_spawned = self.caves_spawned
	
	if self.batstoattack and #self.batstoattack > 0 then
		data.batstoattack = {}
		for i, bat in ipairs(self.batstoattack) do
			table.insert(data.batstoattack, bat.GUID)
			table.insert(refs, bat.GUID)
		end
	end

	return data, refs
end 

function Batted:OnLoad(data)
	if data.caves_spawned then 
		self.task:Cancel()
		self.caves_spawned = true 
	end 
	self.neverattack = data.neverattack
end 

function Batted:LoadPostPass(ents, data)
	if data.batstoattack then
		self.batstoattack = {}
		for i,batGUID in ipairs(data.batstoattack) do
			table.insert(self.batstoattack, ents[batGUID] and ents[batGUID].entity)	
		end
	end	
end

function Batted:Disable(set)
	self.neverattack = set
end

function Batted:SetDiffMod(diff)
	self.diffmod = diff
end

function Batted:LongUpdate(dt)
	if not POPULATING then
		local dtbat = dt
		while dtbat > 0 do
			if dtbat < self.timetoaddbat then
				 self.timetoaddbat = self.timetoaddbat - dtbat
				 dtbat = 0
			else
				dtbat = dtbat - self.timetoaddbat
				self:AddBat()
				self.timetoaddbat = self:GetAddTime()
			end
		end

		local dtattack = dt
		while dtattack > 0 do
			if dtattack < self.timetoattack then
				 self.timetoattack = self.timetoattack - dtattack
				 dtattack = 0
			else
				dtattack = dtattack - self.timetoattack
				local ents = self:CollectBatsFromCaves()
				for i,ent in ipairs(ents)do
					table.insert(self.batstoattack, ent)
				end	
				self.timetoattack = self:GetAttackTime()						
			end
		end	
		if self.batstoattack and #self.batstoattack > 0 and not TheCamera.interior then
			self:DoBatAttack()
		end		
	end
end 

function Batted:OnUpdate(dt)

	-- slowly fill bat caves on a timer. 
	if self.neverattack == true then 
		self.inst:StopUpdatingComponent(self)
		return 
	end

	self.timetoattack = self.timetoattack - dt
	if self.timetoattack <= 0 then 		
		local ents = self:CollectBatsFromCaves()
		for i,ent in ipairs(ents)do
			table.insert(self.batstoattack, ent)
		end		
		self.timetoattack = self:GetAttackTime()
	end

	if self.batstoattack and #self.batstoattack > 0 and not TheCamera.interior then
		self:DoBatAttack()
	end

	self.timetoaddbat = self.timetoaddbat -dt
	if self.timetoaddbat <= 0 then
		self:AddBat()
		self.timetoaddbat = self:GetAddTime()
	end
end  

function Batted:GetAttackTime()
	local time = (TUNING.TOTAL_DAY_TIME* 3.5) + (TUNING.TOTAL_DAY_TIME*math.random())
	return time  -- 9999999 
end

function Batted:GetAddTime()
	local day = GetClock().numcycles
	local time = 130

	if day < 5 then
		time = 960   -- 1 bat every 2 days
	elseif day < 10 then
		time = 720   -- 1 bat every 1.5 days
	elseif day < 20 then
		time = 480    -- 1 bat a day
	elseif day < 40 then
		time = 360	-- 1.5 bats / day
	else
		time = 240	-- 2 bats / day
	end

	--local time =  math.max((1/(0.5 + 0.19*day + 0.0078*day^2 - 0.000092*day^3) * TUNING.TOTAL_DAY_TIME * 1.2), 0.1 * TUNING.TOTAL_DAY_TIME)
	if self.diffmod then
		time = time * self.diffmod	
	end
	return time -- 2
end

function Batted:GetBatsFromDays(days)
	local x = days
	--testing out curve fitting here	
	return math.ceil(0.5 + 0.19*x + 0.0078*x^2 - 0.000092*x^3)
end 


function Batted:ForceBatAttack()
	local ents = self:CollectBatsFromCaves()
	for i, ent in ipairs(ents) do
		table.insert(self.batstoattack, ent)
	end	

	self.timetoattack = 0
	--self:DoBatAttack()
end

function Batted:DoBatAttack()

	local pt = Vector3(GetPlayer().Transform:GetWorldPosition()) 

	local leader = nil
	if #self.batstoattack > 0 then
		GetPlayer():DoTaskInTime(5, function() GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUCE_BATS")) end)

		for i = #self.batstoattack, 1 , -1 do
			if self.batstoattack[i]:IsValid() then

				local bat = SpawnPrefab("circlingbat")
				local pt = GetPlayer():GetPosition()

				local spawn_pt = self:GetSpawnPoint(pt)
				if spawn_pt then
					bat.Transform:SetPosition(spawn_pt.x, spawn_pt.y, spawn_pt.z)

					bat.components.circler:SetCircleTarget(GetPlayer())
					bat.components.circler.dontfollowinterior = true
					bat.components.circler:Start()

					self.batstoattack[i]:Remove()
				end
			end		
		end

		self.batstoattack = {}
	end
end

function Batted:GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = BAT_SPAWN_DIST

	local offset = FindWalkableOffset(pt, theta, math.random()*radius, 12, true) --12

	if offset then
		local pos = pt +offset

		local ground = GetWorld()
	    local tile = GROUND.GRASS
	    if ground and ground.Map then
	        tile = self.inst:GetCurrentTileType(pos:Get())

		    local onWater = ground.Map:IsWater(tile)
		    if not onWater then 
		    	return pos
		    end 
	    end
	end
end

function Batted:AddBat()	
	local bats = self:CountBats()
	if bats < 25 then
		local cave = self.batcaves[math.random(#self.batcaves)]
		local interiorSpawner = GetWorld().components.interiorspawner
		local interior  = interiorSpawner:GetInteriorByName(cave)
		local pos = {
						x_offset= (math.random()*interior.height) - interior.height/2,
						z_offset= (math.random()*interior.depth) - interior.depth/2
					}

		local prefabdata = { startstate = "forcesleep", }
		interiorSpawner:insertprefab(interior,"vampirebat",pos,prefabdata)
		print("ADDING BAT", cave)
	end
end

function Batted:CountBats()
	local bats = 0
	for i, interiorname in ipairs(self.batcaves) do
		--print("INTERIOR",interiorname)
		local interiorSpawner = GetWorld().components.interiorspawner
		local interior  = interiorSpawner:GetInteriorByName(interiorname)

		if interior.prefabs and #interior.prefabs > 0 then
			for i = #interior.prefabs, 1, -1 do
				local potentialprefab = interior.prefabs[i]
				
				if potentialprefab.name == "vampirebat" then
					bats = bats + 1
				end
			end
		end
	
		if interior.object_list and #interior.object_list > 0 then
			for i = #interior.object_list, 1, -1 do
				local prefab = interior.object_list[i]
				if prefab.prefab == "vampirebat" then
					bats = bats + 1				
				end
			end		
		end
	end

	return bats
end

function Batted:CollectBatsFromCaves()
	local bats = {}
	for i, interiorname in ipairs(self.batcaves) do
		--print("INTERIOR",interiorname)
		local interiorSpawner = GetWorld().components.interiorspawner
		local interior  = interiorSpawner:GetInteriorByName(interiorname)

		if interior.prefabs and #interior.prefabs > 0 then
			for i = #interior.prefabs, 1, -1 do
				local potentialprefab = interior.prefabs[i]
				
				if potentialprefab.name == "vampirebat" then
					local bat = SpawnPrefab("vampirebat")
					table.insert(bats,bat)					
					table.remove(interior.prefabs, i)
				end				
			end
		end
		
		--print("ACTUALS", #interior.object_list)
		if interior.object_list and #interior.object_list > 0 then
			for i = #interior.object_list, 1, -1 do
				
				local prefab = interior.object_list[i]
				if prefab.prefab == "vampirebat" then
					table.insert(bats,prefab)
					table.remove(interior.object_list, i)					
				end 
			end		
		end
	end

	--print("TOTAL BATS = ", #bats)
	return bats
end

function Batted:RegisterInterior(interior)
	table.insert(self.batcaves, interior)
end

function Batted:UnRegisterInterior( interior )
	for i, cave in ipairs(self.batcaves) do
		if cave == interior then
			self.batcaves[i] = nil
			break
		end
	end
end

return Batted