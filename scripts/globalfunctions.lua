require("utils/deco_util")
require("utils/deco_placer_util")

function _G.MakeInteriorPhysics(inst, depth, height, width)
    height = height or 20

    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    inst.Physics:SetMass(0) 
    --inst.Physics:SetCollisionGroup(COLLISION.INTWALL) -- GetWorldCollision()
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)    
    inst.Physics:SetRectangle(depth, height, width)
end

--Thx Hornet
function _G.PixelToUnit(pixels)
	return pixels/150
end

function _G.UnitToPixel(units)
	return units*150
end
