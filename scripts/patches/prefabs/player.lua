return function(inst)
	-- inst.Physics:CollidesWith(COLLISION.WAVES)
	if inst and inst:HasTag("player") then
		if TheWorld.ismastersim then
			inst:AddComponent("interiorplayer")
			inst:AddComponent("shopper")
		end
	end
end