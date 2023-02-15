local GenericPlayerFn = require("patches/prefabs/player")
local SimFn = require("patches/sim")
local CamFn = require("patches/camera")

local PATCHES = 
{
	COMPONENTS = {
		"inventoryitem",
		"birdspawner",
		"playercontroller",
	},
	
	PREFABS = {
		world = "world",
		player_classified = "player_classified",
	},
	
	SCREENS = {
	},

	WIDGETS = {
		"redux/craftingmenu_widget",	
		"redux/craftingmenu_hud",	
	},

	STATEGRAPHS = { --To patch existing states
		--"SGwilson", 
	},
	STATES = {--To add new states
		"wilson", 
		"wilson_client", 
	},
}

local function patch(prefab, fn)
	AddPrefabPostInit(prefab, fn)
end
	
for path, data in pairs(PATCHES.PREFABS) do
	local fn = require("patches/prefabs/"..path)
	
	if type(data) == "string" then
		patch(data, function(inst) fn(inst, data) end)
	else
		for _, pref in ipairs(data) do
			patch(pref, function(inst) fn(inst, pref) end)
		end
	end
end

AddPlayerPostInit(GenericPlayerFn)
AddSimPostInit(SimFn)
AddClassPostConstruct("cameras/followcamera", CamFn)

for _, name in ipairs(PATCHES.STATEGRAPHS) do
	AddStategraphPostInit(name, require("patches/stategraphs/"..name))
end

for _, file in ipairs(PATCHES.STATES) do
	local states = require("patches/states/"..file)
	for i, state in ipairs(states) do
		AddStategraphState(file, state)
	end
end

for _, file in ipairs(PATCHES.COMPONENTS) do
	local fn = require("patches/components/"..file)
	AddComponentPostInit(file, fn)
end

for _, file in ipairs(PATCHES.SCREENS) do
	local fn = require("patches/screens/"..file)
	AddClassPostConstruct("screens/"..file, fn)
end

for _, file in ipairs(PATCHES.WIDGETS) do
	local fn = require("patches/widgets/"..file)
	AddClassPostConstruct("widgets/"..file, fn)
end

EmitterManager._updatefuncs = {snow = nil, rain = nil, pollen = nil}
local _PostUpdate = EmitterManager.PostUpdate
local function PostUpdate(self,...)
	for inst, data in pairs( self.awakeEmitters.infiniteLifetimes ) do
		if inst.prefab == "pollen" or inst.prefab == "snow" or inst.prefab == "rain" then
			if not self._updatefuncs[inst.prefab] then
				self._updatefuncs[inst.prefab] = data.updateFunc
			end
			local x,y,z = inst.Transform:GetWorldPosition()
			if x > 1800 then
				data.updateFunc = function() end 
			else
				data.updateFunc = self._updatefuncs[inst.prefab] and self._updatefuncs[inst.prefab] or function() end
			end
		end
	end
	if _PostUpdate then
		return _PostUpdate(self,...)
	end
end
EmitterManager.PostUpdate = PostUpdate

local _PlayFootstep = _G.PlayFootstep
function _G.PlayFootstep(inst, volume, ispredicted, ...)
	local sound = inst.SoundEmitter
	if sound then
		local size_inst = inst
        if inst:HasTag("player") then
            local rider = inst.components.rider or inst.replica.rider
            if rider  and rider:IsRiding() then
                size_inst = rider:GetMount() or inst
            end
        end
		local groundsound = inst.replica.interiorplayer and inst.replica.interiorplayer:GetGroundSound()--GetClosestInterior(inst)
		if not groundsound  then
			return _PlayFootstep(inst, volume, ispredicted, ...)
		end
		sound:PlaySound(
			(inst.sg and inst.sg:HasStateTag("running") and "dontstarve/movement/run_"..groundsound or "dontstarve/movement/walk_"..groundsound
			)..
			(   (size_inst:HasTag("smallcreature") and "_small") or
				(size_inst:HasTag("largecreature") and "_large" or "")
			),
			nil,
			volume or 1,
			ispredicted)	
	end
end

local _MakeSnowCovered = _G.MakeSnowCovered
function _G.MakeSnowCovered(inst)
	inst:DoTaskInTime(0, function()
		local interior = GetClosestInterior(inst)
		if interior then
			inst.AnimState:Hide("snow")
			return
		end
		return _MakeSnowCovered(inst)
	end)
end

AddGlobalClassPostConstruct("recipe", "Recipe", function(self, name, ingredients, tab, level, placer_or_more_data, ...)
	self.wallitem = placer_or_more_data.wallitem
	self.decor = placer_or_more_data.decor
	self.flipable = placer_or_more_data.flipable
end)
