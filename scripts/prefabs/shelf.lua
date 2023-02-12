local assets =
{
    --Asset("ANIM", "anim/store_items.zip"),
    Asset("ANIM", "anim/room_shelves.zip"),
    Asset("ANIM", "anim/pedestal_key.zip"),
    --Asset("ATLAS_BUILD", "images/inventoryimages.xml", 256),
    --Asset("ATLAS_BUILD", "images/inventoryimages_2.xml", 256),
    Asset("INV_IMAGE", "reno_shelves_wood"),
    Asset("INV_IMAGE", "reno_shelves_basic"),
    Asset("INV_IMAGE", "reno_shelves_cinderblocks"),
    Asset("INV_IMAGE", "reno_shelves_marble"),
    Asset("INV_IMAGE", "reno_shelves_glass"),
    Asset("INV_IMAGE", "reno_shelves_ladder"),
    Asset("INV_IMAGE", "reno_shelves_hutch"),
    Asset("INV_IMAGE", "reno_shelves_industrial"),
    Asset("INV_IMAGE", "reno_shelves_adjustable"),
    Asset("INV_IMAGE", "reno_shelves_midcentury"),
    Asset("INV_IMAGE", "reno_shelves_wallmount"),
    Asset("INV_IMAGE", "reno_shelves_aframe"),
    Asset("INV_IMAGE", "reno_shelves_crates"),
    Asset("INV_IMAGE", "reno_shelves_fridge"),
    Asset("INV_IMAGE", "reno_shelves_floating"),
    Asset("INV_IMAGE", "reno_shelves_pipe"),
    Asset("INV_IMAGE", "reno_shelves_hattree"),
    Asset("INV_IMAGE", "reno_shelves_pallet"),
    Asset("INV_IMAGE", "pedestal_key"),    

    Asset("MINIMAP_IMAGE", "shelf_ruins"),
}

local prefabs =
{
--    "minisign_item",
--    "minisign_drawn",
    "shelf_slot",
}

local function onopen(inst) 
	if not inst:HasTag("burnt") then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
	end
end

local function onclose(inst)
	if not inst:HasTag("burnt") then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
	end
end


local function smash(inst)
    if inst.components.lootdropper then
        local interiorSpawner = TheWorld.components.interiorspawner 
        if interiorSpawner.current_interior then
            local originpt = interiorSpawner:GetSpawnOrigin()
            local x, y, z = inst.Transform:GetWorldPosition()
            local dropdir = Vector3(originpt.x - x, 0.0, originpt.z - z):GetNormalized()
            inst.components.lootdropper.lootdropangle = 0
			inst.components.lootdropper.lootdroparc = 90
            inst.components.lootdropper:DropLoot()
        end
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    if inst.SoundEmitter then
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    end

    if inst.shelves and #inst.shelves > 0 then
        for i, v in ipairs(inst.shelves)do           
            v.empty(v)
            v:Remove()
        end
    end

    inst:Remove()
end    

local function setPlayerUncraftable(inst)
    inst:AddTag("playercrafted") 

    inst:RemoveTag("NOCLICK")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper.lootdropangle = 180
    inst.components.lootdropper.lootdroparc = 90
    
    inst.entity:AddSoundEmitter()
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(
        function(inst, worker, workleft)
            if workleft <= 0 then
                smash(inst)
            end
        end)
end

local function onBuilt(inst)
    setPlayerUncraftable(inst)
    inst.onbuilt = true         
end

local function SetImage(inst, ent, slot)
    local src = ent 
    local image = nil 

    if ent.shelfart then
        image = ent.shelfart
    elseif src ~= nil and src.components.inventoryitem ~= nil then
        image = #(ent.components.inventoryitem.imagename or "") > 0 and
            ent.components.inventoryitem.imagename or
            ent.prefab
    end 

    if image ~= nil then 
        local texname = image..".tex"
        inst.AnimState:OverrideSymbol(slot, GetInventoryItemAtlas(texname), texname)
        --inst.AnimState:OverrideSymbol("SWAP_SIGN", "store_items", image)
        inst.imagename = src ~=nil or ""
    else
        inst.imagename = ""
        inst.AnimState:ClearOverrideSymbol(slot)
    end
end 

local function SetImageFromName(inst, name, slot)
    --print("HERE 2?")
    local image = name

    if image ~= nil then 
        local texname = image..".tex"
        inst.AnimState:OverrideSymbol(slot, GetInventoryItemAtlas(texname), texname)
        --inst.AnimState:OverrideSymbol("SWAP_SIGN", "store_items", image)
        inst.imagename = image
    else
        inst.imagename = ""
        inst.AnimState:ClearOverrideSymbol(slot)
    end
end 

local function displaynamefn(inst)
    return "whatever"
end

local function spawnshelfslots(inst)
    inst.shelves = {}
    for i = 1, inst.size do
        local object = SpawnPrefab("shelf_slot")   
		object.components.shelfer.slotindex = i
        if inst.swp_img_list then
            object.components.inventoryitem:PutOnShelf(inst, inst.swp_img_list[i])
            object.components.shelfer:SetShelf(inst, inst.swp_img_list[i])            
        else                     
            object.components.inventoryitem:PutOnShelf(inst,"SWAP_img"..i)
            object.components.shelfer:SetShelf(inst, "SWAP_img"..i)            
        end
        table.insert(inst.shelves, object)
	end
end

local function spawnchildren(inst)
    if not inst.childrenspawned then
		spawnshelfslots(inst)
        for i = 1, inst.size do
			local object = inst.shelves[i]
            if inst.shelfitems then
                for index,set in pairs(inst.shelfitems)do
                    if set[1] == i then
                        local item = SpawnPrefab(set[2])
                        if item then
                            object.components.shelfer:AcceptGift(nil, item)
                        end
                    end
                end
            end
        end
        inst.childrenspawned = true
    end
end

local lock -- forward declare

-- update interactibility of shelf and slots
local function CheckAllowActionOnCabinet(inst)
	local useController = TheInput:ControllerAttached()
	if useController then
		-- Okay, this will be a problem if we get shelves with one slot that are playercrafted (and thus hammerable)
		-- Single slot cabinets don't use the container UI (seemed silly), so they player interacts with the slot directly and the shelf is non-interactable
		-- If this becomes an issue the single slot version will have to use the container UI as well, or the shelf-slot will have to also take on the role of the
		-- shelf in displaying other prompts.
		local isLocked = inst.components.lock and inst.components.lock:IsLocked()
		local singleSlot = inst.components.container.numslots == 1
		local canInteractWithCabinet = isLocked or not singleSlot
		if canInteractWithCabinet then
		    inst:RemoveTag("NOCLICK")
			if inst.shelves then
				for i,v in pairs(inst.shelves) do
					v:AddTag("NOCLICK")
				end
			end
		else
		    inst:AddTag("NOCLICK")
			if inst.shelves then
				for i,v in pairs(inst.shelves) do
					v:RemoveTag("NOCLICK")
				end
			end
		end
		inst.components.container.canbeopened = not isLocked
	else
		local isLocked = inst.components.lock and inst.components.lock:IsLocked()
		local isHammerable = inst:HasTag("playercrafted")
		local canInteractWithCabinet = isLocked or isHammerable
		if canInteractWithCabinet then
		    inst:RemoveTag("NOCLICK")
		else
		    inst:AddTag("NOCLICK")
		end
		-- shelf-slots are always interactable with mouse
	    if inst.shelves then
			for i,v in pairs(inst.shelves) do
				v:RemoveTag("NOCLICK")
			end
		end
		-- mouse never uses the container interface
		inst.components.container.canbeopened = false
	end
end

local function unlock(inst, key, doer, skipsound) 	-- skipsound is optional, defaults to true
	local playsound = not skipsound

    inst.AnimState:Hide("LOCK")
	if playsound then
	    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/royal_gallery/unlock") 
	end
    if inst.shelves then
        for i,object in ipairs(inst.shelves) do      
            object.components.shelfer:Enable()
        end 
    end
	inst.components.container.canbeopened = true
	CheckAllowActionOnCabinet(inst)
end

-- ugly syntax because of forward declare
lock = function(inst)
    inst.AnimState:Show("LOCK") 
    if inst.shelves then
        for i,object in ipairs(inst.shelves) do      
            object.components.shelfer:Disable()      
        end    
    end
	inst.components.container.canbeopened = false
	CheckAllowActionOnCabinet(inst)
end

local function onsave(inst, data)    
    if inst.childrenspawned then
        data.childrenspawned = inst.childrenspawned
    end
    data.rotation = inst.Transform:GetRotation()    
    if inst.onbuilt then
        data.onbuilt = inst.onbuilt
    end     
    if inst:HasTag("playercrafted") then
        data.playercrafted = true
    end    

--    data.locked = inst.locked
end

local function onload(inst, data)
    if data.rotation then
        inst.Transform:SetRotation(data.rotation)
    end    
    if data.childrenspawned then
        inst.childrenspawned = data.childrenspawned
    end
    if data.onbuilt then
        setPlayerUncraftable(inst)
        inst.onbuilt = data.onbuilt
    end     
    if data.playercrafted then
        inst:AddTag("playercrafted")
    end    
    if data.locked then
        lock(inst)
    else
        unlock(inst,nil,nil,true)
    end
end

local function onloadpostpass(inst, ents, data)
	if not inst:HasTag("INTERIOR_LIMBO") then
		spawnshelfslots(inst)

		-- put the container items in there
		for i,v in pairs(inst.shelves) do
			local item = inst.components.container:GetItemInSlot(i)		
			if item then
				v.components.shelfer:UpdateGift(nil, item)
			end
		end
	end
end  

local function docurse(inst)
    if math.random() < 0.3 then
        local ghost = SpawnPrefab("pigghost")
        local pt = Vector3(inst.Transform:GetWorldPosition())
        ghost.Transform:SetPosition(pt.x,pt.y,pt.z)
    end
end

local function onitemgetfn(inst,data)
	if inst.shelves then
		local shelf = inst.shelves[data.slot]
		shelf.components.shelfer:UpdateGift(data.owner, data.item)
	end
end

local function onitemlosefn(inst,data)
	if inst.shelves then
		local shelf = inst.shelves[data.slot]
		-- tell the shelf_slot to stop tracking this
		shelf.components.shelfer:GiveGift()
	end
end

local function itemtestfn(inst, item, slot) 
	local inventoryitem = item.components.inventoryitem
	local owner = inventoryitem and inventoryitem.owner						
	if inst.shelves then
		if slot then
			local shelf = inst.shelves[slot]
			return shelf and shelf.components.shelfer:CanAccept(item, owner)
		else
			for i,shelf in pairs(inst.shelves) do
				if shelf.components.shelfer:CanAccept(item, owner) then
					return true
				end
			end
			return false
		end
	end
	-- during load
	return true
end

local function testcontrollermodefn(inst)
	local useController = TheInput:ControllerAttached()
	if useController ~= inst.useController then
		CheckAllowActionOnCabinet(inst)
		inst.useController = useController
	end
end

local function OnRemove(inst)
	inst:RemoveEventCallback("controllermode_changed", inst.testcontrollermodefn, TheWorld)
end

local function OnReturn(inst)
	testcontrollermodefn(inst)
	inst:ListenForEvent("controllermode_changed", inst.testcontrollermodefn, TheWorld)
end

function handlelock(inst)
	if inst.components.lock then
		local locked = inst.components.lock:IsLocked()
		if locked then
			lock(inst)
		else
			unlock(inst,nil,nil,true)
		end
	end
end

local function returntointeriorscene(inst)
	spawnshelfslots(inst)	

	-- put the container items in there
	for i,v in pairs(inst.shelves) do
		local item = inst.components.container:GetItemInSlot(i)		
		if item then
			v.components.shelfer:UpdateGift(nil, item)
		end
	end

	handlelock(inst)
end

local function makeobstacle(inst)
	-- print('makeobstacle walls.lua')
    local ground = TheWorld
    if ground then
    	local pt = Point(inst.Transform:GetWorldPosition())
		--print("    at: ", pt)
    	ground.Pathfinder:AddWall(pt.x, pt.y, pt.z-1)
    	ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
    	ground.Pathfinder:AddWall(pt.x, pt.y, pt.z+1)
    end
end

local function clearobstacle(inst)

    local ground = TheWorld
    if ground then
    	local pt = Point(inst.Transform:GetWorldPosition())
    	ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z-1)
    	ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
    	ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z+1)
    end
end

local function common(setsize,swp_img_list, locked, physics_round)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    local anim = inst.entity:AddAnimState()
	
    local size = setsize or 6

    if physics_round then
        MakeObstaclePhysics(inst, .5)
    else
        MakeInteriorPhysics(inst, 1.6, 1, 0.2)
		inst:DoTaskInTime(0, makeobstacle)
	    inst.returntointeriorscene = makeobstacle
    	inst.removefrominteriorscene = clearobstacle
    end 

    --inst.AnimState:SetOrientation(ANIM_ORIENTATION.RotatingBillboard)

    inst:AddTag("NOCLICK")
    inst:AddTag("wallsection")
    inst:AddTag("furniture")    

    anim:SetBuild("room_shelves")
    anim:SetBank("bookcase")
    anim:PlayAnimation("wood", false)

    inst.Transform:SetRotation(-90)

    inst.imagename = nil 

    inst.SetImage = SetImage
    inst.SetImageFromName = SetImageFromName

    inst.swp_img_list = swp_img_list
    inst.size = setsize or 6
    if swp_img_list then
        for i=1,size do
            SetImageFromName(inst, nil, swp_img_list[i])
        end
    else
        for i=1,size do
            SetImageFromName(inst, nil, "SWAP_img"..i)
        end
    end
   
    inst:ListenForEvent( "onbuilt", function()
        onBuilt(inst)
    end)        

    inst.locked = locked
   

    inst.OnSave = onsave 
    inst.OnLoad = onload
    inst.OnLoadPostPass = onloadpostpass
    inst.lock = lock
    inst.unlock = unlock

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end


    inst:DoTaskInTime(0, function() 
        if inst:HasTag("playercrafted") then
            setPlayerUncraftable(inst)
        end

        spawnchildren(inst) 
		handlelock(inst)
		OnReturn(inst)	-- to update the NOCLICK tag based on controller mode
    end)

	inst:AddComponent("container")
	local slotpos = {}

	local animname = "ui_icepack_2x3"
	if inst.size == 6 then
		slotpos[1] = Vector3(-165,-80,0)
		slotpos[2] = Vector3(-85,-80,0)
		slotpos[3] = Vector3(-165,0,0)
		slotpos[4] = Vector3(-85, 0, 0)
		slotpos[5] = Vector3(-165,80,0)
		slotpos[6] = Vector3(-85, 80, 0)
	elseif inst.size == 3 then
		-- 3 slots
		slotpos[1] = Vector3(-85+20,0,0)
		slotpos[2] = Vector3(-85+20,-80,0)
		slotpos[3] = Vector3(-85+20,80,0)
	else
		-- single slot containers won't really use the interface, but need to know number of slots
		slotpos[1] = Vector3(0,0,0)
	end
	
	inst.components.container:SetNumSlots(#slotpos)

	-- so that we can discern this from a regular container
	inst.components.container.isshelf = inst

	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose

	-- 2x3
	if inst.size == 6 then
		inst.components.container.widgetslotpos = slotpos
		inst.components.container.widgetanimbank = animname
		inst.components.container.widgetanimbuild = animname
		inst.components.container.widgetpos = Vector3(70, 200, 0)
		inst.components.container.side_align_tip = 0
		inst.components.container.acceptsstacks = false
	else
		-- 1x3. 1x1 gets special treatment
		inst.components.container.widgetslotpos = slotpos
		inst.components.container.widgetanimbank = animname
		inst.components.container.widgetanimbuild = animname
		inst.components.container.widgetpos = Vector3(30, 200, 0)
		inst.components.container.side_align_tip = 0
		inst.components.container.hscale = 0.5
		inst.components.container.acceptsstacks = false
	end

	inst.components.container.itemtestfn = itemtestfn

	inst:ListenForEvent("itemget", onitemgetfn, inst)
	inst:ListenForEvent("itemlose", onitemlosefn, inst)

	inst.testcontrollermodefn = function()
									testcontrollermodefn(inst)
								end

    inst:ListenForEvent("enterlimbo", OnRemove)
    inst:ListenForEvent("exitlimbo", OnReturn)

	inst.returntointeriorscene = returntointeriorscene

    return inst
end

local function wood()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("wood", false)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function basic()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("basic", false)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function marble()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("marble", false)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function metal()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("metalcrates", false)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end


local function glass()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("glass", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function ladder()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("ladder", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function hutch()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("hutch", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function industrial()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("industrial", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function adjustable()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("adjustable", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function fridge()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("fridge", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function cinderblocks()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("cinderblocks", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function midcentury()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("midcentury", false)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)   
    return inst
end

local function wallmount()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("wallmount", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function aframe()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("aframe", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function crates()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("crates", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function hooks()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("hooks", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function pipe()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("pipe", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function hattree()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("hattree", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function pallet()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("pallet", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function floating()
    local inst = common()
    local anim = inst.AnimState
    anim:PlayAnimation("floating", false) 
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)  
    return inst
end

local function display()
    local inst = common(3,nil,nil,true)
    local anim = inst.AnimState

    anim:SetBuild("room_shelves")
    anim:SetBank("bookcase")    
    anim:PlayAnimation("displayshelf_wood", false) 

	inst.name = STRINGS.NAMES.SHELVES_DISPLAYCASE

    return inst
end

local function display_metal()
    local inst = display()
    local anim = inst.AnimState
    anim:PlayAnimation("displayshelf_metal", false) 
    return inst
end

local function ruins()
    local inst = common(1,nil,nil,true)
    local anim = inst.AnimState

    local minimap = inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("shelf_ruins.png")

    anim:SetBuild("room_shelves")
    anim:SetBank("bookcase")    
    anim:PlayAnimation("ruins", false) 

    inst.curse = docurse
    return inst
end

local function queen_display_common(size,list)
    local inst = common(size,list,true,true)
    local anim = inst.AnimState

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "royal_gallery"
    inst.name = STRINGS.NAMES.ROYAL_GALLERY  
       
    inst:RemoveTag("NOCLICK")

    inst:AddComponent("lock")
    inst.components.lock.locktype = "royal gallery"    
    inst.components.lock:SetOnUnlockedFn(unlock)    
    inst.components.lock:SetOnLockedFn(lock)    
	inst.components.lock:Lock()
    

    anim:SetBuild("pedestal_crate")
    anim:SetBank("pedestal")    
    return inst
end

local function queen_display1()
    local inst = queen_display_common(1,{"SWAP_SIGN"})
    local anim = inst.AnimState
  
    anim:PlayAnimation("lock19_east", false) 
    return inst
end

local function queen_display2()
    local inst = queen_display_common(1,{"SWAP_SIGN"})
    local anim = inst.AnimState
  
    anim:PlayAnimation("lock17_east", false) 
    return inst
end

local function queen_display3()
    local inst = queen_display_common(1,{"SWAP_SIGN"})
    local anim = inst.AnimState
  
    anim:PlayAnimation("lock12_west", false) 
    return inst
end

local function queen_display4()
    local inst = queen_display_common(1,{"SWAP_SIGN"})
    local anim = inst.AnimState
  
    anim:PlayAnimation("lock12_west", false) 
    return inst
end


local function key()    
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("pedestal_key")
    inst.AnimState:SetBuild("pedestal_key")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("key")
    inst.components.key.keytype = "royal gallery" 
    
    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inventoryitem")
    inst:AddComponent("tradable")

    return inst
end

return  Prefab("shelves_wood", wood, assets, prefabs),
        Prefab("shelves_basic", basic, assets, prefabs),
        Prefab("shelves_marble", marble, assets, prefabs),
        Prefab("shelves_glass", glass, assets, prefabs),
        Prefab("shelves_ladder", ladder, assets, prefabs),
        Prefab("shelves_hutch", hutch, assets, prefabs),
        Prefab("shelves_industrial", industrial, assets, prefabs),
        Prefab("shelves_adjustable", adjustable, assets, prefabs),
        Prefab("shelves_fridge", fridge, assets, prefabs), 
        Prefab("shelves_cinderblocks", cinderblocks, assets, prefabs),
        Prefab("shelves_midcentury", midcentury, assets, prefabs),
        Prefab("shelves_wallmount", wallmount, assets, prefabs),
        Prefab("shelves_aframe", aframe, assets, prefabs),
        Prefab("shelves_crates", crates, assets, prefabs),
        Prefab("shelves_hooks", hooks, assets, prefabs),
        Prefab("shelves_pipe", pipe, assets, prefabs),
        Prefab("shelves_hattree", hattree, assets, prefabs),
        Prefab("shelves_pallet", pallet, assets, prefabs),
        Prefab("shelves_floating", floating, assets, prefabs),
        Prefab("shelves_displaycase", display, assets, prefabs),
        Prefab("shelves_displaycase_metal", display_metal, assets, prefabs),
        Prefab("shelves_queen_display_1", queen_display1, assets, prefabs),
        Prefab("shelves_queen_display_2", queen_display2, assets, prefabs),
        Prefab("shelves_queen_display_3", queen_display3, assets, prefabs),
        Prefab("shelves_queen_display_4", queen_display4, assets, prefabs),

        Prefab("shelves_ruins", ruins, assets, prefabs),

        Prefab("pedestal_key",key,assets,prefabs),
        Prefab("shelves_metal", metal, assets, prefabs)