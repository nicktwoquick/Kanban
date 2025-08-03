-- Kanban Addon for WoW Classic Anniversary
-- A kanban-style to-do list addon

local addonName, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- Create the addon using AceAddon framework
local Kanban = AceAddon:NewAddon(addonName, "AceEvent-3.0")
addon = Kanban -- Make addon globally accessible
_G.Kanban = Kanban -- Make addon globally accessible for modules

-- Modules will be loaded by the TOC file in order
-- They will be available as global tables: _G.Kanban_Utils, _G.Kanban_TaskManager, etc.

-- Debug function
local function debug(message)
    print("|cFF00FF00Kanban|r: " .. message)
end

-- Addon initialization
function Kanban:OnInitialize()
    -- Create slash command
    SLASH_KANBAN1 = "/kanban"
    SLASH_KANBAN2 = "/kb"
    SlashCmdList["KANBAN"] = function(msg)
        Kanban:ToggleWindow()
    end
    
    -- Attach modules to the addon
    self.Utils = _G.Kanban_Utils
    self.TaskManager = _G.Kanban_TaskManager
    self.UIComponents = _G.Kanban_UIComponents
    self.Dialogs = _G.Kanban_Dialogs
    self.Board = _G.Kanban_Board
    
    debug("Addon loaded. Type /kanban or /kb to open the window.")
    debug("Global Kanban reference set: " .. tostring(_G.Kanban ~= nil))
end

-- Toggle the main window
function Kanban:ToggleWindow()
    debug("ToggleWindow called")
    
    -- Defensive check: ensure we only have one window
    if self.mainFrame and not self.mainFrame:IsValid() then
        debug("Main frame is invalid, clearing reference")
        self.mainFrame = nil
    end
    
    if not self.mainFrame then
        debug("Creating new window")
        self:CreateMainWindow()
        -- Ensure the window is shown after creation
        if self.mainFrame then
            debug("Showing newly created window")
            self.mainFrame:Show()
        end
    else
        if self.mainFrame:IsShown() then
            debug("Hiding existing window")
            self.mainFrame:Hide()
        else
            debug("Showing existing window")
            self.mainFrame:Show()
        end
    end
end

-- Refresh the main window (recreates the window content)
function Kanban:RefreshMainWindow()
    debug("RefreshMainWindow called")
    
    -- Defensive check: ensure the frame is valid before trying to refresh
    if self.mainFrame and not self.mainFrame:IsValid() then
        debug("Main frame is invalid, clearing reference")
        self.mainFrame = nil
    end
    
    if self.mainFrame then
        debug("Main frame exists, forcing complete refresh")
        -- Store current window position and visibility
        local wasShown = self.mainFrame:IsShown()
        
        -- Force a complete cleanup
        self.mainFrame:Release()
        self.mainFrame = nil
        
        -- Create a new window immediately
        self:CreateMainWindow()
        
        -- Show the window if it was previously shown
        if self.mainFrame and wasShown then
            self.mainFrame:Show()
        end
        
        -- Force a UI update
        if self.mainFrame then
            self.mainFrame:DoLayout()
        end
    else
        debug("No main frame exists, creating new window")
        -- Create new window if none exists
        self:CreateMainWindow()
        if self.mainFrame then
            self.mainFrame:Show()
        end
    end
end

-- Refresh just the components without recreating the entire window
function Kanban:RefreshComponents()
    debug("RefreshComponents called")
    
    if not self.mainFrame then
        debug("No main frame to refresh components")
        return
    end
    
    -- Get all children of the main frame
    local children = {}
    for i = 1, self.mainFrame:GetNumChildren() do
        local child = self.mainFrame:GetChild(i)
        if child then
            table.insert(children, child)
        end
    end
    
    debug("Found " .. #children .. " children to refresh")
    
    -- Remove all children except the first one (CRUD button row)
    for i = #children, 2, -1 do
        debug("Removing child " .. i)
        self.mainFrame:RemoveChild(children[i])
        children[i]:Release()
    end
    
    -- Recreate the kanban board
    debug("Recreating kanban board")
    local boardContainer = AceGUI:Create("InlineGroup")
    boardContainer:SetLayout("Flow")
    boardContainer:SetWidth(880)
    -- Set a specific height for the board container to ensure proper sizing
    -- Window (700) - Window padding (57) - CRUD row (60) = 583px available
    boardContainer:SetHeight(583)
    
    -- Add the kanban board with error handling
    local success, kanbanBoard = pcall(function()
        if self.Board and self.Board.CreateKanbanBoard then
            return self.Board:CreateKanbanBoard(self.mainFrame)
        else
            debug("Board.CreateKanbanBoard not found")
            return nil
        end
    end)
    
    if success and kanbanBoard then
        debug("Kanban board recreated successfully")
        boardContainer:AddChild(kanbanBoard)
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
    
    -- Add the board container to the main frame
    self.mainFrame:AddChild(boardContainer)
    
    -- Task dropdown refresh removed - no longer needed
    
    debug("RefreshComponents completed")
end

-- Create the main window using AceGUI
function Kanban:CreateMainWindow()
    debug("CreateMainWindow called")
    
    -- Defensive check: if a main frame already exists, release it first
    if self.mainFrame then
        debug("Main frame already exists, releasing it first")
        self.mainFrame:Release()
        self.mainFrame = nil
    end
    
    -- Create the main frame
    self.mainFrame = AceGUI:Create("Frame")
    
    -- Initialize refresh counter if it doesn't exist
    if not self.refreshCount then
        self.refreshCount = 0
    end
    self.refreshCount = self.refreshCount + 1
    
    self.mainFrame:SetTitle("Kanban - To-Do List (Refresh #" .. self.refreshCount .. " at " .. date("%H:%M:%S") .. ")")
    self.mainFrame:SetLayout("List") -- Changed from Flow to List for top alignment
    self.mainFrame:SetWidth(900)
    self.mainFrame:SetHeight(700)
    
    -- Disable resizing to make the window static size
    self.mainFrame:EnableResize(false)
    
    -- Set up close callback
    self.mainFrame:SetCallback("OnClose", function(widget)
        debug("Window close callback triggered")
        -- Clear the reference so the window can be recreated
        self.mainFrame = nil
        widget:Release()
    end)
    
    -- Set up ESC key handling
    self.mainFrame.frame:SetScript("OnKeyDown", function(frame, key)
        if key == "ESCAPE" then
            debug("ESC key pressed, closing window")
            self.mainFrame:Hide()
            self.mainFrame = nil
            frame:Release()
        end
    end)
    
    -- Enable keyboard input for the frame
    self.mainFrame.frame:EnableKeyboard(true)
    
    debug("About to create button row")
    
    -- Create button row that spans the full width
    local buttonGroup = AceGUI:Create("InlineGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetWidth(880) -- Full width minus some padding
    buttonGroup:SetHeight(60) -- Increased height for better spacing
    
    -- Add Task button
    local addButton = AceGUI:Create("Button")
    addButton:SetText("+ Add Task")
    addButton:SetWidth(120)
    addButton:SetCallback("OnClick", function()
        if self.Dialogs and self.Dialogs.ShowAddTaskDialog then
            self.Dialogs:ShowAddTaskDialog()
        end
    end)
    buttonGroup:AddChild(addButton)
    
    local refreshButton = AceGUI:Create("Button")
    refreshButton:SetText("Refresh")
    refreshButton:SetWidth(120)
    refreshButton:SetCallback("OnClick", function()
        debug("Refresh button clicked")
        
        -- Use the new lightweight board refresh
        if self.Board and self.Board.RefreshBoard then
            debug("Using Board.RefreshBoard for lightweight refresh")
            self.Board:RefreshBoard()
        else
            debug("Board.RefreshBoard not available, falling back to RefreshMainWindow")
            self:RefreshMainWindow()
        end
        
        debug("Refresh button completed")
    end)
    buttonGroup:AddChild(refreshButton)
    
    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All")
    clearButton:SetWidth(120)
    clearButton:SetCallback("OnClick", function()
        if self.Dialogs and self.Dialogs.ShowConfirmClearDialog then
            self.Dialogs:ShowConfirmClearDialog()
        end
    end)
    buttonGroup:AddChild(clearButton)
    
    -- Add a test button to manually move the sample task
    local testMoveButton = AceGUI:Create("Button")
    testMoveButton:SetText("Test Move")
    testMoveButton:SetWidth(120)
    testMoveButton:SetCallback("OnClick", function()
        debug("Test move button clicked")
        if self.TaskManager and self.TaskManager.moveTask then
            local success = self.TaskManager.moveTask(1, "In Progress")
            debug("Test move result: " .. tostring(success))
            if success then
                -- Use the new lightweight board refresh
                if self.Board and self.Board.RefreshBoard then
                    debug("Using Board.RefreshBoard after test move")
                    self.Board:RefreshBoard()
                else
                    debug("Board.RefreshBoard not available, falling back to RefreshMainWindow")
                    self:RefreshMainWindow()
                end
            end
        end
    end)
    buttonGroup:AddChild(testMoveButton)
    
    -- Add the button row to the main frame
    self.mainFrame:AddChild(buttonGroup)
    
    debug("About to create kanban board")
    
    -- Create the kanban board container with Flow layout for horizontal columns
    local boardContainer = AceGUI:Create("InlineGroup")
    boardContainer:SetLayout("Fill") -- This is a REQUIREMENT if children will use auto size
    boardContainer:SetWidth(880)
    -- Set a specific height for the board container to ensure proper sizing
    -- Window (700) - Window padding (57) - Button row (60) = 583px available
    boardContainer:SetHeight(583)
    
    -- Add the kanban board with error handling
    local success, kanbanBoard = pcall(function()
        if self.Board and self.Board.CreateKanbanBoard then
            return self.Board:CreateKanbanBoard(self.mainFrame)
        else
            debug("Board.CreateKanbanBoard not found")
            return nil
        end
    end)
    
    if success and kanbanBoard then
        debug("Kanban board created successfully")
        boardContainer:AddChild(kanbanBoard)
        debug("Kanban board added to container")
    else
        debug("Failed to create kanban board")
        if not success then
            debug("Error: " .. tostring(kanbanBoard))
        end
        
        -- Add fallback content
        local fallbackLabel = AceGUI:Create("Label")
        fallbackLabel:SetText("Kanban board failed to load. Check for errors.")
        fallbackLabel:SetColor(1, 0, 0)
        boardContainer:AddChild(fallbackLabel)
        
        -- Add a simple test button
        local testButton = AceGUI:Create("Button")
        testButton:SetText("Test Button")
        testButton:SetWidth(120)
        testButton:SetCallback("OnClick", function()
            debug("Test button clicked!")
        end)
        boardContainer:AddChild(testButton)
    end
    
    -- Add the board container to the main frame
    self.mainFrame:AddChild(boardContainer)
    
    debug("CreateMainWindow completed")
end 