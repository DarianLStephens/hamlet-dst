local GenericPlayerFn = require("patches/prefabs/player")
local SimFn = require("patches/sim")

local PATCHES = 
{
	COMPONENTS = {
		"inventoryitem",
	},
	
	PREFABS = {
		world = "world",
		player_classified = "player_classified",
	},
	
	SCREENS = {
	},

	WIDGETS = {},

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
