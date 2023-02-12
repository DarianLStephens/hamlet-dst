local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst:AddTag("cave_potential")
    return inst
end

return Prefab( "vampirebatcave_potential", fn ) 