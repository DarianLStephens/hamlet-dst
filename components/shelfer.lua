local Shelfer = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.deleteitemonaccept = true
end)

function Shelfer:OnSave()
    local data = {}
    local references = {}
    data.enabled = self.enabled 
    data.slot = self.slot
	data.slotindex = self.slotindex
    if self.shelf then
        data.shelf = self.shelf.GUID
    table.insert(references, self.shelf.GUID)
    end
    return  data, references
end

function Shelfer:OnLoad(data)
    self.enabled = data.enabled
    if data.slot then
        self.slot = data.slot
    end
	if not data.slotindex then
		if data.slot == "SWAP_SIGN" then
			self.slotindex = 1
		else
			local slot = data.slot
			local prefix = slot:sub(1,8)
			assert(prefix == "SWAP_img")
			self.slotindex = tonumber(slot:sub(9))
		end		
	else
		self.slotindex = data.slotindex
	end
end

function Shelfer:LoadPostPass(newents, data)
    if data.shelf and newents[data.shelf] then
        self.shelf = newents[data.shelf].entity
	    self:SetArt()
    end
end

function Shelfer:IsTryingToTradeWithMe(inst)
    local act = inst:GetBufferedAction()
    if act then
        return act.target == self.inst and act.action == ACTIONS.GIVE
    end
end

function Shelfer:Enable( )
    self.enabled = true
	-- do I have an underlying item?
    self.inst.components.inventoryitem.canbepickedup = self:GetGift() and true or false
end

function Shelfer:Disable( )
    self.enabled = false
    self.inst.components.inventoryitem.canbepickedup = false
end

function Shelfer:SetShelf( shelf, slot )
    self.shelf = shelf
    self.slot = slot
end

function Shelfer:GetGift()
	return self.shelf.components.container:GetItemInSlot(self.slotindex)
end

function Shelfer:GiveGift()
    self.inst.components.inventoryitem.canbepickedup = false
    self.shelf.SetImageFromName(self.shelf, nil, self.slot)
	local item = self.shelf.components.container:RemoveItemBySlot(self.slotindex)
    return self:ReturnGift(item)
end

function Shelfer:CanAccept( item , giver )
    local frozen = false
    if  self.inst.components.freezable and self.inst.components.freezable:IsFrozen() then
        frozen = true        
    end
    
    local inventortyitem = false
    if  item.components.inventoryitem then
        inventortyitem = true
    end

	local item = self.shelf.components.container:GetItemInSlot(self.slotindex)

    return self.enabled and inventortyitem and not frozen and not item -- (not self.test or self.test(self.inst, item, giver))
end

function Shelfer:SetArt()
	local item = self.shelf.components.container:GetItemInSlot(self.slotindex)

    if item then
        self.shelf.SetImage(self.shelf, item, self.slot)
        self.inst:SetPrefabNameOverride(item.components.inspectable.nameoverride or item.prefab)
	else
	    self.inst.components.inventoryitem.canbepickedup = false
    end
end

function Shelfer:ReturnGift(item)
    if item then
        item.onshelf = nil
        return item
    end
end

function Shelfer:AcceptGift( giver, item )

    if not self.enabled then
        return false
    end
   
    if self:CanAccept(item, giver) then

		if item.components.stackable and item.components.stackable.stacksize > 1 then
			item = item.components.stackable:Get()
		else
			item.components.inventoryitem:RemoveFromOwner()
		end

		self:UpdateGift(giver, item)

        return true
    end

    local frozen = false
    if  self.inst.components.freezable and self.inst.components.freezable:IsFrozen() then
        frozen = true        
    end

	if self.onrefuse and not frozen then
		self.onrefuse(self.inst, giver, item)
	end
end

function Shelfer:UpdateGift(giver, item)
	item.onshelf = self.inst
    self.inst:PushEvent("trade", {giver = giver, item = item})
    if self.shelf and self.slot then
		self.shelf.components.container:GiveItem(item, self.slotindex)
        self.inst.components.inventoryitem.canbepickedup = true
        self:SetArt()            
    end
end

return Shelfer
