-- Kanban Board Module
-- Handles the main kanban board layout and refresh logic

local addonName, addon = ...

-- Import libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Import utilities and other modules
local Utils = _G.Kanban_Utils or {}
local TaskManager = _G.Kanban_TaskManager or {}
local UIComponents = _G.Kanban_UIComponents or {}
local debug = Utils.debug or function(msg) print("|cFF00FF00Kanban|r: " .. msg) end

-- Create the kanban board
local function CreateKanbanBoard(parentFrame)
    debug("CreateKanbanBoard called")
    
    local boardGroup = AceGUI:Create("InlineGroup")
    boardGroup:SetLayout("Flow")
    boardGroup:SetWidth(700)
    boardGroup:SetHeight(550)
    
    local columns = Utils.COLUMNS or {}
    debug("Creating " .. #columns .. " columns")
    
    -- Create columns
    for _, columnData in ipairs(columns) do
        local column = UIComponents.createColumn and UIComponents.createColumn(columnData, parentFrame)
        if column then
            boardGroup:AddChild(column)
        else
            debug("Failed to create column: " .. columnData.name)
        end
    end
    
    debug("Kanban board creation complete")
    return boardGroup
end

-- Refresh the entire board
local function RefreshBoard()
    local mainAddon = _G.Kanban
    debug("RefreshBoard called - mainAddon: " .. tostring(mainAddon ~= nil))
    if mainAddon then
        debug("RefreshMainWindow available: " .. tostring(mainAddon.RefreshMainWindow ~= nil))
        debug("MainFrame exists: " .. tostring(mainAddon.mainFrame ~= nil))
        if mainAddon.mainFrame then
            debug("MainFrame is shown: " .. tostring(mainAddon.mainFrame:IsShown()))
        end
    end
    if mainAddon and mainAddon.RefreshMainWindow then
        debug("Calling RefreshMainWindow")
        mainAddon:RefreshMainWindow()
        debug("RefreshMainWindow call completed")
    else
        debug("RefreshMainWindow not available")
    end
end

-- Export board functions
local Board = {
    CreateKanbanBoard = CreateKanbanBoard,
    RefreshBoard = RefreshBoard
}

-- Make available globally
_G.Kanban_Board = Board

-- Attach to addon if available
if addon then
    addon.Board = Board
end

return Board 