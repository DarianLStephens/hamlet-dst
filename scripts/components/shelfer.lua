local Shelfer = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.deleteitemonaccept = true
	self.inst:AddTag("shelfcanaccept")
	self.inst:AddTag("shelfer")
end)

function Shelfer:OnSave()
    local data = {}
    local references = {}
    data.enabled = self.enabled 
    data.slot = self.slot
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
	if self.inst.components.inventoryitem then
    self.inst.components.inventoryitem.canbepickedup = true
	end
end

function Shelfer:Disable( )
    self.enabled = false
	if self.inst.components.inventoryitem then
    self.inst.components.inventoryitem.canbepickedup = false
	end
end

function Shelfer:SetShelf( shelf, slot )
    self.shelf = shelf
    self.slot = slot
end

function Shelfer:GetGift()
    return self.inst.components.pocket:GetItem("shelfitem")        
end

function Shelfer:GiveGift()
    self.inst.components.inventoryitem.canbepickedup = false
	if self.shelf ~= nil then
    self.shelf.SetImageFromName(self.shelf, nil, self.slot)
	end
    local item = self.inst.components.pocket:RemoveItem("shelfitem")
	if self.inst.components.shelfer and self.inst.components.shelfer.shelf:HasTag("pigcurse") then
	if self.inst.components.shelfer and self.inst.components.shelfer.shelf.components.timer then
	self.inst.components.shelfer.shelf.components.timer:StartTimer("spawndelay", 60*8*30)	
	end	
    if math.random() < 0.3 and self.inst.components.shelfer and self.inst.components.shelfer.shelf then
    local ghost = SpawnPrefab("ghost")
    local pt = Vector3(self.inst.components.shelfer.shelf.Transform:GetWorldPosition())
	if ghost then ghost.Transform:SetPosition(pt.x,pt.y,pt.z) end
    end
	end
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

    local pocketitem = self.inst.components.pocket:GetItem("shelfitem")

    return self.enabled and inventortyitem and not frozen and not pocketitem -- (not self.test or self.test(self.inst, item, giver))
end

function Shelfer:SetArt()

    local item = self.inst.components.pocket:GetItem("shelfitem")
    if item then
        self.shelf.SetImage(self.shelf, item, self.slot)
		if item.components.inspectable then
        self.inst:SetPrefabNameOverride(item.components.inspectable.nameoverride or item.prefab)
		end
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
        item.onshelf = self.inst
        self.inst:PushEvent("trade", {giver = giver, item = item})

        if self.shelf and self.slot then
            self.inst.components.pocket:GiveItem("shelfitem", item)  
            self.inst.components.inventoryitem.canbepickedup = true
            self:SetArt()            
        end

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

return Shelfer
