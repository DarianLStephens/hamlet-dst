return function(self)
	local index
	local _OnPlayerActivated
	for i, func in ipairs(self.inst.event_listeners["playeractivated"][self.inst]) do
		if debug.getinfo(func, "S").source == "scripts/components/dynamicmusic.lua" then
			index = i
			break
		end
	end
	_OnPlayerActivated = self.inst.event_listeners["playeractivated"][self.inst][index]

	local _StartPlayerListeners = UpvalueHacker.GetUpvalue(_OnPlayerActivated, "StartPlayerListeners")
	local _StartDanger = UpvalueHacker.GetUpvalue(_StartPlayerListeners, "OnAttacked", "StartDanger")
	local _StopDanger = UpvalueHacker.GetUpvalue(_OnPlayerActivated, "StopSoundEmitter", "StopDanger")
	local _StartBusy = UpvalueHacker.GetUpvalue(_StartPlayerListeners, "StartBusy")
	local _StopBusy = UpvalueHacker.GetUpvalue(_StartBusy, "StopBusy")
	local _OnPhase = UpvalueHacker.GetUpvalue(_OnPlayerActivated, "StartSoundEmitter", "OnPhase")
	
	local _istone = false

	local function StartBusy(player)
		if _istone then
			return
		end
		_StartBusy(player)
	end

	local function StartTone(player, data)
		local _isenabled = UpvalueHacker.GetUpvalue(_StartBusy, "_isenabled")
		local _soundemitter = UpvalueHacker.GetUpvalue(_StartBusy, "_soundemitter")

		if player.replica.interiorplayer.interiormode:value() then
			if _isenabled then
				_soundemitter:KillSound("busy")
				_soundemitter:PlaySound(data.path, "tone")
					
				_soundemitter:SetParameter("tone", "intensity", 1)
			end
		end
	end
	
	local function OnPhase(...)
		if _istone then
			return
		end
		_OnPhase(...)
	end
		
	local function StartDanger(player)
		local _soundemitter = UpvalueHacker.GetUpvalue(_StartBusy, "_soundemitter")
		if _istone then
			_soundemitter:SetParameter("tone", "intensity", 0)
		end
		_StartDanger(player)
	end

	local function StopDanger(player)
		local _soundemitter = UpvalueHacker.GetUpvalue(_StartBusy, "_soundemitter")
		if _istone then
			_soundemitter:SetParameter("tone", "intensity", 1)
		end
		_StopDanger(player)
	end
	
	local function EnterInterior(player, data)
		print("SHDADASDADWD", data.category)
		local _soundemitter = UpvalueHacker.GetUpvalue(_StartBusy, "_soundemitter")
		local CATEGORIES = {
			shop = {path ="dontstarve_DLC003/music/theme", timeout = 75 }, -- shop_enter for some reasons didn't worked
			ruins = {path ="dontstarve_DLC003/music/ruins_enter", timeout = 75 },
			ruins_humid = {path ="dontstarve_DLC003/music/ruins_enter_2", timeout = 75 },
			ruins_lush = {path ="dontstarve_DLC003/music/ruins_enter_3", timeout = 75 },          
			jungle = {path ="dontstarve_DLC003/music/deeprainforest_enter_1", timeout = 75 },
			jungle_humid = {path ="dontstarve_DLC003/music/deeprainforest_enter_2", timeout = 75 },
			jungle_lush = {path ="dontstarve_DLC003/music/deeprainforest_enter_3", timeout = 75 },    
		}

		_StopBusy(true)
		_istone = true
		StartTone(player, CATEGORIES[data.category])
	end

	local function ExitInterior(data)
		local _soundemitter = UpvalueHacker.GetUpvalue(_StartBusy, "_soundemitter")
		_istone = false
		_soundemitter:KillSound("tone")
	end

	local function StartPlayerListeners(player, data)
		_StartPlayerListeners(player)
		self.inst:ListenForEvent("enteredinterior", function(player, data) EnterInterior(player, {category = data}) end, player)
		self.inst:ListenForEvent("exitedinterior", ExitInterior, player)
	end
	
	UpvalueHacker.SetUpvalue(_OnPlayerActivated, OnPhase, "StartSoundEmitter", "OnPhase")
	UpvalueHacker.SetUpvalue(_StartPlayerListeners, StartBusy, "StartBusy")
	UpvalueHacker.SetUpvalue(_StartPlayerListeners, StartDanger, "OnAttacked", "StartDanger")
	UpvalueHacker.SetUpvalue(_OnPlayerActivated, StopDanger, "StopSoundEmitter", "StopDanger")
	UpvalueHacker.SetUpvalue(_OnPlayerActivated, StartPlayerListeners, "StartPlayerListeners")
end
