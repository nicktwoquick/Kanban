-- Kanban GUI Components (Legacy Loader)
-- This file now serves as a compatibility layer for the refactored modules

local addonName, addon = ...

-- Debug function
local function debug(message)
    print("|cFF00FF00Kanban|r: " .. message)
end

-- Load modules (for backward compatibility)
-- Modules are loaded by TOC file and available as global tables
local Utils = _G.Kanban_Utils
local TaskManager = _G.Kanban_TaskManager
local UIComponents = _G.Kanban_UIComponents
local Dialogs = _G.Kanban_Dialogs
local Board = _G.Kanban_Board

-- Legacy compatibility functions
local function CreateKanbanBoard(parentFrame)
    if Board and Board.CreateKanbanBoard then
        return Board:CreateKanbanBoard(parentFrame)
    else
        debug("Board module not available")
        return nil
    end
end

local function RefreshBoard()
    if Board and Board.RefreshBoard then
        Board:RefreshBoard()
    else
        debug("Board module not available")
    end
end

local function ShowAddTaskDialog()
    if Dialogs and Dialogs.ShowAddTaskDialog then
        Dialogs:ShowAddTaskDialog()
    else
        debug("Dialogs module not available")
    end
end

-- Store functions in global table for backward compatibility
_G.Kanban_GUI_Functions = {
    CreateKanbanBoard = CreateKanbanBoard,
    RefreshBoard = RefreshBoard,
    ShowAddTaskDialog = ShowAddTaskDialog
}

-- Attach functions to the addon when it's available (for backward compatibility)
if addon then
    if not addon.GUI then
        addon.GUI = {}
    end
    
    addon.GUI.CreateKanbanBoard = CreateKanbanBoard
    addon.GUI.RefreshBoard = RefreshBoard
    addon.GUI.ShowAddTaskDialog = ShowAddTaskDialog
    
    debug("Legacy GUI functions attached to addon")
else
    debug("Addon not available yet, legacy functions stored in global table")
end

-- Debug: Print that the GUI file loaded
debug("Legacy GUI loader loaded successfully") 