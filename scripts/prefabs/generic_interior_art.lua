require "prefabutil"
	
local assets =
{
	Asset("ANIM", "anim/pig_room_general.zip"),
}

local function SetArt(inst, symbol)
	inst.AnimState:OverrideSymbol(symbol, "pig_room_wood", symbol)
	inst.AnimState:Show(symbol)
	inst.current_art = symbol
end

local function SaveInteriorData(inst, save_data)
	if inst.current_art then
		save_data.current_art = inst.current_art
	end
end

local function InitFromInteriorSave(inst, save_data)
	if save_data.current_art then
		SetArt(inst, save_data.current_art)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("pig_room")
    anim:SetBuild("pig_room_general")
    anim:PlayAnimation("idle", true)
    anim:OverrideSymbol("wall_back", "pig_room_wood", "wall_back")
	anim:Hide("wall_back")
	anim:Hide("wall_side1")
	anim:Hide("wall_side2")
	anim:Hide("floor")
	
	inst.setArt = SetArt
	inst:AddTag("structure")
	
	inst.saveInteriorData = SaveInteriorData
	inst.initFromInteriorSave = InitFromInteriorSave
    return inst
end

return Prefab( "common/objects/generic_interior_art", fn, assets, {} )  
