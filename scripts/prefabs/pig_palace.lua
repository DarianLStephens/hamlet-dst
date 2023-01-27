require "prefabutil"
require "recipes"

local assets =
{
    Asset("ANIM", "anim/palace.zip"),
    Asset("ANIM", "anim/pig_shop_doormats.zip"),
    Asset("ANIM", "anim/palace_door.zip"),
    Asset("ANIM", "anim/interior_wall_decals_palace.zip"),
    Asset("MINIMAP_IMAGE", "pig_palace"),
    Asset("MINIMAP_IMAGE", "pig_shop_florist"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs = 
{
    "trinket_giftshop_1",
    "trinket_giftshop_3",
    "trinket_giftshop_4",
    -- "grounded_wilba",
    "city_hammer",
}

local function LightsOn(inst)
    if not inst:HasTag("burnt") then
        inst.Light:Enable(true)
        inst.AnimState:PlayAnimation("lit", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
        inst.lightson = true
    end
end

local function LightsOff(inst)
    if not inst:HasTag("burnt") then
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
        inst.lightson = false
    end
end

local function onfar(inst) 
    if not inst:HasTag("burnt") then
        if inst.components.spawner and inst.components.spawner:IsOccupied() then
            LightsOn(inst)
        end
    end
end

local function getstatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.components.spawner and inst.components.spawner:IsOccupied() then
        if inst.lightson then
            return "FULL"
        else
            return "LIGHTSOUT"
        end
    end
end

local function onnear(inst) 
    if not inst:HasTag("burnt") then
        if inst.components.spawner and inst.components.spawner:IsOccupied() then
            LightsOff(inst)
        end
    end
end

local function onwere(child)
    if child.parent and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/werepig_in_hut", "pigsound")
    end
end

local function onnormal(child)
    if child.parent and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/city_pig/pig_in_house_LP", "pigsound")
    end
end

local function onoccupied(inst, child)
    if not inst:HasTag("burnt") then
    	inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/city_pig/pig_in_house_LP", "pigsound")
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
    	
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end

    	-- inst.doortask = inst:DoTaskInTime(1, function() if not inst.components.playerprox:IsPlayerClose() then LightsOn(inst) end end)
        inst.doortask = inst:DoTaskInTime(1, function() LightsOn(inst) end)

    	if child then
    	    inst:ListenForEvent("transformwere", onwere, child)
    	    inst:ListenForEvent("transformnormal", onnormal, child)
    	end
    end
end

local function onvacate(inst, child)
    if not inst:HasTag("burnt") then
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end

        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        inst.SoundEmitter:KillSound("pigsound")
    	
    	if child then
    	    inst:RemoveEventCallback("transformwere", onwere, child)
    	    inst:RemoveEventCallback("transformnormal", onnormal, child)

            if child.components.werebeast then
    		    child.components.werebeast:ResetTriggers()
    		end

    		if child.components.health then
    		    child.components.health:SetPercent(1)
    		end
    	end    
    end
end
        
        
local function onhammered(inst, worker)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end

    if inst.doortask then
        inst.doortask:Cancel()
        inst.doortask = nil
    end

	if inst.components.spawner then inst.components.spawner:ReleaseChild() end

	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function ongusthammerfn(inst)
    onhammered(inst, nil)
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
    	inst.AnimState:PlayAnimation("hit")
    	inst.AnimState:PushAnimation("idle")
    end
end

local function OnDay(inst)
    --print(inst, "OnDay")
    if not inst:HasTag("burnt") then
        if inst.components.spawner:IsOccupied() then
            LightsOff(inst)

            if inst.doortask then
                inst.doortask:Cancel()
                inst.doortask = nil
            end

            inst.doortask = inst:DoTaskInTime(1 + math.random()*2, function() inst.components.spawner:ReleaseChild() end)
        end
    end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end

    if inst:HasTag("spawned_shop") then
        data.spawned_shop = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end

    if data and data.spawned_shop then
        inst:AddTag("spawned_shop")
    end
end

local function creatInterior(inst, name)
    if not inst:HasTag("spawned_shop") then
        -- CREATE THE INTERIOR
        local interior_spawner = GetWorld().components.interiorspawner

        local palaceID = interior_spawner:GetNewID()
        local galleryID = interior_spawner:GetNewID()
        local giftshopID = interior_spawner:GetNewID()

        local depth = 18
        local width = 26        

        local exterior_door_def =
        {
            my_door_id = name..palaceID.."_door",
            target_door_id = name..palaceID.."_exit",
            target_interior = palaceID
        }

        interior_spawner:AddDoor(inst, exterior_door_def)

        local floortexture   = "levels/textures/interiors/floor_marble_royal.tex"
        local walltexture    = "levels/textures/interiors/wall_royal_high.tex"
        local minimaptexture = "levels/textures/map_interior/mini_floor_marble_royal.tex"

        -- local floortexture = "levels/textures/interiors/floor_cityhall.tex"
        -- local walltexture = "levels/textures/interiors/wall_mayorsoffice_whispy.tex"         

        local togallery_door_def =
        {
            my_door_id = "palace_courtroom_WEST",
            target_door_id = "palace_gallery_EAST",
            target_interior = galleryID,
        }

        local addprops = {}     
        addprops =
        {
            { name = "prop_door", x_offset = 9, z_offset = 0, animdata = {bank = "palace_door", build = "palace_door", anim = "south", background = false }, 
                my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, rotation = -90, addtags = {"guard_entrance"}, usesounds={"dontstarve_DLC003/common/objects/store/door_close"} },

            { name = "prop_door_shadow", x_offset = 9, z_offset = 0, animdata = {bank = "palace_door", build = "palace_door", anim = "south_floor"} },

            { name = "deco_roomglow_large", x_offset = 0, z_offset = 0 },
           

            { name = "prop_door", x_offset = 0, z_offset = -26/2, animdata = {bank = "wall_decals_palace", build = "interior_wall_decals_palace", anim = "door_sidewall", background = true }, 
                my_door_id = togallery_door_def.my_door_id, target_door_id = togallery_door_def.target_door_id, target_interior = togallery_door_def.target_interior, rotation = -90, flip = true, addtags = {"lockable_door","door_west"} },

            { name = "deco_palace_beam_room_tall_corner",       x_offset = -18/2, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall_corner",       x_offset = -18/2, z_offset =  26/2, rotation = 90 },      
            { name = "deco_palace_beam_room_tall_corner_front", x_offset =  18/2, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall_corner_front", x_offset =  18/2, z_offset =  26/2, rotation = 90 }, 

            { name = "deco_palace_beam_room_tall", x_offset = -18/2, z_offset = -26/6-1, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall", x_offset = -18/2, z_offset =  26/6+1, rotation = 90 }, 

            { name = "deco_palace_beam_room_tall_lights", x_offset = -18/6, z_offset = -26/6 -1, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall_lights", x_offset = -18/6, z_offset =  26/6 +1, rotation = 90 }, 

            { name = "deco_palace_beam_room_tall_lights", x_offset = 18/6, z_offset = -26/6 -1, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall_lights", x_offset = 18/6, z_offset =  26/6 +1, rotation = 90 }, 

            { name = "deco_palace_banner_big_front", x_offset = -18/6, z_offset = -26/3-0.5, rotation = 90 },
            { name = "deco_palace_banner_big_front", x_offset = -18/6, z_offset =  26/3+0.5, rotation = 90 }, 
            { name = "deco_palace_banner_big_front", x_offset =  18/6, z_offset = -26/3-0.5, rotation = 90 },
            { name = "deco_palace_banner_big_front", x_offset =  18/6, z_offset =  26/3+0.5, rotation = 90 }, 

            { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset = -26/18-3, rotation = 90 },
            { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset =  26/18+3, rotation = 90 }, 

            { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset = -26/18 - 26/3, rotation = 90 },
            { name = "deco_palace_banner_small_front", x_offset = -18/2, z_offset =  26/18 - 26/3, rotation = 90 },        

            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14, z_offset =  26/2, rotation = 90 },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14, z_offset =  26/2, rotation = 90 },

            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 3, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 3, z_offset =  26/2, rotation = 90 },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 3, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 3, z_offset =  26/2, rotation = 90 },

            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 5, z_offset =  -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset = -18/14 * 5, z_offset =   26/2, rotation = 90 },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 5, z_offset =  -26/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset =  18/14 * 5, z_offset =   26/2, rotation = 90 },

            { name = "deco_palace_beam_room_tall_corner", x_offset = -18/6, z_offset = -26/2, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall_corner", x_offset =  18/6, z_offset = -26/2, rotation = 90, flip = true }, 
            { name = "deco_palace_beam_room_tall_corner", x_offset = -18/6, z_offset =  26/2, rotation = 90 },
            { name = "deco_palace_beam_room_tall_corner", x_offset =  18/6, z_offset =  26/2, rotation = 90 }, 

            { name = "deco_palace_plant", x_offset = -18/2 +0.3, z_offset = -26/6.5, rotation = 90, flip = true },
            { name = "deco_palace_plant", x_offset = -18/2 +0.3, z_offset =  26/6.5, rotation = 90 },

            { name = "wall_mirror", x_offset =  18/3, z_offset = -26/2, rotation = -90 }, 
            { name = "wall_mirror", x_offset = -18/3, z_offset = -26/2, rotation = -90 }, 

            -- { name = "wall_mirror", x_offset =  18/3, z_offset = 26/2, rotation = 90, flip=true },  
            -- { name = "wall_mirror", x_offset = -18/3, z_offset = 26/2, rotation = 90, flip=true },  
            
            { name = "deco_cityhall_picture1", x_offset =  18/3, z_offset = 26/2, rotation = 90 },
            { name = "deco_cityhall_picture2", x_offset =  -0.5, z_offset = 26/2, rotation = 90 },
            { name = "deco_cityhall_picture1", x_offset =  -18/3, z_offset = 26/2, rotation = 90 },

            { name = "pigman_queen",       x_offset = -3, z_offset = 0 },
            { name = "deco_palace_throne", x_offset = -6, z_offset = 0, rotation = 90 },                 

            -- floor corner pieces
            { name = "rug_palace_corners", x_offset = -18/2, z_offset =  26/2, rotation = 90  },
            { name = "rug_palace_corners", x_offset =  18/2, z_offset =  26/2, rotation = 180 },
            { name = "rug_palace_corners", x_offset =  18/2, z_offset = -26/2, rotation = 270 },
            { name = "rug_palace_corners", x_offset = -18/2, z_offset = -26/2, rotation = 0   },

            -- front wall floor lights
            { name = "swinglightobject", x_offset = 18/2, z_offset = -26/3, rotation = -90 }, 
            { name = "swinglightobject", x_offset = 18/2, z_offset =  26/3, rotation = -90 }, 

            -- back wall lights and floor lights
            { name = "window_round_light_backwall", x_offset = -18/2, z_offset = -26/3, rotation = -90 }, 
            { name = "window_palace",               x_offset = -18/2, z_offset = -26/3, rotation =  90 },
            { name = "window_round_light_backwall", x_offset = -18/2, z_offset =  26/3, rotation = -90 }, 
            { name = "window_palace",               x_offset = -18/2, z_offset =  26/3, rotation =  90 }, 
            { name = "window_round_light_backwall", x_offset = -18/2, z_offset =     0, rotation = -90 }, 
            { name = "window_palace_stainglass",    x_offset = -18/2, z_offset =     0, rotation =  90 }, 

            -- aisle rug
            { name = "rug_palace_runner", x_offset =   -3.38, z_offset = 0, rotation = 90 },
            { name = "rug_palace_runner", x_offset = -3.38*2, z_offset = 0, rotation = 90 },
            { name = "rug_palace_runner", x_offset =       0, z_offset = 0, rotation = 90 },
            { name = "rug_palace_runner", x_offset =    3.38, z_offset = 0, rotation = 90 },
            { name = "rug_palace_runner", x_offset =  3.38*2, z_offset = 0, rotation = 90 },
        } 

        local cityID = nil
        if inst.components.citypossession then
            cityID = inst.components.citypossession.cityID
        end

        interior_spawner:CreateRoom("generic_interior", width, 13, depth, name, palaceID, addprops, {}, walltexture, floortexture, minimaptexture, cityID, "images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "palace", "PALACE","STONE")


        -- CREATE GALLERY

        depth = 12
        width = 18       

        local togiftshop_door_def =
        {
            my_door_id = "palace_gallery_WEST",
            target_door_id = "palace_giftshop_EAST",
            target_interior = giftshopID,
        }

        local topalace_door_def =
        {
            my_door_id = "palace_gallery_EAST",
            target_door_id = "palace_courtroom_WEST",
            target_interior = palaceID,
        }

        floortexture   = "levels/textures/interiors/floor_marble_royal.tex"
        walltexture    = "levels/textures/interiors/wall_royal_high.tex"
        minimaptexture = "levels/textures/map_interior/mini_floor_marble_royal.tex"
        
        addprops = {}     
        addprops =
        {
            { name = "deco_roomglow", x_offset = 0, z_offset = 0 },               

            { name = "prop_door", x_offset =0, z_offset = -18/2, animdata = {bank = "wall_decals_palace", build = "interior_wall_decals_palace", anim = "door_sidewall", background = true }, 
                my_door_id = togiftshop_door_def.my_door_id, target_door_id = togiftshop_door_def.target_door_id, target_interior = togiftshop_door_def.target_interior, rotation = -90, flip = true, addtags = {"lockable_door", "door_west"} },

            { name = "prop_door", x_offset =0, z_offset = 18/2, animdata = {bank = "wall_decals_palace", build = "interior_wall_decals_palace", anim = "door_sidewall", background = true }, 
                my_door_id = topalace_door_def.my_door_id, target_door_id =topalace_door_def.target_door_id, target_interior = topalace_door_def.target_interior, rotation = 90, addtags = {"lockable_door", "door_east"} },

            { name = "rug_palace_corners", x_offset = -12/2, z_offset =  18/2, rotation = 90  },
            { name = "rug_palace_corners", x_offset =  12/2, z_offset =  18/2, rotation = 180 },
            { name = "rug_palace_corners", x_offset =  12/2, z_offset = -18/2, rotation = 270 },
            { name = "rug_palace_corners", x_offset = -12/2, z_offset = -18/2, rotation = 0   },

            { name = "window_round_light_backwall", x_offset = -12/2, z_offset = -18/3, rotation = -90 }, 
            { name = "window_palace",               x_offset = -12/2, z_offset = -18/3, rotation =  90 },
            { name = "window_round_light_backwall", x_offset = -18/2, z_offset =  26/3, rotation = -90 }, 
            { name = "window_palace",               x_offset = -12/2, z_offset =  18/3, rotation =  90 }, 

            { name = "deco_palace_beam_room_tall_corner",       x_offset = -12/2, z_offset =  -18/2, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall_corner",       x_offset = -12/2, z_offset =   18/2, rotation = 90 },      
            { name = "deco_palace_beam_room_tall_corner_front", x_offset =  12/2, z_offset =  -18/2, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall_corner_front", x_offset =  12/2, z_offset =   18/2, rotation = 90 }, 

            { name = "deco_palace_beam_room_tall", x_offset = -12/6, z_offset =  -18/6, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall", x_offset = -12/6, z_offset =  18/6, rotation = 90 },

            { name = "deco_palace_beam_room_tall", x_offset = 12/6, z_offset =  -18/6, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_tall", x_offset = 12/6, z_offset =  18/6, rotation = 90 },                 


            { name = "shelves_queen_display_1", x_offset = -12/4, z_offset =  -18/3, rotation = 90, shelfitems={{1,"key_to_city"}} },
            { name = "shelves_queen_display_2", x_offset =     0, z_offset =      0, rotation = 90, shelfitems={{1,"trinket_giftshop_4"}} },
            { name = "shelves_queen_display_3", x_offset = -12/4, z_offset =   18/3, rotation = 90, flip = true, shelfitems={{1,"city_hammer"}} },
            --{ name = "shelves_queen_display_1", x_offset =  12/4, z_offset =  -18/3, rotation = 90, flip = true, shelfitems={{1,"trinket_giftshop_3"}} },
            --{ name = "shelves_queen_display_4", x_offset =  12/4, z_offset =   18/3, rotation = 90, flip = true, shelfitems={{1,"trinket_giftshop_3"}} },
           
           -- { name = "shop_buyer", x_offset = -12/4, z_offset =  -18/3,  saveID = true, startAnim = "lock19_east" },
           -- { name = "shop_buyer", x_offset =     0, z_offset =      0,  saveID = true, startAnim = "lock17_east" },
           -- { name = "shop_buyer", x_offset = -12/4, z_offset =   18/3,  saveID = true, startAnim = "lock12_west" },
           -- { name = "shop_buyer", x_offset =  12/4, z_offset =  -18/3,  saveID = true, startAnim = "lock19_east" },
           -- { name = "shop_buyer", x_offset =  12/4, z_offset =   18/3,  saveID = true, startAnim = "lock12_west" },

            { name = "deco_palace_banner_small_sidewall", x_offset = -12/14 * 3, z_offset =  -18/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset = -12/14 * 3, z_offset =   18/2, rotation = 90 },
            { name = "deco_palace_banner_small_sidewall", x_offset =  12/14 * 3, z_offset =  -18/2, rotation = 90, flip = true },
            { name = "deco_palace_banner_small_sidewall", x_offset =  12/14 * 3, z_offset =   18/2, rotation = 90 },

            { name = "shelves_marble", x_offset = -12/2, z_offset = 0, shelfitems={{5,"trinket_20"},{6,"trinket_14"},{3,"trinket_4"},{4,"trinket_2"}}  },
        } 

        interior_spawner:CreateRoom("generic_interior", width, 12, depth, name, galleryID, addprops, {}, walltexture, floortexture, minimaptexture, cityID ,"images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "palace", "PALACE","STONE")


        -- CREATE GIFT SHOP

        depth = 10
        width = 15        

        local togallery_door_def =
        {
            my_door_id = "palace_giftshop_EAST",
            target_door_id = "palace_gallery_WEST",
            target_interior = galleryID,
        }

        local toexit_door_def =
        {
            my_door_id = "palace_giftshop_SOUTH",
            target_door_id = exterior_door_def.my_door_id,
        }

        floortexture   = "levels/textures/interiors/floor_marble_royal.tex"
        walltexture    = "levels/textures/interiors/wall_royal_high.tex"
        minimaptexture = "levels/textures/map_interior/mini_floor_marble_royal.tex"

        addprops = {}     
        addprops =
        {
            { name = "deco_roomglow", x_offset = 0, z_offset = 0 },               

            { name = "prop_door", x_offset = 10/2, z_offset = 0, animdata = {bank = "pig_shop_doormats", build = "pig_shop_doormats", anim = "idle_giftshop", background = true }, 
                my_door_id = toexit_door_def.my_door_id, target_door_id = toexit_door_def.target_door_id, rotation = -90, addtags = {"guard_entrance"}, usesounds={"dontstarve_DLC003/common/objects/store/door_close"} },

            { name = "prop_door", x_offset = 0, z_offset = 15/2, animdata = {bank = "wall_decals_palace", build = "interior_wall_decals_palace", anim = "door_sidewall", background = true }, 
                my_door_id = togallery_door_def.my_door_id, target_door_id =togallery_door_def.target_door_id, target_interior = togallery_door_def.target_interior, rotation = 90, addtags = {"lockable_door", "door_east"} },

            { name = "rug_palace_corners", x_offset = -10/2, z_offset =  15/2, rotation = 90  },
            { name = "rug_palace_corners", x_offset =  10/2, z_offset =  15/2, rotation = 180 },
            { name = "rug_palace_corners", x_offset =  10/2, z_offset = -15/2, rotation = 270 },
            { name = "rug_palace_corners", x_offset = -10/2, z_offset = -15/2, rotation = 0   },

            { name = "deco_palace_beam_room_short_corner_lights",       x_offset = -10/2, z_offset =  -15/2, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_short_corner_lights",       x_offset = -10/2, z_offset =   15/2, rotation = 90 },      
            { name = "deco_palace_beam_room_short_corner_front_lights", x_offset =  10/2, z_offset =  -15/2, rotation = 90, flip = true },
            { name = "deco_palace_beam_room_short_corner_front_lights", x_offset =  10/2, z_offset =   15/2, rotation = 90 },  

            { name = "deco_cityhall_picture2", x_offset = -10/5, z_offset = -15/2, rotation = 90, flip = true },
            { name = "deco_cityhall_picture1", x_offset =  10/5, z_offset = -15/2, rotation = 90, flip = true },

            { name = "shelves_wood", x_offset = -10/2, z_offset = -15/5, rotation =- 90, shelfitems={{1,"trinket_giftshop_3"},{2,"trinket_giftshop_3"},{3,"trinket_giftshop_3"},{5,"trinket_giftshop_3"},{6,"trinket_giftshop_3"}} },
            { name = "shelves_wood", x_offset = -10/2, z_offset =  15/5, rotation =- 90, shelfitems={{1,"trinket_giftshop_3"},{3,"trinket_giftshop_3"},{4,"trinket_giftshop_3"},{5,"trinket_giftshop_3"},{6,"trinket_giftshop_3"}} },

            { name = "swinging_light_floral_bloomer", x_offset = 0, z_offset = 0 },

            { name = "shelves_displaycase", x_offset = -10/5, z_offset = -15/3, rotation = 90, flip = true, shelfitems={{1,"trinket_giftshop_1"},{2,"trinket_giftshop_1"},{3,"trinket_giftshop_1"}} },
            { name = "shelves_displaycase", x_offset =  10/5, z_offset =  15/3, rotation = 90,              shelfitems={{1,"trinket_giftshop_1"},{3,"trinket_giftshop_1"}} },
            { name = "shelves_displaycase", x_offset =  10/5, z_offset = -15/3, rotation = 90, flip = true, shelfitems={{2,"trinket_giftshop_1"},{3,"trinket_giftshop_1"}} },
            { name = "shelves_displaycase", x_offset = -10/5, z_offset =  15/3, rotation = 90,              shelfitems={{1,"trinket_giftshop_1"},{2,"trinket_giftshop_1"}} },
        }

        -- if not Profile:IsCharacterUnlocked("wilba") then
            -- table.insert(addprops, { name = "grounded_wilba", x_offset = 0, z_offset = 0 })
        -- end

        interior_spawner:CreateRoom("generic_interior", width, 11, depth, name, giftshopID, addprops, {}, walltexture, floortexture, minimaptexture, cityID ,"images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "palace", "PALACE","STONE")

        inst.interiorID = palaceID
        inst:AddTag("spawned_shop")
    end
end

local function usedoor(inst,data)
    if inst.usesounds then
        if data and data.doer and data.doer.SoundEmitter then
            for i,sound in ipairs(inst.usesounds)do
                data.doer.SoundEmitter:PlaySound(sound)
            end
        end
    end
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local light = inst.entity:AddLight()
    inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "pig_palace.png" )

    light:SetFalloff(1)
    light:SetIntensity(.5)
    light:SetRadius(1)
    light:Enable(false)
    light:SetColour(180/255, 195/255, 50/255)
    
    MakeObstaclePhysics(inst, 1.25)

    anim:SetBank("palace")

    anim:SetBuild("palace")

    anim:PlayAnimation("idle", true)


    inst:AddTag("structure")

    inst:AddComponent("door")

	inst:AddComponent("spawner")
    inst.components.spawner:Configure("pigman_banker", TUNING.TOTAL_DAY_TIME*4)
    inst.components.spawner.onoccupied = onoccupied
    inst.components.spawner.onvacate = onvacate
    inst:ListenForEvent( "daytime", function() OnDay(inst) end, GetWorld())    
   
    inst:AddComponent("inspectable")    
	
    inst.components.inspectable.getstatus = getstatus
	
	MakeSnowCovered(inst, .01)

    inst:ListenForEvent("burntup", function(inst)
        inst.components.fixable:AddRecinstructionStageData("burnt", "pig_shop", "palace", 1)
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
        inst:Remove()
    end)

    inst:ListenForEvent("onignite", function(inst, data)
        if inst.components.spawner then
            inst.components.spawner:ReleaseChild()
        end
    end)

    inst.OnSave = onsave 
    inst.OnLoad = onload

	inst:ListenForEvent( "onbuilt", onbuilt)
    inst:DoTaskInTime(math.random(), function() 
        if GetClock():IsDay() then 
            OnDay(inst)
        end 
    end)

    inst:DoTaskInTime(0, function() 
        creatInterior(inst, "pig_palace")
    end)

    inst.usesounds = {"dontstarve_DLC003/common/objects/store/door_open"}
    inst:ListenForEvent("usedoor", function(inst,data) usedoor(inst,data) end)  

    return inst
end

return Prefab("common/objects/pig_palace", fn, assets, prefabs)

