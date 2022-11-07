local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function OnRoomCamXDirty(inst)
    print("Dirty X event received, print inst...", inst)
	print("Printing X...", inst.net_roomx:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.camX = inst.net_roomx:value()
	
end

local function OnRoomCamZDirty(inst)
    print("Dirty Z event received, print inst...", inst)
	print("Printing Z...", inst.net_roomz:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.camZ = inst.net_roomz:value()
end

local function OnRoomCamZoomDirty(inst)
    print("Dirty Zoom event received, print inst...", inst)
	print("Printing Zoom...", inst.net_roomzoom:value())
	if inst._parent ~= ThePlayer then
        return
    end
	inst._parent.replica.interiorplayer.camZoom = inst.net_roomzoom:value()
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
	inst.net_intcamera = net_bool(inst.GUID, "setintcam", "setintcamdirty")
	
	-- inst.intccmode = net_bool(inst.GUID, "interiorplayer.camera"

    inst.net_roomx:set(0)
    inst.net_roomz:set(0)
    inst.net_intcamera:set(false)

    --Delay net listeners until after initial values are deserialized
    inst:DoTaskInTime(0, RegisterNetListeners)
end)
