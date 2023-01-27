-- Entire prefab thanks to Asura!

local function build_mesh(vertices)
	print("Building mesh with vertices about to be dumped")
	dumptable(vertices, 1, 0, nil, 0)
	local triangles = {}
	local y0 = 0
    local y1 = 3

	local idx0 = #vertices
    for idx1 = 1, #vertices do

        local x0, z0 = vertices[idx0][1], vertices[idx0][2]
		local x1, z1 = vertices[idx1][1], vertices[idx1][2]
    
		--vertical one    
        table.insert(triangles, x0)
        table.insert(triangles, y0)
        table.insert(triangles, z0)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x1)
        table.insert(triangles, y0)
        table.insert(triangles, z1)

        table.insert(triangles, x0)
        table.insert(triangles, y1)
        table.insert(triangles, z0)

        table.insert(triangles, x1)
        table.insert(triangles, y1)
        table.insert(triangles, z1)

		idx0 = idx1
    end

	print("Constructed triangles, dumping...")
	dumptable(triangles, 1, 0, nil, 0)
	return triangles
end

--local vertices = {{-7.25, -9.25}, {-7.25, 9.25}, {5.25, 9.25}, {5.25, -9.25}}
local function interior_collision()
    local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.LAND_OCEAN_LIMITS)
    inst.Physics:CollidesWith(COLLISION.BOAT_LIMITS)
    inst.Physics:CollidesWith(COLLISION.LIMITS)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.FLYERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    -- inst.Physics:CollidesWith(COLLISION.GIANTS)
    
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
	inst:AddTag("interior_collision")
	
    inst.SetVerticles = function(inst, depth, width)
		print("Interior Collision prefab attempting to build a triangle mesh")
        -- inst.Physics:SetTriangleMesh(build_mesh({{-depth+0.5, -width}, {-depth+0.5, width}, {depth, width}, {depth, -width}}))
        inst.Physics:SetTriangleMesh(build_mesh({{-depth-0.5, -width}, {-depth-0.5, width}, {depth+0.5, width}, {depth+0.5, -width}}))
		-- First 2 values are the back of the room (Negative depth), last 2 are the from (Positive Depth). Value 1 is... right?
    end
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function OnCollideCeiling(inst, collider)
	if collider:IsValid() and collider.Transform  then
		local cy, cx, cz = collider.Transform:GetWorldPosition()
        if cx < 10 then
			if collider:HasTag("bird") then
				if collider.components.lootdropper  then
					collider.components.lootdropper:SetLoot({})
				end
				if collider.components.combat  then
					collider.components.combat:GetAttacked(inst, 5)
				end
				collider:PushEvent("gotosleep")
			end
		else
			if not inst:IsValid() then
				return
			end
			collider.Physics:Teleport(inst:GetNormalPosition(collider:GetPosition()):Get()) 
		end
	end
end

local function OnCeilingInit(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	inst.Transform:SetPosition(x, 8, z)
end

local function interior_ceiling()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	
	local phys = inst.entity:AddPhysics()
	phys:SetMass(0)
	phys:SetCollisionGroup(COLLISION.WORLD)
	phys:ClearCollisionMask()
	phys:CollidesWith(COLLISION.ITEMS)
	phys:CollidesWith(COLLISION.CHARACTERS)
	phys:CollidesWith(COLLISION.GIANTS)
	phys:CollidesWith(COLLISION.FLYERS)
	phys:SetCylinder(70, 70)
	phys:SetCollisionCallback(OnCollideCeiling)
	
	inst:DoTaskInTime(0, OnCeilingInit)
	
	return inst
end

return Prefab("interior_collision", interior_collision),
        Prefab("interior_ceiling", interior_ceiling)
