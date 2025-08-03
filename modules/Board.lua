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
    scrollContainer:SetFullHeight(true)
    scrollContainer:SetWidth(880)

    -- Create the actual scroll frame for items
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow") -- flow here because we want rows of our columns
    scrollFrame:SetFullWidth(true)


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
    return boardGroup
end

-- Refresh the board by removing children and re-adding them
local function RefreshBoard()
    debug("RefreshBoard called")
    
    local mainAddon = _G.Kanban
    debug("mainAddon check: " .. tostring(mainAddon ~= nil))
    if not mainAddon or not mainAddon.mainFrame then
        debug("No main frame available for refresh")
        return
    end
    
    debug("mainFrame exists: " .. tostring(mainAddon.mainFrame ~= nil))
    
    -- Check if the main frame is still valid (optional check)
    local isValid = true
    if mainAddon.mainFrame.IsValid then
        local success, result = pcall(function() return mainAddon.mainFrame:IsValid() end)
        if success then
            isValid = result
        else
            debug("IsValid() call failed: " .. tostring(result))
            isValid = true -- Assume valid if check fails
        end
    end
    
    if not isValid then
        debug("Main frame is no longer valid")
        return
    end
    
    debug("Main frame is valid")
    debug("Starting board refresh - mainFrame exists: " .. tostring(mainAddon.mainFrame ~= nil))
    
    -- Find the board container (InlineGroup that contains the kanban board)
    local boardContainer = nil
    local children = {}
    
    debug("About to get children count")
    -- Get all children of the main frame using the correct AceGUI method
    local children = {}
    
    -- Try to access children using the widget's children property or method
    if mainAddon.mainFrame.children then
        -- Some widgets have a children property
        children = mainAddon.mainFrame.children
        debug("Found children property, count: " .. tostring(#children))
    elseif mainAddon.mainFrame.GetChildren then
        -- Some widgets have a GetChildren method
        local success, result = pcall(function() return mainAddon.mainFrame:GetChildren() end)
        if success then
            children = result
            debug("Found GetChildren method, count: " .. tostring(#children))
        else
            debug("GetChildren() call failed: " .. tostring(result))
        end
    else
        debug("No known method to access children")
        -- Try to access the widget's internal structure
        if mainAddon.mainFrame.frame then
            debug("Widget has frame property, trying to access children through frame")
            -- Some AceGUI widgets store children in the frame
            if mainAddon.mainFrame.frame.children then
                children = mainAddon.mainFrame.frame.children
                debug("Found children in frame, count: " .. tostring(#children))
            end
        end
    end
    
    debug("Main frame has " .. #children .. " children")
    
    -- Look for the board container (should be the second child after the CRUD button row)
    if #children >= 2 then
        boardContainer = children[2]
        debug("Found board container at index 2, type: " .. tostring(boardContainer and boardContainer.type))
    else
        debug("Board container not found in expected position")
        return
    end
    
    if not boardContainer then
        debug("Board container is nil")
        return
    end
    
    -- Check if the board container is still valid (optional check)
    local boardContainerValid = true
    if boardContainer.IsValid then
        local success, result = pcall(function() return boardContainer:IsValid() end)
        if success then
            boardContainerValid = result
        else
            debug("Board container IsValid() call failed: " .. tostring(result))
            boardContainerValid = true -- Assume valid if check fails
        end
    end
    
    if not boardContainerValid then
        debug("Board container is no longer valid")
        return
    end
    
    debug("Board container is valid")
    
    -- Check what children the board container has
    local boardChildren = {}
    debug("About to get board container children count")
    
    -- Try to access children using the widget's children property or method
    if boardContainer.children then
        -- Some widgets have a children property
        boardChildren = boardContainer.children
        debug("Found board container children property, count: " .. tostring(#boardChildren))
    elseif boardContainer.GetChildren then
        -- Some widgets have a GetChildren method
        local success, result = pcall(function() return boardContainer:GetChildren() end)
        if success then
            boardChildren = result
            debug("Found board container GetChildren method, count: " .. tostring(#boardChildren))
        else
            debug("Board container GetChildren() call failed: " .. tostring(result))
        end
    else
        debug("No known method to access board container children")
        -- Try to access the widget's internal structure
        if boardContainer.frame then
            debug("Board container has frame property, trying to access children through frame")
            -- Some AceGUI widgets store children in the frame
            if boardContainer.frame.children then
                boardChildren = boardContainer.frame.children
                debug("Found board container children in frame, count: " .. tostring(#boardChildren))
            end
        end
    end
    
    debug("Board container has " .. #boardChildren .. " children")
    
    -- Log the types of board children for debugging
    for i, child in ipairs(boardChildren) do
        debug("Board container child " .. i .. " type: " .. tostring(child and child.type))
    end
    
    -- Find the kanban board within the board container
    local kanbanBoard = nil
    if #boardChildren >= 1 then
        kanbanBoard = boardChildren[1]
        debug("Found kanban board, type: " .. tostring(kanbanBoard.type))
    else
        debug("No kanban board found in board container")
        return
    end
    
    -- Check if the kanban board is still valid (optional check)
    local kanbanBoardValid = true
    if kanbanBoard.IsValid then
        local success, result = pcall(function() return kanbanBoard:IsValid() end)
        if success then
            kanbanBoardValid = result
        else
            debug("Kanban board IsValid() call failed: " .. tostring(result))
            kanbanBoardValid = true -- Assume valid if check fails
        end
    end
    
    if not kanbanBoardValid then
        debug("Kanban board is not valid")
        return
    end
    
    debug("Kanban board is valid")
    
    -- Pause layout during the refresh operation
    if kanbanBoard.PauseLayout then
        debug("Pausing layout")
        kanbanBoard:PauseLayout()
    else
        debug("No PauseLayout method")
    end
    
    -- Remove all existing children from the kanban board
    debug("Removing existing kanban board children")
    if kanbanBoard.ReleaseChildren then
        kanbanBoard:ReleaseChildren()
        debug("Released children")
    else
        debug("Kanban board doesn't have ReleaseChildren method")
        return
    end
    
    -- Recreate the columns within the existing kanban board
    debug("Recreating columns within existing kanban board")
    local columns = Utils.COLUMNS or {}
    debug("Creating " .. #columns .. " columns")
    
    for _, columnData in ipairs(columns) do
        debug("Creating column: " .. columnData.name)
        local column = UIComponents.createColumn and UIComponents.createColumn(columnData, mainAddon.mainFrame)
        if column then
            kanbanBoard:AddChild(column)
            debug("Added column: " .. columnData.name)
        else
            debug("Failed to create column: " .. columnData.name)
        end
    end
    
    -- Resume layout and force a layout update
    if kanbanBoard.ResumeLayout then
        debug("Resuming layout")
        kanbanBoard:ResumeLayout()
    else
        debug("No ResumeLayout method")
    end
    if kanbanBoard.DoLayout then
        debug("Doing layout")
        kanbanBoard:DoLayout()
    else
        debug("No DoLayout method")
    end
    
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