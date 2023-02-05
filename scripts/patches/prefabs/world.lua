return function(inst)
	if not inst.ismastersim then
		return
	end

	inst:AddComponent("interiorspawner")
	inst:AddComponent("economy")
	inst:AddComponent("aporkalypse")
	inst:AddComponent("periodicpoopmanager")
end
