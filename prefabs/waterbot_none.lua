local assets =
{
	Asset("ANIM", "anim/living_suit_build.zip"),
	-- Asset( "ANIM", "anim/ghost_waterbot_build.zip" ),
}

local skins =
{
	normal_skin = "living_suit_build",
	-- ghost_skin = "ghost_waterbot_build",
}

return CreatePrefabSkin("waterbot_none",
{
	base_prefab = "waterbot",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"waterbot", "CHARACTER", "BASE"},
	build_name_override = "living_suit_build",
	rarity = "Character",
})