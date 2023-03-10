return function(self)

	

	function self:Copy(rhs)
		rhs = rhs ~= nil and rhs.components.recallmark
		if rhs then
			self:MarkPosition(rhs.recall_x, rhs.recall_y, rhs.recall_z, rhs.recall_worldid, rhs.interior)
		end
	end

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
	

	-- Added to prevent the markers from every interior showing in every other interior
	-- Still need to somehow override pocketwatch_common to handle interior transitions refreshing it, though.
	-- Maybe I can call it directly, or something?
	function self:GetMarkedPosition()
		local hidemarker = false
		if self.interior then
			hidemarker = true
			local owner = self.inst.components.inventoryitem:GetGrandOwner()
			if owner ~= nil and owner:HasTag("player") then
				if owner.components.interiorplayer.roomid == self.interior then
					hidemarker = false
				end
			end
		end
		
		print("DS - RecallMark - GMP - Hide marker = ", hidemarker)
					
		if (self.recall_worldid == TheShard:GetShardId()) and not hidemarker then
			return self.recall_x, self.recall_y, self.recall_z
		end

		return nil
	end
	

	function self:OnSave()
		return {
			recall_x = self.recall_x,
			recall_y = self.recall_y,
			recall_z = self.recall_z,
			recall_worldid = self.recall_worldid,
			recall_interior = self.interior,
		}
	end

	function self:OnLoad(data)
		if data ~= nil and data.recall_worldid ~= nil then
			self:MarkPosition(data.recall_x, data.recall_y, data.recall_z, data.recall_worldid, data.recall_interior)
		end
	end
	
end