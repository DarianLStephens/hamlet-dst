INTERIORPLACERS = {}
local PLACE_OFFSET = 3.25
local function placer_onupdatetransform(inst)
    local pos = inst:GetPosition()
    for i, pillar in ipairs(inst.pillars) do
        local pillarpos = pillar:GetPosition()
        if distsq(pillarpos.x, pillarpos.z, pos.x, pos.z) < 2 then
            inst.Transform:SetPosition(pillarpos.x, pillarpos.y, pillarpos.z)      
            
            inst.AnimState:SetScale(pillar.flip and -1 or 1,1,1)
            inst.AnimState:PlayAnimation(pillar.far and inst.data.far or inst.data.anim)
            
            inst.accept_placement = true
            return
        end
        inst.accept_placement = false
    end
end

local function placer_override_build_point(inst)
    return inst:GetPosition()
end

local function placer_override_testfn(inst)
    local can_build, mouse_blocked = true, false

    if inst.components.placer.testfn ~= nil then
        can_build, mouse_blocked = inst.components.placer.testfn(inst:GetPosition(), inst:GetRotation())
    end

    can_build = can_build and inst.accept_placement

    return can_build, mouse_blocked
end

local function SpawnPillar(inst, data, flip, far)
    local placer = CreateEntity()

    --[[Non-networked entity]]
    placer.entity:SetCanSleep(false)
    placer.persists = false

    placer.entity:AddTransform()
    placer.entity:AddAnimState()

    placer:AddTag("CLASSIFIED")
    placer:AddTag("NOCLICK")
    placer:AddTag("placer")
    placer:AddTag("pillarplacer")

    placer.AnimState:SetBank(inst.data.bank)
    placer.AnimState:SetBuild(inst.data.build)    
    placer.AnimState:PlayAnimation(far and inst.data.far or inst.data.anim)
    placer.AnimState:SetLightOverride(1)
    placer.AnimState:UsePointFiltering(true)
    
    local color = Vector3(.25*0.1, .75*0.1, .25*0.1)
    placer.AnimState:SetAddColour(color.x, color.y, color.z, 1)
    placer.AnimState:SetMultColour(0.5, 0.5, 0.5, 0.5)

    placer.flip = flip
    placer.far = far

    if flip then
        placer.AnimState:SetScale(-1,1,1)
    end

    return placer
end

local function WallPostInitFn(inst)
    inst.pillars = {}
    local pt = inst:GetPosition()
    inst:DoTaskInTime(0, function()
        local interior = ThePlayer.replica.interiorplayer
        if interior then
            local width = interior.interiorwidth:value()
            local depth = interior.interiordepth:value()
            local originpt = {x = interior.camx:value(), z = interior.camz:value()}

            local dMax = originpt.x + (depth + PLACE_OFFSET)/2
            local dMin = originpt.x - (depth - PLACE_OFFSET)/2 

            local wMax = originpt.z + width/2
            local wMin = originpt.z - width/2

            local pts = {}
            table.insert(pts, {coord=Vector3(dMax, 0, wMax), billboard=true})
            table.insert(pts, {coord=Vector3(dMin, 0, wMax), billboard=true})
            table.insert(pts, {coord=Vector3(dMax, 0, wMin), billboard=true})
            table.insert(pts, {coord=Vector3(dMin, 0, wMin), billboard=true})

            for i, subpt in ipairs(pts) do         
                local pillar = SpawnPillar(inst, inst.data, subpt.coord.z > originpt.z, subpt.coord.x < originpt.x)
                pillar.Transform:SetPosition(subpt.coord.x, subpt.coord.y, subpt.coord.z)

                table.insert(inst.pillars, pillar)
                inst:ListenForEvent("onremove", function() pillar:Remove() end)
            end
        end
    end)

    inst.components.placer.onupdatetransform = placer_onupdatetransform
    inst.components.placer.override_build_point_fn = placer_override_build_point

    inst.components.placer.override_testfn = placer_override_testfn

    inst.accept_placement = false
end

function _G.MakePillarPlacer(name, bank, build, anim, data)
	--return MakePlacer(name, bank, build, anim, nil, nil, nil, nil, nil, nil, nil, nil, nil, TestPillarFn, ModifyPillarFn, PrePillarFn),
    return MakePlacer(name, bank, build, anim, nil, nil, nil, nil, nil, nil, function(inst) 
        inst.data = {
            bank = bank,
            build = build,
            anim = anim,
            far = data.far,
        }
        WallPostInitFn(inst) 
    end)
end

function _G.MakePillarBuilder(name, near, far)
    table.insert(INTERIORPLACERS, name)
	local function OnBuilt(inst, builder)
        local pos = inst:GetPosition()
        local interior = ThePlayer.replica.interiorplayer
        if interior then
            local originpt = {x = interior.camx:value(), z = interior.camz:value()}

            local pillar = SpawnAt(pos.x > originpt.x and near or far, inst)
            if pos.z > originpt.z then
                pillar.flipped = true
                pillar.AnimState:SetScale(-1,1,1)
            end
            pillar:OnBuiltFn()
        end
		inst:Remove()
	end
	
	return Prefab(name, function(inst)
		local inst = CreateEntity()

		inst.entity:AddTransform()
	
		inst:AddTag("CLASSIFIED")
	
		--[[Non-networked entity]]
		inst.persists = false
	
		--Auto-remove if not spawned by builder
		inst:DoTaskInTime(0, inst.Remove)
	
		if not TheWorld.ismastersim then
			return inst
		end
	
		inst.OnBuiltFn = OnBuilt
	
		return inst
	end)
end

local function FurnitureOnUpdate(inst)
    local pt = inst:GetPosition()
    local interior = ThePlayer.replica.interiorplayer
    if interior then
        local width = interior.interiorwidth:value()
        local depth = interior.interiordepth:value()
        local originpt = {x = interior.camx:value(), z = interior.camz:value()}

        local dMax = originpt.x + depth/2
        local dMin = originpt.x - depth/2

        local wMax = originpt.z + width/2
        local wMin = originpt.z - width/2 

        local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 2, nil, {"player", "fx", "NOBLOCK"}) -- {"furniture"}

        for i,ent in pairs(ents)do
            if ent == inst or (ent.components.inventoryitem and ent.components.inventoryitem.owner) then
                ents[i] = nil            
            end
        end

        if #ents < 1 then
            inst.accept_placement = true
            return true
        end   
    end
    inst.accept_placement = false
end

local function FurniturePostInitFn(inst)
    inst.components.placer.onupdatetransform = FurnitureOnUpdate
    inst.components.placer.override_build_point_fn = placer_override_build_point

    inst.components.placer.override_testfn = placer_override_testfn

    inst.accept_placement = false
end

function _G.MakeFurniturePlacer(name, bank, build, anim, data)
    return MakePlacer(name, bank, build, anim, nil, nil, nil, nil, nil, nil, FurniturePostInitFn)
end

local function CeilingLightOnUpdate(inst)
    local pt = inst:GetPosition()
    local interior = ThePlayer.replica.interiorplayer
    if interior then
        local width = interior.interiorwidth:value()
        local depth = interior.interiordepth:value()
        local originpt = {x = interior.camx:value(), z = interior.camz:value()}

        local dMax = originpt.x + depth/2
        local dMin = originpt.x - depth/2

        local wMax = originpt.z + width/2
        local wMin = originpt.z - width/2 

        local dist = inst.data and inst.data.distance or 3

        local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 2, {"centerlight"})
        local inbounds = true

        if pt.x < dMin+1 or pt.x > dMax -1 or pt.z < wMin+1 or pt.z > wMax-1 then
            inbounds = false
        end

        if inbounds and #ents < 1 then
            inst.accept_placement = true
            return
        end   
        inst.accept_placement = false
        return
    end
    inst.accept_placement = false
end

local function CeilingLightPostInitFn(inst)
    if inst.parent then
        local px, py, pz = inst.Transform:GetWorldPosition()
        inst.parent:RemoveChild(inst)
        inst.Transform:SetPosition(px,py,pz)
    end

    --inst.AnimState:SetOrientation(ANIM_ORIENTATION.RotatingBillboard)  
    inst.Transform:SetRotation(-90)   

    inst.components.placer.onupdatetransform = CeilingLightOnUpdate
    inst.components.placer.override_build_point_fn = placer_override_build_point

    inst.components.placer.override_testfn = placer_override_testfn

    inst.accept_placement = false
end

function _G.MakeCeilingLight(name, bank, build, anim, data)
    return MakePlacer(name, bank, build, anim, nil, nil, nil, nil, nil, nil, CeilingLightPostInitFn)
end

local function RugOnUpdate(inst)
    local pt = inst:GetPosition()
    local interior = ThePlayer.replica.interiorplayer
    if interior then
        local width = interior.interiorwidth:value()
        local depth = interior.interiordepth:value()
        local originpt = {x = interior.camx:value(), z = interior.camz:value()}

        local dMax = originpt.x + depth/2
        local dMin = originpt.x - depth/2

        local wMax = originpt.z + width/2
        local wMin = originpt.z - width/2 

        local dist = inst.data and inst.data.distance or 3

        --local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 2, {"furniture"})

        if pt.x < dMin+dist or pt.x > dMax -dist or pt.z < wMin+dist or pt.z > wMax-dist then
            inst.accept_placement = true
        end
        return
    end
    inst.accept_placement = false
end

local function RugPostInitFn(inst, data)
    local pt = inst:GetPosition()
    
    inst.flipsrotate = true
    inst.Transform:SetRotation(90)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

    inst:DoTaskInTime(0, function()
        if inst.parent then
            local myrot = inst.Transform:GetRotation()
            local px, py, pz = inst.Transform:GetWorldPosition()
            inst.parent:RemoveChild(inst)
            inst.Transform:SetPosition(px,py,pz)
            inst.Transform:SetRotation(myrot)
        end
    
        inst.components.placer.onupdatetransform = RugOnUpdate
        inst.components.placer.override_build_point_fn = placer_override_build_point
    
        inst.components.placer.override_testfn = placer_override_testfn

        inst.accept_placement = false
    end)
end

function _G.MakeRugPlacer(name, bank, build, anim, data)
    return MakePlacer(name, bank, build, anim, nil, nil, nil, nil, nil, nil, function(inst) RugPostInitFn(inst, data) end)
end

local function WallDecoOnUpdate(inst)
    local pt = inst:GetPosition()
    local interior = ThePlayer.replica.interiorplayer
    if interior then
        local width = interior.interiorwidth:value()
        local depth = interior.interiordepth:value()
        local originpt = {x = interior.camx:value(), z = interior.camz:value()}
        
        local dMax = originpt.x + (depth + PLACE_OFFSET)/2
        local dMin = originpt.x - (depth - PLACE_OFFSET)/2

        local wMax = originpt.z + width/2
        local wMin = originpt.z - width/2 

        local dist = 2
        local newpt = {}
        local backdiff =  pt.x < (originpt.x - (depth - PLACE_OFFSET)/2 + dist)
        local frontdiff = pt.x > (originpt.x + (depth + PLACE_OFFSET)/2 - dist)
        local rightdiff = pt.z > (originpt.z + width/2 - dist)
        local leftdiff =  pt.z < (originpt.z - width/2 + dist)

        inst.accept_placement = true
        local side = ""
        local rot = -90
        if backdiff and not rightdiff and not leftdiff then
            newpt = {x= originpt.x - (depth - PLACE_OFFSET) /2, y=0, z=pt.z}
            inst.AnimState:SetScale(1,1,1)
            rot = -90
        elseif rightdiff and not backdiff and not frontdiff then
            newpt = {x= pt.x, y=0, z= originpt.z + width/2}
            side = "_side"
            inst.AnimState:SetScale(-1,1,1)
            rot = 90
        elseif leftdiff and not backdiff and not frontdiff then
            newpt = {x= pt.x, y=0, z= originpt.z - width/2}                                    
            side = "_side"
            inst.AnimState:SetScale(1,1,1)
            rot = -90
        else
            inst.accept_placement = false
        end

        if newpt.x and newpt.y and newpt.z then
            inst.Transform:SetPosition(newpt.x,newpt.y,newpt.z)                  
        end

        if inst.accept_placement then
            inst.Transform:SetRotation(rot)
        end

        inst.AnimState:SetBank(inst.data.bank..side)
        inst.AnimState:PlayAnimation(inst.data.anim)
        inst.Transform:SetRotation(rot)

        local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 7, {"fullwallsection"})
        if #ents > 0 then
            inst.accept_placement = false
        end
        
        dist = inst.data.distance or 3

        ents = TheSim:FindEntities(pt.x, pt.y, pt.z, dist, {"wallsection"})  
        if #ents < 1 and inst.accept_placement then
            inst.accept_placement = true
        end  
    end
end

local function WallDecoPostInitFn(inst, data)
    if inst.parent then
        local px, py, pz = inst.Transform:GetWorldPosition()
        inst.parent:RemoveChild(inst)
        inst.Transform:SetPosition(px,py,pz)
    end

    --inst.AnimState:SetOrientation(ANIM_ORIENTATION.RotatingBillboard)  
    inst.Transform:SetRotation(-90)   

    inst.components.placer.onupdatetransform = WallDecoOnUpdate
    inst.components.placer.override_build_point_fn = placer_override_build_point

    inst.components.placer.override_testfn = placer_override_testfn
end

function _G.MakeWallDecoPlacer(name, bank, build, anim, data)
    table.insert(INTERIORPLACERS, string.sub(name, 0, -8))
    return MakePlacer(name, bank, build, anim, nil, nil, nil, nil, nil, nil, function(inst) 
        inst.data = {
            bank = bank,
            build = build,
            anim = anim,
            distance = data and data.distance,
        }
        WallDecoPostInitFn(inst) 
    end)
end


local function WindowOnUpdate(inst)
    local pt = inst:GetPosition()
    local interior = ThePlayer.replica.interiorplayer
    if interior then
        local width = interior.interiorwidth:value()
        local depth = interior.interiordepth:value()
        local originpt = {x = interior.camx:value(), z = interior.camz:value()}
        
        local dMax = originpt.x + (depth + PLACE_OFFSET)/2
        local dMin = originpt.x - (depth - PLACE_OFFSET)/2

        local wMax = originpt.z + width/2
        local wMin = originpt.z - width/2 

        local dist = 2
        local newpt = {}
        local backdiff =  pt.x < (originpt.x - (depth - PLACE_OFFSET)/2 + dist)
        local frontdiff = pt.x > (originpt.x + (depth + PLACE_OFFSET)/2 - dist)
        local rightdiff = pt.z > (originpt.z + width/2 - dist)
        local leftdiff =  pt.z < (originpt.z - width/2 + dist)

        inst.accept_placement = true
        local side = ""
        local rot = -90
        if backdiff and not rightdiff and not leftdiff then
            newpt = {x= originpt.x - (depth - PLACE_OFFSET) /2, y=0, z=pt.z}
            inst.AnimState:SetScale(1,1,1)
            rot = -90
        elseif rightdiff and not backdiff and not frontdiff then
            newpt = {x= pt.x, y=0, z= originpt.z + width/2}
            side = "_side"
            inst.AnimState:SetScale(-1,1,1)
            rot = 90
        elseif leftdiff and not backdiff and not frontdiff then
            newpt = {x= pt.x, y=0, z= originpt.z - width/2}                                    
            side = "_side"
            inst.AnimState:SetScale(1,1,1)
            rot = -90
        else
            inst.accept_placement = false
        end

        if newpt.x and newpt.y and newpt.z then
            inst.Transform:SetPosition(newpt.x,newpt.y,newpt.z)                  
        end

        if inst.accept_placement then
            inst.Transform:SetRotation(rot)
        end

        inst.AnimState:SetBank(inst.data.bank..side)
        inst.AnimState:PlayAnimation(inst.data.anim)
        inst.Transform:SetRotation(rot)

        local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 7, {"fullwallsection"})
        if #ents > 0 then
            inst.accept_placement = false
        end
        
        dist = inst.data.distance or 3

        ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 3, {"wallsection"})  
        if #ents < 1 and inst.accept_placement then
            inst.accept_placement = true
        end  
    end
end

local function WindowPostInitFn(inst, data)
    if data and data.nocurtain then
        inst.AnimState:Hide("curtain")
    end

    if inst.parent then
        inst.parent:RemoveChild(inst)
    end

    --inst.AnimState:SetOrientation(ANIM_ORIENTATION.RotatingBillboard)  
    inst.Transform:SetRotation(-90)   

    inst.components.placer.onupdatetransform = WindowOnUpdate
    inst.components.placer.override_build_point_fn = placer_override_build_point

    inst.components.placer.override_testfn = placer_override_testfn
end

function _G.MakeWindowPlacer(name, bank, build, anim, data)
    table.insert(INTERIORPLACERS, string.sub(name, 0, -8))
    return MakePlacer(name, bank, build, anim, nil, nil, nil, nil, nil, nil, function(inst) 
        inst.data = {
            bank = bank,
            build = build,
            anim = anim,
            nocurtain = data and data.nocurtain,
        }
        WindowPostInitFn(inst) 
    end)
end

local function ShelfOnUpdate(inst)
    local pt = inst:GetPosition()
    local interior = ThePlayer.replica.interiorplayer
    if interior then
        local width = interior.interiorwidth:value()
        local depth = interior.interiordepth:value()
        local originpt = {x = interior.camx:value(), z = interior.camz:value()}
        local add_offset = PLACE_OFFSET+1.1
        local dMax = originpt.x + (depth + add_offset)/2
        local dMin = originpt.x - (depth - add_offset)/2

        local wMax = originpt.z + width/2
        local wMin = originpt.z - width/2 

        local dist = 2
        local newpt = {}
        local backdiff =  pt.x < (originpt.x - (depth - add_offset)/2 + dist)
        local frontdiff = pt.x > (originpt.x + (depth + add_offset)/2 - dist)
        local rightdiff = pt.z > (originpt.z + width/2 - dist)
        local leftdiff =  pt.z < (originpt.z - width/2 + dist)

        inst.accept_placement = true
        local bank = ""
        local rot = -90
        if backdiff and not rightdiff and not leftdiff then
            newpt = {x= originpt.x - (depth - add_offset)/2, y=0, z=pt.z}
            bank = ""
            rot = -90      
        else
			newpt = pt
            inst.accept_placement = false
        end

        if inst.parent then
            inst.parent:RemoveChild(inst)
        end

        inst.Transform:SetPosition(newpt.x, newpt.y, newpt.z)                    
        if inst.accept_placement then
            inst.Transform:SetRotation(rot)
        end

        local ents = TheSim:FindEntities(newpt.x, newpt.y, newpt.z, 7, {"fullwallsection"})
        if #ents > 0 then
            inst.accept_placement = false
        end        

        local blockeddist = 4
        ents = TheSim:FindEntities(newpt.x, newpt.y, newpt.z, blockeddist, nil, nil, {"furniture", "wallsection"})

        if inst.accept_placement and #ents < 1 then
            inst.accept_placement = true
            return
        end 
        inst.accept_placement = false  
    end
end

local function ShelfPostInitFn(inst)
    inst.components.placer.onupdatetransform = ShelfOnUpdate
    inst.components.placer.override_build_point_fn = placer_override_build_point

    inst.components.placer.override_testfn = placer_override_testfn

    inst.accept_placement = false
end

function _G.MakeShelfPlacer(name, bank, build, anim, data)
    table.insert(INTERIORPLACERS, string.sub(name, 0, -8))
    return MakePlacer(name, bank, build, anim, nil, nil, nil, nil, nil, nil, ShelfPostInitFn)
end

function _G.MakeDoorBuilder(name, bank, build)
    table.insert(INTERIORPLACERS, name)
	local function OnBuilt(inst, builder)
        local pos = inst:GetPosition()
        local interior = ThePlayer.replica.interiorplayer
        local originpt = {x = interior.camx:value(), z = interior.camz:value()}
        local width = interior.interiorwidth:value()
        local depth = interior.interiordepth:value()
        local backdiff =  pos.x < (originpt.x - depth/2 + 2)
        local frontdiff = pos.x > (originpt.x + depth/2 - 2)
        local rightdiff = pos.z > (originpt.z + width/2 - 2)
        local leftdiff =  pos.z < (originpt.z - width/2 + 2)
		
		local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1, {}, {}, {"interiordoor"})
        if #ents >= 1 then
        	for _, ent in pairs(ents) do
        		if ent:HasTag("interiordoor") then
					ent.animdata.bank = bank
					ent.animdata.build = build
					ent.animdata.anim = name.."_open_"..(backdiff and "north" or frontdiff and "south" or rightdiff and "east" or "west")
					
                    ent.AnimState:SetBank(bank)
                    ent.AnimState:SetBuild(build)
					ent.AnimState:PlayAnimation(name.."_open_"..(backdiff and "north" or frontdiff and "south" or rightdiff and "east" or "west"), true)
					
					inst:Remove()
					return
        		end
        	end
        end
		
        inst:Remove()
	end
	
	return Prefab(name, function(inst)
		local inst = CreateEntity()

		inst.entity:AddTransform()
	
		inst:AddTag("CLASSIFIED")
	
		--[[Non-networked entity]]
		inst.persists = false
	
		--Auto-remove if not spawned by builder
		inst:DoTaskInTime(0, inst.Remove)
	
		if not TheWorld.ismastersim then
			return inst
		end
	
		inst.OnBuiltFn = OnBuilt
	
		return inst
	end)
end

local function DoorOnUpdate(inst)
    local pt = inst:GetPosition()
    local interior = ThePlayer.replica.interiorplayer
    if interior then
        local width = interior.interiorwidth:value()
        local depth = interior.interiordepth:value()
        local originpt = {x = interior.camx:value(), z = interior.camz:value()}
        local add_offset = PLACE_OFFSET
        local dMax = originpt.x + (depth + add_offset)/2
        local dMin = originpt.x - (depth - add_offset)/2

        local wMax = originpt.z + width/2
        local wMin = originpt.z - width/2 

        local dist = 2
        local newpt = {}
        local backdiff =  pt.x < (originpt.x - (depth - add_offset)/2 + dist)
        local frontdiff = pt.x > (originpt.x + (depth + add_offset)/2 - dist)
        local rightdiff = pt.z > (originpt.z + width/2 - dist)
        local leftdiff =  pt.z < (originpt.z - width/2 + dist)

        inst.accept_placement = true

        local name = string.gsub(inst.prefab, "_placer", "")

        local rot = -90
        if backdiff and not rightdiff and not leftdiff then
            newpt = { x = originpt.x - (depth - add_offset)/2, y = 0, z = originpt.z }
            inst.AnimState:PlayAnimation(name .. "_open_north")

        elseif frontdiff and not rightdiff and not leftdiff then
        	newpt = { x = originpt.x + (depth + add_offset)/2, y = 0, z = originpt.z }
            inst.AnimState:PlayAnimation(name .. "_open_south")

        elseif rightdiff and not backdiff and not frontdiff then
            newpt = { x = originpt.x+1.5, y = 0, z = originpt.z + width/2 }
            inst.AnimState:PlayAnimation(name .. "_open_west")

        elseif leftdiff and not backdiff and not frontdiff then
            newpt = { x = originpt.x+1.5, y = 0, z = originpt.z - width/2 }
            inst.AnimState:PlayAnimation(name .. "_open_east")
        else
			newpt = pt
            inst.accept_placement = false
        end

        if inst.accept_placement then
            inst.Transform:SetPosition(newpt.x, newpt.y, newpt.z)
            inst.Transform:SetRotation(rot)
        else
            inst.Transform:SetPosition(pt.x, pt.y, pt.z)
        end

        inst.Transform:SetRotation(rot)


        -- local index_x, index_y = 1,1 --interior_spawner:GetCurrentPlayerRoomIndex()
        -- if backdiff and not rightdiff and not leftdiff and index_x == 0 and index_y == -1 then
        --     inst.accept_placement = false
        -- 	return 
        -- end

        local ents = TheSim:FindEntities(newpt.x, newpt.y, newpt.z, 3, {}, {}, {"wallsection", "interiorteleporter", "interiordoor"})
        if #ents >= 1 then
        	for _, ent in pairs(ents) do
				if ent.animdata then
					local anim = string.find(ent.animdata.anim, "_open_north") and string.gsub(ent.animdata.anim, "_open_north", "")
						or string.find(ent.animdata.anim, "_open_south") and string.gsub(ent.animdata.anim, "_open_south", "") 
						or string.find(ent.animdata.anim, "_open_west") and string.gsub(ent.animdata.anim, "_open_west", "")
						or string.find(ent.animdata.anim, "_open_east") and string.gsub(ent.animdata.anim, "_open_east", "")
					if ent:HasTag("interiordoor") and anim ~= name then
						inst.accept_placement = true
						return
					end
				end
        	end
        end

        if #ents < 1 and inst.accept_placement then
            inst.accept_placement = true
            return
        end
        inst.accept_placement = false
    end
end

local function DoorPostInitFn(inst)
    inst.components.placer.onupdatetransform =  DoorOnUpdate
    inst.components.placer.override_build_point_fn = placer_override_build_point

    inst.components.placer.override_testfn = placer_override_testfn

    inst.accept_placement = false
end

function _G.MakeDoorPlacer(name, bank, build, anim, data)
    table.insert(INTERIORPLACERS, string.sub(name, 0, -8))
    return MakePlacer(name, bank, build, anim, nil, nil, nil, nil, nil, nil, function(inst)
        inst.data = {
            bank = bank,
            build = build,
            anim = anim,
            nocurtain = data and data.nocurtain,
        }
        DoorPostInitFn(inst)
    end)
end
