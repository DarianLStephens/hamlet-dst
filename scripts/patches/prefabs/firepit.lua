local function returntointeriorscene(inst)
	local burn = inst.components.burnable
	if burn then
		print("DS - Fire Pit - Fixing burn FX for return to interior")
		burn:FixFX()
	else
		print("DS - Fire Pit - Missing burn component, can't fix")
	end
end

return function(inst)
	if not TheWorld.ismastersim then return end
	inst.returntointeriorscene = returntointeriorscene
end