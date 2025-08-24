-- Kanban UIComponents Module
-- Contains individual UI components like task cards and columns

local addonName, addon = ...

-- Import libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Import utilities and task manager
local Utils = _G.Kanban_Utils or {}
local TaskManager = _G.Kanban_TaskManager or {}
local debug = Utils.debug or function(msg) print("|cFF00FF00Kanban|r: " .. msg) end

-- Global variables for drag and drop
local dragState = {
    isDragging = false,
    draggedWidget = nil,
    originalParent = nil,
    originalPosition = nil,
    dropZones = {},
    dragGhost = nil
}

-- Function to create drop zones for each column
local function createDropZone(columnName, parentFrame)
    local dropZone = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    dropZone:SetAllPoints()
    dropZone.columnName = columnName
    
    debug("Created drop zone for column: " .. columnName)
    
    -- Visual feedback
    dropZone:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    dropZone:SetBackdropColor(0, 0, 0, 0)
    dropZone:SetBackdropBorderColor(0, 0, 0, 0)
    
    -- Store reference to drop zone
    dragState.dropZones[columnName] = dropZone
    
    -- Add debug info
    dropZone:SetScript("OnEnter", function(self)
        debug("Mouse entered drop zone: " .. columnName)
    end)
    
    return dropZone
end

-- Function to get drop target based on mouse position
local function getDropTarget()
    local mouseX, mouseY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    mouseX = mouseX / uiScale
    mouseY = mouseY / uiScale
    
    debug("Mouse position: " .. mouseX .. ", " .. mouseY)
    
    -- Check all drop zones
    for columnName, dropZone in pairs(dragState.dropZones) do
        if dropZone:IsVisible() then
            -- Get the drop zone's position relative to the screen
            local left, bottom, width, height = dropZone:GetRect()
            debug("Drop zone " .. columnName .. ": " .. left .. ", " .. bottom .. ", " .. width .. ", " .. height)
            
            -- Check if mouse is within the drop zone bounds
            if mouseX >= left and mouseX <= left + width and
               mouseY >= bottom and mouseY <= bottom + height then
                debug("Found drop target: " .. columnName)
                return dropZone
            end
        else
            debug("Drop zone " .. columnName .. " is not visible")
        end
    end
    
    debug("No drop target found")
    return nil
end

-- Function to handle task drop
local function handleTaskDrop(draggedWidget, taskData, targetDropZone)
    if not targetDropZone or not taskData then
        debug("Invalid drop target or task data")
        return false
    end
    
    local newStatus = targetDropZone.columnName
    debug("Dropping task " .. taskData.id .. " to column: " .. newStatus)
    
    -- Move the task in the data layer
    if TaskManager.moveTask and TaskManager.moveTask(taskData.id, newStatus) then
        debug("Task moved successfully in data layer")
        
        -- Refresh the UI to show the change
        if _G.Kanban and _G.Kanban.RefreshMainWindow then
            debug("Refreshing main window after task move")
            _G.Kanban:RefreshMainWindow()
        else
            debug("RefreshMainWindow not available")
        end
        
        return true
    else
        debug("Failed to move task in data layer")
        return false
    end
end

-- Function to create a drag ghost
local function createDragGhost(taskData)
    local ghost = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    ghost:SetSize(200, 120) -- Same size as task cards
    ghost:SetFrameStrata("TOOLTIP")
    ghost:SetFrameLevel(1000)
    
    -- Create ghost appearance
    ghost:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    ghost:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    ghost:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
    
    -- Add task title to ghost
    local titleText = ghost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("TOPLEFT", 10, -10)
    titleText:SetPoint("TOPRIGHT", -10, -10)
    titleText:SetText(taskData.title)
    titleText:SetTextColor(1, 1, 1, 0.8)
    ghost.titleText = titleText
    
    -- Add priority indicator
    local priorityText = ghost:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    priorityText:SetPoint("BOTTOMLEFT", 10, 10)
    priorityText:SetText("Priority: " .. taskData.priority)
    if taskData.priority == "High" then
        priorityText:SetTextColor(1, 0.3, 0.3, 0.8)
    elseif taskData.priority == "Medium" then
        priorityText:SetTextColor(1, 1, 0.3, 0.8)
    else
        priorityText:SetTextColor(0.3, 1, 0.3, 0.8)
    end
    ghost.priorityText = priorityText
    
    return ghost
end

-- Function to update drag ghost position
local function updateDragGhostPosition()
    if dragState.dragGhost then
        local mouseX, mouseY = GetCursorPosition()
        local uiScale = UIParent:GetEffectiveScale()
        mouseX = mouseX / uiScale
        mouseY = mouseY / uiScale
        
        -- Position ghost at mouse cursor, offset slightly so it doesn't cover the cursor
        dragState.dragGhost:SetPoint("CENTER", UIParent, "BOTTOMLEFT", mouseX, mouseY)
    end
end

-- Function to destroy drag ghost
local function destroyDragGhost()
    if dragState.dragGhost then
        dragState.dragGhost:Hide()
        dragState.dragGhost:SetParent(nil)
        dragState.dragGhost = nil
    end
end

-- Function to restore dragged widget to original position
local function restoreDraggedWidget()
    if dragState.draggedWidget and dragState.originalParent then
        debug("Restoring dragged widget to original position")
        
        -- Destroy the drag ghost
        destroyDragGhost()
        
        -- For AceGUI widgets, we need to refresh the entire UI instead of trying to restore
        -- Clear drag state first
        dragState.isDragging = false
        dragState.draggedWidget = nil
        dragState.originalParent = nil
        dragState.originalPosition = nil
        
        -- Refresh the UI to restore proper layout
        if _G.Kanban and _G.Kanban.RefreshMainWindow then
            debug("Refreshing UI to restore dragged widget")
            _G.Kanban:RefreshMainWindow()
        end
    end
end

-- Create a draggable task card widget
local function createTaskCard(task, parentFrame)
    debug("Creating draggable task card for: " .. task.title .. " (ID: " .. task.id .. ", Status: " .. task.status .. ")")
    
    local cardGroup = AceGUI:Create("InlineGroup")
    cardGroup:SetLayout("Flow")
    cardGroup:SetWidth(200)
    cardGroup:SetHeight(120)
    
    -- Task title
    local titleLabel = AceGUI:Create("Label")
    titleLabel:SetText(task.title)
    titleLabel:SetColor(1, 1, 1)
    cardGroup:AddChild(titleLabel)
    
    -- Task description
    local descLabel = AceGUI:Create("Label")
    descLabel:SetText(task.description)
    descLabel:SetColor(0.8, 0.8, 0.8)
    cardGroup:AddChild(descLabel)
    
    -- Priority indicator
    local priorityLabel = AceGUI:Create("Label")
    priorityLabel:SetText("Priority: " .. task.priority)
    if task.priority == "High" then
        priorityLabel:SetColor(1, 0.3, 0.3)
    elseif task.priority == "Medium" then
        priorityLabel:SetColor(1, 1, 0.3)
    else
        priorityLabel:SetColor(0.3, 1, 0.3)
    end
    cardGroup:AddChild(priorityLabel)
    
    -- Action buttons (edit and delete only - removed move buttons)
    local buttonGroup = AceGUI:Create("InlineGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetWidth(180)
    
    -- Edit button
    local editButton = AceGUI:Create("Button")
    editButton:SetText("✏️ Edit")
    editButton:SetCallback("OnClick", function()
        debug("Edit button clicked for task " .. task.id .. " with title: " .. task.title)
        -- Show edit dialog
        local Dialogs = _G.Kanban_Dialogs
        if Dialogs and Dialogs.ShowEditTaskDialog then
            debug("Calling ShowEditTaskDialog with taskId: " .. task.id)
            Dialogs.ShowEditTaskDialog(task.id)
        else
            debug("Edit dialog not available")
        end
    end)
    buttonGroup:AddChild(editButton)
    
    -- Delete button
    local deleteButton = AceGUI:Create("Button")
    deleteButton:SetText("🗑️ Delete")
    deleteButton:SetCallback("OnClick", function()
        debug("Delete button clicked for task " .. task.id)
        -- Show confirmation dialog
        local Dialogs = _G.Kanban_Dialogs
        if Dialogs and Dialogs.ShowConfirmDeleteDialog then
            Dialogs.ShowConfirmDeleteDialog(task.id)
        else
            debug("Delete dialog not available")
        end
    end)
    buttonGroup:AddChild(deleteButton)
    
    cardGroup:AddChild(buttonGroup)
    
    -- Make the card draggable
    local frame = cardGroup.frame
    frame:EnableMouse(true)
    
    -- Store task data in the frame for drag operations
    frame.taskData = task
    
    -- Add hover effects to indicate draggability
    frame:SetScript("OnEnter", function(self)
        if not dragState.isDragging then
            -- Add a subtle highlight to show the card is interactive
            self:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 16,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            self:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
            self:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
        end
    end)
    
    frame:SetScript("OnLeave", function(self)
        if not dragState.isDragging then
            -- Remove the highlight
            self:SetBackdrop(nil)
        end
    end)
    
    -- Drag start handler
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not dragState.isDragging then
            debug("Starting drag for task: " .. task.title)
            
            -- Store drag state
            dragState.isDragging = true
            dragState.draggedWidget = cardGroup
            dragState.originalParent = self:GetParent()
            dragState.originalPosition = {self:GetPoint()}
            
            -- Create and show drag ghost
            dragState.dragGhost = createDragGhost(task)
            updateDragGhostPosition()
            
            -- Change cursor to indicate dragging
            SetCursor("Interface\\CURSOR\\UI-Cursor-Move")
            
            -- Highlight drop zones
            for _, dropZone in pairs(dragState.dropZones) do
                if dropZone.columnName ~= task.status then
                    dropZone:SetBackdropColor(0.2, 0.6, 1, 0.3)
                    dropZone:SetBackdropBorderColor(0.2, 0.6, 1, 0.8)
                end
            end
            
            -- Set up mouse movement tracking for ghost
            frame:SetScript("OnUpdate", function(self)
                if dragState.isDragging then
                    updateDragGhostPosition()
                end
            end)
        end
    end)
    
    -- Drag end handler
    frame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and dragState.isDragging then
            debug("Ending drag for task: " .. task.title)
            
            -- Stop mouse movement tracking
            frame:SetScript("OnUpdate", nil)
            
            -- Reset cursor
            ResetCursor()
            
            -- Clear drop zone highlighting
            for _, dropZone in pairs(dragState.dropZones) do
                dropZone:SetBackdropColor(0, 0, 0, 0)
                dropZone:SetBackdropBorderColor(0, 0, 0, 0)
            end
            
            -- Check for valid drop target
            local targetDropZone = getDropTarget()
            if targetDropZone and targetDropZone.columnName ~= task.status then
                debug("Valid drop target found: " .. targetDropZone.columnName)
                -- Destroy ghost before handling drop
                destroyDragGhost()
                handleTaskDrop(cardGroup, task, targetDropZone)
            else
                debug("No valid drop target, restoring original position")
                restoreDraggedWidget()
            end
        end
    end)
    
    debug("Draggable task card created successfully for: " .. task.title)
    return cardGroup
end

-- Create a column widget with drop zone
local function createColumn(columnData, parentFrame)
    debug("Creating column with drop zone: " .. columnData.name)
    
    -- Create a simple column group with title
    local columnGroup = AceGUI:Create("InlineGroup")
    columnGroup:SetLayout("List")
    columnGroup:SetFullHeight(true)
    
    -- Create drop zone for this column - attach to the column frame
    local dropZone = createDropZone(columnData.name, columnGroup.frame)
    
    -- Make sure the drop zone covers the entire column area
    dropZone:SetFrameLevel(columnGroup.frame:GetFrameLevel() + 1)
    
    -- Get tasks for this column
    local columnTasks = {}
    if TaskManager.getTasksByStatus then
        columnTasks = TaskManager.getTasksByStatus(columnData.name)
        debug("Retrieved " .. #columnTasks .. " tasks for column " .. columnData.name)
        for _, task in ipairs(columnTasks) do
            debug("  - Task: " .. task.title .. " (ID: " .. task.id .. ", Status: " .. task.status .. ")")
        end
    else
        debug("TaskManager.getTasksByStatus not available")
    end
    debug("Found " .. #columnTasks .. " tasks for column " .. columnData.name)
    
    -- Also show all tasks for debugging
    if TaskManager.getAllTasks then
        local allTasks = TaskManager.getAllTasks()
        debug("Total tasks in system: " .. #allTasks)
        for _, task in ipairs(allTasks) do
            debug("  All tasks - ID: " .. task.id .. ", Title: " .. task.title .. ", Status: " .. task.status)
        end
    end
    
    -- Add task cards
    debug("Adding " .. #columnTasks .. " task cards to column " .. columnData.name)
    for _, task in ipairs(columnTasks) do
        local taskCard = createTaskCard(task, parentFrame)
        if taskCard then
            columnGroup:AddChild(taskCard)
            debug("Added task card for: " .. task.title)
        else
            debug("Failed to create task card for: " .. task.title)
        end
    end

    return columnGroup
end

-- Function to clear drop zones (call this when refreshing the board)
local function clearDropZones()
    -- Clean up any existing drag ghost
    destroyDragGhost()
    
    dragState.dropZones = {}
    dragState.isDragging = false
    dragState.draggedWidget = nil
    dragState.originalParent = nil
    dragState.originalPosition = nil
end

-- Export UI components
local UIComponents = {
    createTaskCard = createTaskCard,
    createColumn = createColumn,
    clearDropZones = clearDropZones
}

-- Make available globally
_G.Kanban_UIComponents = UIComponents

-- Attach to addon if available
if addon then
    addon.UIComponents = UIComponents
end

return UIComponents 