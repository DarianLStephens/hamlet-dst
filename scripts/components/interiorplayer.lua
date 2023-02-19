
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

local function oncamoffsetthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.camoffset:set(val)
	end
end

local function onintmodthresh(self, val)
	if val ~= nil then
		self.inst.replica.interiorplayer.interiormode:set(val)
	end
	if self.inst.UpdateInteriorDarkness then
		self.inst:UpdateInteriorDarkness()
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

local function onreverbthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.reverb:set(val)
	end
end

local function onambsndthresh(self, val)
	if val ~= "" and val ~= nil then
		self.inst.replica.interiorplayer.ambsnd:set(val)
	end
end

local function onroomidthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.roomid:set(val)
	end
end

local function onplayerroomthresh(self, val)
	self.inst.player_classified.craftingfiltertype:set(val and "reno" or "")
end

local function ondynamicmusicthresh(self, val)
	if val then
		self.inst.replica.interiorplayer.dynamicmusictone:set(val)
	end
end

local InteriorPlayer = Class(function(self, inst)
    self.inst = inst
	self.camx = 0
	self.camz = 0
	self.camzoom = 0
	self.camoffset = 0
	
	self.interiormode = false
	self._lastMode = false
	
	self.interiorwidth = 0
	self.interiordepth = 0
	self.interiorheight = 0
	self.walltexture = nil
	self.floortexture = nil
	self.groundsound = "WOOD"
	self.reverb = "default"
	self.ambsnd = ""
	self.roomid = "unknown"
	self.playerroom = false
	self.dynamicmusictone = ""
	
	self.soundupdatertask = nil
end,
nil,
{
    camx = oncamxthresh,
    camz = oncamzthresh,
    camzoom = oncamzoomthresh,
    camoffset = oncamoffsetthresh,
    interiormode = onintmodthresh,
    interiorwidth = onintwidththresh,
    interiordepth = onintdepththresh,
    interiorheight = onintheightthresh,
    walltexture = onwalltexthresh,
    floortexture = onfloortexthresh,
    groundsound = ongroundsoundthresh,
    reverb = onreverbthresh,
    ambsnd = onambsndthresh,
    roomid = onroomidthresh,
    playerroom = onplayerroomthresh,
    dynamicmusictone = ondynamicmusicthresh,
})

function InteriorPlayer:UpdateInterior(facing, texture, groundsound)
	local interior = self.roomid and TheWorld.components.interiorspawner:GetInteriorByName(self.roomid)
	if interior then
		if facing == INTERIORFACING.FLOOR then
			self.floortexture = texture
			self.groundsound = groundsound
			interior.floortexture = texture
			interior.groundsound = groundsound
		end

		if facing == INTERIORFACING.WALL then
			self.walltexture = texture
			interior.walltexture = texture
		end
	end
end

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
		camoffset = self.camoffset,
		interiormode = self.interiormode,
		
		interiorwidth = self.interiorwidth,
		interiordepth = self.interiordepth,
		interiorheight = self.interiorheight,
		walltexture = self.walltexture,
		floortexture = self.floortexture,
		groundsound = self.groundsound,
		reverb = self.reverb,
		ambsnd = self.ambsnd,
		roomid = self.roomid,
		playerroom = self.playerroom,
		dynamicmusictone = self.dynamicmusictone,
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
		self.camoffset = data.camoffset
		self.interiormode = data.interiormode
		self._lastMode = data.interiormode

		self.interiorwidth = data.interiorwidth
		self.interiordepth = data.interiordepth
		self.interiorheight = data.interiorheight
		self.walltexture = data.walltexture
		self.floortexture = data.floortexture
		self.groundsound = data.groundsound
		self.reverb = data.reverb
		self.ambsnd = data.ambsnd
		self.roomid = data.roomid
		self.playerroom = data.playerroom
		self.dynamicmusictone = data.dynamicmusictone
	end
end

return InteriorPlayer