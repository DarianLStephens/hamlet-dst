require "prefabutil"
local assets =
{
}

local prefabs = 
{
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	

    inst:Hide()
    
    inst.SoundEmitter:PlaySound( "dontstarve_DLC003/music/shop_enter", "musac")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    return inst
end

return Prefab( "common/inventory/musac", fn, assets, prefabs)