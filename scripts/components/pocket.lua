--Mostly for if something needs to hold an entity that isn't an inventory item.

local Pocket = Class(function(self, inst)
	self.inst = inst
	self.items = {}
	self.ontakeitemfn = nil
	self.cantakeitemfn = nil
	self.onloseitemfn = nil

	self.interactable = false --Can the player put stuff in this pocket?

	self.numitems = 0
	self.maxitems = 10
end)

function Pocket:SetMaxItems(num)
	self.maxitems = num
end

function Pocket:SetOnLoseItemFn(fn)
	self.onloseitemfn = fn
end

function Pocket:SetOnTakeItemFn(fn)
	self.ontakeitemfn = fn
end

function Pocket:SetCanTakeItemFn(fn)
	self.cantakeitemfn = fn
end

function Pocket:IsFull()
	return self.numitems >= self.maxitems
end

function Pocket:CanTakeItem(item)
	if self.cantakeitemfn then
		return self.cantakeitemfn(self.inst, item)
	end

	return not self:IsFull()
end

function Pocket:GiveItem(key, item)
	if not self:CanTakeItem(item) then
		return false
	end
	self.numitems = self.numitems + 1

	self.items[key] = item
	self.inst:AddChild(item)
	item:RemoveFromScene()
    item.Transform:SetPosition(0,0,0)
	item.Transform:UpdateTransform()

	if self.ontakeitemfn then
		self.ontakeitemfn(self.inst, item)
	end
	return true
end

function Pocket:GetItem(key)
	return self.items[key]
end

function Pocket:RemoveItem(key)
	local item = self.items[key]

	if item then
		self.numitems = self.numitems - 1

		if self.onloseitemfn then
			self.onloseitemfn(self.inst, item)
		end

		self.inst:RemoveChild(item)
	    item:ReturnToScene()	    
        local pos = self.inst:GetPosition()
	    item.Transform:SetPosition(pos:Get())
	    item.Transform:UpdateTransform()
	end

	self.items[key] = nil
	return item
end

function Pocket:OnSave(inst)
	local data = {items = {}}

	for k,v in pairs(self.items) do
		if v.persists then
			data.items[k] = v:GetSaveRecord()
		end
	end

	return data
end

function Pocket:OnLoad(data, newents)
	if data.items then
		for k,v in pairs(data.items) do
			local inst = SpawnSaveRecord(v, newents)
			if inst then
				self:GiveItem(k, inst)
			end
		end
	end
end

function Pocket:GetDebugString()
	local s = "--- Items ---\n"
	local count = 0
    for k,item in pairs(self.items) do
    	s = s..string.format("--- '%s' - %s x %2.0f \n", k, item.prefab, (item.components.stackable and item.components.stackable:StackSize()) or 1)
	end
	return s
end



return Pocket