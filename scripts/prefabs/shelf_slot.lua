local assets =
{
    Asset("ANIM", "anim/shelf_slot.zip"),
}

local prefabs = {}

local function empty(inst)     
    local item =  inst.components.pocket:RemoveItem("shelfitem")  
    if item then    
        inst.components.shelfer:ReturnGift(item)

        local pt = inst.Transform:GetWorldPosition()

        if inst.components.shelfer.shelf then
            pt = inst.components.shelfer.shelf.Transform:GetWorldPosition()
        end

		if item and inst.components.lootdropper then
			inst.components.lootdropper:DropLoot(pt)
		end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("shelf_slot")
    inst.AnimState:SetBank("shelf_slot")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLayer(LAYER_WORLD)
    inst.AnimState:SetSortOrder(3)	
   	inst.AnimState:SetMultColour(255/255, 255/255, 255/255, 0.02)	

    inst:AddTag("cost_one_oinc")
    inst:AddTag("NOBLOCK")
    inst:AddTag("shelfcanaccept")
	
	inst:SetPhysicsRadiusOverride(1.75)
	
    inst:AddComponent("pocket")

    inst:AddComponent("shelfer")	
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
   
    inst:AddComponent("lootdropper")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
	
    inst.empty = empty

    return inst
end

return Prefab( "shelf_slot", fn, assets, prefabs)       
   
