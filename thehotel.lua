-- Global check to prevent multiple executions
if getgenv().DoorsPlusPlus then return end
getgenv().DoorsPlusPlus = true

-- Load Linoria UI Library
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Doors ++',
    Center = true,
    AutoShow = true,
    Size = UDim2.new(0, 500, 0, 600),
    CanDrag = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Visuals'),
    Config = Window:AddTab('Config'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

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

-- Helper function for creating highlights with default properties
local function CreateHighlightESP(object, fillColor)
    if not object or not fillColor then return nil end
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
    if not GeneralTable.ESP[espType] then return end
    for _, highlight in pairs(GeneralTable.ESP[espType]) do
        if highlight and highlight.Adornee then
            highlight.FillColor = color
        end
    end
end

-- Cleanup ESPs for rooms beyond the specified range
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

-- Function for applying ESP to specific objects
local function ApplyESPForType(espType, getObjectsFunc, color)
    if not GeneralTable.ToggleStates[espType] then return end
    if not getObjectsFunc then return end
    local objects = getObjectsFunc()
    if objects then
        for _, obj in pairs(objects) do
            if obj:IsA("Instance") and not obj:FindFirstChildOfClass("Highlight") then
                local highlight = CreateHighlightESP(obj, color)
                if highlight then
                    table.insert(GeneralTable.ESP[espType], highlight)
                end
            end
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
    return doorObjects
end

local function GetTargetObjects()
    local targets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "KeyObtain" or obj.Name == "LiveBreakerPolePickup" or obj.Name == "LiveHintBook" or obj.Name == "LeverForGate" then
            table.insert(targets, obj)
        end
    end
    return targets
end

local function GetChestObjects()
    local chestObjects = {}
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        for _, obj in pairs(room:GetDescendants()) do
            if obj.Name == "Main" and obj.Parent and obj.Parent.Name == "ChestBox" then
                table.insert(chestObjects, obj)
            end
        end
    end
    return chestObjects
end

local function GetEntityObjects()
    local entityObjects = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(obj) then
            table.insert(entityObjects, obj)
        end
    end
    return entityObjects
end

local function GetAllItemObjects()
    local items = {}
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        for _, obj in pairs(room:GetDescendants()) do
            if obj:IsA("Model") and (obj:GetAttribute("Pickup") or obj:GetAttribute("PropType")) then
                table.insert(items, obj)
            end
        end
    end
    for _, item in pairs(workspace.Drops:GetChildren()) do
        table.insert(items, item)
    end
    return items
end

-- Initialize ESP
local latestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom
latestRoom:GetPropertyChangedSignal("Value"):Connect(function()
    local newRoom = workspace.CurrentRooms:FindFirstChild(tostring(latestRoom.Value))
    if newRoom then
        ApplyESPForType("DoorESP", GetDoorObjects, GeneralTable.ESPColors.DoorESP)
        ApplyESPForType("TargetESP", GetTargetObjects, GeneralTable.ESPColors.TargetESP)
        ApplyESPForType("ChestESP", GetChestObjects, GeneralTable.ESPColors.ChestESP)
        ApplyESPForType("EntityESP", GetEntityObjects, GeneralTable.ESPColors.EntityESP)
        ApplyESPForType("ItemESP", GetAllItemObjects, GeneralTable.ESPColors.ItemESP)
        CleanupOldRooms()
    end
end)

-- Add UI Elements
local VisualGroup = Tabs.Main:AddLeftGroupbox("Visual Toggles")
for espType, _ in pairs(GeneralTable.ESP) do
    VisualGroup:AddToggle(espType, {
        Text = espType:gsub("ESP", " ESP"),
        Default = false,
        Callback = function(value)
            GeneralTable.ToggleStates[espType] = value
            if value then
                ApplyESPForType(espType, _G["Get" .. espType], GeneralTable.ESPColors[espType])
            end
        end
    })
end

-- Update colors on change
local ColorGroup = Tabs.Config:AddLeftGroupbox("ESP Colors")
for espType, color in pairs(GeneralTable.ESPColors) do
    ColorGroup:AddLabel(espType):AddColorPicker(espType, {
        Default = color,
        Callback = function(value)
            GeneralTable.ESPColors[espType] = value
            UpdateESPColors(espType, value)
        end
    })
end

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddLabel('Adjust UI Keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    Text = 'Menu keybind'
})
Library.ToggleKeybind = Options.MenuKeybind
SaveManager:LoadAutoloadConfig()

Library:Notify('Doors ++ loaded successfully.')
