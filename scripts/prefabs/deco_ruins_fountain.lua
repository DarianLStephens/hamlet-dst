local assets =
{
    Asset("ANIM", "anim/pig_ruins_well.zip"),      
}

local prefabs =
{
 
}


local function onsave(inst, data)    
    data.rotation = inst.Transform:GetRotation()
   
    if inst.animdata then
        data.animdata = inst.animdata
    end    
end

local function onload(inst, data)
    if data.rotation then
        inst.Transform:SetRotation(data.rotation)
    end

    if data.animdata then
        inst.animdata = data.animdata
        if inst.animdata.build then
            inst.AnimState:SetBuild(inst.animdata.build)
        end
        if inst.animdata.bank then
            inst.AnimState:SetBank(inst.animdata.bank)
        end
        if inst.animdata.anim then
            inst.AnimState:PlayAnimation(inst.animdata.anim,inst.animdata.animloop)
        end                
    end
  end

local function loadpostpass(inst,ents, data)

end

local function ShouldAcceptItem(inst, item)

    if not inst:HasTag("vortex") then
        local can_accept = item.components.currency or item.prefab == "goldnugget" or item.prefab == "dubloon" --and (Prefabs[seed_name] or item.prefab == "seeds" or item.components.edible.foodtype == "MEAT") 
    
        return can_accept 
    else
        return true         
    end
end

local function OnRefuseItem(inst, item)
--    inst.AnimState:PlayAnimation("flap")
--    inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
--    inst.AnimState:PushAnimation("idle_bird")
end

local function OnGetItemFromPlayer(inst, giver, item)
    if not inst:HasTag("vortex") then
        local value = 0
        if item.prefab == "oinc" then
            value = 1
        elseif item.prefab == "oinc10" then
            value = 10
        elseif item.prefab == "oinc100" then
            value = 100        
        elseif item.prefab == "goldnugget" then
            value = 20
        elseif item.prefab == "dubloon" then
            value = 5
        end

        inst.AnimState:PlayAnimation("splash")
        inst.AnimState:PushAnimation("idle_full",true)   

        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/item_sink") 

        inst:DoTaskInTime(1, function()
                if math.random() * 25 < value then
                    if giver.components.poisonable and  giver.components.poisonable.poisoned then
                        giver.components.poisonable:Cure(inst)
                    end
                    if giver.components.health and  giver.components.health:GetPercent() < 1 then
                        giver.components.health:DoDelta( value*5 ,false,inst.prefab)
                        giver:PushEvent("celebrate")
                    end           
                end
            end)
    else
        inst.AnimState:PlayAnimation("vortex_splash")
        inst.AnimState:PushAnimation("vortex_idle_full",true)   
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/endswell/splash") 

        local value = 1
        if item.prefab == "nightmarefuel" then
            value = 100
        elseif item.prefab == "redgem" or item.prefab == "bluegem" or item.prefab == "orangegem" or item.prefab == "yellowgem" or item.prefab == "greengem" then
            value = 50               
        end

        value = value + math.random()*100

        inst:DoTaskInTime(1, function()
                local gems = 0
                if value < 100 then
                    if math.random() <= 0.6 then
                        SpawnAt("crawlingnightmare",inst)
                    else
                        SpawnAt("nightmarebeak",inst)
                    end
                elseif value < 150 then
                        gems = 1
                elseif value < 200 then
                       gems = 3
                end

                if gems > 0 then
                    inst.AnimState:PlayAnimation("vortex_splash")
                    inst.AnimState:PushAnimation("vortex_idle_full",true)   
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/endswell/splash")                     
                    for k = 1, gems do
                        local nug = SpawnPrefab("purplegem")
                        local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
                        
                        nug.Transform:SetPosition(pt:Get())
                        local down = TheCamera:GetDownVec()
                        local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
                        --local angle = (-TUNING.CAM_ROT-90 + math.random()*60-30)/180*PI
                        local sp = math.random()*4+2
                        nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
                        nug.components.inventoryitem:OnStartFalling()
                    end
                end
        end)

    end
end

local function decofn(build, bank, animframe, data )

    local function fn(Sim)
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()

        anim:SetBuild(build)
        anim:SetBank(bank)
        anim:PlayAnimation(animframe, true)
        -- anim:SetOrientation(ANIM_ORIENTATION.RotatingBillboard)  

        local minimap = inst.entity:AddMiniMapEntity()        
        minimap:SetIcon("pig_ruins_well.png")
		
		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

        inst:AddTag("blocker")
        inst.entity:AddPhysics()
        inst.Physics:SetMass(0)
        inst.Physics:SetCapsule(2,1.0)
        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)  
        -- inst.Physics:CollidesWith(COLLISION.INTWALL)     

        if data and data.vortex then
            inst:AddTag("vortex")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/endswell/hum_LP","doom")            
            minimap:SetIcon("pig_ruins_well_vortex.png")
        end

        inst:AddComponent("trader")
        inst.components.trader:SetAcceptTest(ShouldAcceptItem)
        inst.components.trader.onaccept = OnGetItemFromPlayer
        inst.components.trader.onrefuse = OnRefuseItem

        inst:AddComponent("inspectable")

        inst.OnSave = onsave 
        inst.OnLoad = onload
        inst.LoadPostPass = loadpostpass

        anim:SetTime(math.random() * anim:GetCurrentAnimationLength())

        return inst
    end
    return fn
end

local function deco(name, build, bank, anim, data)
    return Prefab("deco/"..name, decofn(build, bank, anim, data), assets, prefabs)
end

return  deco("deco_ruins_fountain", "pig_ruins_well","pig_ruins_well","idle_full"),
        deco("deco_ruins_endswell", "pig_ruins_well","pig_ruins_well","vortex_idle_full",{vortex=true})