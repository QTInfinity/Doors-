-- Global check to prevent multiple executions
if getgenv().DoorsPlusPlus then return end
getgenv().DoorsPlusPlus = true

-- Load Linoria UI Library
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Initialize UI and Configurations
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
    Config = Window:AddTab('Config')
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
    ToggleStates = {}
}

-- Initialize Toggle States to False
for espType, _ in pairs(GeneralTable.ESP) do
    GeneralTable.ToggleStates[espType] = false
end

-- Helper function for creating highlights with default properties
local function CreateHighlightESP(object, fillColor)
    if not object or not fillColor then
        return nil
    end
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
    for _, highlight in pairs(GeneralTable.ESP[espType] or {}) do
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

-- Apply ESP for each object type
local function ApplyESPForType(espType, getObjectsFunc, color)
    -- Validate the function and color
    if not getObjectsFunc or not color then
        warn("ApplyESPForType: Missing function or color for " .. espType)
        return
    end
    
    -- Retrieve objects using the function
    local objects = getObjectsFunc()
    
    -- Validate objects list
    if not objects or #objects == 0 then
        warn("ApplyESPForType: No objects found for " .. espType)
        return
    end
    
    -- Create highlights for each object
    for _, obj in pairs(objects) do
        if obj:IsA("Instance") and not obj:FindFirstChildOfClass("Highlight") then
            local highlight = CreateHighlightESP(obj, color)
            if highlight then
                table.insert(GeneralTable.ESP[espType], highlight)
            else
                warn("ApplyESPForType: Failed to create highlight for " .. tostring(obj))
            end
        end
    end
end

-- Define GetObjects functions for each ESP type
local function GetDoorObjects()
    -- Logic to get door objects
    local objects = {}
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        local door = room:FindFirstChild("Door")
        if door then table.insert(objects, door) end
    end
    return objects
end

-- Define other functions like GetTargetObjects, GetPlayerObjects, etc. here...

-- ESP Toggles and Color Configurations
local VisualGroup = Tabs.Main:AddLeftGroupbox("Visual Toggles")
for espType, _ in pairs(GeneralTable.ESP) do
    VisualGroup:AddToggle(espType, {
        Text = espType:gsub("ESP", " ESP"),
        Default = false,
        Callback = function(value)
            GeneralTable.ToggleStates[espType] = value
            ApplyESPForType(espType, _G["Get"..espType.."Objects"], GeneralTable.ESPColors[espType])
        end
    })
end

-- Configs and UI Toggle
local ConfigGroup = Tabs.Config:AddRightGroupbox("ESP Colors")
for espType, _ in pairs(GeneralTable.ESP) do
    ConfigGroup:AddLabel(espType .. " Color"):AddColorPicker(espType .. "Color", {
        Default = GeneralTable.ESPColors[espType],
        Callback = function(value)
            GeneralTable.ESPColors[espType] = value
            UpdateESPColors(espType, value)
        end
    })
end

-- UI Key Picker
ConfigGroup:AddLabel('UI Toggle Key'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    Text = 'Menu keybind',
    Mode = 'Toggle',
    Callback = function()
        Library:Toggle()
    end
})

-- ThemeManager Setup
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs.Config)
SaveManager:SetFolder("Doors++")
SaveManager:BuildConfigSection(Tabs.Config)

Library:Notify('Doors ++ loaded successfully.')

-- Monitor room changes and apply ESP
local latestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom
latestRoom:GetPropertyChangedSignal("Value"):Connect(function()
    local newRoom = workspace.CurrentRooms:FindFirstChild(tostring(latestRoom.Value))
    if newRoom then
        InitializeESP()
        CleanupOldRooms()
    end
end)

-- Function to Initialize ESP
local function InitializeESP()
    for espType, _ in pairs(GeneralTable.ESP) do
        if GeneralTable.ToggleStates[espType] then
            local color = GeneralTable.ESPColors[espType] or Color3.new(1, 1, 1)
            ApplyESPForType(espType, _G["Get"..espType.."Objects"], color)
        end
    end
end
