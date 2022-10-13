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
"construction_permit",
"house_door",
"oinc",
"oinc10",
"oinc100"}

print("Hello world! Interior mod here! Coming at you from main.lua!")

-- local EntityScript = require("scripts/cameras/interiorcamera")
-- EntityScript.InteriorCamera = function(EntityScript)
-- function EntityScript:InteriorCamera()

local x = require("cameras/interiorcamera")
GLOBAL.InteriorCamera = x


-- function GLOBAL.TheCamera:InteriorCamera()
-- end

-- local TheCamera = require("cameras/interiorcamera.lua")
-- TheCamera.InteriorCamera = function(EntityScript)end
-- function TheCamera:InteriorCamera()
-- end