local activelisteners = 0

local Hackable = Class(function(self, inst)
    self.inst = inst
    self.canbehacked = nil
    self.hasbeenhacked = nil
    self.regentime = nil
    self.baseregentime = nil
    self.product = nil
    self.onregenfn = nil
    self.onpickedfn = nil
    self.makeemptyfn = nil
    self.makefullfn = nil
    self.makebarrenfn = nil
    self.cycles_left = nil
    self.transplanted = false
    self.caninteractwith = true

	self.paused = false
    self.pause_time = 0

    self.protected_cycles = nil
    self.wither_time = nil
    self.withered = false
    self.shouldwither = false
    self.witherable = false
    self.protected = false
    self.wildfirestarter = false
    
    -- if SaveGameIndex:GetCurrentMode() == "volcano" or SaveGameIndex:GetCurrentMode() == "shipwrecked" then
        -- self.wither_temp = math.random(TUNING.SW_MIN_PLANT_WITHER_TEMP, TUNING.SW_MAX_PLANT_WITHER_TEMP)
    	-- self.rejuvenate_temp = math.random(TUNING.SW_MIN_PLANT_REJUVENATE_TEMP, TUNING.SW_MAX_PLANT_REJUVENATE_TEMP)
    -- else
        self.wither_temp = math.random(TUNING.MIN_PLANT_WITHER_TEMP, TUNING.MAX_PLANT_WITHER_TEMP)
    	self.rejuvenate_temp = math.random(TUNING.MIN_PLANT_REJUVENATE_TEMP, TUNING.MAX_PLANT_REJUVENATE_TEMP)
    -- end

    self.hacksleft = 1
    self.maxhacks = 1
	self.repeat_hack_cycle = false
	
    self.reverseseasons = nil

	self.witherHandler = function(it, data)
		local tempcheck = false
		if self.reverseseasons then
			tempcheck = data.temp <= self.rejuvenate_temp
		else
			tempcheck = data.temp > self.wither_temp
		end

    	if self.witherable and not self.withered and not self.protected and tempcheck and 
    	   (self.protected_cycles == nil or self.protected_cycles < 1) then
    		self.withered = true
    		self.inst:AddTag("withered")
    		self.wither_time = GetTime()
    		self:MakeBarren()
    	end
    end
	self.rejuvenateHandler = function(it, data)
		local tempcheck = false
		if self.reverseseasons then
			tempcheck = data.temp >= self.wither_temp
		else
			tempcheck = data.temp < self.rejuvenate_temp
		end

		if tempcheck then
	    	local time_since_wither = GetTime()
	    	if self.wither_time then 
	    		time_since_wither = time_since_wither - self.wither_time
	    	else
	    		time_since_wither = TUNING.TOTAL_DAY_TIME
	    	end
	    	if self.withered and time_since_wither >= TUNING.TOTAL_DAY_TIME then
	    		if self.cycles_left and self.cycles_left <= 0 then
	    			self:MakeBarren()
	    		else
	    			self:MakeEmpty()
	    		end
	    		self.withered = false
	    		self.inst:RemoveTag("withered")
	    		self.shouldwither = false
	    		self.witherable = true
	    		self.inst:AddTag("witherable")
	    	elseif self.shouldwither and time_since_wither >= TUNING.TOTAL_DAY_TIME then
	    		self.shouldwither = false
	    		self.witherable = true
	    		self.inst:AddTag("witherable")
	    	end
	    end
	end
end)

function Hackable:CheckPlantState()
	-- local data = { temp = GetSeasonManager():GetCurrentTemperature() }
	local data = { temp = TheWorld.state.temperature }
	self:witherHandler(data)
	self:rejuvenateHandler(data)
end

function Hackable:StartListeningToEvents()
	if self.reverseseasons then
	    self.inst:ListenForEvent("witherplants", self.rejuvenateHandler, GetWorld())
	    self.inst:ListenForEvent("rejuvenateplants", self.witherHandler, GetWorld())
	else
	    self.inst:ListenForEvent("witherplants", self.witherHandler, GetWorld())
	    self.inst:ListenForEvent("rejuvenateplants", self.rejuvenateHandler, GetWorld())
	end
end

function Hackable:StopListeningToEvents()
	if self.reverseseasons then
	    self.inst:RemoveEventCallback("witherplants", self.rejuvenateHandler, GetWorld())
	    self.inst:RemoveEventCallback("rejuvenateplants", self.witherHandler, GetWorld())
	else
		self.inst:RemoveEventCallback("witherplants", self.witherHandler, GetWorld())
    	self.inst:RemoveEventCallback("rejuvenateplants", self.rejuvenateHandler, GetWorld())
    end
end

function Hackable:SetReverseSeasons(reverse)
	self:StopListeningToEvents()
	self.reverseseasons = reverse
	self:StartListeningToEvents()
end

function Hackable:OnEntitySleep()
	self:StopListeningToEvents()
end

function Hackable:OnEntityWake()
	self.wither_time = nil

	self:CheckPlantState()
	self:StartListeningToEvents()
end


function Hackable:LongUpdate(dt)

	self.wither_time = nil

	if not self.paused and self.targettime and not self.withered then
	
		if self.task then 
			self.task:Cancel()
			self.task = nil
		end
	
	    local time = GetTime()
		if self.targettime > time + dt then
	        --resechedule
	        local time_to_pickable = self.targettime - time - dt
	        time_to_pickable = time_to_pickable * self:GetGrowthMod()
			self.task = self.inst:DoTaskInTime(time_to_pickable, OnHackableRegen, "regen")
			self.targettime = time + time_to_pickable
	    else
			--become pickable right away
			self:Regen()
	    end
	end
end

function Hackable:IsWithered()
	return self.withered
end

function Hackable:MakeWitherable()
	self.witherable = true
	self.inst:AddTag("witherable")
end

function Hackable:Rejuvenate(fertilizer)
	if self.inst.components.burnable then
        self.inst.components.burnable:StopSmoldering()
    end

	if self.protected_cycles ~= nil then
		self.protected_cycles = self.protected_cycles + fertilizer.components.fertilizer.withered_cycles
	else
		self.protected_cycles = fertilizer.components.fertilizer.withered_cycles
	end

	if self.protected_cycles >= 1 then
		self.withered = false
		self.inst:RemoveTag("withered")
		self.witherable = false
		self.inst:RemoveTag("witherable")
		self.shouldwither = true
		self:Regen()

		-- self.inst:DoTaskInTime(TUNING.TOTAL_DAY_TIME*7, function() 
		-- 	if self.shouldwither then
		-- 		self.witherable = true
		-- 		self.shouldwither = false
		-- 		if not self.withered and GetSeasonManager:GetTemperature() > self.wither_temp then
		-- 			self.withered = true
		--     		self.wither_time = GetTime()
		--     		self:MakeBarren()
		--     		while self.protected_cycles >= 1 do
		--     			self.protected_cycles = self.protected_cycles - 1
		--     		end
		--     	end
		-- 	end
		-- end)
	else
		GetPlayer():PushEvent("insufficientfertilizer")
	end
end

function Hackable:IsWildfireStarter()
	return (self.wildfirestarter == true or self.withered == true)
end

function Hackable:FinishGrowing()
	if not self.canbehacked and not self.withered then
		if self.task then
			self.task:Cancel()
			self.task = nil	
			self:Regen()
		end
	end
end

function Hackable:Resume()
	if self.paused then
		self.paused = false
		if not self.canbehacked and (not self.cycles_left or self.cycles_left > 0) then
		
			if self.pause_time then
				self.pause_time = self.pause_time * self:GetGrowthMod()
				self.task = self.inst:DoTaskInTime(self.pause_time, OnHackableRegen, "regen")
				self.targettime = GetTime() + self.pause_time
			else
				self:MakeEmpty()
			end
			
		end
	end
end

function Hackable:Pause()
	if self.paused == false then
		self.pause_time = nil
		self.paused = true
		
		if self.task then
			self.task:Cancel()
			self.task = nil	
		end
		
		if self.targettime then
			self.pause_time = math.max(0, self.targettime - GetTime())
		end
	end
end

function Hackable:GetDebugString()
	local time = GetTime()

	local str = ""
	if self.caninteractwith then
		str = "caninteractwith"
	elseif self.paused then
		str = "paused"
		if self.pause_time then
			str = str.. string.format(" %2.2f", self.pause_time)
		end
	elseif self.transplanted then
		str = "cycles:" .. tostring(self.cycles_left) .. " / " .. tostring(self.max_cycles)
		if self.targettime and self.targettime > time then
			str = str.." Regen in:" ..  tostring(math.floor(self.targettime - time))
		end
	else
		str = "Not transplanted "
		if self.targettime and self.targettime > time then
			str = str.." Regen in:" ..  tostring(math.floor(self.targettime - time))
		end
	end
	str = str .. " || withertemp: " .. self.wither_temp .. " rejuvtemp: " .. self.rejuvenate_temp
	return str
end

function Hackable:GetGrowthMod()
	if self.reverseseasons then
		return 1
	end

	local mod = 1.0
	-- local sm = GetSeasonManager()
	-- if sm and (sm:IsSpring() or sm:IsGreenSeason()) then
	if sm and (TheWorld.state.isspring) then --or sm:IsGreenSeason()) then
		mod = TUNING.SPRING_GROWTH_MODIFIER
	end
	return mod
end

function Hackable:SetUp(product, regen, number)
    self.canbehacked = true
    self.inst:RemoveTag("stump")
    self.hasbeenhacked = false
    self.product = product
    self.baseregentime = regen
    self.regentime = regen
end

function Hackable:SetOnPickedFn(fn)
	self.onpickedfn = fn
end

function Hackable:SetOnRegenFn(fn)
	self.onregenfn = fn
end

function Hackable:SetMakeBarrenFn(fn)
	self.makebarrenfn = fn
end

function Hackable:SetMakeEmptyFn(fn)
	self.makeemptyfn = fn
end

function Hackable:CanBeFertilized()
	if self.fertilizable ~= false and self.cycles_left == 0 then
		return true
	end
	if self.fertilizable ~= false and self.withered then--(self.withered or self.shouldwither) then
		return true
	end
end

function Hackable:Fertilize(fertilizer)
	if self.inst.components.burnable then
        self.inst.components.burnable:StopSmoldering()
    end

    if fertilizer.components.finiteuses then
        fertilizer.components.finiteuses:Use()
    else
        fertilizer.components.stackable:Get(1):Remove()
    end
	self.cycles_left = self.max_cycles

	-- self:MakeEmpty() used to be an OR result of this function.. but then things like 
	-- vines and bamboo would go from withered to full and ready to harvest right away after fertalizing.
	-- It seemed that all of these items need to be set empty after being fertalized, so it was taken out.
	if self.withered or self.shouldwither then
		self:Rejuvenate(fertilizer)
	end	
	self:MakeEmpty()
end

function Hackable:OnSave()
	
	local data = { 
		withered = self.withered,
		shouldwither = self.shouldwither,
		protected_cycles = self.protected_cycles,
		picked = not self.canbehacked and true or nil, 
		transplanted = self.transplanted and true or nil,
		paused = self.paused and true or nil,
		caninteractwith = self.caninteractwith and true or nil,
		hacksleft = self.hacksleft, 
		--pause_time = self.pause_time 
	}

	if self.cycles_left ~= self.max_cycles then
		data.cycles_left = self.cycles_left
		data.max_cycles = self.max_cycles 
	end
	
	if self.pause_time and self.pause_time > 0 then
		data.pause_time = self.pause_time
	end
	
	if self.targettime then
	    local time = GetTime()
		if self.targettime > time then
	        data.time = math.floor(self.targettime - time)
	    end
	end
	
    if next(data) then
		return data
	end
	
end

function Hackable:OnLoad(data)

	self.transplanted = data.transplanted or false
	
	self.cycles_left = data.cycles_left or self.cycles_left
	self.max_cycles = data.max_cycles or self.max_cycles
	self.hacksleft = self.hacksleft
	
	if (data.picked or data.time) and not self.repeat_hack_cycle then
        if self.cycles_left == 0 and self.makebarrenfn then
			self.makebarrenfn(self.inst)
        elseif self.makeemptyfn then
			self.makeemptyfn(self.inst)
		end
        self.canbehacked = false
        self.inst:AddTag("stump")
        self.hasbeenhacked = true
	else
		if self.makefullfn then
			self.makefullfn(self.inst)
		end
		self.canbehacked = true
        self.inst:RemoveTag("stump")
		self.hasbeenhacked = false
	end
    
    if data.caninteractwith then
    	self.caninteractwith = data.caninteractwith
    end

    if data.paused then
		self.paused = true
		self.pause_time = data.pause_time
    else
		if data.time then
			self.task = self.inst:DoTaskInTime(data.time, OnHackableRegen, "regen")
			self.targettime = GetTime() + data.time
		end
	end    

	if data.makealwaysbarren == 1 then
		if self.makebarrenfn then
			self:MakeBarren()
		end
	end

	self.withered = data.withered
	self.shouldwither = data.shouldwither
	self.protected_cycles = data.protected_cycles
	if self.withered then
		self:MakeBarren()
	end
end

function Hackable:IsBarren()
	return self.cycles_left and self.cycles_left == 0
end

function Hackable:CanBeHacked()
    return self.canbehacked
end

function OnHackableRegen(inst)

	if inst.components.hackable then
		inst.components.hackable:Regen()
	end
end

function Hackable:Regen()
    
    self.canbehacked = true
    self.inst:RemoveTag("stump")
    self.hasbeenhacked = false
    self.hacksleft = self.maxhacks
    if self.onregenfn then
        self.onregenfn(self.inst)
    end
    if self.makefullfn then
    	self.makefullfn(self.inst)
    end
    self.targettime = nil
    self.task = nil
end

function Hackable:MakeBarren()
	
	if not self.withered then 
		self.cycles_left = 0
	end
	
    self.canbehacked = false
	self.inst:AddTag("stump")
    if self.task then
		self.task:Cancel()
    end
    
	if self.makebarrenfn then
		self.makebarrenfn(self.inst)
	end
end

function Hackable:OnTransplant()
	self.transplanted = true
	
	if self.ontransplantfn then
		self.ontransplantfn(self.inst)
	end
end

function Hackable:MakeEmpty()
    if self.task then
		self.task:Cancel()
    end
    
	if self.makeemptyfn then
		self.makeemptyfn(self.inst)
	end

    self.canbehacked = false
    self.inst:AddTag("stump")
    
	if not self.paused then
		if self.baseregentime then
			local time = self.baseregentime
			
			if self.getregentimefn then
				time = self.getregentimefn(self.inst)
			end
			
			time = time * self:GetGrowthMod()
			self.task = self.inst:DoTaskInTime(time, OnHackableRegen, "regen")
			self.targettime = GetTime() + time
		end
	end
end

function Hackable:Hack(hacker, numworks, shear_mult, from_shears)
    if self.canbehacked and self.caninteractwith then

    	self.hacksleft = self.hacksleft - numworks 
    	--Check work left here and fire callback and early out if there's still more work to do 
    	 if self.onhackedfn then
            self.onhackedfn(self.inst, hacker, self.hacksleft, from_shears)
        end

        if(self.hacksleft <= 0) then         
			if self.transplanted then
				if self.cycles_left ~= nil then
					self.cycles_left = self.cycles_left - 1
				end
			end

			if self.shouldwither then
				if self.protected_cycles ~= nil then
					self.protected_cycles = self.protected_cycles - 1
				end
			end
			
			local loot = self:DropProduct(shear_mult)
			
			if self.repeat_hack_cycle then
				self.hacksleft = self.maxhacks
			else
				self.canbehacked = false
				self.inst:AddTag("stump")
				self.hasbeenhacked = true	
			end
	        
	        if not self.paused and not self.withered and self.baseregentime and (self.cycles_left == nil or self.cycles_left > 0) then
	        	self.regentime = self.baseregentime * self:GetGrowthMod()
				self.task = self.inst:DoTaskInTime(self.regentime, OnHackableRegen, "regen")
				self.targettime = GetTime() + self.regentime
			end
	        
	        self.inst:PushEvent("hacked", {hacker = hacker, loot = loot, plant = self.inst})
	    end
    end
end

function Hackable:DropProduct(shear_mult)
	local loot = nil
	shear_mult = shear_mult or 1

	for i=1, shear_mult do
	    if self.product then
	    	if self.inst.components.lootdropper then 
	    		self.inst.components.lootdropper:SpawnLootPrefab(self.product)
	    	else
	            loot = SpawnPrefab(self.product)

	            if loot then
					self.inst:ApplyInheritedMoisture(loot)
			        --picker:PushEvent("picksomething", {object = self.inst, loot= loot})

			        local pt = Point(self.inst.Transform:GetWorldPosition())
			        loot.Transform:SetPosition(pt.x,pt.y,pt.z)

			        local angle = math.random()*2*PI
					local speed = math.random()
					loot.Physics:SetVel(speed*math.cos(angle), GetRandomWithVariance(12, 3), speed*math.sin(angle))
	                --picker.components.inventory:GiveItem(loot, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
	            end
	        end 
	    end
	end
	return loot
end

function Hackable:IsActionValid(action, right)
    if not self.canbehacked then return false end

    if action == ACTIONS.HAMMER and not right then
		return false
    end
    
    return self.hacksleft > 0 and action == ACTIONS.HACK
end

function Hackable:CollectSceneActions(doer, actions)
    if self.canbehacked and self.caninteractwith and not (self.inst.components.burnable and self.inst.components.burnable:IsBurning()) then
    	--Check if a hack tool is available
    	local tool = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    	if (tool and tool.components.tool and tool.components.tool:CanDoAction(ACTIONS.HACK)) then
			table.insert(actions, ACTIONS.HACK)
		end 
    end
end

return Hackable
