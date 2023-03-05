return function(self)
	function self:MarkPosition(recall_x, recall_y, recall_z, recall_worldid, recall_interior)
		if recall_x ~= nil then
			self.recall_x = recall_x or 0
			self.recall_y = recall_y or 0
			self.recall_z = recall_z or 0
			
			self.interior = recall_interior
			
			self.inst:RemoveTag("recall_unmarked")

			self.recall_worldid = recall_worldid or TheShard:GetShardId()
		end

		if self.onMarkPosition ~= nil then
			self.onMarkPosition(self.inst, recall_x, recall_y, recall_z, recall_worldid)
		end
	end
end