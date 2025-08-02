-- Kanban Addon for WoW Classic Anniversary
-- A kanban-style to-do list addon

local addonName, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- Create the addon using AceAddon framework
local Kanban = AceAddon:NewAddon(addonName, "AceEvent-3.0")
addon = Kanban -- Make addon globally accessible

-- Addon initialization
function Kanban:OnInitialize()
    -- Create slash command
    SLASH_KANBAN1 = "/kanban"
    SLASH_KANBAN2 = "/kb"
    SlashCmdList["KANBAN"] = function(msg)
        Kanban:ToggleWindow()
    end
    
    print("|cFF00FF00Kanban|r: Addon loaded. Type /kanban or /kb to open the window.")
end

-- Toggle the main window
function Kanban:ToggleWindow()
    if not self.mainFrame then
        self:CreateMainWindow()
    end
    
    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
    else
        self.mainFrame:Show()
    end
end

-- Create the main window using AceGUI
function Kanban:CreateMainWindow()
    -- Create the main frame
    self.mainFrame = AceGUI:Create("Frame")
    self.mainFrame:SetTitle("Kanban - To-Do List")
    self.mainFrame:SetLayout("Flow")
    self.mainFrame:SetWidth(800)
    self.mainFrame:SetHeight(600)
    self.mainFrame:SetCallback("OnClose", function(widget)
        widget:Hide()
    end)
    
    -- Add a simple text to show the window is working
    local testLabel = AceGUI:Create("Label")
    testLabel:SetText("Kanban window is working!\n\nThis is where the kanban board will go.")
    testLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)
    testLabel:SetColor(1, 1, 1)
    self.mainFrame:AddChild(testLabel)
    
    -- Add a test button to show AceGUI is working
    local testButton = AceGUI:Create("Button")
    testButton:SetText("Test Button")
    testButton:SetWidth(120)
    testButton:SetCallback("OnClick", function()
        print("|cFF00FF00Kanban|r: Test button clicked!")
    end)
    self.mainFrame:AddChild(testButton)
end 