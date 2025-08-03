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
    
    local boardGroup = AceGUI:Create("SimpleGroup")
    boardGroup:SetLayout("List")
    boardGroup:SetWidth(700)
    boardGroup:SetFullHeight(true) -- Use full available height
    boardGroup:SetFullWidth(true)
    
    local columns = Utils.COLUMNS or {}
    debug("Creating " .. #columns .. " columns")
    
    -- Create title row
    local titleRow = AceGUI:Create("InlineGroup")
    titleRow:SetLayout("Flow")
    titleRow:SetWidth(700)
    titleRow:SetHeight(40) -- Keep fixed height for title row
    titleRow:SetFullWidth(true)
    
    -- Add column titles
    for _, columnData in ipairs(columns) do
        local titleLabel = AceGUI:Create("Label")
        titleLabel:SetText(columnData.name)
        titleLabel:SetColor(unpack(columnData.color))
        titleLabel:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        titleLabel:SetWidth(220)
        titleLabel:SetHeight(30)
        titleLabel:SetJustifyH("CENTER")
        titleRow:AddChild(titleLabel)
    end
    
    boardGroup:AddChild(titleRow)
    
    -- Create a scrollable container for all columns
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetWidth(700)
    scrollFrame:SetFullWidth(true)
    -- Calculate available height: Board container (583) - InlineGroup padding (20) - Title row (40) - Title row padding (20)
    -- 583 - 20 - 40 - 20 = 503px available for scroll frame
    scrollFrame:SetHeight(503)
    
    -- Create columns (without headers)
    for _, columnData in ipairs(columns) do
        local column = UIComponents.createColumn and UIComponents.createColumn(columnData, parentFrame)
        if column then
            scrollFrame:AddChild(column)
        else
            debug("Failed to create column: " .. columnData.name)
        end
    end
    
    boardGroup:AddChild(scrollFrame)
    
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