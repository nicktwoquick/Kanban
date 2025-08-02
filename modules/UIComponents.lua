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
    debug("Creating task card for: " .. task.title)
    
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
    
    -- Move buttons
    local buttonGroup = AceGUI:Create("InlineGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetWidth(180)
    
    for _, column in ipairs(Utils.COLUMNS or {}) do
        if column.name ~= task.status then
            local moveButton = AceGUI:Create("Button")
            moveButton:SetText("→ " .. column.name)
            moveButton:SetWidth(80)
            moveButton:SetCallback("OnClick", function()
                debug("Move button clicked for task " .. task.id .. " to " .. column.name)
                if TaskManager.moveTask and TaskManager.moveTask(task.id, column.name) then
                    debug("Task moved successfully, refreshing board")
                    -- Refresh the board
                    if addon and addon.Board and addon.Board.RefreshBoard then
                        addon.Board:RefreshBoard()
                    else
                        debug("Board refresh not available, trying direct refresh")
                        -- Try direct refresh if Board module not available
                        if _G.Kanban and _G.Kanban.RefreshMainWindow then
                            _G.Kanban:RefreshMainWindow()
                        end
                    end
                else
                    debug("Failed to move task")
                end
            end)
            buttonGroup:AddChild(moveButton)
        end
    end
    
    cardGroup:AddChild(buttonGroup)
    
    return cardGroup
end

-- Create a column widget
local function createColumn(columnData, parentFrame)
    debug("Creating column: " .. columnData.name)
    
    local columnGroup = AceGUI:Create("InlineGroup")
    columnGroup:SetLayout("List")
    columnGroup:SetWidth(220)
    columnGroup:SetHeight(500)
    
    -- Column header
    local headerLabel = AceGUI:Create("Label")
    headerLabel:SetText(columnData.name)
    headerLabel:SetColor(unpack(columnData.color))
    columnGroup:AddChild(headerLabel)
    
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
    for _, task in ipairs(columnTasks) do
        local taskCard = createTaskCard(task, parentFrame)
        columnGroup:AddChild(taskCard)
    end
    
    -- Remove the add task button since it's now in the CRUD button row
    -- if columnData.name == "To-Do" then
    --     local addButton = AceGUI:Create("Button")
    --     addButton:SetText("+ Add Task")
    --     addButton:SetWidth(180)
    --     addButton:SetCallback("OnClick", function()
    --         if addon and addon.Dialogs and addon.Dialogs.ShowAddTaskDialog then
    --             addon.Dialogs:ShowAddTaskDialog()
    --         end
    --     end)
    --     columnGroup:AddChild(addButton)
    -- end
    
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