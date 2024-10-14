-- Importing the Cerberus UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/cerberus.lua"))()

-- Creating the main window
local window = Library.new("ESP Menu", true, 500, 400, "RightShift")

-- Locking window within screen boundaries
window:LockScreenBoundaries(true)

-- Creating tabs for UI
local visualsTab = window:Tab("Visuals")
local configTab = window:Tab("Config")

-- Visuals Section for ESP toggles
local visualsSection = visualsTab:Section("ESP Options")

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

-- Adding toggles for Door ESP, Target ESP, and Chest ESP
visualsSection:Toggle("Door ESP", function(state)
    if state then
        ManageDoorESP()
    else
        ClearESP("Doors")
    end
end):Set(false) -- Default to off

visualsSection:Toggle("Target ESP", function(state)
    if state then
        ManageTargetESP()
    else
        ClearESP("Targets")
    end
end):Set(false) -- Default to off

visualsSection:Toggle("Chest ESP", function(state)
    if state then
        ManageChestESP()
    else
        ClearESP("Chests")
    end
end):Set(false) -- Default to off

-- Config Section for UI keybinding
local configSection = configTab:Section("Config")

-- Setting up keybinding for toggling the UI visibility
configSection:Keybind("Toggle UI", function()
    window:Toggle()
end, "RightShift") -- Default key to toggle UI

-- Additional UI Controls
configSection:Button("Unload", function()
    window:Destroy()
    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
    print("Unloaded ESP Menu")
end)

configSection:TextBox("Textbox Example", function(txt)
    print("Textbox content: " .. txt)
end)

configSection:Slider("Example Slider", function(val)
    print("Slider value: " .. val)
end, 100, 0) -- Slider with max value 100 and min value 0
