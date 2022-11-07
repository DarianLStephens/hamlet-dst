Assets = {
	Asset("IMAGE", "images/colour_cubes/pigshop_interior_cc.tex"),
	
	Asset("IMAGE", "images/inventoryimages.tex"),
    Asset("ATLAS", "images/inventoryimages.xml"),
	
	Asset("IMAGE", "images/inventoryimages_2.tex"),
    Asset("ATLAS", "images/inventoryimages_2.xml"),
	
	Asset("SOUNDPACKAGE", "sound/dontstarve_DLC003.fev"),
	Asset("SOUND", "sound/DLC003_sfx.fsb"),
	
    Asset("ANIM", "anim/player_actions_tap.zip"),
	
    Asset("ANIM", "anim/player_living_suit_destruct.zip"),
    Asset("ANIM", "anim/player_living_suit_morph.zip"),
    Asset("ANIM", "anim/player_living_suit_punch.zip"),
    Asset("ANIM", "anim/player_living_suit_shoot.zip"),
	
    Asset("ANIM", "anim/living_suit_build.zip"),
    Asset("ANIM", "anim/living_suit_explode_fx.zip"),
    Asset("ANIM", "anim/livingartifact_meter.zip"),
}

local textures = require("assets/inventorytextures1")
local atlas = GLOBAL.resolvefilepath("images/inventoryimages.xml")

for i, tex in pairs(textures) do
    RegisterInventoryItemAtlas(atlas, tex)
end


textures = require("assets/inventorytextures2")
atlas = GLOBAL.resolvefilepath("images/inventoryimages_2.xml")
for i, tex in pairs(textures) do
    RegisterInventoryItemAtlas(atlas, tex)
end