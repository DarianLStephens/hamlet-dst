local function DoTest(inst)   
	if inst:HasTag("INTERIOR_LIMBO") then
		return
	end

    local component = inst.components.creatureprox
    if component and component.enabled and not inst:HasTag("INTERIOR_LIMBO") then      
    
        local x,y,z = inst.Transform:GetWorldPosition()

        local range = nil       

        if component.isclose then
            range = component.far
        else
            range = component.near
        end

        local musthave = { "animal","character","monster","stationarymonster","insect","smallcreature","structure","seacreature"}

        if component.inventorytrigger then
            -- musthave = {"isinventoryitem", "monster", "animal", "character","insect","smallcreature"}
            musthave = {"_inventoryitem", "monster", "animal", "character","insect","smallcreature"}
        end

        local nothave = {"INTERIOR_LIMBO"}
        local ents = TheSim:FindEntities(x,y,z, range, nil, nothave,  musthave )
        local close = nil

        for i=#ents,1,-1 do        
            if ents[i] == inst or ( component.testfn and not component.testfn(ents[i]) ) then
                table.remove(ents,i)           
            end      
        end

        if #ents > 0 and inst then 
            close = true      
            if component.inproxfn then
                for i, ent in ipairs(ents)do
                    component.inproxfn(inst,ent)
                end
            end
        end
        if component.isclose ~= close then
            component.isclose = close
            if component.isclose and component.onnear then
                component.onnear(inst, ents)
            end

            if not component.isclose and component.onfar then
                component.onfar(inst)
            end        
        end        
        if component.piggybackfn then
            component.piggybackfn(inst)
        end
    end
end

local CreatureProx = Class(function(self, inst)
    self.inst = inst
    self.near = 2
    self.far = 3
    self.period = .333
    self.onnear = nil
    self.onfar = nil
    self.isclose = nil
    self.enabled = true    
    
    self.task = nil
    
    self:Schedule()
end)

function CreatureProx:GetDebugString()
    return self.isclose and "NEAR" or "FAR"
end

function CreatureProx:SetOnPlayerNear(fn)
    self.onnear = fn
end
-- Ported from Jerry's Hamlet, to make it more compatible
function CreatureProx:SetOnNear(fn)
    self.onnear = fn
end

function CreatureProx:SetOnFar(fn)
    self.onfar = fn
end


function CreatureProx:OnSave()
   local data = {
        enabled = self.enabled
    }
end
function CreatureProx:OnLoad(data)
    if data.enabled then
        self.enabled = data.enabled
    end
end

function CreatureProx:SetEnabled(enabled)
    self.enabled = enabled
    if enabled == false then
        self.isclose = nil
    end
end

function CreatureProx:SetOnPlayerFar(fn)
    self.onfar = fn
end

function CreatureProx:IsPlayerClose()
	return self.isclose
end

function CreatureProx:SetDist(near, far)
    self.near = near
    self.far = far
end

function CreatureProx:SetTestfn(testfn)
    self.testfn = testfn    
end

function CreatureProx:forcetest()
    DoTest(self.inst)
end


function CreatureProx:Schedule()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
	if not self.inst:IsAsleep() then
	    self.task = self.inst:DoPeriodicTask(self.period, DoTest, math.random() * self.period)
	end
end

function CreatureProx:OnEntitySleep()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function CreatureProx:OnEntityWake()
    self:Schedule()
end

function CreatureProx:OnRemoveEntity()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

return CreatureProx
