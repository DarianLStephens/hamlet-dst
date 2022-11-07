local assets =
{
    Asset("ANIM", "anim/vamp_bat_entrance.zip"),
	Asset("SOUND", "sound/hound.fsb"),
    Asset("MINIMAP_IMAGE", "vamp_bat_cave"),
}

local prefabs =
{
    "vampirebat", 
    "cave_fern",
}


local function onsave(inst, data)
    if inst:HasTag("spawned_cave") then
        data.spawned_cave = true
    end
end

local function onload(inst, data)
    if data and data.spawned_cave then
        inst:AddTag("spawned_cave")
    end
end


local function getlocationoutofcenter(dist,hole,random,invert)
    local pos =  (math.random()*((dist/2) - (hole/2))) + hole/2    
    if invert or (random and math.random()<0.5) then
        pos = pos *-1
    end
    return pos
end

local function creatInterior(inst)    
    if not inst:HasTag("spawned_cave") then
        local interior_spawner = TheWorld.components.interiorspawner

        local name = "vampirebatcave".. interior_spawner:GetNewID()
        local height = 18
        local width = 26

        local newID = interior_spawner:GetNewID()

        local exterior_door_def = {
            my_door_id = name..newID.."_door",
            target_door_id = name..newID.."_exit",
            target_interior = newID,
        }

        interior_spawner:AddDoor(inst, exterior_door_def)

        local    floortexture = "levels/textures/interiors/batcave_floor.tex"
        local    walltexture =  "levels/textures/interiors/batcave_wall_rock.tex"
        local    minimaptexture = "levels/textures/map_interior/mini_vamp_cave_noise.tex"

        local addprops = {
               --     { name = "batcavemanager", x_offset = 0, z_offset = 0 },


                    { name = "prop_door", x_offset = -height/2, z_offset = 0,  animdata = {minimapicon ="vamp_bat_cave_exit.png", bank = "doorway_cave", build = "bat_cave_door", anim="day_loop", light = true}, 
                            my_door_id = exterior_door_def.target_door_id, target_door_id =exterior_door_def.my_door_id, rotation = -90, angle=0, addtags={"timechange_anims"} },


           --         { name = "prop_door", x_offset = (height/2), z_offset = 0, animdata = {bank ="ant_cave_door", build ="ant_cave_door", anim="south", background=true}, 
           --                     my_door_id = "roc_cave_ENTRANCE1", target_door_id = "roc_cave_EXIT1", rotation = -90, angle=0 },
           --         { name = "prop_door_shadow", x_offset = (height/2), z_offset = 0, animdata = {bank ="ant_cave_door", build ="ant_cave_door", anim="south_floor"}},                                                           
                }


        table.insert(addprops, { name = "deco_cave_cornerbeam", x_offset = -height/2, z_offset =  -width/2, rotation = -90} )
        table.insert(addprops, { name = "deco_cave_cornerbeam", x_offset = -height/2, z_offset =  width/2, rotation = -90, flip=true  } )
        table.insert(addprops, { name = "deco_cave_pillar_side", x_offset = height/2, z_offset =  -width/2, rotation = -90} )
        table.insert(addprops, { name = "deco_cave_pillar_side", x_offset = height/2, z_offset =  width/2, rotation = -90, flip=true  } )        

        table.insert(addprops, { name = "deco_cave_bat_burrow", x_offset = 0, z_offset = 0, rotation = -90 } )

        for i=1,math.random(1,3) do 
            table.insert(addprops, { name = "deco_cave_ceiling_trim", x_offset = -height/2 , z_offset = getlocationoutofcenter(width*0.6, 3, true) } )
        end

        table.insert(addprops, { name = "deco_cave_floor_trim_front", x_offset = height/2, z_offset = -width/4, rotation=-90})
        table.insert(addprops, { name = "deco_cave_floor_trim_front", x_offset = height/2, z_offset = 0, rotation=-90, addtags={"roc_cave_delete_me"}, roc_cave_delete_me = true})
        table.insert(addprops, { name = "deco_cave_floor_trim_front", x_offset = height/2, z_offset = width/4, rotation=-90})

        if math.random()<0.7 then
            table.insert(addprops, { name = "deco_cave_floor_trim_2", x_offset = (math.random()*height*0.5) - height/2*0.5, z_offset = -width/2, rotation=-90})
        end
        if math.random()<0.7 then
            table.insert(addprops, { name = "deco_cave_floor_trim_2", x_offset = (math.random()*height*0.5) - height/2*0.5, z_offset = width/2, rotation=-90, flip=true})        
        end

        if math.random()<0.7 then
            table.insert(addprops, { name = "deco_cave_ceiling_trim_2", x_offset = (math.random()*height*0.5) - height/2*0.5, z_offset = -width/2, rotation=-90})
        end
        if math.random()<0.7 then
            table.insert(addprops, { name = "deco_cave_ceiling_trim_2", x_offset = (math.random()*height*0.5) - height/2*0.5, z_offset = width/2, rotation=-90, flip=true})        
        end

--[[
        for i=1,math.random(1,3) do 
            table.insert(addprops, { name = "deco_cave_floor_trim_front", x_offset = height/2 , z_offset = (math.random()*width) - width/2, rotation=-90})
        end
]]
        if math.random() < 0.5 then
            table.insert(addprops, { name = "deco_cave_beam_room", x_offset = (math.random()*height*0.65) - height/2*0.65 , z_offset = getlocationoutofcenter(width*0.65,7,false,true), rotation = -90 } )
        end
        if math.random() < 0.5 then
            table.insert(addprops, { name = "deco_cave_beam_room", x_offset = (math.random()*height*0.65) - height/2*0.65 , z_offset = getlocationoutofcenter(width*0.65,7), rotation = -90 } )
        end

        table.insert(addprops, { name = "flint", x_offset = getlocationoutofcenter(height*0.65,3,true), z_offset = getlocationoutofcenter(width*0.65,3,true) } )  
        if math.random() < 0.5 then
            table.insert(addprops, { name = "flint", x_offset = getlocationoutofcenter(height*0.65,3,true), z_offset = getlocationoutofcenter(width*0.65,3,true) } )
        end

        table.insert(addprops, { name = "stalagmite", x_offset = getlocationoutofcenter(height*0.65,4,true), z_offset = getlocationoutofcenter(width*0.65,4,true) } )
        if math.random()<0.5 then
            if math.random()<0.5 then
                table.insert(addprops, { name = "stalagmite", x_offset = getlocationoutofcenter(height*0.65,4,true), z_offset = getlocationoutofcenter(width*0.65,4,true) } )
            else
                table.insert(addprops, { name = "stalagmite_tall", x_offset = getlocationoutofcenter(height*0.65,4,true), z_offset = getlocationoutofcenter(width*0.65,4,true) } )
            end
        end
        if math.random()<0.5 then
            table.insert(addprops, { name = "stalagmite_tall", x_offset = getlocationoutofcenter(height*0.65,3,true), z_offset = getlocationoutofcenter(width*0.65,3,true) } )
        end        

        if math.random()<0.5 then
            table.insert(addprops, { name = "deco_cave_stalactite", x_offset = (math.random()*height*0.5) - height*0.5/2, z_offset = getlocationoutofcenter(width,6,true) } )
        end   
        if math.random()<0.5 then
            table.insert(addprops, { name = "deco_cave_stalactite", x_offset = (math.random()*height*0.5) - height*0.5/2, z_offset =  getlocationoutofcenter(width,6,true) } )
        end   
        if math.random()<0.5 then
            table.insert(addprops, { name = "deco_cave_stalactite", x_offset = (math.random()*height*0.5) - height*0.5/2, z_offset =  getlocationoutofcenter(width,6,true) } )
        end   
        if math.random()<0.5 then
            table.insert(addprops, { name = "deco_cave_stalactite", x_offset = (math.random()*height*0.5) - height*0.5/2, z_offset =  getlocationoutofcenter(width,6,true) } )
        end                   

        for i=1,math.random(2,5) do        
            table.insert(addprops, { name = "cave_fern", x_offset = getlocationoutofcenter(height*0.7,3,true), z_offset = getlocationoutofcenter(width*0.7,3,true) } )
        end

--        table.insert(addprops, { name = "vampirebat", x_offset = (math.random()*height*0.7) - height*0.7/2, z_offset = (math.random()*width*0.7) - width*0.7/2 } )

        interior_spawner:CreateRoom("generic_interior", width, 10, height, name, newID, addprops, {}, walltexture, floortexture, minimaptexture, nil, "images/colour_cubes/pigshop_interior_cc.tex", true, nil, "batcave","BAT_CAVE","DIRT", nil, nil, true)        
        inst:AddTag("spawned_cave")
    end        
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    inst.entity:AddSoundEmitter()

	inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "vamp_bat_cave.png" )

	anim:SetBank("vampbat_den")
	anim:SetBuild("vamp_bat_entrance")
	anim:PlayAnimation("idle")

    --inst:AddTag("structure")
    inst:AddTag("houndmound")
    inst:AddTag("batcave")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    -------------------

    inst:AddComponent("door")
    inst.components.door.outside = true

    inst:DoTaskInTime(0, function() 
         creatInterior(inst)
    end)

    inst.OnSave = onsave 
    inst.OnLoad = onload

    ---------------------
    inst:AddComponent("inspectable")
	MakeSnowCovered(inst)
    
	return inst
end

return Prefab( "forest/monsters/vampirebatcave", fn, assets, prefabs ) 