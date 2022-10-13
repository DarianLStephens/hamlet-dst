local assets =
{

}

local prefabs =
{

}

local function roomlightobjectfn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
    inst.entity:SetPristine()
	
    local light = inst.entity:AddLight()
    inst:AddTag("NOBLOCK")
    
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(197/255/2,197/255/2,50/255/2)
    inst.Light:SetFalloff( 0.5 )
    inst.Light:SetRadius( 6 )

    light:Enable(true) 

	if not TheWorld.ismastersim then
		return inst
	end

    return inst
end

local function roomlightobjectlargefn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	inst.entity:SetPristine()
    
    local light = inst.entity:AddLight()
    inst:AddTag("NOBLOCK")

    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(197/255/2,197/255/2,50/255/2)
    inst.Light:SetFalloff( 0.5 )
    inst.Light:SetRadius( 9 )

    light:Enable(true) 

	if not TheWorld.ismastersim then
		return inst
	end

    return inst
end

return Prefab( "marsh/objects/deco_roomglow", roomlightobjectfn, assets, prefabs),
       Prefab( "marsh/objects/deco_roomglow_large", roomlightobjectlargefn, assets, prefabs)

