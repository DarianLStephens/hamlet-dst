require "prefabutil"
require "recipes"

 local function InitInteriorPrefab(inst, doer, prefab_definition, interior_definition)
 	inst:DoTaskInTime(0, function() inst.components.shopinterior:MakeShop(5, prefab_definition.shop_type) end) 
 end 

local function onsave(inst, data)    
    data.interiorID = inst.interiorID
end

local function onload(inst, data)
    if data then  
        if data.interiorID then
            inst.interiorID  = data.interiorID
        end
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddNetwork()
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
    inst:AddComponent("shopinterior")
    inst.initInteriorPrefab = InitInteriorPrefab	
    inst.components.shopinterior.want_all = true

    inst.OnSave = onsave 
    inst.OnLoad = onload

    return inst
end

return Prefab( "shop_spawner", fn ) 
