-- Importing the Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Optional: Enabling secure mode for detection reduction (uncomment if needed)
-- getgenv().SecureMode = true

-- Creating the main window with configuration saving enabled
local Window = Rayfield:CreateWindow({
    Name = "ESP Menu",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyGameESP", -- Custom folder for configuration
        FileName = "ESPConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Creating tabs for UI
local VisualsTab = Window:CreateTab("Visuals", 4483362458) -- Use any relevant image ID
local ConfigTab = Window:CreateTab("Config", 4483362458)

-- Creating sections for ESP Options and Configurations
local ESPSection = VisualsTab:CreateSection("ESP Options")
local ConfigSection = ConfigTab:CreateSection("Config")

-- Default services and player setup
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Centralized tables for ESP objects
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

-- Functions for managing ESP
local function ManageDoorESP()
    ClearESP("Doors")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, object in ipairs(currentRoom:GetChildren()) do
            if object.Name == "Door" and object:FindFirstChild("Door") then
                ESPObjects.Doors[object] = ApplyESP(object.Door)
            end
        end
    end
end

local function ManageTargetESP()
    ClearESP("Targets")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        local assetsFolder = currentRoom:FindFirstChild("Assets")
        if assetsFolder then
            for _, object in ipairs(assetsFolder:GetChildren()) do
                local color = nil
                if object.Name == "KeyObtain" then
                    color = Color3.fromRGB(255, 0, 0)
                elseif object.Name == "LeverForGate" then
                    color = Color3.fromRGB(255, 255, 0)
                elseif object.Name == "LiveHintBook" then
                    color = Color3.fromRGB(0, 255, 255)
                elseif object.Name == "LiveBreakerPolePickup" then
                    color = Color3.fromRGB(128, 0, 255)
                end
                if color then
                    ESPObjects.Targets[object] = ApplyESP(object, color)
                end
            end
        end
    end
end

local function ManageChestESP()
    ClearESP("Chests")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, chest in ipairs(currentRoom:GetDescendants()) do
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
    table.insert(ESPObjects, roomChangedConnection)
end

MonitorRoomChanges()

-- Adding toggles for Door ESP, Target ESP, and Chest ESP
local DoorToggle = VisualsTab:CreateToggle({
    Name = "Door ESP",
    CurrentValue = false,
    Flag = "DoorESP", -- Unique identifier for saving
    Callback = function(state)
        if state then
            ManageDoorESP()
        else
            ClearESP("Doors")
        end
    end,
})

local TargetToggle = VisualsTab:CreateToggle({
    Name = "Target ESP",
    CurrentValue = false,
    Flag = "TargetESP",
    Callback = function(state)
        if state then
            ManageTargetESP()
        else
            ClearESP("Targets")
        end
    end,
})

local ChestToggle = VisualsTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(state)
        if state then
            ManageChestESP()
        else
            ClearESP("Chests")
        end
    end,
})

-- Keybind to toggle UI visibility
ConfigSection:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightShift",
    Flag = "ToggleUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- Button to unload the script
ConfigSection:CreateButton({
    Name = "Unload",
    Callback = function()
        Rayfield:Destroy()
        print("ESP Menu Unloaded")
    end,
})

-- Notify the user
Rayfield:Notify({
    Title = "ESP Loaded",
    Content = "The ESP system is now active.",
    Duration = 6.5,
    Image = 4483362458, -- Replace with a relevant image ID
    Actions = {
        Ignore = {
            Name = "Okay",
            Callback = function()
                print("The user tapped Okay!")
            end
        },
    },
})

-- Load the configuration if saved
Rayfield:LoadConfiguration()
