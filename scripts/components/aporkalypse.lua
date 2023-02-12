local Aporkalypse = Class(function(self, inst)
    self.inst = inst
    self.begin_date = 60 * TUNING.TOTAL_DAY_TIME
    self.aporkalypse_active = false
    self.inside_ruins = false
    self.near_days = 7

    self.bat_task = nil
    self.bat_amount = 15

    self.clock_dungeon = math.random(1,3)

    self.herald_spawn_table = 
    {
    	self.SpawnNightmares,
    	self.SpawnGhosts,
    	self.SpawnFrogRain,
    	self.SpawnFireRain
	}

	self.fiesta_active = false
	self.fiesta_begin_date = 0
	self.fiesta_duration = 5 * TUNING.TOTAL_DAY_TIME
	self.fiesta_task = nil

	self.first_time = true

    self.inst:ListenForEvent("clocktick", function(inst, data) 
    	-- if GetClock():GetTotalTime() >= self.begin_date and not self:IsActive() then
    	if TheWorld.state.cycles >= self.begin_date and not self:IsActive() then
    		self:BeginAporkalypse()
    	end
    end)

    self.inst:ListenForEvent("seasonChange", function(inst, data)
    	if self.aporkalypse_active and data.season ~= SEASONS.APORKALYPSE then
    		--self:EndAporkalypse()
    	end
    end)

    self.inst:ListenForEvent("enterinterior", function(inst, data)
    	if data.to_target and data.to_target:HasTag("ruins_entrance") then
    		self.inside_ruins = true
    	end
    end)

    self.inst:ListenForEvent("exitinterior", function(inst, data)
    	self.inside_ruins = false
    end)

    self.inst:ListenForEvent("doorused", function (inst, data)
    	if self.inside_ruins and self.aporkalypse_active then
    		self:SpawnInteriorGhosts()
    	end
    end)

end)

function Aporkalypse:OnSave()
	return 
	{
		current_season = self.current_season,
		begin_date = self.begin_date,
		aporkalypse_active = self.aporkalypse_active,
		current_season = self.current_season,
		inside_ruins = self.inside_ruins,
		fiesta_active = self.fiesta_active,
		fiesta_begin_date = self.fiesta_begin_date,
		first_time = self.first_time,
	}
end

function Aporkalypse:OnLoad(data)

	print ("LOADING APORKALYPSE")

	if data.current_season then
		self.current_season = data.current_season
	end

	if data.begin_date then
		self.begin_date = data.begin_date
	else
		-- self.begin_date = GetClock():GetTotalTime() + (60 * TUNING.TOTAL_DAY_TIME)
		self.begin_date = TheWorld.state.cycles + (60 * TUNING.TOTAL_DAY_TIME)
	end

	if data.aporkalypse_active then
		self.aporkalypse_active = data.aporkalypse_active
		self:ScheduleAporkalypseTasks()
	end

	if data.current_season then
		self.current_season = data.current_season
	end

	if data.inside_ruins then
		self.inside_ruins = data.inside_ruins
	end

	if data.fiesta_active then
		-- TODO: should we push "beginfiesta" here?

		self.fiesta_active = data.fiesta_active
		self.fiesta_begin_date = data.fiesta_begin_date

		-- local fiesta_elapsed = GetClock():GetTotalTime() - self.fiesta_begin_date
		local fiesta_elapsed = TheWorld.state.cycles - self.fiesta_begin_date

		self.fiesta_task = self.inst:DoTaskInTime(self.fiesta_duration - fiesta_elapsed, function() 
			self.fiesta_active = false
			self.inst:PushEvent("endfiesta")
		end)
	end

	self.first_time = data.first_time
end

function Aporkalypse:ScheduleAporkalypse(date)
	-- local currentTime = GetClock():GetTotalTime()
	local currentTime = TheWorld.state.cycles

	-- local delta = date - GetClock():GetTotalTime()
	local delta = date - TheWorld.state.cycles

	local daytime = 60 * TUNING.TOTAL_DAY_TIME
    while delta > daytime do
        delta = delta % daytime
    end

    while delta < 0 do
        delta = delta + daytime
    end

	self.begin_date = currentTime + delta
end

function Aporkalypse:ScheduleAporkalypseTasks()
	self:ScheduleBatSpawning()
	self:ScheduleHeraldCheck()
end

function Aporkalypse:BeginAporkalypse()
	if self.aporkalypse_active then
		return
	end

	self.aporkalypse_active = true

	local seasonmanager = GetSeasonManager()
	self.current_season = seasonmanager:GetSeason()

	seasonmanager:SetAporkalypseLength(self.first_time and 10000 or TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT)
	seasonmanager:StartAporkalypse()

	GetClock():SetBloodMoon(true)

	self:ScheduleAporkalypseTasks()

	self.inst:PushEvent("beginaporkalypse")
end


function Aporkalypse:BeginFiesta()
	self.fiesta_active = true
	-- self.fiesta_begin_date = GetClock():GetTotalTime()
	self.fiesta_begin_date = TheWorld.state.cycles
	self.inst:PushEvent("beginfiesta")
	self.fiesta_task = self.inst:DoTaskInTime(self.fiesta_duration, function()
		self:EndFiesta()
	end)	
end
function Aporkalypse:EndFiesta()
	self.fiesta_active = false
	self.inst:PushEvent("endfiesta")
end

function Aporkalypse:EndAporkalypse()
	if not self.aporkalypse_active then
		return
	end

	self.aporkalypse_active = false
	GetClock():SetBloodMoon(false)

	self:CancelBatSpawning()
	self:CancelHeraldCheck()

	GetSeasonManager():ResumePreviousSeason()

	-- local aporkalypse_duration = (GetClock():GetTotalTime() - self.begin_date) / TUNING.TOTAL_DAY_TIME
	local aporkalypse_duration = (TheWorld.state.cycles - self.begin_date) / TUNING.TOTAL_DAY_TIME
	if aporkalypse_duration >= 2 then
		self:BeginFiesta()
	end

	self.first_time = false

	-- Schedule the next one!
	-- self:ScheduleAporkalypse(GetClock():GetTotalTime() + (60 * TUNING.TOTAL_DAY_TIME))
	self:ScheduleAporkalypse(TheWorld.state.cycles + (60 * TUNING.TOTAL_DAY_TIME))
	self.inst:PushEvent("endaporkalypse")
end

function Aporkalypse:ScheduleBatSpawning()
	self:CancelBatSpawning()
	self.bat_task = self.inst:DoTaskInTime(TUNING.TOTAL_DAY_TIME + (TUNING.TOTAL_DAY_TIME * math.random(0, 0.25)), function() self:SpawnBats() end)
end

function Aporkalypse:CancelBatSpawning()
	if self.bat_task then
		self.bat_task:Cancel()
		self.bat_task = nil
	end
end

function Aporkalypse:SpawnBats()
	local batted = GetWorld().components.batted
	for i=1, self.bat_amount do
		batted:AddBat()
	end

	batted:ForceBatAttack()
	self:ScheduleBatSpawning()
end

function Aporkalypse:ScheduleHeraldCheck()

	self:CancelHeraldCheck()
	self.herald_check_task = self.inst:DoTaskInTime(math.random(TUNING.TOTAL_DAY_TIME/3, TUNING.TOTAL_DAY_TIME),
		function() 
			local player = GetPlayer()
			if player and not player.components.health:IsDead() then
				local herald = GetClosestInstWithTag("ancient", player, 20)
				
				if herald == nil then
					if not TheWorld.components.interiorspawner:IsPlayerConsideredInside() then
						self:SpawnRandomInRange("ancient_herald", 1, 1, 10)
					end
				else
					herald.components.combat:SuggestTarget(player)
				end

				self:ScheduleHeraldCheck()
			end
		end
	)
end

function Aporkalypse:CancelHeraldCheck()
	if self.herald_check_task then
		self.herald_check_task:Cancel()
		self.herald_check_task = nil
	end
end

function Aporkalypse:SpawnInteriorPrefabs(prefab, min, max, findtags)
	local function getoffset()
		local offset_x = math.random() * TUNING.ROOM_SMALL_DEPTH / 2
		local offset_z = math.random() * TUNING.ROOM_SMALL_WIDTH / 2

		if math.random() < 0.5 then
	        offset_x = offset_x * -1
	    end

	    if math.random() < 0.5 then
	        offset_z = offset_z * -1
	    end

	    return offset_x, offset_z
	end

	local pt = GetWorld().components.interiorspawner:GetSpawnOrigin()
    local ents = TheSim:FindEntities(pt.x, pt.y,pt.z, 20, findtags)

	if next(ents) == nil then
		local count = math.random(min, max)
		for i=1,count do
			local offset_x, offset_z = getoffset()

	    	offset_x = pt.x + offset_x
	    	offset_z = pt.z + offset_z

			local object = SpawnPrefab(prefab)
			object.Transform:SetPosition(offset_x, pt.y, offset_z)
			object:AddTag("aporkalypse_cleanup")

			if object.components.combat then
				object.components.combat:SuggestTarget(GetPlayer())
			end
		end
	end
end

function Aporkalypse:SpawnInteriorGhosts()
	self:SpawnInteriorPrefabs("pigghost", 2, 5, {"ghost"})
end

function Aporkalypse:SpawnRandomInRange(prefab, min_count, max_count, radius, offset_y)
	
	local objs = {}
	offset_y = offset_y or 0

	local player = GetPlayer()
	if not player or player.components.health:IsDead() then
		return {}
	end

	local pt = Vector3(player.Transform:GetWorldPosition())

	local count = math.random(min_count, max_count)

	local function getrandomoffset()
	    local theta = math.random() * 2 * PI
		local offset = FindWalkableOffset(pt, theta, radius, 12, true)
		if offset then
			return pt+offset
		end
	end

	for i=1, count do
		local spawn_pt = getrandomoffset()
		if spawn_pt then
			if offset_y then
				spawn_pt.y = spawn_pt.y + offset_y
			end

			local obj = nil
			if type(prefab) == "table" then
				obj = SpawnPrefab(prefab[math.random(1, #prefab)])
			else
				obj = SpawnPrefab(prefab)
			end

			if obj.Physics then
				obj.Physics:Teleport(spawn_pt:Get())
			else
				obj.Transform:SetPosition(spawn_pt.x, spawn_pt.y, spawn_pt.z)
			end

			if obj.components.combat then
				obj.components.combat:SuggestTarget(player)
			end

			obj:AddTag("aporkalypse_cleanup")
			table.insert(objs, obj)
		end
	end

	return objs
end


function Aporkalypse:SpawnNightmares()
	local nightmares = self:SpawnRandomInRange({ "nightmarebeak", "crawlingnightmare"}, 2, 4, 10)

	for k,nightmare in pairs(nightmares) do
		nightmare:AddTag("aporkalypse_cleanup")
		
		-- Injecting this here because I don't wanna change a base game prefab
		nightmare:ListenForEvent("endaporkalypse",
	        function(eventsender)
	            if nightmare:HasTag("aporkalypse_cleanup") then
	                nightmare:Remove()
	            end
	        end, 
	    GetWorld())
	end
end

function Aporkalypse:SpawnGhosts()
	self:SpawnRandomInRange("pigghost", 4, 6, 10)
end

function Aporkalypse:SpawnFrogRain()
	local function cancelrain()
		if self.frograintask then
			self.frograintask:Cancel()
			self.frograintask = nil
		end
	end

	cancelrain()

	local count = 0
	local max = 5

	self.frograintask = self.inst:DoPeriodicTask(0.2, 
		function() 
			local objs = self:SpawnRandomInRange("frog_poison", 1, 4, 8, 35)
			
			for k,v in pairs(objs) do
				v.sg:GoToState("fall")
			end

			count = count + 1
			if count >= max then
				cancelrain()
			end
		end
	)
end

function Aporkalypse:SpawnFireRain()
	local objs = self:SpawnRandomInRange("firerain", 1, 4, 6)
			
	for k,v in pairs(objs) do
		v.StartStepWithDelay(v, math.random() * 2)
	end	
end

function Aporkalypse:HeraldSpawnAttack()
	local fn = self.herald_spawn_table[math.random(1, #self.herald_spawn_table)]
	fn(self)
end

function Aporkalypse:GetClockDungeon()
	return "RUINS_" .. self.clock_dungeon
end

function Aporkalypse:IsNear()
	-- return self.begin_date - GetClock():GetTotalTime() < self.near_days * TUNING.TOTAL_DAY_TIME
	return self.begin_date - TheWorld.state.cycles < self.near_days * TUNING.TOTAL_DAY_TIME
end

function Aporkalypse:GetBeginDate()
	return self.begin_date
end

function Aporkalypse:IsActive()
	return self.aporkalypse_active
end

function Aporkalypse:GetFiestaActive()
	return self.fiesta_active
end

return Aporkalypse