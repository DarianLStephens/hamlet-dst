require "prefabutil"
require "recipes"

local assets =
{
    Asset("ANIM", "anim/pig_shop.zip"),    
    Asset("ANIM", "anim/pig_shop_florist.zip"),
    Asset("ANIM", "anim/pig_shop_hoofspa.zip"),
    Asset("ANIM", "anim/pig_shop_produce.zip"),
    Asset("ANIM", "anim/pig_shop_general.zip"),
    Asset("ANIM", "anim/pig_shop_deli.zip"),    
    Asset("ANIM", "anim/pig_shop_antiquities.zip"),       

    Asset("ANIM", "anim/flag_post_duster_build.zip"),    
    Asset("ANIM", "anim/flag_post_wilson_build.zip"),    

    Asset("ANIM", "anim/pig_cityhall.zip"),      
    Asset("ANIM", "anim/pig_shop_arcane.zip"),
    Asset("ANIM", "anim/pig_shop_weapons.zip"),
    Asset("ANIM", "anim/pig_shop_accademia.zip"),
    Asset("ANIM", "anim/pig_shop_millinery.zip"),
    Asset("ANIM", "anim/pig_shop_bank.zip"),   
    Asset("ANIM", "anim/pig_shop_tinker.zip"),  

    Asset("IMAGE", "images/colour_cubes/pigshop_interior_cc.tex"),
        
    Asset("MINIMAP_IMAGE", "pig_shop_florist"),
    Asset("MINIMAP_IMAGE", "pig_shop_general"),
    Asset("MINIMAP_IMAGE", "pig_shop_hoofspa"),
    Asset("MINIMAP_IMAGE", "pig_shop_produce"),

    Asset("MINIMAP_IMAGE", "pig_shop_deli"),
    Asset("MINIMAP_IMAGE", "pig_shop_antiquities"),
    Asset("MINIMAP_IMAGE", "pig_shop_cityhall"),   

    Asset("MINIMAP_IMAGE", "pig_shop_academy"),
    Asset("MINIMAP_IMAGE", "pig_shop_arcane"),
    Asset("MINIMAP_IMAGE", "pig_shop_hatshop"),
    Asset("MINIMAP_IMAGE", "pig_shop_weapons"),
    Asset("MINIMAP_IMAGE", "pig_shop_bank"),  
    Asset("MINIMAP_IMAGE", "pig_shop_tinker"),

    Asset("INV_IMAGE", "pig_shop_antiquities"),
    Asset("INV_IMAGE", "pig_shop_arcane"),
    Asset("INV_IMAGE", "pig_shop_deli"),
    Asset("INV_IMAGE", "pig_shop_florist"),
    Asset("INV_IMAGE", "pig_shop_general"),
    Asset("INV_IMAGE", "pig_shop_hoofspa"),
    Asset("INV_IMAGE", "pig_shop_hatshop"),
    Asset("INV_IMAGE", "pig_shop_produce"),
    Asset("INV_IMAGE", "pig_shop_weapons"),  
    Asset("INV_IMAGE", "pig_shop_bank"),
    Asset("INV_IMAGE", "pig_shop_tinker"),
    Asset("INV_IMAGE", "pig_shop_cityhall_player"),        

    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs = 
{
    "pigman_collector",
    "pigman_banker",
    "pigman_beautician",
    "pigman_florist",
    "pigman_erudite",
    "pigman_professor",
    "pigman_hunter",
    "pigman_hatmaker_shopkeep",
    "pigman_mayor",
    "pigman_mechanic",
    "pigman_storeowner",

    "window_round",
  --  "window_sunlight",
    "deco_wallpaper_rip1",
    "deco_wallpaper_rip2",
    "deco_wallpaper_rip_side1",
    "deco_wallpaper_rip_side2",
    "deco_wallpaper_rip_side3",
    "deco_wallpaper_rip_side4",
    "deco_wood_beam",
    "deco_wood_cornerbeam",
    "wall_light1",
    "swinging_light1",
    "swinging_light_floral_bloomer",
    "swinging_light_basic_metal",
    "swinging_light_chandalier_candles",
    "swinging_light_rope_1",
    "swinging_light_rope_2",
    "swinging_light_floral_bulb",
    "swinging_light_pendant_cherries",
    "swinging_light_floral_scallop",
    "swinglightobject",
    "deco_roomglow",
    "light_dust_fx",
    "rug_round",
    "rug_oval",
    "rug_square",
    "rug_rectangle",
    "rug_leather",
    "rug_fur",

    "shelves_wood",    
    "shelves_marble",
    "shelves_glass",

    "deco_marble_cornerbeam",
    "deco_marble_beam",
    "deco_valence",
    "wall_light_hoofspa",
    "wall_light_hoofspa_backwall",

    "wall_mirror",

    "deco_chaise",
    "deco_lamp_hoofspa",

    "deed",
    "construction_permit",
    "demolition_permit",
    "securitycontract",
}

local SHOPSOUND_ENTER1 = "dontstarve_DLC003/objects/store/door_open"
local SHOPSOUND_ENTER2 = "dontstarve_DLC003/objects/store/door_entrance"
local SHOPSOUND_EXIT = "dontstarve_DLC003/objects/store/door_close"

local spawnprefabs =
{
    "pig_shop_florist",
    "pig_shop_general",
    "pig_shop_hoofspa",
    "pig_shop_produce",    
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
        -- inst.SoundEmitter:PlaySound("dontstarve/pighouse_door")
        
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
        --inst.doortask = inst:DoTaskInTime(1, function() if not inst.components.playerprox:IsPlayerClose() then LightsOn(inst) end end)
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
        -- inst.SoundEmitter:PlaySound("dontstarve/pighouse_door")
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

    if not inst.components.fixable then
        inst.components.lootdropper:DropLoot()
    end    

    SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/destroy_wood")
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
    if not inst:HasTag("burnt") then
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
        inst.doortask = inst:DoTaskInTime(1, function() LightsOn(inst) end)    
    end
end

local function OnDusk(inst)
    --print(inst, "OnDay")
    if not inst:HasTag("burnt") then       
        LightsOff(inst)
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end            
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/crafted/pighouse/wood_1")
    inst.AnimState:PushAnimation("idle")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") then
        data.burnt = true
    end
    if inst:HasTag("fire") then
        -- if the player is inside we gotta keep burning
        local interior_spawner = GetWorld().components.interiorspawner
        if not interior_spawner:IsPlayerConsideredInside(inst.interiorID) then
            data.burnt = true
        else
            data.burning = true
        end 
    end

    if inst:HasTag("spawned_shop") then
        data.spawned_shop = true
    end

    if inst.interiorID then
        data.interiorID = inst.interiorID
    end
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end

    if data and data.burning == true then
        inst:DoTaskInTime(0, function() inst.components.burnable:Ignite(true) end)
    end

    if data and data.spawned_shop then
        inst:AddTag("spawned_shop")
    end

    if data and data.interiorID then
        inst.interiorID = data.interiorID

        -- Checks if the cityhall has the construction_permit for sale, and if it doesn't, it patches it in
        if inst.prefab == "pig_shop_cityhall" then
            inst:DoTaskInTime(0, function()
                
                local patched = false
                local interior_ents = {}

                local interior_spawner = TheWorld.components.interiorspawner
                local interior = interior_spawner:GetInteriorByName(inst.interiorID)
                local inside_interior = interior == interior_spawner.current_interior
                local pt = interior_spawner:GetSpawnOrigin()
                
                -- Gets the interior entities wether the interior has been visited or not
                local function GetInteriorEnts()
                    if inside_interior then
                        return TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO", "INLIMBO"})
                    else
                        return interior.object_list
                    end
                end

                interior_ents = GetInteriorEnts()

                -- Checks if we have 3 pedestals, if we do, cancel the patching
                local buyer_count = 0
                for _, ent in pairs(interior_ents) do
                    if ent.prefab == "shop_buyer" then
                        buyer_count = buyer_count + 1
                        if buyer_count >= 4 then
                            patched = true
                            break
                        end
                    end
                end

                -- x_offset = 1.75,   z_offset =  width/2-5

                if not patched then

                    local saleitems =
                    {
                        {"construction_permit", "oinc", 50 },
                        {"demolition_permit",   "oinc", 10 },
                    }

                    local offsets =
                    {
                        { x_offset = 3.5, z_offset =  TUNING.ROOM_TINY_WIDTH/2-2 },
                        { x_offset = -1,  z_offset =  TUNING.ROOM_TINY_WIDTH/2-2 },
                    }

                    local startAnim = "idle_globe_bar"

                    if interior.visited then
                        for _, ent in pairs(interior_ents) do
                            if ent.prefab == "shop_buyer" and ent.components.shopdispenser.item_served == "deed" then
                                local x,y,z = ent.Transform:GetWorldPosition()
                                ent.Transform:SetPosition(x + 1.75, y, z -2)
                                c_select(ent)
                                break
                            end
                        end
                    else
                        for _, prefab in ipairs(interior.prefabs) do
                            if prefab.name == "shop_buyer" and prefab.saleitem[1] == "deed" then
                                prefab.x_offset = 1.75
                                prefab.z_offset = TUNING.ROOM_TINY_WIDTH/2-5
                            end
                        end
                    end

                    for i=1,#saleitems do
                        local offset = offsets[i]
                        local saleitem = saleitems[i]
                        local prefab_data = {saleitem = saleitem, startAnim = startAnim }

                        -- If the interior has been visited we have to spawn the prefab, initialize it and put it in the interior
                        if interior.visited then
                            local pedestal = SpawnPrefab("shop_buyer")
                            -- Sets position, item and animation
                            pedestal.Transform:SetPosition(pt.x + offset.x_offset, 0, pt.z + offset.z_offset) -- HERE
                            pedestal.saleitem = saleitem -- HERE
                            pedestal.AnimState:PlayAnimation(startAnim)
                            pedestal.startAnim = startAnim

                            -- Shop spawner contains a bunch of info about the store itself, so we need it to initialize our pedestals
                            local shop_spawner = nil
                            for _, ent in pairs(interior_ents) do
                                if ent.prefab == "shop_spawner" then
                                    shop_spawner = ent
                                    break
                                end
                            end

                            -- This shouldn't happen
                            if not shop_spawner then
                                print ("ERROR: COULD NOT FIND SHOP SPAWNER")
                            else -- Sets the proper products and what not
                                local product = shop_spawner.components.shopinterior:GetNewProduct("pig_shop_cityhall")

                                pedestal.components.shopped:SetShop(shop_spawner, "pig_shop_cityhall")
                                pedestal:AddTag("pig_shop_item")
                                pedestal:SpawnInventory(saleitem[1], saleitem[2], saleitem[3]) -- HERE

                                -- If we're not currently in the interior, put the pedestal in limbo
                                if interior ~= interior_spawner.current_interior then
                                    interior_spawner:PutPropIntoInteriorLimbo(pedestal, interior)
                                end
                            end
                        else -- If the interior hasn't been visited, just insert the prefab. Easy.
                            interior_spawner:insertprefab(interior, "shop_buyer", offset, prefab_data) -- HERE
                        end
                    end
                end
            end)
        end
    end    
end

local function spawn_shop(inst)  
   -- print("CHECKING",inst.cancelspawn,inst.forcespawn)

    if not inst.cancelspawn then
        if inst.forcespawn then
            local spawn = inst.forcespawn

            local pt = Vector3(inst.Transform:GetWorldPosition())
           -- local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 3, {"structure"})
            if spawn then -- and  #ents == 0 
                --print("SPAWNING",spawn)
                local shop = SpawnPrefab(spawn)                
                shop.Transform:SetPosition(inst.Transform:GetWorldPosition())
                if not shop.components.citypossession then
                    shop:AddComponent("citypossession")
                end
                shop.components.citypossession.cityID = inst.components.citypossession.cityID                 
            end                    
        else

            local nilwieght = inst.nilwieght or 6

            local spawn_list = 
            {
                {"pig_shop_florist",1},
                {"pig_shop_general",1},
                {"pig_shop_hoofspa",1},
                {"pig_shop_produce",1},
                {"pig_guard_tower",1},        
                {"pighouse_city",4},
                {nil,nilwieght},
            }

            local total = 0

            for i = 1, #spawn_list do
                total = total + spawn_list[i][2]
            end

            local choice = math.random(0,total)
            total = 0
            for i = 1, #spawn_list do
                total = total + spawn_list[i][2]
                if choice <= total then
                    local spawn = spawn_list[i][1]
                    local pt = Vector3(inst.Transform:GetWorldPosition())
                    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 3, {"structure"})

                    if spawn and  #ents == 0 then
                        local shop = SpawnPrefab(spawn)
                        shop.Transform:SetPosition(inst.Transform:GetWorldPosition())                                                      
                        if not shop.components.citypossession then
                            shop:AddComponent("citypossession")
                        end
                        if  inst.components.citypossession and inst.components.citypossession.cityID then
                            shop.components.citypossession.cityID = inst.components.citypossession.cityID                                                                             
                        end
                    end
                    break
                end
            end
        end
    end
    inst:Remove()
end

local function makespawnerfn(Sim)
    print("SPAWNER SPAWNING")

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    trans:SetEightFaced()

    MakeObstaclePhysics(inst, 1)
    anim:SetBank("pig_shop")
    anim:PlayAnimation("idle",true)
    
    inst:AddTag("pig_shop_spawner")

    inst:DoTaskInTime(0, function() print("KILLING A SHOP SPAWNER") inst:Remove() end ) -- spawn_shop(inst)

    return inst    
end

local function creatInterior(inst, name)
    if not inst:HasTag("spawned_shop") then
        -- CREATE THE INTERIOR
        local interior_spawner = GetWorld().components.interiorspawner

        local ID = inst.interiorID

        if not ID then
            ID = interior_spawner:GetNewID()          
        end

        local exterior_door_def = {
            my_door_id = name..ID.."_door",
            target_door_id = name..ID.."_exit",
            target_interior = ID
        }
        interior_spawner:AddDoor(inst, exterior_door_def)

        local ambsnd = "STORE"
        
        if not inst.interiorID then

            local floortexture = "levels/textures/ground_noise_checkeredlawn.tex"
            local walltexture = "levels/textures/ground_noise_checkeredlawn.tex"
            local minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"

            local addprops = {}

            local width = TUNING.ROOM_TINY_WIDTH
            local depth = TUNING.ROOM_TINY_DEPTH
            local height = nil

            if inst:HasTag("pig_shop_academy") then
                
                floortexture   = "levels/textures/interiors/shop_floor_hexagon.tex"
                walltexture    = "levels/textures/interiors/shop_wall_circles.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"

                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_giftshop", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },

                    { name = "musac",                       x_offset =  0,   z_offset = 0 }, 
                    { name = "deco_roomglow",               x_offset =  0,   z_offset = 0 }, 
                    { name = "shop_spawner",                x_offset = -3,   z_offset = 0,  shop_type = name },
                    { name = "pigman_professor_shopkeep",   x_offset = -2.3, z_offset = 4,  startstate = "desk_pre" },
                    { name = "shelves_midcentury",          x_offset = -4.5, z_offset = -3.3, shelfitems={{1,"trinket_1"},{5,"trinket_2"},{6,"trinket_3"}} },

                    { name = "deco_accademy_beam",          x_offset = -5,  z_offset = width/2, flip=true },
                    { name = "deco_accademy_beam",          x_offset = -5,  z_offset = -width/2 },
                    { name = "deco_accademy_cornerbeam",    x_offset = 4.7, z_offset = width/2, flip=true },
                    { name = "deco_accademy_cornerbeam",    x_offset = 4.7, z_offset = -width/2 },

                    { name = "swinging_light_floral_bulb",          x_offset = -3,  z_offset =  -0 },                    
        
                    { name = "deco_cityhall_picture1",  x_offset = 0, z_offset =  width/2, flip=true },
                    { name = "deco_cityhall_picture2",  x_offset = 0, z_offset = -width/2 },

                    { name = "deco_accademy_pig_king_painting",  x_offset = -5, z_offset =  3, flip=true },

                     { name = "deco_accademy_barrier_vert",  x_offset =  2,  z_offset =  -5.5 },
                     { name = "deco_accademy_vause",         x_offset =  2,  z_offset =  -6.5 },                                             
                     { name = "deco_accademy_barrier_vert",  x_offset = -2,  z_offset =  -5.5 },
                     { name = "deco_accademy_graniteblock",  x_offset = -2,  z_offset =  -6.5 },

                     { name = "deco_accademy_table_books",  x_offset = 0,   z_offset =  -3 },

                     { name = "deco_accademy_potterywheel_urn",  x_offset = -3.5,   z_offset =  0 },
                     { name = "deco_accademy_barrier",           x_offset = -2.5,   z_offset =  0 },         

                    { name = "shop_buyer", x_offset = 1, z_offset =  0.5, saleitem={"oinc10","relic_1",1},   startAnim="idle_stoneslab"},
                    { name = "shop_buyer", x_offset = 1.5, z_offset =  3, saleitem={"oinc10","relic_2",1},   startAnim="idle_stoneslab"},
                    { name = "shop_buyer", x_offset = 2, z_offset =  5.5, saleitem={"oinc10","relic_3",1},   startAnim="idle_stoneslab"},                            
                }

            elseif inst:HasTag("pig_shop_antiquities") then
                
                floortexture   = "levels/textures/interiors/noise_woodfloor.tex"
                walltexture    = "levels/textures/interiors/harlequin_panel.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_antiquities", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },

                    { name = "musac",               x_offset =  0,   z_offset = 0 }, 
                    { name = "pigman_collector_shopkeep", x_offset = -3, z_offset = 4, startstate = "desk_pre" },
                    { name = "deco_roomglow",             x_offset = 0, z_offset = 0 }, 
                    { name = "shop_spawner",              x_offset = -3, z_offset = 0, shop_type = name, },
                    { name = "shelves_midcentury",        x_offset = -4.5, z_offset = 0, shelfitems={{1,"trinket_1"},{5,"trinket_2"},{6,"trinket_3"}} },
                    { name = "shelves_cinderblocks",      x_offset = -4.5, z_offset = -5},

                    { name = "rug_porcupuss",                  x_offset = 0, z_offset = 0},

                    { name = "deco_antiquities_wallfish",      x_offset = -5, z_offset =  3.9 },

                    { name = "deco_antiquities_cornerbeam",    x_offset = -5,   z_offset = width/2, flip=true },
                    { name = "deco_antiquities_cornerbeam",    x_offset = -5,   z_offset = -width/2 },      
                    { name = "deco_antiquities_cornerbeam2",   x_offset =  4.7, z_offset = width/2,flip=true },
                    { name = "deco_antiquities_cornerbeam2",   x_offset =  4.7, z_offset = -width/2 },  
                    { name = "swinging_light_rope_1",          x_offset = -3,   z_offset =  width/6 }, 

                    { name = "deco_antiquities_screamcatcher", x_offset =-2, z_offset =  -6.5 },
                    { name = "deco_antiquities_windchime",     x_offset = -2, z_offset =  6.5 },

                    { name = "deco_antiquities_beefalo_side",  x_offset = 0, z_offset =  width/2, flip=true },
                    { name = "window_round_curtains_nails",    x_offset = 0, z_offset = -width/2 },
                    { name = "window_round_light",             x_offset = 0, z_offset = -width/2 },                

                    { name = "shop_buyer", x_offset = -2,   z_offset =  (width/2)-3,   startAnim="idle_barrel_dome"},
                    { name = "shop_buyer", x_offset =  1.7, z_offset =  (width/2)-2.5, startAnim="idle_barrel_dome"},  
                    { name = "shop_buyer", x_offset = -2,   z_offset =  2,             startAnim="idle_barrel_dome"},
                    { name = "shop_buyer", x_offset =  2.9, z_offset =  3,             startAnim="idle_barrel_dome"},                                

                    { name = "shop_buyer", x_offset = -2,   z_offset =  (-width/2) + 3,   startAnim="idle_barrel_dome"},
                    { name = "shop_buyer", x_offset =  1.9, z_offset =  (-width/2) + 2.5, startAnim="idle_barrel_dome"},  
                    { name = "shop_buyer", x_offset = -2,   z_offset =  -2,               startAnim="idle_barrel_dome"},
                    { name = "shop_buyer", x_offset =  2.9, z_offset =  -3,               startAnim="idle_barrel_dome"},                                
                }

            elseif inst:HasTag("pig_shop_hatshop") then
                
                floortexture   = "levels/textures/interiors/shop_floor_checkered.tex"
                walltexture    = "levels/textures/interiors/shop_wall_floraltrim2.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"

                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_giftshop", background=true},
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },
                    { name = "shelves_floating",               x_offset = -5,   z_offset = 0, 
                            shelfitems={{1,"petals"},{2,"petals"},{3,"petals"}, {4,"cutgrass"}, {5,"cutgrass"},{6,"petals"}} },

                    { name = "musac",                          x_offset =  0,   z_offset = 0 }, 
                    { name = "deco_roomglow",                  x_offset =  0,   z_offset = 0 }, 
                    { name = "shop_spawner",                   x_offset = -3,   z_offset = 0, shop_type = name },
                    { name = "pigman_hatmaker_shopkeep",       x_offset = -3.5, z_offset = 5, startstate = "desk_pre" },

                    { name = "shelves_pipe",                   x_offset = -4.5, z_offset = -3.5 },

                    { name = "rug_rectangle",                  x_offset =  0,   z_offset = 0, rotation = 90 },
                    { name = "hat_lamp_side",                  x_offset =  2,   z_offset = -width/2 },
                    { name = "wall_mirror",                    x_offset = -1,   z_offset = -width/2 },
                    { name = "sewingmachine",                  x_offset =  4,   z_offset = 5.5 },
                    { name = "hatbox1",                        x_offset = -2,   z_offset = 6.5, },
                    { name = "hatbox1",                        x_offset =  4,   z_offset = -6.5 },
                    { name = "hatbox2",                        x_offset =  4.5, z_offset = -5.75 },

                    { name = "deco_millinery_cornerbeam2",     x_offset = -5,  z_offset = -width/2 },
                    { name = "deco_millinery_beam3",           x_offset = 4.7, z_offset = -width/2 },
                    { name = "deco_millinery_beam2",           x_offset = 4.7, z_offset =  width/2, flip=true },
                    { name = "deco_millinery_cornerbeam3",     x_offset = -5,  z_offset =  width/2, flip=true },

                    { name = "swinging_light_rope_1",          x_offset = -3,   z_offset =  width/6 },

                    { name = "window_round_burlap_backwall", x_offset =  -width/2, z_offset = -5 },
                    { name = "window_round_light_backwall",  x_offset =  -width/2, z_offset = -5 },
                    { name = "window_round_burlap_backwall", x_offset =  -width/2, z_offset =  5 },
                    { name = "window_round_light_backwall",  x_offset =  -width/2, z_offset =  5 },

                    { name = "hat_lamp_side",  x_offset =  0,   z_offset =  width/2, flip=true },
                    { name = "picture_1",      x_offset = -2.5, z_offset =  width/2, flip=true },
                    { name = "picture_2",      x_offset =  2.5, z_offset =  width/2, flip=true },

                    { name = "shop_buyer", x_offset = -1,   z_offset = -3.5, startAnim="idle_hatbox2"},
                    { name = "shop_buyer", x_offset = -1,   z_offset = -1,   startAnim="idle_hatbox4"},
                    { name = "shop_buyer", x_offset = -1,   z_offset =  1.5, startAnim="idle_hatbox2"},
                    { name = "shop_buyer", x_offset =  1.5, z_offset = -4.5, startAnim="idle_hatbox3"},
                    { name = "shop_buyer", x_offset =  1.5, z_offset = -2,   startAnim="idle_hatbox1"},
                    { name = "shop_buyer", x_offset =  1.5, z_offset =  0.5, startAnim="idle_hatbox1"},
                    { name = "shop_buyer", x_offset =  1.5, z_offset =  3,   startAnim="idle_hatbox3"},
                }

            elseif inst:HasTag("pig_shop_weapons") then
                
                floortexture   = "levels/textures/interiors/shop_floor_herringbone.tex"
                walltexture    = "levels/textures/interiors/shop_wall_upholstered.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_basic", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },
                    
                    { name = "shelves_midcentury", x_offset = -4.5, z_offset = 4, --rotation = -90,
                            shelfitems={{5,"twigs"}, {6,"twigs"}, {3,"twigs"}, {4,"twigs"}} },
                    { name = "musac",               x_offset =  0,   z_offset = 0 }, 
                    { name = "deco_roomglow",          x_offset =  0,    z_offset =  0 }, 
                    { name = "shop_spawner",           x_offset = -3,    z_offset =  0, shop_type = name },
                    { name = "pigman_hunter_shopkeep", x_offset = -3,    z_offset =  0, startstate = "desk_pre" },
                    { name = "shield_axes",            x_offset = -width/2, z_offset =  0 }, 

                    { name = "rug_porcupuss", x_offset =  0, z_offset = -2, rotation = -90 },
                    { name = "rug_fur",       x_offset =  2, z_offset =  4, rotation =  90 },
                    { name = "rug_catcoon",   x_offset = -2, z_offset =  4, rotation =  90 },

                    { name = "deco_weapon_beam1", x_offset = -5,   z_offset =  width/2, rotation = -90, flip=true },
                    { name = "deco_weapon_beam1", x_offset = -5,   z_offset = -width/2, rotation = -90 },      
                    { name = "deco_weapon_beam2", x_offset =  4.7, z_offset =  width/2, rotation = -90, flip=true },
                    { name = "deco_weapon_beam2", x_offset =  4.7, z_offset = -width/2, rotation = -90 },
                    
                    { name = "window_square_weapons",         x_offset = 1,  z_offset = -width/2, rotation = -90  },
                    { name = "swinging_light_basic_metal",    x_offset = -2, z_offset =  -4.5,    rotation = -90 },
                    { name = "swinging_light_basic_metal",    x_offset = -6, z_offset =  3,       rotation = -90 },
                    { name = "swinging_light_basic_metal",    x_offset = 3,  z_offset =  6.5,     rotation = -90 },

                    { name = "deco_antiquities_beefalo_side", x_offset = -2, z_offset = width/2,  rotation = -90, flip=true },
                    -- { name = "shield_sidewall",    x_offset = 3, z_offset = -width/2, rotation = -90  },
                    -- { name = "spears_sidewall",    x_offset = 3, z_offset = (-width/2)+0.1, rotation = -90  },
                    { name = "closed_chest",       x_offset = 4.5, z_offset = (-width/2)+1.5},
                    { name = "deco_displaycase",   x_offset = -4,  z_offset = -5.5},
                    { name = "deco_displaycase",   x_offset = -4,  z_offset = -4},
                    

                    { name = "shop_buyer", x_offset =  2.5, z_offset = -2,   saveID = true, startAnim = "idle_cablespool" },
                    { name = "shop_buyer", x_offset = -0.5, z_offset = -2.5, saveID = true, startAnim = "idle_cablespool" },
                    { name = "shop_buyer", x_offset =  1.5, z_offset = -5,   saveID = true, startAnim = "idle_cablespool" },
                    { name = "shop_buyer", x_offset = -1.5, z_offset = -5.5, saveID = true, startAnim = "idle_cablespool" },
                    { name = "shop_buyer", x_offset =  0,   z_offset =  3.5, saveID = true, startAnim = "idle_cablespool" },
                    { name = "shop_buyer", x_offset =  3.5, z_offset =  2.5, saveID = true, startAnim = "idle_cablespool" },
                    { name = "shop_buyer", x_offset =  2.5, z_offset =  5.5, saveID = true, startAnim = "idle_cablespool" },
                }

            elseif inst:HasTag("pig_shop_arcane") then
                
                floortexture = "levels/textures/interiors/shop_floor_octagon.tex"
                walltexture = "levels/textures/interiors/shop_wall_moroc.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_florist", background=true}, 
                             my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },

                    { name = "musac",                   x_offset =  0,   z_offset = 0 }, 
                    { name = "pigman_erudite_shopkeep", x_offset = -3,   z_offset = 4, startstate = "desk_pre" },
                    { name = "deco_roomglow",           x_offset = 0,    z_offset = 0 }, 
                    { name = "shop_spawner",            x_offset = -3,   z_offset = 0, shop_type = name, saveID = true },
                    { name = "shelves_glass",           x_offset = -4.5, z_offset = -4, rotation=-90, shelfitems={{1,"trinket_1"},{5,"trinket_2"},{6,"trinket_3"}} },
                    { name = "deco_arcane_bookshelf",   x_offset = -4.5, z_offset = 0},

                    { name = "rug_round",  x_offset = 0, z_offset = 0},
                    { name = "containers", x_offset = width/2 - 3, z_offset = -width/2 + 1.5},

                    --{ name = "mirror_backwall", x_offset = -5, z_offset =  3.9, rotation = 90 },

                    { name = "deco_accademy_cornerbeam", x_offset =  4.7, z_offset =   width/2, rotation = -90, flip=true },
                    { name = "deco_accademy_cornerbeam", x_offset =  4.7, z_offset =  -width/2, rotation = -90 },  
                    { name = "deco_accademy_beam",       x_offset = -5,   z_offset =   width/2, rotation = -90, flip=true },
                    { name = "deco_accademy_beam",       x_offset = -5,   z_offset =  -width/2, rotation = -90 },      
                    { name = "swinging_light_rope_1",    x_offset = -3,   z_offset =   width/6, rotation = -90 }, 

                    { name = "deco_antiquities_screamcatcher", x_offset =-2,    z_offset =  -6.5, rotation = -90 },
                    { name = "deco_antiquities_windchime",     x_offset = -2,   z_offset =   6.5, rotation = -90 },

                    { name = "deco_antiquities_beefalo_side",  x_offset = 0,    z_offset =  width/2, rotation = -90, flip=true },

                    { name = "window_round_arcane",            x_offset = 0,    z_offset = -width/2, rotation = -90  },
                    { name = "window_round_light",             x_offset = 0,    z_offset = -width/2, rotation = -90  },                

                    { name = "shop_buyer", x_offset = -0.5, z_offset =  2.5,  saveID = true, startAnim="idle_marble"},
                    { name = "shop_buyer", x_offset = -0.5, z_offset = -2.5,  saveID = true, startAnim="idle_marblesilk"},
                    { name = "shop_buyer", x_offset =  2.5, z_offset =  2.5,  saveID = true, startAnim="idle_marble"},
                    { name = "shop_buyer", x_offset =  2.5, z_offset = -2.5,  saveID = true, startAnim="idle_marblesilk"},
                    { name = "shop_buyer", x_offset =  0.5, z_offset = (width/2) - 2.5,  saveID = true, startAnim="idle_marblesilk"},  
                    { name = "shop_buyer", x_offset =  0.5, z_offset = (-width/2) + 2.5, saveID = true, startAnim="idle_marble"},
                }

            elseif inst:HasTag("pig_shop_florist") then
                
                floortexture = "levels/textures/interiors/noise_woodfloor.tex"
                walltexture = "levels/textures/interiors/shop_wall_sunflower2.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_florist", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },

                    { name = "musac",               x_offset =  0,   z_offset = 0 }, 
                    { name = "pigman_florist_shopkeep", x_offset = -1,   z_offset =  4,    startstate = "desk_pre" },
                    { name = "deco_roomglow",           x_offset =  0,   z_offset =  0 }, 
                    { name = "shop_spawner",            x_offset =  0,   z_offset =  0,    shop_type = name },
                    { name = "shelves_hutch",           x_offset = -4.5, z_offset = -2.6, shelfitems={{3,"seeds"},{4,"seeds"},{5,"seeds"},{6,"seeds"}} },

                    { name = "rug_rectangle", x_offset = -2.3, z_offset = -width/4+1,   rotation = 92},
                    { name = "rug_rectangle", x_offset =  1.5, z_offset = -width/4+0.5, rotation = 86},

                    { name = "deco_wallpaper_florist_rip1", x_offset = -5,    z_offset =  0 },
                    { name = "deco_florist_latice_front",   x_offset = -4.5,  z_offset =  3 }, 
                    { name = "deco_florist_latice_side",    x_offset = 0,     z_offset =  width/2, flip = true},                                
                    { name = "deco_florist_pillar_front",   x_offset = -4.5,  z_offset = -width/2 + 0.8 },
                    { name = "deco_florist_pillar_front",   x_offset = -4.5,  z_offset =  width/2 - 0.8 },
                    { name = "deco_florist_pillar_side",    x_offset = 4.3,   z_offset = -width/2 },  
                    { name = "deco_florist_pillar_side",    x_offset = 4.3,   z_offset =  width/2, flip = true },  
                    { name = "deco_florist_plantholder",    x_offset = 3,     z_offset = -width/2 + 0.8},
                    { name = "deco_florist_vines2",         x_offset =  -4.5, z_offset = -5 },  
                    { name = "deco_florist_vines3",         x_offset =  -3,   z_offset = -width/2 },  
                    { name = "deco_florist_hangingplant1",  x_offset = -1,    z_offset = -width/2+2.5 },
                    { name = "deco_florist_hangingplant2",  x_offset = -1,    z_offset =  width/2-2 }, 

                    { name = "window_round",       x_offset = 0, z_offset = -width/2 },
                    { name = "window_round_light", x_offset = 0, z_offset = -width/2 },

                    { name = "swinging_light_floral_scallop", x_offset = -2, z_offset =  2 },

                    { name = "shop_buyer", x_offset = -2,   z_offset =  (-width/2) + 3.5, startAnim="idle_cart"},
                    { name = "shop_buyer", x_offset =  1.5, z_offset =  (-width/2) + 3,   startAnim="idle_cart"},
                    { name = "shop_buyer", x_offset = -2,   z_offset = -1.5,              startAnim="idle_traystand"},
                    { name = "shop_buyer", x_offset = 1.5, z_offset =  -2,                startAnim="idle_traystand"},                    
                    { name = "shop_buyer", x_offset = 1.5,  z_offset =  2,                startAnim="idle_traystand"},
                    { name = "shop_buyer", x_offset = 1.5,  z_offset =  (width/2) - 3,    startAnim="idle_wagon"},
                }
            elseif inst:HasTag("pig_shop_hoofspa") then
                
                floortexture = "levels/textures/interiors/shop_floor_checker.tex"
                walltexture = "levels/textures/interiors/shop_wall_marble.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_hoofspa", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT}},
                    { name = "musac",               x_offset =  0,   z_offset = 0 }, 
                    { name = "pigman_beautician_shopkeep", x_offset = -3, z_offset = 3, startstate = "desk_pre" },
                    { name = "deco_roomglow",              x_offset = 0,  z_offset = 0 }, 
                    { name = "shop_spawner",               x_offset = -3, z_offset = 0, shop_type = name },

                    { name = "shelves_marble", x_offset = -4.5, z_offset = -3,  rotation=-90, shelfitems={{3,"petals"},{4,"petals"},{5,"petals"},{6,"petals"}}},

                    { name = "deco_marble_cornerbeam",  x_offset = -5,    z_offset = -width/2 }, 
                    { name = "deco_marble_cornerbeam",  x_offset = -5,    z_offset =  width/2,         flip = true },      
                    { name = "deco_marble_beam",        x_offset =  4.7,  z_offset = -width/2 + 0.3 },
                    { name = "deco_marble_beam",        x_offset =  4.7,  z_offset =  width/2 - 0.3,   flip = true  },  
                    { name = "deco_chaise",             x_offset = -1.4,  z_offset = -3.5 },
                    { name = "deco_lamp_hoofspa",       x_offset = -1.9,  z_offset = -5.2 },
                    { name = "deco_plantholder_marble", x_offset = -4.6,  z_offset =  (width/2)-2 },
                    { name = "deco_valence",            x_offset = -5.01, z_offset =  -width/2 },
                    { name = "deco_valence",            x_offset = -5.01, z_offset =  width/2,         flip = true },

                    { name = "wall_mirror",                x_offset = -1, z_offset = -width/2 },  
                    { name = "swinging_light_floral_bulb", x_offset = -2, z_offset = 0 }, 

                    { name = "shop_buyer", x_offset = 2.3,  z_offset =  -4.5,   startAnim = "idle_cakestand" },
                    { name = "shop_buyer", x_offset = 2.3,  z_offset =  -2.6,   startAnim = "idle_cakestand" }, 
                    { name = "shop_buyer", x_offset = -0.5, z_offset =  0,      startAnim = "idle_marble" },
                    { name = "shop_buyer", x_offset = -0.5, z_offset =  3,      startAnim = "idle_marble" },
                    { name = "shop_buyer", x_offset = 2,    z_offset =  4.4,    startAnim = "idle_marblesilk" },
                } 
            elseif inst:HasTag("pig_shop_general") then
                
                floortexture = "levels/textures/interiors/shop_floor_checker.tex"
                walltexture = "levels/textures/interiors/shop_wall_woodwall.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_general", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },

                    { name = "pigman_banker_shopkeep", x_offset = -1, z_offset = 4, startstate = "desk_pre" },
                    { name = "musac",               x_offset =  0,   z_offset = 0 }, 
                    { name = "shop_spawner", x_offset = -3,   z_offset =  0, shop_type = name },
                    { name = "shelves_wood", x_offset = -4.5, z_offset = -4, shelfitems={{3,"rocks"},{4,"rocks"},{5,"rocks"},{6,"rocks"}} },
                    { name = "shelves_wood", x_offset = -4.5, z_offset =  4, shelfitems={{3,"cutgrass"},{4,"cutgrass"},{5,"cutgrass"},{6,"cutgrass"}} },
                    { name = "rug_hedgehog", x_offset = -0.2, z_offset =  4, rotation = 90},
                  
                    { name = "deco_roomglow",             x_offset =  0, z_offset =  0 }, 
                    { name = "deco_wood_cornerbeam",      x_offset = -5, z_offset = width/2, flip=true },
                    { name = "deco_wood_cornerbeam",      x_offset = -5, z_offset = -width/2 },      
                    { name = "deco_wood_cornerbeam",      x_offset =  5, z_offset =  width/2, flip=true },
                    { name = "deco_wood_cornerbeam",      x_offset =  5, z_offset = -width/2,},  
                    { name = "deco_general_hangingpans",  x_offset =  0, z_offset = -width/2+2},
                    { name = "deco_general_hangingscale", x_offset = -2, z_offset =  6 },
                    { name = "deco_general_trough",       x_offset =  1, z_offset = -width/2 },
                    { name = "deco_general_trough",       x_offset =  3, z_offset = -width/2 },

                    { name = "window_round",       x_offset = -2, z_offset = -width/2 },
                    { name = "window_round_light", x_offset = -2, z_offset = -width/2 },

                    { name = "window_round",       x_offset = 1.5, z_offset = width/2, rotation = 90 },
                    { name = "window_round_light", x_offset = 1.5, z_offset = width/2, rotation = 90 },

                    { name = "swinging_light_chandalier_candles", x_offset = -1.3, z_offset = 0 }, 
                
                    { name = "shop_buyer", x_offset = -1.8, z_offset = -4.1, startAnim="idle_cablespool" },
                    { name = "shop_buyer", x_offset = -1.8, z_offset = -1.9, startAnim="idle_barrel" },
                    { name = "shop_buyer", x_offset = -2,   z_offset =  0.3, startAnim="idle_barrel" },

                    { name = "shop_buyer", x_offset = 1.1, z_offset = -4.4,  startAnim = "idle_barrel" },
                    { name = "shop_buyer", x_offset = 1.3, z_offset = -2.2,  startAnim = "idle_barrel" },                  
                    { name = "shop_buyer", x_offset = 1.1, z_offset =  0,    startAnim = "idle_cablespool" },     

                    { name = "shop_buyer", x_offset = 1.5, z_offset = 5,     startAnim = "idle_barrel" },
                    { name = "shop_buyer", x_offset = 1.5, z_offset = 2.5,   startAnim = "idle_barrel" },
                } 
            elseif inst:HasTag("pig_shop_produce") then
                
                floortexture = "levels/textures/interiors/noise_woodfloor.tex"
                walltexture = "levels/textures/interiors/shop_wall_woodwall.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_produce", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },
                    { name = "musac",               x_offset =  0,   z_offset = 0 }, 
                    { name = "pigman_storeowner_shopkeep", x_offset = -2.5,         z_offset = 4, startstate = "desk_pre" }, 
                    { name = "shop_spawner",               x_offset = -3,           z_offset = 0, shop_type = name },
                    { name = "rug_rectangle",              x_offset = depth/6+1,    z_offset = width/6+1, rotation =  95},
                    { name = "rug_rectangle",              x_offset = -depth/6+1,   z_offset = width/6+1, rotation =  91},
                    { name = "rug_rectangle",              x_offset = depth/6+0.5,  z_offset = -width/6,  rotation = -95},
                    { name = "rug_rectangle",              x_offset = -depth/6-0.5, z_offset = -width/6,  rotation =  91},

                    { name = "deco_roomglow",                 x_offset =  0,       z_offset = 0 }, 
                    { name = "deco_general_hangingscale",     x_offset = -4,       z_offset = 4.7 },
                    { name = "deco_produce_stone_cornerbeam", x_offset = -5,       z_offset =  width/2, flip = true },
                    { name = "deco_produce_stone_cornerbeam", x_offset = -5,       z_offset = -width/2 },      
                    { name = "deco_wood_cornerbeam",          x_offset =  5,       z_offset = -width/2, },
                    { name = "deco_wood_cornerbeam",          x_offset =  5,       z_offset =  width/2, flip = true },  
                    { name = "deco_produce_menu_side",        x_offset =  0,       z_offset = -width/2 }, 
                    { name = "deco_produce_menu",             x_offset = -depth/2, z_offset = -width/6 },
                    { name = "deco_produce_menu",             x_offset = -depth/2, z_offset =  width/6 },

                    { name = "window_round",       x_offset =  depth/6, z_offset = width/2, rotation = 90 },
                    { name = "window_round",       x_offset = -depth/6, z_offset = width/2, rotation = 90 },
                    { name = "window_round_light", x_offset =  depth/6, z_offset = width/2, rotation = 90 },
                    { name = "window_round_light", x_offset = -depth/6, z_offset = width/2, rotation = 90 },

                    { name = "swinging_light_pendant_cherries", x_offset = -1, z_offset =  -width/6 },


                    { name = "shop_buyer", x_offset = -2.5, z_offset = -4.9, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset = -2.5, z_offset = -2.7, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset = -2.8, z_offset = -0.5, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset = -0.3, z_offset =  2.2, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset = -0.3, z_offset =  4.4, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset =  1,   z_offset = -5.1, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset =  1,   z_offset = -2.7, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset =  1,   z_offset = -0.5, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset =  2.7, z_offset =  2.2, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset =  2.7, z_offset =  4.4, startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset =  4,   z_offset = -4,   startAnim = "idle_ice_bucket", saleitem={"ice","oinc",1},},
                }             
            elseif inst:HasTag("pig_shop_deli") then
                
                floortexture = "levels/textures/interiors/shop_floor_sheetmetal.tex"
                walltexture = "levels/textures/interiors/shop_wall_checkered_metal.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_deli", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },
                    { name = "musac",               x_offset =  0,   z_offset = 0 }, 
                    { name = "pigman_storeowner_shopkeep", x_offset = -1, z_offset = 4, startstate = "desk_pre" },
                    { name = "shop_spawner",               x_offset = -3, z_offset = 0, shop_type = name },
                    { name = "shelves_fridge", x_offset = -4.5, z_offset = -4, rotation=-90,  shelfitems={{1,"fish_raw_small"},{2,"fish_raw_small"},{3,"bird_egg"},{4,"bird_egg"},{5,"froglegs"},{6,"froglegs"}} },

                    { name = "deco_general_hangingscale",     x_offset = -2, z_offset =  4.7 },
                    { name = "deco_roomglow",                 x_offset =  0, z_offset =  0 }, 
                    { name = "deco_wood_cornerbeam",          x_offset = -5, z_offset =  width/2, flip = true },
                    { name = "deco_wood_cornerbeam",          x_offset = -5, z_offset = -width/2 },      
                    { name = "deco_wood_cornerbeam",          x_offset =  5, z_offset =  width/2, flip = true },
                    { name = "deco_wood_cornerbeam",          x_offset =  5, z_offset = -width/2 },  
                    { name = "deco_deli_meatrack",            x_offset =  0, z_offset = -width/2+2 },
                    { name = "deco_deli_basket",              x_offset =  3, z_offset = -width/2+1 },
                    { name = "deco_deli_stove_metal_side",    x_offset = -3, z_offset =  width/2, flip = true },
                    { name = "deco_deli_wallpaper_rip_side1", x_offset = -1, z_offset = -width/2 },
                    { name = "deco_deli_wallpaper_rip_side2", x_offset =  2, z_offset =  width/2, flip = true },

                    { name = "window_round_burlap_backwall", x_offset = -5, z_offset = 2  },
                    { name = "window_round_light_backwall",  x_offset = -5, z_offset = 2  },

                    { name = "swinging_light_basic_metal", x_offset = -1.3, z_offset = -width/6+0.5 }, 

                    { name = "shop_buyer", x_offset = -1.8, z_offset = -5.1,  startAnim = "idle_cakestand_dome" },
                    { name = "shop_buyer", x_offset = -1.8, z_offset = -2.4,  startAnim = "idle_cakestand_dome" },
                    { name = "shop_buyer", x_offset = -2,   z_offset =  0.3,  startAnim = "idle_cakestand_dome" },
                    { name = "shop_buyer", x_offset = 3.1,  z_offset = -5.4,  startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset = 1,    z_offset = -4.6,  startAnim = "idle_ice_box" },
                    { name = "shop_buyer", x_offset = 2.1,  z_offset = -2,    startAnim = "idle_ice_bucket" },
                    { name = "shop_buyer", x_offset = 2.5,  z_offset = 5,     startAnim = "idle_fridge_display" },
                    { name = "shop_buyer", x_offset = 2.5,  z_offset = 2.5,   startAnim = "idle_fridge_display" },
                } 
            elseif inst:HasTag("pig_shop_cityhall") then             
                
                floortexture = "levels/textures/interiors/floor_cityhall.tex"
                walltexture = "levels/textures/interiors/wall_mayorsoffice_whispy.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_flag", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },

                    { name = "pigman_mayor_shopkeep",    x_offset = -3, z_offset = 4 },
                    { name = "deco_roomglow",            x_offset = 0,  z_offset = 0 }, 
                    { name = "shop_spawner",             x_offset = -3, z_offset = 0, shop_type = name },

                    { name = "deco_cityhall_desk",       x_offset = -1.3,     z_offset =  0 },
                    { name = "deco_cityhall_bookshelf",  x_offset = -depth/2, z_offset =  width/3 },
                    { name = "deco_cityhall_bookshelf",  x_offset = -depth/2, z_offset = -width/3, flip=true  },

                    { name = "deco_cityhall_cornerbeam", x_offset = -4.99, z_offset =  width/2, flip=true },
                    { name = "deco_cityhall_cornerbeam", x_offset = -4.99, z_offset = -width/2 },      
                    { name = "deco_cityhall_pillar",     x_offset =  4.7,  z_offset =  width/2, flip=true },
                    { name = "deco_cityhall_pillar",     x_offset =  4.7,  z_offset = -width/2 },  

                    { name = "deco_cityhall_picture1",   x_offset =  1.3,  z_offset =  width/2, flip=true },
                    { name = "deco_cityhall_picture2",   x_offset = -1.3,  z_offset =  width/2, flip=true },

                    { name = "rug_hoofprint",            x_offset =  0,    z_offset =  0,    rotation = 90  },

                    { name = "rug_cityhall_corners", x_offset = -depth/2, z_offset =  width/2, rotation = 90  },
                    { name = "rug_cityhall_corners", x_offset =  depth/2, z_offset =  width/2, rotation = 180 },
                    { name = "rug_cityhall_corners", x_offset =  depth/2, z_offset = -width/2, rotation = 270 },
                    { name = "rug_cityhall_corners", x_offset = -depth/2, z_offset = -width/2, rotation = 0   },

                    { name = "window_round_light_backwall", x_offset = -5,    z_offset = 2 }, 
                    { name = "window_mayorsoffice",         x_offset = -depth/2, z_offset = 0, rotation =  90 },

                    { name = "wall_mirror", x_offset = -1, z_offset = -width/2 },  

                    { name = "shop_buyer", x_offset = 1.75,   z_offset =  width/2-5, saleitem = {"deed","oinc", 50},                  startAnim = "idle_globe_bar", justsellonce = true},
                    { name = "shop_buyer", x_offset = 3.5, z_offset =  width/2-2, saleitem = {"construction_permit", "oinc", 50 }, startAnim = "idle_globe_bar"  },
                    { name = "shop_buyer", x_offset = -1, z_offset =  width/2-2, saleitem = {"demolition_permit",   "oinc", 10 }, startAnim = "idle_globe_bar"  },

                    { name = "shop_buyer", x_offset = 2,   z_offset = -width/2+3, saleitem = {"securitycontract",    "oinc", 10 }, startAnim = "idle_marble_dome"},
                }     
            elseif inst:HasTag("pig_shop_cityhall_player") then             
                
                floortexture = "levels/textures/interiors/floor_cityhall.tex"
                walltexture = "levels/textures/interiors/wall_mayorsoffice_whispy.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_flag", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },

                    --{ name = "pigman_mayor_shopkeep",    x_offset = -3, z_offset = 4 },
                    { name = "deco_roomglow",            x_offset = 0,  z_offset = 0 }, 
                    { name = "shop_spawner",             x_offset = -3, z_offset = 0, shop_type = name },

                    { name = "deco_cityhall_desk",       x_offset = -1.3,     z_offset =  0 },
                    { name = "deco_cityhall_bookshelf",  x_offset = -depth/2, z_offset =  width/3 },
                    { name = "deco_cityhall_bookshelf",  x_offset = -depth/2, z_offset = -width/3, flip=true  },

                    { name = "deco_cityhall_cornerbeam", x_offset = -4.99, z_offset =  width/2, flip=true },
                    { name = "deco_cityhall_cornerbeam", x_offset = -4.99, z_offset = -width/2 },      
                    { name = "deco_cityhall_pillar",     x_offset =  4.7,  z_offset =  width/2, flip=true },
                    { name = "deco_cityhall_pillar",     x_offset =  4.7,  z_offset = -width/2 },  

                    { name = "deco_cityhall_picture1",   x_offset =  1.3,  z_offset =  width/2, flip=true },
                    { name = "deco_cityhall_picture2",   x_offset = -1.3,  z_offset =  width/2, flip=true },

                    { name = "rug_hoofprint",            x_offset =  0,    z_offset =  0,    rotation = 90  },

                    { name = "rug_cityhall_corners", x_offset = -depth/2, z_offset =  width/2, rotation = 90  },
                    { name = "rug_cityhall_corners", x_offset =  depth/2, z_offset =  width/2, rotation = 180 },
                    { name = "rug_cityhall_corners", x_offset =  depth/2, z_offset = -width/2, rotation = 270 },
                    { name = "rug_cityhall_corners", x_offset = -depth/2, z_offset = -width/2, rotation = 0   },

                    { name = "window_round_light_backwall", x_offset = -5,    z_offset = 2 }, 
                    { name = "window_mayorsoffice",         x_offset = -depth/2, z_offset = 0, rotation =  90 },

                    { name = "wall_mirror", x_offset = -1, z_offset = -width/2 },  
            
                }    
            elseif inst:HasTag("pig_shop_bank") then             
                
                floortexture = "levels/textures/interiors/shop_floor_hoof_curvy.tex"
                walltexture = "levels/textures/interiors/shop_wall_fullwall_moulding.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                height = 6
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_bank", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },

                    { name = "musac",               x_offset =  0,   z_offset = 0 }, 
                    { name = "pigman_banker_shopkeep",     x_offset = -2.5,         z_offset = 0, startstate = "desk_pre" }, 
                    { name = "shop_spawner",               x_offset = -3,           z_offset = 0, shop_type = name },

                    { name = "deco_roomglow",            x_offset = 0,  z_offset = 0 }, 


                    { name = "deco_bank_marble_cornerbeam", x_offset = -4.99, z_offset =  width/2, flip=true },
                    { name = "deco_bank_marble_cornerbeam", x_offset = -4.99, z_offset = -width/2 },      
                    { name = "deco_bank_marble_beam",     x_offset =  4.7,  z_offset =  width/2, flip=true },
                    { name = "deco_bank_marble_beam",     x_offset =  4.7,  z_offset = -width/2 },  

                    { name = "deco_bank_clock1_side",   x_offset = -depth/4,  z_offset =  width/2, flip=true },
                    { name = "deco_bank_clock2_side",   x_offset = 0,  z_offset =  width/2, flip=true },
                    { name = "deco_bank_clock3_side",   x_offset = depth/4,  z_offset =  width/2, flip=true },

                    { name = "deco_bank_clock3_side",   x_offset = -depth/4,  z_offset =  -width/2},
                    { name = "deco_bank_clock1_side",   x_offset = 0,  z_offset =  -width/2 },
                    { name = "deco_bank_clock2_side",   x_offset = depth/4,  z_offset =  -width/2},

                    { name = "shop_buyer", x_offset = 2.3,  z_offset = -width/4.5,    startAnim = "idle_marble_dome", saleitem={"oinc10","oinc",10} },                    
                    { name = "shop_buyer", x_offset = -1.7,  z_offset = -width/4.5,   startAnim = "idle_marble_dome", saleitem={"oinc100","oinc",100} },
                    { name = "shop_buyer", x_offset = -1.7,  z_offset = width/4.5,     startAnim = "idle_marble_dome", saleitem={"goldnugget","oinc",10} },

                    { name = "deco_bank_vault",            x_offset = -depth/2,    z_offset =  0  },

                    { name = "deco_accademy_barrier",           x_offset = -3,   z_offset =  -width/4.5 },                   
                    { name = "deco_accademy_barrier",           x_offset = -3,   z_offset =  width/4.5 },                   
                    { name = "deco_accademy_barrier_vert",  x_offset = -2,  z_offset =  -5 },                    
                    { name = "deco_accademy_barrier_vert",  x_offset =  2.3,  z_offset =  -5 },
                    
                    { name = "deco_accademy_barrier_vert",  x_offset = -2,  z_offset =  5, flip = true },                    
                    { name = "deco_accademy_barrier_vert",  x_offset =  2.3,  z_offset =  5, flip = true }, 

                    { name = "shelves_displaycase_metal", x_offset = -2, z_offset = -width/2+0.75, rotation = 90, flip = true, shelfitems={{1,"flint"},{2,"rocks"},{3,"flint"}} },                   
                    { name = "shelves_displaycase_metal", x_offset = -2, z_offset = width/2-0.75, rotation = 90, shelfitems={{1,"rocks"},{2,"rocks"},{3,"rocks"}} },                   
                    { name = "shelves_displaycase_metal", x_offset = 2.3, z_offset = -width/2+0.75, rotation = 90, flip = true, shelfitems={{1,"nitre"},{2,"nitre"},{3,"rocks"}} },                   
                    { name = "shelves_displaycase_metal", x_offset = 2.3, z_offset = width/2-0.75, rotation = 90, shelfitems={{1,"rocks"},{2,"charcoal"},{3,"charcoal"}} },                   

                    { name = "swinging_light_bank", x_offset = -1.7, z_offset = -width/4.5 }, 

                    { name = "swinging_light_bank", x_offset = -1.7, z_offset = width/4.5}, 
            
                }       

            elseif inst:HasTag("pig_shop_tinker") then             
                
                floortexture = "levels/textures/interiors/shop_floor_woodpaneling2.tex"
                walltexture = "levels/textures/interiors/shop_wall_bricks.tex"
                minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
                height = 6
                addprops = {
                    { name = "prop_door", x_offset = 5, z_offset = 0, animdata = {bank ="pig_shop_doormats", build ="pig_shop_doormats", anim="idle_tinker", background=true}, 
                        my_door_id = exterior_door_def.target_door_id, target_door_id = exterior_door_def.my_door_id, addtags={"guard_entrance"}, usesounds={SHOPSOUND_EXIT} },

                    { name = "musac",               x_offset =  0,   z_offset = 0 }, 
                    { name = "pigman_mechanic_shopkeep",     x_offset = -2,         z_offset = -3, startstate = "desk_pre" }, 
                    { name = "shop_spawner",               x_offset = -3,           z_offset = 0, shop_type = name },

                    { name = "deco_roomglow",            x_offset = 0,  z_offset = 0 }, 

                    { name = "deco_tinker_cornerbeam", x_offset = -4.99, z_offset =  width/2, flip=true },
                    { name = "deco_tinker_cornerbeam", x_offset = -4.99, z_offset = -width/2 },      
                    { name = "deco_tinker_beam",     x_offset =  4.7,  z_offset =  width/2, flip=true },
                    { name = "deco_tinker_beam",     x_offset =  4.7,  z_offset = -width/2 },  

                    { name = "deco_bank_clock1_side",   x_offset = -depth/4,  z_offset =  width/2, flip=true },
                    { name = "deco_bank_clock2_side",   x_offset = 0,  z_offset =  -width/2},

                    { name = "shop_buyer", x_offset = 1.3,  z_offset = -width/6 -1.75,     startAnim = "idle_metal" },                    
                    { name = "shop_buyer", x_offset = 1.3,  z_offset = -1.75,            startAnim = "idle_metal" },                    
                    { name = "shop_buyer", x_offset = -1.7,  z_offset = width/6 +0.5,     startAnim = "idle_metal" },
                    { name = "shop_buyer", x_offset = -1.7,  z_offset = 0.5,            startAnim = "idle_metal" },

                    { name = "shelves_metal", x_offset = -4.0, z_offset = 4,  rotation=-90, shelfitems={{3,"charcoal"},{4,"nitre"},{5,"papyrus"},{6,"charcoal"}}},
                  -- { name = "shelves_metal", x_offset = -4.0, z_offset = -4,  rotation=-90, shelfitems={{1,"charcoal"},{2,"nitre"},{3,"papyrus"},{4,"charcoal"}}},

                    { name = "window_round_backwall",   x_offset = -depth/2, z_offset = 0 },
                --    { name = "window_round_light",      x_offset = -depth/2, z_offset = 0 },

                    { name = "rug_fur",       x_offset =  -1.5, z_offset =  2, rotation =  100 },   
                    { name = "rug_fur",       x_offset = 1.5, z_offset =  -3, rotation =  90 },   

                    { name = "swinging_light_bank", x_offset = -3, z_offset = -width/4.5+0.5 }, 
                    { name = "swinging_light_bank", x_offset = 0, z_offset = width/4.5+2 }, 
                    
                   
                    { name = "deco_rollchest",              x_offset = 4,  z_offset = -5 }, 
                    { name = "deco_worktable",              x_offset = 2.5,  z_offset = 4, rotation=90, flip = true  },                     

                    { name = "deco_filecabinet",            x_offset = -2.5,  z_offset = -width/2 }, 
                    { name = "deco_rollholder",            x_offset = 2,  z_offset = -width/2+0.7 }, 
                    { name = "deco_rollholder",            x_offset = 0,  z_offset = width/2-0.7, rotation=90, flip = true }, 
                    { name = "deco_rollholder_front",            x_offset = -depth/2+0.3,  z_offset =-4 }, 
            
                }                                        
            else
                print("UNKNOWN SHOP TYPE") 
            end     

            local cityID = nil
            if inst.components.citypossession then
                cityID = inst.components.citypossession.cityID
            end
                                                                                                                                                                                                                
            interior_spawner:CreateRoom("generic_interior", width, height, depth, name..ID, ID, addprops, {}, walltexture, floortexture, minimaptexture, cityID ,"images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "inside",  ambsnd, "WOOD")
            -- END INTERIOR CREATION
        end

        inst.interiorID = ID
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

local function canburn(inst)
    local interior_spawner = GetWorld().components.interiorspawner
    if inst.components.door then
        local interior = inst.components.door.target_interior
        if interior_spawner:IsPlayerConsideredInside(interior) then
            -- try again in 2-5 seconds
            return false, 2 + math.random() * 3
        end
    end
    return true
end

local function makeobstacle(inst)

    local ground = GetWorld()
    if ground then
        local pt = Point(inst.Transform:GetWorldPosition())
        --print("    at: ", pt)
        ground.Pathfinder:AddWall(pt.x, pt.y, pt.z-1)
        ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
        ground.Pathfinder:AddWall(pt.x, pt.y, pt.z+1)
        
        ground.Pathfinder:AddWall(pt.x-1, pt.y, pt.z-1)
        ground.Pathfinder:AddWall(pt.x-1, pt.y, pt.z)
        ground.Pathfinder:AddWall(pt.x-1, pt.y, pt.z+1)

        ground.Pathfinder:AddWall(pt.x+1, pt.y, pt.z-1)
        ground.Pathfinder:AddWall(pt.x+1, pt.y, pt.z)
        ground.Pathfinder:AddWall(pt.x+1, pt.y, pt.z+1)
    end
end

local function clearobstacle(inst)

    local ground = TheWorld
    if ground then
        local pt = Point(inst.Transform:GetWorldPosition())
        ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z-1)
        ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
        ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z+1)
        
        ground.Pathfinder:RemoveWall(pt.x-1, pt.y, pt.z-1)
        ground.Pathfinder:RemoveWall(pt.x-1, pt.y, pt.z)
        ground.Pathfinder:RemoveWall(pt.x-1, pt.y, pt.z+1)

        ground.Pathfinder:RemoveWall(pt.x+1, pt.y, pt.z-1)
        ground.Pathfinder:RemoveWall(pt.x+1, pt.y, pt.z)
        ground.Pathfinder:RemoveWall(pt.x+1, pt.y, pt.z+1)        
    end
end


local function makefn(name,build, bank, data)

    local function fn(Sim)
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        local light = inst.entity:AddLight()
        inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()

        local minimap = inst.entity:AddMiniMapEntity()
        if name == "pig_shop_cityhall_player" then 
             -- minimap:SetIcon( "pig_shop_cityhall.png" )
             inst.MiniMapEntity:SetIcon( "pig_shop_cityhall.png" )
        else
            -- minimap:SetIcon( name .. ".png" )
            inst.MiniMapEntity:SetIcon( name .. ".png" )
        end

        light:SetFalloff(1)
        light:SetIntensity(.5)
        light:SetRadius(1)
        light:Enable(false)
        light:SetColour(180/255, 195/255, 50/255)
        
        MakeObstaclePhysics(inst, 1.25)

        if bank then
            anim:SetBank(bank)
        else
            anim:SetBank("pig_shop")
        end

        anim:SetBuild(build)
        anim:PlayAnimation("idle", true)
        anim:Hide("YOTP")
        anim:Hide("YOTP")
	
		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

        inst:AddTag(name)

        inst:AddTag("structure")
        inst:AddTag("city_hammerable")
        
        inst:AddComponent("lootdropper")

        inst:AddComponent("door")
        
        if not data or not data.indestructable then
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(4)
            inst.components.workable:SetOnFinishCallback(onhammered)
            inst.components.workable:SetOnWorkCallback(onhit)
        end

        inst:ListenForEvent( "daytime", function() OnDay(inst) end, GetWorld())    
        inst:ListenForEvent( "dusktime", function() OnDusk(inst) end, GetWorld())    
  
        inst:AddComponent("inspectable")    

        if name == "pig_shop_cityhall" then
            inst.AnimState:AddOverrideBuild("flag_post_duster_build")
        end
        if name == "pig_shop_cityhall_player" then
           inst.AnimState:AddOverrideBuild("flag_post_wilson_build") 
        end
        
        if name == "pig_shop_cityhall_player" then
            GetPlayer():AddTag("mayor")
        end

        inst.components.inspectable.getstatus = getstatus
        
        MakeSnowCovered(inst, .01)

        inst:AddComponent("fixable")
        local fixbank = "pig_shop"
        if bank then
            fixbank = bank
        end
        inst.components.fixable:AddRecinstructionStageData("rubble",fixbank,build)
        inst.components.fixable:AddRecinstructionStageData("unbuilt",fixbank,build)

        if not data or not data.unburnable then
            MakeMediumBurnable(inst, nil, nil, true)
            MakeLargePropagator(inst)
            -- inst.components.burnable:SetCanActuallyBurnFunction(canburn)
        end

        inst:ListenForEvent("burntup", function(inst)
            inst.components.fixable:AddRecinstructionStageData("burnt",fixbank,build,1)
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
            --print(inst, "spawn check day")
            if TheWorld.state.isday then 
                OnDay(inst)
            end 
        end)

        inst:DoTaskInTime(0, function() 
             creatInterior(inst, name)
        end)

        inst:ListenForEvent("nighttime", function() inst.components.door.disabled = true end, GetWorld())
        inst:ListenForEvent("daytime", function() inst.components.door.disabled = nil end, GetWorld())  

        if data and data.sounds then
            inst.usesounds = data.sounds
        end

        inst:ListenForEvent("usedoor", function(inst,data) usedoor(inst,data) end)

        inst:AddComponent("gridnudger")

        inst.setobstical = makeobstacle
        inst:ListenForEvent("onremove", function(inst) clearobstacle(inst) end)

        inst.OnEntityWake = function (_inst)
            if TheWorld.components.aporkalypse and TheWorld.components.aporkalypse:GetFiestaActive() then
                inst.AnimState:Show("YOTP")
            else
                inst.AnimState:Hide("YOTP")
            end
        end

        return inst
    end
    return fn
end

local function makeshop(name, build, bank, data)   
    return Prefab("objects/" .. name, makefn(name, build, bank, data), assets, prefabs )
end

local function placetestfn(inst)
    inst.AnimState:Hide("YOTP")
    inst.AnimState:Hide("SNOW")

    local pt = inst:GetPosition()
    local tile = GetWorld().Map:GetTileAtPoint(pt.x,pt.y,pt.z)
    if tile == GROUND.INTERIOR then
        return false
    end

    return true
end

return makeshop("pig_shop_deli",        "pig_shop_deli",        nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),
       makeshop("pig_shop_general",     "pig_shop_general",     nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),
       makeshop("pig_shop_hoofspa",     "pig_shop_hoofspa",     nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),        
       makeshop("pig_shop_produce",     "pig_shop_produce",     nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),
       makeshop("pig_shop_florist",     "pig_shop_florist",     nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),
       makeshop("pig_shop_antiquities", "pig_shop_antiquities", nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ), 

       makeshop("pig_shop_academy",     "pig_shop_accademia",   nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),
       makeshop("pig_shop_arcane",      "pig_shop_arcane",      nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),
       makeshop("pig_shop_weapons",     "pig_shop_weapons",     nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),
       makeshop("pig_shop_hatshop",     "pig_shop_millinery",   nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),

       makeshop("pig_shop_bank",        "pig_shop_bank",        nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),
       makeshop("pig_shop_tinker",      "pig_shop_tinker",      nil,    {sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} } ),

       makeshop("pig_shop_cityhall", "pig_cityhall", "pig_cityhall",    {indestructable=true, unburnable=true, sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} }),
       makeshop("pig_shop_cityhall_player", "pig_cityhall", "pig_cityhall",{ unburnable=true, sounds = {SHOPSOUND_ENTER1,SHOPSOUND_ENTER2} }),
       Prefab("pig_shop_spawner", makespawnerfn, assets, spawnprefabs ),


       MakePlacer("pig_shop_deli_placer", "pig_shop", "pig_shop_deli", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_general_placer", "pig_shop", "pig_shop_general", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_hoofspa_placer", "pig_shop", "pig_shop_hoofspa", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_produce_placer", "pig_shop", "pig_shop_produce", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_florist_placer", "pig_shop", "pig_shop_florist", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_antiquities_placer", "pig_shop", "pig_shop_antiquities", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_arcane_placer", "pig_shop", "pig_shop_arcane", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_weapons_placer", "pig_shop", "pig_shop_weapons", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_hatshop_placer", "pig_shop", "pig_shop_millinery", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_cityhall_placer", "pig_cityhall", "pig_cityhall", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_bank_placer", "pig_shop", "pig_shop_bank", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("pig_shop_tinker_placer", "pig_shop", "pig_shop_tinker", "idle", false, false, true, nil, nil, nil, nil, nil, nil, placetestfn)