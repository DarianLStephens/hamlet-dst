local assets =
{
    Asset("ANIM", "anim/interior_unique.zip"),      
    Asset("ANIM", "anim/interior_sconce.zip"),  
    Asset("ANIM", "anim/interior_defect.zip"),  
    Asset("ANIM", "anim/interior_decor.zip"),  
    Asset("ANIM", "anim/interior_pillar.zip"),  
    Asset("ANIM", "anim/ceiling_lights.zip"),
    Asset("ANIM", "anim/containers.zip"),
    Asset("ANIM", "anim/interior_floor_decor.zip"),
    Asset("ANIM", "anim/interior_window.zip"),
    Asset("ANIM", "anim/interior_window_burlap.zip"),
    Asset("ANIM", "anim/interior_window_lightfx.zip"),
    Asset("ANIM", "anim/window_arcane_build.zip"),

    Asset("ANIM", "anim/interior_wall_decals.zip"),
    Asset("ANIM", "anim/interior_wall_decals_hoofspa.zip"),
    Asset("ANIM", "anim/interior_wall_mirror.zip"),
    Asset("ANIM", "anim/interior_chair.zip"),
   
    Asset("ANIM", "anim/interior_wall_decals_antcave.zip"),
    Asset("ANIM", "anim/interior_wall_decals_antiquities.zip"),
    Asset("ANIM", "anim/interior_wall_decals_arcane.zip"),
    Asset("ANIM", "anim/interior_wall_decals_batcave.zip"),
    Asset("ANIM", "anim/interior_wall_decals_deli.zip"),
    Asset("ANIM", "anim/interior_wall_decals_florist.zip"),
    Asset("ANIM", "anim/interior_wall_decals_mayorsoffice.zip"),
    Asset("ANIM", "anim/interior_wall_decals_palace.zip"),
    Asset("ANIM", "anim/interior_wall_decals_ruins.zip"),
    Asset("ANIM", "anim/interior_wall_decals_ruins_blue.zip"),    
    Asset("ANIM", "anim/interior_wall_decals_accademia.zip"),
    Asset("ANIM", "anim/interior_wall_decals_millinery.zip"),
    Asset("ANIM", "anim/interior_wall_decals_weapons.zip"),

    Asset("ANIM", "anim/interior_wallornament.zip"),

    Asset("ANIM", "anim/window_mayorsoffice.zip"),
    Asset("ANIM", "anim/window_palace.zip"),
    Asset("ANIM", "anim/window_palace_stainglass.zip"),

    Asset("ANIM", "anim/interior_plant.zip"),
    Asset("ANIM", "anim/interior_table.zip"),
    Asset("ANIM", "anim/interior_floorlamp.zip"),

    Asset("ANIM", "anim/interior_window_small.zip"),
    Asset("ANIM", "anim/interior_window_large.zip"),
    Asset("ANIM", "anim/interior_window_tall.zip"),
    Asset("ANIM", "anim/interior_window_greenhouse.zip"),  
    Asset("ANIM", "anim/interior_window_greenhouse_build.zip"),  
    
    Asset("ANIM", "anim/window_weapons_build.zip"),

    Asset("ANIM", "anim/pig_ruins_well.zip"),
    Asset("ANIM", "anim/ceiling_decor.zip"),
    Asset("ANIM", "anim/light_dust_fx.zip"),
}

local prefabs =
{
    "swinglightobject",
    "deco_roomglow",
    "deco_wood_cornerbeam_placer",
}

local function Smash(inst, worker)
    if inst.components.lootdropper then
        local interior = worker and worker.components.interiorplayer
        if interior then
            local originpt = {x = interior.camx, z = interior.camz}
            local x, y, z = inst.Transform:GetWorldPosition()
            local dropdir = Vector3(originpt.x - x, 0.0, originpt.z - z):GetNormalized()
            inst.components.lootdropper.dropdir = dropdir
            inst.components.lootdropper:DropLoot()
        end
    end

    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")

    inst:Remove()
end    

local function SetPlayerUncraftable(inst)
	inst:RemoveTag("NOCLICK")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(Smash)
end

local function SmashNearObjects(inst, tag)
    if inst:HasTag(tag) then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 1, {tag})
        for i,ent in ipairs(ents) do
            if ent ~= inst then
                Smash(ent)
            end
        end
    end 
end

local function OnBuiltFn(inst)
    SetPlayerUncraftable(inst)
    inst.onbuilt = true

    SmashNearObjects(inst, "cornerpost")
    SmashNearObjects(inst, "centerlight")
    SmashNearObjects(inst, "wallsection")          
end

local function OnWork(inst, instant)
    local workleft = inst.components.workable.workleft
    local animlevel = workleft/TUNING.DECO_RUINS_BEAM_WORK
    if animlevel <= 0 then
        if not instant then
            inst.AnimState:PlayAnimation("pillar_front_crumble")
            inst.AnimState:PushAnimation("pillar_front_crumble_idle")
        else
            inst.AnimState:PlayAnimation("pillar_front_crumble_idle")
        end
    elseif animlevel < 1/3 then
        inst.AnimState:PlayAnimation("pillar_front_break_2")
    elseif animlevel < 2/3 then
        inst.AnimState:PlayAnimation("pillar_front_break_1")
    end
    if workleft <= 0 then
        inst.components.workable:SetWorkable(false)
    end
end

local function OnSave(inst, data)    
    local references = {}
    data.rotation = inst.Transform:GetRotation()
    local pt = Vector3(inst.Transform:GetScale())
    data.scalex = pt.x
    data.scaley = pt.y
    data.scalez = pt.z

    if inst.sunraysspawned then
        data.sunraysspawned = inst.sunraysspawned
    end

    if inst.childrenspawned then
        data.childrenspawned = inst.childrenspawned 
    end

    if inst.flipped then
        data.flipped = inst.flipped
    end    
    if inst.setbackground then
        data.setbackground = inst.setbackground
    end
    
    data.dartthrower = inst:HasTag("dartthrower")
    data.dartthrower_right = inst:HasTag("dartthrower_right")
    data.dartthrower_left = inst:HasTag("dartthrower_left")
    data.playercrafted = inst:HasTag("playercrafted")
    data.roc_cave_delete_me = inst:HasTag("roc_cave_delete_me")
    
    data.children = {}
    if inst.decochildrenToRemove then
        for i, child in ipairs(inst.decochildrenToRemove) do
            table.insert(data.children, child.GUID)
            table.insert(references, child.GUID)
        end
    end

    if inst.dust then
        data.dust = inst.dust.GUID
        table.insert(references, data.dust)
    end

    if inst.swinglight then
        data.swinglight = inst.swinglight.GUID
        table.insert(references, data.swinglight)
    end    

    if inst.animdata then
        data.animdata = inst.animdata
    end

    if inst.onbuilt then
        data.onbuilt = inst.onbuilt
    end
    if inst.recipeproxy then
        data.recipeproxy = inst.recipeproxy
    end

    return references
end

local function OnLoad(inst, data)
    if data.rotation then
        inst.Transform:SetRotation(data.rotation)
    end
    if data.scalex  then
        inst.Transform:SetScale( data.scalex, data.scaley, data.scalez)
    end
    if data.sunraysspawned then
        inst.sunraysspawned = data.sunraysspawned
    end  
    if data.childrenspawned then
        inst.childrenspawned = data.childrenspawned
    end
    if data.flipped then
        inst.flipped = data.flipped        
        inst.AnimState:SetScale(-1,1,1)
    end       
    if data.dartthrower then
       inst:AddTag("dartthrower")
    end
    if data.dartthrower_right then
        inst:AddTag("dartthrower_right")
    end
    if  data.dartthrower_left then
        inst:AddTag("dartthrower_left")
    end
    if data.playercrafted then
        inst:AddTag("playercrafted")
    end    
    if data.setbackground then
        inst.AnimState:SetLayer( LAYER_WORLD_BACKGROUND )
        inst.AnimState:SetSortOrder(data.setbackground)   
        inst.setbackground = data.setbackground
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
        
    if data.onbuilt then
        SetPlayerUncraftable(inst)
    end

    if data.recipeproxy then
        inst.recipeproxy = data.recipeproxy
    end 

    if data.roc_cave_delete_me then    
        inst:AddTag("roc_cave_delete_me")
    end    
end

local function LoadPostPass(inst,ents, data)
    if data then
        if data.swinglight then  
            local swinglight = ents[data.swinglight]
            if swinglight then
                inst.swinglight = swinglight.entity
            end
        end
        if data.dust then  
            local dust = ents[data.dust]
            if dust then
                inst.dust = dust.entity
            end
        end  

        inst.decochildrenToRemove = {}
        if data.children then
            for i,child in ipairs(data.children) do
                local childent = ents[child]
                if childent then
                    if inst.Transform:GetRotation() > 0 then
                        childent.entity.AnimState:SetScale(-1,1,1)
                    end
                    table.insert(inst.decochildrenToRemove, childent.entity)
                end
            end
        end              
    end
    if inst.updateworkableart then        
        OnWork(inst,true)      
    end
end

local function onremove(inst)
    if inst.decochildrenToRemove then
        for i,child in ipairs(inst.decochildrenToRemove) do
            child:Remove()
        end
    end

    if inst.swinglight then
        inst.swinglight:Remove()
    end
    if inst.dust then
        inst.dust:Remove()
    end
end

local function UpdateTime(inst)    
	local phase = TheWorld.state.phase
    if phase == "day" then
        inst.AnimState:PlayAnimation("to_day")
        inst.AnimState:PushAnimation("day_loop", true)
    elseif phase == "night" then
        inst.AnimState:PlayAnimation("to_night")
        inst.AnimState:PushAnimation("night_loop", true)
    elseif phase == "dusk" then
        inst.AnimState:PlayAnimation("to_dusk")
        inst.AnimState:PushAnimation("dusk_loop", true)
    end
end

local function MirrorIdle(inst)
    if inst.isneer then
        inst.AnimState:PlayAnimation("shadow_blink")
        inst.AnimState:PushAnimation("shadow_idle", true)
    end
    inst.blink_task = inst:DoTaskInTime(10 + (math.random()*50), function() MirrorIdle(inst) end) 
end

local function MirrorNear(inst)
    inst.AnimState:PlayAnimation("shadow_in")
    inst.AnimState:PushAnimation("shadow_idle", true)

    inst.blink_task = inst:DoTaskInTime(10 + (math.random()*50), function() MirrorIdle(inst) end) 
    inst.isneer = true
end

local function MirrorFar(inst)
    if inst.isneer then        
        inst.AnimState:PlayAnimation("shadow_out")
        inst.AnimState:PushAnimation("idle", true)    
        inst.isneer = nil
        inst.blink_task:Cancel()
        inst.blink_task = nil
    end
end

local function SwapColor(inst, light)
    if inst.iswhite then
        inst.iswhite = false
        inst.isred = true
        inst.components.lighttweener:StartTween(light, Lerp(0, 3, 1), nil, nil, {240/255, 100/255, 100/255}, 0.2, SwapColor)
    elseif inst.isred then
        inst.isred = false
        inst.isgreen = true
        inst.components.lighttweener:StartTween(light, Lerp(0, 3, 1), nil, nil, {240/255, 230/255, 100/255}, 0.2, SwapColor)
    else
        inst.isgreen = false
        inst.iswhite =true
        inst.components.lighttweener:StartTween(light, Lerp(0, 3, 1), nil, nil, {100/255, 240/255, 100/255}, 0.2, SwapColor)
    end
end    

local function MakePhysics(inst, name)
    if name then
        if name == "sofa_physics" then
            MakeInteriorPhysics(inst, 1, 1.3, 0.2)
        elseif name == "sofa_physics_vert" then
            MakeInteriorPhysics(inst, 1, 0.2, 1.3)                
        elseif name == "chair_physics_small" then
            MakeObstaclePhysics(inst, .5)   
        elseif name == "chair_physics" then
            MakeInteriorPhysics(inst, 1, 1, 1)
        elseif name == "desk_physics" then
            MakeInteriorPhysics(inst, 1, 2, 1)
        elseif name == "tree_physics" then
            inst:AddTag("blocker")
            inst.entity:AddPhysics()
            inst.Physics:SetMass(0)
            inst.Physics:SetCylinder(4.7, 4.0)
            inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.ITEMS)
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        elseif name == "pond_physics" then
            inst:AddTag("blocker")
            inst.entity:AddPhysics()
            inst.Physics:SetMass(0)
            inst.Physics:SetCylinder(1.6, 4.0)
            inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.ITEMS)
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        elseif name == "big_post_physics" then
            MakeObstaclePhysics(inst, 0.75)
        elseif name == "post_physics" then
            MakeObstaclePhysics(inst, .25)
        end
    end
end

local function fn(name, build, bank, anim, data)
    if not data then
        data = {}
    end    

    local function fn(Sim)
        local inst = CreateEntity()
        
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        if data.minimapicon then
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon(data.minimapicon)
        end

        if data.light then
            inst.entity:AddLight()
        end

        MakePhysics(inst, data.physics)

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(anim, data.loopanim)

        if data.background then
            inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
            inst.AnimState:SetSortOrder(data.background)   
            inst.setbackground = data.background
        end

        if data.scale then
            inst.AnimState:SetScale(data.scale.x, data.scale.y, data.data.scale.z)
        end

        if data.loopanim then
            inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
        end

        if not data.curtains then
            inst.AnimState:Hide("curtain")
        end

        if data.bloom then
            inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
        end

        if data.decal then
            ----inst.AnimState:SetOrientation(ANIM_ORIENTATION.RotatingBillboard)       
        else
            inst.Transform:SetTwoFaced()
        end

        inst.Transform:SetRotation(-90)

        for i, tag in ipairs(data.tags or {}) do
            inst:AddTag(tag)
        end

        if data.light then
            if not data.followlight then
                inst.Light:SetIntensity(data.light.intensity)
                inst.Light:SetColour(data.light.color[1], data.light.color[2], data.light.color[3])
                inst.Light:SetFalloff(data.light.falloff)
                inst.Light:SetRadius(data.light.radius)
                inst.Light:Enable(true)

                inst:AddComponent("fader")
            end

            if data.blink then
                inst:AddComponent("lighttweener")

                SwapColor(inst, inst.Light)         
            end
        end

        if data.recipeproxy then
            inst.recipeproxy = data.recipeproxy
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        if data.light then
            if data.followlight then
                inst:DoTaskInTime(0, function()
                    if not inst.sunraysspawned then
                        inst.swinglight = SpawnPrefab("swinglightobject")
                        inst.swinglight:SetLightType(data.followlight)
                        if data.windowlight then
                            inst.swinglight:SetListenEvents()                           
                        end                        
                        local follower = inst.swinglight.entity:AddFollower()
                        follower:FollowSymbol( inst.GUID, "light_circle", 0, 0, 0 )
                        inst.swinglight.followobject =  {GUID=inst.GUID, symbol="light_circle", x=0, y=0, z=0}
                        inst.sunraysspawned = true
                    end
                end)
            end
        end

        if data.children then
            inst:DoTaskInTime(0,function()
                if not inst.childrenspawned then
                    for i, child in ipairs(data.children) do                    
                        local childprop = SpawnPrefab(child)
                        local pt = Vector3(inst.Transform:GetWorldPosition())
                        
                        if inst.flipped and childprop.AnimState then
                            childprop.AnimState:SetScale(-1,1,1)
                        end

                        childprop.Transform:SetPosition(pt.x ,pt.y, pt.z)
                        childprop.Transform:SetRotation(inst.Transform:GetRotation())
                        if not inst.decochildrenToRemove then
                            inst.decochildrenToRemove = {}
                        end       
                        table.insert(inst.decochildrenToRemove,childprop)
                    end
                    inst.childrenspawned = true
                end
           end)
        end

        local name_override = (data.recipeproxy or data.name_override)
        if name_override or data.workable or data.prefabname or STRINGS.NAMES[string.upper(name)] then
            inst:AddComponent("inspectable")

            if name_override then
                inst.name = STRINGS.NAMES[name_override:upper()]
                inst.components.inspectable.nameoverride = name_override
            end

            if data.prefabname then
                inst:SetPrefabName(data.prefabname)
            end    
        end

        if data.dayevents then
            inst:WatchWorldState("phase", UpdateTime)
            UpdateTime(inst, TheWorld.state.phase)
        end

        if data.mirror then
            inst:AddComponent("playerprox")
            inst.components.playerprox:SetOnPlayerNear(MirrorNear)
            inst.components.playerprox:SetOnPlayerFar(MirrorFar)
            inst.components.playerprox:SetDist(2, 2.1)
        end

        if data.workable then
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.MINE)
            inst.components.workable:SetWorkLeft(TUNING.DECO_RUINS_BEAM_WORK)
            inst.components.workable:SetMaxWork(TUNING.DECO_RUINS_BEAM_WORK)
            inst.components.workable.savestate = true
            inst.components.workable:SetOnWorkCallback(function(inst, worker, workleft)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
                
                OnWork(inst)

                if TheWorld.components.interiorquaker then
                    if workleft <= 0 then
                        TheWorld.components.interiorquaker:ForceQuake("cavein", inst)                            
                    else
                        TheWorld.components.interiorquaker:ForceQuake("pillarshake", inst)
                    end
                end
            end)
            inst.updateworkableart = true
        end

        if data.prefabname == "pig_latin_1" then
            inst:AddTag("pig_writing_1")
            TheWorld:ListenForEvent("doorused", function(world, data) 
                if not inst:HasTag("INTERIOR_LIMBO") then
                    inst:DoTaskInTime(1, function()
                        local pt = Vector3(inst.Transform:GetWorldPosition())
                        local torches = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, {"wall_torch"}, {"INTERIOR_LIMBO"})
                        local closedoors = false
                        for i,torch in ipairs(torches)do
                            if not torch.components.cooker then
                                closedoors = true
                            end
                        end

                        if closedoors then
                            local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, {"lockable_door"}, {"INTERIOR_LIMBO"})
                            for i, ent in ipairs(ents)do
                                if ent ~= data.door then
                                    ent:PushEvent("close")
                                end
                            end
                        end
                    end)
                end
            end, TheWorld)


            inst:ListenForEvent("fire_lit", function() 
                local opendoors = true
                local pt = Vector3(inst.Transform:GetWorldPosition())
                local torches = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, {"wall_torch"}, {"INTERIOR_LIMBO"})

                for i,torch in ipairs(torches)do
                    if not torch.components.cooker then
                        opendoors = false
                    end
                end

                if opendoors then
                    local pt = Vector3(inst.Transform:GetWorldPosition())
                    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO"})
                    for i, ent in ipairs(ents)do
                        if ent:HasTag("lockable_door") then
                            ent:PushEvent("open")
                        end
                    end
                end                   
            end)
        end

        inst:ListenForEvent("onremove", onremove)
        
        inst:DoTaskInTime(0,function() 
            if inst:HasTag("playercrafted") then
                SetPlayerUncraftable(inst)
            end
        end)

        if data.onbuilt then
            inst.OnBuiltFn = OnBuiltFn        
        end

        inst.OnSave = OnSave 
        inst.OnLoad = OnLoad
        inst.LoadPostPass = LoadPostPass

        return inst
    end
    return fn
end

function _G.MakeInteriorDecor(name, build, bank, anim, data)
    return Prefab(name, fn(name, build, bank, anim, data), assets, prefabs)
end

function _G.GetInteriorLights()
    return {
        SUNBEAM =
        { 
            day  = {radius = 3, intensity = 0.75, falloff = 0.5, color = {1, 1, 1}},
            dusk = {radius = 2, intensity = 0.75, falloff = 0.5, color = {1/1.8, 1/1.8, 1/1.8}},
            full = {radius = 2, intensity = 0.75, falloff = 0.5, color = {0.8/1.8, 0.8/1.8, 1/1.8}}
        },
    
        SUNBEAM =
        { 
            intensity = 0.9,
            color     = {197/255, 197/255, 50/255},
            falloff   = 0.5,
            radius    = 2,
        },
    
        SMALL =
        { 
            intensity = 0.75,
            color     = {97/255, 197/255, 50/255},
            falloff   = 0.7,
            radius    = 1,
        },
    
        MED =
        { 
            intensity = 0.9,
            color     = {197/255, 197/255, 50/255},
            falloff   = 0.5,
            radius    = 3,
        },
    
        SMALL_YELLOW =
        { 
            intensity = 0.75,
            color     = {197/255, 197/255, 50/255},
            falloff   = 0.7,
            radius    = 1,
        },
        FESTIVETREE = 
        { 
            intensity = 0.9,
            color     = {197/255, 197/255, 50/255},
            falloff   = 0.5,
            radius    = 3,
        },
    }
end
