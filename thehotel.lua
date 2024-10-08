-- Global check to prevent multiple executions
if getgenv().SeerGG_Doors_TheHotel then
    return
end
getgenv().SeerGG_Doors_TheHotel = true

-- Load Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Seer.GG/Doors ESP",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Seer.GG/Doors/TheHotel"
})

-- Tabs and Sections
local MainTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local ConfigTab = Window:MakeTab({Name = "Config", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- Store ESP Data and Colors
local GeneralTable = {
    ESP = {
        DoorESP = {},
        TargetESP = {},
        ChestESP = {},
        EntityESP = {},
        GuidingLightESP = {},
        GoldESP = {},
        ItemESP = {},
        HandheldItemESP = {},
        PlayerESP = {}
    },
    ESPColors = {
        DoorESP = Color3.fromRGB(255, 0, 0),
        TargetESP = Color3.fromRGB(0, 255, 0),
        ChestESP = Color3.fromRGB(255, 255, 0),
        EntityESP = Color3.fromRGB(255, 0, 255),
        GuidingLightESP = Color3.fromRGB(0, 150, 255),
        GoldESP = Color3.fromRGB(255, 215, 0),
        ItemESP = Color3.fromRGB(0, 0, 255),
        HandheldItemESP = Color3.fromRGB(255, 127, 0),
        PlayerESP = Color3.fromRGB(255, 255, 255)
    },
    RoomHistory = {},
    ToggleStates = {
        DoorESP = false,
        TargetESP = false,
        ChestESP = false,
        EntityESP = false,
        GuidingLightESP = false,
        GoldESP = false,
        ItemESP = false,
        HandheldItemESP = false,
        PlayerESP = false
    }
}

-- Function to create and update Highlight ESP
local function CreateHighlightESP(object, fillColor)
    local highlight = object:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
    highlight.Adornee = object
    highlight.FillColor = fillColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0.3
    highlight.Parent = object
    return highlight
end

-- Update all ESPs of a specific type with a new color
local function UpdateESPColors(espType, color)
    for _, highlight in pairs(GeneralTable.ESP[espType]) do
        if highlight and highlight.Adornee then
            highlight.FillColor = color
        end
    end
end

-- Cleanup old rooms' ESPs
local function CleanupOldRooms()
    local currentRoomIndex = tonumber(game:GetService("ReplicatedStorage").GameData.LatestRoom.Value)
    for roomIndex, objects in pairs(GeneralTable.RoomHistory) do
        if tonumber(roomIndex) < currentRoomIndex - 2 then
            for _, obj in pairs(objects) do
                local highlight = obj:FindFirstChildOfClass("Highlight")
                if highlight then highlight:Destroy() end
            end
            GeneralTable.RoomHistory[roomIndex] = nil
        end
    end
end

-- General function for applying ESP
local function ApplyESPForType(espType, getObjectsFunc, color)
    if not GeneralTable.ToggleStates[espType] then return end
    local objects = getObjectsFunc()
    if objects then
        for _, obj in pairs(objects) do
            local highlight = CreateHighlightESP(obj, color)
            table.insert(GeneralTable.ESP[espType], highlight)
        end
    end
end

-- Functions to retrieve objects for different ESP types
local function GetDoorObjects()
    local doorObjects = {}
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        local door = room:FindFirstChild("Door") and room.Door:FindFirstChild("Door")
        if door then table.insert(doorObjects, door) end
    end
    return #doorObjects > 0 and doorObjects or nil
end

local function GetTargetObjects()
    local targets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "KeyObtain" or obj.Name == "LiveBreakerPolePickup" or obj.Name == "LiveHintBook" then
            table.insert(targets, obj)
        end
    end
    return #targets > 0 and targets or nil
end

local function GetChestObjects()
    local chestObjects = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Chest" then
            table.insert(chestObjects, obj)
        end
    end
    return #chestObjects > 0 and chestObjects or nil
end

local function GetEntityObjects()
    local entityObjects = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name ~= "The Figure" then
            table.insert(entityObjects, obj)
        end
    end
    return #entityObjects > 0 and entityObjects or nil
end

local function GetGuidingLightObjects()
    local guidingLights = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "GuidingLight" then
            table.insert(guidingLights, obj)
        end
    end
    return #guidingLights > 0 and guidingLights or nil
end

local function GetGoldObjects()
    local goldObjects = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Gold" then
            table.insert(goldObjects, obj)
        end
    end
    return #goldObjects > 0 and goldObjects or nil
end

local function GetItemObjects()
    local itemObjects = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            table.insert(itemObjects, obj)
        end
    end
    return #itemObjects > 0 and itemObjects or nil
end

local function GetHandheldItemObjects()
    local handheldObjects = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChildOfClass("Tool") then
            table.insert(handheldObjects, player.Character:FindFirstChildOfClass("Tool"))
        end
    end
    return #handheldObjects > 0 and handheldObjects or nil
end

local function GetPlayerObjects()
    local playerObjects = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            table.insert(playerObjects, player.Character)
        end
    end
    return #playerObjects > 0 and playerObjects or nil
end

-- Monitor room generation and updates
local latestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom
latestRoom:GetPropertyChangedSignal("Value"):Connect(function()
    local newRoom = workspace.CurrentRooms:FindFirstChild(tostring(latestRoom.Value))
    if newRoom then
        ApplyESPForType("DoorESP", GetDoorObjects, GeneralTable.ESPColors.DoorESP)
        ApplyESPForType("TargetESP", GetTargetObjects, GeneralTable.ESPColors.TargetESP)
        ApplyESPForType("ChestESP", GetChestObjects, GeneralTable.ESPColors.ChestESP)
        ApplyESPForType("EntityESP", GetEntityObjects, GeneralTable.ESPColors.EntityESP)
        ApplyESPForType("GuidingLightESP", GetGuidingLightObjects, GeneralTable.ESPColors.GuidingLightESP)
        ApplyESPForType("GoldESP", GetGoldObjects, GeneralTable.ESPColors.GoldESP)
        ApplyESPForType("ItemESP", GetItemObjects, GeneralTable.ESPColors.ItemESP)
        ApplyESPForType("HandheldItemESP", GetHandheldItemObjects, GeneralTable.ESPColors.HandheldItemESP)
        ApplyESPForType("PlayerESP", GetPlayerObjects, GeneralTable.ESPColors.PlayerESP)
        CleanupOldRooms()
    end
end)

-- UI Toggles and Color Pickers for each ESP
for espType, _ in pairs(GeneralTable.ESP) do
    MainTab:AddToggle({
        Name = espType .. " Toggle",
        Default = false,
        Callback = function(enabled)
            GeneralTable.ToggleStates[espType] = enabled
            if enabled then
                ApplyESPForType(espType, _G["Get" .. espType .. "Objects"], GeneralTable.ESPColors[espType])
            else
                for _, esp in pairs(GeneralTable.ESP[espType]) do esp:Destroy() end
                GeneralTable.ESP[espType] = {}
            end
        end
    })

    ConfigTab:AddColorpicker({
        Name = espType .. " Color",
        Default = GeneralTable.ESPColors[espType],
        Callback = function(color)
            GeneralTable.ESPColors[espType] = color
            UpdateESPColors(espType, color)
        end
    })
end

-- Initialize Orion Library
OrionLib:Init()
