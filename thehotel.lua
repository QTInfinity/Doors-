-- Importing the Cerberus UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/cerberus.lua"))()

-- Create the main window
local window = Library.new("ESP Menu", true, 500, 400, "RightShift")

-- Locking window within screen boundaries
window:LockScreenBoundaries(true)

-- Creating tabs for UI
local visualsTab = window:Tab("Visuals")
local configTab = window:Tab("Config")

-- Sections for ESP Options and Configurations
local visualsSection = visualsTab:Section("ESP Options")
local configSection = configTab:Section("Config")

-- Services and player setup
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Centralized tables for connections and ESP objects
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
    ESPObjects[type] = {}
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

-- Handling ESP toggles
visualsSection:Toggle("Door ESP", function(state)
    if state then
        ManageDoorESP()
    else
        ClearESP("Doors")
    end
end):Set(false)

visualsSection:Toggle("Target ESP", function(state)
    if state then
        ManageTargetESP()
    else
        ClearESP("Targets")
    end
end):Set(false)

visualsSection:Toggle("Chest ESP", function(state)
    if state then
        ManageChestESP()
    else
        ClearESP("Chests")
    end
end):Set(false)

-- Keybind to toggle UI visibility
configSection:Keybind("Toggle UI", function()
    window:Toggle()
end, "RightShift")

-- Button to unload the script
configSection:Button("Unload", function()
    window:Destroy()
    print("ESP Menu Unloaded")
end)
