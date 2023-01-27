local assets=
{
	Asset("ANIM", "anim/chitin.zip"),
}

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    inst.entity:AddNetwork()
    
    inst.AnimState:SetBank("chitin")
    inst.AnimState:SetBuild("chitin")
    inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	return inst
end

return Prefab("objects/chitin", fn, assets)
