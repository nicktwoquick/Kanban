-- Kanban GUI Components
-- This file will contain all the UI components for the kanban board

local addonName, addon = ...

-- Import libraries
local AceGUI = LibStub("AceGUI-3.0")
local AceAddon = LibStub("AceAddon-3.0")

-- GUI namespace
addon.GUI = {}

-- Kanban board columns
local COLUMNS = {
    {name = "To-Do", color = {0.2, 0.6, 1.0}},      -- Blue
    {name = "In Progress", color = {1.0, 0.6, 0.2}}, -- Orange
    {name = "Done", color = {0.2, 0.8, 0.2}}         -- Green
}

-- This file will be expanded as we build the kanban board components
-- For now, it's just a placeholder to ensure the TOC file loads correctly 