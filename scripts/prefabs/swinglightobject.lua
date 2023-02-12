local MULT = 0.8 

local lighttypes = {
    natural = {
        day = {rad=3,intensity=0.75,falloff=0.5,color={1*MULT,1*MULT,1*MULT}},
        dusk = {rad=2,intensity=0.75,falloff=0.5,color={1/1.8*MULT,1/1.8*MULT,1/1.8*MULT}},
        full = {rad=2,intensity=0.75,falloff=0.5,color={0.8/1.8*MULT,0.8/1.8*MULT,1/1.8*MULT}}
    },
    electric_1 = {
        day = {rad=3,intensity=0.9,falloff=0.5,color={197/255,197/255,50/255}},
    },    
}


local function turnoff(inst, light)
    if light then
        light:Enable(false)
    end   
end

local phasefunctions = 
{
    day = function(inst, instant)
        local lights = lighttypes[inst.lighttype]
        if not inst:IsInLimbo() then inst.Light:Enable(true) end
        local time = 2
        if instant then time = 0 end
        inst.components.lighttweener:StartTween(nil, lights.day.rad, lights.day.intensity, lights.day.falloff, {lights.day.color[1],lights.day.color[2],lights.day.color[3]}, time)
    end,

    dusk = function(inst, instant) 
        local lights = lighttypes[inst.lighttype]
        if not inst:IsInLimbo() then inst.Light:Enable(true) end       
        local time = 2
        if instant then time = 0 end        
        inst.components.lighttweener:StartTween(nil, lights.dusk.rad, lights.dusk.intensity, lights.dusk.falloff, {lights.dusk.color[1],lights.dusk.color[2],lights.dusk.color[3]}, time)
    end,

    night = function(inst, instant) 
        local lights = lighttypes[inst.lighttype]
        if TheWorld.state.isfullmoon then
            local time = 4
            if instant then time = 0 end            
            inst.components.lighttweener:StartTween(nil, lights.full.rad, lights.full.intensity, lights.full.falloff, {lights.full.color[1],lights.full.color[2],lights.full.color[3]}, time)
        else
            inst.components.lighttweener:StartTween(nil, 0, 0, 1, {0,0,0}, 6, turnoff)
        end    
    end,
}

local function UpdateTime(inst, instant)    
	local phase = TheWorld.state.phase
    if inst.Light then
        phasefunctions[phase](inst, instant)
    end
end

local function SetListenEvents(inst)
    inst:AddComponent("lighttweener")
    local lights = lighttypes[inst.lighttype]
    inst.components.lighttweener:StartTween(inst.Light, lights.day.rad, lights.day.intensity, lights.day.falloff, {lights.day.color[1],lights.day.color[2],lights.day.color[3]}, 0)

    inst:WatchWorldState("phase", UpdateTime)
    UpdateTime(inst, TheWorld.state.phase)

    inst.daytimeevents = true
end
local function SetLightType(inst, lighttype)
    if lighttypes[lighttype] then
        inst.lighttype = lighttype    
        inst.Light:SetIntensity(lighttypes[inst.lighttype].day.intensity)
        inst.Light:SetColour(lighttypes[inst.lighttype].day.color[1],lighttypes[inst.lighttype].day.color[2],lighttypes[inst.lighttype].day.color[3])
        inst.Light:SetFalloff( lighttypes[inst.lighttype].day.falloff )
        inst.Light:SetRadius( lighttypes[inst.lighttype].day.rad )           
    end
end

local function onsave(inst, data)
    if inst.daytimeevents then
        data.daytimeevents = inst.daytimeevents
    end
    if inst.followobject then
        data.followobject = inst.followobject
    end
    if inst.lighttype then
        data.lighttype = inst.lighttype
    end
end

local function onload(inst, data)
    if data.lighttype then
        inst.lighttype = data.lighttype
        inst.Light:SetIntensity(lighttypes[inst.lighttype].day.intensity)
        inst.Light:SetColour(lighttypes[inst.lighttype].day.color[1],lighttypes[inst.lighttype].day.color[2],lighttypes[inst.lighttype].day.color[3])
        inst.Light:SetFalloff( lighttypes[inst.lighttype].day.falloff )
        inst.Light:SetRadius( lighttypes[inst.lighttype].day.rad )         
    end     
    if data and data.daytimeevents then
        SetListenEvents(inst)
    end     
end

local function OnLoadPostPass(inst, data)
    if data then
        if data.followobject then
            local follower = object.entity:AddFollower()
            follower:FollowSymbol( data.followobject.GUID, data.followobject.symbol, data.followobject.x,data.followobject.y,data.followobject.z ) 
            inst.followobject = data.followobject
        end        
    end        
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("swinglight")
    inst:AddTag("NOBLOCK")

    inst.lighttype = "natural"

    inst.Light:SetIntensity(lighttypes[inst.lighttype].day.intensity)
    inst.Light:SetColour(lighttypes[inst.lighttype].day.color[1],lighttypes[inst.lighttype].day.color[2],lighttypes[inst.lighttype].day.color[3])
    inst.Light:SetFalloff( lighttypes[inst.lighttype].day.falloff )
    inst.Light:SetRadius( lighttypes[inst.lighttype].day.rad )

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetListenEvents = SetListenEvents
    inst.SetLightType = SetLightType

    inst.OnSave = onsave 
    inst.OnLoad = onload

    return inst
end

return Prefab("swinglightobject", fn)
