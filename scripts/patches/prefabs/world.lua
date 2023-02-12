return function(inst)
	if not inst.ismastersim then
		return
	end

	inst:AddComponent("interiorspawner")
	inst:AddComponent("quaker_interior")
	inst:AddComponent("economy")
	inst:AddComponent("aporkalypse")
	inst:AddComponent("periodicpoopmanager")
end
