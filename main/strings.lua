local HAMENV = env
GLOBAL.setfenv(1, GLOBAL)

local _speech = {
	-- "generic",
	-- "willow",
	-- "wolfgang",
	"wendy"--,
	-- "wx78",
	-- "wickerbottom",
	-- "woodie",
	-- "wes",
	-- "waxwell",
	-- "wathgrithr",
	-- "webber",
	-- "winona",
	-- "wortox",
	-- "wormwood",
	-- "warly",
	-- "wurt",
	-- "walter",
	-- "wanda",
}

local _newspeech = {
	-- "walani",
	-- "wilbur",
	-- "woodlegs",
}

local _pigstuff = {
	"pig_names",
	"pig_speech"
}

local function merge(target, new, soft)
	if not target then
		target = {}
	end

	for k, v in pairs(new) do
		if type(v) == "table" then
			target[k] = type(target[k]) == "table" and target[k] or {}
			merge(target[k], v)
		else
			if target[k] then
				if soft then
					-- print("couldn't add " ..  k, " (already is \"" ..  target[k]  .. "\")")
				else
					-- print("replacing " ..  k, " (with \"" ..  v  .. "\")")
					target[k] = v
				end
			else
				target[k] = v
			end
		end
	end
	return target
end

-- Install our crazy loader!
local function import(modulename)
	print("modimport (strings file): " .. HAMENV.MODROOT .. "strings/" .. modulename)
	-- if string.sub(modulename, #modulename-3,#modulename) ~= ".lua" then
		-- modulename = modulename .. ".lua"
	-- end
	local result = kleiloadlua(HAMENV.MODROOT .. "strings/" .. modulename)
	if result == nil then
		error("Error in custom import: Stringsfile " .. modulename .. " not found!")
	elseif type(result) == "string" then
		error("Error in custom import: Island Adventures importing strings/" .. modulename .. "!\n" .. result)
	else
		setfenv(result, HAMENV) -- in case we use mod data
		return result()
	end
end

local IsTheFrontEnd = rawget(_G, "TheFrontEnd") and rawget(_G, "IsInFrontEnd") and IsInFrontEnd()

if not IsTheFrontEnd then
    -- add character speech
    for _,v in pairs(_speech) do
    	merge(STRINGS.CHARACTERS[string.upper(v)], import(v .. ".lua"))
    end
    for _,v in pairs(_newspeech) do
    	STRINGS.CHARACTERS[string.upper(v)] = import(v .. ".lua")
    end
    for _,v in pairs(_pigstuff) do
    	merge(STRINGS, import(v .. ".lua"))
    end
end