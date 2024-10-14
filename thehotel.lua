-- Service(s)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Centralized tables for connections and ESP objects
local Connections = {}
local ESPObjects = {
    Doors = {},
    Targets = {}, -- Target ESP storage
}

-- UI Library setup
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'ESP Menu',
    Center = true,
    AutoShow = true,
    Draggable = true
})

local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Config = Window:AddTab('Config'),
}

local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP Options')

-- Function to apply general ESP (used for doors and targets)
local function ApplyESP(object, color)
    local highlight = Instance.new("Highlight")
    highlight.Parent = object
    highlight.FillColor = color or Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.75
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    return highlight
end

-- Function to clear ESP
local function ClearESP(type)
    for object, highlight in pairs(ESPObjects[type]) do
        if highlight then
            highlight:Destroy()
        end
    end
    ESPObjects[type] = {} -- Clear the table
end

-- Function to manage door ESP
local function ManageDoorESP()
    ClearESP("Doors") -- Ensure previous ESP is cleared
    local currentRoomModel = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoomModel then
        for _, object in ipairs(currentRoomModel:GetChildren()) do
            if object.Name == "Door" then
                local door = object:FindFirstChild("Door")
                if door then
                    ESPObjects.Doors[object] = ApplyESP(door) -- Store the highlight
                end
            end
        end
    end
end

-- Function to manage target ESP for KeyObtain, LeverForGate, LiveHintBook, and others
local function ManageTargetESP()
    ClearESP("Targets") -- Ensure previous ESP is cleared
    local currentRoomModel = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoomModel then
        local assetsFolder = currentRoomModel:FindFirstChild("Assets")
        if assetsFolder then
            for _, object in ipairs(assetsFolder:GetChildren()) do
                if object.Name == "KeyObtain" then
                    ESPObjects.Targets[object] = ApplyESP(object, Color3.fromRGB(255, 0, 0)) -- Red highlight for KeyObtain
                elseif object.Name == "LeverForGate" then
                    ESPObjects.Targets[object] = ApplyESP(object, Color3.fromRGB(255, 255, 0)) -- Yellow highlight for Gate Lever
                elseif object.Name == "LiveHintBook" then
                    ESPObjects.Targets[object] = ApplyESP(object, Color3.fromRGB(0, 255, 255)) -- Cyan highlight for Hint Book
                elseif object.Name == "LiveBreakerPolePickup" then
                    ESPObjects.Targets[object] = ApplyESP(object, Color3.fromRGB(128, 0, 255)) -- Purple highlight for Breaker
                end
            end
        end
    end
end

-- Instant room change handling with no delay
local function OnRoomChange()
    ManageDoorESP()
    ManageTargetESP()
end

-- Detect room changes and apply ESP immediately without delay
local function MonitorRoomChanges()
    OnRoomChange() -- Apply ESP immediately on script load
    local roomChangedConnection = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(OnRoomChange)
    table.insert(Connections, roomChangedConnection)
end

MonitorRoomChanges()

-- UI Control for Door ESP Toggle
ESPGroup:AddToggle('DoorESP', {
    Text = 'Enable Door ESP',
    Default = true,
    Tooltip = 'Toggles Door ESP on or off',
    Callback = function(enabled)
        if enabled then
            ManageDoorESP()
        else
            ClearESP("Doors")
        end
    end
})

-- UI Control for Target ESP Toggle
ESPGroup:AddToggle('TargetESP', {
    Text = 'Enable Target ESP',
    Default = true,
    Tooltip = 'Toggles Target ESP on or off',
    Callback = function(enabled)
        if enabled then
            ManageTargetESP()
        else
            ClearESP("Targets")
        end
    end
})

-- Config Tab for Keybinding to toggle the UI itself
local ConfigGroup = Tabs.Config:AddLeftGroupbox('Config')
ConfigGroup:AddLabel('Keybind to Toggle UI')

-- Dynamic UI Toggle Fix
ConfigGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift', -- Default key to toggle UI
    NoUI = true, -- Hide the keybind from the keybind menu
    Text = 'Toggle UI Keybind',
    Mode = 'Toggle', -- Modes: Always, Toggle, Hold
    Callback = function(Value)
        -- Properly toggling UI visibility using ToggleKeybind reference
        Library.ToggleKeybind = Value
        Library:ToggleUI()
    end
})

-- Ensure the ToggleUI function behaves correctly
Library.ToggleUI = function()
    Window.Visible = not Window.Visible
end

-- Additional UI Settings (Themes, Saves)
local MenuGroup = Tabs.Config:AddLeftGroupbox('UI Settings')
MenuGroup:AddButton('Unload', function() Library:Unload() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Config)
ThemeManager:ApplyToTab(Tabs.Config)
