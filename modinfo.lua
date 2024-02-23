name = "Pig Ruins for Core"
description = "Trying to make Hamlet-style interiors."
author = "Darian Stephens \nAssistant: asura"
version = "0.1"

local workshop_mod = folder_name and folder_name:find("workshop-") ~= nil

if not workshop_mod then
	name = "[GitHub] "..name
	description = description.."\n\n\n\nDeveloper version"
end

forumthread = ""
api_version = 10

dst_compatible = true

all_clients_require_mod = true
clients_only_mod = false

mod_dependencies = {
    {
        ["Interior Core Darian Branch"] = true,
    },
}