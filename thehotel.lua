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
        DoorsName = { "Door" },  -- Updated Door model path
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

-- Door ESP based on the provided logic
local function ManageDoorESP()
    ClearESP("Doors")
    local currentRoom = Workspace.CurrentRooms[tostring(LocalPlayer:GetAttribute("CurrentRoom"))]
    if currentRoom then
        local door = currentRoom:FindFirstChild("Door")
        if door then
            local doorModel = door:WaitForChild("Door")
            local doorNumber = tonumber(currentRoom.Name) + 1
            local opened = door:GetAttribute("Opened")
            local locked = currentRoom:GetAttribute("RequiresKey")
            local doorState = opened and "[Opened]" or (locked and "[Locked]" or "")
            local doorIdx = door.Name .. tostring(doorNumber)

            local doorEsp = ApplyESP(doorModel, Color3.fromRGB(0, 255, 0))
            doorEsp.Adornee = doorModel

            local connection
            connection = door:GetAttributeChangedSignal("Opened"):Connect(function()
                if door:GetAttribute("Opened") then
                    doorEsp.Adornee.Text = string.format("Door %s [Opened]", doorNumber)
                    connection:Disconnect()
                end
            end)
        end
    end
end

-- Specific ESP managers
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

-- Other ESP functions (Chest, Gold, Guiding, Targets, Items, etc.) are unchanged

-- Event handler for room change, instant application of ESP
local function OnRoomChange()
    ManageDoorESP()
    ManageEntityESP()
    -- Other ESP functions
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

-- Fixing the CreateButton error
-- Ensure the method is correctly implemented for button creation
if ConfigSection.CreateButton then
    ConfigSection:CreateButton({
        Name = "Unload",
        Callback = function()
            Rayfield:Destroy()
            print("ESP Menu Unloaded")
        end,
    })
else
    warn("CreateButton method missing in ConfigSection.")
end

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
