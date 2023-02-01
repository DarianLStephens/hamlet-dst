PrefabFiles = {
"playerhouse_city",
"pighousewithinterior",
"generic_door",
"home_prototyper",
"generic_wall_back",
"generic_wall_side",
"prop_door",
"generic_interior",
"deco_roomglow",
"shelf",
"shelf_slot",
"deco_antiquities",
"deco_swinging_light",
"deco_placers",
"deco",
"deco_lightglow",
"deco_academy",
"deco_chair",
"deco_florist",
"deco_lamp",
"deco_plantholder",
"deco_ruins_fountain",
"deco_table",
"deco_wall_ornament",
"construction_permit",
"house_door",
-- "oinc",
-- "oinc10",
-- "oinc100",
"oincs", -- The new combined Oincs file
"vampirebatcave",
"pig_ruins_entrance",
"pig_ruins_creeping_vines",
"pig_ruins_dart",
"pig_ruins_dart_statue",
"pig_ruins_light_beam",
"pig_ruins_pressure_plate",
"pig_ruins_spear_trap",
"pig_ruins_torch",
"scorpion",
"deep_jungle_fern_noise",
"rocks_ham",
"snake",
"smashingpot", -- This darn thing is instantly crashing the entire game, and I want to know why
"ham_light_rays",
"wallcrack_ruins",
"relics",
"ham_fx",
"cave_entrance_roc",
"pigman_city",
"pig_shop",
"musac",
"shop_pedestals",
"shop_spawner",
"shop_trinket",
"pigman_shopkeeper_desk",
"rug",
"littlehammer",
"iron",
"ancient_robots",
"ancient_robots_assembly",
"laser",
"laser_ring",
"living_artifact",
"waterbot",
"waterbot_none",
"ancient_hulk",
"interior_wall_fx",
"deed",
"demolition_permit",
"securitycontract",
"interior_collision",
"chitin",
"city_lamp",
"pighouse_city",
"alloy",
"smelter",
"reconstruction_project",
"waterdrop",
"floweroflife"
}

print("Hello world! Interior mod here! Coming at you from main.lua!")

-- local EntityScript = require("scripts/cameras/interiorcamera")
-- EntityScript.InteriorCamera = function(EntityScript)
-- function EntityScript:InteriorCamera()



local x = require("cameras/interiorcamera")
GLOBAL.InteriorCamera = x

GLOBAL.NUM_RELICS = 5


local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)

HAMENV.AddModCharacter("waterbot", "ROBOT")

table.insert(SEAMLESSSWAP_CHARACTERLIST, "waterbot") -- I still don't fully understand LUA global stuff like this


-- function GLOBAL.TheCamera:InteriorCamera()
-- end

-- local TheCamera = require("cameras/interiorcamera.lua")
-- TheCamera.InteriorCamera = function(EntityScript)end
-- function TheCamera:InteriorCamera()
-- end