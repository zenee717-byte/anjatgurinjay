-- ════════════════════════════════════════════════════════════════
-- MODERN UI LIBRARY v2.1 - FIXED & STABLE
-- Professional, Clean, Error-handled
-- ════════════════════════════════════════════════════════════════

local Library = {}
Library.__index = Library

-- ════════════════════════════════════════════════════════════════
-- SAFE SERVICE LOADING
-- ════════════════════════════════════════════════════════════════
local function GetService(name)
    local success, service = pcall(function()
        return game:GetService(name)
    end)
    return success and service or nil
end

local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local RunService = GetService("RunService")
local Players = GetService("Players")
local CoreGui = GetService("CoreGui") or GetService("StarterGui")
local HttpService = GetService("HttpService")

if not TweenService or not UserInputService or not Players then
    error("Critical services not available")
    return nil
end

local Player = Players.LocalPlayer
local Mouse = Player and Player:GetMouse()

-- ════════════════════════════════════════════════════════════════
-- THEME - Clean & Modern
-- ════════════════════════════════════════════════════════════════
local Theme = {
    Background = Color3.fromRGB(18, 18, 23),
    Surface = Color3.fromRGB(25, 25, 30),
    Card = Color3.fromRGB(30, 30, 37),
    Elevated = Color3.fromRGB(35, 35, 42),
    
    Primary = Color3.fromRGB(99, 102, 241),
    PrimaryDark = Color3.fromRGB(79, 70, 229),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 191, 36),
    Error = Color3.fromRGB(239, 68, 68),
    
    Text = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    TextTertiary = Color3.fromRGB(100, 100, 115),
    
    Border = Color3.fromRGB(45, 45, 52),
    BorderLight = Color3.fromRGB(55, 55, 62),
    
    Shadow = Color3.fromRGB(0, 0, 0),
    Overlay = Color3.fromRGB(0, 0, 0),
}

-- ════════════════════════════════════════════════════════════════
-- ANIMATION PRESETS
-- ════════════════════════════════════════════════════════════════
local Animations = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
}

local function Tween(instance, info, properties)
    if not instance or not instance.Parent then return end
    local success, err = pcall(function()
        TweenService:Create(instance, info, properties):Play()
    end)
    if not success then
        warn("Tween error:", err)
    end
end

-- ════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════
local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function AddPadding(parent, all)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, all)
    padding.PaddingBottom = UDim.new(0, all)
    padding.PaddingLeft = UDim.new(0, all)
    padding.PaddingRight = UDim.new(0, all)
    padding.Parent = parent
    return padding
end

-- ════════════════════════════════════════════════════════════════
-- LIBRARY CREATION
-- ════════════════════════════════════════════════════════════════
function Library:New(config)
    local self = setmetatable({}, Library)
    
    config = config or {}
    self.Name = config.Name or "Modern UI"
    self.Size = config.Size or {Width = 580, Height = 420}
    self.Theme = config.Theme or "Dark"
    
    -- Cleanup old instances
    pcall(function()
        local old = CoreGui:FindFirstChild("ModernUI")
        if old then old:Destroy() end
    end)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ModernUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = CoreGui
    
    -- Main Container
    self.Main = Instance.new("Frame")
    self.Main.Name = "Main"
    self.Main.Size = UDim2.fromOffset(0, 0)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Main.BackgroundColor3 = Theme.Background
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Parent = self.ScreenGui
    
    AddCorner(self.Main, 12)
    AddStroke(self.Main, Theme.BorderLight, 1)
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    self:CreateTopbar()
    self:CreateSidebar()
    self:CreateContent()
    self:MakeDraggable()
    self:Animate()
    
    return self
end

-- ════════════════════════════════════════════════════════════════
-- TOPBAR
-- ════════════════════════════════════════════════════════════════
function Library:CreateTopbar()
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 50)
    Topbar.BackgroundColor3 = Theme.Surface
    Topbar.BorderSizePixel = 0
    Topbar.Parent = self.Main
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.fromOffset(20, 0)
    Title.BackgroundTransparency = 1
    Title.Text = self.Name
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.fromOffset(36, 36)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, 0)
    CloseBtn.AnchorPoint = Vector2.new(0, 0.5)
    CloseBtn.BackgroundColor3 = Theme.Card
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 20
    CloseBtn.TextColor3 = Theme.TextSecondary
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Topbar
    
    AddCorner(CloseBtn, 8)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, Animations.Fast, {BackgroundColor3 = Theme.Error})
        Tween(CloseBtn, Animations.Fast, {TextColor3 = Theme.Text})
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, Animations.Fast, {BackgroundColor3 = Theme.Card})
        Tween(CloseBtn, Animations.Fast, {TextColor3 = Theme.TextSecondary})
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, Animations.Medium, {Size = UDim2.fromOffset(0, 0)})
        task.wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    local Border = Instance.new("Frame")
    Border.Size = UDim2.new(1, 0, 0, 1)
    Border.Position = UDim2.new(0, 0, 1, 0)
    Border.BackgroundColor3 = Theme.Border
    Border.BorderSizePixel = 0
    Border.Parent = Topbar
    
    self.Topbar = Topbar
end

-- ════════════════════════════════════════════════════════════════
-- SIDEBAR
-- ════════════════════════════════════════════════════════════════
function Library:CreateSidebar()
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, -50)
    Sidebar.Position = UDim2.fromOffset(0, 50)
    Sidebar.BackgroundColor3 = Theme.Surface
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = self.Main
    
    local TabsContainer = Instance.new("ScrollingFrame")
    TabsContainer.Name = "TabsContainer"
    TabsContainer.Size = UDim2.new(1, -16, 1, -16)
    TabsContainer.Position = UDim2.fromOffset(8, 8)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.BorderSizePixel = 0
    TabsContainer.ScrollBarThickness = 4
    TabsContainer.ScrollBarImageColor3 = Theme.Primary
    TabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabsContainer.Parent = Sidebar
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = TabsContainer
    
    local Border = Instance.new("Frame")
    Border.Size = UDim2.new(0, 1, 1, 0)
    Border.Position = UDim2.new(1, 0, 0, 0)
    Border.BackgroundColor3 = Theme.Border
    Border.BorderSizePixel = 0
    Border.Parent = Sidebar
    
    self.Sidebar = Sidebar
    self.TabsContainer = TabsContainer
end

-- ════════════════════════════════════════════════════════════════
-- CONTENT AREA
-- ════════════════════════════════════════════════════════════════
function Library:CreateContent()
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -180, 1, -50)
    Content.Position = UDim2.fromOffset(180, 50)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.Parent = self.Main
    
    self.Content = Content
end

-- ════════════════════════════════════════════════════════════════
-- DRAGGABLE
-- ════════════════════════════════════════════════════════════════
function Library:MakeDraggable()
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        Tween(self.Main, Animations.Fast, {
            Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        })
    end
    
    self.Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        if dragging and dragInput then
            update(dragInput)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- ANIMATIONS
-- ════════════════════════════════════════════════════════════════
function Library:Animate()
    Tween(self.Main, Animations.Spring, {
        Size = UDim2.fromOffset(self.Size.Width, self.Size.Height)
    })
end


-- ════════════════════════════════════════════════════════════════
-- CREATE TAB
-- ════════════════════════════════════════════════════════════════
function Library:CreateTab(config)
    config = config or {}
    local tabName = config.Name or "Tab"
    local tabIcon = config.Icon or "📄"
    
    local Tab = {}
    Tab.Name = tabName
    Tab.Sections = {Left = nil, Right = nil}
    Tab.Active = false
    
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundColor3 = Theme.Card
    TabButton.BackgroundTransparency = 1
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.Parent = self.TabsContainer
    
    AddCorner(TabButton, 8)
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.fromOffset(24, 24)
    Icon.Position = UDim2.fromOffset(12, 8)
    Icon.BackgroundTransparency = 1
    Icon.Text = tabIcon
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 16
    Icon.TextColor3 = Theme.TextSecondary
    Icon.Parent = TabButton
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -48, 1, 0)
    Label.Position = UDim2.fromOffset(44, 0)
    Label.BackgroundTransparency = 1
    Label.Text = tabName
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextColor3 = Theme.TextSecondary
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TabButton
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.fromOffset(3, 0)
    Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BackgroundColor3 = Theme.Primary
    Indicator.BorderSizePixel = 0
    Indicator.Parent = TabButton
    
    AddCorner(Indicator, 2)
    
    local TabContent = Instance.new("Frame")
    TabContent.Name = tabName .. "Content"
    TabContent.Size = UDim2.new(1, -32, 1, -16)
    TabContent.Position = UDim2.fromOffset(16, 8)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = self.Content
    
    local LeftSection = Instance.new("ScrollingFrame")
    LeftSection.Name = "Left"
    LeftSection.Size = UDim2.new(0.5, -8, 1, 0)
    LeftSection.Position = UDim2.fromOffset(0, 0)
    LeftSection.BackgroundTransparency = 1
    LeftSection.BorderSizePixel = 0
    LeftSection.ScrollBarThickness = 4
    LeftSection.ScrollBarImageColor3 = Theme.Primary
    LeftSection.CanvasSize = UDim2.new(0, 0, 0, 0)
    LeftSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LeftSection.Parent = TabContent
    
    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.Padding = UDim.new(0, 12)
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Parent = LeftSection
    
    local RightSection = Instance.new("ScrollingFrame")
    RightSection.Name = "Right"
    RightSection.Size = UDim2.new(0.5, -8, 1, 0)
    RightSection.Position = UDim2.new(0.5, 8, 0, 0)
    RightSection.BackgroundTransparency = 1
    RightSection.BorderSizePixel = 0
    RightSection.ScrollBarThickness = 4
    RightSection.ScrollBarImageColor3 = Theme.Primary
    RightSection.CanvasSize = UDim2.new(0, 0, 0, 0)
    RightSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
    RightSection.Parent = TabContent
    
    local RightLayout = Instance.new("UIListLayout")
    RightLayout.Padding = UDim.new(0, 12)
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Parent = RightSection
    
    Tab.Sections.Left = LeftSection
    Tab.Sections.Right = RightSection
    Tab.Content = TabContent
    
    function Tab:Activate()
        for _, tab in pairs(self.Parent.Tabs) do
            if tab ~= self then
                tab:Deactivate()
            end
        end
        
        self.Active = true
        TabContent.Visible = true
        
        Tween(TabButton, Animations.Fast, {BackgroundTransparency = 0})
        Tween(Icon, Animations.Fast, {TextColor3 = Theme.Primary})
        Tween(Label, Animations.Fast, {TextColor3 = Theme.Text})
        Tween(Indicator, Animations.Medium, {Size = UDim2.fromOffset(3, 24)})
    end
    
    function Tab:Deactivate()
        self.Active = false
        TabContent.Visible = false
        
        Tween(TabButton, Animations.Fast, {BackgroundTransparency = 1})
        Tween(Icon, Animations.Fast, {TextColor3 = Theme.TextSecondary})
        Tween(Label, Animations.Fast, {TextColor3 = Theme.TextSecondary})
        Tween(Indicator, Animations.Medium, {Size = UDim2.fromOffset(3, 0)})
    end
    
    TabButton.MouseButton1Click:Connect(function()
        Tab:Activate()
    end)
    
    TabButton.MouseEnter:Connect(function()
        if not Tab.Active then
            Tween(TabButton, Animations.Fast, {BackgroundTransparency = 0.5})
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if not Tab.Active then
            Tween(TabButton, Animations.Fast, {BackgroundTransparency = 1})
        end
    end)
    
    Tab.Parent = self
    table.insert(self.Tabs, Tab)
    
    if #self.Tabs == 1 then
        Tab:Activate()
        self.CurrentTab = Tab
    end
    
    Tab.CreateSection = function(_, cfg) return self:CreateSection(Tab, cfg) end
    Tab.CreateToggle = function(_, cfg) return self:CreateToggle(Tab, cfg) end
    Tab.CreateButton = function(_, cfg) return self:CreateButton(Tab, cfg) end
    Tab.CreateSlider = function(_, cfg) return self:CreateSlider(Tab, cfg) end
    Tab.CreateDropdown = function(_, cfg) return self:CreateDropdown(Tab, cfg) end
    Tab.CreateTextbox = function(_, cfg) return self:CreateTextbox(Tab, cfg) end
    Tab.CreateLabel = function(_, cfg) return self:CreateLabel(Tab, cfg) end
    
    return Tab
end

-- ════════════════════════════════════════════════════════════════
-- SECTION
-- ════════════════════════════════════════════════════════════════
function Library:CreateSection(tab, config)
    config = config or {}
    local sectionName = config.Name or "Section"
    local side = config.Side or "Left"
    local parent = side == "Left" and tab.Sections.Left or tab.Sections.Right
    
    local Section = Instance.new("Frame")
    Section.Name = sectionName
    Section.Size = UDim2.new(1, 0, 0, 36)
    Section.BackgroundTransparency = 1
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.Parent = parent
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 24)
    Title.BackgroundTransparency = 1
    Title.Text = sectionName
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Section
    
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 0, 28)
    Divider.BackgroundColor3 = Theme.Border
    Divider.BorderSizePixel = 0
    Divider.Parent = Section
    
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.Position = UDim2.fromOffset(0, 36)
    Container.BackgroundTransparency = 1
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.Parent = Section
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Container
    
    return Container
end


-- ════════════════════════════════════════════════════════════════
-- TOGGLE
-- ════════════════════════════════════════════════════════════════
function Library:CreateToggle(tab, config)
    config = config or {}
    local parent = config.Parent or (config.Side == "Right" and tab.Sections.Right or tab.Sections.Left)
    
    local Toggle = {
        Value = config.Default or false,
        Callback = config.Callback or function() end
    }
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
    ToggleFrame.BackgroundColor3 = Theme.Card
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    AddCorner(ToggleFrame, 8)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -52, 1, 0)
    Label.Position = UDim2.fromOffset(12, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Toggle"
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.fromOffset(40, 20)
    Switch.Position = UDim2.new(1, -46, 0.5, 0)
    Switch.AnchorPoint = Vector2.new(0, 0.5)
    Switch.BackgroundColor3 = Theme.Elevated
    Switch.Text = ""
    Switch.AutoButtonColor = false
    Switch.Parent = ToggleFrame
    
    AddCorner(Switch, 10)
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.fromOffset(16, 16)
    Circle.Position = UDim2.fromOffset(2, 2)
    Circle.BackgroundColor3 = Theme.TextTertiary
    Circle.BorderSizePixel = 0
    Circle.Parent = Switch
    
    AddCorner(Circle, 8)
    
    function Toggle:SetValue(value)
        self.Value = value
        
        if value then
            Tween(Switch, Animations.Medium, {BackgroundColor3 = Theme.Primary})
            Tween(Circle, Animations.Medium, {
                Position = UDim2.fromOffset(22, 2),
                BackgroundColor3 = Theme.Text
            })
        else
            Tween(Switch, Animations.Medium, {BackgroundColor3 = Theme.Elevated})
            Tween(Circle, Animations.Medium, {
                Position = UDim2.fromOffset(2, 2),
                BackgroundColor3 = Theme.TextTertiary
            })
        end
        
        pcall(function() self.Callback(value) end)
    end
    
    Switch.MouseButton1Click:Connect(function()
        Toggle:SetValue(not Toggle.Value)
    end)
    
    ToggleFrame.MouseEnter:Connect(function()
        Tween(ToggleFrame, Animations.Fast, {BackgroundColor3 = Theme.Elevated})
    end)
    
    ToggleFrame.MouseLeave:Connect(function()
        Tween(ToggleFrame, Animations.Fast, {BackgroundColor3 = Theme.Card})
    end)
    
    Toggle:SetValue(Toggle.Value)
    
    return Toggle
end

-- ════════════════════════════════════════════════════════════════
-- BUTTON
-- ════════════════════════════════════════════════════════════════
function Library:CreateButton(tab, config)
    config = config or {}
    local parent = config.Parent or (config.Side == "Right" and tab.Sections.Right or tab.Sections.Left)
    
    local ButtonFrame = Instance.new("TextButton")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 36)
    ButtonFrame.BackgroundColor3 = Theme.Primary
    ButtonFrame.Text = ""
    ButtonFrame.AutoButtonColor = false
    ButtonFrame.Parent = parent
    
    AddCorner(ButtonFrame, 8)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Button"
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextColor3 = Theme.Text
    Label.Parent = ButtonFrame
    
    ButtonFrame.MouseButton1Click:Connect(function()
        Tween(ButtonFrame, Animations.Fast, {BackgroundColor3 = Theme.PrimaryDark})
        task.wait(0.1)
        Tween(ButtonFrame, Animations.Fast, {BackgroundColor3 = Theme.Primary})
        
        if config.Callback then
            pcall(function() config.Callback() end)
        end
    end)
    
    ButtonFrame.MouseEnter:Connect(function()
        Tween(ButtonFrame, Animations.Fast, {BackgroundColor3 = Theme.PrimaryDark})
    end)
    
    ButtonFrame.MouseLeave:Connect(function()
        Tween(ButtonFrame, Animations.Fast, {BackgroundColor3 = Theme.Primary})
    end)
    
    return ButtonFrame
end

-- ════════════════════════════════════════════════════════════════
-- SLIDER
-- ════════════════════════════════════════════════════════════════
function Library:CreateSlider(tab, config)
    config = config or {}
    local parent = config.Parent or (config.Side == "Right" and tab.Sections.Right or tab.Sections.Left)
    
    local Slider = {
        Value = config.Default or config.Min or 0,
        Min = config.Min or 0,
        Max = config.Max or 100,
        Callback = config.Callback or function() end
    }
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Theme.Card
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    
    AddCorner(SliderFrame, 8)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.Position = UDim2.fromOffset(12, 8)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Slider"
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, -12, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Slider.Value)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 12
    ValueLabel.TextColor3 = Theme.Primary
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -24, 0, 4)
    Bar.Position = UDim2.new(0.5, 0, 1, -14)
    Bar.AnchorPoint = Vector2.new(0.5, 0.5)
    Bar.BackgroundColor3 = Theme.Elevated
    Bar.BorderSizePixel = 0
    Bar.Parent = SliderFrame
    
    AddCorner(Bar, 2)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Primary
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    
    AddCorner(Fill, 2)
    
    local Dragging = false
    
    function Slider:SetValue(value)
        value = math.clamp(value, self.Min, self.Max)
        self.Value = value
        
        local percent = (value - self.Min) / (self.Max - self.Min)
        Tween(Fill, Animations.Fast, {Size = UDim2.new(percent, 0, 1, 0)})
        ValueLabel.Text = tostring(math.floor(value))
        
        pcall(function() self.Callback(value) end)
    end
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local value = Slider.Min + (Slider.Max - Slider.Min) * pos
        Slider:SetValue(value)
    end
    
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Update(input)
        end
    end)
    
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    
    Slider:SetValue(Slider.Value)
    
    return Slider
end


-- ════════════════════════════════════════════════════════════════
-- DROPDOWN
-- ════════════════════════════════════════════════════════════════
function Library:CreateDropdown(tab, config)
    config = config or {}
    local parent = config.Parent or (config.Side == "Right" and tab.Sections.Right or tab.Sections.Left)
    
    local Dropdown = {
        Value = config.Default or (config.Options and config.Options[1]) or "None",
        Options = config.Options or {"Option 1", "Option 2"},
        Callback = config.Callback or function() end,
        Open = false
    }
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
    DropdownFrame.BackgroundColor3 = Theme.Card
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = false
    DropdownFrame.Parent = parent
    
    AddCorner(DropdownFrame, 8)
    
    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.Parent = DropdownFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.fromOffset(12, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Dropdown"
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Header
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.4, -32, 1, 0)
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = Dropdown.Value
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextSize = 11
    ValueLabel.TextColor3 = Theme.TextSecondary
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Header
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.fromOffset(20, 20)
    Arrow.Position = UDim2.new(1, -24, 0.5, 0)
    Arrow.AnchorPoint = Vector2.new(0, 0.5)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 10
    Arrow.TextColor3 = Theme.TextSecondary
    Arrow.Parent = Header
    
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 4)
    OptionsFrame.BackgroundColor3 = Theme.Surface
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Visible = false
    OptionsFrame.ZIndex = 10
    OptionsFrame.Parent = DropdownFrame
    
    AddCorner(OptionsFrame, 8)
    AddStroke(OptionsFrame, Theme.BorderLight, 1)
    
    local OptionsList = Instance.new("ScrollingFrame")
    OptionsList.Size = UDim2.new(1, 0, 1, 0)
    OptionsList.BackgroundTransparency = 1
    OptionsList.BorderSizePixel = 0
    OptionsList.ScrollBarThickness = 4
    OptionsList.ScrollBarImageColor3 = Theme.Primary
    OptionsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    OptionsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OptionsList.Parent = OptionsFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = OptionsList
    
    AddPadding(OptionsList, 4)
    
    function Dropdown:Refresh()
        OptionsList:ClearAllChildren()
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = OptionsList
        
        AddPadding(OptionsList, 4)
        
        for _, option in ipairs(self.Options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Size = UDim2.new(1, -8, 0, 28)
            OptionButton.BackgroundColor3 = Theme.Card
            OptionButton.BackgroundTransparency = self.Value == option and 0 or 1
            OptionButton.Text = option
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.TextSize = 11
            OptionButton.TextColor3 = self.Value == option and Theme.Primary or Theme.TextSecondary
            OptionButton.AutoButtonColor = false
            OptionButton.Parent = OptionsList
            
            AddCorner(OptionButton, 6)
            
            OptionButton.MouseButton1Click:Connect(function()
                self:SetValue(option)
                self:Toggle()
            end)
            
            OptionButton.MouseEnter:Connect(function()
                if self.Value ~= option then
                    Tween(OptionButton, Animations.Fast, {BackgroundTransparency = 0.5})
                end
            end)
            
            OptionButton.MouseLeave:Connect(function()
                if self.Value ~= option then
                    Tween(OptionButton, Animations.Fast, {BackgroundTransparency = 1})
                end
            end)
        end
    end
    
    function Dropdown:SetValue(value)
        self.Value = value
        ValueLabel.Text = value
        self:Refresh()
        pcall(function() self.Callback(value) end)
    end
    
    function Dropdown:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            local height = math.min(#self.Options * 28 + 8, 150)
            OptionsFrame.Visible = true
            Tween(OptionsFrame, Animations.Medium, {Size = UDim2.new(1, 0, 0, height)})
            Tween(Arrow, Animations.Fast, {Rotation = 180})
            Tween(DropdownFrame, Animations.Medium, {Size = UDim2.new(1, 0, 0, 36 + height + 4)})
        else
            Tween(OptionsFrame, Animations.Medium, {Size = UDim2.new(1, 0, 0, 0)})
            Tween(Arrow, Animations.Fast, {Rotation = 0})
            Tween(DropdownFrame, Animations.Medium, {Size = UDim2.new(1, 0, 0, 36)})
            task.wait(0.25)
            OptionsFrame.Visible = false
        end
    end
    
    Header.MouseButton1Click:Connect(function()
        Dropdown:Toggle()
    end)
    
    DropdownFrame.MouseEnter:Connect(function()
        Tween(DropdownFrame, Animations.Fast, {BackgroundColor3 = Theme.Elevated})
    end)
    
    DropdownFrame.MouseLeave:Connect(function()
        Tween(DropdownFrame, Animations.Fast, {BackgroundColor3 = Theme.Card})
    end)
    
    Dropdown:Refresh()
    
    return Dropdown
end

-- ════════════════════════════════════════════════════════════════
-- TEXTBOX
-- ════════════════════════════════════════════════════════════════
function Library:CreateTextbox(tab, config)
    config = config or {}
    local parent = config.Parent or (config.Side == "Right" and tab.Sections.Right or tab.Sections.Left)
    
    local Textbox = {
        Value = config.Default or "",
        Callback = config.Callback or function() end
    }
    
    local TextboxFrame = Instance.new("Frame")
    TextboxFrame.Size = UDim2.new(1, 0, 0, 60)
    TextboxFrame.BackgroundColor3 = Theme.Card
    TextboxFrame.BorderSizePixel = 0
    TextboxFrame.Parent = parent
    
    AddCorner(TextboxFrame, 8)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -24, 0, 20)
    Label.Position = UDim2.fromOffset(12, 8)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Textbox"
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TextboxFrame
    
    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -24, 0, 28)
    Input.Position = UDim2.fromOffset(12, 28)
    Input.BackgroundColor3 = Theme.Elevated
    Input.Text = Textbox.Value
    Input.PlaceholderText = config.Placeholder or "Enter text..."
    Input.Font = Enum.Font.Gotham
    Input.TextSize = 11
    Input.TextColor3 = Theme.Text
    Input.PlaceholderColor3 = Theme.TextTertiary
    Input.ClearTextOnFocus = false
    Input.Parent = TextboxFrame
    
    AddCorner(Input, 6)
    AddPadding(Input, 8)
    
    Input.Focused:Connect(function()
        Tween(Input, Animations.Fast, {BackgroundColor3 = Theme.Surface})
    end)
    
    Input.FocusLost:Connect(function()
        Tween(Input, Animations.Fast, {BackgroundColor3 = Theme.Elevated})
        Textbox.Value = Input.Text
        pcall(function() Textbox.Callback(Input.Text) end)
    end)
    
    function Textbox:SetValue(value)
        self.Value = value
        Input.Text = value
    end
    
    return Textbox
end

-- ════════════════════════════════════════════════════════════════
-- LABEL
-- ════════════════════════════════════════════════════════════════
function Library:CreateLabel(tab, config)
    config = config or {}
    local parent = config.Parent or (config.Side == "Right" and tab.Sections.Right or tab.Sections.Left)
    
    local LabelFrame = Instance.new("Frame")
    LabelFrame.Size = UDim2.new(1, 0, 0, 24)
    LabelFrame.BackgroundTransparency = 1
    LabelFrame.AutomaticSize = Enum.AutomaticSize.Y
    LabelFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -16, 0, 20)
    Label.Position = UDim2.fromOffset(8, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Text or "Label"
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextColor3 = Theme.TextSecondary
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.AutomaticSize = Enum.AutomaticSize.Y
    Label.Parent = LabelFrame
    
    return {
        SetText = function(_, text)
            Label.Text = text
        end
    }
end

-- ════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════════
function Library:Notify(config)
    config = config or {}
    
    local NotifGui = CoreGui:FindFirstChild("ModernNotifications")
    if not NotifGui then
        NotifGui = Instance.new("ScreenGui")
        NotifGui.Name = "ModernNotifications"
        NotifGui.ResetOnSpawn = false
        NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        NotifGui.Parent = CoreGui
        
        local Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.Size = UDim2.new(0, 300, 1, -20)
        Container.Position = UDim2.new(1, -310, 0, 10)
        Container.BackgroundTransparency = 1
        Container.Parent = NotifGui
        
        local Layout = Instance.new("UIListLayout")
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 8)
        Layout.Parent = Container
    end
    
    local Container = NotifGui.Container
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(1, 0, 0, 0)
    Notification.BackgroundColor3 = Theme.Surface
    Notification.BorderSizePixel = 0
    Notification.ClipsDescendants = true
    Notification.Parent = Container
    
    AddCorner(Notification, 8)
    AddStroke(Notification, Theme.Primary, 1)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 20)
    Title.Position = UDim2.fromOffset(12, 8)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Notification"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification
    
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -24, 0, 0)
    Message.Position = UDim2.fromOffset(12, 32)
    Message.BackgroundTransparency = 1
    Message.Text = config.Message or ""
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 11
    Message.TextColor3 = Theme.TextSecondary
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.TextWrapped = true
    Message.AutomaticSize = Enum.AutomaticSize.Y
    Message.Parent = Notification
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.fromOffset(20, 20)
    CloseBtn.Position = UDim2.new(1, -26, 0, 6)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.TextColor3 = Theme.TextSecondary
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Notification
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Notification, Animations.Fast, {Size = UDim2.new(1, 0, 0, 0)})
        task.wait(0.2)
        Notification:Destroy()
    end)
    
    Tween(Notification, Animations.Medium, {Size = UDim2.new(1, 0, 0, Message.AbsoluteSize.Y + 44)})
    
    local duration = config.Duration or 5
    task.delay(duration, function()
        if Notification and Notification.Parent then
            Tween(Notification, Animations.Fast, {Size = UDim2.new(1, 0, 0, 0)})
            task.wait(0.2)
            Notification:Destroy()
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- RETURN LIBRARY
-- ════════════════════════════════════════════════════════════════
return Library
