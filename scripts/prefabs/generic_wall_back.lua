require "prefabutil"
	
local function setUp(inst,width,rotation,coords,depth)
	if width then
		inst.wall_width = width
		inst.wall_depth = depth
		--MakeInteriorPhysics(inst, width, nil, depth)
	end
	if rotation then
		inst.wall_rotation = rotation
		inst.Transform:SetRotation(rotation)
	end
end

local function InitFromInteriorSave(inst, save_data)
	inst.setUp(inst, save_data.wall_width, save_data.wall_rotation)
end


local function onsave(inst, data)
	if inst.wall_width then
		data.wall_width = inst.wall_width
	end
	if inst.wall_depth then
		data.wall_depth = inst.wall_depth
	end
	if inst.wall_rotation then
		data.wall_rotation = inst.wall_rotation
	end

end

local function onload(inst, data)
	if data then
		if data.wall_width then
			inst.wall_width = data.wall_width
		end
		if data.wall_depth then
			inst.wall_depth = data.wall_depth
		end
		if data.wall_rotation then
			inst.wall_rotation = data.wall_rotation
		end
		setUp(inst,inst.wall_width,inst.wall_rotation, nil, inst.wall_depth)
	end
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)   
	inst.Transform:SetScale(1,1,1)
	inst.Transform:SetNoFaced()
    inst:AddTag("structure")
    inst:AddTag("NOBLOCK")

    inst.setUp = setUp
	inst.initFromInteriorSave = InitFromInteriorSave
    
    --------SaveLoad
    inst.OnSave = onsave 
    inst.OnLoad = onload 	

    return inst
end

return Prefab( "common/objects/generic_wall_back", fn, {}, {} )  
