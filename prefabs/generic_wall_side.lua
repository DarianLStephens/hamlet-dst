require "prefabutil"
	
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
    --MakeWallPhysics(inst, 10)
	MakeObstaclePhysics(inst, 1)
	inst.Transform:SetScale(2.3,2.3,2.3)
	inst.Transform:SetRotation(90)
	inst.Transform:SetNoFaced()
    inst:AddTag("structure")

    return inst
end

return Prefab( "common/objects/generic_wall_side", fn, {}, {} )  
