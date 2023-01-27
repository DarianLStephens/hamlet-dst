local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function ForceUpdateCamera(inst)
	print("Force Update received for Camera")
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer:ForceUpdateCamera()
end

local function OnRoomCamXDirty(inst)
    print("Dirty X event received, print inst...", inst)
	print("Printing X...", inst.net_roomx:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.camX = inst.net_roomx:value()
	ForceUpdateCamera(inst)
	
end

local function OnRoomCamZDirty(inst)
    print("Dirty Z event received, print inst...", inst)
	print("Printing Z...", inst.net_roomz:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.camZ = inst.net_roomz:value()
	ForceUpdateCamera(inst)
end

local function OnRoomCamZoomDirty(inst)
    print("Dirty Zoom event received, print inst...", inst)
	print("Printing Zoom...", inst.net_roomzoom:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.camZoom = inst.net_roomzoom:value()
	ForceUpdateCamera(inst)
end

local function SetIntCamDirty(inst)
    print("Dirty cam event received, print inst...", inst)
	print("Printing bool...", inst.net_intcamera:value())
	if inst._parent ~= ThePlayer then
        return
    end
	-- inst.replica.interiorplayer:SetCamera(inst.net_intcamera)
	-- inst._parent.components.interiorplayer:SetCamera(inst.net_intcamera)
	-- inst._parent.replica.interiorplayer:SetCamera(inst.net_intcamera:value())
	inst._parent.replica.interiorplayer.interiorMode = inst.net_intcamera:value()
	inst._parent.replica.interiorplayer:SetCamera()
	
	-- inst.net_intcamera:set_local(true) -- Maybe I need to do this?
	-- inst.net_intcamera:set(false) -- Maybe I need to do this?
end

local function OnRoomWidthDirty(inst)
    print("Dirty Room Width event received, print inst...", inst)
	print("Printing Room Width...", inst.net_roomwidth:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.interiorWidth = inst.net_roomwidth:value()
end

local function OnRoomDepthDirty(inst)
    print("Dirty Room Depth event received, print inst...", inst)
	print("Printing Room Depth...", inst.net_roomdepth:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.interiorDepth = inst.net_roomdepth:value()
end

local function OnRoomTextureFloorDirty(inst)
    print("Dirty Room Floor Texture event received, print inst...", inst)
	print("Printing Floor Texture...", inst.net_roomtexturefloor:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.floorTexture = inst.net_roomtexturefloor:value()
end

local function OnRoomTextureWallDirty(inst)
    print("Dirty Room Wall Texture event received, print inst...", inst)
	print("Printing Wall Texture...", inst.net_roomtexturewall:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.wallTexture = inst.net_roomtexturewall:value()
end

local function OnRoomGroundSoundDirty(inst)
    print("Dirty Room Ground Sound event received, print inst...", inst)
	print("Printing Ground Sound...", inst.net_roomgroundsound:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.groundSound = inst.net_roomgroundsound:value()
end

local function RegisterNetListeners(inst)
	print("DS - Player net listener event registry running...")
	if TheWorld.ismastersim then
        inst._parent = inst.entity:GetParent()
	end
    if not TheNet:IsDedicated() then
    -- if not TheWorld.ismastersim then -- Client only
		print("DS - Registering net events on the client?")
        inst:ListenForEvent("roomxdirty", OnRoomCamXDirty)
        inst:ListenForEvent("roomzdirty", OnRoomCamZDirty)
        inst:ListenForEvent("roomzoomdirty", OnRoomCamZoomDirty)
        inst:ListenForEvent("setintcamdirty", SetIntCamDirty)
		
        inst:ListenForEvent("forceupdatecamdirty", ForceUpdateCamera)
		
        inst:ListenForEvent("roomwidthdirty", OnRoomWidthDirty)
        inst:ListenForEvent("roomdepthdirty", OnRoomDepthDirty)
        inst:ListenForEvent("roomtexturefloordirt", OnRoomTextureFloorDirty)
        inst:ListenForEvent("roomtexturewalldirty", OnRoomTextureWallDirty)
    end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

HAMENV.AddPrefabPostInit("player_classified", function(inst)
	print("DS - Player classified being edited with new net things, I hope")
    inst.net_roomx = net_float(inst.GUID, "roomx", "roomxdirty")
	inst.net_roomz = net_float(inst.GUID, "roomz", "roomzdirty")
	inst.net_roomzoom = net_float(inst.GUID, "roomzoom", "roomzoomdirty")
	
	inst.net_roomwidth = net_float(inst.GUID, "roomwidth", "roomwidthdirty")
	inst.net_roomdepth = net_float(inst.GUID, "roomdepth", "roomdepthdirty")
	inst.net_roomtexturefloor = net_string(inst.GUID, "roomtexturefloor", "roomtexturefloordirt")
	inst.net_roomtexturewall = net_string(inst.GUID, "roomtexturewall", "roomtexturewalldirty")
	inst.net_roomgroundsound = net_string(inst.GUID, "roomgroundsound", "roomgroundsounddirty")
	
	inst.net_intcamera = net_bool(inst.GUID, "setintcam", "setintcamdirty")
	
	inst.net_forceupdatecamera = net_bool(inst.GUID, "forceupdatecam", "forceupdatecamdirty")
	
	-- inst.intccmode = net_bool(inst.GUID, "interiorplayer.camera"

    inst.net_roomx:set(0)
    inst.net_roomz:set(0)
    inst.net_intcamera:set(false)

    --Delay net listeners until after initial values are deserialized
    inst:DoTaskInTime(0, RegisterNetListeners)
end)
