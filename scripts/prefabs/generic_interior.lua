require "prefabutil"
require "recipes"

local assets =
{
	Asset("ANIM", "anim/pig_room_general.zip"),
}

local prefabs = 
{
	"generic_wall_side",
	"generic_wall_back",
	"test_interior_art",
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("pig_room")
    anim:SetBuild("pig_room_general")
    anim:PlayAnimation("idle", true)
	anim:Hide("floor")
	anim:Hide("wall_side1")
	anim:Hide("wall_side2")
	anim:Hide("wall_back")
	
    inst:AddTag("structure")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")	
    return inst
end

return Prefab( "common/objects/generic_interior", fn, assets, prefabs )
