require "prefabutil"
require "recipes"

local assets =
{
    Asset("ANIM", "anim/pig_ruins_entrance.zip"),
    Asset("ANIM", "anim/pig_door_test.zip"), 
    Asset("MINIMAP_IMAGE", "pig_ruins_entrance"),
    Asset("ANIM", "anim/pig_ruins_entrance_build.zip"),
    Asset("ANIM", "anim/pig_ruins_entrance_top_build.zip"),
}

local prefabs = 
{
    "deco_roomglow",
    "light_dust_fx",
    "deco_ruins_wallcrumble_1",
    "deco_ruins_wallcrumble_side_1",
    "deco_ruins_cornerbeam",
    "deco_ruins_beam",
    "deco_ruins_wallstrut",
    "deco_ruins_beam_broken",
    "deco_ruins_cornerbeam_heavy",
    "deco_ruins_beam_room",
    "deco_ruins_fountain",
    "pig_ruins_torch_sidewall",
    "deco_ruins_pigman_relief_side",
    "deco_ruins_writing1",

    "pig_ruins_dart",

    "pig_ruins_pressure_plate",

    "pig_ruins_torch_wall",

    "deco_ruins_crack_roots1",
    "deco_ruins_crack_roots2",
    "deco_ruins_crack_roots3",
    "deco_ruins_crack_roots4",
    "deco_ruins_crack_roots5",

    "deco_ruins_pigqueen_relief",
    "deco_ruins_pigking_relief",

    "deco_ruins_pigman_relief1",
    "deco_ruins_pigman_relief2",
    "deco_ruins_pigman_relief3",

    "pig_ruins_creeping_vines",
    "pig_ruins_wall_vines_north",
    "pig_ruins_wall_vines_east",
    "pig_ruins_wall_vines_west",

    "smashingpot",
    "aporkalypse_clock",
    "wallcrack_ruins"
}

local room_creatures  = {
    {
        { name = "bat", x_offset = (math.random()*7) - (7/2), z_offset = (math.random()*13) - (13/2) },
        { name = "bat", x_offset = (math.random()*7) - (7/2), z_offset = (math.random()*13) - (13/2) },
    },
    {
        { name = "bat", x_offset = (math.random()*7) - (7/2), z_offset = (math.random()*13) - (13/2) },
        { name = "bat", x_offset = (math.random()*7) - (7/2), z_offset = (math.random()*13) - (13/2) },
        { name = "bat", x_offset = (math.random()*7) - (7/2), z_offset = (math.random()*13) - (13/2) },
    },
    {
        { name = "scorpion", x_offset = (math.random()*7) - (7/2), z_offset = (math.random()*13) - (13/2) },
        { name = "scorpion", x_offset = (math.random()*7) - (7/2), z_offset = (math.random()*13) - (13/2) },
    },    
    {
        { name = "scorpion", x_offset = (math.random()*7) - (7/2), z_offset = (math.random()*13) - (13/2) },
    },       
    --{
    --    { name = "pig_ghost", x_offset = (math.random()*7) - (7/2), z_offset = (math.random()*13) - (13/2) },
    --},           
}

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

local function spawnspeartrapset(addprops, depth, width, offsetx, offsetz, tags, nocenter, full, scale, pluspattern)
    local scaledist = 15
    if scale then
        scaledist = scale
    end

    if pluspattern then
        table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = -depth/scaledist + offsetx, z_offset =  0 + offsetz, addtags = tags} )
        table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = 0 + offsetx,                z_offset =  - width/scaledist + offsetz,  addtags = tags} )
    --    table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = 0 + offsetx,                z_offset =  0 + offsetz,  addtags = tags} )
        table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = 0 + offsetx,                z_offset =  width/scaledist + offsetz,  addtags = tags} )
        table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = depth/scaledist - offsetx, z_offset =  0 + offsetz,  addtags = tags} )
    else
        table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = -depth/scaledist + offsetx, z_offset =  -width/scaledist + offsetz, addtags = tags} )
        table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = -depth/scaledist + offsetx, z_offset =  width/scaledist + offsetz,  addtags = tags} )
        if not nocenter then
            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = 0 + offsetx, z_offset =  0 + offsetz, addtags = tags} )
        end
        table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = depth/scaledist + offsetx, z_offset =  -width/scaledist + offsetz,  addtags = tags} )
        table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = depth/scaledist + offsetx, z_offset =  width/scaledist + offsetz,   addtags = tags} )    

        if full then
            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = -depth/scaledist + offsetx, z_offset =  0+ offsetz,  addtags = tags} )
            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = depth/scaledist + offsetx, z_offset =  0+ offsetz,   addtags = tags} )
            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = 0+ offsetx, z_offset =  -width/scaledist + offsetz,  addtags = tags} )
            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = 0+ offsetx, z_offset =  width/scaledist + offsetz,   addtags = tags} )
        end
    end    return addprops
end
local function addgoldstatue(addprops,x,z)
    if math.random() <0.5 then
        table.insert(addprops, { name = "pig_ruins_pig", x_offset = x, z_offset =  z, rotation = -90 } )
    else
        table.insert(addprops, { name = "pig_ruins_ant", x_offset = x, z_offset =  z, rotation = -90 } )
    end
    return addprops
end

local function addrelicstatue(addprops,x,z, tags)
    if math.random() <0.5 then
        table.insert(addprops, { name = "pig_ruins_idol", x_offset = x, z_offset =  z, rotation = -90, addtags = tags } )
    else
        table.insert(addprops, { name = "pig_ruins_plaque", x_offset = x, z_offset =  z, rotation = -90, addtags = tags } )
    end
    return addprops
end

local function makechoice(list)

    local item = nil
    local total = 0
    for i = 1, #list do
        total = total + list[i][2]
    end

    local choice = math.random(1,total)
    total = 0
    local last = 0
    local top = 0
--    print("-------------")
    for i = 1, #list do
        top = top + list[i][2]
   --     print("CHECK",last,top,choice)
        if choice > last and choice <= top then
    --        print("CHECK TRUE")
            item = list[i][1]
            break
        end
        last = top
    end
    assert(item)
    return item
 end

local function getRoomByIndex(rooms,idx)
    for i, room in ipairs(rooms)do
        if room.idx == idx then
            return room
        end
    end
end
local function mazemaker(inst, dungeondef)

	

	local EAST  = { x =  1, y =  0, label = "east" }
	local WEST  = { x = -1, y =  0, label = "west" }
	local NORTH = { x =  0, y =  1, label = "north" }
	local SOUTH = { x =  0, y = -1, label = "south" }

	local dir_str =
	{
		"north",
		"east",
		"south",
		"west",
	}

	local op_dir_str =
	{
		["north"] = "south",
		["east"]  = "west",
		["south"] = "north",
		["west"]  = "east",
	}

	local dir_main =
	{
		EAST,
		WEST,
		NORTH,
		SOUTH,
	}

	local dir_opposite_main =
	{
		WEST,
		EAST,
		SOUTH,
		NORTH,
	}
	
	local function GetOppositeFromDirection(direction)
		-- DS - There's gotta be a way to get the index of the direction and just return that straight from the opposite table, right?
		if direction == NORTH then
			return SOUTH
		elseif direction == EAST then
			return WEST
		elseif direction == SOUTH then
			return NORTH
		else
			return EAST
		end
	end

    local interior_spawner = TheWorld.components.interiorspawner
	
    local rooms_to_make = dungeondef.rooms --24
    local entranceRoom = nil
    local exitRoom = nil
    local rooms = {} 
	
    local room = {
        x=0,
        y=0,
        -- idx = dungeondef.name.."_"..interior_spawner:GetNewID(),
        idx = interior_spawner:GetNewID(),
        exits = {},
        blocked_exits = {NORTH}, -- 3 == NORTH
        entrance1 = true,
    }   

    local rooms_by_id = {}
    rooms_by_id[room.idx] = room
    table.insert(rooms,room)

    local clock_placed = false

    while #rooms < rooms_to_make do
        local dir = dir_main
        local dir_opposite = dir_opposite_main
        local dir_choice = math.random(#dir)
        local fromroom = rooms[math.random(#rooms)]

        local fail = false
        -- fail if this direction from the chosen room is blocked
        for i,exit in ipairs(fromroom.blocked_exits) do
            if dir_main[dir_choice] == exit then
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
                idx = interior_spawner:GetNewID(),
                -- idx = dungeondef.name.."_"..interior_spawner:GetNewID(),
                exits = {},
                blocked_exits = {},
            }

            fromroom.exits[dir[dir_choice]] = {
                target_room = newroom.idx,
                bank =  "doorway_ruins",
                build = "pig_ruins_door",
                room = fromroom.idx,
            }

            newroom.exits[dir_opposite[dir_choice]] = {
                target_room = fromroom.idx,
                bank =  "doorway_ruins",
                build = "pig_ruins_door",
                room = newroom.idx,
            }

			-- Vines are fine, and world options are a looong way off, anyway
            -- if GetWorld().getworldgenoptions(GetWorld())["door_vines"] and GetWorld().getworldgenoptions(GetWorld())["door_vines"] == "never" then
                -- dungeondef.doorvines = nil
            -- end

            if dungeondef.doorvines and math.random() < dungeondef.doorvines then
                fromroom.exits[dir[dir_choice]].vined = true
                newroom.exits[dir_opposite[dir_choice]].vined = true
            end

            rooms_by_id[newroom.idx] = newroom

            table.insert(rooms, newroom)
        end
    end

    local function CreateSecretRoom()
        local grid = {}

        local function CheckFreeGridPos(x, y)
            for i,room in ipairs(rooms) do
                if room.x == x and room.y == y then
                    return false
                end
            end

            return true
        end

        local function CheckAdjacent(room, dir)
            local x = room.x + dir.x
            local y = room.y + dir.y
            
            if CheckFreeGridPos(x, y) then

                if not grid[x] then
                    grid[x] = {}
                end

                if not grid[x][y] then
                    grid[x][y] = { rooms = {room}, dirs = {dir}}
                else
                    table.insert(grid[x][y].rooms, room)
                    table.insert(grid[x][y].dirs, dir)
                end
            end
        end

        local function FindCandidates()
            for i,room in ipairs(rooms) do

                local north = NORTH
                local west = WEST
                local east = EAST
                
                local dir = nil

                -- NORTH IS OPEN
                if not room.exits[north] and not room.entrance2 and not room.entrance1 then
                    CheckAdjacent(room, north)
                end
                
                -- WEST IS OPEN
                if not room.exits[west]  then
                    CheckAdjacent(room, west)
                end
                
                -- EAST IS OPEN
                if not room.exits[east] then
                    CheckAdjacent(room, east)
                end
            end
        end

        local function GetMax()
            local max_x = 0
            local max_y = 0
            local max = 0
            local key_1 = 0
            local key_2 = 0
            
            for k,v in pairs(grid) do
                for k2,v2 in pairs(v) do
                    if #v2.rooms > max then
                        max = #v2.rooms
                        max_x = k
                        max_y = k2
                    end
                end
            end

            if max > 0 then
                return max_x, max_y
            end
        end

        local function PopulateSecretRoom(x, y)

            local secret_room = {
                x = x,
                y = y,
                -- idx = dungeondef.name.."_"..interior_spawner:GetNewID(),
                idx = interior_spawner:GetNewID(),
                exits = {},
                blocked_exits ={},
                secretroom = true
            }

            local grid_rooms = grid[x][y].rooms
            local grid_dirs = grid[x][y].dirs

            local bank =  "interior_wall_decals_ruins"
            local build = "interior_wall_decals_ruins_cracks"

            if dungeondef.name == "RUINS_5" and not clock_placed then
                -- reduce the grid_room to 1
                clock_placed = true
                secret_room.aporkalypseclock = true                  
                while #grid_rooms > 1 do

                    local num = math.random(1,#grid_rooms)                    
                    table.remove(grid_rooms,num)
                    table.remove(grid_dirs,num)
                    bank =  "doorway_ruins"
                    build = "pig_ruins_door"
                end
            end

            for i, grid_room in ipairs(grid_rooms) do
                local op_dir = GetOppositeFromDirection(grid_dirs[i])
                local secret = true
                if secret_room.aporkalypseclock == true then
                    secret = false
                end

                secret_room.exits[op_dir] = {
                    target_room = grid_room.idx,
                    bank =  bank,
                    build = build,
                    room = secret_room.idx,
                    secret = secret,                    
                }

                grid_room.exits[grid_dirs[i]] = {
                    target_room = secret_room.idx,
                    bank =  "interior_wall_decals_ruins",
                    build = "interior_wall_decals_ruins_cracks",
                    room = grid_room.idx,
                    secret = true
                }
            end

            grid[x][y] = nil            
            return secret_room
        end

        FindCandidates()

        local secret_room_count = dungeondef.secretrooms

        for i=1, secret_room_count do
            local x, y = GetMax()
            if x == nil or y == nil then
                print ("COULDN'T FIND SUITABLE CANDIDATES FOR THE SECRET ROOM.")
            else
                local newroom = PopulateSecretRoom(x, y)
                if newroom then
                    rooms_by_id[newroom.idx] = newroom
                    table.insert(rooms, newroom)
                end
            end
        end
    end


    local choices = {}
    local dist = 0
    for i,room in ipairs(rooms) do
       -- local dir = interior_spawner:GetDir()
        local north_exit_open = not room.exits[NORTH]

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

    local advancedtraps = false
    if dungeondef.name == "RUINS_3" then
        choices[math.random(#choices)].pheromonestone = true
    elseif dungeondef.name == "RUINS_1" then
        choices[math.random(#choices)].relictruffle = true
    elseif dungeondef.name == "RUINS_2" then
        choices[math.random(#choices)].relicsow = true
    elseif dungeondef.name == "RUINS_5" then
        advancedtraps = true
        choices[math.random(#choices)].endswell = true        
    else
        choices[math.random(#choices)].treasure = true
    end

    CreateSecretRoom()

    local width = 18
    local depth = 12
    local props_by_room = {}

    for i,room in ipairs(rooms) do

        if dungeondef.deepruins and math.random() < 0.3 then            
            room.color = "_blue"          
        else
            room.color = ""
        end

        local addprops = {}

        local addedprops = false
        local nopressureplates = false

        -- all rooms with 1 exit get creatures
        if exitNumbers(room) == 1 then
            for p,prop in ipairs(room_creatures[math.random(#room_creatures)] ) do
                table.insert(addprops,prop)
            end
            addedprops = true
        end
        -- randomly add creatures otherwise
        if not addedprops then
            if math.random() < 0.3 then
                for p,prop in ipairs(room_creatures[math.random(#room_creatures)] ) do
                    table.insert(addprops,prop)
                end
            end
        end        
        
        if room.entrance1 then
            width = 24
            depth = 16
            local prefab = { name = "prop_door", x_offset = -depth/2, z_offset = 0,  animdata = {minimapicon = "pig_ruins_exit_int.png", bank = "doorway_ruins", build = "pig_ruins_door", anim = "day_loop", light = true}, 
                            my_door_id = dungeondef.name.."_EXIT1", target_door_id = dungeondef.name.."_ENTRANCE1", rotation = -90, angle=0, targetDoor = inst, addtags = {"timechange_anims","ruins_entrance"} }
            table.insert(addprops, prefab)
            entranceRoom = room
        end

        if room.entrance2 then
            width = 24
            depth = 16
            local prefab = { name = "prop_door", x_offset = -depth/2, z_offset = 0,  animdata = {minimapicon = "pig_ruins_exit_int.png", bank = "doorway_ruins", build = "pig_ruins_door", anim = "day_loop", light = true}, 
                            my_door_id = dungeondef.name.."_EXIT2", target_door_id = dungeondef.name.."_ENTRANCE2", rotation = -90, angle=0, targetDoor = inst, addtags = {"timechange_anims","ruins_entrance"} }
            table.insert(addprops, prefab)
            exitRoom = room
        end 

        if room.endswell then
            width = 24
            depth = 16
            local prefab = { name = "deco_ruins_endswell", x_offset = 0, z_offset = 0, rotation = -90 }
            table.insert(addprops, prefab)
        end 

        if room.pheromonestone then
            width = 24
            depth = 16
            local prefab = { name = "pheromonestone", x_offset = 0, z_offset = 0 }
            table.insert(addprops, prefab)
        end 

        local roomtype = nil
        local roomtypes = {"grownover","storeroom","smalltreasure","snakes!",nil} -- lightfires -- critters

		-- Ditto for worldgen options
        -- if not GetWorld().getworldgenoptions(GetWorld())["spear_traps"] or GetWorld().getworldgenoptions(GetWorld())["spear_traps"] ~= "never" then
            table.insert(roomtypes,"speartraps!")
        -- end

        -- if not GetWorld().getworldgenoptions(GetWorld())["dart_traps"] or GetWorld().getworldgenoptions(GetWorld())["dart_traps"] ~= "never" then
            table.insert(roomtypes,"darts!")
        -- end       

        -- if more than one exit, add the doortrap to the potential list
        if exitNumbers(room) > 1 and not room.sercretroom then
            table.insert(roomtypes,"doortrap")
            table.insert(roomtypes,"doortrap")
        end

        roomtype = roomtypes[math.random(1,#roomtypes)]
        local treasuretype = nil

        if room.treasure then
            roomtype =  "treasure"
        end

        if room.relictruffle or room.relicsow then
            roomtype =  "treasure"
            treasuretype = "rarerelic"
        end

        if room.secretroom  then
            roomtype = "treasure"
            treasuretype =  "secret"
        end        

        if room.aporkalypseclock then
            roomtype = "treasure"
            treasuretype = "aporkalypse"
        end
        -- this prevents other features from conflicting with the endswell well. 
        if room.endswell then
            roomtype = "treasure"
            treasuretype = "endswell"
        end
        
        -- DEBUG ==================================================================================         
        --      roomtype =  "treasure"
        --    treasuretype = "rarerelic"        
        -- END DEBUG

        rooms_by_id = {}
        for i,roomset in ipairs(rooms)do
            rooms_by_id[roomset.idx] = roomset
        end

        local northexitopen = not room.exits[NORTH] and not room.entrance2 and not room.entrance1
        local westexitopen = not room.exits[WEST] 
        local southexitopen = not room.exits[SOUTH] 
        local eastexitopen = not room.exits[EAST]

        local numexits = 0
        for i,exit in pairs(room.exits)do
            numexits = numexits + 1
        end
        print("NUMBER OF EXITS", numexits)

        -- Adds fake wall cracks
        if northexitopen and math.random() < 0.10  then
            table.insert(addprops, { name = "wallcrack_ruins", x_offset = -depth/2, z_offset = 0, startAnim = "north_closed", animdata = {anim = "north"}} )
            northexitopen = false
        end
        if westexitopen and math.random() < 0.10  then
            table.insert(addprops, { name = "wallcrack_ruins", x_offset = 0, z_offset = -width/2, startAnim = "east_closed", animdata = {anim = "east"}} )
            westexitopen = false
        end
        if eastexitopen and math.random() < 0.10  then
            table.insert(addprops, { name = "wallcrack_ruins", x_offset = 0, z_offset = width/2, startAnim = "west_closed", animdata = {anim = "west"}} )
            eastexitopen = false
        end

        print("ROOMTYPE", roomtype)
        
        local fountain = false
        local pilars = false
        local widepilars = false
        local function addroomcolumn(x,z)
            if math.random() <0.2 then
                table.insert(addprops, { name = "deco_ruins_beam_room_broken"..room.color, x_offset = x, z_offset =  z, rotation = -90 } )
            else
                table.insert(addprops, { name = "deco_ruins_beam_room"..room.color, x_offset = x, z_offset =  z, rotation = -90 } )
            end
        end
        local function getspawnlocation(widthrange, depthrange)
            local setwidth = width*widthrange * math.random() - width*widthrange/2
            local setdepth = depth*depthrange * math.random() - depth*depthrange/2 
            local place = true
            if fountain then
                -- filters out thigns that would place where the fountain is
                if  math.abs(setwidth * setwidth) + math.abs(setdepth * setdepth) < 4*4 then
                    place = false
                end
            end
            if place == true then                  
                return setwidth, setdepth
            end
        end

        -- put in the general decor... may dictate where other things go later, like due to the fountain.
        if roomtype ~= "darts!" and roomtype ~= "speartraps!" and roomtype ~= "rarerelic" and roomtype ~= "treasure" and roomtype ~= "smalltreasure" and roomtype ~= "secret" and roomtype ~= "aporkalypse" then
            local feature = math.random(8)
            if feature == 1 then 
                addroomcolumn(-depth/6, -width/6)
                addroomcolumn( depth/6,  width/6)
                addroomcolumn( depth/6, -width/6)
                addroomcolumn(-depth/6,  width/6)      
                widepilars = true          

            elseif feature == 2 then
                if roomtype ~= "doortrap" and not room.pheromonestone then
                    table.insert(addprops, { name = "deco_ruins_fountain", x_offset = 0, z_offset =  0, rotation = -90 } )
                    fountain = true
                end
                if math.random()<0.5 then
                    addroomcolumn(-depth/6,  width/3)
                    addroomcolumn( depth/6, -width/3)
                    widepilars = true
                else
                    addroomcolumn(-depth/4, width/4)
                    addroomcolumn(-depth/4,-width/4)
                    addroomcolumn( depth/4,-width/4)
                    addroomcolumn( depth/4, width/4)
                    pilars = true
                end
            elseif feature == 3 then
                addroomcolumn(-depth/4,width/6)
                addroomcolumn(0,width/6)
                addroomcolumn(depth/4,width/6)
                addroomcolumn(-depth/4,-width/6)
                addroomcolumn(0,-width/6)
                addroomcolumn(depth/4,-width/6)
                pilars = true
            end
        end

        -- Sets up the secret room 
        

        if roomtype == "snakes!" then
            for i=1,math.random(3,6) do
                table.insert(addprops, { name = "snake_amphibious", x_offset =  depth*0.8 * math.random() - depth*0.8/2, z_offset =  width*0.8 * math.random() - width*0.8/2 } )
            end
        end

        if roomtype == "storeroom" then
            for i=1, math.random(6)+6 do
                local setwidth, setdepth = getspawnlocation(0.8, 0.8)
                if setwidth and setdepth then
                     table.insert(addprops, { name = "smashingpot", x_offset = setdepth, z_offset =  setwidth} )            
                end
            end
        end

        if roomtype == "doortrap" then
            local setups = {"default","default","default","hor","vert"}

            if dungeondef.deepruins then
                if northexitopen or southexitopen then
                    table.insert(setups,"longhor") 
                end
                if eastexitopen or westexitopen then
                    table.insert(setups,"longvert")
                end
            end
            local random =  math.random(1,#setups)

            if setups[random] == "default" then            
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -depth/2 +3 + (math.random()*2 - 1), z_offset = (math.random()*2 - 1) } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset =  depth/2 -3 + (math.random()*2 - 1), z_offset = (math.random()*2 - 1) } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = (math.random()*2 - 1), z_offset = (math.random()*2 - 1) } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = (math.random()*2 - 1), z_offset =  width/2 -3 + (math.random()*2 - 1) } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = (math.random()*2 - 1), z_offset = -width/2 +3 + (math.random()*2 - 1) } )
            elseif setups[random] == "hor" then
                local unit = 1.5
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0, z_offset = 0 } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0, z_offset = 1*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0, z_offset = -1*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0, z_offset = -2*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0, z_offset = 2*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0, z_offset = 3*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0, z_offset = -3*unit } )
            elseif setups[random] == "longvert" then
                local unit = 1.5
                local dir = {}
                if eastexitopen then
                    table.insert(dir,1)
                end
                if westexitopen then
                    table.insert(dir,-1)
                end                
                dir = dir[math.random(1,#dir)]
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = 0 } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = 1*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = -1*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = -2*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = 2*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = 3*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = -3*unit } ) 
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = 4*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = -4*unit } )                                
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = 5*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = -5*unit } )  
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = 6*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = -6*unit } )  
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = 7*unit } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/4.5 * dir, z_offset = -7*unit } )    

            elseif setups[random] == "vert" then
                local unit = 1.5
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0, z_offset = 0 } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 1*unit, z_offset = 0 } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 2*unit, z_offset = 0 } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 3*unit, z_offset = 0 } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -1*unit, z_offset = 0 } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -2*unit, z_offset = 0 } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -3*unit, z_offset = 0 } )                

            elseif setups[random] == "longhor" then
                local unit = 1.5
                local dir = {}
                if northexitopen then
                    table.insert(dir,-1)
                end
                if southexitopen then
                    table.insert(dir,1)
                end                
                dir = dir[math.random(1,#dir)]
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0, z_offset =  width/4.5 * dir } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 1*unit, z_offset =  width/4.5 * dir } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 2*unit, z_offset =  width/4.5 * dir } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 3*unit, z_offset =  width/4.5 * dir } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 4*unit, z_offset =  width/4.5 * dir } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 5*unit, z_offset =  width/4.5 * dir } )

                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -1*unit, z_offset =  width/4.5 * dir } )                                
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -2*unit, z_offset =  width/4.5 * dir } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -3*unit, z_offset =  width/4.5 * dir } )  
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -4*unit, z_offset =  width/4.5 * dir } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -5*unit, z_offset =  width/4.5 * dir } )  
 
            end
            
        end
    
        if roomtype == "treasure" then

            if treasuretype and treasuretype == "aporkalypse" then

                table.insert(addprops, { name = "aporkalypse_clock", x_offset = -1, z_offset = 0} )
                fountain = true

            elseif treasuretype and treasuretype == "secret" then

                local getitem = function()
                    local items =  {
                        redgem =30,
                        bluegem =20,
                        relic_1 = 10,
                        relic_2 = 10,
                        relic_3 = 10,
                        nightsword = 1,
                        ruins_bat = 1,
                        ruinshat = 1,
                        orangestaff = 1,
                        armorruins = 1,
                        multitool_axe_pickaxe = 1,
                    }
                    return weighted_random_choice(items)
                end

                if not dungeondef.smallsecret then
                    table.insert(addprops, { name = "shelves_ruins", x_offset = -depth/7, z_offset = -width/7, shelfitems={{1,getitem()}} })                
                    table.insert(addprops, { name = "shelves_ruins", x_offset = depth/7, z_offset = -width/7, shelfitems={{1,getitem()}} })
                    table.insert(addprops, { name = "shelves_ruins", x_offset = -depth/7, z_offset = width/7, shelfitems={{1,getitem()}} })                
                    table.insert(addprops, { name = "shelves_ruins", x_offset = depth/7, z_offset = width/7, shelfitems={{1,getitem()}} })
                else
                    table.insert(addprops, { name = "shelves_ruins", x_offset = 0, z_offset =-width/7, shelfitems={{1,getitem()}} })
                    table.insert(addprops, { name = "shelves_ruins", x_offset = 0, z_offset =width/7, shelfitems={{1,getitem()}} })
                end

            elseif treasuretype and treasuretype == "rarerelic" then
                room.color = "_blue"
             
                local relic = "pig_ruins_truffle"
                if room.relicsow then
                    relic = "pig_ruins_sow"
                end

                if not northexitopen then
                    table.insert(addprops, { name = relic, x_offset = depth/2-2, z_offset =  0, addtags={"trggerdarttraps"}} )
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/2-2, z_offset =  0} )
                elseif not southexitopen then                
                    table.insert(addprops, { name = relic, x_offset = -depth/2+2, z_offset =  0, addtags={"trggerdarttraps"}} )
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/2+2, z_offset =  0} )
                elseif not eastexitopen then
                    table.insert(addprops, { name = relic, x_offset = 0, z_offset = width/2-2, addtags={"trggerdarttraps"}} )                
                    table.insert(addprops, { name = "pig_ruins_light_beam",  x_offset = 0, z_offset = width/2-2} )
                elseif not westexitopen then
                    table.insert(addprops, { name = relic, x_offset = 0, z_offset = -width/2+2, addtags={"trggerdarttraps"}} )                
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset = -width/2+2} )
                end     

                for i=0,3 do
                    for t=0,3 do
                        local x = -depth/2 + (depth/4 *i)
                        local z = -width/2 + (width/4 *i)
                        if math.random()<0.6 then table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = x, z_offset =  z} ) end                        
                    end
                end

                local function add4plates(x,y)                    
                    if math.random()<0.5 then 
                        local xoffset = x + depth/16 
                        local yoffset = y - width/16
                        if math.abs(xoffset) < depth/2 and math.abs(yoffset) < width/2 then
                            table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = xoffset, z_offset = yoffset, addtags={"trap_dart"} } ) 
                        end
                    end                    
                    if math.random()<0.5 then
                        local xoffset = x - depth/16 
                        local yoffset = y - width/16
                        if math.abs(xoffset) < depth/2 and math.abs(yoffset) < width/2 then
                            table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = xoffset, z_offset = yoffset, addtags={"trap_dart"} } ) 
                        end
                    end
                    if math.random()<0.5 then 
                        local xoffset = x - depth/16 
                        local yoffset = y + width/16
                        if math.abs(xoffset) < depth/2 and math.abs(yoffset) < width/2 then                        
                            table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = xoffset, z_offset = yoffset, addtags={"trap_dart"} } ) 
                        end
                    end
                    if math.random()<0.5 then 
                        local xoffset = x + depth/16 
                        local yoffset = y + width/16
                        if math.abs(xoffset) < depth/2 and math.abs(yoffset) < width/2 then                         
                            table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = xoffset, z_offset = yoffset, addtags={"trap_dart"} } ) 
                        end
                    end
                end

                if math.random() < 0.5 then
                    table.insert(addprops, { name = "pig_ruins_dart_statue", x_offset = depth/4, z_offset = width/4 } )
                    table.insert(addprops, { name = "pig_ruins_dart_statue", x_offset = -depth/4, z_offset = -width/4 } )
                else
                    table.insert(addprops, { name = "pig_ruins_dart_statue", x_offset = -depth/4, z_offset = width/4 } )
                    table.insert(addprops, { name = "pig_ruins_dart_statue", x_offset = depth/4, z_offset = -width/4 } )
                end

                add4plates(depth/4,width/4)
                add4plates(depth/4,0)
                add4plates(depth/4,-width/4)

                add4plates(0,width/4)
                add4plates(0,0)
                add4plates(0,-width/4)

                add4plates(-depth/4,width/4)
                add4plates(-depth/4,0)
                add4plates(-depth/4,-width/4)

                add4plates(-depth/2,width/4)                
                add4plates(-depth/2,-width/4)                

                add4plates(depth/2,width/4)                
                add4plates(depth/2,-width/4)     

                add4plates(depth/4,width/2)                
                add4plates(depth/4,-width/2)

                add4plates(-depth/4,-width/2)                
                add4plates(-depth/4,width/2)                                                                
      
            elseif not treasuretype or treasuretype ~= "endswell" then

                local setups = {"darts n relics","spears n relics","relics n dust"}
                local random =  math.random(1,#setups)
                random = 1
                if setups[random] == "relics n dust" then
                    addprops = addgoldstatue(addprops,-depth/3,-width/3)
                    addprops = addgoldstatue(addprops,depth/3,width/3)
                    addprops = addrelicstatue(addprops,0,0)
                    addprops = addgoldstatue(addprops,depth/3,-width/3)
                    addprops = addgoldstatue(addprops,-depth/3,width/3)
                elseif setups[random] == "spears n relics" then
                    addprops = addrelicstatue(addprops,0,-width/4)
                    addprops = addrelicstatue(addprops,0,0) 
                    addprops = addrelicstatue(addprops,0,width/4)

                    addprops = spawnspeartrapset(addprops, depth, width, 0, -width/4, nil, true, true,12)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  -width/4, addtags={"localtrap"}} )
                    addprops = spawnspeartrapset(addprops, depth, width, 0, 0, nil, true, true, 12)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  0, addtags={"localtrap"}} )
                    addprops = spawnspeartrapset(addprops, depth, width, 0, width/4, nil, true, true, 12)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  width/4, addtags={"localtrap"}} )
                elseif setups[random] == "darts n relics" then
                    addprops = addrelicstatue(addprops,0,-width/3 +1, {"trggerdarttraps"})
                    addprops = addrelicstatue(addprops,depth/4-1,0, {"trggerdarttraps"})
                    addprops = addrelicstatue(addprops,0,width/3 -1, {"trggerdarttraps"})
                    roomtype = "darts!"
                    nopressureplates = true
                end
            end
        end

         if roomtype == "smalltreasure" then
            if math.random() <0.5 then
                addprops = addgoldstatue(addprops,0,-width/6)
                addprops = addgoldstatue(addprops,0,width/6)
            else
                addprops = addrelicstatue(addprops,0,0)
            end
         end  
        
        if roomtype == "grownover" then
            for i=1, math.random(10)+8 do                
                local setwidth, setdepth = getspawnlocation(0.8, 0.8)
                if setwidth and setdepth then
                     table.insert(addprops, { name = "grass", x_offset = setdepth, z_offset =  setwidth} )
                end                            
            end
            for i=1, math.random(4)+8 do                
                local setwidth, setdepth = getspawnlocation(0.8, 0.8)
                if setwidth and setdepth then
                     table.insert(addprops, { name = "sapling", x_offset = setdepth, z_offset =  setwidth} )
                end                               
            end            
            for i=1, math.random(10)+10 do                
                local setwidth, setdepth = getspawnlocation(0.8, 0.8)
                if setwidth and setdepth then
                     table.insert(addprops, { name = "deep_jungle_fern_noise_plant", x_offset = setdepth, z_offset =  setwidth} )
                end                                 
            end              
            table.insert(addprops, { name = "lightrays", x_offset = 0, z_offset = 0})
        end

        -- GENERAL RUINS ROOM ART
        local heavybeams = false
        if math.random()<0.8 or roomtype == "lightfires" or roomtype == "darts!" then  -- the wall torches get blocked by the big beams
            table.insert(addprops, { name = "deco_ruins_cornerbeam"..room.color, x_offset = -depth/2, z_offset =  -width/2, rotation = -90} )
            table.insert(addprops, { name = "deco_ruins_cornerbeam"..room.color, x_offset = -depth/2, z_offset =  width/2, rotation = -90,flip=true  } )
            table.insert(addprops, { name = "deco_ruins_cornerbeam"..room.color, x_offset = depth/2, z_offset =  -width/2, rotation = -90 } )
            table.insert(addprops, { name = "deco_ruins_cornerbeam"..room.color, x_offset = depth/2, z_offset =  width/2, rotation = -90,flip=true } )
        else
            table.insert(addprops, { name = "deco_ruins_cornerbeam_heavy"..room.color, x_offset = -depth/2, z_offset =  -width/2, rotation = -90} )
            table.insert(addprops, { name = "deco_ruins_cornerbeam_heavy"..room.color, x_offset = -depth/2, z_offset =  width/2, rotation = -90, flip=true  } )
            table.insert(addprops, { name = "deco_ruins_beam_heavy"..room.color, x_offset = depth/2, z_offset =  -width/2, rotation = -90 } )
            table.insert(addprops, { name = "deco_ruins_beam_heavy"..room.color, x_offset = depth/2, z_offset =  width/2, rotation = -90, flip=true } )            heavybeams = true
        end

        local prop = "deco_ruins_beam"..room.color
        if math.random()<0.2 then
            prop = "deco_ruins_beam_broken"..room.color
        end

        table.insert(addprops, { name = prop, x_offset = -depth/2, z_offset =  -width/6, rotation = -90 } )
        table.insert(addprops, { name = prop, x_offset = -depth/2, z_offset =  width/6, rotation = -90, } )

        if room.exits[NORTH] and room.exits[NORTH].vined then

            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = -width/2 + 0.75} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = -width/3 + 0.75} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = -width/3 - 0.75} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = -width/6 + 0.75} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = -width/6 - 0.75} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = width/6 + 0.75} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = width/6 - 0.75} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = width/3 + 0.75} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = width/3 - 0.75} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_north", x_offset = -depth/2, z_offset = width/2 - 0.75} ) end            
        end

        if room.exits[WEST] and room.exits[WEST].vined then            

            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_east", x_offset = -depth/2 + 0.75, z_offset = -width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_east", x_offset = -depth/3 - 0.75, z_offset = -width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_east", x_offset = -depth/6 - 0.75, z_offset = -width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_east", x_offset = depth/6 + 0.75, z_offset = -width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_east", x_offset = depth/3 - 0.75, z_offset = -width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_east", x_offset = depth/2 - 0.75, z_offset = -width/2} ) end            
        end

        if room.exits[EAST] and room.exits[EAST].vined then            

            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_west", x_offset = -depth/2 + 0.75, z_offset = width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_west", x_offset = -depth/3 - 0.75, z_offset = width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_west", x_offset = -depth/6 - 0.75, z_offset = width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_west", x_offset = depth/6 + 0.75, z_offset = width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_west", x_offset = depth/3 + 0.75, z_offset = width/2} ) end
            if math.random()<1 then table.insert(addprops, { name = "pig_ruins_wall_vines_west", x_offset = depth/2 - 0.75, z_offset = width/2} ) end       
        end

        if roomtype == "speartraps!" then

            local speartraps = {"spottraps","walltrap","wavetrap","bait"}
            if dungeondef.deepruins and numexits > 1 then
                table.insert(speartraps,"litfloor")
            end            
            local random = math.random(1,#speartraps)
            --random = 4
            if speartraps[random] == "spottraps" then
                if math.random() < 0.3 then
                    addprops = spawnspeartrapset(addprops, depth, width, depth/3, -width/3)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/3, z_offset =  -width/3, addtags={"localtrap"}} )                    
                elseif math.random() < 0.5 then
                    addprops = spawnspeartrapset(addprops, depth, width, 0, -width/3)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  -width/3, addtags={"localtrap"}} )
                else                
                    addprops = spawnspeartrapset(addprops, depth, width, -depth/3, -width/3)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/3, z_offset =  -width/3, addtags={"localtrap"}} )                   
                end

                if math.random() < 0.3 then
                    addprops = spawnspeartrapset(addprops, depth, width, -depth/3, width/3)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/3, z_offset =  width/3, addtags={"localtrap"}} )                             
                elseif math.random() < 0.5 then
                    addprops = spawnspeartrapset(addprops, depth, width, 0, width/3)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  width/3, addtags={"localtrap"}} )
                else                
                    addprops = spawnspeartrapset(addprops, depth, width, depth/3, width/3)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/3, z_offset =  width/3, addtags={"localtrap"}} )                    
                end

                if math.random() < 0.3 then
                    addprops = spawnspeartrapset(addprops, depth, width, -depth/3, 0)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/3, z_offset =  0, addtags={"localtrap"}} )                             
                elseif math.random() < 0.5 then
                    addprops = spawnspeartrapset(addprops, depth, width, 0,0)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  0, addtags={"localtrap"}} )
                else                
                    addprops = spawnspeartrapset(addprops, depth, width, depth/3, 0)
                    table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/3, z_offset = 0, addtags={"localtrap"}} )                    
                end
      
            elseif speartraps[random] == "bait" then
                local baits = {
                                {"goldnugget",5},
                                {"rocks",20},
                                {"flint",20},
                                {"redgem",1},
                                {"relic_1",1},
                                {"relic_2",1},
                                {"relic_3",1},
                                {"boneshard",5},
                                {"meat_dried",5},
                            }

                local offsets = {{-depth/5,-width/5},
                                  { depth/5,-width/5},
                                  {-depth/5, width/5},
                                  { depth/5, width/5}}

                for i=1, math.random(1,3)do
                    local rand = 1 

                    rand = math.random(1,#offsets)
                    local choicex = offsets[rand][1]
                    local choicez = offsets[rand][2]
                    table.remove(offsets,rand) 

                    local loot = makechoice(deepcopy(baits))

                    addprops = spawnspeartrapset(addprops, depth, width, 0+choicex,0+choicez, nil, true, true, 12)
                    table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0+choicex, z_offset = 0+choicez, addtags={"trap_spear","localtrap","reversetrigger","startdown"} } )
                    table.insert(addprops, { name = loot, x_offset = 0+choicex, z_offset = 0+choicez } )
                end
      
            elseif speartraps[random] == "walltrap" then

                local angle = 0
                local traps = 14
                local anglestep = (2*PI)/traps
                local radius = 4
                for i=1,traps do
                    local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
                    table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = offset.x, z_offset =  offset.z} )
                    angle = angle + anglestep
                end

                angle = 0
                traps = 24
                anglestep = (2*PI)/traps
                radius = 5
                for i=1,traps do
                    local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
                    table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = offset.x, z_offset =  offset.z} )
                    angle = angle + anglestep
                end

                table.insert(addprops, { name = "relic_1", x_offset = 0, z_offset =  0} )
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  0} )

            elseif speartraps[random] == "wavetrap" then
                if math.random() < 0.2 then
                    local function getrandomset()
                        local set = {}
                        local random = math.random(1,3)
                        if random == 1 then
                            set = {"timed","up_3","down_6","delay_3"}
                        elseif random == 2 then
                            set = {"timed","up_3","down_6","delay_6"}
                        elseif random == 3 then
                            set = {"timed","up_3","down_6","delay_9"}
                        end

                        return set
                    end

                    local function setrandomspearsets(xmod, ymod, plus)
                        local scaledist = 15
                        if plus then
                            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = -depth/scaledist + xmod, z_offset =  ymod, addtags = getrandomset()} )
                            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset =  xmod, z_offset =  width/scaledist + ymod, addtags = getrandomset()} )

                            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = depth/scaledist + xmod, z_offset =  ymod, addtags = getrandomset()} )
                            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = xmod, z_offset =  -width/scaledist + ymod, addtags = getrandomset()} )                             
                        else
                            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = -depth/scaledist + xmod, z_offset =  -width/scaledist + ymod, addtags = getrandomset()} )
                            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = -depth/scaledist + xmod, z_offset =  width/scaledist + ymod, addtags = getrandomset()} )

                            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = depth/scaledist + xmod, z_offset =  -width/scaledist + ymod, addtags = getrandomset()} )
                            table.insert(addprops, { name = "pig_ruins_spear_trap", x_offset = depth/scaledist + xmod, z_offset =  width/scaledist + ymod, addtags = getrandomset()} ) 
                        end
                    end

                    setrandomspearsets(0, -width/4)
                    setrandomspearsets(0, 0, true)
                    setrandomspearsets(0, width/4)

                    setrandomspearsets(-depth/4, -width/4, true)
                    setrandomspearsets(-depth/4, 0)
                    setrandomspearsets(-depth/4, width/4, true)
                    
                    setrandomspearsets(depth/4, -width/4, true)
                    setrandomspearsets(depth/4, 0)
                    setrandomspearsets(depth/4, width/4, true)

                else
                    if math.random() < 0.5 then
                        spawnspeartrapset(addprops, depth, width, 0, -width/4, {"timed","up_3","down_6","delay_3"}, true)
                        spawnspeartrapset(addprops, depth, width, 0, 0,        {"timed","up_3","down_6","delay_6"}, true)
                        spawnspeartrapset(addprops, depth, width, 0, width/4,  {"timed","up_3","down_6","delay_9"}, true)

                        spawnspeartrapset(addprops, depth, width, -depth/4, -width/4, {"timed","up_3","down_6","delay_3"}, true)
                        spawnspeartrapset(addprops, depth, width, -depth/4, 0,        {"timed","up_3","down_6","delay_6"}, true)
                        spawnspeartrapset(addprops, depth, width, -depth/4, width/4,  {"timed","up_3","down_6","delay_9"}, true)

                        spawnspeartrapset(addprops, depth, width, depth/4, -width/4, {"timed","up_3","down_6","delay_3"}, true)
                        spawnspeartrapset(addprops, depth, width, depth/4, 0,        {"timed","up_3","down_6","delay_6"}, true)
                        spawnspeartrapset(addprops, depth, width, depth/4, width/4,  {"timed","up_3","down_6","delay_9"}, true)
                    else
                        spawnspeartrapset(addprops, depth, width, 0, -width/4, {"timed","up_3","down_6","delay_6"}, true)
                        spawnspeartrapset(addprops, depth, width, 0, 0,        {"timed","up_3","down_6","delay_6"}, true)
                        spawnspeartrapset(addprops, depth, width, 0, width/4,  {"timed","up_3","down_6","delay_6"}, true)

                        spawnspeartrapset(addprops, depth, width, -depth/4, -width/4, {"timed","up_3","down_6","delay_9"}, true)
                        spawnspeartrapset(addprops, depth, width, -depth/4, 0,        {"timed","up_3","down_6","delay_9"}, true)
                        spawnspeartrapset(addprops, depth, width, -depth/4, width/4,  {"timed","up_3","down_6","delay_9"}, true)

                        spawnspeartrapset(addprops, depth, width, depth/4, -width/4, {"timed","up_3","down_6","delay_3"}, true)
                        spawnspeartrapset(addprops, depth, width, depth/4, 0,        {"timed","up_3","down_6","delay_3"}, true)
                        spawnspeartrapset(addprops, depth, width, depth/4, width/4,  {"timed","up_3","down_6","delay_3"}, true)
                    end
                end
            elseif speartraps[random] == "litfloor" then

                addprops = spawnspeartrapset(addprops, depth, width, depth/2.7, -width/2.7)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/2.5, z_offset =  -width/2.5, addtags={"localtrap"}} )  

                addprops = spawnspeartrapset(addprops, depth, width, depth/6, -width/2.7, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/6, z_offset =  -width/2.5, addtags={"localtrap"}} )                    

        --        addprops = spawnspeartrapset(addprops, depth, width, 0, -width/2.5)
          --      table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  -width/2.5, addtags={"localtrap"}} )
                
                addprops = spawnspeartrapset(addprops, depth, width, -depth/6, -width/2.7, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/6, z_offset =  -width/2.5, addtags={"localtrap"}} )                    
      
                addprops = spawnspeartrapset(addprops, depth, width, -depth/2.7, -width/2.7)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/2.5, z_offset =  -width/2.5, addtags={"localtrap"}} )                   



                addprops = spawnspeartrapset(addprops, depth, width, depth/2.5, -width/6, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/2.5, z_offset =  -width/6, addtags={"localtrap"}} )  

                addprops = spawnspeartrapset(addprops, depth, width, depth/6, -width/6)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/6, z_offset =  -width/6, addtags={"localtrap"}} )                    

                addprops = spawnspeartrapset(addprops, depth, width, 0, -width/6, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  -width/6, addtags={"localtrap"}} )
                
                addprops = spawnspeartrapset(addprops, depth, width, -depth/6, -width/6)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/6, z_offset =  -width/6, addtags={"localtrap"}} )                    
      
                addprops = spawnspeartrapset(addprops, depth, width, -depth/2.5, -width/6, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/2.5, z_offset =  -width/6, addtags={"localtrap"}} )



          --      addprops = spawnspeartrapset(addprops, depth, width, depth/2.5, 0)
          --      table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/2.5, z_offset =  0, addtags={"localtrap"}} )  

                addprops = spawnspeartrapset(addprops, depth, width, depth/6, 0, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/6, z_offset = 0, addtags={"localtrap"}} )                    

                addprops = spawnspeartrapset(addprops, depth, width, 0, 0)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset = 0, addtags={"localtrap"}} )
                
                addprops = spawnspeartrapset(addprops, depth, width, -depth/6, 0, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/6, z_offset = 0, addtags={"localtrap"}} )                    
      
          --      addprops = spawnspeartrapset(addprops, depth, width, -depth/2.5, 0)
          --      table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/2.5, z_offset = 0, addtags={"localtrap"}} )                   


                addprops = spawnspeartrapset(addprops, depth, width, depth/2.5, width/6, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/2.5, z_offset = width/6, addtags={"localtrap"}} )  

                addprops = spawnspeartrapset(addprops, depth, width, depth/6, width/6)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/6, z_offset = width/6, addtags={"localtrap"}} )                    

                addprops = spawnspeartrapset(addprops, depth, width, 0, width/6, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset =  width/6, addtags={"localtrap"}} )
                
                addprops = spawnspeartrapset(addprops, depth, width, -depth/6, width/6)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/6, z_offset = width/6, addtags={"localtrap"}} )                    
      
                addprops = spawnspeartrapset(addprops, depth, width, -depth/2.5, width/6, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/2.5, z_offset = width/6, addtags={"localtrap"}} )


                addprops = spawnspeartrapset(addprops, depth, width, depth/2.7, width/2.7)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/2.5, z_offset = width/2.5, addtags={"localtrap"}} )  

                addprops = spawnspeartrapset(addprops, depth, width, depth/6, width/2.7, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = depth/6, z_offset = width/2.5, addtags={"localtrap"}} )                    

        --        addprops = spawnspeartrapset(addprops, depth, width, 0, width/2.5)
          --      table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = 0, z_offset = width/2.5, addtags={"localtrap"}} )
                
                addprops = spawnspeartrapset(addprops, depth, width, -depth/6, width/2.7, nil, nil, nil, nil, true)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/6, z_offset = width/2.5, addtags={"localtrap"}} )                    
      
                addprops = spawnspeartrapset(addprops, depth, width, -depth/2.7, width/2.7)
                table.insert(addprops, { name = "pig_ruins_light_beam", x_offset = -depth/2.5, z_offset = width/2.5, addtags={"localtrap"}} )                   

            end
        elseif roomtype == "darts!" then
            if advancedtraps and  math.random()<0.3 then 
                local x = depth/8 
                if math.random()<0.5 then
                    x = -x
                end
                local z = width/8
                if math.random()<0.5 then
                    z = -z
                end                
                table.insert(addprops, { name = "pig_ruins_dart_statue", x_offset = x, z_offset =  z} )   
            else
                table.insert(addprops, { name = "pig_ruins_pigman_relief_dart"..math.random(4)..room.color, x_offset = -depth/2, z_offset =  -width/3} )            
                if northexitopen then
                    table.insert(addprops, { name = "pig_ruins_pigman_relief_dart"..math.random(4)..room.color, x_offset = -depth/2, z_offset =  0} )            
                end
                table.insert(addprops, { name = "pig_ruins_pigman_relief_dart"..math.random(4)..room.color, x_offset = -depth/2, z_offset =  width/3 } )

                table.insert(addprops, { name = "pig_ruins_pigman_relief_leftside_dart"..room.color, x_offset = -depth/4+(math.random()*1 -0.5), z_offset =  -width/2 } )
                if westexitopen then
                    table.insert(addprops, { name = "pig_ruins_pigman_relief_leftside_dart"..room.color, x_offset = 0+(math.random()*1 -0.5), z_offset =  -width/2 } )
                end
                table.insert(addprops, { name = "pig_ruins_pigman_relief_leftside_dart"..room.color, x_offset = depth/4+(math.random()*1 -0.5), z_offset =  -width/2 } )

                table.insert(addprops, { name = "pig_ruins_pigman_relief_rightside_dart"..room.color, x_offset = -depth/4+(math.random()*1 -0.5), z_offset =  width/2 } )
                if eastexitopen then
                    table.insert(addprops, { name = "pig_ruins_pigman_relief_rightside_dart"..room.color, x_offset = 0+(math.random()*1 -0.5), z_offset =  width/2 } )
                end            
                table.insert(addprops, { name = "pig_ruins_pigman_relief_rightside_dart"..room.color, x_offset = depth/4+(math.random()*1 -0.5), z_offset =  width/2 } )    
            end        
            -- if the treasure room wants dart traps, then the plates get turned off.
            if not nopressureplates then
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -depth/6*2+ (math.random()*2 - 1),        z_offset = 0+ (math.random()*2 - 1),        addtags={"trap_dart"} } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = 0 + (math.random(2) - 1),        z_offset = 0+ (math.random()*2 - 1),        addtags={"trap_dart"} } )
                
                if southexitopen then
                    table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = depth/6*2+ (math.random()*2 - 1),        z_offset = 0+ (math.random()*2 - 1),        addtags={"trap_dart"} } )
                end
          
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -depth/6*2+ (math.random()*2 - 1), z_offset = -width/6*2+(math.random()*2 - 1), addtags={"trap_dart"} } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = (math.random()*2 - 1), z_offset = -width/6*2+(math.random()*2 - 1), addtags={"trap_dart"} } )            
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset = -depth/6*2+ (math.random()*2 - 1), z_offset =  width/6*2+(math.random()*2 - 1), addtags={"trap_dart"} } )

                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset =  depth/6*2+ (math.random()*2 - 1), z_offset = -width/6*2+(math.random()*2 - 1), addtags={"trap_dart"} } )
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset =  (math.random()*2 - 1), z_offset = width/6*2+(math.random()*2 - 1), addtags={"trap_dart"} } )            
                table.insert(addprops, { name = "pig_ruins_pressure_plate", x_offset =  depth/6*2+ (math.random()*2 - 1), z_offset =  width/6*2+(math.random()*2 - 1), addtags={"trap_dart"} } )
            end            
        else            
            local wallrelief = math.random()
            if wallrelief < 0.6 and roomtype ~= "lightfires" then
                if math.random()<0.8 then 
                    table.insert(addprops, { name = "deco_ruins_pigman_relief"..math.random(3)..room.color, x_offset = -depth/2, z_offset =  -width/6*2, rotation = -90 } )
                else 
                    table.insert(addprops, { name = "deco_ruins_crack_roots"..math.random(4), x_offset = -depth/2, z_offset =  -width/6*2, rotation = -90 } ) 
                end

                if northexitopen then
                    if math.random()<0.8 then 
                        if math.random()<0.1 then
                            table.insert(addprops, { name = "deco_ruins_pigqueen_relief"..room.color, x_offset = -depth/2, z_offset =  -width/18, rotation = -90, } )    
                            table.insert(addprops, { name = "deco_ruins_pigking_relief"..room.color, x_offset = -depth/2, z_offset =  width/18, rotation = -90, } )  
                        else
                            table.insert(addprops, { name = "deco_ruins_pigman_relief"..math.random(3)..room.color, x_offset = -depth/2, z_offset =  0, rotation = -90, } )            
                        end
                    else
                        table.insert(addprops, { name = "deco_ruins_crack_roots"..math.random(4), x_offset = -depth/2, z_offset =  0, rotation = -90, } ) 
                    end
                end
                if math.random()<0.8 then 
                    table.insert(addprops, { name = "deco_ruins_pigman_relief"..math.random(3)..room.color, x_offset = -depth/2, z_offset =  width/6*2, rotation = -90, } )
                else
                    table.insert(addprops, { name = "deco_ruins_crack_roots"..math.random(4), x_offset = -depth/2, z_offset =  width/6*2, rotation = -90, } ) 
                end   
            else
                if math.random()< 0.5 or roomtype == "lightfires" then
                    local tags = nil
                    if roomtype == "lightfires" then   
                        tags = "something"
                        if northexitopen then
                            table.insert(addprops, { name = "deco_ruins_writing1", x_offset = -depth/2, z_offset =  0, rotation = -90 } )            
                            table.insert(addprops, { name = "pig_ruins_torch_wall"..room.color, x_offset = -depth/2, z_offset =  -width/6*2, rotation = -90, addtags={tags} } )  
                        else
                            table.insert(addprops, { name = "deco_ruins_writing1", x_offset = -depth/2, z_offset =  -width/6*2, rotation = -90, } )    
                        end
                        table.insert(addprops, { name = "pig_ruins_torch_wall"..room.color, x_offset = -depth/2, z_offset =  width/6*2, rotation = -90, } )
                    else
                        table.insert(addprops, { name = "pig_ruins_torch_wall"..room.color, x_offset = -depth/2, z_offset =  -width/6*2, rotation = -90 } )
                        if northexitopen then
                            table.insert(addprops, { name = "pig_ruins_torch_wall"..room.color, x_offset = -depth/2, z_offset =  0, rotation = -90, } )            
                        end
                        table.insert(addprops, { name = "pig_ruins_torch_wall"..room.color, x_offset = -depth/2, z_offset =  width/6*2, rotation = -90, } )
                    end

                    table.insert(addprops, { name = "pig_ruins_torch_sidewall"..room.color, x_offset = -depth/3-0.5, z_offset =  -width/2, rotation = -90 } )                
                    if westexitopen then
                        table.insert(addprops, { name = "pig_ruins_torch_sidewall"..room.color, x_offset = 0-0.5, z_offset =  -width/2, rotation = -90 } )
                    end
                    table.insert(addprops, { name = "pig_ruins_torch_sidewall"..room.color, x_offset =  depth/3-0.5, z_offset =  -width/2, rotation = -90 } )

                    table.insert(addprops, { name = "pig_ruins_torch_sidewall"..room.color, x_offset = -depth/3-0.5, z_offset =  width/2, rotation = -90, flip=true } )
                    if eastexitopen then
                        table.insert(addprops, { name = "pig_ruins_torch_sidewall"..room.color, x_offset = 0-0.5, z_offset =  width/2, rotation = -90, flip=true } )
                    end
                    table.insert(addprops, { name = "pig_ruins_torch_sidewall"..room.color, x_offset =  depth/3-0.5, z_offset =  width/2, rotation = -90, flip=true } )                
                end
            end
        end
        local hangingroots = math.random()
        if hangingroots < 0.3 and not roomtype == "lightfires" then 

            local function jostle()
                return math.random() - 0.5
            end

            local function flip()
                local test = true 
                if math.random()<0.5 then 
                    test = false
                end
                return test
            end

            local roots_left = {
                { name = "deco_ruins_roots"..math.random(3), x_offset = -depth/2, z_offset =  -width/6 - width/12 + jostle(), rotation = -90,flip=flip() },
                { name = "deco_ruins_roots"..math.random(3), x_offset = -depth/2, z_offset =  -width/6 - width/12*2+ jostle(), rotation = -90,flip=flip() },
                { name = "deco_ruins_roots"..math.random(3), x_offset = -depth/2, z_offset =  -width/6 - width/12*3+ jostle(), rotation = -90,flip=flip() }
            }

            local num = math.random(#roots_left)
            for i=1,num do
                local choice = math.random(#roots_left)
                table.insert(addprops, roots_left[choice])
                table.remove(roots_left,choice)
            end

            if northexitopen then
                local roots_center = {
                    { name = "deco_ruins_roots"..math.random(3), x_offset = -depth/2, z_offset =  0 + width/12+ jostle(), rotation = -90,flip=flip() },
                    { name = "deco_ruins_roots"..math.random(3), x_offset = -depth/2, z_offset =  0 + jostle(), rotation = -90,flip=flip() },
                    { name = "deco_ruins_roots"..math.random(3), x_offset = -depth/2, z_offset =  0 - width/12+ jostle(), rotation = -90,flip=flip() }
                }

                local num = math.random(#roots_center)
                for i=1,num do
                    local choice = math.random(#roots_center)
                    table.insert(addprops, roots_center[choice])
                    table.remove(roots_center,choice)
                end
            end

            local roots_right = {
                { name = "deco_ruins_roots"..math.random(3), x_offset = -depth/2, z_offset =  width/6 + width/12+ jostle(), rotation = -90,flip=flip() },
                { name = "deco_ruins_roots"..math.random(3), x_offset = -depth/2, z_offset =  width/6 + width/12*2+ jostle(), rotation = -90,flip=flip() },
                { name = "deco_ruins_roots"..math.random(3), x_offset = -depth/2, z_offset =  width/6 + width/12*3+ jostle(), rotation = -90,flip=flip() }
            }

            local num = math.random(#roots_right)
            for i=1,num do
                local choice = math.random(#roots_right)
                table.insert(addprops, roots_right[choice])
                table.remove(roots_right,choice)
            end
        end

        if math.random() < 0.1 and roomtype ~= "lightfires" and roomtype ~= "speartraps!" then
            if math.random() < 0.5 then
                table.insert(addprops, { name = "deco_ruins_corner_tree", x_offset = -depth/2, z_offset =  width/2, rotation = -90,flip=true  } )
            else
                table.insert(addprops, { name = "deco_ruins_corner_tree", x_offset = -depth/2, z_offset =  -width/2, rotation = -90} )
            end
        end

        --RANDOM POTS
        if roomtype ~= "secret" and roomtype ~= "aporkalypse" and math.random() < 0.25 then
            for i=1, math.random(2)+1 do                
                local setwidth, setdepth = getspawnlocation(0.8, 0.8)
                if setwidth and setdepth then
                     table.insert(addprops, { name = "smashingpot", x_offset = setdepth, z_offset =  setwidth} )
                end                
            end
        end

        local function addroomcolumn(x,z)
            if math.random() <0.2 then
                table.insert(addprops, { name = "deco_ruins_beam_room_broken", x_offset = x, z_offset =  z, rotation = -90 } )
            else
                table.insert(addprops, { name = "deco_ruins_beam_room", x_offset = x, z_offset =  z, rotation = -90 } )
            end
        end

        props_by_room[room] = {addprops = addprops}

    end
    
    for i,room in ipairs(rooms) do
        local floortexture = "levels/textures/interiors/ground_ruins_slab.tex"
        local walltexture = "levels/textures/interiors/pig_ruins_panel.tex"
        local minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"

        if room.color == "_blue" then
            floortexture = "levels/textures/interiors/ground_ruins_slab_blue.tex"
            walltexture = "levels/textures/interiors/pig_ruins_panel_blue.tex"     

            for i,exit in pairs(room.exits)do
                if exit.build == "pig_ruins_door" then
                    exit.build = "pig_ruins_door_blue"
                end
            end
        end     
		
		local prefab = {}
		
		local roomindex = room.idx
		print("About to loop through exits")
		for t, exit in pairs(room.exits) do
			print("Loop ",t)

			if not exit.house_door then
				if     t == NORTH then
					prefab = { name = "prop_door", x_offset = -depth/2, z_offset = 0, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "north", background = true },
								my_door_id = roomindex.."_NORTH", target_door_id = exit.target_room.."_SOUTH", target_interior = exit.target_room, rotation = -90, hidden = false, angle=0, addtags = { "lockable_door", "door_north" } }
				
				elseif t == SOUTH then
					prefab = { name = "prop_door", x_offset = (depth/2), z_offset = 0, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "south", background = false },
								my_door_id = roomindex.."_SOUTH", target_door_id = exit.target_room.."_NORTH", target_interior = exit.target_room, rotation = -90, hidden = false, angle=180, addtags = { "lockable_door", "door_south" } }
					
					if not exit.secret then
						table.insert(props_by_room[room].addprops, { name = "prop_door_shadow", x_offset = (depth/2), z_offset = 0, animdata = { bank = exit.bank, build = exit.build, anim = "south_floor" } })
					end

				elseif t == EAST then
					prefab = { name = "prop_door", x_offset = 0, z_offset = width/2, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "east", background = true },
								my_door_id = roomindex.."_EAST", target_door_id = exit.target_room.."_WEST", target_interior = exit.target_room, rotation = -90, hidden = false, angle=90, addtags = { "lockable_door", "door_east" } }
				
				elseif t == WEST then
					prefab = { name = "prop_door", x_offset = 0, z_offset = -width/2, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "west", background = true },
								my_door_id = roomindex.."_WEST", target_door_id = exit.target_room.."_EAST", target_interior = exit.target_room, rotation = -90, hidden = false, angle=270, addtags = { "lockable_door", "door_west" } }
				end
			else
				local doordata = player_interior_exit_dir_data[t.label]
					prefab = { name = exit.prefab_name, x_offset = doordata.x_offset, z_offset = doordata.z_offset, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = exit.prefab_name .. "_open_"..doordata.anim, background = doordata.background },
								my_door_id = roomindex..doordata.my_door_id_dir, target_door_id = exit.target_room..doordata.target_door_id_dir, target_interior = exit.target_room, rotation = -90, hidden = false, angle=doordata.angle, addtags = { "lockable_door", doordata.door_tag } }

			end

			if exit.vined then
				prefab.vined = true
			end

			if exit.secret then
				prefab.secret = true
				prefab.hidden = true
			end

			table.insert(props_by_room[room].addprops, prefab)
			-- table.insert(interior_def.prefabs, prefab)
		end
		print("Exit loop finished")
		
		local mappos = {}
		mappos.x = room.x
		mappos.y = room.y

		-- DS - Aaaaah I did it wrong
		-- interior_data = {
			-- dimensions = {
				-- depth,
				-- width,
				-- nil
			-- },
			-- textures = {
				-- floor = floortexture,
				-- wall = walltexture,
				-- minimap = minimaptexture
			-- },
			-- interior_group = dungeondef.name,
            -- interior_id = room.idx,
            -- pending_props = props_by_room[room].addprops,

            -- camera_offset = -2,
            -- camera_zoom = 23,
            
            -- cc = "images/colour_cubes/pigshop_interior_cc.tex",
            -- reverb = "ruins",
            -- pos = mappos,
            -- tile = "STONE",
		-- }
		
        -- interior_spawner:CreateRoom(interior_data)

		local interior_data = {}
		interior_data.length = width
		interior_data.width = depth
		interior_data.height = nil
		interior_data.floortexture = floortexture
		interior_data.walltexture = walltexture
		interior_data.minimaptexture = minimaptexture
		interior_data.interior_group = dungeondef.name
		interior_data.interior_id = room.idx
		interior_data.pending_props = props_by_room[room].addprops
		interior_data.cameraoffset = -2
		interior_data.zoom = 23
		interior_data.cc = "images/colour_cubes/pigshop_interior_cc.tex"
		interior_data.reverb = "ruins"
		interior_data.pos = mappos
		interior_data.tile = "INTERIOR"
		-- interior_data.tile = "STONE"
		
        interior_spawner:CreateRoom(interior_data)
        -- interior_spawner:CreateRoom("generic_interior", nil, nil, nil, "ruins","RUINS")
        -- interior_spawner:CreateRoom("generic_interior", width, nil, depth, dungeondef.name, room.idx, props_by_room[room].addprops, room.exits, walltexture, floortexture, minimaptexture, nil, "images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "ruins","RUINS","STONE")
    end

    return entranceRoom, exitRoom
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

local function refreshImage(inst,push)
    local anim = "idle_closed"
    if inst.stage == 2 then 
        anim = "idle_med"
    elseif inst.stage == 1 then 
        anim = "idle_low"
    elseif inst.stage == 0 then 
        anim = "idle_open"
    end

    if inst:HasTag("top_ornament") then
        inst.AnimState:AddOverrideBuild("pig_ruins_entrance_top_build")
        inst.AnimState:Hide("swap_ornament2")
        inst.AnimState:Hide("swap_ornament3")
        inst.AnimState:Hide("swap_ornament4")        
    elseif inst:HasTag("top_ornament2") then
        inst.AnimState:AddOverrideBuild("pig_ruins_entrance_top_build")
        inst.AnimState:Hide("swap_ornament3")
        inst.AnimState:Hide("swap_ornament4")
        inst.AnimState:Hide("swap_ornament")
    elseif inst:HasTag("top_ornament3") then
        inst.AnimState:AddOverrideBuild("pig_ruins_entrance_top_build")
        inst.AnimState:Hide("swap_ornament2")
        inst.AnimState:Hide("swap_ornament4")
        inst.AnimState:Hide("swap_ornament")
    elseif inst:HasTag("top_ornament4") then
        inst.AnimState:AddOverrideBuild("pig_ruins_entrance_top_build")
        inst.AnimState:Hide("swap_ornament2")
        inst.AnimState:Hide("swap_ornament3")
        inst.AnimState:Hide("swap_ornament")        
    else
        inst.AnimState:Hide("swap_ornament4")
        inst.AnimState:Hide("swap_ornament3")
        inst.AnimState:Hide("swap_ornament2")
        inst.AnimState:Hide("swap_ornament")
        inst.AnimState:OverrideSymbol("statue_01", "pig_ruins_entrance", "")                
        inst.AnimState:OverrideSymbol("swap_ornament", "pig_ruins_entrance", "")                             
    end

    if push then
        inst.AnimState:PushAnimation(anim, true)
    else
        inst.AnimState:PlayAnimation(anim, true)
    end
end

local function onhit(inst, worker)
    if inst.stage == 3 then
        inst.AnimState:PlayAnimation("hit_closed")
    elseif inst.stage == 2 then 
        inst.AnimState:PlayAnimation("hit_med")
    elseif inst.stage == 1 then 
        inst.AnimState:PlayAnimation("hit_low")
    end
    refreshImage(inst,true)
end

local function onsave(inst, data)
    data.stage = inst.stage
    data.hackeable = inst.components.hackable.canbehacked
	data.exitdoor = inst.exitdoor
    if inst:HasTag("maze_generated") then
        data.maze_generated = true
    end
    
    if inst:HasTag("top_ornament") then
        data.top_ornament = true
    end
    if inst:HasTag("top_ornament2") then
        data.top_ornament2 = true
    end
    if inst:HasTag("top_ornament3") then
        data.top_ornament3 = true
    end        
end

local function onload(inst, data)
    if data then
        if data.stage then
            inst.stage = data.stage
        end
        if data.hackable then
            inst.components.hackable.canbehacked = data.hackeable
        end
        if data.maze_generated then
            inst:AddTag("maze_generated")
        end
        if data.top_ornament then
            inst:AddTag("top_ornament")
        end
        if data.top_ornament2 then
            inst:AddTag("top_ornament2")
        end
        if data.top_ornament3 then
            inst:AddTag("top_ornament3")
        end
		if data.exitdoor then
			inst.exitdoor = exitdoor
		end
    end
    
    refreshImage(inst)
end

local function onhackedfn(inst, hacker, hacksleft)
    
    if hacksleft <= 0 then
        if inst.stage > 0 then
            inst.stage = inst.stage -1

            if inst.stage == 0 then
                inst.components.hackable.canbehacked = false
                inst.components.interiordoor:checkDisableDoor(false, "vines")                
            else
                inst.components.hackable.hacksleft = inst.components.hackable.maxhacks
            end
        end
    end

    local fx = SpawnPrefab("hacking_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/vine_hack")
    onhit(inst, hacker)
end

local function initmaze(inst, dungeonname)

    if not inst:HasTag("maze_generated") then

        local dungeondef = {
            name = dungeonname,
            rooms = 24,
            lock  = true,
            doorvines = 0.3,
            deepruins = true,
            secretrooms = 2,
        }

        if dungeonname == "RUINS_2" then
            dungeondef.rooms = 15        
            dungeondef.doorvines = 0.6
        elseif dungeonname == "RUINS_3" then
            dungeondef.rooms = 15
            dungeondef.nosecondexit = true
        elseif dungeonname == "RUINS_4" then
            dungeondef.rooms = 20        
            dungeondef.doorvines = 0.4
        elseif dungeonname == "RUINS_5" then
            dungeondef.rooms = 30
            dungeondef.doorvines = 0.6
            dungeondef.nosecondexit = true            
        elseif dungeonname == "RUINS_SMALL" then
            local interior_spawner = TheWorld.components.interiorspawner
            dungeondef.name = "RUINS_SMALL"..interior_spawner:GetNewID()
            dungeondef.rooms = math.random(6,8)
            dungeondef.nosecondexit = true
            dungeondef.lock = nil
            dungeondef.doorvines = nil
            dungeondef.deepruins = nil
            dungeondef.secretrooms = 1            
            dungeondef.smallsecret = true
        end

        local entranceRoom, exitRoom = mazemaker(inst, dungeondef)

		local function AddDoor(inst, door_definition)
			print("ADDING DOOR", door_definition.my_door_id)
			-- this sets some properties on the door component of the door object instance
			-- this also adds the door id to a list here in interiorspawner so it's easier to find what room needs to load when a door is used
			-- self.doors[door_definition.my_door_id] = { my_interior_name = door_definition.my_interior_name, inst = inst, target_interior = door_definition.target_interior }

			if inst ~= nil then
				print("Door is valid, setting data...")
				if inst.components.interiordoor == nil then
					print("Door was missing door component, add it")
					inst:AddComponent("interiordoor")
				end
				inst.components.interiordoor.door_id = door_definition.my_door_id
				inst.components.interiordoor.interior_name = door_definition.my_interior_name
				inst.components.interiordoor.target_door_id = door_definition.target_door_id
				inst.components.interiordoor.targetInteriorID = door_definition.target_interior
				inst.components.interiordoor.targetDoor = inst.exitdoor
				
				print("Double-checking door data: ")
				print("Door ID: ", inst.components.interiordoor.door_id )
				print("Interior Name: ", inst.components.interiordoor.interior_name )
				print("Target Door ID: ", inst.components.interiordoor.target_door_id )
				print("Target Interior: ", inst.components.interiordoor.targetInteriorID )
				print("Target Door: ", inst.components.interiordoor.targetDoor )
				
			end
		end

        local interior_spawner = TheWorld.components.interiorspawner
        local exterior_door_def = {
            my_door_id = dungeondef.name.."_ENTRANCE1",
            target_door_id = dungeondef.name.."_EXIT1",
            target_interior = entranceRoom.idx,
        }
        AddDoor(inst, exterior_door_def)

        if inst.components.interiordoor and dungeondef.lock then
            inst.components.interiordoor:checkDisableDoor(true, "vines")
        end      

        local exit_door = nil
        for i,ent in pairs(Ents) do
            if ent:HasTag(dungeondef.name.."_EXIT_TARGET") then
                exit_door = ent
            end
        end

        if exit_door and exitRoom then
            -- CREATE 2nd DOOR
            local exterior_door_def2 = {
                my_door_id = dungeondef.name.."_ENTRANCE2",
                target_door_id = dungeondef.name.."_EXIT2",
                target_interior = exitRoom.idx,
            }
            AddDoor(exit_door, exterior_door_def2)
        end     

        inst:AddTag("maze_generated")
    end

    refreshImage(inst)
end

local function inspect(inst)
    if inst.components.interiordoor.disabled then
        return "LOCKED"
    end
end

local function makefn(name,build_interiors, dungeonname)

    local function fn(Sim)
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        local light = inst.entity:AddLight()
        inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()
        --trans:SetEightFaced()

        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon( "pig_ruins_entrance.png" )

        MakeObstaclePhysics(inst, 1.20)

        anim:SetBank("pig_ruins_entrance")

        anim:SetBuild("pig_ruins_entrance_build")

        anim:PlayAnimation("idle_closed", true)

        --inst:AddTag("structure")
        inst:AddTag("ruins_exit")
	
		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

        inst:AddComponent("hackable")
        inst.components.hackable:SetUp()
        inst.components.hackable.onhackedfn = onhackedfn
        inst.components.hackable.hacksleft = TUNING.RUINS_ENTRANCE_VINES_HACKS
        inst.components.hackable.maxhacks = TUNING.RUINS_ENTRANCE_VINES_HACKS

        inst:AddComponent("shearable")

        inst:AddComponent("inspectable")  
        inst.components.inspectable.getstatus = inspect


        inst:AddComponent("interiordoor")
        -- inst:AddComponent("door")
        -- inst.components.interiordoor.outside = true

        if dungeonname == "RUINS_1" then
            inst:AddTag("top_ornament") 
        elseif dungeonname == "RUINS_2" then
            inst:AddTag("top_ornament2") 
        elseif dungeonname == "RUINS_3" then
            inst:AddTag("top_ornament3") 
        elseif dungeonname == "RUINS_4" or dungeonname == "RUINS_5" then
            inst:AddTag("top_ornament4")             
        end

        if build_interiors then
            -- this prefab is the entrance. Makes the maze            
            inst.stage = 3

            -- spread out the maze gen for less hiccup at load time.
            inst:DoTaskInTime(0,function()
                local time = 0
                local player = GetPlayer()
                -- local dist = inst:GetDistanceSqToInst(player)
                local dist = 0 -- Because I don't know why inst is invalid. Wait, won't that cause problems below, too?
                local w,h = TheWorld.Map:GetSize()
                if not TheWorld.ruinspawntime then
                    TheWorld.ruinspawntime = 0.5
                end
                if dist < 40*40 then
                    time = Remap(dist,0,40*40,0,0.5)
                else
                    time = GetWorld().ruinspawntime 
                    GetWorld().ruinspawntime  = GetWorld().ruinspawntime + 0.3
                end
                inst:DoTaskInTime(time, function() 
                    initmaze(inst, dungeonname) 
                end )
            end)
        else
            -- this prefab is an exit. Just set the door and art
            inst:AddTag(dungeonname.."_EXIT_TARGET")
            inst.stage = 0 
            inst.components.hackable.canbehacked = false
            inst.components.interiordoor.disabled = false
            refreshImage(inst)
        end 

        if dungeonname == "RUINS_SMALL" then
            inst.stage = 0 
            inst.components.hackable.canbehacked = false
            inst.components.interiordoor.disabled = false
            refreshImage(inst)
        end

        inst.components.inspectable.getstatus = getstatus
        
        MakeSnowCovered(inst, .01)

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end
    return fn
end
 
return Prefab("pig_ruins_entrance", makefn("pig_ruins_entrance", true,"RUINS_1"), assets, prefabs ),
       Prefab("pig_ruins_exit", makefn("pig_ruins_entrance", false,"RUINS_1"), assets, prefabs ),

       Prefab("pig_ruins_entrance2", makefn("pig_ruins_entrance", true,"RUINS_2"), assets, prefabs ),
       Prefab("pig_ruins_exit2", makefn("pig_ruins_entrance", false,"RUINS_2"), assets, prefabs ),

       Prefab("pig_ruins_entrance3", makefn("pig_ruins_entrance", true,"RUINS_3"), assets, prefabs ),

       Prefab("pig_ruins_entrance4", makefn("pig_ruins_entrance", true,"RUINS_4"), assets, prefabs ),
       Prefab("pig_ruins_exit4", makefn("pig_ruins_entrance", false,"RUINS_4"), assets, prefabs ),
  
       Prefab("pig_ruins_entrance5", makefn("pig_ruins_entrance", true,"RUINS_5"), assets, prefabs ),

       Prefab("pig_ruins_entrance_small", makefn("pig_ruins_entrance", true,"RUINS_SMALL"), assets, prefabs )