local SHOPTYPES = 
{
    ["DEFAULT"] = {"rocks", "flint", "goldnugget"},

    ["pig_shop_deli"] = {
                            { "ratatouille",     "oinc", 3  },
                            { "monsterlasagna",  "oinc", 2  },
                            { "pumpkincookie",   "oinc", 3  },
                            { "stuffedeggplant", "oinc", 4  },
                            { "frogglebunwich",  "oinc", 5  },
                            { "honeynuggets",    "oinc", 5  },
                            { "perogies",        "oinc", 10 },
                            { "waffles",         "oinc", 10 },
                            { "meatballs",       "oinc", 10 },
                            { "honeyham",        "oinc", 20 },
                            { "turkeydinner",    "oinc", 10 },
                            { "dragonpie",       "oinc", 30 },
                        },
    
    ["pig_shop_florist"] = {
                            { "carrot_seeds",      "oinc", 1  },
                            { "pumpkin_seeds",     "oinc", 1  },
                            { "pomegranate_seeds", "oinc", 1  },
                            { "eggplant_seeds",    "oinc", 1  },
                            { "durian_seeds",      "oinc", 1  },
                            { "corn_seeds",        "oinc", 1  },
                            { "dragonfruit_seeds", "oinc", 10 },
                            { "watermelon_seeds",  "oinc", 1  },
                            { "flowerhat",         "oinc", 2  },
                            { "acorn",             "oinc", 1  },
                            { "pinecone",          "oinc", 1  },
                            { "dug_berrybush2",    "oinc", 2  },
                            { "dug_berrybush",     "oinc", 2  },
                        },

    ["pig_shop_general"] = {
                            { "pitchfork",  "oinc", 5  },
                            { "shovel",     "oinc", 5  },
                            { "pickaxe",    "oinc", 5  },
                            { "axe",        "oinc", 5  },
                            { "flint",      "oinc", 1  },
                            { "machete",    "oinc", 5  },
                            { "minerhat",   "oinc", 20 },
                            { "razor",      "oinc", 3  },
                            { "backpack",   "oinc", 5  },
                            { "umbrella",   "oinc", 10 },
                            { "fabric",     "oinc", 5  },
                            { "bugnet",     "oinc", 20 },
                            { "fishingrod", "oinc", 10 },                            
                        },
    ["pig_shop_general_fiesta"] = {                            
                            { "firecrackers",  "oinc", 1  },
                            { "firecrackers",  "oinc", 1  },
                            { "firecrackers",  "oinc", 1  },
                            { "firecrackers",  "oinc", 1  },
                            { "flint",      "oinc", 1  },
                            { "minerhat",   "oinc", 20 },
                            { "backpack",   "oinc", 5  },                            
                            { "fabric",     "oinc", 5  },
                            { "umbrella",   "oinc", 10 },
                            { "bugnet",     "oinc", 20 },                                                                                    
                        },                        

    ["pig_shop_hoofspa"] = {
                            { "blue_cap",     "oinc", 3 },
                            { "green_cap",    "oinc", 2 },
                            { "bandage",      "oinc", 5 },
                            { "healingsalve", "oinc", 4 },
                            { "antivenom",    "oinc", 5 },
                            { "coffeebeans",  "oinc", 2 },
                        },

    ["pig_shop_produce"] = {
                            { "berries",      "oinc", 1 },
                            { "watermelon",   "oinc", 1 },
                            { "sweet_potato", "oinc", 1 },
                            { "carrot",       "oinc", 1 },
                            { "drumstick",    "oinc", 2 },
                            { "eggplant",     "oinc", 2 },
                            { "corn",         "oinc", 2 },
                            { "pumpkin",      "oinc", 3 },
                            { "meat",         "oinc", 5 },
                            { "pomegranate",  "oinc", 1 },
                            { "cave_banana",  "oinc", 1 },
                            { "coconut",      "oinc", 3 },
                            { "froglegs",     "oinc", 2 },
                        },

    ["pig_shop_antiquities"] = {
                            { "silk",              "oinc", 5  },
                            { "gears",             "oinc", 10 },
                            { "mandrake",          "oinc", 50 },
                            { "wormlight",         "oinc", 20 },
                            { "deerclops_eyeball", "oinc", 50 },
                            { "walrus_tusk",       "oinc", 50 },
                            { "bearger_fur",       "oinc", 40 },
                            { "goose_feather",     "oinc", 40 },
                            { "dragon_scales",     "oinc", 30 },
                            { "houndstooth",       "oinc", 5  },
                            { "bamboo",            "oinc", 3  },
                            { "horn",              "oinc", 5  },
                            { "coontail",          "oinc", 4  },
                            { "lightninggoathorn", "oinc", 5  },
                            { "ox_horn",           "oinc", 5  },
                        },

    ["pig_shop_cityhall"] = {                       
                        },

    ["pig_shop_arcane"] = {                     
                            { "icestaff",     "oinc", 50 },
                            { "firestaff",    "oinc", 50 },
                            { "amulet",       "oinc", 50 },
                            { "blueamulet",   "oinc", 50 },
                            { "purpleamulet", "oinc", 50 },
                            { "livinglog",    "oinc", 5  },
                            { "armorslurper", "oinc", 20 },
                            { "nightsword",   "oinc", 50 },
                            { "armor_sanity", "oinc", 20 },
                            { "onemanband",   "oinc", 40 },
                        },  
    ["pig_shop_weapons"] = {
                            { "spear",          "oinc", 3  },
                            { "halberd",        "oinc", 5  },
                            { "cutlass",        "oinc", 50 },
                            { "trap_teeth",     "oinc", 10 },
                            { "birdtrap",       "oinc", 20 },
                            { "trap",           "oinc", 2  },
                            { "coconade",       "oinc", 20 },
                            { "blowdart_pipe",  "oinc", 10 },
                            { "blowdart_sleep", "oinc", 10 },
                            { "boomerang",      "oinc", 10 },
                        },                      
    ["pig_shop_hatshop"] = {                        
                            { "winterhat",   "oinc", 10 },
                            { "tophat",      "oinc", 10 },
                            { "earmuffshat", "oinc", 5  },
                            { "walrushat",   "oinc", 50 },
                            { "molehat",     "oinc", 20 },
                            { "catcoonhat",  "oinc", 10 },
                            { "captainhat",  "oinc", 20 },
                            { "featherhat",  "oinc", 5  },
                            { "strawhat",    "oinc", 3  },
                            { "beefalohat",  "oinc", 10 },
                            { "pithhat",     "oinc", 10 },
                        },  
    ["pig_shop_bank"] = {                        
                            { "goldnugget",  "oinc", 10 },
                            { "oinc10",      "oinc", 10 },
                            { "oinc100",     "oinc", 100  },
                        },

                        -- MAKE SURE TO ADD A RECIPE TO RECIPES.LUA FOR THINGS ADDED HERE SO THEY CAN BE CRAFTED WITHOUT THE DLC
    ["pig_shop_tinker"] = {                        
                            { "eyebrellahat_blueprint",         "oinc", 300 },
                            { "cane_blueprint",                 "oinc", 500 },
                            { "icepack_blueprint",              "oinc", 100 },
                            { "staff_tornado_blueprint",        "oinc", 100 },
                            { "armordragonfly_blueprint",       "oinc", 200 },
                            { "dragonflychest_blueprint",       "oinc", 200 },   
                            { "molehat_blueprint",              "oinc", 30 },
                            { "beargervest_blueprint",          "oinc", 50 },  
                            { "ox_flute_blueprint",             "oinc", 100 },  
                        },                                                  
    ["pig_shop_academy"] = {
                        },
}

local ShopInterior = Class(function(self, inst)
    self.inst = inst
    self.payment_wanted = nil 
    self.items = {}
    self.pigseller = nil 
    self.shopType = nil 
    self.want_all = false
    self.items_wanted = {}
end)

function ShopInterior:BoughtItem(prefab, player)
    if self.items ~= nil then   
        if player.components.inventory and prefab.components.shopdispenser then 

            local item = SpawnPrefab(prefab.components.shopdispenser:GetItem())
            if item.OnBought then
                item.OnBought(item)
            end
            
            player.components.inventory:GiveItem(item, nil, Vector3(TheSim:GetScreenPos(prefab.Transform:GetWorldPosition())))
            local newItem = GetRandomItem(self.items)
            prefab:SoldItem() -- TimedInventory(newItem)
        end 
    end 
end 
 
function ShopInterior:OnRemoveEntity()
    if self.thought then
        self.thought:Remove()
    end
    local x,y,z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 5, {"pig_shop_item"})
    for i=#ents,1, -1 do
        local ent = ents[i]
        if ent.components.shopped and ent.components.shopped.shop == self then
            ent:Remove()
        end
    end
end

function ShopInterior:GetNewProduct(shoptype)
    if TheWorld.components.aporkalypse and TheWorld.components.aporkalypse:GetFiestaActive() and SHOPTYPES[shoptype.."_fiesta"] then
        shoptype = shoptype.."_fiesta"
    end
    local items = SHOPTYPES[shoptype]
    if items then
        local itemset = GetRandomItem(items)
        return itemset
    end
end

function ShopInterior:FillPedestals(numItems, shopType)

    local x,y,z = self.inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x,y,z, 10, {"shop_pedestal"})

    for i=#ents,1, -1 do
        if not ents[i].interiorID or ents[i].interiorID ~= self.inst.interiorID then
            table.remove(ents,i)
        end
    end

    for i = 1, #ents do    
        local itemset = self:GetNewProduct(shopType)        
        local spawn = ents[i]
        if spawn.saleitem then
            itemset = spawn.saleitem
        end        
        spawn.components.shopped:SetShop(self.inst, shopType)
        spawn:AddTag("pig_shop_item")
        spawn:SpawnInventory(itemset[1],itemset[2],itemset[3])
    end

end

function ShopInterior:OnSave()
    local data = {}
    if self.payment_wanted then
        data.payment_wanted = self.payment_wanted
    end
    if next(data) then
        return data
    end
end

function ShopInterior:OnLoad(data)
    if data.payment_wanted then
        self.payment_wanted = data.payment_wanted

    end
end

function ShopInterior:MakeShop(numItems, shopType)
    local x,y,z = self.inst.Transform:GetWorldPosition()
    self.shopType = shopType
    if SHOPTYPES[shopType] then 
        self.items = SHOPTYPES[shopType]
        self:FillPedestals(numItems, shopType)
    end 
end 

function ShopInterior:GetWanted()
    return self.payment_wanted
end 

return ShopInterior 