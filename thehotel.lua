-- Service(s)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local CurrentRoom = LocalPlayer:GetAttribute("CurrentRoom") or 0

-- UI Library setup
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'ESP Menu',
    Center = true,
    AutoShow = true,
    Draggable = true -- Allow the UI window to be draggable
})

local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Config = Window:AddTab('Config'),
}

local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP Options')

-- Table to store ESP objects
local MainTable = {
    ESP = {
        Doors = {},
        Targets = {} -- New table for target objects
    },
    ESPEnabled = true, -- Control whether ESP is enabled or not
    TargetESPEnabled = true -- Control whether Target ESP is enabled
}

-- General ESP Highlight Function
function ESPHighlight(object, color)
    local highlight = Instance.new("Highlight")
    highlight.Parent = object
    highlight.FillColor = color or Color3.fromRGB(0, 255, 0) -- Default to green if no color provided
    highlight.FillTransparency = 0.75
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    return highlight
end

-- Function to add Door ESP, using the Mspaint model method (Object = door:WaitForChild("Door"))
function DoorESP()
    if not MainTable.ESPEnabled then return end -- If ESP is disabled, don't run

    local currentRoomModel = workspace.CurrentRooms[tostring(CurrentRoom)]
    if not currentRoomModel then return end

    -- Iterate through the objects in the current room and find doors
    for _, object in ipairs(currentRoomModel:GetChildren()) do
        if object.Name == "Door" and not MainTable.ESP.Doors[object] then -- Check if the object is a door and not already highlighted
            local door = object:WaitForChild("Door", 5) -- Use the Mspaint model
            if door then
                local highlight = ESPHighlight(door) -- Use the generalized ESPHighlight function
                MainTable.ESP.Doors[object] = highlight -- Store the highlight in the table
            end
        end
    end
end

-- Function to add Target ESP (for KeyObtain, LeverForGate, LiveHintBook)
function TargetESP()
    if not MainTable.TargetESPEnabled then return end -- If Target ESP is disabled, don't run

    local currentRoomModel = workspace.CurrentRooms[tostring(CurrentRoom)]
    if not currentRoomModel then return end

    -- Iterate through objects in the current room to find target objects
    for _, object in ipairs(currentRoomModel:GetChildren()) do
        if (object.Name == "KeyObtain" or object.Name == "LeverForGate" or object.Name == "LiveHintBook") and not MainTable.ESP.Targets[object] then
            local highlight = ESPHighlight(object, Color3.fromRGB(255, 0, 0)) -- Red color for target objects
            MainTable.ESP.Targets[object] = highlight -- Store the highlight in the table
        end
    end
end

-- Remove ESP for doors or targets when needed
function ClearESP(type)
    if type == "Doors" then
        for door, highlight in pairs(MainTable.ESP.Doors) do
            if highlight then
                highlight:Destroy() -- Remove the highlight
            end
        end
        MainTable.ESP.Doors = {} -- Clear the table
    elseif type == "Targets" then
        for target, highlight in pairs(MainTable.ESP.Targets) do
            if highlight then
                highlight:Destroy() -- Remove the highlight
            end
        end
        MainTable.ESP.Targets = {} -- Clear the table
    end
end

-- Optimized real-time ESP updater using RunService.RenderStepped for instant response
RunService.RenderStepped:Connect(function()
    local newRoom = LocalPlayer:GetAttribute("CurrentRoom")
    if newRoom ~= CurrentRoom then
        CurrentRoom = newRoom
        ClearESP("Doors") -- Remove previous door highlights instantly when entering a new room
        ClearESP("Targets") -- Remove previous target highlights
        DoorESP()  -- Add ESP to doors in the new room immediately
        TargetESP() -- Add ESP to target objects in the new room
    end
end)

-- UI Control for Door ESP Toggle
ESPGroup:AddToggle('DoorESP', {
    Text = 'Enable Door ESP',
    Default = true, -- ESP is enabled by default
    Tooltip = 'Toggles Door ESP on or off',
    Callback = function(value)
        MainTable.ESPEnabled = value
        if not value then
            ClearESP("Doors") -- Clear Door ESP if it's toggled off
        else
            DoorESP() -- Apply Door ESP if toggled on
        end
    end
})

-- UI Control for Target ESP Toggle
ESPGroup:AddToggle('TargetESP', {
    Text = 'Enable Target ESP',
    Default = true, -- Target ESP is enabled by default
    Tooltip = 'Toggles Target ESP on or off',
    Callback = function(value)
        MainTable.TargetESPEnabled = value
        if not value then
            ClearESP("Targets") -- Clear Target ESP if it's toggled off
        else
            TargetESP() -- Apply Target ESP if toggled on
        end
    end
})

-- Config Tab for Keybinding to toggle the UI itself
local ConfigGroup = Tabs.Config:AddLeftGroupbox('Config')
ConfigGroup:AddLabel('Keybind to Toggle UI')

-- Correctly setting up the keybind using AddKeyPicker based on your example
ConfigGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'End', -- Default key to toggle UI
    NoUI = true, -- Hide the keybind from the keybind menu
    Text = 'Toggle UI Keybind',
    Mode = 'Toggle', -- Modes: Always, Toggle, Hold
    Callback = function()
        -- Toggle the UI visibility
        if Library.ToggleUI then
            Library:ToggleUI()
        end
    end
})

-- Additional UI Settings (Themes, Saves)
local MenuGroup = Tabs.Config:AddLeftGroupbox('UI Settings')
MenuGroup:AddButton('Unload', function() Library:Unload() end)

-- Theme and Save manager setup
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Config)
ThemeManager:ApplyToTab(Tabs.Config)
