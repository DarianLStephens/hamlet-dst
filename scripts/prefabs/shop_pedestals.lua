local assets =
{
    --Asset("ANIM", "anim/store_items.zip"),
    Asset("ANIM", "anim/pedestal_crate.zip"),
    Asset("ATLAS_BUILD", "images/inventoryimages1.xml", 256),
    Asset("ATLAS_BUILD", "images/inventoryimages1.xml", 256),
    Asset("ATLAS_BUILD", "images/porkland_inventoryimages.xml", 256),
    Asset("INV_IMAGE", "cost-1"),
    Asset("INV_IMAGE", "cost-2"),
    Asset("INV_IMAGE", "cost-3"),
    Asset("INV_IMAGE", "cost-4"),
    Asset("INV_IMAGE", "cost-5"),
    Asset("INV_IMAGE", "cost-10"),    
    Asset("INV_IMAGE", "cost-20"),
    Asset("INV_IMAGE", "cost-30"),
    Asset("INV_IMAGE", "cost-40"),
    Asset("INV_IMAGE", "cost-50"),
    Asset("INV_IMAGE", "cost-100"),    
    Asset("INV_IMAGE", "cost-200"),
    Asset("INV_IMAGE", "cost-300"),
    Asset("INV_IMAGE", "cost-400"),
    Asset("INV_IMAGE", "cost-500"),    
    Asset("INV_IMAGE", "cost-nil"),    
    Asset("MINIMAP_IMAGE", "accomplishment_shrine"),    
}

local prefabs =
{

}

local function shopkeeper_speech(inst,speech)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 20, {"shopkeep"}) 
    for i, ent in ipairs(ents)do
        ent.shopkeeper_speech(ent,speech)
        --ent.components.talker:Say(speech)                   
    end
end

local function SetImage(inst, ent)
    local src = ent 
    local image = nil 

    if src ~= nil and src.components.inventoryitem ~= nil then
        image = src.prefab
        if src.components.inventoryitem.imagename then
            image = src.components.inventoryitem.imagename
        end          
    end 

    if image ~= nil then 
        local texname = image..".tex"
        inst.AnimState:OverrideSymbol("SWAP_SIGN", GetInventoryItemAtlas(texname), texname)
        --inst.AnimState:OverrideSymbol("SWAP_SIGN", "store_items", image)
        inst.imagename = image
    else
        inst.imagename = ""
        inst.AnimState:ClearOverrideSymbol("SWAP_SIGN")
    end
end 

local function SetImageFromName(inst, name)
    local image = name

    if image ~= nil then 
        local texname = image..".tex"
        inst.AnimState:OverrideSymbol("SWAP_SIGN", GetInventoryItemAtlas(texname), texname)
        --inst.AnimState:OverrideSymbol("SWAP_SIGN", "store_items", image)
        inst.imagename = image
    else
        inst.imagename = ""
        inst.AnimState:ClearOverrideSymbol("SWAP_SIGN")
    end
end 

local function SetCost(inst, costprefab, cost)    

    local image = nil 
    
    if costprefab then
        image = costprefab
    end
    if costprefab == "oinc" and cost then
        image = "cost-"..cost
    end

    if image ~= nil then 
        local texname = image..".tex"
        inst.AnimState:OverrideSymbol("SWAP_COST", GetInventoryItemAtlas(texname), texname)
        --inst.AnimState:OverrideSymbol("SWAP_SIGN", "store_items", image)
        inst.costimagename = image
    else
        inst.costimagename = ""
        inst.AnimState:ClearOverrideSymbol("SWAP_COST")
    end
end 

local function SpawnInventory(inst, prefabtype, costprefab, cost)
    inst.costprefab = costprefab
    inst.cost = cost

    local item = nil
    if prefabtype ~= nil then
        item = SpawnPrefab(prefabtype)
    else
        item = SpawnPrefab(inst.prefabtype)
    end

    if item ~= nil then 
        inst:SetImage(item)
        inst:SetCost(costprefab,cost)
        inst.components.shopdispenser:SetItem(item)
        item:Remove()

    end
end 


local function TimedInventory(inst, prefabtype)
    inst.prefabtype = prefabtype 
    local time = 300 + math.random() * 300
    inst.components.shopdispenser:RemoveItem()
    inst:SetImage(nil)
    inst:DoTaskInTime(time, function() inst:SpawnInventory(nil) end)
end 

local function SoldItem(inst)
    inst.components.shopdispenser:RemoveItem()
    inst:SetImage(nil)
end

local function restock(inst,force)
    if inst:HasTag("nodailyrestock") then
        print("NO DAILY RESTOCK")
        return
    elseif inst:HasTag("robbed") then
        inst.costprefab = "cost-nil"
        SetCost(inst, "cost-nil")    
        shopkeeper_speech(inst,STRINGS.CITY_PIG_SHOPKEEPER_ROBBED[math.random(1,#STRINGS.CITY_PIG_SHOPKEEPER_ROBBED)])
    elseif (inst:IsInLimbo() and (inst.imagename == "" or math.random()<0.16 ) and not inst:HasTag("justsellonce")) or force then
        print("CHANGING ITEM")
        local newproduct = inst.components.shopped.shop.components.shopinterior:GetNewProduct(inst.components.shopped.shoptype)
        if inst.saleitem then
            newproduct = inst.saleitem
        end
        SpawnInventory(inst, newproduct[1],newproduct[2],newproduct[3])        
    end
end


local function displaynamefn(inst)
    return "whatever"
end

local function onsave(inst, data)    
    data.imagename = inst.imagename
    data.costprefab = inst.costprefab
    data.cost = inst.cost
    data.interiorID = inst.interiorID
    data.startAnim = inst.startAnim 
    data.saleitem = inst.saleitem
    data.justsellonce = inst:HasTag("justsellonce")
    data.nodailyrestock = inst:HasTag("nodailyrestock")
end

local function onload(inst, data)
    if data then
        if data.imagename then
            SetImageFromName(inst, data.imagename)
        end
        if data.cost then
            inst.cost = data.cost
        end             
        if data.costprefab then
           inst.costprefab = data.costprefab
           SetCost(inst, inst.costprefab, inst.cost)
        end     
        if data.interiorID then
            inst.interiorID  = data.interiorID
        end
        if data.startAnim then
            inst.startAnim = data.startAnim
            inst.AnimState:PlayAnimation(data.startAnim)
        end
        if data.saleitem then
            inst.saleitem = data.saleitem
        end
        if data.justsellonce then
            inst:AddTag("justsellonce")
        end     
        if data.nodailyrestock then
            inst:AddTag("nodailyrestock")   
        end
    end
end

local function setobstical(inst)
    local ground = TheWorld
    if ground then
        local pt = Point(inst.Transform:GetWorldPosition())
        ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
    end
end

local function clearobstacle(inst)
    local ground = TheWorld
    if ground then
    	local pt = Point(inst.Transform:GetWorldPosition())
    	ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
    end
end


local function common()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

    local minimap = inst.entity:AddMiniMapEntity()    
    inst.MiniMapEntity:SetIcon( "accomplishment_shrine.png" )

    MakeObstaclePhysics(inst, .25)   

    inst.AnimState:SetBank("pedestal")
    inst.AnimState:SetBuild("pedestal_crate")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    inst:AddTag("shop_pedestal")

    inst.imagename = nil 

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)

    inst.SetImage = SetImage
    inst.SetCost = SetCost
    inst.SetImageFromName = SetImageFromName
    inst.SpawnInventory = SpawnInventory
    inst.TimedInventory = TimedInventory
    inst.shopkeeper_speech = shopkeeper_speech
    inst.SoldItem = SoldItem

    inst.OnSave = onsave 
    inst.OnLoad = onload
    inst.restock = restock

    inst.setobstical = setobstical
	inst:DoTaskInTime(0, function()
							-- defer, our position hasn't been set
						    inst.setobstical(inst)
						end)

    inst.returntointeriorscene = setobstical
   	inst.removefrominteriorscene = clearobstacle

    inst.OnEntityWake = function()
        if TheWorld.components.aporkalypse and TheWorld.components.aporkalypse:GetFiestaActive() then
            inst.AnimState:PlayAnimation("idle_yotp")
        else
            inst.AnimState:PlayAnimation(inst.startAnim)            
        end
    end

    return inst
end


local function buyer()
    local inst = common()
    inst:AddComponent("shopdispenser")
    inst:AddComponent("shopped")

    inst:ListenForEvent("daytime", function() restock(inst) end, TheWorld)
    inst:ListenForEvent("beginfiesta", function() restock(inst,true) end, TheWorld)
    inst:ListenForEvent("endfiesta", function() restock(inst,true) end, TheWorld)
    return inst
end

local function seller()
    local inst = common()
    return inst 
end 

return Prefab( "shop_buyer", buyer, assets, prefabs),
       Prefab("shop_seller", seller, assets, prefabs)
