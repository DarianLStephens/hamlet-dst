local assets=
{
	Asset("ANIM", "anim/infused_iron.zip"),
}

local function onsave(inst, data)
	data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
	    inst.AnimState:PlayAnimation(inst.animname)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    -- MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)
    
    inst.AnimState:SetBank("infused_iron")
    inst.AnimState:SetBuild("infused_iron")
    inst.AnimState:PlayAnimation("idle")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 1
    inst:AddComponent("tradable")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst:AddComponent("bait")
    inst:AddTag("molebait")
    inst:AddTag("infused")    

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.INFUSED_IRON_PERISHTIME)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "iron"


--[[
	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "orp"
	inst.components.repairer.healthrepairvalue = TUNING.REPAIR_ROCKS_HEALTH
]]
    inst.OnSave = onsave 
    inst.OnLoad = onload 
    return inst
end

return Prefab( "common/inventory/infused_iron", fn, assets) 
