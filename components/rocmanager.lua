
local SPAWNDIST = 40
local TESTTIME = TUNING.SEG_TIME/2

local Rocmanager = Class(function(self, inst)
	self.disabled = false
	self.inst = inst
	self.inst:DoPeriodicTask(TESTTIME,function() self:ShouldSpawn() end) -- 
	self.roc = nil
	self.nexttime = self:GetNextSpawnTime()
end)

function Rocmanager:OnSave()	
	local refs = {}
	local data = {}
	data.disabled = self.disabled
	data.nexttime = self.nexttime
	return data, refs
end 

function Rocmanager:OnLoad(data)

	if data.disabled then
		self.disabled = data.disabled
	end
	if data.nexttime then
		self.nexttime = data.nexttime
	end
end
function Rocmanager:RemoveRoc(inst)
	if self.roc == inst then 
		self.roc = nil
	end
end

function Rocmanager:GetNextSpawnTime()
	return (TUNING.TOTAL_DAY_TIME * 10)  + (math.random() * TUNING.TOTAL_DAY_TIME * 10)
end

function Rocmanager:Spawn()
	if not self.roc then
		local pt= Vector3(GetPlayer().Transform:GetWorldPosition())
		local angle = math.random()* 2*PI
		local offset = Vector3(SPAWNDIST * math.cos( angle ), 0, -SPAWNDIST * math.sin( angle ))
		local roc = SpawnPrefab("roc")
		roc.Transform:SetPosition(pt.x+offset.x,0,pt.z+offset.z)
		self.roc = roc
		self.nexttime = self:GetNextSpawnTime()			
	end
end

function Rocmanager:ShouldSpawn()
	if self.disabled then
		return
	end
	local clock = GetClock()

	if self.nexttime > 0 then
		self.nexttime = self.nexttime - TESTTIME
	end	
	-- will only spawn before the first half of daylight, and not wile player is indoors
	if not self.roc and clock:GetNormTime() < (clock.daysegs / 16) /2 and not TheCamera.interior then 
		-- do test stuff.
		if self.nexttime <= 0 then
			self:Spawn()
		end		
	end
end

function Rocmanager:LongUpdate(dt)
	self.nexttime = self.nexttime - dt
end

function Rocmanager:OnUpdate(dt)

end

return Rocmanager