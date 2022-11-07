local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)

function MakeWallPhysics(inst, rad, height)
    height = height or 2

    inst:AddTag("blocker")
    inst.entity:AddPhysics()
	local phys = inst.Physics
    phys:SetMass(0) 
    -- phys:SetRectangle(rad,height) -- This function doesn't exist, unfortunately. Could maybe be substituted with the triangle mesh stuff, though.
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    -- inst.Physics:CollidesWith(COLLISION.INTWALL)
	return phys
end

function MakeInteriorPhysics(inst, rad, height, width)
    height = height or 20
	
    inst:AddTag("blocker")
    inst.entity:AddPhysics()
	local phys = inst.Physics
    phys:SetMass(0) 
    -- phys:SetRectangle(rad,height,width)
    -- phys:SetCollisionGroup(COLLISION.INTWALL) -- GetWorldCollision()
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)  
	return phys
end

-- function GetAporkalypse()     return GetWorldComponent("aporkalypse") end
-- function GetInteriorSpawner() return GetWorldComponent("interiorspawner") end
function GetAporkalypse()     return TheWorld.components.aporkalypse end
function GetInteriorSpawner() return TheWorld.components.interiorspawner end



-- UpvalueHacker = modimport("scripts/tools/upvaluehacker")

-- modimport("scripts/tools/upvaluehacker")
-- Makes UpvalueHacker available