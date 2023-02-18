local function WatchPhase(inst, onenter)
	local _thresh = 0
	inst.fadetask = inst:DoPeriodicTask(.1, function()    
		if inst.components.interiorplayer.interiormode then
			local thresh = TheSim:GetLightAtPoint(10000, 10000, 10000) 
			inst.LightWatcher:SetLightThresh(0.075 + thresh) 
			inst.LightWatcher:SetDarkThresh(0.05 + thresh)
			if _thresh == thresh then
				if inst.fadetask then
					inst.fadetask:Cancel()
					inst.fadetask = nil
				end
			end
		else
			inst.LightWatcher:SetLightThresh(0.075) 
			inst.LightWatcher:SetDarkThresh(0.05)
			if inst.fadetask then
				inst.fadetask:Cancel()
				inst.fadetask = nil
			end
		end
	end)
end

return function(inst)
	-- inst.Physics:CollidesWith(COLLISION.WAVES)
	if not TheWorld.ismastersim then
		return
	end

	inst:AddComponent("interiorplayer")
	inst:AddComponent("shopper")
	inst:WatchWorldState("phase", WatchPhase)
	inst.UpdateInteriorDarkness = WatchPhase
end