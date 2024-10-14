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
        FolderName = "MyGameESP",
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
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local ConfigTab = Window:CreateTab("Config", 4483362458)

-- Creating sections for ESP Options and Configurations
local ESPSection = VisualsTab:CreateSection("ESP Options")
local ConfigSection = ConfigTab:CreateSection("Config")

-- Default services and player setup
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Centralized tables for ESP objects
local GeneralTable = {
    ESPStorage = {
        Doors = {},
        Entity = {},
        Chests = {},
        Gold = {},
        Guiding = {},
        Targets = {},
        Items = {},
        Players = {},
        Hideables = {}
    },
    ESPNames = {
        DoorsName = { "Door.Door" },  -- Updated to the correct model path for Door
        EntityName = { "RushMoving", "AmbushMoving", "BackdoorRush", "Eyes" },
        ChestName = { "Chest", "Toolshed_Small", "ChestBoxLocked" },
        GoldName = { "GoldPile" },
        GuidingName = { "GuidingLight" },
        TargetsName = { "KeyObtain", "LeverForGate", "LiveHintBook" },
        ItemsName = { "Crucifix" },
        PlayersName = {},
        HideablesName = { "Wardrobe", "Bed" }
    }
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

-- Function to clear ESP for a specific type
local function ClearESP(type)
    for object, highlight in pairs(GeneralTable.ESPStorage[type]) do
        if highlight then
            highlight:Destroy()
        end
    end
    GeneralTable.ESPStorage[type] = {} -- Clear the table
end

-- General ESP management function
local function ManageESPByType(type, nameTable, color, filterFunction)
    ClearESP(type)
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, object in ipairs(currentRoom:GetDescendants()) do
            for _, name in ipairs(GeneralTable.ESPNames[nameTable]) do
                -- If a filter function is provided, use it
                if object.Name == name and (not filterFunction or filterFunction(object)) then
                    GeneralTable.ESPStorage[type][object] = ApplyESP(object, color)
                end
            end
        end
    end
end

-- Specific ESP managers
local function ManageDoorESP()
    ManageESPByType("Doors", "DoorsName", Color3.fromRGB(0, 255, 0))
end

local function ManageEntityESP()
    ClearESP("Entity")
    -- First check in the player's current room
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, object in ipairs(currentRoom:GetDescendants()) do
            for _, name in ipairs(GeneralTable.ESPNames.EntityName) do
                if object.Name == name then
                    GeneralTable.ESPStorage.Entity[object] = ApplyESP(object, Color3.fromRGB(255, 100, 0))
                end
            end
        end
    end
    -- Then check globally in the workspace (for entities like RushMoving)
    for _, object in ipairs(Workspace:GetDescendants()) do
        for _, name in ipairs(GeneralTable.ESPNames.EntityName) do
            if object.Name == name then
                GeneralTable.ESPStorage.Entity[object] = ApplyESP(object, Color3.fromRGB(255, 0, 0))
            end
        end
    end
end

-- Function for Chest ESP (includes locked chests)
local function ManageChestESP()
    ClearESP("Chests")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        for _, chest in ipairs(currentRoom:GetDescendants()) do
            if chest:GetAttribute("Storage") == "ChestBox" or chest.Name == "Toolshed_Small" or chest.Name == "ChestBoxLocked" then
                GeneralTable.ESPStorage.Chests[chest] = ApplyESP(chest, Color3.fromRGB(0, 255, 100))
            end
        end
    end
end

local function ManageGoldESP()
    ManageESPByType("Gold", "GoldName", Color3.fromRGB(255, 215, 0))
end

local function ManageGuidingESP()
    ManageESPByType("Guiding", "GuidingName", Color3.fromRGB(0, 255, 255))
end

local function ManageTargetsESP()
    ManageESPByType("Targets", "TargetsName", Color3.fromRGB(255, 0, 100))
end

local function ManageItemsESP()
    ManageESPByType("Items", "ItemsName", Color3.fromRGB(0, 255, 100), function(item)
        return item:IsA("Model") and (item:GetAttribute("Pickup") or item:GetAttribute("PropType")) and not item:GetAttribute("FuseID")
    end)
end

local function ManagePlayerESP()
    ClearESP("Players")
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                GeneralTable.ESPStorage.Players[player] = ApplyESP(character, Color3.fromRGB(0, 255, 255))
            end
        end
    end
end

local function ManageHideablesESP()
    ManageESPByType("Hideables", "HideablesName", Color3.fromRGB(255, 255, 255))
end

-- Function to preload the next room's ESP to make loading quicker
local function PreloadNextRoomESP()
    local currentRoomIndex = LocalPlayer:GetAttribute("CurrentRoom")
    local nextRoomIndex = tostring(tonumber(currentRoomIndex) + 1)
    local nextRoom = Workspace.CurrentRooms[nextRoomIndex]
    
    if nextRoom then
        -- Preload ESP for the next room
        for _, object in ipairs(nextRoom:GetDescendants()) do
            -- Preload for Doors, Entities, etc.
            ManageESPByType("Doors", "DoorsName", Color3.fromRGB(0, 255, 0))
            ManageESPByType("Entity", "EntityName", Color3.fromRGB(255, 0, 0))
            ManageESPByType("Chests", "ChestName", Color3.fromRGB(0, 255, 100))
        end
    end
end

-- Event handler for room change, instant application of ESP
local function OnRoomChange()
    ManageDoorESP()
    ManageEntityESP()
    ManageGoldESP()
    ManageChestESP()
    ManageGuidingESP()
    ManageTargetsESP()
    ManageItemsESP()
    ManagePlayerESP()
    ManageHideablesESP()
    PreloadNextRoomESP()  -- Preload the next room's ESP
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
    Name = "Chest ESP",  -- Re-added Chest ESP
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
    Name = "Targets ESP",
    CurrentValue = false,
    Flag = "TargetsESP",
    Callback = function(state)
        if state then
            ManageTargetsESP()
        else
            ClearESP("Targets")
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

-- Fixed the Button creation method to prevent the UI error
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
