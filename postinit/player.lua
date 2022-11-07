local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)

-- local function addInteriorPlayerComponents(inst)
	
-- end

HAMENV.AddPlayerPostInit(function(inst)
	-- inst.Physics:CollidesWith(COLLISION.WAVES)
	-- HAMENV.AddPrefabPostInitAny( function(inst)
		if inst and inst:HasTag("player") then
			if TheWorld.ismastersim then
				inst:AddComponent("interiorplayer")
				inst:AddComponent("shopper")
			end
		end
	-- end)
	
end)