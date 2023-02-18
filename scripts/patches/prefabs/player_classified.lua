local function CraftingFilterTypeDirty(inst)
	if not inst._parent then
		return
	end

	inst._parent.HUD.controls.craftingmenu:AddFilterSwapper(inst.craftingfiltertype:value())
end
local function InteriorEnterDirty(inst)
	if not inst._parent then
		return
	end
	if inst.interiorenter:value() == "" then
		inst._parent:PushEvent("exitedinterior")
	else
		inst._parent:PushEvent("enteredinterior", inst.interiorenter:value())
	end
end
return function(inst)
	inst.craftingfiltertype = net_string(inst.GUID, "craftingfiltertype", "craftingfiltertypedirty")
	inst.interiorenter = net_string(inst.GUID, "interiorenter", "interiorenterdirty")
	
	if not TheNet:IsDedicated() then
		inst:ListenForEvent("craftingfiltertypedirty", CraftingFilterTypeDirty)
		inst:ListenForEvent("interiorenterdirty", InteriorEnterDirty)
	end
end
