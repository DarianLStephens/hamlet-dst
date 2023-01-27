local assets =
{
	Asset("ANIM", "anim/lamp_post2.zip"),
    Asset("ANIM", "anim/lamp_post2_city_build.zip"),    
}

local INTENSITY = .6



local function fadein(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("on")
    inst.AnimState:PushAnimation("idle", true)
    inst.Light:Enable(true)
	if inst:IsAsleep() then
		inst.Light:SetIntensity(INTENSITY)
	else
		inst.Light:SetIntensity(0)
		inst.components.fader:Fade(0, INTENSITY, 3+math.random()*2, function(v) inst.Light:SetIntensity(v) end, function() inst:RemoveTag("NOCLICK") end)
	end
end

local function fadeout(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("off")
    inst.AnimState:PushAnimation("idle", true)
	if inst:IsAsleep() then
		inst.Light:SetIntensity(0)
	else
		inst.components.fader:Fade(INTENSITY, 0, .75+math.random()*1, function(v) inst.Light:SetIntensity(v) end, function() inst:AddTag("NOCLICK") inst.Light:Enable(false) end)
	end
end

local function updatelight(inst)
    if GetClock():IsDusk() then
        if not inst.lighton then
            inst:DoTaskInTime(math.random()*2,function() 
                fadein(inst)
            end)

        else            
            inst.Light:Enable(true)
            inst.Light:SetIntensity(INTENSITY)
        end
        inst.AnimState:Show("FIRE")
        inst.AnimState:Show("GLOW")        
        inst.lighton = true
        inst:RemoveTag("NOCLICK")
    else
        if inst.lighton then
            inst:DoTaskInTime(math.random()*2,function() 
                fadeout(inst)
            end)            
        else
            inst.Light:Enable(false)
            inst.Light:SetIntensity(0)
        end

        inst.AnimState:Hide("FIRE")
        inst.AnimState:Hide("GLOW")        

        inst.lighton = false
        inst:AddTag("NOCLICK")
    end
end

local function fn(Sim)

	local inst = CreateEntity()

    inst:AddTag("CITY_LAMP")
    inst:AddTag("NOCLICK")
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.entity:AddPhysics()
 
    MakeObstaclePhysics(inst, .25)   

    local light = inst.entity:AddLight()
    light:SetFalloff(1)
    light:SetIntensity(INTENSITY)
--    light:SetRadius(1)
--    light:SetColour(180/255, 195/255, 150/255)

--    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(197/255,197/255,10/255)
    inst.Light:SetFalloff( 0.9 )
    inst.Light:SetRadius( 15 )
    inst.Light:SetIntensity(INTENSITY)
    light:Enable(true)
    inst.AnimState:Show("FIRE")
    inst.AnimState:Show("GLOW") 
    
    --inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    
    inst.AnimState:SetBank("lamp_post")
    inst.AnimState:SetBuild("lamp_post2_city_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:SetRayTestOnBB(true);

    inst:AddComponent("inspectable")

    inst:AddComponent("fader")
    
    return inst
end

return Prefab( "common/objects/city_lamp_inside", fn, assets) 

