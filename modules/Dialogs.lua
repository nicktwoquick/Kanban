-- Kanban Dialogs Module
-- Contains dialog windows for adding/editing tasks

local addonName, addon = ...

-- Import libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Import utilities and task manager
local Utils = _G.Kanban_Utils or {}
local TaskManager = _G.Kanban_TaskManager or {}
local debug = Utils.debug or function(msg) print("|cFF00FF00Kanban|r: " .. msg) end

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
    
    -- Enable keyboard input for dialog frame and handle ESC
    dialog.frame:EnableKeyboard(true)
    dialog.frame:SetScript("OnKeyDown", function(frame, key)
        if key == "ESCAPE" then
            debug("ESC pressed on add dialog frame, closing dialog")
            dialog:Release()
        end
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
    -- Enable keyboard input for text field and handle ESC
    titleEdit.frame:EnableKeyboard(true)
    titleEdit.frame:SetScript("OnKeyDown", function(frame, key)
        if key == "ESCAPE" then
            debug("ESC pressed in title field, closing dialog")
            dialog:Release()
        end
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
    -- Enable keyboard input for text field and handle ESC
    descEdit.frame:EnableKeyboard(true)
    descEdit.frame:SetScript("OnKeyDown", function(frame, key)
        if key == "ESCAPE" then
            debug("ESC pressed in description field, closing dialog")
            dialog:Release()
        end
    end)
    dialog:AddChild(descEdit)
    
    -- Priority dropdown
    local priorityLabel = AceGUI:Create("Label")
    priorityLabel:SetText("Priority:")
    dialog:AddChild(priorityLabel)
    
    local priorityDropdown = AceGUI:Create("Dropdown")
    priorityDropdown:SetWidth(200)
    priorityDropdown:SetList(Utils.PRIORITIES or {
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
            if TaskManager.addTask then
                TaskManager.addTask(title, description, priority)
                -- Release the dialog first
                dialog:Release()
                -- Then refresh the board using the proper refresh method
                local mainAddon = _G.Kanban
                if mainAddon and mainAddon.RefreshMainWindow then
                    debug("Add dialog - using RefreshMainWindow for complete refresh")
                    mainAddon:RefreshMainWindow()
                else
                    debug("Add dialog - RefreshMainWindow not available")
                end
            else
                dialog:Release()
            end
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

-- Show edit task dialog
local function ShowEditTaskDialog(taskId)
    debug("ShowEditTaskDialog called with taskId: " .. tostring(taskId))
    local task = TaskManager.getTaskById and TaskManager.getTaskById(taskId)
    if not task then
        debug("Task not found for editing with ID: " .. tostring(taskId))
        return
    end
    debug("Found task for editing: ID=" .. task.id .. ", Title=" .. task.title)
    
    local dialog = AceGUI:Create("Frame")
    dialog:SetTitle("Edit Task")
    dialog:SetLayout("Flow")
    dialog:SetWidth(400)
    dialog:SetHeight(300)
    dialog:SetCallback("OnClose", function(widget)
        widget:Release()
    end)
    
    -- Enable keyboard input for dialog frame and handle ESC
    dialog.frame:EnableKeyboard(true)
    dialog.frame:SetScript("OnKeyDown", function(frame, key)
        if key == "ESCAPE" then
            debug("ESC pressed on edit dialog frame, closing dialog")
            dialog:Release()
        end
    end)
    
    -- Title input
    local titleLabel = AceGUI:Create("Label")
    titleLabel:SetText("Title:")
    dialog:AddChild(titleLabel)
    
    local titleEdit = AceGUI:Create("EditBox")
    titleEdit:SetWidth(350)
    titleEdit:SetText(task.title)
    titleEdit:SetCallback("OnEnterPressed", function(widget, event, text)
        widget:ClearFocus()
    end)
    -- Enable keyboard input for text field and handle ESC
    titleEdit.frame:EnableKeyboard(true)
    titleEdit.frame:SetScript("OnKeyDown", function(frame, key)
        if key == "ESCAPE" then
            debug("ESC pressed in edit title field, closing dialog")
            dialog:Release()
        end
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
    descEdit:SetText(task.description)
    -- Enable keyboard input for text field and handle ESC
    descEdit.frame:EnableKeyboard(true)
    descEdit.frame:SetScript("OnKeyDown", function(frame, key)
        if key == "ESCAPE" then
            debug("ESC pressed in edit description field, closing dialog")
            dialog:Release()
        end
    end)
    dialog:AddChild(descEdit)
    
    -- Priority dropdown
    local priorityLabel = AceGUI:Create("Label")
    priorityLabel:SetText("Priority:")
    dialog:AddChild(priorityLabel)
    
    local priorityDropdown = AceGUI:Create("Dropdown")
    priorityDropdown:SetWidth(200)
    priorityDropdown:SetList(Utils.PRIORITIES or {
        ["Low"] = "Low",
        ["Medium"] = "Medium", 
        ["High"] = "High"
    })
    priorityDropdown:SetValue(task.priority)
    dialog:AddChild(priorityDropdown)
    
    -- Buttons
    local buttonGroup = AceGUI:Create("InlineGroup")
    buttonGroup:SetLayout("Flow")
    
    local saveButton = AceGUI:Create("Button")
    saveButton:SetText("Save Changes")
    saveButton:SetWidth(100)
    saveButton:SetCallback("OnClick", function()
        local title = titleEdit:GetText()
        local description = descEdit:GetText()
        local priority = priorityDropdown:GetValue()
        
        if title and title ~= "" then
            if TaskManager.updateTask then
                TaskManager.updateTask(taskId, {
                    title = title,
                    description = description,
                    priority = priority
                })
                -- Release the dialog first
                dialog:Release()
                -- Then refresh the board using the proper refresh method
                local mainAddon = _G.Kanban
                if mainAddon and mainAddon.RefreshMainWindow then
                    debug("Edit dialog - using RefreshMainWindow for complete refresh")
                    mainAddon:RefreshMainWindow()
                else
                    debug("Edit dialog - RefreshMainWindow not available")
                end
            else
                dialog:Release()
            end
        else
            debug("Please enter a task title!")
        end
    end)
    buttonGroup:AddChild(saveButton)
    
    local cancelButton = AceGUI:Create("Button")
    cancelButton:SetText("Cancel")
    cancelButton:SetWidth(100)
    cancelButton:SetCallback("OnClick", function()
        dialog:Release()
    end)
    buttonGroup:AddChild(cancelButton)
    
    dialog:AddChild(buttonGroup)
end

-- Show confirmation dialog for clearing all tasks
local function ShowConfirmClearDialog()
    local dialog = AceGUI:Create("Frame")
    dialog:SetTitle("Confirm Clear All")
    dialog:SetLayout("Flow")
    dialog:SetWidth(350)
    dialog:SetHeight(150)
    dialog:SetCallback("OnClose", function(widget)
        widget:Release()
    end)
    
    -- Enable keyboard input for dialog frame and handle ESC
    dialog.frame:EnableKeyboard(true)
    dialog.frame:SetScript("OnKeyDown", function(frame, key)
        if key == "ESCAPE" then
            debug("ESC pressed on clear dialog frame, closing dialog")
            dialog:Release()
        end
    end)
    
    -- Warning message
    local warningLabel = AceGUI:Create("Label")
    warningLabel:SetText("Are you sure you want to clear all tasks?\nThis action cannot be undone.")
    warningLabel:SetColor(1, 0.5, 0) -- Orange warning color
    dialog:AddChild(warningLabel)
    
    -- Buttons
    local buttonGroup = AceGUI:Create("InlineGroup")
    buttonGroup:SetLayout("Flow")
    
    local confirmButton = AceGUI:Create("Button")
    confirmButton:SetText("Clear All")
    confirmButton:SetWidth(100)
    confirmButton:SetCallback("OnClick", function()
        if TaskManager.clearAllTasks then
            TaskManager.clearAllTasks()
            -- Release the dialog first
            dialog:Release()
            -- Then refresh the board using the proper refresh method
            local mainAddon = _G.Kanban
            debug("Clear dialog - mainAddon: " .. tostring(mainAddon ~= nil))
            if mainAddon and mainAddon.RefreshMainWindow then
                debug("Clear dialog - using RefreshMainWindow for complete refresh")
                mainAddon:RefreshMainWindow()
                debug("Clear dialog - RefreshMainWindow call completed")
            else
                debug("Clear dialog - RefreshMainWindow not available")
            end
        else
            dialog:Release()
        end
    end)
    buttonGroup:AddChild(confirmButton)
    
    local cancelButton = AceGUI:Create("Button")
    cancelButton:SetText("Cancel")
    cancelButton:SetWidth(100)
    cancelButton:SetCallback("OnClick", function()
        dialog:Release()
    end)
    buttonGroup:AddChild(cancelButton)
    
    dialog:AddChild(buttonGroup)
end

-- Show confirmation dialog for deleting a specific task
local function ShowConfirmDeleteDialog(taskId)
    local task = TaskManager.getTaskById and TaskManager.getTaskById(taskId)
    if not task then
        debug("Task not found for deletion")
        return
    end
    
    local dialog = AceGUI:Create("Frame")
    dialog:SetTitle("Confirm Delete Task")
    dialog:SetLayout("Flow")
    dialog:SetWidth(400)
    dialog:SetHeight(150)
    dialog:SetCallback("OnClose", function(widget)
        widget:Release()
    end)
    
    -- Enable keyboard input for dialog frame and handle ESC
    dialog.frame:EnableKeyboard(true)
    dialog.frame:SetScript("OnKeyDown", function(frame, key)
        if key == "ESCAPE" then
            debug("ESC pressed on delete dialog frame, closing dialog")
            dialog:Release()
        end
    end)
    
    -- Warning message
    local warningLabel = AceGUI:Create("Label")
    warningLabel:SetText("Are you sure you want to delete this task?\n\nTitle: " .. task.title .. "\nThis action cannot be undone.")
    warningLabel:SetColor(1, 0.5, 0) -- Orange warning color
    dialog:AddChild(warningLabel)
    
    -- Buttons
    local buttonGroup = AceGUI:Create("InlineGroup")
    buttonGroup:SetLayout("Flow")
    
    local confirmButton = AceGUI:Create("Button")
    confirmButton:SetText("Delete Task")
    confirmButton:SetWidth(100)
    confirmButton:SetCallback("OnClick", function()
        if TaskManager.deleteTask then
            TaskManager.deleteTask(taskId)
            -- Release the dialog first
            dialog:Release()
            -- Then refresh the board using the proper refresh method
            local mainAddon = _G.Kanban
            if mainAddon and mainAddon.RefreshMainWindow then
                debug("Delete dialog - using RefreshMainWindow for complete refresh")
                mainAddon:RefreshMainWindow()
            else
                debug("Delete dialog - RefreshMainWindow not available")
            end
        else
            dialog:Release()
        end
    end)
    buttonGroup:AddChild(confirmButton)
    
    local cancelButton = AceGUI:Create("Button")
    cancelButton:SetText("Cancel")
    cancelButton:SetWidth(100)
    cancelButton:SetCallback("OnClick", function()
        dialog:Release()
    end)
    buttonGroup:AddChild(cancelButton)
    
    dialog:AddChild(buttonGroup)
end

-- Export dialogs
local Dialogs = {
    ShowAddTaskDialog = ShowAddTaskDialog,
    ShowEditTaskDialog = ShowEditTaskDialog,
    ShowConfirmClearDialog = ShowConfirmClearDialog,
    ShowConfirmDeleteDialog = ShowConfirmDeleteDialog
}

-- Make available globally
_G.Kanban_Dialogs = Dialogs

-- Attach to addon if available
if addon then
    addon.Dialogs = Dialogs
end

return Dialogs 