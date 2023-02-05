env._G = GLOBAL
_G.setmetatable(env,{__index=function(t,k) return _G.rawget(_G,k) end})

_G.CHEATS_ENABLED = true 
require("debugkeys")

modimport("scripts/main.lua")
