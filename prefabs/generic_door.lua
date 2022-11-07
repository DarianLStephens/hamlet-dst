require "prefabutil"
local assets =
{
Asset("ANIM", "anim/acorn.zip"),
}

local prefabs = 
{
}

local link = nil
local destination = nil



local notags = {'NOBLOCK', 'player', 'FX'}

local function displaynamefn(inst)
    if inst.growtime then
        return STRINGS.NAMES.ACORN_SAPLING
    end
    return STRINGS.NAMES.ACORN
end



local function Teleport(obj, target_x, target_y, target_z)
	--local target_x, target_y, target_z = destpos
	if obj.Physics ~= nil then
		obj.Physics:Teleport(target_x, target_y, target_z)
	elseif obj.Transform ~= nil then
		obj.Transform:SetPosition(target_x, target_y, target_z)
	end
	TheCamera:Snap()
end

local function Activate(inst, doer)
	print("Generic door activated!")
	--doer.transform:SetPosition(0,0,0)
	local link = inst.link
	if link then
		local x, y, z = link.Transform:GetWorldPosition()
		Teleport(doer, x, y, z)
	else
		print("Missing link in generic door!")
	end
end

local function usedoor(inst,data)
	print("Generic door UseDoor Activated, prefab-side")
    if inst.usesounds then
        if data and data.doer and data.doer.SoundEmitter then
            for i,sound in ipairs(inst.usesounds)do
                data.doer.SoundEmitter:PlaySound(sound)
            end
        end
    end
	Activate(inst,data.doer)
end



local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("acorn")
    inst.AnimState:SetBuild("acorn")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddTag("icebox_valid")
    inst:AddTag("cattoy")
	inst:AddTag("activedoor")
    inst:AddComponent("tradable")
	inst:AddComponent("door")
	
	-- inst:AddComponent("activatable")
	-- inst.components.activatable.standingaction = true
	-- inst.components.activatable.OnActivate = Activate
	
	inst:AddComponent("inspectable")
	inst:ListenForEvent("usedoor", function(inst,data) usedoor(inst,data) end)
    
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    --inst.components.burnable:MakeDragonflyBait(3)
    inst.displaynamefn = displaynamefn
    
	-- local interior_spawner = GetWorld().components.interiorspawner
	-- local door_def = {
		-- my_door_id = "generic door",
		-- target_door_id = "Bottom Door",
	-- }
	-- interior_spawner:AddDoor(inst, door_def)
	
	-- local interior_def = {
		-- unique_name = "The Generic Door",
		-- width = 65, -- Visible Spawn Width
		-- height = 20, -- Visible Spawn Height
		-- wall_width = 30, 
		-- wall_height = 20,
		-- prefabs = {
			-- { name = "generic_interior", x_offset = -2, z_offset = 0 },
			-- { name = "side_door", x_offset = 6.8, z_offset = 0, type = "bottom", my_door_id="CrazyDoor", target_door_id="Bottom Acorn Door" },
		-- }
	-- }	
	-- interiors:AddInterior(interior_def)
		
    return inst
end

return Prefab( "generic_door", fn, assets, prefabs)


