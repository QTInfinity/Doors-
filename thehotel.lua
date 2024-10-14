
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
    Entities = {},
    Gold = {},
    Items = {},
    Guiding = {},
    Players = {},
    Hideables = {},
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
-- Function to clear ESP for a specific type
local function ClearESP(type)
    for object, highlight in pairs(ESPObjects[type]) do
        if highlight then
            highlight:Destroy()
        end
    end
    ESPObjects[type] = {} -- Clear the table
end
-- Function for Doors ESP
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
-- Function for Target ESP
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
-- Function for managing Entities (merged Entity and SideEntity)
local function ManageEntityESP()
    ClearESP("Entities")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, entity in ipairs(currentRoom:GetChildren()) do
            if entity:IsA("Model") and entity:FindFirstChild("PrimaryPart") then
                ESPObjects.Entities[entity] = ApplyESP(entity.PrimaryPart, Color3.fromRGB(255, 100, 100))
            end
        end
    end
end
-- Function for managing Gold ESP
local function ManageGoldESP()
    ClearESP("Gold")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, asset in ipairs(currentRoom:GetChildren()) do
            if asset.Name == "GoldPile" and asset:FindFirstChild("PrimaryPart") then
                ESPObjects.Gold[asset] = ApplyESP(asset.PrimaryPart, Color3.fromRGB(255, 215, 0))  -- Gold color
            end
        end
    end
end
-- Function for managing Items (merged Item and DroppedItem ESP)
local function ManageItemsESP()
    ClearESP("Items")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, item in ipairs(currentRoom:GetChildren()) do
            if item:GetAttribute("IsDropped") or item:GetAttribute("IsItem") and item:FindFirstChild("PrimaryPart") then
                ESPObjects.Items[item] = ApplyESP(item.PrimaryPart, Color3.fromRGB(0, 255, 100))
            end
        end
    end
end
-- Function for Guiding ESP
local function ManageGuidingESP()
    ClearESP("Guiding")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, guidance in ipairs(currentRoom:GetChildren()) do
            if guidance.Name == "GuidingLight" and guidance:FindFirstChild("PrimaryPart") then
                ESPObjects.Guiding[guidance] = ApplyESP(guidance.PrimaryPart, Color3.fromRGB(0, 255, 255))  -- Cyan color
            end
        end
    end
end
-- Function for managing Hideables (renamed from HidingSpot)
local function ManageHideablesESP()
    ClearESP("Hideables")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, asset in ipairs(currentRoom:GetChildren()) do
            if (asset.Name == "Wardrobe" or asset.Name == "Locker") and asset:FindFirstChild("PrimaryPart") then
                ESPObjects.Hideables[asset] = ApplyESP(asset.PrimaryPart, Color3.fromRGB(100, 100, 255))  -- Blue color
            end
        end
    end
end
-- Function for Player ESP
local function ManagePlayersESP()
    ClearESP("Players")
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("PrimaryPart") then
            ESPObjects.Players[player.Character] = ApplyESP(player.Character.PrimaryPart, Color3.fromRGB(255, 0, 0))  -- Red color
        end
    end
end
-- Adding toggles for various ESP types
local DoorToggle = VisualsTab:CreateToggle({
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
local EntityToggle = VisualsTab:CreateToggle({
    Name = "Entity ESP",
    CurrentValue = false,
    Flag = "EntityESP",
    Callback = function(state)
        if state then
            ManageEntityESP()
        else
            ClearESP("Entities")
        end
    end,
})
local GoldToggle = VisualsTab:CreateToggle({
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
local ItemsToggle = VisualsTab:CreateToggle({
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
local GuidingToggle = VisualsTab:CreateToggle({
    Name = "Guiding Light ESP",
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
local HideablesToggle = VisualsTab:CreateToggle({
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
local PlayersToggle = VisualsTab:CreateToggle({
    Name = "Players ESP",
    CurrentValue = false,
    Flag = "PlayersESP",
    Callback = function(state)
        if state then
            ManagePlayersESP()
        else
            ClearESP("Players")
        end
    end,
})
-- Event handler for room change
local function OnRoomChange()
    ManageEntityESP()
    ManageGoldESP()
    ManageItemsESP()
    ManageGuidingESP()
    ManageHideablesESP()
    ManagePlayersESP()
end
-- Monitor room changes
local function MonitorRoomChanges()
    OnRoomChange()
    local roomChangedConnection = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(OnRoomChange)
    table.insert(ESPObjects, roomChangedConnection)
end
MonitorRoomChanges()
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
