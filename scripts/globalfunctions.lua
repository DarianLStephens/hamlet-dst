require("utils/deco_util")
require("utils/deco_placer_util")

function _G.GetClosestInterior(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    local interior = TheSim:FindEntities(x, y, z, 20, nil, nil, {"interior_collision"})[1]
    --You should add here checking for current interior
    return interior
end

function _G.MakeInteriorPhysics(inst, depth, height, width)
    height = height or 20

    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    inst.Physics:SetMass(0) 
    --inst.Physics:SetCollisionGroup(COLLISION.INTWALL) -- GetWorldCollision()
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)    
    
    inst:DoTaskInTime(0, function() inst.Physics:SetRectangle(depth, height, width) end)
end

function _G.MakeInteriorTexturePackage(name, facing, texture, groundsound)
	return Prefab(name, function(inst)
		local inst = CreateEntity()

		inst.entity:AddTransform()
	
		inst:AddTag("CLASSIFIED")
	
		--[[Non-networked entity]]
		inst.persists = false

		--Auto-remove if not spawned by builder
		inst:DoTaskInTime(0, inst.Remove)
	
		if not TheWorld.ismastersim then
			return inst
		end
	
		inst.OnBuiltFn = function(inst, builder)
			if builder then
				local interior = builder.components.interiorplayer
				
				if not interior then
					return
				end

                if facing == INTERIORFACING.FLOOR then
					interior.floortexture = texture
					interior.groundsound = groundsound
				end

				if facing == INTERIORFACING.WALL then
					interior.walltexture = texture
				end

                interior:UpdateCamera()
				inst:Remove()
			end
		end

		return inst
	end)
end

--Thx Hornet
function _G.PixelToUnit(pixels)
	return pixels/150
end

function _G.UnitToPixel(units)
	return units*150
end

function _G.CreateRoom(data)
    local SHADER = "shaders/interior.ksh"
    local SCALE_DEPTH = "interior"..data.id.."depth"
    local SCALE_HEIGHT = "interior"..data.id.."height"
    local SCALE_HEIGHT_INVERTED = "interior"..data.id.."heightinv"

    local MAX_LIFETIME = 99999 --27 hours. Should be good enough aye?
    local MAX_PARTICLES1 = 1
    local MAX_PARTICLES2 = 2
    
    local assets =
    {
        Asset("SHADER", SHADER),
    }
    
    local function Envolve()
        local scale = UnitToPixel(data.depth) / 512 --only supports 512x512 textures rn
        EnvelopeManager:AddVector2Envelope(
            SCALE_DEPTH,
            {
                { 0,    { scale, scale } },
                { 1,    { scale, scale } },
            }
        )
        
        scale = UnitToPixel(data.height) / 512
        EnvelopeManager:AddVector2Envelope(
            SCALE_HEIGHT,
            {
                { 0,    { -scale, -scale * 1.064 } }, --why do I seemingly randomly increase height scale by this arbitrary amount? Well, Hamlet's walls are slightly taller too for some reason, I do not know the exact value
                { 1,    { -scale, -scale * 1.064 } },
            }
        )
        EnvelopeManager:AddVector2Envelope(
            SCALE_HEIGHT_INVERTED,
            {
                { 0,    { scale, -scale * 1.064 } },
                { 1,    { scale, -scale * 1.064 } },
            }
        )
        Envolve = nil
    end
    
    local function emit(inst, emitter, pos, uv)
        uv = uv or {}
    
        inst.VFXEffect:AddParticle(
            emitter or 0,
            MAX_LIFETIME,   -- lifetime
            (pos.x or 0), (pos.y or 0), (pos.z or 0),     -- position
            0, 0, 0			-- velocity
        )
    end
    
    local function fn()
        local inst = CreateEntity()
    
        inst:AddTag("FX")
        inst:AddTag("interior")
    
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
    
        inst.persists = false
        
        if Envolve then
            Envolve()
        end
        
        inst.entity:SetPristine()
    
        -----------------------------------------------------
    
        --Dedicated does not need to spawn local vfx
        if TheNet:IsDedicated() then 
            return inst 
        end
    
        local effect = inst.entity:AddVFXEffect()
        effect:InitEmitters(4)
        effect:SetRenderResources(0, resolvefilepath(data.floortex), resolvefilepath(SHADER)) 
        effect:SetMaxNumParticles(0, MAX_PARTICLES1)
        effect:SetMaxLifetime(0, MAX_LIFETIME)
        effect:SetSpawnVectors(0,
            0, 0, -1,
            1, 0, 0
        )
        effect:SetUVFrameSize(0, -1.5, 1)
        effect:SetKillOnEntityDeath(0, true)
        effect:SetLayer(0, LAYER_BACKDROP)

        effect:SetRenderResources(1, resolvefilepath(data.walltex), resolvefilepath(SHADER))
        effect:SetMaxNumParticles(1, MAX_PARTICLES2)
        effect:SetMaxLifetime(1, MAX_LIFETIME)
        effect:SetSpawnVectors(1,
            1, 0, 0,
            -.5, 1, 0
        )
        effect:SetUVFrameSize(1, 2, 1)
        effect:SetKillOnEntityDeath(1, true)
        effect:SetLayer(1, LAYER_BACKDROP)
        
        effect:SetRenderResources(2, resolvefilepath(data.walltex), resolvefilepath(SHADER))
        effect:SetMaxNumParticles(2, MAX_PARTICLES2)
        effect:SetMaxLifetime(2, MAX_LIFETIME)
        effect:SetSpawnVectors(2,
            1, 0, 0,
            -.5, 1, 0
        )
        effect:SetUVFrameSize(2, 2, 1)
        effect:SetKillOnEntityDeath(2, true)
        effect:SetLayer(2, LAYER_BACKDROP)

        effect:SetRenderResources(3, resolvefilepath(data.walltex), resolvefilepath(SHADER))
        effect:SetMaxNumParticles(3, MAX_PARTICLES1)
        effect:SetMaxLifetime(3, MAX_LIFETIME)
        effect:SetSpawnVectors(3,
            0, 0, 1,
            -.5, 1, 0
        )
        effect:SetUVFrameSize(3, 3, 1)
        effect:SetKillOnEntityDeath(3, true)
        effect:SetLayer(3, LAYER_BACKDROP)
    
        inst:DoTaskInTime(0, function()
            --TODO, currently assumes 512x512 is the texture width/length, this needs to change
            local heightscale = UnitToPixel(data.height) / 512
            local scale = UnitToPixel(data.depth) / 512
            local height = PixelToUnit(512 * heightscale) / 2
            local realheight = height * 0.948 --magic number
            local halfwidth = data.width/2
            local halfdepth = data.depth/2
            local extrawidth = height/math.tan(math.rad(64.3589)) --this should be 60 degrees(or pi/3) but its... just not I guess? this looks more accurate in-game so um, yea, let's go with it
            
            --i am really shit with math, as you can tell.
            
            inst.VFXEffect:SetScaleEnvelope(0, SCALE_DEPTH)
            inst.VFXEffect:SetUVFrameSize(0, -data.width/data.depth, 1)
    
            inst.VFXEffect:SetScaleEnvelope(1, SCALE_HEIGHT_INVERTED)
            inst.VFXEffect:SetUVFrameSize(1, -data.depth/data.height, 1)
            
            inst.VFXEffect:SetScaleEnvelope(2, SCALE_HEIGHT)
            inst.VFXEffect:SetUVFrameSize(2, -data.depth/data.height, 1)
            
            inst.VFXEffect:SetScaleEnvelope(3, SCALE_HEIGHT)
            inst.VFXEffect:SetUVFrameSize(3, -data.width/data.height, 1)
    
            emit(inst, 0, {x = 0, y = 0, z = 0}) --floor
            emit(inst, 1, {x = -extrawidth, y = realheight, z = -halfwidth}) --side wall
            emit(inst, 2, {x = -extrawidth, y = realheight, z = halfwidth}) --side wall
            emit(inst, 3, {x = -halfdepth-extrawidth, y = realheight, z = 0}) --back wall
        end)
        
        return inst
    end

    if Prefabs["interior_dyn"] then
        TheSim:UnloadPrefabs({"interior_dyn"})
        TheSim:UnregisterPrefabs({"interior_dyn"})	
		local count = 0
		for k,ent in pairs(Ents) do
			-- for i,tag in ipairs(arg) do
				if ent == "interior_dyn" then
					ent:Remove()
					count = count + 1
					break
				end
			-- end
		end
		print("removed",count)
    end
    local prefab = Prefab("interior_dyn", fn, assets)
    RegisterSinglePrefab(prefab)
    TheSim:LoadPrefabs({name})
    return SpawnPrefab("interior_dyn")
end
