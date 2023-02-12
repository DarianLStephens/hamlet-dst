local assets=
{
    Asset("ANIM", "anim/batwing.zip"),
    Asset("INV_IMAGE", "batwing"),
}

local function fn(Sim)
	local inst = CreateEntity()
    
    local newinst = SpawnPrefab("batwing")
    newinst.name = STRINGS.NAMES.VAMPIRE_BAT_WING
    newinst.components.inventoryitem:ChangeImageName("batwing")
    newinst.AnimState:SetBank("batwing")
    newinst.AnimState:SetBuild("batwing")

    newinst.imagenameoverride = "batwing"
    newinst.animbankoverride = "batwing"
    newinst.animbuildoverride = "batwing"
    newinst.nameoverride = "VAMPIRE_BAT_WING"

    inst:Remove()

    return newinst
end

return Prefab( "vampire_bat_wing", fn, assets) 
