Assets = {
	Asset("IMAGE", "images/colour_cubes/pigshop_interior_cc.tex"),
	
	Asset("IMAGE", "images/inventoryimages.tex"),
    Asset("ATLAS", "images/inventoryimages.xml"),
	
	Asset("IMAGE", "images/inventoryimages_2.tex"),
    Asset("ATLAS", "images/inventoryimages_2.xml"),
	
	Asset("IMAGE", "images/minimap/ham_minimap_atlas.tex"),
    Asset("ATLAS", "images/minimap/ham_minimap_data.xml"),
	
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
	
    Asset("ANIM", "anim/player_lifeplant.zip"), -- Will either of these work?
    Asset("ANIM", "anim/player_rebirth.zip"),
	
	Asset("IMAGE", "levels/textures/interiors/pig_ruins_panel.tex"),
	Asset("IMAGE", "levels/textures/interiors/ground_ruins_slab.tex"),
	Asset("IMAGE", "levels/textures/interiors/pig_ruins_panel_blue.tex"),
	Asset("IMAGE", "levels/textures/interiors/ground_ruins_slab_blue.tex"),
	Asset("IMAGE", "levels/textures/interiors/batcave_wall_rock.tex"),
	Asset("IMAGE", "levels/textures/interiors/batcave_floor.tex"),
	Asset("IMAGE", "levels/textures/noise_woodfloor.tex"),
	Asset("IMAGE", "levels/textures/interiors/harlequin_panel.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_wall_woodwall.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_floor_hexagon.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_wall_circles.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_floor_sheetmetal.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_wall_checkered_metal.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_floor_checker.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_floor_hoof_curvy.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_wall_fullwall_moulding.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_wall_sunflower2.tex"),
	Asset("IMAGE", "levels/textures/interiors/floor_cityhall.tex"),
	Asset("IMAGE", "levels/textures/interiors/wall_mayorsoffice_whispy.tex"),
	Asset("IMAGE", "levels/textures/interiors/shop_wall_marble.tex"),
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

AddMinimapAtlas("images/minimap/ham_minimap_data.xml")