local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    -- Asset("ANIM", "anim/living_suit_build.zip"),
}

local prefabs =
{
    
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WILSON
end

prefabs = FlattenTree({ prefabs, start_inv }, true)



local function RightClickPicker(inst, target_ent, pos)
    if not inst.sg:HasStateTag("charging") then
        return inst.components.playeractionpicker:SortActionList({ACTIONS.CHARGE_UP}, nil, nil)
    end    
    return {}
end
-- local function IronLordhurt(inst, delta)
local function IronLordhurt(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    if amount < 0 then
        inst.sg:PushEvent("attacked")
    end
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right then
        return { ACTIONS.CHARGE_UP }
    end
    return {}
end

local function OnSetOwner(inst)
	print("DS - Waterbot owner set thing running, attempting to make the charge action")
    if inst.components.playeractionpicker ~= nil then
		print("Charge action picker being set...")
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
	else
		print("Failed to find the action picker component")
    end
	inst.AnimState:SetBuild("living_suit_build")
end

local function common_postinit(inst)
	inst:ListenForEvent("setowner", OnSetOwner)
	-- inst:AddTag("invincible")
end


local function master_postinit(inst)

	inst:SetStateGraph("SGironlord")

    inst:AddComponent("worker")
    inst.components.worker:SetAction(ACTIONS.DIG, 1)
    inst.components.worker:SetAction(ACTIONS.CHOP, 4)
    inst.components.worker:SetAction(ACTIONS.MINE, 3)
    inst.components.worker:SetAction(ACTIONS.HAMMER, 3)
    -- inst.components.worker:SetAction(ACTIONS.HACK, 2)   

    -- inst:AddTag("umbrella")
	-- inst:AddTag("waterproofer")
	-- inst:AddComponent("waterproofer")
	-- inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

    inst:AddTag("ironlord")
    inst:AddTag("has_gasmask")
	
	-- inst:AddComponent("playeractionpicker") -- Probably jank and dangerous, but I want this working dangit!
	
	-- inst.components.playercontroller.actionbuttonoverride = ArtifactActionButton
    -- inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
    -- inst.components.playeractionpicker.rightclickoverride = RightClickPicker

    inst.components.combat:SetDefaultDamage(TUNING.IRON_LORD_DAMAGE)

    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*1.3 -- Maybe make this a tuning value of its own?
	
    inst.components.sanity:SetPercent(1)
    inst.components.health:SetPercent(1)
    inst.components.hunger:SetPercent(1)

    inst.components.hunger:Pause()
    inst.components.sanity.ignore = true
    inst.components.health.redirect = IronLordhurt
    -- inst.components.health.redirect_percent = 0
	inst.components.health.canheal = false

    inst:AddTag("laser_immune")
    inst:AddTag("mech")
	
	inst.nightlight = SpawnPrefab("living_artifact_light")
    inst:AddChild(inst.nightlight)
	
    if inst:HasTag("lightsource") then       
        inst:RemoveTag("lightsource")    
    end    

    inst:AddTag("notslippery")
    inst:AddTag("cantdrop")      
end

return MakePlayerCharacter("waterbot", prefabs, assets, common_postinit, master_postinit)
