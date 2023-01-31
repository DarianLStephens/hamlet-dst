
local function addHamletComponents(inst)
	print("IST - Attempting to install world interior components")
	if inst.ismastersim then
		--print("This is where the component would be added, if the game didn't crash and stuff when I tried")
		print("Adding interior component")
		inst:AddComponent("interiorspawner")
		print("Adding economy component...")
		inst:AddComponent("economy")
		print("Adding aporkalypse component...")
		inst:AddComponent("aporkalypse")
		print("Adding... periodic poop manager component...")
		inst:AddComponent("periodicpoopmanager")
	end
	inst.addHamletComponents = nil --self-destruct after use
end

AddPrefabPostInit("world", function(inst)

	--------------------------------------------------------------------------

	inst.addHamletComponents = addHamletComponents

	-- local OnPreLoad_old = inst.OnPreLoad
	-- inst.OnPreLoad = function(...)
		if inst.addHamletComponents then
			inst:addHamletComponents()
		end

		-- return OnPreLoad_old and OnPreLoad_old(...)
	-- end

	--------------------------------------------------------------------------

end)
