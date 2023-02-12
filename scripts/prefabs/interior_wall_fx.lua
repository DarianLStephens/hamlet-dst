-- local TEXTURE = "data/levels/textures/interiors/pig_ruins_panel.tex"
-- local TEXTURE = "pig_ruins_panel.tex"
local TEXTURE = "ground_ruins_slab.tex"
local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "wall_colourenvelope"
local SCALE_ENVELOPE_NAME = "wall_scaleenvelope"

local FLOOR_MEDIUM_SCALE_ENVELOPE_NAME = "floor_medium_scaleenvelope"
local FLOOR_BIG_SCALE_ENVELOPE_NAME = "floor_big_scaleenvelope"
local SIDE_MEDIUM_SCALE_ENVELOPE_NAME = "side_wall_scaleenvelope"
local BACK_MEDIUM_SCALE_ENVELOPE_NAME = "back_wall_scaleenvelope"

local assets =
{
    -- Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

local iSetup = 0

local walltype = 0
-- 0 = floor
-- 1 = back wall
-- 2 = side wall
local ScaleOverride = nil
local SizeOverride = 1

-- local height = 2.345
-- local width = 2.345--1.175 --TEMP!
-- local height = 2--7 / 2
-- local width = 24 / 4--1.175 --TEMP!
-- -- local height = width
-- local height = 2.4

local height = 1
local width = 1

local big_height = 40
local big_width = 40

local medium_width = 24
local medium_height = 16

local default_height = 3.5 -- Default height of walls

-- Medium room measurements
local floor_medium_width = (medium_width / 2) * .6
local floor_medium_height = (medium_height / 2) * .6

local side_medium_width = (medium_height / 2) * .6
local side_medium_height = default_height

local back_medium_width = (medium_width / 2) * .6
local back_medium_height = default_height

-- local TileUV_X = width * 0.5
local TileUV_X = 0
local TileUV_Y = 0

local function InitEnvelopes()
	
	-- width = ThePlayer.replica.interiorplayer.interiorwidth
	-- height = ThePlayer.replica.interiorplayer.interiordepth
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    { 1, 1, 1, 1 } },
            { 1,    { 1, 1, 1, 1 } },
        }
    )

	print("Interior Wall FX - About to create scale with width ", width, ", height ", height)
	EnvelopeManager:AddVector2Envelope(
		SCALE_ENVELOPE_NAME,
		{
			{ 0,    { width, height } },
			{ 1,    { width, height } },
		}
	)

	EnvelopeManager:AddVector2Envelope(
		FLOOR_MEDIUM_SCALE_ENVELOPE_NAME,
		{
			{ 0,    { floor_medium_width, floor_medium_height } },
			{ 1,    { floor_medium_width, floor_medium_height } },
		}
	)

	EnvelopeManager:AddVector2Envelope(
		FLOOR_BIG_SCALE_ENVELOPE_NAME,
		{
			{ 0,    { big_width, big_height } },
			{ 1,    { big_width, big_height } },
		}
	)
	
	-- Side walls
	EnvelopeManager:AddVector2Envelope(
		SIDE_MEDIUM_SCALE_ENVELOPE_NAME,
		{
			{ 0,    { side_medium_width, side_medium_height } },
			{ 1,    { side_medium_width, side_medium_height } },
		}
	)
	
	-- Back wall
	EnvelopeManager:AddVector2Envelope(
		BACK_MEDIUM_SCALE_ENVELOPE_NAME,
		{
			{ 0,    { back_medium_width, back_medium_height } },
			{ 1,    { back_medium_width, back_medium_height } },
		}
	)

    InitEnvelopes = nil
end

local MAX_LIFETIME = 9999
local function emit_fn(inst, effect, scale)
	local angle = ((inst.angle or 0) + (90 * DEGREES)) or 0
    -- local uvoffset_x, uvoffset_y = Lerp(0.5,0, inst.uv_x or 0), Lerp(0.5,0, inst.uv_y or 1)   --Asura: here you can change position of cutting point use 1 or 0
	
	if scale == nil then
		scale = 1
	end
	
	-- inst.effect:SetUVFrameSize(0, scale, scale)
	
    -- local uvoffset_x, uvoffset_y = TileUV_X * scale, TileUV_Y * scale
    local uvoffset_x, uvoffset_y = TileUV_X, TileUV_Y
    -- effect:AddParticleUV(
        -- 0,
        -- MAX_LIFETIME,   -- lifetime
        -- math.sin(angle) * 1.5, height+height*.75, math.cos(angle) * 1.5,     -- position
        -- 0, 0, 0,			-- velocity
        -- uvoffset_x, uvoffset_y        -- uv offset
    -- )
	
	-- To move wall types off the ground, instead of having them sunk in to it
	local zOffset = 0
	if walltype > 0 then
		zOffset = height+height*.75
	end
	
    -- local particle = effect:AddParticleUV(
    effect:AddParticleUV(
        0,
        MAX_LIFETIME,   -- lifetime
        math.sin(angle) * 1.5, zOffset, math.cos(angle) * 1.5,     -- position
        0, 0, 0,			-- velocity
        uvoffset_x, uvoffset_y        -- uv offset
    )
	-- particle.Transform:SetScale(scale)
end

local function SetWallData(inst, texture, newwidth, newheight)
	inst.width = newwidth
	inst.height = newheight
	width = newwidth
	height = newheight
    -- self:SetTexture(inst, texture)
	inst.SetTexture(inst, texture)
	
	-- Maybe this'll work? I dunno
	-- InitEnvelopes()
	
	-- inst.Transform:SetScale(newwidth*4,newheight*4,1)
	-- inst.effect.Transform:SetScale(newwidth*4,newheight*4,1)
	
	-- EnvelopeManager:AddVector2Envelope(
		-- SCALE_ENVELOPE_NAME,
		-- {
			-- { 0,    { width, height } },
			-- { 1,    { width, height } },
		-- }
	-- )
	
	-- local fxwidth = 6.5 -- Basically just gotta guesstimate here, because I don't know how the game translate particle UV to world units
	local fxwidth = 3.25 --* SizeOverride
	-- if not SizeOverride == 1 then
		-- fxwidth == SizeOverride
	-- end
	
	if walltype == 1 or walltype == 2 then
		fxwidth = 1 -- More hacks, but maybe it'll be presentable?
	end
	
	-- local count = math.floor((newwidth / 10) + 0.5)
	-- local countx = math.floor((newwidth / fxwidth) + 0.5)
	-- local countz = math.floor((newheight / fxwidth) + 0.5)
	local countx = math.floor(newwidth / fxwidth)
	local countz = math.floor(newheight / fxwidth)
	-- local totalcount = count * (newheight / fxwidth)
	local totalcount = countx * countz
	-- local count = math.floor((fxwidth / newwidth) + 0.5)
	
	-- local myPos = Vector3(inst.Transform:GetWorldPosition())
	local x,y,z = inst.Transform:GetWorldPosition()
	
	-- local newx = x - (newwidth / 2)
	local newx = x
	-- Why my not no work?
	-- if not walltype == 1 then
	if walltype == 0 or walltype == 2 then
		newx = (x - (newwidth / 2)) + (fxwidth / 2)  -- I want to get the top-left corner
		-- Only give us the new X if it's not side walls; those don't change their left/right positions
	
	end
	local newy = y
	
	local newz = z
	-- if not walltype == 2 then
	if walltype == 0 or walltype == 1 then
		newz = (z - (newheight / 2)) + (fxwidth / 2)
	end
	-- local newz = z - (newheight / 2) - (fxwidth / 2)
	
	-- inst.Transform:SetPosition(((x - (newwidth / 2)),y,z))
	-- inst.Transform:SetPosition(Vector3((x - (newwidth / 2)),y,z))
	inst.Transform:SetPosition(newx,y,z)
	-- local fxScale = 
	
	-- local newscale = newwidth / 14
	-- local newscale = 10 / newwidth
	local newscale = 10
	
	print("FX desired count: ", totalcount)
	for i=0,countz,1 do
		-- inst.Transform:SetWorldPosition
		-- inst.Transform:SetPosition(newx + ((newwidth / 2) * count),y,z)
		
		for offset=0,countx,1 do
		
			local xadjust = 0
			local zadjust = 0
		
			if walltype == 0 or walltype == 1 then -- Floor or Back
				-- I want left and right here. Is that Z or X?
				-- zadjust = (i * fxwidth) % count
				zadjust = (offset * fxwidth)
			end
			if walltype == 0 or walltype == 2 then -- Side walls
				-- I want up and down. It naturally also applies to the floor, since it's square
				-- xadjust = fxwidth * i % (i / (newwidth / fxwidth)
				
				-- % (newwidth / fxwidth)
				-- xadjust = (math.floor(i / count) * fxwidth)
				xadjust = fxwidth * i
				
			end
			
			-- inst.Transform:SetPosition(newx + (fxwidth * i),y,z)
			inst.Transform:SetPosition(newx + xadjust,newy,newz + zadjust)
			print("Emitting new particle, x loop ", i, " z loop ", offset)
			emit_fn(inst, inst.effect, newscale)
			-- inst.Transform:SetScale
		end
	end
	-- inst.iSetup = 1
	print("New UV scale: ", newscale)
	
end

local function GetTexture(inst)
    return inst.texture
end

local function SetTexture(inst, texture)
    inst.texture = texture
    inst.VFXEffect:SetRenderResources(0, resolvefilepath(texture), resolvefilepath(SHADER))
    -- inst.VFXEffect:SetRenderResources(0, resolvefilepath(texture), resolvefilepath(SHADER))
end

local function initEmit()
	
end

local function commonfn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("interiorwall")
    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    if TheNet:GetIsClient() then
        inst.entity:AddClientSleepable()
    end
    inst.persists = false

    inst.entity:AddTransform()

    -----------------------------------------------------
	
	inst.SetWallData = SetWallData

    if InitEnvelopes ~= nil then
        InitEnvelopes()
    end

    local effect = inst.entity:AddVFXEffect()
	inst.effect = effect
    effect:InitEmitters(1)

	-- effect:SetRenderResources(0, resolvefilepath(TEXTURE), resolvefilepath(SHADER))
	effect:SetRenderResources(0, resolvefilepath(resolvefilepath("levels/textures/interiors/"..TEXTURE)), resolvefilepath(SHADER))
	effect:SetMaxNumParticles(0, 100)
	-- effect:SetSortOrder(0, -1)
	-- effect:SetSortOffset(0, 0)
	--effect:SetLayer(0, 3)
	effect:SetLayer(0, LAYER_BACKGROUND)
	effect:SetMaxLifetime(0, MAX_LIFETIME)
	-- effect:SetSpawnVectors(0,
		-- 0, 0, 1, --faces towards 0 degree
		-- 0, 1, 0
	-- )
	-- These actually seem to be the facing directions? Skewing and stuff happens at diagonals
	
	-- Info:
	-- Bottom-right = left/right skew of the top part
	local ScaleName = SCALE_ENVELOPE_NAME
	-- if not ScaleOverride == nil then
		-- ScaleName = ScaleOverride
	-- end
	
	-- Floor
	if walltype == 0 then
		effect:SetSpawnVectors(0,
			0, 0, 1,
			1, 0, 0
		)
		-- ScaleName = FLOOR_MEDIUM_SCALE_ENVELOPE_NAME
	-- Back wall
	elseif walltype == 1 then
	
		-- effect:SetSpawnVectors(0,
			-- 0, 0, 1, --faces towards 0 degree
			-- -0.75, 1, 0
		-- )
	
		effect:SetSpawnVectors(0,
			0, 0, 1, --faces towards 0 degree
			-0.6, 1, 0
		)
		-- ScaleName = BACK_MEDIUM_SCALE_ENVELOPE_NAME
	-- Side Walls
	elseif walltype == 2 then
	
		-- effect:SetSpawnVectors(0,
			-- 1, 0, 0,
			-- -0.75, 1, 0
		-- )
		effect:SetSpawnVectors(0,
			1, 0, 0,
			-0.6, 1, 0
		)
		-- ScaleName = SIDE_MEDIUM_SCALE_ENVELOPE_NAME
	end
	-- This makes it flat on the ground!
	-- effect:SetSpawnVectors(0,
		-- 0, 0, 1,
		-- 1, 0, 0
	-- )
	
	
	effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
	effect:SetScaleEnvelope(0, ScaleName)
	
	-- effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
	
	
    effect:SetUVFrameSize(0, 1, 1)
	effect:SetKillOnEntityDeath(0, true)
	-- effect:EnableDepthTest(0, true)
    -----------------------------------------------------
    inst.SetTexture = SetTexture
    inst.GetTexture = GetTexture
	

    local updateFunc = function()
		-- if iSetup == 1 then
			-- emit_fn(inst, effect)
		-- end
    end

    EmitterManager:AddEmitter( inst, nil, updateFunc )

    return inst
end

local function floorfn()
	walltype = 0
	local inst = commonfn()
	
	inst.effect:SetSortOrder(0, 0)
	inst.effect:SetSortOffset(0, 0)
	inst.effect:SetLayer(0, LAYER_GROUND) -- Apparently ground is lower than background? According to Half, at least, it's about the tile layer
	-- inst.effect:SetLayer(0, LAYER_BACKGROUND)
    return inst
end

local function floorbigfn()
	walltype = 0
	ScaleOverride = FLOOR_BIG_SCALE_ENVELOPE_NAME
	SizeOverride = 4
	local inst = commonfn()
	
	-- inst.effect:SetSortOrder(0, -1)
	inst.effect:SetSortOffset(0, 0)
	-- inst.effect:SetLayer(0, LAYER_BACKGROUND)
	inst.effect:SetLayer(0, LAYER_GROUND)
    return inst
end

local function backwallfn()
	walltype = 1
	local inst = commonfn()
	
	inst.effect:SetSortOrder(1, 2)
	-- inst.effect:SetSortOffset(0, 1)
	-- inst.effect:SetLayer(0, LAYER_GROUND)
	inst.effect:SetLayer(0, LAYER_BACKGROUND)
    return inst
end

local function sidewallfn()
	walltype = 2
	local inst = commonfn()
	inst.effect:SetSortOrder(2, 2)
	-- inst.effect:SetSortOffset(0, 0)
	-- inst.effect:SetLayer(0, LAYER_GROUND)
	inst.effect:SetLayer(0, LAYER_BACKGROUND)
	
    return inst
end

return Prefab("interior_wall_back", backwallfn, assets),
	Prefab("interior_wall_side", sidewallfn, assets),
	Prefab("interior_wall_floor", floorfn, assets),
	Prefab("interior_wall_floor_big", floorbigfn, assets)--,
	
	-- Prefab("interior_wall_back_fx", backwallfxfn, assets),
	-- Prefab("interior_wall_side_fx", sidewallfxfn, assets),
	-- Prefab("interior_wall_floor_fx", floorfxfn, assets)