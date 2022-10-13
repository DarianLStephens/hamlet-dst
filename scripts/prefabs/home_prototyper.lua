require "prefabutil"

local prefabs =
{

}






local function OnLoad(inst,data)
    if not data then
        return
    end
end

local function OnSave(inst,data)

end

local function canCurrentlyPrototypeTestFn()
	-- we can prototype if we're in a player interior
    local interiorSpawner = GetWorld().components.interiorspawner
	return interiorSpawner and interiorSpawner.current_interior and interiorSpawner.current_interior.playerroom
end

local function CreatePrototyper(name, state, techtree)
	
    -- light, rad, intensity, falloff, colour, time, callback
	local function OnTurnOn(inst)
        inst.components.prototyper.on = true  -- prototyper doesn't set this until after this function is called!!
	end
	local function OnTurnOff(inst)
        inst.components.prototyper.on = false  -- prototyper doesn't set this until after this function is called
	end

	local assets = 
	{
		Asset("ANIM", "anim/researchlab.zip"),
	}

	local function InitFn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()  

        anim:SetBank("researchlab")
        anim:SetBuild("researchlab")
        anim:PlayAnimation("idle")

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
	        
		inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

		inst:AddTag("prototyper")		

		inst:AddComponent("prototyper")
		inst.components.prototyper.onturnon = OnTurnOn
		inst.components.prototyper.onturnoff = OnTurnOff
		
		inst.components.prototyper.trees = techtree
		inst.components.prototyper.craftingstation = true

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

		-- inst.components.prototyper.onactivate = function()

            -- inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft","sound")

			-- inst:DoTaskInTime(1.5, function() 
				-- inst.SoundEmitter:KillSound("sound")
				-- inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_2_ding","sound")		
			-- end)
		-- end
		
        -- inst.components.prototyper.onactivate = onactivate

        inst:AddComponent("wardrobe")
        inst.components.wardrobe:SetCanUseAction(false) --also means NO wardrobe tag!
        inst.components.wardrobe:SetCanBeShared(true)
        inst.components.wardrobe:SetRange(10)
		
    	--inst.components.prototyper:SetCanPrototypeTestFunction(canCurrentlyPrototypeTestFn)

		inst.persists = false

		inst:Hide()
		return inst
	end

	return Prefab( "common/objects/"..name, InitFn, assets, prefabs)

end

return CreatePrototyper("home_prototyper", true, TUNING.PROTOTYPER_TREES.HOME)


