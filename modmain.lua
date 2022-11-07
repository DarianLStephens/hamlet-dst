local TUNING = GLOBAL.TUNING

-- Assets = {
	-- Asset("IMAGE", "images/inventoryimages.tex"),
    -- Asset("ATLAS", "images/inventoryimages.xml"),
	
	-- Asset("IMAGE", "images/inventoryimages_2.tex"),
    -- Asset("ATLAS", "images/inventoryimages_2.xml"),
	
	-- Asset("SOUNDPACKAGE", "sound/dontstarve_DLC003.fev"),
	-- Asset("SOUND", "sound/DLC003_sfx.fsb"),
	
    -- Asset("ANIM", "anim/player_actions_tap.zip"),
	
    -- Asset("ANIM", "anim/player_living_suit_destruct.zip"),
    -- Asset("ANIM", "anim/player_living_suit_morph.zip"),
    -- Asset("ANIM", "anim/player_living_suit_punch.zip"),
    -- Asset("ANIM", "anim/player_living_suit_shoot.zip"),
	
    -- Asset("ANIM", "anim/living_suit_build.zip"),
    -- Asset("ANIM", "anim/living_suit_explode_fx.zip"),
    -- Asset("ANIM", "anim/livingartifact_meter.zip"),
-- }

--local MaxIndicator = GetModConfigData("MaxIndicator")

TUNING.GLOBAL_BUFFER_ZONE = 300
TUNING.ROOM_BUFFER_ZONE = 100
TUNING.MAX_ROOM_CARDINAL = 10

---- HAM Replicable Components ----

-- modimport("interiorplayer_replica")
AddReplicableComponent("interiorplayer")

modimport("scripts/main.lua")
--print("Hello world! Interior mod here!")
modimport("scripts/actions")
modimport("scripts/recipes.lua")
modimport("postinit/stategraphs/SGwilson.lua")
modimport("postinit/sim.lua")
modimport("scripts/components/interiorspawner.lua")
modimport("postinit/prefabs/world.lua")
modimport("scripts/cameras/interiorcamera.lua")
modimport("main/tuning.lua")
modimport("main/globalfunctions.lua")
modimport("scripts/ham_fx.lua")

modimport("postinit/player.lua")
modimport("postinit/prefabs/player_classified.lua")

modimport("strings/names") -- So things have their display names
modimport("main/strings.lua")

modimport("main/assets.lua")