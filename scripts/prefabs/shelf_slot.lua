local assets =
{
    --Asset("ANIM", "anim/store_items.zip"),
    Asset("ANIM", "anim/shelf_slot.zip"),
}

local prefabs =
{

}

local function empty(inst)     
	local item = inst.components.shelfer:GiveGift()
    if item then    
        local pt = Point(inst.Transform:GetWorldPosition())
        if inst.components.shelfer.shelf then
            pt = Point(inst.components.shelfer.shelf.Transform:GetWorldPosition())
        end
        --DropLootPrefab
        inst.components.lootdropper:DropLootPrefab(item, pt, 0,90)
    end
end

local function droploot(inst)     
	local item = inst.components.shelfer:GiveGift()
    if item then    
        local pt = Point(inst.Transform:GetWorldPosition())
        if inst.components.shelfer.shelf then
            pt = Point(inst.components.shelfer.shelf.Transform:GetWorldPosition())
        end
        return inst.components.lootdropper:DropLootPrefab(item, pt, 0,90, false)
    end
end

local function displaynamefn(inst)
	local item = inst.components.shelfer:GetGift()
	if not item then
		return ""
	end
	return item:GetDisplayName()
end

local function OnLoadPostPass(inst)
	inst:DoTaskInTime(0.5, function()
		local pocket = inst.components.pocket
		local shelfer = inst.components.shelfer
		local pocketitem = pocket:GetItem("shelfitem")
		local containeritem = shelfer:GetGift()
		if pocketitem then
			if containeritem then
				-- drop whatever was placed in there
				local loot = droploot(inst)
				if loot then
					local interior = TheWorld.components.interiorspawner:getPropInterior(inst)
					if interior then
			    	    TheWorld.components.interiorspawner:injectprefab(loot,interior)
					end
				end
			end
			-- and remove the pocket item and put it in the container
			pocketitem = pocket:RemoveItem("shelfitem")
			-- in case it's a locked cabinet
			local enabled = shelfer.enabled
			shelfer.enabled = true
			shelfer:UpdateGift(nil, pocketitem)	
			-- and lock it again if needed
			if enabled then
				shelfer:Enable()
			else
				shelfer:Disable()
			end
		end
		-- discard the loaded slot
		inst:Remove()
	end)
end

local function common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    anim:SetBuild("shelf_slot")
    anim:SetBank("shelf_slot")
    anim:PlayAnimation("idle")
    anim:Hide("mouseclick")
    inst.entity:AddNetwork()

    inst:AddTag("cost_one_oinc")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOFORAGE")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
    
    inst:AddComponent("lootdropper")

    inst:AddComponent("pocket")

    inst:AddComponent("shelfer")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.empty = empty

	inst.displaynamefn = displaynamefn

	inst.OnLoadPostPass = OnLoadPostPass

	-- we're not saving those anymore
	inst.persists = false

    return inst
end

return Prefab( "shelf_slot", common, assets, prefabs)       
