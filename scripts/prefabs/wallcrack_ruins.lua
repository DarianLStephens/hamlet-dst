local assets =
{
    Asset("ANIM", "anim/interior_wall_decals_ruins.zip"),
    --Asset("ANIM", "anim/pig_ruins_door_blue.zip"),
    Asset("ANIM", "anim/interior_wall_decals_ruins_cracks.zip"),
    Asset("ANIM", "anim/interior_wall_decals_ruins_cracks_fake.zip"),
}

local prefabs = 
{
}

local function GetOpposite( dir )
    if dir == "east" then
        return "west"
    elseif dir == "west" then
        return "east"
    end

    return dir
end

local function onload(inst, ents, data)
    if data then
        if data.baseanimname then
            inst.baseanimname = data.baseanimname
            inst.AnimState:PlayAnimation(inst.baseanimname .. "_closed")
        end

        if data.door_guid then
            inst.door = ents[data.door_guid].entity
        end
        if data.revealed then
            inst.AnimState:PushAnimation(inst.baseanimname)
        end
    end
end

local function onsave(inst, data)
    data.baseanimname = inst.baseanimname
    if inst.door then
        data.door_guid = inst.door.GUID
        local refs = {}
        table.insert(refs, data.door_guid)
        return refs
    end
    if inst.revealed then
        data.revealed = true
    end
end


local function SetCrack(inst, door)
    inst.Transform:SetPosition(door.Transform:GetWorldPosition())
    
    inst.baseanimname = door.baseanimname
    inst.baseanimname = GetOpposite(inst.baseanimname)

    inst.AnimState:SetBuild("interior_wall_decals_ruins_cracks")

    inst.door = door
    inst.AnimState:PlayAnimation(inst.baseanimname .. "_closed")


    if not door:HasTag("secret") then
        inst.reveal()
        end

end

local function InitInteriorPrefab(inst, doer, prefab_definition, interior_definition)
    if prefab_definition.animdata and prefab_definition.animdata.anim then
        inst.baseanimname = prefab_definition.animdata.anim
    end 
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()  
    local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

    inst.AnimState:SetBank ("interior_wall_decals_ruins_fake")
    inst.AnimState:SetBuild("interior_wall_decals_ruins_cracks_fake")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

	inst.AnimState:SetRayTestOnBB(true)

    inst.OnSave = onsave
    inst.OnLoadPostPass = onload

    inst.SetCrack = SetCrack

    inst:AddTag("secret_room")
    inst:AddComponent("mystery_door")

    inst:AddComponent("inspectable")

    local function reveal()
        if inst.door then
            inst.door.components.door:sethidden(false)
            inst.door.components.door:updateDoorVis()

            inst.door.AnimState:PlayAnimation(GetOpposite(inst.baseanimname).. "_open")
            inst.door:RemoveTag("secret")

            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")

            -- GetPlayer().SoundEmitter:PlaySound( "dontstarve_DLC003/music/secret_found")
            inst.SoundEmitter:PlaySound( "dontstarve_DLC003/music/secret_found")

            -- The rest of the function unlocks the equivalent door within the secret room
            local interior_spawner = TheWorld.components.interiorspawner
            local target_door_id = inst.door.components.door.target_door_id
            local dest_door = interior_spawner:GetDoor(target_door_id)

            -- If the player has been to the secret room before we remove the tag from the instance manually
            if dest_door and dest_door.inst then
                dest_door.inst:RemoveTag("secret")
            else
                -- If the player has yet to be in the secret room we find the door definition and remove the secret and hidden tags
                local interior = interior_spawner:GetInteriorByName(inst.door.components.door.target_interior)
                for k,v in pairs(interior.prefabs) do
                    if v.my_door_id == target_door_id then
                        v.secret = false
                        v.hidden = false
                        break
                    end
                end
            end

            inst:Remove()
        else 
            inst.revealed =true
            inst.AnimState:PlayAnimation(inst.baseanimname.. "_open")
            inst.AnimState:PushAnimation(inst.baseanimname)
        end
    end
    inst.reveal = reveal

    inst.initInteriorPrefab = InitInteriorPrefab

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.BLANK)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(function()
        reveal()
    end)


    inst:ListenForEvent("death", function(_) reveal() end)
    inst:ListenForEvent("endquake", function() 
		print("Door crack got endquake, check limbo")
		if not inst:IsInLimbo() then
			print("Not in limbo, reveal the door")
        	reveal()
		end
    end, TheWorld)

    inst:ListenForEvent("exitlimbo", function(_)
        -- Self destruct if this door has already been unlocked
        if inst.door and not inst.door:HasTag("secret") then
            reveal()
        end
    end)

    return inst
end

return Prefab( "common/inventory/wallcrack_ruins", fn, assets, prefabs)