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
    Entity = {}, -- Merged Entity and SideEntity here
    Chests = {},
    Gold = {},
    Guiding = {},
    Items = {}, -- Merged Item and DroppedItem here
    Players = {}, -- Renamed Player to Players
    Hideables = {}, -- Renamed HidingSpot to Hideables
}

-- Function to apply general ESP (used for doors, entity, etc.)
local function ApplyESP(object, color)
    local highlight = Instance.new("Highlight")
    highlight.Parent = object
    highlight.FillColor = color or Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.75
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    return highlight
end

-- Function to clear ESP for a specific type (Doors, Entity, etc.)
local function ClearESP(type)
    for object, highlight in pairs(ESPObjects[type]) do
        if highlight then
            highlight:Destroy()
        end
    end
    ESPObjects[type] = {} -- Clear the table
end

-- Functions for managing ESP for each object type
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

local function ManageEntityESP()
    ClearESP("Entity")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, object in ipairs(currentRoom:GetChildren()) do
            -- Combine checks for both Entity and SideEntity here
            if object.Name == "Entity" or object.Name == "SideEntity" then
                ESPObjects.Entity[object] = ApplyESP(object, Color3.fromRGB(255, 100, 0))
            end
        end
    end
end

local function ManageGoldESP()
    ClearESP("Gold")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, gold in ipairs(currentRoom:GetDescendants()) do
            if gold.Name == "GoldPile" then
                ESPObjects.Gold[gold] = ApplyESP(gold, Color3.fromRGB(255, 215, 0))
            end
        end
    end
end

local function ManageGuidingESP()
    ClearESP("Guiding")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, guiding in ipairs(currentRoom:GetDescendants()) do
            if guiding.Name == "GuidingLight" then
                ESPObjects.Guiding[guiding] = ApplyESP(guiding, Color3.fromRGB(0, 255, 255))
            end
        end
    end
end

local function ManageItemsESP()
    ClearESP("Items")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, item in ipairs(currentRoom:GetDescendants()) do
            -- Merged Item and DroppedItem checks here
            if item.Name == "Item" or item.Name == "DroppedItem" then
                ESPObjects.Items[item] = ApplyESP(item, Color3.fromRGB(0, 255, 100))
            end
        end
    end
end

local function ManagePlayerESP()
    ClearESP("Players")
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                ESPObjects.Players[player] = ApplyESP(character, Color3.fromRGB(0, 255, 255))
            end
        end
    end
end

local function ManageHideablesESP()
    ClearESP("Hideables")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, hidingSpot in ipairs(currentRoom:GetChildren()) do
            if hidingSpot:GetAttribute("HidingSpot") then
                ESPObjects.Hideables[hidingSpot] = ApplyESP(hidingSpot, Color3.fromRGB(255, 255, 255))
            end
        end
    end
end

-- Event handler for room change, instant application of ESP
local function OnRoomChange()
    ManageDoorESP()
    ManageEntityESP()
    ManageGoldESP()
    ManageGuidingESP()
    ManageItemsESP()
    ManagePlayerESP()
    ManageHideablesESP()
end

-- Detect room changes and apply ESP instantly without delay
local function MonitorRoomChanges()
    OnRoomChange()
    LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(OnRoomChange)
end
MonitorRoomChanges()

-- Adding toggles for the new ESP types
VisualsTab:CreateToggle({
    Name = "Door ESP",
    CurrentValue = false,
    Flag = "DoorESP",
    Callback = function(state)
        if state then
            ManageDoorESP()
        else
            ClearESP("Doors")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Entity ESP",
    CurrentValue = false,
    Flag = "EntityESP",
    Callback = function(state)
        if state then
            ManageEntityESP()
        else
            ClearESP("Entity")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Gold ESP",
    CurrentValue = false,
    Flag = "GoldESP",
    Callback = function(state)
        if state then
            ManageGoldESP()
        else
            ClearESP("Gold")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Guiding ESP",
    CurrentValue = false,
    Flag = "GuidingESP",
    Callback = function(state)
        if state then
            ManageGuidingESP()
        else
            ClearESP("Guiding")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Items ESP",
    CurrentValue = false,
    Flag = "ItemsESP",
    Callback = function(state)
        if state then
            ManageItemsESP()
        else
            ClearESP("Items")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Players ESP",
    CurrentValue = false,
    Flag = "PlayersESP",
    Callback = function(state)
        if state then
            ManagePlayerESP()
        else
            ClearESP("Players")
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Hideables ESP",
    CurrentValue = false,
    Flag = "HideablesESP",
    Callback = function(state)
        if state then
            ManageHideablesESP()
        else
            ClearESP("Hideables")
        end
    end,
})

-- Remove Keybind Section (as requested)
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
    Image = 4483362458,
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
