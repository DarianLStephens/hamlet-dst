local PopupDialogScreen = require "screens/popupdialog"

local assets=
{
	Asset("ANIM", "anim/cave_entrance.zip"),
	Asset("ANIM", "anim/ruins_entrance.zip"),
	Asset("ANIM", "anim/cave_exit_rope.zip"),
    Asset("ANIM", "anim/rock_batcave.zip"),

	Asset("MINIMAP_IMAGE", "cave_closed"),
	Asset("MINIMAP_IMAGE", "cave_open"),
	Asset("MINIMAP_IMAGE", "cave_open2"),
	Asset("MINIMAP_IMAGE", "ruins_closed"),
    Asset("MINIMAP_IMAGE", "rock_batcave"),    
}

local prefabs = 
{
	"exitcavelight",
	"roc_nest",
	"roc_nest_tree1",
	"roc_nest_tree2",
	"roc_nest_bush",
	"roc_nest_branch1",
	"roc_nest_branch2",
	"roc_nest_trunk",
	"roc_nest_house",
	"roc_nest_rusty_lamp",

	"roc_nest_egg1",
	"roc_nest_egg2",
	"roc_nest_egg3",
	"roc_nest_egg4",

    "roc_nest_debris1",
    "roc_nest_debris2",
    "roc_nest_debris3",
    
	"roc_cave_light_beam",

}

--dumptable(GetWorld().components.interiorspawner:GetInteriorsByDungeonName("vampirebatcave")[1],1,1,1)

local function findBatCave()
	local interior_spawner = TheWorld.components.interiorspawner
	local interior = nil

	local choices = interior_spawner:GetInteriorsByDungeonNameStart("vampirebatcave")	
	if #choices > 0 then
		interior = choices[math.random(1,#choices)]
	end

	if interior then
		print("FOUND CAVE")		
        for i,item in pairs(interior)do
            print(i,type(item))
        end
        print("end")
	else
		print("&&&&&&&&&&&&&&&&&&&&&&&&&&  NO CAVE FOUND")
	end

	return interior
end

local function GetVerb(inst)
	return STRINGS.ACTIONS.ACTIVATE.SPELUNK
end

local function Open(inst)

    -- inst.AnimState:PlayAnimation("idle_open", true)
    inst.AnimState:PlayAnimation("open", true)
    inst:RemoveComponent("workable")
    inst.open = true
    inst.name = STRINGS.NAMES.CAVE_ENTRANCE_OPEN
	inst:RemoveComponent("lootdropper")
	inst.MiniMapEntity:SetIcon("cave_open.png")

	inst.components.door:checkDisableDoor(false, "plug")
end      

local function OnWork(inst, worker, workleft)
	local pt = Point(inst.Transform:GetWorldPosition())
	if workleft <= 0 then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
		inst.components.lootdropper:DropLoot(pt)
        ProfileStatsSet("cave_entrance_opened", true)
		Open(inst)
	else				
		if workleft < TUNING.ROCKS_MINE*(1/3) then
			inst.AnimState:PlayAnimation("low")
		elseif workleft < TUNING.ROCKS_MINE*(2/3) then
			inst.AnimState:PlayAnimation("med")
		else
			inst.AnimState:PlayAnimation("idle_closed")
		end
	end
end

local function Close(inst)

    inst.AnimState:PlayAnimation("idle_closed", true)

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	inst.components.workable:SetOnWorkCallback(OnWork)
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"rocks", "rocks", "flint", "flint", "flint"})

    inst.name = STRINGS.NAMES.CAVE_ENTRANCE_CLOSED
	-- if SaveGameIndex:GetCurrentMode() == "cave" then
        -- inst.name = STRINGS.NAMES.CAVE_ENTRANCE_CLOSED_CAVE
    -- end   

    inst.open = false

    inst.components.door:checkDisableDoor(true, "plug")
end      


local function GetStatus(inst)
    if inst.open then
        return "OPEN"
    end
end  

local function exitNumbers(room)
    local exits = room.exits
    local total = 0
    for i,exit in pairs(exits) do
        total = total + 1
    end
    if room.entrance1 or room.entrance2 then        
        total = total + 1
    end
    return total
end

local function getlocationoutofcenter(dist,hole,random,invert)
    local pos =  (math.random()*((dist/2) - (hole/2))) + hole/2    
    if invert or (random and math.random()<0.5) then
        pos = pos *-1
    end
    return pos
end


local function mazemaker(inst, dungeondef)

    local interior_spawner = TheWorld.components.interiorspawner
 
    local rooms_to_make = dungeondef.rooms 
    local entranceRoom = nil
    local exitRoom = nil
    local rooms = {} 

    local room = {
        x=0,
        y=0,
        idx = dungeondef.name.."_"..interior_spawner:GetNewID(), 
        exits = {},
        blocked_exits = {},
        entrance1 = true,
    }   

    table.insert(rooms,room)

    while #rooms < rooms_to_make do
        local dir = interior_spawner:GetDir()
        local dir_opposite = interior_spawner:GetDirOpposite() 
        local dir_choice = math.random(#dir)
        local fromroom = rooms[math.random(#rooms)] 

        local fail = false
        -- fail if this direction from the chosen room is blocked
        for i,exit in ipairs(fromroom.blocked_exits) do
            if interior_spawner:GetDir()[dir_choice] == exit then
                fail = true 
            end
        end
        -- fail if this room of the maze is already set up.
        if not fail then
            for i,checkroom in ipairs(rooms)do 
                if checkroom.x == fromroom.x + dir[dir_choice].x and checkroom.y == fromroom.y + dir[dir_choice].y then
                    fail = true
                    break
                end
            end
        end

        if not fail then

            local newroom = {
                x= fromroom.x + dir[dir_choice].x,
                y= fromroom.y + dir[dir_choice].y,
                idx = dungeondef.name.."_"..interior_spawner:GetNewID(), 
                exits = {},
                blocked_exits = {},
            }  

            fromroom.exits[dir[dir_choice]] = {
                target_room = newroom.idx,
        		bank  = "ant_cave_door",
        		build = "ant_cave_door",
                room = fromroom.idx,                                                                                  
            }     

            newroom.exits[dir_opposite[dir_choice]] = {
                target_room = fromroom.idx,
        		bank  = "ant_cave_door",
        		build = "ant_cave_door",
                room = newroom.idx,                
            }           

            if dungeondef.doorvines and math.random() < dungeondef.doorvines then                
                fromroom.exits[dir[dir_choice]].vined = true
                newroom.exits[dir_opposite[dir_choice]].vined = true
            end

            table.insert(rooms,newroom)
        end
    end

    local choices = {}
    local dist = 0
    for i,room in ipairs(rooms) do  
       -- local dir = interior_spawner:GetDir()
        local north_exit_open = not room.exits[interior_spawner:GetNorth()]

        if not north_exit_open then
            print("THIS ROOM'S NORTH EXIT IS USED")
        end

        if math.abs(room.x)+math.abs(room.y) > dist and north_exit_open then
            choices = {}
        end
        if math.abs(room.x)+math.abs(room.y) >= dist and north_exit_open then 
            table.insert(choices,room)
            dist = math.abs(room.x)+math.abs(room.y)
        end            
    end
    print("FOUND THIS MANY PLACES FOR THE EXIT",#choices)

    if not dungeondef.nosecondexit then
        if #choices > 0 then
            choices[math.random(#choices)].entrance2 = true
        end   
    end

    choices = {}
    for i,room in ipairs(rooms) do
        if exitNumbers(room) == 1 then
            table.insert(choices,room)
        end
    end

    local height = 16
    local width = 24

    local exits = {}
    for i,room in ipairs(rooms) do
    	if i > 1 then
	    	local northexitopen = not room.exits[interior_spawner:GetNorth()]
	    	if northexitopen then
	    		table.insert(exits,i)
	    	end
    	end
    end
    local exit = exits[math.random(1,#exits)]

--[[
    rooms[exit].exits[interior_spawner:GetNorth()] = target_room = newroom.idx,
        		bank  = "ant_cave_door",
        		build = "ant_cave_door",
                room = fromroom.idx, 
]]

    for i,room in ipairs(rooms) do   

        local northexitopen = not room.exits[interior_spawner:GetNorth()] and exit ~= i
        local westexitopen = not room.exits[interior_spawner:GetWest()] 
        local southexitopen = not room.exits[interior_spawner:GetSouth()] 
        local eastexitopen = not room.exits[interior_spawner:GetEast()]  

        local addprops = {}

        if exit == i then
        	table.insert(addprops, { name = "cave_exit_roc", x_offset = -height/2, z_offset = 0})
        end

        if room.entrance1 then
            local prefab = { name = "prop_door", x_offset = 0, z_offset = -width/6,  animdata = {minimapicon = nil, bank = "exitrope", build = "cave_exit_rope", anim = "idle_loop"},  --,light = true
                            my_door_id = dungeondef.name.."_EXIT1", target_door_id = dungeondef.name.."_ENTRANCE1", rotation = -90, angle=0  } -- addtags = {"timechange_anims","ruins_entrance"}
            table.insert(addprops, prefab)
            --table.insert(addprops, { name = "lightrays", x_offset = 0, z_offset = 0} )
            table.insert(addprops, { name = "roc_cave_light_beam", x_offset = 0, z_offset = -width/6})
            entranceRoom = room
        end                            

        local roomtype = nil

        local roomtypes = {"stalacmites","stalacmites","glowplants","ferns","mushtree"}
        roomtype = roomtypes[math.random(1,#roomtypes)]

        if i == 1 then
        	roomtype = "stalacmites"
        end

        table.insert(addprops, { name = "deco_cave_cornerbeam", x_offset = -height/2, z_offset =  -width/2, rotation = -90} )
        table.insert(addprops, { name = "deco_cave_cornerbeam", x_offset = -height/2, z_offset =  width/2, rotation = -90, flip=true  } )
        table.insert(addprops, { name = "deco_cave_pillar_side", x_offset = height/2, z_offset =  -width/2, rotation = -90} )
        table.insert(addprops, { name = "deco_cave_pillar_side", x_offset = height/2, z_offset =  width/2, rotation = -90, flip=true  } )        

        for i=1,math.random(1,3) do 
            table.insert(addprops, { name = "deco_cave_ceiling_trim", x_offset = -height/2 , z_offset = getlocationoutofcenter(width*0.6, 3, true) } )
        end


        table.insert(addprops, { name = "deco_cave_floor_trim_front", x_offset = height/2, z_offset = -width/4, rotation=-90})
        if southexitopen then
        	table.insert(addprops, { name = "deco_cave_floor_trim_front", x_offset = height/2, z_offset = 0, rotation=-90})
    	end
        table.insert(addprops, { name = "deco_cave_floor_trim_front", x_offset = height/2, z_offset = width/4, rotation=-90})
 		
        if westexitopen and math.random()<0.7 then
            table.insert(addprops, { name = "deco_cave_floor_trim_2", x_offset = (math.random()*height*0.5) - height/2*0.5, z_offset = -width/2, rotation=-90})
        end

        if eastexitopen and math.random()<0.7 then
            table.insert(addprops, { name = "deco_cave_floor_trim_2", x_offset = (math.random()*height*0.5) - height/2*0.5, z_offset = width/2, rotation=-90, flip=true})        
        end

        if math.random()<0.7 then
            table.insert(addprops, { name = "deco_cave_ceiling_trim_2", x_offset = (math.random()*height*0.5) - height/2*0.5, z_offset = -width/2, rotation=-90})
        end
        if math.random()<0.7 then
            table.insert(addprops, { name = "deco_cave_ceiling_trim_2", x_offset = (math.random()*height*0.5) - height/2*0.5, z_offset = width/2, rotation=-90, flip=true})        
        end

        if math.random() < 0.5 then
            table.insert(addprops, { name = "deco_cave_beam_room", x_offset = (math.random()*height*0.65) - height/2*0.65 , z_offset = getlocationoutofcenter(width*0.65,7,false,true), rotation = -90 } )
        end
        if math.random() < 0.5 then
            table.insert(addprops, { name = "deco_cave_beam_room", x_offset = (math.random()*height*0.65) - height/2*0.65 , z_offset = getlocationoutofcenter(width*0.65,7), rotation = -90 } )
        end
   
        if math.random() < 0.5 then
            table.insert(addprops, { name = "flint", x_offset = getlocationoutofcenter(height*0.65,3,true), z_offset = getlocationoutofcenter(width*0.65,3,true) } )
        end

        if roomtype == "stalacmites" then
			if math.random()<0.3 then
	        	table.insert(addprops, { name = "stalagmite", x_offset = getlocationoutofcenter(height*0.65,4,true), z_offset = getlocationoutofcenter(width*0.65,4,true) } )
	        end
	        if math.random()<0.2 then
	            if math.random()<0.5 then
	                table.insert(addprops, { name = "stalagmite", x_offset = getlocationoutofcenter(height*0.65,4,true), z_offset = getlocationoutofcenter(width*0.65,4,true) } )
	            else
	                table.insert(addprops, { name = "stalagmite_tall", x_offset = getlocationoutofcenter(height*0.65,4,true), z_offset = getlocationoutofcenter(width*0.65,4,true) } )
	            end
	        end
	        if math.random()<0.3 then
	            table.insert(addprops, { name = "stalagmite_tall", x_offset = getlocationoutofcenter(height*0.65,3,true), z_offset = getlocationoutofcenter(width*0.65,3,true) } )
	        end        
	        if math.random()<0.5 then
	            table.insert(addprops, { name = "deco_cave_stalactite", x_offset = (math.random()*height*0.5) - height*0.5/2, z_offset = getlocationoutofcenter(width,6,true) } )
	        end   
	        if math.random()<0.5 then
	            table.insert(addprops, { name = "deco_cave_stalactite", x_offset = (math.random()*height*0.5) - height*0.5/2, z_offset =  getlocationoutofcenter(width,6,true) } )
	        end	        
    	end

        if math.random()<0.5 then
            table.insert(addprops, { name = "deco_cave_stalactite", x_offset = (math.random()*height*0.5) - height*0.5/2, z_offset =  getlocationoutofcenter(width,6,true) } )
        end   
        if math.random()<0.5 then
            table.insert(addprops, { name = "deco_cave_stalactite", x_offset = (math.random()*height*0.5) - height*0.5/2, z_offset =  getlocationoutofcenter(width,6,true) } )
        end                   

 		if roomtype == "ferns" then
	        for i=1,math.random(5,15) do        	            
	            table.insert(addprops, { name = "cave_fern", x_offset = (math.random()*height*0.7) - height*0.7/2, z_offset = (math.random()*width*0.7) - width*0.7/2 } )
	        end
    	end

 		if roomtype == "mushtree" then
 			if math.random() < 0.3 then
		        for i=1,math.random(3,8) do        	            
		            table.insert(addprops, { name = "mushtree_tall", x_offset = (math.random()*height*0.7) - height*0.7/2, z_offset = (math.random()*width*0.7) - width*0.7/2 } )
		        end
	        elseif math.random() < 0.5 then
		        for i=1,math.random(3,8) do        	            
		            table.insert(addprops, { name = "mushtree_medium", x_offset = (math.random()*height*0.7) - height*0.7/2, z_offset = (math.random()*width*0.7) - width*0.7/2 } )
		        end	
	    	else
		        for i=1,math.random(3,8) do        	            
		            table.insert(addprops, { name = "mushtree_small", x_offset = (math.random()*height*0.7) - height*0.7/2, z_offset = (math.random()*width*0.7) - width*0.7/2 } )
		        end		                
	    	end
    	end

 		if roomtype == "glowplants" then
	        for i=1,math.random(4,12) do        	            
	            table.insert(addprops, { name = "flower_cave", x_offset = (math.random()*height*0.7) - height*0.7/2, z_offset = (math.random()*width*0.7) - width*0.7/2 } )
	        end
    	end

        for i=1,math.random(2,5) do        
            table.insert(addprops, { name = "cave_fern", x_offset = getlocationoutofcenter(height*0.7,3,true), z_offset = getlocationoutofcenter(width*0.7,3,true) } )
        end

        local    floortexture = "levels/textures/interiors/batcave_floor.tex"
        local    walltexture =  "levels/textures/interiors/batcave_wall_rock.tex"
        local    minimaptexture = "levels/textures/map_interior/mini_vamp_cave_noise.tex"

        interior_spawner:CreateRoom("generic_interior", width, 10, height, dungeondef.name, room.idx, addprops, room.exits, walltexture, floortexture, minimaptexture, nil, "images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "ruins","RUINS","STONE")        
    end

    return entranceRoom, exitRoom
end

local function initmaze(inst, dungeonname)

    if not inst:HasTag("maze_generated") then

        local dungeondef = {
            name = dungeonname,
            rooms = 6,           
        }

        local entranceRoom, exitRoom = mazemaker(inst, dungeondef)

        local interior_spawner = TheWorld.components.interiorspawner
        local exterior_door_def = {
            my_door_id = dungeondef.name.."_ENTRANCE1",
            target_door_id = dungeondef.name.."_EXIT1",
            target_interior = entranceRoom.idx,
        }
        interior_spawner:AddDoor(inst, exterior_door_def)

        inst:AddTag("maze_generated")
    end    
end

local function patchindoor(inst,interior)
    local interior_spawner = TheWorld.components.interiorspawner
    local ents = nil   
    local pt = nil                     
    for i,prop in ipairs(interior.object_list) do
        print(prop.prefab,prop:HasTag("roc_cave_delete_me"))
        if prop.prefab == "deco_cave_floor_trim_front" then
            local ppt = Vector3(prop.Transform:GetWorldPosition())
            local opt = interior_spawner:GetSpawnStorage()
            if ppt.z == opt.z then
                pt = Vector3(prop.Transform:GetWorldPosition())
                table.remove(interior.object_list,i)
                prop:Remove()                                
                break
            end
        end
    end

    if not pt then
        for i,prop in ipairs(interior.object_list) do
            print(prop.prefab,prop:HasTag("roc_cave_delete_me"))
            if prop.prefab == "deco_cave_floor_trim_front" then
                local ppt = Vector3(prop.Transform:GetWorldPosition())
                local opt = interior_spawner:GetSpawnStorage()
                pt = Vector3(ppt.x,0,opt.z)                                      
                break
                
            end
        end     
    end

    if pt then                   
        local door2 = SpawnPrefab("prop_door")
        door2.Transform:SetPosition(pt.x,pt.y,pt.z)
        door2.AnimState:SetBank("ant_cave_door")
        door2.AnimState:SetBuild("ant_cave_door")  
        door2.Transform:SetRotation(-90)        
        door2.AnimState:PlayAnimation("south")  

        door2.door_data_animstate = "south"
        door2.door_data_bank ="ant_cave_door"
        door2.door_data_build = "ant_cave_door"

        local minimap = door2.entity:AddMiniMapEntity()         
        minimap:SetIcon("ant_cave_door.png")        
        door2.minimapicon = "ant_cave_door.png"                             

        local door = interior_spawner.doors["roc_cave_EXIT2"]
        local data = 
        {
            my_interior_name = interior.unique_name,
            my_door_id = "roc_cave_ENTRANCE2",
            target_door_id = "roc_cave_EXIT2",
            target_interior = door.my_interior_name,
        }           

        door2.door_data_bank = "ant_cave_door"
        door2.door_data_build = "ant_cave_door"
        interior_spawner:AddDoor(door2, data)

        local shadow = SpawnPrefab("prop_door_shadow")
        shadow.Transform:SetPosition(pt.x,pt.y,pt.z)
        shadow.AnimState:SetBank("ant_cave_door")
        shadow.AnimState:SetBuild("ant_cave_door")  
        shadow.Transform:SetRotation(-90)
        shadow.AnimState:PlayAnimation("south_floor")
        
        interior_spawner:PutPropIntoInteriorLimbo(door2,interior,true)
        interior_spawner:PutPropIntoInteriorLimbo(shadow,interior,true)                            
    end
end

local function onsave(inst, data)
    if inst:HasTag("maze_generated") then
        data.maze_generated = true
    end
	data.open = inst.open    
end

local function onload(inst, data)
    if data then  
        if data.maze_generated then
            inst:AddTag("maze_generated")
        end  
    end

	if data and data.open then
		Open(inst)
	end    
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)
    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("cave_closed.png")
    anim:SetBank("cave_entrance")
    anim:SetBuild("cave_entrance")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
	inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("door")
    inst.components.door.outside = true
            
    inst:DoTaskInTime(0, function() initmaze(inst, "roc_cave") end )

    Close(inst)
	inst.OnSave = onsave
	inst.OnLoad = onload

	inst.findBatCave = findBatCave
	
	inst.components.inspectable.nameoverride = "CAVE_ENTRANCE"

    return inst
end


local function exitfn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()    
	
	MakeObstaclePhysics(inst, 1.)
	
	inst.AnimState:SetBank("rock_batcave")
	inst.AnimState:SetBuild("rock_batcave")
	inst.AnimState:PlayAnimation("full")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "rock_batcave.png" )

	inst:AddComponent("lootdropper") 
	inst.components.lootdropper:SetChanceLootTable('rock1')
	inst.components.lootdropper.alwaysinfront = true
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	
	inst.components.workable:SetOnWorkCallback(
		function(inst, worker, workleft)
			local pt = Point(inst.Transform:GetWorldPosition())
			if workleft <= 0 then
                SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
				inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
				inst.components.lootdropper:DropLoot(pt)

				TheWorld.components.quaker_interior:ForceQuake("pillarshake", inst)

				local interior = findBatCave()
				if interior then
					print("FOUND BAT CAVE")
					dumptable(interior,1,1,1)

					local door = SpawnPrefab("prop_door")
					door.Transform:SetPosition(pt.x,pt.y,pt.z)
	    			door.AnimState:SetBank("ant_cave_door")
	    			door.AnimState:SetBuild("ant_cave_door")
	    			door.Transform:SetRotation(-90)
	    			door.AnimState:PlayAnimation("north")	

	    			local minimap = door.entity:AddMiniMapEntity()	    	
	    			minimap:SetIcon("ant_cave_door.png") 		
	    			door.minimapicon = "ant_cave_door.png"			

					local interior_spawner = TheWorld.components.interiorspawner

	    			local data =
	    			{
	    				my_interior_name = interior_spawner.current_interior.unique_name,
	    				my_door_id =  "roc_cave_EXIT2", 
	    				target_door_id = "roc_cave_ENTRANCE2",
	    				target_interior	= interior.unique_name,
	    			}	    	

	    			door.door_data_bank = "ant_cave_door"
	    			door.door_data_build = "ant_cave_door"
	    			door.door_data_animstate = "north"

	    			interior_spawner:AddDoor(door, data)

	    			if interior.prefabs then
	    				-- tinker with the perfab data before the room has been created

	    				local x_offset = nil
	    				local z_offset = nil

	    				for i = #interior.prefabs, 1, -1 do
	    				 	if interior.prefabs[i].roc_cave_delete_me then
	    				 		x_offset = interior.prefabs[i].x_offset
	    				 		z_offset = interior.prefabs[i].z_offset
	    				 		table.remove(interior.prefabs,i)
	    				 	end
	    				end

	           			local prefab = { name = "prop_door", x_offset = x_offset, z_offset = z_offset, animdata = {minimapicon = "ant_cave_door.png", bank ="ant_cave_door", build ="ant_cave_door", anim="south", background=true}, 
	                                my_door_id = "roc_cave_ENTRANCE2", target_door_id = "roc_cave_EXIT2", target_interior = interior_spawner.current_interior.unique_name, rotation = -90, angle=0 }
	                    local prefab1 = { name = "prop_door_shadow", x_offset = x_offset, z_offset = z_offset, animdata = {bank ="ant_cave_door", build ="ant_cave_door", anim="south_floor"}}                                                   

	                    table.insert(interior.prefabs,prefab)
						table.insert(interior.prefabs,prefab1)
	    			else
	    				-- tinker with the actual prefabs since the room has been visited
                        local ents = nil   
                        local pt = nil                     
                        for i,prop in ipairs(interior.object_list) do
                            print(prop.prefab,prop:HasTag("roc_cave_delete_me_"))
                            if prop:HasTag("roc_cave_delete_me_") then
                                pt = Vector3(prop.Transform:GetWorldPosition())
                                table.remove(interior.object_list,i)
                                prop:Remove()                                
                                break
                            end
                        end

		    			if pt then		    				
							local door2 = SpawnPrefab("prop_door")
							door2.Transform:SetPosition(pt.x,pt.y,pt.z)
			    			door2.AnimState:SetBank("ant_cave_door")
			    			door2.AnimState:SetBuild("ant_cave_door")  
			    			door2.Transform:SetRotation(-90)  		
			    			door2.AnimState:PlayAnimation("south")	

			    			door2.door_data_animstate = "south"
			    			door2.door_data_bank ="ant_cave_door"
			    			door2.door_data_build = "ant_cave_door"

			    			local minimap = door2.entity:AddMiniMapEntity()	    	
			    			minimap:SetIcon("ant_cave_door.png") 		
			    			door2.minimapicon = "ant_cave_door.png"				    			

			    			local data = 
			    			{
			    				my_interior_name = interior.unique_name,
			    				my_door_id = "roc_cave_ENTRANCE2",
			    				target_door_id = "roc_cave_EXIT2",
			    				target_interior	= interior_spawner.current_interior.unique_name,
			    			}	    	

			    			door2.door_data_bank = "ant_cave_door"
			    			door2.door_data_build = "ant_cave_door"
			    			interior_spawner:AddDoor(door2, data)

			    			local shadow = SpawnPrefab("prop_door_shadow")
							shadow.Transform:SetPosition(pt.x,pt.y,pt.z)
			    			shadow.AnimState:SetBank("ant_cave_door")
			    			shadow.AnimState:SetBuild("ant_cave_door")  
			    			shadow.Transform:SetRotation(-90)
			    			shadow.AnimState:PlayAnimation("south_floor")
			    			
			    			interior_spawner:PutPropIntoInteriorLimbo(door2,interior,true)
			    			interior_spawner:PutPropIntoInteriorLimbo(shadow,interior,true)

                        else
                            -- THIS CODE IS TO SUPPORT OLDER SAVE FILES THAT MIGHT BE BROKEN                            
                           patchindoor(inst,interior)
                            
		    			end
	    			end
    			end
				inst:Remove()
			else
				if workleft < TUNING.ROCKS_MINE*(1/3) then
					inst.AnimState:PlayAnimation("low")
				elseif workleft < TUNING.ROCKS_MINE*(2/3) then
					inst.AnimState:PlayAnimation("med")
				else
					inst.AnimState:PlayAnimation("full")
				end
			end
		end)      

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "ROCK"
	MakeSnowCovered(inst, .01)        
	return inst
end



return Prefab( "cave_entrance_roc", fn, assets, prefabs),
       Prefab( "cave_exit_roc", exitfn, assets, prefabs)
