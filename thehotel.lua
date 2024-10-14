-- Importing necessary libraries
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Creating the main window
local Window = Library:CreateWindow({
    Title = 'ESP Menu',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Creating tabs for UI
local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Config = Window:AddTab('Config'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Group for ESP settings
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP Options')

-- Group for Config settings and UI keybinding
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- Default services and player setup
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Centralized tables for connections and ESP objects
local Connections = {}
local ESPObjects = {
    Doors = {},
    Targets = {},
    Chests = {},
}

-- Function to apply general ESP (used for doors, targets, and chests)
local function ApplyESP(object, color)
    local highlight = Instance.new("Highlight")
    highlight.Parent = object
    highlight.FillColor = color or Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.75
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    return highlight
end

-- Function to clear ESP for a specific type (Doors, Targets, Chests)
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
    ClearESP("Doors")
    local currentRoomModel = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoomModel then
        for _, object in ipairs(currentRoomModel:GetChildren()) do
            if object.Name == "Door" then
                local door = object:FindFirstChild("Door")
                if door then
                    ESPObjects.Doors[object] = ApplyESP(door)
                end
            end
        end
    end
end

-- Function to manage target ESP (e.g., KeyObtain, LeverForGate)
local function ManageTargetESP()
    ClearESP("Targets")
    local currentRoomModel = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoomModel then
        local assetsFolder = currentRoomModel:FindFirstChild("Assets")
        if assetsFolder then
            for _, object in ipairs(assetsFolder:GetChildren()) do
                if object.Name == "KeyObtain" then
                    ESPObjects.Targets[object] = ApplyESP(object, Color3.fromRGB(255, 0, 0))
                elseif object.Name == "LeverForGate" then
                    ESPObjects.Targets[object] = ApplyESP(object, Color3.fromRGB(255, 255, 0))
                elseif object.Name == "LiveHintBook" then
                    ESPObjects.Targets[object] = ApplyESP(object, Color3.fromRGB(0, 255, 255))
                elseif object.Name == "LiveBreakerPolePickup" then
                    ESPObjects.Targets[object] = ApplyESP(object, Color3.fromRGB(128, 0, 255))
                end
            end
        end
    end
end

-- Function to manage chest ESP
local function ManageChestESP()
    ClearESP("Chests")
    local currentRoomModel = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoomModel then
        for _, chest in ipairs(currentRoomModel:GetDescendants()) do
            if chest:GetAttribute("Storage") == "ChestBox" or chest.Name == "Toolshed_Small" then
                ESPObjects.Chests[chest] = ApplyESP(chest, Color3.fromRGB(0, 255, 100))
            end
        end
    end
end

-- Event handler for room change, instant application of ESP
local function OnRoomChange()
    ManageDoorESP()
    ManageTargetESP()
    ManageChestESP()
end

-- Detect room changes and apply ESP instantly without delay
local function MonitorRoomChanges()
    OnRoomChange()
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

-- UI Control for Chest ESP Toggle
ESPGroup:AddToggle('ChestESP', {
    Text = 'Enable Chest ESP',
    Default = true,
    Tooltip = 'Toggles Chest ESP on or off',
    Callback = function(enabled)
        if enabled then
            ManageChestESP()
        else
            ClearESP("Chests")
        end
    end
})

-- Setting up keybinding for toggling the UI visibility
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift', -- Default key to toggle UI
    NoUI = true, -- Hide the keybind from the keybind menu
    Text = 'Toggle UI Keybind'
})

-- Store the keybind value in a variable for easier access
local menuToggleKey = Enum.KeyCode.RightShift -- Default value
Options.MenuKeybind:OnChanged(function(value)
    menuToggleKey = Enum.KeyCode[value] or Enum.KeyCode.RightShift
end)

-- Function to toggle the visibility of the UI
local function ToggleUIVisibility()
    Window:SetVisible(not Window.Visible)
end

-- Listen for input to toggle the UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == menuToggleKey then
        ToggleUIVisibility()
    end
end)

-- Addons for saving and managing themes
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
