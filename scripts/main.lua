env._G = GLOBAL
_G.setmetatable(env,{__index=function(t,k) return _G.rawget(_G,k) end})

_G.CHEATS_ENABLED = true 
require("debugkeys")

local ToLoad = require("to_load")
PrefabFiles = ToLoad.Prefabs
Assets = ToLoad.Assets

for key, atlas in pairs(ToLoad.MiniMapAtlases) do
    AddMinimapAtlas(atlas)
end

for _, data in ipairs(ToLoad.InventoryItemsAtlasses) do
    for _, texture in ipairs(data.texture) do
        RegisterInventoryItemAtlas(data.atlas, texture)
    end
end

---- HAM Replicable Components ----
AddReplicableComponent("interiorplayer")

modimport("scripts/actions")
for k, v in pairs(require("ham_tunings")) do
    TUNING[k] = v
end

_G.UpvalueHacker =  require("tools/upvaluehacker")

modimport("scripts/constants.lua")
modimport("scripts/recipes.lua")
modimport("scripts/patches.lua")
modimport("scripts/strings.lua")
modimport("scripts/ham_fx.lua")
modimport("scripts/ham_containers.lua")
modimport("scripts/globalfunctions.lua")

modimport("strings/names") -- So things have their display names


AddModCharacter("waterbot", "ROBOT")
table.insert(SEAMLESSSWAP_CHARACTERLIST, "waterbot") 

AddTile(
    "INTERIOR",
    "LAND",
    { ground_name = "Interior" },
    { name="dirt", noise_texture="Ground_noise_dirt", runsound="dontstarve/movement/run_dirt", walksound="dontstarve/movement/walk_dirt", snowsound="dontstarve/movement/run_snow", mudsound="dontstarve/movement/run_mud", cannotbedug = true, flooring = true, hard = true }
)
