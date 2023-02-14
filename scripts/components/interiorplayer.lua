
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
	self._lastMode = false
	
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
	if self.interiormode then
		if self._lastMode == self.interiormode then
			SetDirty(self.inst.replica.interiorplayer.forceupdatecamera, true)
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
	if self.interiormode then
		return data
	end
end

function InteriorPlayer:OnLoad(data)
	if data then
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
	end
end

function InteriorPlayer:LoadPostPass(data)
	if data.interiormode then
		self:UpdateCamera()
	end
end

return InteriorPlayer