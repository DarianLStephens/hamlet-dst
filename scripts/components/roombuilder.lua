local RoomBuilder = Class(function(self, inst)
    self.inst = inst
	self.inst:AddTag("roombuilder")
end)

-- DS - This is all deprecated in DST, according to Half.
-- function RoomBuilder:CollectUseActions(doer, target, actions)
    -- if target:HasTag("predoor") then
        -- table.insert(actions, ACTIONS.BUILD_ROOM)
    -- end
-- end

function RoomBuilder:OnRemoveFromEntity()
    self.inst:RemoveTag("roombuilder")
end


return RoomBuilder
