

local function _OnUpdate(inst, self, dt)
	if not self.interior then
		-- Avoid updating if you're in interior storage space, so you don't burn everything in every interior simultaneously
		-- Actually, maybe not needed now? After disabling the 'non-persistent' deletion in the interior, nothing has burnt, even with a fully-stocked bare campfire
		self:OnUpdate(dt)
	end
end