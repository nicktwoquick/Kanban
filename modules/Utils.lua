-- Kanban Utils Module
-- Contains debug functions and common constants

local addonName, addon = ...

-- Debug function
local function debug(message)
    local db = _G.Kanban.db
    if not db.profile.options.debug then
        return
    end
    print("|cFF00FF00Kanban|r: " .. message)
end

-- Kanban board columns configuration
local COLUMNS = {
    {name = "To-Do", color = {0.2, 0.6, 1.0}},      -- Blue
    {name = "In Progress", color = {1.0, 0.6, 0.2}}, -- Orange
    {name = "Done", color = {0.2, 0.8, 0.2}}         -- Green
}

-- Priority options
local PRIORITIES = {
    ["Low"] = "Low",
    ["Medium"] = "Medium", 
    ["High"] = "High"
}

-- Export functions and constants
local Utils = {
    debug = debug,
    COLUMNS = COLUMNS,
    PRIORITIES = PRIORITIES
}

-- Make available globally
_G.Kanban_Utils = Utils

-- Attach to addon if available
if addon then
    addon.Utils = Utils
end

return Utils 