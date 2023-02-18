local function BuildMesh(vertices, height)
    local triangles = {}
    local y0 = 0
    local y1 = height
 
    local idx0 = #vertices
    for idx1 = 1, #vertices do
        local x0, z0 = vertices[idx0].x, vertices[idx0].z
        local x1, z1 = vertices[idx1].x, vertices[idx1].z
 
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
 
    return triangles
end

local function CreateBounds(inst, depth, width, height, name)
    local vertexes = {
        Vector3(((depth+0.5)/2), 0, -((width+0.5)/2)),
        Vector3(-((depth+0.5)/2), 0, -((width+0.5)/2)),
        Vector3(-((depth+0.5)/2), 0, ((width+0.5)/2)),
        Vector3(((depth+0.5)/2), 0, ((width+0.5)/2)),
    }
    inst:DoTaskInTime(0, function()
        local _x,_,_z = inst.Transform:GetWorldPosition()
        for x = -depth/2, depth/2 do
            for z = -width/2, width/2 do
                TheWorld.Map:SetInteriorTileData(_x+x,0,_z+z,name)
            end
        end
    end)
    inst.Physics:SetTriangleMesh(BuildMesh(vertexes, height or 3))
end

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

    inst.depth = net_smallbyte(inst.GUID, "interior_collision.depth", "interiorcollisiondirty")
    inst.width = net_smallbyte(inst.GUID, "interior_collision.width", "interiorcollisiondirty")
    inst.height = net_smallbyte(inst.GUID, "interior_collision.height", "interiorcollisiondirty")
    inst.name = net_string(inst.GUID, "interior_collision.name")

    inst.depth:set(0)
    inst.width:set(0)
    inst.height:set(0)
    inst.name:set("")
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("interiorcollisiondirty", function()
            CreateBounds(inst, inst.depth:value(), inst.width:value(), inst.height:value(), inst.name:value())
        end)
        return inst
    end

    inst:AddComponent("lightningblocker")

    inst.SetName = function(inst, name)
        inst.name:set(name)
    end

    inst.SetVerticles = function(inst, depth, width, height)
        inst.depth:set(depth)
        inst.width:set(width)
        inst.height:set(height)
        inst.components.lightningblocker:SetBlockRange(math.sqrt(depth*depth + width*width)/2)
        
        CreateBounds(inst, depth, width, height, inst.name:value())

        if height then
            if not inst.ceiling then
                inst.ceiling = SpawnAt("interior_ceiling", inst)
            end
            local x, y, z = inst.Transform:GetWorldPosition()
            inst.ceiling.Transform:SetPosition(x, 3+height, z)
        end
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
			--collider.Physics:Teleport(inst:GetNormalPosition(collider:GetPosition()):Get()) 
		end
	end
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
	
	return inst
end

return Prefab("interior_collision", interior_collision),
        Prefab("interior_ceiling", interior_ceiling)
