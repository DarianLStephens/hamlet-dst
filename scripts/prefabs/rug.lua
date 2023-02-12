local assets =
{
	Asset("ANIM", "anim/rugs.zip"),
	Asset("ANIM", "anim/interior_wall_decals_mayorsoffice.zip"),
	Asset("ANIM", "anim/interior_wall_decals_palace.zip"),
	Asset("INV_IMAGE", "reno_rug_round"),
	Asset("INV_IMAGE", "reno_rug_square"),
	Asset("INV_IMAGE", "reno_rug_oval"),
	Asset("INV_IMAGE", "reno_rug_rectangle"),
	Asset("INV_IMAGE", "reno_rug_fur"),
	Asset("INV_IMAGE", "reno_rug_hedgehog"),
	Asset("INV_IMAGE", "reno_rug_porcupuss"),
	Asset("INV_IMAGE", "reno_rug_hoofprint"),
	Asset("INV_IMAGE", "reno_rug_octagon"),
	Asset("INV_IMAGE", "reno_rug_swirl"),
	Asset("INV_IMAGE", "reno_rug_catcoon"),
	Asset("INV_IMAGE", "reno_rug_rubbermat"),
	Asset("INV_IMAGE", "reno_rug_web"),
	Asset("INV_IMAGE", "reno_rug_metal"),
	Asset("INV_IMAGE", "reno_rug_wormhole"),
	Asset("INV_IMAGE", "reno_rug_braid"),
	Asset("INV_IMAGE", "reno_rug_beard"),
	Asset("INV_IMAGE", "reno_rug_nailbed"),
	Asset("INV_IMAGE", "reno_rug_crime"),
	Asset("INV_IMAGE", "reno_rug_tiles"),
}

local prefabs =
{
}

local function smash(inst)
    if inst.components.lootdropper then
		local interiorSpawner = GetWorld().components.interiorspawner 
        if interiorSpawner.current_interior then
            local originpt = interiorSpawner:GetSpawnOrigin()
            local x, y, z = inst.Transform:GetWorldPosition()
            local dropdir = Vector3(originpt.x - x, 0.0, originpt.z - z):GetNormalized()
            inst.components.lootdropper.dropdir = dropdir
	        inst.components.lootdropper:DropLoot()
	    end
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    if inst.SoundEmitter then
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    end

    inst:Remove()
end    

local function setPlayerUncraftable(inst)
	inst:RemoveTag("NOCLICK")
    inst:AddComponent("lootdropper")
    inst.entity:AddSoundEmitter()
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(
        function(inst, worker, workleft)
            if workleft <= 0 then
                smash(inst)
            end
        end)
end

local function onsave(inst, data)
	data.rotation = inst.Transform:GetRotation()
    if inst.onbuilt then
        data.onbuilt = inst.onbuilt
    end	
end	

local function onload(inst, data)
	if data.rotation then
		inst.Transform:SetRotation(data.rotation)
	end
    if data.onbuilt then
        setPlayerUncraftable(inst)
        inst.onbuilt = data.onbuilt
    end	
end

local function onBuilt(inst)
    setPlayerUncraftable(inst)
    inst.onbuilt = true         
end


local function commonfn(rugtype)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()

    anim:SetBuild("rugs")
    anim:SetBank("rugs")
    anim:PlayAnimation(rugtype, true)
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddTag("OnFloor")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")

    inst:ListenForEvent( "onbuilt", function()
        onBuilt(inst)
    end)        

	inst.OnSave = onsave 
    inst.OnLoad = onload

	return inst
end

local function round()
	local inst = commonfn("rug_round")
	return inst
end	

local function oval()
	local inst = commonfn("rug_oval")
	return inst
end	

local function square()
	local inst = commonfn("rug_square")
	return inst
end	

local function rectangle()
	local inst = commonfn("rug_rectangle")
	return inst
end

local function leather()
	local inst = commonfn("rug_leather")
	return inst
end	

local function fur()
	local inst = commonfn("rug_fur")
	return inst
end	

local function circle()
	local inst = commonfn("half_circle")
	return inst
end

local function hedgehog()
	local inst = commonfn("rug_hedgehog")
	return inst
end	


local function twosided(name)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst.Transform:SetTwoFaced()

    anim:SetBuild("rugs")
    anim:SetBank("rugs")
    anim:PlayAnimation(name)
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddTag("OnFloor")
	inst:AddTag("NOCLICK")

	inst.OnSave = onsave 
    inst.OnLoad = onload

    
    inst:ListenForEvent( "onbuilt", function()
        onBuilt(inst)
    end)       

	return inst
end

local function porcupus()
	local inst = twosided("rug_porcupuss")
	return inst
end	

local function hoofprint()
	local inst = commonfn("rug_hoofprints")
	return inst
end

local function octagon()
	local inst = commonfn("rug_octagon")
	return inst
end

local function swirl()
	local inst = commonfn("rug_swirl")
	return inst
end

local function catcoon()
	local inst = commonfn("rug_catcoon")
	return inst
end

local function rubbermat()
	local inst = commonfn("rug_rubbermat")
	return inst
end

local function web()
	local inst = commonfn("rug_web")
	return inst
end

local function metal()
	local inst = commonfn("rug_metal")
	return inst
end

local function wormhole()
	local inst = commonfn("rug_wormhole")
	return inst
end

local function braid()
	local inst = commonfn("rug_braid")
	return inst
end

local function beard()
	local inst = commonfn("rug_beard")
	return inst
end

local function nailbed()
	local inst = twosided("rug_nailbed")
	return inst
end

local function crime()
	local inst = commonfn("rug_crime")
	return inst
end

local function tiles()
	local inst = commonfn("rug_tiles")
	return inst
end

local function palace_runner()
	local inst = commonfn("rug_throneroom")
	return inst
end	

local function cityhall_corners()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()

    anim:SetBuild("interior_wall_decals_mayorsoffice")
    anim:SetBank("wall_decals_mayorsoffice")
    anim:PlayAnimation("corner_back", true)
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddTag("NOCLICK")

	inst.OnSave = onsave 
    inst.OnLoad = onload

	return inst
end

local function palace_corners()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddNetwork()

    anim:SetBuild("interior_wall_decals_palace")
    anim:SetBank("wall_decals_palace")
    anim:PlayAnimation("floortrim_corner", true)
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddTag("NOCLICK")

	inst.OnSave = onsave 
    inst.OnLoad = onload

	return inst
end

return Prefab("marsh/objects/rug_round", round, assets, prefabs),
	   Prefab("marsh/objects/rug_oval", oval, assets, prefabs),
	   Prefab("marsh/objects/rug_square", square, assets, prefabs),
	   Prefab("marsh/objects/rug_rectangle", rectangle, assets, prefabs),
	   Prefab("marsh/objects/rug_leather", leather, assets, prefabs),	   
	   Prefab("marsh/objects/rug_fur", fur, assets, prefabs),
	   Prefab("marsh/objects/rug_circle", circle, assets, prefabs),	   
	   Prefab("marsh/objects/rug_hedgehog", hedgehog, assets, prefabs),
	   Prefab("marsh/objects/rug_porcupuss", porcupus, assets, prefabs),
	   Prefab("marsh/objects/rug_hoofprint", hoofprint, assets, prefabs),
	   Prefab("marsh/objects/rug_octagon", octagon, assets, prefabs),
	   Prefab("marsh/objects/rug_swirl", swirl, assets, prefabs),
	   Prefab("marsh/objects/rug_catcoon", catcoon, assets, prefabs),
	   Prefab("marsh/objects/rug_rubbermat", rubbermat, assets, prefabs),
	   Prefab("marsh/objects/rug_web", web, assets, prefabs),
	   Prefab("marsh/objects/rug_metal", metal, assets, prefabs),
	   Prefab("marsh/objects/rug_wormhole", wormhole, assets, prefabs),
	   Prefab("marsh/objects/rug_braid", braid, assets, prefabs),
	   Prefab("marsh/objects/rug_beard", beard, assets, prefabs),
	   Prefab("marsh/objects/rug_nailbed", nailbed, assets, prefabs),
	   Prefab("marsh/objects/rug_crime", crime, assets, prefabs),
	   Prefab("marsh/objects/rug_tiles", tiles, assets, prefabs),
	   Prefab("marsh/objects/rug_cityhall_corners", cityhall_corners, assets, prefabs),
	   Prefab("marsh/objects/rug_palace_corners", palace_corners, assets, prefabs),
	   Prefab("marsh/objects/rug_palace_runner", palace_runner, assets, prefabs)

	   

