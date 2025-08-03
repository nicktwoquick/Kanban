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
    
    local columns = Utils.COLUMNS or {}
    debug("Creating " .. #columns .. " columns")

    -- Create a parent container for a scroll board which requires fill layout
    local scrollContainer = AceGUI:Create("SimpleGroup")
    scrollContainer:SetLayout("Fill")
    scrollContainer:SetFullHeight(true) -- TODO: parent is touch to large
    scrollContainer:SetFullWidth(true)
    
    -- Create the actual scroll frame for items
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Table") -- Use Table layout for proper column arrangement
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    
    -- Set up table columns: equal width for all columns, left-aligned
    local columnCount = #columns
    local columnWidth = 1.0 / columnCount -- Equal width distribution
    local tableConfig = {
        columns = {}
    }
    
    for i = 1, columnCount do
        tableConfig.columns[i] = {
            width = columnWidth,
            align = "TOPLEFT"
        }
    end
    tableConfig.spaceH = 10 -- Horizontal spacing between columns
    
    scrollFrame:SetUserData("table", tableConfig)
    debug("Set up table layout with " .. columnCount .. " columns, each " .. (columnWidth * 100) .. "% width")

    -- Create columns directly without complex nesting    
    for _, columnData in ipairs(columns) do
        local column = UIComponents.createColumn and UIComponents.createColumn(columnData, parentFrame)
        if column then
            scrollFrame:AddChild(column)
            debug("Added column: " .. columnData.name)
        else
            debug("Failed to create column: " .. columnData.name)
        end
    end

    -- Add the scroll container to the board group
    scrollContainer:AddChild(scrollFrame)

    -- Create a simple group that will work with Flow layout
    local boardGroup = AceGUI:Create("SimpleGroup")
    boardGroup:SetLayout("Flow") -- Use Flow layout to arrange columns horizontally
    
    -- Add the scroll container to the board group
    boardGroup:AddChild(scrollContainer)

    debug("Kanban board creation complete")
    debug("Board group created: " .. tostring(boardGroup ~= nil))
    if boardGroup then
        debug("Board group type: " .. tostring(boardGroup.type))
    end
    return boardGroup
end

-- Note: RefreshBoard function removed - use RefreshMainWindow() instead
-- The RefreshBoard approach of manipulating existing children doesn't work properly
-- with AceGUI widgets. Instead, we use the proper RefreshMainWindow() method
-- that releases and recreates the entire window.

-- Export board functions
local Board = {
    CreateKanbanBoard = CreateKanbanBoard
}

-- Make available globally
_G.Kanban_Board = Board

-- Attach to addon if available
if addon then
    addon.Board = Board
end

return Board 