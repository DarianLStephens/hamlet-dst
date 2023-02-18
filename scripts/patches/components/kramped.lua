return function(self)
	local index
	local _ForceNaughtiness
	for i, func in ipairs(self.inst.event_listeners["ms_forcenaughtiness"][self.inst]) do
		if debug.getinfo(func, "S").source == "scripts/components/kramped.lua" then
			index = i
			break
		end
	end
	_ForceNaughtiness = self.inst.event_listeners["ms_forcenaughtiness"][self.inst][index]
	local _MakeAKrampusForPlayer = UpvalueHacker.GetUpvalue(_ForceNaughtiness, "MakeAKrampusForPlayer")

	local function MakeAKrampusForPlayer(player, ...)
		if player and player.components.interiorplayer.interiormode then
			return
		end
		_MakeAKrampusForPlayer(player, ...)
	end
	UpvalueHacker.SetUpvalue(_ForceNaughtiness, MakeAKrampusForPlayer, "MakeAKrampusForPlayer")

end
