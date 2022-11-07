local RoomDemolisher = Class(function(self, inst)
    self.inst = inst
end)

function RoomDemolisher:CollectUseActions(doer, target, actions)
    if target:HasTag("interior_door") and target:HasTag("house_door") then
        table.insert(actions, ACTIONS.DEMOLISH_ROOM)
    end
end


return RoomDemolisher
