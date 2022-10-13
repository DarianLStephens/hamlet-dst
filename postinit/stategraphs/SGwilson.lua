local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)

HAMENV.AddStategraphPostInit("wilson", function(sg)

local actionhandlers = {
	ActionHandler(ACTIONS.ENTERDOOR, "dostandingaction"),
    ActionHandler(ACTIONS.BUILD_ROOM, "doshortaction"),
    ActionHandler(ACTIONS.DEMOLISH_ROOM, "doshortaction")
}

-- local states = {
    -- State{
        -- name = "enterdoor",
        -- tags = {"canrotate", "busy", "nomorph", "nopredict"},
        -- onenter = function(inst)
            -- local BA = inst:GetBufferedAction()
            -- if BA.target and BA.target.components.sailable and not BA.target.components.sailable:IsOccupied() then
                -- BA.target.components.sailable.isembarking = true
                -- if inst.components.sailor and inst.components.sailor:IsSailing() then
                    -- inst.components.sailor:Disembark(nil, true)
                -- else
                    -- inst.sg:GoToState("jumponboatstart")
                -- end
			-- else
				-- --go to idle first so wilson can go to the talk state if desired -M
				-- --and in my defence, Klei does that too, in opengift state
				-- inst.sg:GoToState("idle")
				-- inst:PushEvent("actionfailed", { action = inst.bufferedaction, reason = "INUSE" })
				-- inst:ClearBufferedAction()
            -- end
        -- end,

        -- onexit = function(inst)
        -- end,
    -- }
-- }

for k, v in pairs(actionhandlers) do
    assert(v:is_a(ActionHandler), "Non-action handler added in mod actionhandler table!")
    sg.actionhandlers[v.action] = v
end

-- for k, v in pairs(events) do
    -- assert(v:is_a(EventHandler), "Non-event added in mod events table!")
    -- sg.events[v.name] = v
-- end

-- for k, v in pairs(states) do
    -- assert(v:is_a(State), "Non-state added in mod state table!")
    -- sg.states[v.name] = v
-- end

end)