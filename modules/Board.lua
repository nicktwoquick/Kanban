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

-- Refresh the board by removing children and re-adding them
local function RefreshBoard()
    debug("RefreshBoard called")
    
    local mainAddon = _G.Kanban
    if not mainAddon or not mainAddon.mainFrame then
        debug("No main frame available for refresh")
        return
    end
    
    debug("Starting board refresh - mainFrame exists: " .. tostring(mainAddon.mainFrame ~= nil))
    
    -- Find the board container (it should be the second child after the CRUD button row)
    local boardContainer = nil
    local children = mainAddon.mainFrame.children or {}
    
    debug("Main frame has " .. #children .. " children")
    
    -- Look for the board container (should be the second child)
    if #children >= 2 then
        boardContainer = children[2]
        debug("Found board container at index 2")
    else
        debug("Board container not found in expected position")
        return
    end
    
    if not boardContainer then
        debug("Board container is nil")
        return
    end
    
    -- Pause layout during the refresh operation
    boardContainer:PauseLayout()
    
    -- Remove all existing children from the board container
    debug("Removing existing board children")
    boardContainer:ReleaseChildren()
    
    -- Recreate the kanban board using the same pattern as initial creation
    debug("Recreating kanban board using CreateKanbanBoard")
    local success, kanbanBoard = pcall(function()
        if mainAddon.Board and mainAddon.Board.CreateKanbanBoard then
            return mainAddon.Board:CreateKanbanBoard(mainAddon.mainFrame)
        else
            debug("Board.CreateKanbanBoard not found")
            return nil
        end
    end)
    
    if success and kanbanBoard then
        debug("Kanban board recreated successfully")
        boardContainer:AddChild(kanbanBoard)
        debug("Kanban board added to container")
    else
        debug("Failed to recreate kanban board")
        if not success then
            debug("Error: " .. tostring(kanbanBoard))
        end
        
        -- Add fallback content
        local fallbackLabel = AceGUI:Create("Label")
        fallbackLabel:SetText("Kanban board failed to load. Check for errors.")
        fallbackLabel:SetColor(1, 0, 0)
        boardContainer:AddChild(fallbackLabel)
    end
    
    -- Resume layout and force a layout update
    boardContainer:ResumeLayout()
    boardContainer:DoLayout()
    
    debug("Board refresh completed successfully")
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