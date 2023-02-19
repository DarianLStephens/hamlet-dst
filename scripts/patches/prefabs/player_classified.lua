local function CraftingFilterTypeDirty(inst)
	if not inst._parent then
		return
	end

	inst._parent.HUD.controls.craftingmenu:AddFilterSwapper(inst.craftingfiltertype:value())
end

return function(inst)
	inst.craftingfiltertype = net_string(inst.GUID, "craftingfiltertype", "craftingfiltertypedirty")
	
	if not TheNet:IsDedicated() then
		inst:ListenForEvent("craftingfiltertypedirty", CraftingFilterTypeDirty)
	end
end
