local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(197/255/2, 197/255/2, 50/255/2)
    inst.Light:SetFalloff(.5)
    inst.Light:SetRadius(6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetLarge = function(val)
        if val then
            inst.Light:SetRadius(6)
        else
            inst.Light:SetRadius(9)
        end
    end

    return inst
end

return Prefab( "deco_roomglow", fn)
