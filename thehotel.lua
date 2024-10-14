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
        Doors = {}
    },
    ESPEnabled = true -- Control whether ESP is enabled or not
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

-- Function to add ESP to doors
function DoorESP()
    if not MainTable.ESPEnabled then return end -- If ESP is disabled, don't run

    local currentRoomModel = workspace.CurrentRooms[tostring(CurrentRoom)]
    if not currentRoomModel then return end

    -- Iterate through the objects in the current room and find doors
    for _, object in ipairs(currentRoomModel:GetChildren()) do
        if object.Name == "Door" and not MainTable.ESP.Doors[object] then -- Check if the object is a door and not already highlighted
            local highlight = ESPHighlight(object) -- Use the generalized ESPHighlight function
            MainTable.ESP.Doors[object] = highlight -- Store the highlight in the table
        end
    end
end

-- Remove ESP when needed
function ClearESP()
    for door, highlight in pairs(MainTable.ESP.Doors) do
        if highlight then
            highlight:Destroy() -- Remove the highlight
        end
    end
    MainTable.ESP.Doors = {} -- Clear the table
end

-- Optimized real-time ESP updater using RunService.RenderStepped for instant response
RunService.RenderStepped:Connect(function()
    local newRoom = LocalPlayer:GetAttribute("CurrentRoom")
    if newRoom ~= CurrentRoom then
        CurrentRoom = newRoom
        ClearESP() -- Remove previous highlights instantly when entering a new room
        DoorESP()  -- Add ESP to doors in the new room immediately
    end
end)

-- UI Control for ESP Toggle
ESPGroup:AddToggle('DoorESP', {
    Text = 'Enable Door ESP',
    Default = true, -- ESP is enabled by default
    Tooltip = 'Toggles Door ESP on or off',
    Callback = function(value)
        MainTable.ESPEnabled = value
        if not value then
            ClearESP() -- Clear ESP if it's toggled off
        else
            DoorESP() -- Apply ESP if toggled on
        end
    end
})

-- Config Tab for Keybinding to toggle the UI itself (Corrected)
local ConfigGroup = Tabs.Config:AddLeftGroupbox('Config')
ConfigGroup:AddLabel('Keybind to Toggle UI')

-- Correctly setting up the keybind to toggle the UI visibility
ConfigGroup:AddKeyPicker('ToggleUIMenuKeybind', {
    Default = 'End', -- Default key to toggle UI
    Text = 'Toggle UI Key',
    NoUI = true, -- Hides the keybind from the keybind menu
    Mode = 'Toggle', -- Mode: Toggle or Hold
    Callback = function()
        -- Toggle the UI visibility
        Library.ToggleUI()
    end
})

-- Additional UI Settings (Themes, Saves)
local MenuGroup = Tabs.Config:AddLeftGroupbox('UI Settings')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

-- Theme and Save manager setup
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Config)
ThemeManager:ApplyToTab(Tabs.Config)
