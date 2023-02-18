return function(self)
	local _OnUpdate = self.OnUpdate
	function self:OnUpdate(...)
		if self.inst.components.interiorplayer.interiormode then
			self:SetSheltered(true, 2)
			return
		end
		_OnUpdate(self, ...)
	end
end
