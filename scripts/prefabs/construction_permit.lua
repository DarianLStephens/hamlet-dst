local assets=
{
	Asset("ANIM", "anim/permit_reno.zip"),
}

local function makefn(inst)
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)   

    inst.AnimState:SetBank("permit_reno")
    inst.AnimState:SetBuild("permit_reno")
    inst.AnimState:PlayAnimation("idle")

	--inst:AddTag("room_builder")
    inst:AddComponent("roombuilder")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"
    

    MakeInventoryFloatable(inst, "idle_water", "idle")

    return inst
end

return Prefab( "common/inventory/construction_permit", makefn, assets)