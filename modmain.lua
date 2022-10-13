local TUNING = GLOBAL.TUNING

--local MaxIndicator = GetModConfigData("MaxIndicator")

TUNING.GLOBAL_BUFFER_ZONE = 300
TUNING.ROOM_BUFFER_ZONE = 100
TUNING.MAX_ROOM_CARDINAL = 10

modimport("scripts/main.lua")
--print("Hello world! Interior mod here!")
modimport("scripts/actions")
modimport("scripts/recipes.lua")
modimport("postinit/stategraphs/SGwilson.lua")
modimport("postinit/sim.lua")
modimport("scripts/components/interiorspawner.lua")
modimport("postinit/prefabs/world.lua")
modimport("scripts/cameras/interiorcamera.lua")