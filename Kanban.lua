-- Kanban Addon for WoW Classic Anniversary
-- A kanban-style to-do list addon

local addonName, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- Create the addon using AceAddon framework
local Kanban = AceAddon:NewAddon(addonName, "AceEvent-3.0")
addon = Kanban -- Make addon globally accessible

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
    
    -- Ensure GUI functions are attached
    if not self.GUI then
        self.GUI = {}
    end
    
    -- Force GUI functions to be attached if they exist in the global scope
    if _G.Kanban_GUI_Functions then
        debug("Attaching GUI functions from global scope")
        for name, func in pairs(_G.Kanban_GUI_Functions) do
            self.GUI[name] = func
        end
    end
    
    debug("Addon loaded. Type /kanban or /kb to open the window.")
end

-- Toggle the main window
function Kanban:ToggleWindow()
    debug("ToggleWindow called")
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

-- Create the main window using AceGUI
function Kanban:CreateMainWindow()
    debug("CreateMainWindow called")
    
    -- Create the main frame
    self.mainFrame = AceGUI:Create("Frame")
    self.mainFrame:SetTitle("Kanban - To-Do List")
    self.mainFrame:SetLayout("Flow")
    self.mainFrame:SetWidth(900)
    self.mainFrame:SetHeight(700)
    self.mainFrame:SetCallback("OnClose", function(widget)
        debug("Window close callback triggered")
        widget:Hide()
    end)
    
    debug("About to create kanban board")
    
    -- Add the kanban board with error handling
    local success, kanbanBoard = pcall(function()
        if self.GUI and self.GUI.CreateKanbanBoard then
            return self.GUI:CreateKanbanBoard(self.mainFrame)
        else
            debug("GUI.CreateKanbanBoard not found")
            return nil
        end
    end)
    
    if success and kanbanBoard then
        debug("Kanban board created successfully")
        self.mainFrame:AddChild(kanbanBoard)
        debug("Kanban board added to main frame")
    else
        debug("Failed to create kanban board")
        if not success then
            debug("Error: " .. tostring(kanbanBoard))
        end
        
        -- Add fallback content
        local fallbackLabel = AceGUI:Create("Label")
        fallbackLabel:SetText("Kanban board failed to load. Check for errors.")
        fallbackLabel:SetColor(1, 0, 0)
        self.mainFrame:AddChild(fallbackLabel)
        
        -- Add a simple test button
        local testButton = AceGUI:Create("Button")
        testButton:SetText("Test Button")
        testButton:SetWidth(120)
        testButton:SetCallback("OnClick", function()
            debug("Test button clicked!")
        end)
        self.mainFrame:AddChild(testButton)
    end
    
    debug("CreateMainWindow completed")
end 