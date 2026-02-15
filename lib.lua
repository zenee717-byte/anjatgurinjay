--// Gnnrs UI Library (Upgraded from Vincent Hub)
--// Supports Toggles, Tabs, Sections, Flag Saving, Mobile Button
--// All Vincent Hub references replaced with Gnnrs

local UserInputService = game:GetService('UserInputService')
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local CoreGui = game:GetService('CoreGui')

local LocalPlayer = Players.LocalPlayer

--// Main Library Table
local Library = {
    connections = {},
    Flags = {},
    Enabled = true,
    slider_drag = false,
    core = nil,
    dragging = false,
    drag_position = nil,
    start_position = nil
}

--// Folder Name Changed
local FolderName = "Gnnrs"

--// Enable flag saving by default
local SaveFlagsG = true

--// Create folder
if not isfolder(FolderName) then
    makefolder(FolderName)
end

--// Disconnect all connections
function Library:Disconnect()
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    table.clear(self.connections)
end

--// Clear existing UI
function Library:Clear()
    for _, object in ipairs(CoreGui:GetChildren()) do
        if object.Name == "Gnnrs" then
            object:Destroy()
        end
    end
end

--// Check if exists
function Library:Exist()
    return self.core and self.core.Parent ~= nil
end

--// Save flags
function Library:SaveFlags()
    if not SaveFlagsG then return end

    pcall(function()
        writefile(
            string.format("%s/%s.json", FolderName, game.GameId),
            HttpService:JSONEncode(self.Flags)
        )
    end)
end

--// Load flags
function Library:LoadFlags()
    if not SaveFlagsG then return end

    pcall(function()
        local path = string.format("%s/%s.json", FolderName, game.GameId)

        if not isfile(path) then
            self:SaveFlags()
            return
        end

        self.Flags = HttpService:JSONDecode(readfile(path))
    end)
end

--// Toggle UI visibility
function Library:ToggleUI()
    self.Enabled = not self.Enabled

    if self.Enabled then
        self.Container.Visible = true
        self.Shadow.Visible = true
    else
        self.Container.Visible = false
        self.Shadow.Visible = false
    end
end

--// Create main window
function Library:CreateWindow(title)

    self:LoadFlags()
    self:Clear()

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Gnnrs"
    ScreenGui.Parent = CoreGui

    self.core = ScreenGui

    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = ScreenGui
    Shadow.AnchorPoint = Vector2.new(0.5,0.5)
    Shadow.Position = UDim2.new(0.5,0,0.5,0)
    Shadow.Size = UDim2.new(0,780,0,520)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://17290899982"

    self.Shadow = Shadow

    -- Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = ScreenGui
    Container.AnchorPoint = Vector2.new(0.5,0.5)
    Container.Position = UDim2.new(0.5,0,0.5,0)
    Container.Size = UDim2.new(0,700,0,430)
    Container.BackgroundColor3 = Color3.fromRGB(19,20,24)

    self.Container = Container

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0,20)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = Container
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Gnnrs"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.new(1,1,1)

    -- Tabs Container
    local TabsFrame = Instance.new("Frame")
    TabsFrame.Parent = Container
    TabsFrame.Position = UDim2.new(0,0,0,40)
    TabsFrame.Size = UDim2.new(0,200,1,-40)
    TabsFrame.BackgroundTransparency = 1

    local TabsLayout = Instance.new("UIListLayout", TabsFrame)
    TabsLayout.Padding = UDim.new(0,5)

    -- Sections Container
    local SectionsFrame = Instance.new("Frame")
    SectionsFrame.Parent = Container
    SectionsFrame.Position = UDim2.new(0,200,0,40)
    SectionsFrame.Size = UDim2.new(1,-200,1,-40)
    SectionsFrame.BackgroundTransparency = 1

    local Window = {}
    Window.Tabs = {}

    -- Create Tab
    function Window:CreateTab(name)

        local TabButton = Instance.new("TextButton")
        TabButton.Parent = TabsFrame
        TabButton.Size = UDim2.new(1,0,0,40)
        TabButton.Text = name
        TabButton.BackgroundColor3 = Color3.fromRGB(30,30,35)
        TabButton.TextColor3 = Color3.new(1,1,1)

        Instance.new("UICorner", TabButton)

        local SectionFrame = Instance.new("ScrollingFrame")
        SectionFrame.Parent = SectionsFrame
        SectionFrame.Size = UDim2.new(1,0,1,0)
        SectionFrame.Visible = false
        SectionFrame.BackgroundTransparency = 1

        local Layout = Instance.new("UIListLayout", SectionFrame)
        Layout.Padding = UDim.new(0,6)

        local Tab = {}

        function TabButton.MouseButton1Click()
            for _, tab in pairs(Window.Tabs) do
                tab.Section.Visible = false
            end

            SectionFrame.Visible = true
        end

        -- Create Toggle
        function Tab:CreateToggle(cfg)

            local Toggle = Instance.new("TextButton")
            Toggle.Parent = SectionFrame
            Toggle.Size = UDim2.new(1,-10,0,35)
            Toggle.Text = cfg.Name
            Toggle.BackgroundColor3 = Color3.fromRGB(27,28,33)
            Toggle.TextColor3 = Color3.new(1,1,1)

            Instance.new("UICorner", Toggle)

            local Flag = cfg.Flag or cfg.Name

            if Library.Flags[Flag] == nil then
                Library.Flags[Flag] = cfg.Default or false
            end

            local function Refresh()
                Toggle.Text = cfg.Name .. ": " .. (Library.Flags[Flag] and "ON" or "OFF")
            end

            Refresh()

            Toggle.MouseButton1Click:Connect(function()

                Library.Flags[Flag] = not Library.Flags[Flag]

                Library:SaveFlags()

                Refresh()

                if cfg.Callback then
                    cfg.Callback(Library.Flags[Flag])
                end

            end)

            if cfg.Callback then
                cfg.Callback(Library.Flags[Flag])
            end

        end

        Tab.Section = SectionFrame

        table.insert(Window.Tabs, Tab)

        return Tab

    end

    -- Mobile button
    local MobileButton = Instance.new("TextButton")
    MobileButton.Parent = ScreenGui
    MobileButton.Size = UDim2.new(0,50,0,50)
    MobileButton.Position = UDim2.new(0,20,0.8,0)
    MobileButton.Text = "G"

    Instance.new("UICorner", MobileButton)

    MobileButton.MouseButton1Click:Connect(function()
        Library:ToggleUI()
    end)

    -- Keybind toggle (RightCtrl)
    UserInputService.InputBegan:Connect(function(input,gpe)
        if gpe then return end

        if input.KeyCode == Enum.KeyCode.RightControl then
            Library:ToggleUI()
        end
    end)

    return Window

end

-- Return Library
return Library

--[[

Example usage:

local Library = loadstring(readfile("GnnrsLibrary.lua"))()

local Window = Library:CreateWindow("Gnnrs Hub")

local CombatTab = Window:CreateTab("Combat")

CombatTab:CreateToggle({
    Name = "Auto Parry",
    Flag = "AutoParry",
    Default = false,
    Callback = function(state)
        print("Auto Parry:", state)
    end
})

CombatTab:CreateToggle({
    Name = "Auto Spam",
    Flag = "AutoSpam",
    Default = false,
    Callback = function(state)
        print("Auto Spam:", state)
    end
})

]]--


--// =============================
--// KEYBIND SUPPORT UPGRADE
--// =============================

local UserInputService = game:GetService("UserInputService")

Gnnrs.ActiveKeybinds = Gnnrs.ActiveKeybinds or {}

function Gnnrs:AddToggleWithKeybind(Tab, Config)

    local Name = Config.Name or "Toggle"
    local Default = Config.Default or false
    local Keybind = Config.Keybind or Enum.KeyCode.E
    local Callback = Config.Callback or function() end
    local Flag = Config.Flag or Name

    local Enabled = Default
    local WaitingForBind = false

    -- container
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1,0,0,30)
    Holder.BackgroundTransparency = 1
    Holder.Parent = Tab

    -- label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6,0,1,0)
    Label.BackgroundTransparency = 1
    Label.Text = Name
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    -- keybind button
    local KeyButton = Instance.new("TextButton")
    KeyButton.Size = UDim2.new(0,40,0,20)
    KeyButton.Position = UDim2.new(0.65,0,0.5,-10)
    KeyButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
    KeyButton.TextColor3 = Color3.fromRGB(255,255,255)
    KeyButton.Font = Enum.Font.GothamBold
    KeyButton.TextSize = 12
    KeyButton.Text = Keybind.Name
    KeyButton.Parent = Holder

    Instance.new("UICorner", KeyButton).CornerRadius = UDim.new(0,6)

    -- toggle button
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0,40,0,20)
    Toggle.Position = UDim2.new(0.85,0,0.5,-10)
    Toggle.BackgroundColor3 = Enabled and Color3.fromRGB(140,70,255) or Color3.fromRGB(60,60,60)
    Toggle.Text = ""
    Toggle.Parent = Holder

    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,10)

    local function SetState(State)
        Enabled = State
        Toggle.BackgroundColor3 = State and Color3.fromRGB(140,70,255) or Color3.fromRGB(60,60,60)
        Callback(State)
    end

    Toggle.MouseButton1Click:Connect(function()
        SetState(not Enabled)
    end)

    KeyButton.MouseButton1Click:Connect(function()
        KeyButton.Text = "..."
        WaitingForBind = true
    end)

    UserInputService.InputBegan:Connect(function(Input, GPE)

        if GPE then return end

        if WaitingForBind then

            if Input.KeyCode ~= Enum.KeyCode.Unknown then

                Keybind = Input.KeyCode
                KeyButton.Text = Keybind.Name
                WaitingForBind = false

            end

            return
        end

        if Input.KeyCode == Keybind then
            SetState(not Enabled)
        end

    end)

    -- save
    Gnnrs.Flags[Flag] = Enabled

    return {
        Set = SetState,
        Get = function()
            return Enabled
        end
    }

end


--// =============================
--// EXAMPLE
--// =============================

-- Example usage:
-- Gnnrs:AddToggleWithKeybind(Tab, {
--     Name = "Auto Parry",
--     Default = false,
--     Keybind = Enum.KeyCode.E,
--     Flag = "AutoParry",
--     Callback = function(State)
--         print("Auto Parry:", State)
--     end
-- })

-- Gnnrs:AddToggleWithKeybind(Tab, {
--     Name = "Auto Spam",
--     Default = false,
--     Keybind = Enum.KeyCode.Q,
--     Flag = "AutoSpam",
--     Callback = function(State)
--         print("Auto Spam:", State)
--     end
-- })

