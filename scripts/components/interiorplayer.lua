
local function oncamxthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.camx:set(val)
	end
end

local function oncamzthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.camz:set(val)
	end
end

local function oncamzoomthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.camzoom:set(val)
	end
end

local function onintmodthresh(self, val)
	if val ~= nil then
		self.inst.replica.interiorplayer.interiormode:set(val)
	end
end

local function onintwidththresh(self, val)
	if val then
		self.inst.replica.interiorplayer.interiorwidth:set(val)
	end
end

local function onintdepththresh(self, val)
	if val then
		self.inst.replica.interiorplayer.interiordepth:set(val)
	end
end

local function onintheightthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.interiorheight:set(val)
	end
end

local function onwalltexthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.walltexture:set(val)
	end
end

local function onfloortexthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.floortexture:set(val)
	end
end

local function ongroundsoundthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.groundsound:set(val)
	end
end

local function onroomidthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.roomid:set(val)
	end
end

local InteriorPlayer = Class(function(self, inst)
    self.inst = inst
	self.camx = 0
	self.camz = 0
	self.camzoom = 0
	
	self.interiormode = false
	self._lastMode = false -- Specifically don't save this
	
	self.interiorwidth = 0
	self.interiordepth = 0
	self.interiorheight = 0
	self.walltexture = nil
	self.floortexture = nil
	self.groundsound = "WOOD"
	self.roomid = "unknown"
	
	self.soundupdatertask = nil
end,
nil,
{
    camx = oncamxthresh,
    camz = oncamzthresh,
    camzoom = oncamzoomthresh,
    interiormode = onintmodthresh,
    interiorwidth = onintwidththresh,
    interiordepth = onintdepththresh,
    interiorheight = onintheightthresh,
    walltexture = onwalltexthresh,
    floortexture = onfloortexthresh,
    groundsound = ongroundsoundthresh,
    roomid = onroomidthresh,
})

function InteriorPlayer:UpdateCamera()
	print("DS - Main interiorplayer component, attempting to send data via net to replica...")
	print("X ", self.camx, "Z ", self.camz, "Zoom ", self.camzoom, "Interior mode ", self.interiormode)
	if self.interiormode then
		if self._lastMode == self.interiormode then
			print("Detected same interior mode, force-update camera position")
			self.inst.replica.interiorplayer.forceupdatecamera:set(true)
		end
	end
	
	self._lastMode = self.interiormode
end

function InteriorPlayer:OnSave()
	local data = {
		camx = self.camx,
		camz = self.camz,
		camzoom = self.camzoom,
		interiormode = self.interiormode,
		
		interiorwidth = self.interiorwidth,
		interiordepth = self.interiordepth,
		interiorheight = self.interiorheight,
		walltexture = self.walltexture,
		floortexture = self.floortexture,
		groundsound = self.groundsound,
		roomid = self.roomid,
	}
	if self.interiormode == true then
		return data
	end
end

function InteriorPlayer:OnLoad(data)
	print("DS - InteriorPlayer load pass")
	if data ~= nil then
		print("Got data from load, dumping...")
		dumptable(data, 1, 1, nil, 0)
		self.camx = data.camx
		self.camz = data.camz
		self.camzoom = data.camzoom
		self.interiormode = data.interiormode
		
		self.interiorwidth = data.interiorwidth
		self.interiordepth = data.interiordepth
		self.interiorheight = data.interiorheight
		self.walltexture = data.walltexture
		self.floortexture = data.floortexture
		self.groundsound = data.groundsound
		self.roomid = data.roomid
	else
		print("Got no data from load, nothing should happen")
	end
end

function InteriorPlayer:LoadPostPass(data)
	print("DS - InteriorPlayer load POST pass")
	if data.interiormode then
		print("Interiormode is true, update camera")
		self:UpdateCamera() -- Moving it a bit later in init so it can hopefully wait for the client to fully load
	else
		print("Interior mode was false, you (probably) weren't in an interior, don't do the thing")
	end
	
end

return InteriorPlayer