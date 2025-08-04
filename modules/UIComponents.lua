-- Kanban UIComponents Module
-- Contains individual UI components like task cards and columns

local addonName, addon = ...

-- Import libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Import utilities and task manager
local Utils = _G.Kanban_Utils or {}
local TaskManager = _G.Kanban_TaskManager or {}
local debug = Utils.debug or function(msg) print("|cFF00FF00Kanban|r: " .. msg) end

-- Create a task card widget
local function createTaskCard(task, parentFrame)
    debug("Creating task card for: " .. task.title .. " (ID: " .. task.id .. ", Status: " .. task.status .. ")")
    
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
    
    -- Action buttons (move and delete)
    local buttonGroup = AceGUI:Create("InlineGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetWidth(180)
    
    -- Move buttons
    for _, column in ipairs(Utils.COLUMNS or {}) do
        if column.name ~= task.status then
            local moveButton = AceGUI:Create("Button")
            moveButton:SetText("→ " .. column.name)
            -- moveButton:SetWidth(80)
            moveButton:SetCallback("OnClick", function()
                debug("Move button clicked for task " .. task.id .. " to " .. column.name)
                if TaskManager.moveTask and TaskManager.moveTask(task.id, column.name) then
                    debug("Task moved successfully, refreshing board")
                    -- Use the proper refresh method that releases and recreates the window
                    if _G.Kanban and _G.Kanban.RefreshMainWindow then
                        debug("Using RefreshMainWindow for task move")
                        _G.Kanban:RefreshMainWindow()
                    else
                        debug("RefreshMainWindow not available")
                    end
                else
                    debug("Failed to move task")
                end
            end)
            buttonGroup:AddChild(moveButton)
        end
    end
    
    -- Edit button
    local editButton = AceGUI:Create("Button")
    editButton:SetText("✏️ Edit")
    -- editButton:SetWidth(80)
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
    -- deleteButton:SetWidth(80)
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
    
    debug("Task card created successfully for: " .. task.title)
    return cardGroup
end

-- Create a column widget
local function createColumn(columnData, parentFrame)
    debug("Creating column: " .. columnData.name)
    
    -- Create a simple column group with title
    local columnGroup = AceGUI:Create("InlineGroup") --TODO: can i make this a simple group?
    columnGroup:SetLayout("List")
    columnGroup:SetFullHeight(true)
    
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

-- Export UI components
local UIComponents = {
    createTaskCard = createTaskCard,
    createColumn = createColumn
}

-- Make available globally
_G.Kanban_UIComponents = UIComponents

-- Attach to addon if available
if addon then
    addon.UIComponents = UIComponents
end

return UIComponents 