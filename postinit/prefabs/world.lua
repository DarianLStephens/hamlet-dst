
local function addInteriorComponents(inst)
	print("IST - Attempting to install world interior components")
	if inst.ismastersim then
		--print("This is where the component would be added, if the game didn't crash and stuff when I tried")
		print("Adding interior component")
		inst:AddComponent("interiorspawner")
	end
	inst.addInteriorComponents = nil --self-destruct after use
end

AddPrefabPostInit("world", function(inst)

	--------------------------------------------------------------------------

	inst.addInteriorComponents = addInteriorComponents

	-- local OnPreLoad_old = inst.OnPreLoad
	-- inst.OnPreLoad = function(...)
		if inst.addInteriorComponents then
			inst:addInteriorComponents()
		end

		-- return OnPreLoad_old and OnPreLoad_old(...)
	-- end

	--------------------------------------------------------------------------

end)
