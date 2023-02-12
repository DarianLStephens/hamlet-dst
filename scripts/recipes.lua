local TechTree = require("techtree")

TUNING.PROTOTYPER_TREES.HOME = {
	HOME = TechTree.Create({
		HOME = 2
	})
}
--TUNING.PROTOTYPER_TREES.HOME = {HOME = 2}
local TABS = {
	DOORS 		  = { str = "Doors",       	 sort = 13, icon = "reno_doors_plate.tex",      isReno = true },
    HOME_KITS     = { str = "Home Kits",      sort = 14, icon = "reno_tab_homekits.tex",     isReno = true },
    CHAIRS        = { str = "Chairs",        sort = 15, icon = "reno_tab_chairs.tex",       isReno = true },
    SHELVES       = { str = "Shelves",       sort = 16, icon = "reno_tab_shelves.tex",      isReno = true },
    RUGS          = { str = "Rugs",          sort = 17, icon = "reno_tab_rugs.tex",         isReno = true },
    LAMPS         = { str = "Lamps",         sort = 18, icon = "reno_tab_lamps.tex",        isReno = true },
    PLANT_HOLDERS = { str = "Plantholders",  sort = 19, icon = "reno_tab_plantholders.tex", isReno = true },
    TABLES        = { str = "Tables",        sort = 20, icon = "reno_tab_tables.tex",       isReno = true },
    ORNAMENTS     = { str = "Ornaments",     sort = 21, icon = "reno_tab_ornaments.tex",    isReno = true },
    WINDOWS       = { str = "Windows",       sort = 22, icon = "reno_tab_windows.tex",      isReno = true },
    COLUMNS       = { str = "Columns",       sort = 23, icon = "reno_tab_columns.tex",      isReno = true },
    FLOORING      = { str = "Floors",      sort = 24, icon = "reno_tab_floors.tex",       isReno = true },
    WALLPAPER     = { str = "Wallpaper",     sort = 25, icon = "reno_tab_wallpaper.tex",    isReno = true },
    HANGING_LAMPS = { str = "Hanging Lamps",  sort = 26, icon = "reno_tab_hanginglamps.tex", isReno = true }
}

local interioraltas = "images/porkland_inventoryimages.xml"
do
    for k, v in pairs(TABS) do
        STRINGS.UI.CRAFTING_FILTERS[k] = v.str
        AddRecipeFilter({name = k, atlas = resolvefilepath(interioraltas), image = v.icon})    
    end
end

AddRecipe2("playerhouse_city", {Ingredient("boards", 5), Ingredient("rope", 5)}, TECH.NONE, {placer="playerhouse_city_placer", image = "playerhouse_city.tex"}, {"STRUCTURES"})

-- Recipe("pighouse_city", {Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pighouse_city_placer", nil, true)

-- Recipe("securitycontract", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true)

AddRecipe2("player_house_cottage_craft",                {Ingredient("oinc", 10)},TECH.NONE,            {}, {"HOME_KITS"})
AddRecipe2("player_house_tudor_craft",                  {Ingredient("oinc", 10)},TECH.NONE,            {}, {"HOME_KITS"})
AddRecipe2("player_house_gothic_craft",                 {Ingredient("oinc", 10)},TECH.NONE,            {}, {"HOME_KITS"})
AddRecipe2("player_house_brick_craft",                  {Ingredient("oinc", 10)},TECH.NONE,            {}, {"HOME_KITS"})
AddRecipe2("player_house_turret_craft",                 {Ingredient("oinc", 10)},TECH.NONE,            {}, {"HOME_KITS"})
AddRecipe2("player_house_villa_craft",                  {Ingredient("oinc", 30)},TECH.NONE,            {}, {"HOME_KITS"})
AddRecipe2("player_house_manor_craft",                  {Ingredient("oinc", 30)},TECH.NONE,            {}, {"HOME_KITS"})

AddRecipe2("deco_chair_classic",                        {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_classic_placer", image = "reno_chair_classic.tex"}, {"CHAIRS"})
AddRecipe2("deco_chair_corner",                         {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_corner_placer", image = "reno_chair_corner.tex"}, {"CHAIRS"})
AddRecipe2("deco_chair_bench",                          {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_bench_placer", image = "reno_chair_bench.tex"}, {"CHAIRS"})
AddRecipe2("deco_chair_horned",                         {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_horned_placer", image = "reno_chair_horned.tex"}, {"CHAIRS"})
AddRecipe2("deco_chair_footrest",                       {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_footrest_placer", image = "reno_chair_footrest.tex"}, {"CHAIRS"})
AddRecipe2("deco_chair_lounge",                         {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_lounge_placer", image = "reno_chair_lounge.tex"}, {"CHAIRS"})
AddRecipe2("deco_chair_massager",                       {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_massager_placer", image = "reno_chair_massager.tex"}, {"CHAIRS"})
AddRecipe2("deco_chair_stuffed",                        {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_stuffed_placer", image = "reno_chair_stuffed.tex"}, {"CHAIRS"})
AddRecipe2("deco_chair_rocking",                        {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_rocking_placer", image = "reno_chair_rocking.tex"}, {"CHAIRS"})
AddRecipe2("deco_chair_ottoman",                        {Ingredient("oinc", 2)}, TECH.NONE,            {placer="chair_ottoman_placer", image = "reno_chair_ottoman.tex"}, {"CHAIRS"})
AddRecipe2("deco_chaise",                               {Ingredient("oinc", 15)},TECH.NONE,            {placer="deco_chaise_placer", image = "reno_chair_chaise.tex"}, {"CHAIRS"})

AddRecipe2("shelves_wood",                              {Ingredient("oinc", 2)}, TECH.NONE,            {placer="shelves_wood_placer", image = "reno_shelves_wood.tex"}, {"SHELVES"})
AddRecipe2("shelves_basic",                             {Ingredient("oinc", 2)}, TECH.NONE,            {placer="shelves_basic_placer", image = "reno_shelves_basic.tex"}, {"SHELVES"})
AddRecipe2("shelves_cinderblocks",                      {Ingredient("oinc", 1)}, TECH.NONE,            {placer="shelves_cinderblocks_placer", image = "reno_shelves_cinderblocks.tex"}, {"SHELVES"})
AddRecipe2("shelves_marble",                            {Ingredient("oinc", 8)}, TECH.NONE,            {placer="shelves_marble_placer", image = "reno_shelves_marble.tex"}, {"SHELVES"})
AddRecipe2("shelves_glass",                             {Ingredient("oinc", 8)}, TECH.NONE,            {placer="shelves_glass_placer", image = "reno_shelves_glass.tex"}, {"SHELVES"})
AddRecipe2("shelves_ladder",                            {Ingredient("oinc", 8)}, TECH.NONE,            {placer="shelves_ladder_placer", image = "reno_shelves_ladder.tex"}, {"SHELVES"})
AddRecipe2("shelves_hutch",                             {Ingredient("oinc", 8)}, TECH.NONE,            {placer="shelves_hutch_placer", image = "reno_shelves_hutch.tex"}, {"SHELVES"})
AddRecipe2("shelves_industrial",                        {Ingredient("oinc", 8)}, TECH.NONE,            {placer="shelves_industrial_placer", image = "reno_shelves_industrial.tex"}, {"SHELVES"})
AddRecipe2("shelves_adjustable",                        {Ingredient("oinc", 8)}, TECH.NONE,            {placer="shelves_adjustable_placer", image = "reno_shelves_adjustable.tex"}, {"SHELVES"})
AddRecipe2("shelves_midcentury",                        {Ingredient("oinc", 6)}, TECH.NONE,            {placer="shelves_midcentury_placer", image = "reno_shelves_midcentury.tex"}, {"SHELVES"})
AddRecipe2("shelves_wallmount",                         {Ingredient("oinc", 6)}, TECH.NONE,            {placer="shelves_wallmount_placer", image = "reno_shelves_wallmount.tex"}, {"SHELVES"})
AddRecipe2("shelves_aframe",                            {Ingredient("oinc", 6)}, TECH.NONE,            {placer="shelves_aframe_placer", image = "reno_shelves_aframe.tex"}, {"SHELVES"})
AddRecipe2("shelves_crates",                            {Ingredient("oinc", 6)}, TECH.NONE,            {placer="shelves_crates_placer", image = "reno_shelves_crates.tex"}, {"SHELVES"})
AddRecipe2("shelves_fridge",                            {Ingredient("oinc", 6)}, TECH.NONE,            {placer="shelves_fridge_placer", image = "reno_shelves_fridge.tex"}, {"SHELVES"})
AddRecipe2("shelves_floating",                          {Ingredient("oinc", 6)}, TECH.NONE,            {placer="shelves_floating_placer", image = "reno_shelves_floating.tex"}, {"SHELVES"})
AddRecipe2("shelves_pipe",                              {Ingredient("oinc", 6)}, TECH.NONE,            {placer="shelves_pipe_placer", image = "reno_shelves_pipe.tex"}, {"SHELVES"})
AddRecipe2("shelves_hattree",                           {Ingredient("oinc", 6)}, TECH.NONE,            {placer="shelves_hattree_placer", image = "reno_shelves_hattree.tex"}, {"SHELVES"})
AddRecipe2("shelves_pallet",                            {Ingredient("oinc", 6)}, TECH.NONE,            {placer="shelves_pallet_placer", image = "reno_shelves_pallet.tex"}, {"SHELVES"})


AddRecipe2("rug_round",                                 {Ingredient("oinc", 2)}, TECH.NONE,            {placer="rug_round_placer", image = "reno_rug_round.tex"}, {"RUGS"})
AddRecipe2("rug_square",                                {Ingredient("oinc", 2)}, TECH.NONE,            {placer="rug_square_placer", image = "reno_rug_square.tex"}, {"RUGS"})
AddRecipe2("rug_oval",                                  {Ingredient("oinc", 2)}, TECH.NONE,            {placer="rug_oval_placer", image = "reno_rug_oval.tex"}, {"RUGS"})
AddRecipe2("rug_rectangle",                             {Ingredient("oinc", 3)}, TECH.NONE,            {placer="rug_rectangle_placer", image = "reno_rug_rectangle.tex"}, {"RUGS"})
AddRecipe2("rug_fur",                                   {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_fur_placer", image = "reno_rug_fur.tex"}, {"RUGS"})
AddRecipe2("rug_hedgehog",                              {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_hedgehog_placer", image = "reno_rug_hedgehog.tex"}, {"RUGS"})
AddRecipe2("rug_porcupuss",                             {Ingredient("oinc", 10)},TECH.NONE,            {placer="rug_porcupuss_placer", image = "reno_rug_porcupuss.tex"}, {"RUGS"})
AddRecipe2("rug_hoofprint",                             {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_hoofprint_placer", image = "reno_rug_hoofprint.tex"}, {"RUGS"})
AddRecipe2("rug_octagon",                               {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_octagon_placer", image = "reno_rug_octagon.tex"}, {"RUGS"})
AddRecipe2("rug_swirl",                                 {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_swirl_placer", image = "reno_rug_swirl.tex"}, {"RUGS"})
AddRecipe2("rug_catcoon",                               {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_catcoon_placer", image = "reno_rug_catcoon.tex"}, {"RUGS"})
AddRecipe2("rug_rubbermat",                             {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_rubbermat_placer", image = "reno_rug_rubbermat.tex"}, {"RUGS"})
AddRecipe2("rug_web",                                   {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_web_placer", image = "reno_rug_web.tex"}, {"RUGS"})
AddRecipe2("rug_metal",                                 {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_metal_placer", image = "reno_rug_metal.tex"}, {"RUGS"})
AddRecipe2("rug_wormhole",                              {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_wormhole_placer", image = "reno_rug_wormhole.tex"}, {"RUGS"})
AddRecipe2("rug_braid",                                 {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_braid_placer", image = "reno_rug_braid.tex"}, {"RUGS"})
AddRecipe2("rug_beard",                                 {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_beard_placer", image = "reno_rug_beard.tex"}, {"RUGS"})
AddRecipe2("rug_nailbed",                               {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_nailbed_placer", image = "reno_rug_nailbed.tex"}, {"RUGS"})
AddRecipe2("rug_crime",                                 {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_crime_placer", image = "reno_rug_crime.tex"}, {"RUGS"})
AddRecipe2("rug_tiles",                                 {Ingredient("oinc", 5)}, TECH.NONE,            {placer="rug_tiles_placer", image = "reno_rug_tiles.tex"}, {"RUGS"})

AddRecipe2("deco_lamp_fringe",                          {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_fringe_placer", image = "reno_lamp_fringe.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_stainglass",                      {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_stainglass_placer", image = "reno_lamp_stainglass.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_downbridge",                      {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_downbridge_placer", image = "reno_lamp_downbridge.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_2embroidered",                    {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_2embroidered_placer", image = "reno_lamp_2embroidered.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_ceramic",                         {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_ceramic_placer", image = "reno_lamp_ceramic.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_glass",                           {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_glass_placer", image = "reno_lamp_glass.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_2fringes",                        {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_2fringes_placer", image = "reno_lamp_2fringes.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_candelabra",                      {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_candelabra_placer", image = "reno_lamp_candelabra.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_elizabethan",                     {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_elizabethan_placer", image = "reno_lamp_elizabethan.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_gothic",                          {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_gothic_placer", image = "reno_lamp_gothic.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_orb",                             {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_orb_placer", image = "reno_lamp_orb.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_bellshade",                       {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_bellshade_placer", image = "reno_lamp_bellshade.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_crystals",                        {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_crystals_placer", image = "reno_lamp_crystals.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_upturn",                          {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_upturn_placer", image = "reno_lamp_upturn.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_2upturns",                        {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_2upturns_placer", image = "reno_lamp_2upturns.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_spool",                           {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_spool_placer", image = "reno_lamp_spool.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_edison",                          {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_edison_placer", image = "reno_lamp_edison.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_adjustable",                      {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_adjustable_placer", image = "reno_lamp_adjustable.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_rightangles",                     {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_rightangles_placer", image = "reno_lamp_rightangles.tex"}, {"LAMPS"})
AddRecipe2("deco_lamp_hoofspa",                         {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_lamp_hoofspa_placer", image = "reno_lamp_hoofspa.tex"}, {"LAMPS"})


AddRecipe2("deco_plantholder_basic",                    {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_basic_placer", image = "reno_plantholder_basic.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_wip",                      {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_wip_placer", image = "reno_plantholder_wip.tex"}, {"PLANT_HOLDERS"})
--AddRecipe2("deco_plantholder_fancy",                    {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_fancy_placer", image = "reno_plantholder_fancy.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_marble",                   {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_marble_placer", image = "reno_plantholder_marble.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_bonsai",                   {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_bonsai_placer", image = "reno_plantholder_bonsai.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_dishgarden",               {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_dishgarden_placer", image = "reno_plantholder_dishgarden.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_philodendron",             {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_philodendron_placer", image = "reno_plantholder_philodendron.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_orchid",                   {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_orchid_placer", image = "reno_plantholder_orchid.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_draceana",                 {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_draceana_placer", image = "reno_plantholder_draceana.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_xerographica",             {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_xerographica_placer", image = "reno_plantholder_xerographica.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_birdcage",                 {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_birdcage_placer", image = "reno_plantholder_birdcage.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_palm",                     {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_palm_placer", image = "reno_plantholder_palm.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_zz",                       {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_zz_placer", image = "reno_plantholder_zz.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_fernstand",                {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_fernstand_placer", image = "reno_plantholder_fernstand.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_fern",                     {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_fern_placer", image = "reno_plantholder_fern.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_terrarium",                {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_terrarium_placer", image = "reno_plantholder_terrarium.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_plantpet",                 {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_plantpet_placer", image = "reno_plantholder_plantpet.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_traps",                    {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_traps_placer", image = "reno_plantholder_traps.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_pitchers",                 {Ingredient("oinc", 6)}, TECH.NONE,            {placer="deco_plantholder_pitchers_placer", image = "reno_plantholder_pitchers.tex"}, {"PLANT_HOLDERS"})

AddRecipe2("deco_plantholder_winterfeasttreeofsadness", {Ingredient("oinc", 2),Ingredient("twigs",1)}, TECH.NONE,{placer="deco_plantholder_winterfeasttreeofsadness_placer", image = "reno_plantholder_winterfeasttreeofsadness.tex"}, {"PLANT_HOLDERS"})
AddRecipe2("deco_plantholder_winterfeasttree",          {Ingredient("oinc", 50)},TECH.NONE,            {placer="deco_plantholder_winterfeasttree_placer", image = "reno_lamp_festivetree.tex"}, {"PLANT_HOLDERS"})

AddRecipe2("deco_table_round",                          {Ingredient("oinc", 2)}, TECH.NONE,            {placer="deco_table_round_placer", image = "reno_table_round.tex"}, {"TABLES"})
AddRecipe2("deco_table_banker",                         {Ingredient("oinc", 4)}, TECH.NONE,            {placer="deco_table_banker_placer", image = "reno_table_banker.tex"}, {"TABLES"})
AddRecipe2("deco_table_diy",                            {Ingredient("oinc", 3)}, TECH.NONE,            {placer="deco_table_diy_placer", image = "reno_table_diy.tex"}, {"TABLES"})
AddRecipe2("deco_table_raw",                            {Ingredient("oinc", 1)}, TECH.NONE,            {placer="deco_table_raw_placer", image = "reno_table_raw.tex"}, {"TABLES"})
AddRecipe2("deco_table_crate",                          {Ingredient("oinc", 1)}, TECH.NONE,            {placer="deco_table_crate_placer", image = "reno_table_crate.tex"}, {"TABLES"})
AddRecipe2("deco_table_chess",                          {Ingredient("oinc", 1)}, TECH.NONE,            {placer="deco_table_chess_placer", image = "reno_table_chess.tex"}, {"TABLES"})

AddRecipe2("deco_wallornament_photo",                   {Ingredient("oinc", 2)}, TECH.NONE,            {placer="deco_wallornament_photo_placer", image = "reno_wallornament_photo.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_fulllength_mirror",       {Ingredient("oinc", 10)},TECH.NONE,            {placer="deco_wallornament_fulllength_mirror_placer", image = "reno_wallornament_fulllength_mirror.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_embroidery_hoop",         {Ingredient("oinc", 3)}, TECH.NONE,            {placer="deco_wallornament_embroidery_hoop_placer", image = "reno_wallornament_embroidery_hoop.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_mosaic",                  {Ingredient("oinc", 4)}, TECH.NONE,            {placer="deco_wallornament_mosaic_placer", image = "reno_wallornament_mosaic.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_wreath",                  {Ingredient("oinc", 4)}, TECH.NONE,            {placer="deco_wallornament_wreath_placer", image = "reno_wallornament_wreath.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_axe",                     {Ingredient("oinc", 5)}, TECH.NONE,            {placer="deco_wallornament_axe_placer", image = "reno_wallornament_axe.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_hunt",                    {Ingredient("oinc", 5)}, TECH.NONE,            {placer="deco_wallornament_hunt_placer", image = "reno_wallornament_hunt.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_periodic_table",          {Ingredient("oinc", 5)}, TECH.NONE,            {placer="deco_wallornament_periodic_table_placer", image = "reno_wallornament_periodic_table.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_gears_art",               {Ingredient("oinc", 8)}, TECH.NONE,            {placer="deco_wallornament_gears_art_placer", image = "reno_wallornament_gears_art.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_cape",                    {Ingredient("oinc", 5)}, TECH.NONE,            {placer="deco_wallornament_cape_placer", image = "reno_wallornament_cape.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_no_smoking",              {Ingredient("oinc", 3)}, TECH.NONE,            {placer="deco_wallornament_no_smoking_placer", image = "reno_wallornament_no_smoking.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_wallornament_black_cat",               {Ingredient("oinc", 5)}, TECH.NONE,            {placer="deco_wallornament_black_cat_placer", image = "reno_wallornament_black_cat.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_antiquities_wallfish",                 {Ingredient("oinc", 2)}, TECH.NONE,            {placer="deco_antiquities_wallfish_placer", image = "reno_antiquities_wallfish.tex"}, {"ORNAMENTS"})
AddRecipe2("deco_antiquities_beefalo",                  {Ingredient("oinc", 10)},TECH.NONE,            {placer="deco_antiquities_beefalo_placer", image = "reno_antiquities_beefalo.tex"}, {"ORNAMENTS"})


--AddRecipe2("window_round_curtains_nails",               {Ingredient("boards", 2)},TECH.NONE,           {placer="window_round_curtains_nails_placer_placer", image = "reno_window_round_curtains_nails.tex"}, {"WINDOWS"})
AddRecipe2("window_small_peaked_curtain",               {Ingredient("oinc", 3)}, TECH.NONE,            {placer="window_small_peaked_curtain_placer", image = "reno_window_small_peaked_curtain.tex"}, {"WINDOWS"})
AddRecipe2("window_round_burlap",                       {Ingredient("oinc", 3)}, TECH.NONE,            {placer="window_round_burlap_placer", image = "reno_window_round_burlap.tex"}, {"WINDOWS"})
AddRecipe2("window_small_peaked",                       {Ingredient("oinc", 3)}, TECH.NONE,            {placer="window_small_peaked_placer", image = "reno_window_small_peaked.tex"}, {"WINDOWS"})
AddRecipe2("window_large_square",                       {Ingredient("oinc", 4)}, TECH.NONE,            {placer="window_large_square_placer", image = "reno_window_large_square.tex"}, {"WINDOWS"})
AddRecipe2("window_tall",                               {Ingredient("oinc", 4)}, TECH.NONE,            {placer="window_tall_placer", image = "reno_window_tall.tex"}, {"WINDOWS"})
AddRecipe2("window_large_square_curtain",               {Ingredient("oinc", 5)}, TECH.NONE,            {placer="window_large_square_curtain_placer", image = "reno_window_large_square_curtain.tex"}, {"WINDOWS"})
AddRecipe2("window_tall_curtain",                       {Ingredient("oinc", 5)}, TECH.NONE,            {placer="window_tall_curtain_placer", image = "reno_window_tall_curtain.tex"}, {"WINDOWS"})
AddRecipe2("window_greenhouse",                         {Ingredient("oinc", 8)}, TECH.NONE,            {placer="window_greenhouse_placer", image = "reno_window_greenhouse.tex"}, {"WINDOWS"})


AddRecipe2("deco_wood",                                 {Ingredient("oinc", 1)}, TECH.NONE,            {placer="deco_wood_cornerbeam_placer", image = "reno_cornerbeam_wood.tex"}, {"COLUMNS"})
AddRecipe2("deco_millinery",                            {Ingredient("oinc", 1)}, TECH.NONE,            {placer="deco_millinery_cornerbeam_placer", image = "reno_cornerbeam_millinery.tex"}, {"COLUMNS"})
AddRecipe2("deco_round",                                {Ingredient("oinc", 1)}, TECH.NONE,            {placer="deco_round_cornerbeam_placer", image = "reno_cornerbeam_round.tex"}, {"COLUMNS"})
AddRecipe2("deco_marble",                               {Ingredient("oinc", 5)}, TECH.NONE,            {placer="deco_marble_cornerbeam_placer", image = "reno_cornerbeam_marble.tex"}, {"COLUMNS"})

AddRecipe2("interior_floor_wood",                       {Ingredient("oinc", 5)}, TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_marble",                     {Ingredient("oinc", 15)},TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_check",                      {Ingredient("oinc", 7)}, TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_plaid_tile",                 {Ingredient("oinc", 10)},TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_sheet_metal",                {Ingredient("oinc", 6)}, TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_gardenstone",                {Ingredient("oinc", 10)},TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_geometrictiles",             {Ingredient("oinc", 12)},TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_shag_carpet",                {Ingredient("oinc", 6)}, TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_transitional",               {Ingredient("oinc", 6)}, TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_woodpanels",                 {Ingredient("oinc", 10)},TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_herringbone",                {Ingredient("oinc", 12)},TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_hexagon",                    {Ingredient("oinc", 12)},TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_hoof_curvy",                 {Ingredient("oinc", 12)},TECH.NONE,            {}, {"FLOORING"})
AddRecipe2("interior_floor_octagon",                    {Ingredient("oinc", 12)},TECH.NONE,            {}, {"FLOORING"})


AddRecipe2("interior_wall_wood",                        {Ingredient("oinc", 1)}, TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_checkered",                   {Ingredient("oinc", 6)}, TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_floral",                      {Ingredient("oinc", 6)}, TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_sunflower",                   {Ingredient("oinc", 6)}, TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_harlequin",                   {Ingredient("oinc", 10)},TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_peagawk",                     {Ingredient("oinc", 6)}, TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_plain_ds",                    {Ingredient("oinc", 4)}, TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_plain_rog",                   {Ingredient("oinc", 4)}, TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_rope",                        {Ingredient("oinc", 6)}, TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_circles",                     {Ingredient("oinc", 10)},TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_marble",                      {Ingredient("oinc", 15)},TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_mayorsoffice",                {Ingredient("oinc", 15)},TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_upholstered",                 {Ingredient("oinc", 15)},TECH.NONE,            {}, {"WALLPAPER"})
AddRecipe2("interior_wall_mayorsoffice",                {Ingredient("oinc", 8)}, TECH.NONE,            {}, {"WALLPAPER"})

AddRecipe2("swinging_light_basic_bulb",                 {Ingredient("oinc", 5)}, TECH.NONE,            {placer="swinging_light_basic_bulb_placer", image = "reno_light_basic_bulb.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_basic_metal",                {Ingredient("oinc", 6)}, TECH.NONE,            {placer="swinging_light_basic_metal_placer", image = "reno_light_basic_metal.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_chandalier_candles",         {Ingredient("oinc", 8)}, TECH.NONE,            {placer="swinging_light_chandalier_candles_placer", image = "reno_light_chandalier_candles.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_rope_1",                     {Ingredient("oinc", 1)}, TECH.NONE,            {placer="swinging_light_rope_1_placer", image = "reno_light_rope_1.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_rope_2",                     {Ingredient("oinc", 1)}, TECH.NONE,            {placer="swinging_light_rope_2_placer", image = "reno_light_rope_2.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_floral_bulb",                {Ingredient("oinc", 10)}, TECH.NONE,            {placer="swinging_light_floral_bulb_placer", image = "reno_light_floral_bulb.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_pendant_cherries",           {Ingredient("oinc", 12)}, TECH.NONE,            {placer="swinging_light_pendant_cherries_placer", image = "reno_light_pendant_cherries.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_floral_scallop",             {Ingredient("oinc", 12)}, TECH.NONE,            {placer="swinging_light_floral_scallop_placer", image = "reno_light_floral_scallop.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_floral_bloomer",             {Ingredient("oinc", 12)}, TECH.NONE,            {placer="swinging_light_floral_bloomer_placer", image = "reno_light_floral_bloomer.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_tophat",                     {Ingredient("oinc", 12)}, TECH.NONE,            {placer="swinging_light_tophat_placer", image = "reno_light_tophat.tex"}, {"HANGING_LAMPS"})
AddRecipe2("swinging_light_derby",                      {Ingredient("oinc", 12)}, TECH.NONE,            {placer="swinging_light_derby_placer", image = "reno_light_derby.tex"}, {"HANGING_LAMPS"})

AddRecipe2("wood_door",                                 {Ingredient("oinc", 10)}, TECH.NONE,            {placer="wood_door_placer", image = "wood_door.tex"}, {"DOORS"})
AddRecipe2("stone_door",                                {Ingredient("oinc", 10)}, TECH.NONE,            {placer="stone_door_placer", image = "stone_door.tex"}, {"DOORS"})
AddRecipe2("organic_door",                              {Ingredient("oinc", 15)}, TECH.NONE,            {placer="organic_door_placer", image = "organic_door.tex"}, {"DOORS"})
AddRecipe2("iron_door",                                 {Ingredient("oinc", 15)}, TECH.NONE,            {placer="iron_door_placer", image = "iron_door.tex"}, {"DOORS"})
AddRecipe2("curtain_door",                              {Ingredient("oinc", 15)}, TECH.NONE,            {placer="curtain_door_placer", image = "curtain_door.tex"}, {"DOORS"})
AddRecipe2("plate_door",                                {Ingredient("oinc", 15)}, TECH.NONE,            {placer="plate_door_placer", image = "plate_door.tex"}, {"DOORS"})
AddRecipe2("round_door",                                {Ingredient("oinc", 20)}, TECH.NONE,            {placer="round_door_placer", image = "round_door.tex"}, {"DOORS"})
AddRecipe2("pillar_door",                               {Ingredient("oinc", 20)}, TECH.NONE,            {placer="pillar_door_placer", image = "pillar_door.tex"}, {"DOORS"})

-- Recipe("disarming_kit", {Ingredient("iron", 2), Ingredient("cutreeds", 2)}, RECIPETABS.ARCHAEOLOGY, TECH.NONE, RECIPE_GAME_TYPE.PORKLAND)
-- Recipe("ballpein_hammer", {Ingredient("iron", 2), Ingredient("twigs", 1)}, RECIPETABS.ARCHAEOLOGY, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)
-- Recipe("goldpan", {Ingredient("iron", 2), Ingredient("hammer", 1)}, RECIPETABS.ARCHAEOLOGY, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)
-- Recipe("magnifying_glass", {Ingredient("iron", 1), Ingredient("twigs", 1), Ingredient("bluegem", 1)}, RECIPETABS.ARCHAEOLOGY, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)

-- --- CITY ---
-- Recipe("turf_foundation", {Ingredient("cutstone", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true)
-- Recipe("turf_cobbleroad", {Ingredient("cutstone", 2), Ingredient("boards", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true)
-- Recipe("city_lamp", {Ingredient("alloy", 1), Ingredient("transistor", 1),Ingredient("lantern",1)}, RECIPETABS.CITY,  TECH.CITY, cityRecipeGameTypes, "city_lamp_placer", nil, true)

-- Recipe("hedge_block_item", {Ingredient("clippings", 9), Ingredient("nitre", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true, 3)
-- Recipe("hedge_cone_item", {Ingredient("clippings", 9), Ingredient("nitre", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true, 3)
-- Recipe("hedge_layered_item", {Ingredient("clippings", 9), Ingredient("nitre", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true, 3)

-- Recipe("lawnornament_1", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_1_placer", 1, true)
-- Recipe("lawnornament_2", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_2_placer", 1, true)
-- Recipe("lawnornament_3", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_3_placer", 1, true)
-- Recipe("lawnornament_4", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_4_placer", 1, true)
-- Recipe("lawnornament_5", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_5_placer", 1, true)
-- Recipe("lawnornament_6", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_6_placer", 1, true)
-- Recipe("lawnornament_7", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_7_placer", 1, true)

-- --- HOME ---

-- Recipe("construction_permit", {Ingredient("oinc", 50)}, RECIPETABS.HOME, {atlas = interioraltas, image = "reno_table_chess.tex", placer = "deco_table_chess_placer"})
-- Recipe("demolition_permit", {Ingredient("oinc", 10)}, 	RECIPETABS.HOME, {atlas = interioraltas, image = "reno_table_chess.tex", placer = "deco_table_chess_placer"})

--[[
AddComponentPostInit("inventory", function(self)
	local _Has = self.Has
    function self:Has(item, amount, ...)
		if item == "oinc" then
			local money = self.inst.components.interiorshopper:CountCurrency()
			return money >= amount, money
		end
		return _Has(self, item, amount, ...)
	end
	
    function self:HasCurrencyType(item, amount, ...)
		return _Has(self, item, amount, ...)
	end
end)

AddComponentPostInit("builder", function(self)
	local _RemoveIngredients = self.RemoveIngredients
	function self:RemoveIngredients(ingredients, recname, ...)
		local recipe = AllRenoRecipes[recname]
		if recipe then
			for k,v in pairs(recipe.ingredients) do
				if v.amount > 0 and v.type == "oinc" then
					self.inst.components.interiorshopper:ConsumeCurrency(v.amount)
				end
			end
		end

		return _RemoveIngredients(self, ingredients, recname, ...)
    end
	
    function self:GetRenoIngredients(recname)
        local recipe = AllRenoRecipes[recname]
        if recipe then
            local ingredients = {}
            for k,v in pairs(recipe.ingredients) do
                if v.amount > 0 then
                    local amt = math.max(1, RoundBiasedUp(v.amount * self.ingredientmod))
                    local items = self.inst.components.inventory:GetItemByName(v.type, amt, true)
                    ingredients[v.type] = items
                end
            end
            return ingredients
        end
    end

	local _GetIngredients = self.GetIngredients
	function self:GetIngredients(recname, ...)
        if AllRenoRecipes[recname] then
            return self:GetRenoIngredients(recname, ...)
        end
		return _GetIngredients(self, recname, ...)
	end    

    self.inst:DoTaskInTime(0.1, function()
        for k, v in pairs(AllRenoRecipes) do
            if IsRecipeValid(v.name) then
                self.inst.replica.builder:SetIsBuildBuffered(v.name, false)
            end
        end
    end)
end)

--]]
