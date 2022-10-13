--require "recipe"
--require "recipecategory"
--require "tuning"

local TechTree = require("techtree")

local _GLOBAL = GLOBAL
local AddRecipe2 = AddRecipe2

_GLOBAL.setfenv(1, _GLOBAL)



local function place_door_test_fn(pt,rot)
    -- self.Transform:SetRotation(-90)

	-- if not TheWorld.ismastersim then
		-- return false
	-- end

    -- local interior_spawner = TheWorld.components.interiorspawner
    -- if interior_spawner.current_interior then

        local originpt = Vector3(1000, 0, 0)--interior_spawner:getSpawnOrigin()
        local width = 15--interior_spawner.current_interior.width
        local depth = 10--interior_spawner.current_interior.depth

        local dist = 2
        local newpt = {}
        local backdiff =  pt.x < (originpt.x - depth/2 + dist)
        local frontdiff = pt.x > (originpt.x + depth/2 - dist)
        local rightdiff = pt.z > (originpt.z + width/2 - dist)
        local leftdiff =  pt.z < (originpt.z - width/2 + dist)

        -- local name = string.gsub(self.prefab, "_placer", "")

        local canbuild = true
        local rot = -90
        if backdiff and not rightdiff and not leftdiff then
            --newpt = {x= originpt.x - depth/2, y=0, z=pt.z}
            newpt = { x = originpt.x - depth/2, y = 0, z = originpt.z }
            -- self.AnimState:PlayAnimation(name .. "_open_north")

        elseif frontdiff and not rightdiff and not leftdiff then
        	newpt = { x = originpt.x + depth/2, y = 0, z = originpt.z }
            -- self.AnimState:PlayAnimation(name .. "_open_south")

        elseif rightdiff and not backdiff and not frontdiff then
            --newpt = {x= pt.x, y=0, z= originpt.z + width/2}
            newpt = { x = originpt.x, y = 0, z = originpt.z + width/2 }
            -- self.AnimState:PlayAnimation(name .. "_open_west")

        elseif leftdiff and not backdiff and not frontdiff then
            --newpt = {x=pt.x, y=0, z= originpt.z - width/2}
            newpt = { x = originpt.x, y = 0, z = originpt.z - width/2 }
            -- self.AnimState:PlayAnimation(name .. "_open_east")
        else
			newpt = pt
            canbuild = false
        end

        -- if self.parent then
            -- self.parent:RemoveChild(self)
        -- end

        if canbuild then
            -- self.Transform:SetPosition(newpt.x, newpt.y, newpt.z)
            -- self.Transform:SetRotation(rot)
        else
            -- self.Transform:SetPosition(pt.x, pt.y, pt.z)
        end

        -- self.Transform:SetRotation(rot)
		
		pt = newpt

        -- local index_x, index_y = interior_spawner:GetCurrentPlayerRoomIndex()
        -- if backdiff and not rightdiff and not leftdiff and index_x == 0 and index_y == -1 then
        	-- return false
        -- end

        local ents = TheSim:FindEntities(newpt.x, newpt.y, newpt.z, 3, {}, {}, {"wallsection", "interior_door", "predoor"})
        if #ents >= 1 then
        	for _, ent in pairs(ents) do
        		if (ent:HasTag("predoor") or ent:HasTag("interior_door")) and ent.prefab ~= name and ent.prefab ~= "prop_door" then
        			return true
        		end
        	end
        end

        if #ents < 1 and canbuild then
            return true
        end
    -- end
    
    return false
end

TUNING.PROTOTYPER_TREES.HOME = {
	HOME = TechTree.Create({
		HOME = 2
	})
}
--TUNING.PROTOTYPER_TREES.HOME = {HOME = 2}

AddRecipe2("playerhouse_city",
{Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)},
TECH.SCIENCE_TWO,
{placer="playerhouse_city_placer"})
 
 AddRecipe2("pighousewithinterior",
 {Ingredient("boards", 1), Ingredient("cutstone", 1), Ingredient("pigskin", 1)},
 TECH.SCIENCE_TWO,
 {placer="interiorhouse_placer"})
 
 AddRecipe2("common/inventory/iron_door",
 {Ingredient("oinc", 15)},
 TECH.HOME_TWO,
 {placer="common/inventory/iron_door_placer",
 testfn=place_door_test_fn,
 nounlock=true})
 
 table.insert(CRAFTING_FILTERS.CRAFTING_STATION.recipes, "iron_door")
-- CRAFTING_FILTER_DEFS


