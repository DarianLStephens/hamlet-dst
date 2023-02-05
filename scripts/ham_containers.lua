-- local params = require("containers").params

local containers = require "containers"

-- local smelter_slots = 

local smelter =
{
    widget =
    {
        slotpos = {	Vector3(0,64+32+8+4,0), 
					Vector3(0,32+4,0),
					Vector3(0,-(32+4),0), 
					Vector3(0,-(64+32+8+4),0)},
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = Vector3(200,0,0),
		side_align_tip = 100,
        buttoninfo =
        {
			-- text = STRINGS.ACTIONS.COOK.SMELT,
			text = "Smelt",
			position = Vector3(0, -165, 0),
			-- fn = function(inst)
				-- inst.components.melter:StartCooking()	
			-- end,
			
			-- validfn = function(inst)
				-- return inst.components.melter:CanCook()
			-- end,
        },
    },
	acceptsstacks = false,
	numslots = 4,
	type = "cooker",
	-- itemtestfn = function containers.params.smelter.itemtestfn(container, item, slot)
	itemtestfn = function(container, item, slot)
		if not container.inst:HasTag("burnt") then
			if item.prefab == "iron" then
				return true
			end
		end
	end
}

-- params["smelter"] = smelter
containers.params["smelter"] = smelter

function containers.params.smelter.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        -- BufferedAction(doer, inst, ACTIONS.COOK):Do()
		inst.components.melter:StartCooking()	
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.COOK.code, inst, ACTIONS.COOK.mod_name)
    end
end