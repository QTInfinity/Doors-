-- Global check to prevent multiple executions
if getgenv().SeerGG_Doors_TheHotel then
    return
end
getgenv().SeerGG_Doors_TheHotel = true

-- Load Linoria UI Library
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Seer.GG/Doors ESP',
    Center = true,
    AutoShow = true,
    Size = UDim2.new(0, 450, 0, 500), -- Slightly smaller window
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
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name ~= "The Figure" and not game.Players:GetPlayerFromCharacter(obj) then
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

-- Function to initialize ESP on existing objects
local function InitializeESP()
    ApplyESPForType("DoorESP", GetDoorObjects, GeneralTable.ESPColors.DoorESP)
    ApplyESPForType("TargetESP", GetTargetObjects, GeneralTable.ESPColors.TargetESP)
    ApplyESPForType("ChestESP", GetChestObjects, GeneralTable.ESPColors.ChestESP)
    ApplyESPForType("EntityESP", GetEntityObjects, GeneralTable.ESPColors.EntityESP)
    ApplyESPForType("GuidingLightESP", GetGuidingLightObjects, GeneralTable.ESPColors.GuidingLightESP)
    ApplyESPForType("GoldESP", GetGoldObjects, GeneralTable.ESPColors.GoldESP)
    ApplyESPForType("ItemESP", GetItemObjects, GeneralTable.ESPColors.ItemESP)
    ApplyESPForType("HandheldItemESP", GetHandheldItemObjects, GeneralTable.ESPColors.HandheldItemESP)
    ApplyESPForType("PlayerESP", GetPlayerObjects, GeneralTable.ESPColors.PlayerESP)
end

-- Monitor room generation and updates
local latestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom
latestRoom:GetPropertyChangedSignal("Value"):Connect(function()
    local newRoom = workspace.CurrentRooms:FindFirstChild(tostring(latestRoom.Value))
    if newRoom then
        InitializeESP()
        CleanupOldRooms()
    end
end)

-- Add Toggles and Color Pickers using Linoria
local VisualsGroup = Tabs.Main:AddLeftGroupbox('ESP Toggles')
local ColorGroup = Tabs.Config:AddLeftGroupbox('ESP Colors')

for espType, _ in pairs(GeneralTable.ESP) do
    local toggleText = espType:gsub("ESP", " ESP")
    VisualsGroup:AddToggle(espType .. 'Toggle', {
        Text = toggleText,
        Default = false,
        Tooltip = 'Enable or disable ' .. toggleText,
        Callback = function(enabled)
            GeneralTable.ToggleStates[espType] = enabled
            if enabled then
                InitializeESP()
            else
                for _, esp in pairs(GeneralTable.ESP[espType]) do esp:Destroy() end
                GeneralTable.ESP[espType] = {}
            end
        end
    })
    
    ColorGroup:AddColorPicker(espType .. 'Color', {
        Text = toggleText .. ' Color',
        Default = GeneralTable.ESPColors[espType],
        Callback = function(color)
            GeneralTable.ESPColors[espType] = color
            UpdateESPColors(espType, color)
        end
    })
end

-- Initialize ESP on first load
InitializeESP()

-- Setup Linoria SaveManager and ThemeManager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:SetFolder('Seer.GG/Doors/TheHotel')

-- UI Settings for changing themes and adding a keybind for menu toggle
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu keybind'
})
Library.ToggleKeybind = Options.MenuKeybind

-- Apply and load default config
SaveManager:LoadAutoloadConfig()

-- Notify when loaded
Library:Notify('Seer.GG ESP loaded successfully.')
