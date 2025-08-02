-- Kanban GUI Components
-- This file will contain all the UI components for the kanban board

local addonName, addon = ...

-- Import libraries
local AceGUI = LibStub("AceGUI-3.0")
local AceAddon = LibStub("AceAddon-3.0")

-- Debug function
local function debug(message)
    print("|cFF00FF00Kanban|r: " .. message)
end

-- Kanban board columns
local COLUMNS = {
    {name = "To-Do", color = {0.2, 0.6, 1.0}},      -- Blue
    {name = "In Progress", color = {1.0, 0.6, 0.2}}, -- Orange
    {name = "Done", color = {0.2, 0.8, 0.2}}         -- Green
}

-- Task data structure (abstraction for future CRUD)
local tasks = {
    {
        id = 1,
        title = "Sample Task",
        description = "This is a sample task to test the kanban board functionality.",
        status = "To-Do",
        created = time(),
        priority = "Medium"
    }
}

-- Task management functions (abstraction for future CRUD)
local function getTasksByStatus(status)
    local result = {}
    for _, task in ipairs(tasks) do
        if task.status == status then
            table.insert(result, task)
        end
    end
    return result
end

local function moveTask(taskId, newStatus)
    for _, task in ipairs(tasks) do
        if task.id == taskId then
            task.status = newStatus
            return true
        end
    end
    return false
end

local function addTask(title, description, priority)
    local newTask = {
        id = #tasks + 1,
        title = title,
        description = description,
        status = "To-Do",
        created = time(),
        priority = priority or "Medium"
    }
    table.insert(tasks, newTask)
    return newTask.id
end

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
    
    for _, column in ipairs(COLUMNS) do
        if column.name ~= task.status then
            local moveButton = AceGUI:Create("Button")
            moveButton:SetText("→ " .. column.name)
            moveButton:SetWidth(80)
            moveButton:SetCallback("OnClick", function()
                if moveTask(task.id, column.name) then
                    -- Refresh the board
                    if addon and addon.GUI and addon.GUI.RefreshBoard then
                        addon.GUI:RefreshBoard()
                    end
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
    local columnTasks = getTasksByStatus(columnData.name)
    debug("Found " .. #columnTasks .. " tasks for column " .. columnData.name)
    
    -- Add task cards
    for _, task in ipairs(columnTasks) do
        local taskCard = createTaskCard(task, parentFrame)
        columnGroup:AddChild(taskCard)
    end
    
    -- Add new task button for To-Do column
    if columnData.name == "To-Do" then
        local addButton = AceGUI:Create("Button")
        addButton:SetText("+ Add Task")
        addButton:SetWidth(180)
        addButton:SetCallback("OnClick", function()
            if addon and addon.GUI and addon.GUI.ShowAddTaskDialog then
                addon.GUI:ShowAddTaskDialog()
            end
        end)
        columnGroup:AddChild(addButton)
    end
    
    return columnGroup
end

-- Show add task dialog
local function ShowAddTaskDialog()
    local dialog = AceGUI:Create("Frame")
    dialog:SetTitle("Add New Task")
    dialog:SetLayout("Flow")
    dialog:SetWidth(400)
    dialog:SetHeight(300)
    dialog:SetCallback("OnClose", function(widget)
        widget:Release()
    end)
    
    -- Title input
    local titleLabel = AceGUI:Create("Label")
    titleLabel:SetText("Title:")
    dialog:AddChild(titleLabel)
    
    local titleEdit = AceGUI:Create("EditBox")
    titleEdit:SetWidth(350)
    titleEdit:SetCallback("OnEnterPressed", function(widget, event, text)
        widget:ClearFocus()
    end)
    dialog:AddChild(titleEdit)
    
    -- Description input
    local descLabel = AceGUI:Create("Label")
    descLabel:SetText("Description:")
    dialog:AddChild(descLabel)
    
    local descEdit = AceGUI:Create("MultiLineEditBox")
    descEdit:SetWidth(350)
    descEdit:SetHeight(100)
    descEdit:SetNumLines(4)
    dialog:AddChild(descEdit)
    
    -- Priority dropdown
    local priorityLabel = AceGUI:Create("Label")
    priorityLabel:SetText("Priority:")
    dialog:AddChild(priorityLabel)
    
    local priorityDropdown = AceGUI:Create("Dropdown")
    priorityDropdown:SetWidth(200)
    priorityDropdown:SetList({
        ["Low"] = "Low",
        ["Medium"] = "Medium", 
        ["High"] = "High"
    })
    priorityDropdown:SetValue("Medium")
    dialog:AddChild(priorityDropdown)
    
    -- Buttons
    local buttonGroup = AceGUI:Create("InlineGroup")
    buttonGroup:SetLayout("Flow")
    
    local addButton = AceGUI:Create("Button")
    addButton:SetText("Add Task")
    addButton:SetWidth(100)
    addButton:SetCallback("OnClick", function()
        local title = titleEdit:GetText()
        local description = descEdit:GetText()
        local priority = priorityDropdown:GetValue()
        
        if title and title ~= "" then
            addTask(title, description, priority)
            if addon and addon.GUI and addon.GUI.RefreshBoard then
                addon.GUI:RefreshBoard()
            end
            dialog:Release()
        else
            debug("Please enter a task title!")
        end
    end)
    buttonGroup:AddChild(addButton)
    
    local cancelButton = AceGUI:Create("Button")
    cancelButton:SetText("Cancel")
    cancelButton:SetWidth(100)
    cancelButton:SetCallback("OnClick", function()
        dialog:Release()
    end)
    buttonGroup:AddChild(cancelButton)
    
    dialog:AddChild(buttonGroup)
end

-- Refresh the entire board
local function RefreshBoard()
    if addon and addon.mainFrame and addon.mainFrame:IsShown() then
        addon:CreateMainWindow()
    end
end

-- Create the kanban board
local function CreateKanbanBoard(parentFrame)
    debug("CreateKanbanBoard called")
    
    local boardGroup = AceGUI:Create("InlineGroup")
    boardGroup:SetLayout("Flow")
    boardGroup:SetWidth(700)
    boardGroup:SetHeight(550)
    
    debug("Creating " .. #COLUMNS .. " columns")
    
    -- Create columns
    for _, columnData in ipairs(COLUMNS) do
        local column = createColumn(columnData, parentFrame)
        boardGroup:AddChild(column)
    end
    
    debug("Kanban board creation complete")
    return boardGroup
end

-- Store functions in global table for main addon to access
_G.Kanban_GUI_Functions = {
    CreateKanbanBoard = CreateKanbanBoard,
    RefreshBoard = RefreshBoard,
    ShowAddTaskDialog = ShowAddTaskDialog
}

-- Attach functions to the addon when it's available
if addon then
    if not addon.GUI then
        addon.GUI = {}
    end
    
    addon.GUI.CreateKanbanBoard = CreateKanbanBoard
    addon.GUI.RefreshBoard = RefreshBoard
    addon.GUI.ShowAddTaskDialog = ShowAddTaskDialog
    
    debug("GUI functions attached to addon")
else
    debug("Addon not available yet, functions stored in global table")
end

-- Debug: Print that the GUI file loaded
debug("GUI file loaded successfully") 