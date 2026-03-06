getgenv().GG = {
    Language = {
        CheckboxEnabled = "Enabled",
        CheckboxDisabled = "Disabled",
        SliderValue = "Value",
        DropdownSelect = "Select",
        DropdownNone = "None",
        DropdownSelected = "Selected",
        ButtonClick = "Click",
        TextboxEnter = "Enter",
        ModuleEnabled = "Enabled",
        ModuleDisabled = "Disabled",
        TabGeneral = "General",
        TabSettings = "Settings",
        Loading = "Loading...",
        Error = "Error",
        Success = "Success"
    }
}

-- =============================================
-- LINK DISCORD
-- =============================================
local DISCORD_LINK = "https://discord.gg/PNkYMTPq22"
-- =============================================

-- =============================================
-- THEME CONFIG — ubah warna di sini
-- =============================================
local Theme = {
    -- Background
    BG_Primary      = Color3.fromRGB(10, 11, 20),      -- layar utama
    BG_Secondary    = Color3.fromRGB(15, 17, 30),      -- modul/panel
    BG_Tertiary     = Color3.fromRGB(20, 23, 40),      -- elemen dalam

    -- Accent (neon blue-purple gradient)
    Accent          = Color3.fromRGB(80, 160, 255),
    AccentDark      = Color3.fromRGB(50, 100, 200),
    AccentGlow      = Color3.fromRGB(110, 180, 255),
    AccentPurple    = Color3.fromRGB(130, 100, 255),

    -- Stroke / divider
    StrokePrimary   = Color3.fromRGB(50, 80, 180),
    StrokeSubtle    = Color3.fromRGB(30, 40, 90),

    -- Text
    TextPrimary     = Color3.fromRGB(235, 245, 255),
    TextSecondary   = Color3.fromRGB(160, 195, 240),
    TextMuted       = Color3.fromRGB(90, 120, 170),

    -- Toggle
    ToggleOn        = Color3.fromRGB(80, 160, 255),
    ToggleOff       = Color3.fromRGB(25, 28, 55),

    -- Discord button
    Discord         = Color3.fromRGB(88, 101, 242),
    DiscordHover    = Color3.fromRGB(110, 125, 255),
}

local SelectedLanguage = GG.Language

-- =============================================
-- HELPERS
-- =============================================
function convertStringToTable(inputString)
    local result = {}
    for value in string.gmatch(inputString, "([^,]+)") do
        local trimmedValue = value:match("^%s*(.-)%s*$")
        table.insert(result, trimmedValue)
    end
    return result
end

function convertTableToString(inputTable)
    return table.concat(inputTable, ", ")
end

-- =============================================
-- SERVICES
-- =============================================
local UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider  = cloneref(game:GetService('ContentProvider'))
local TweenService     = cloneref(game:GetService('TweenService'))
local HttpService      = cloneref(game:GetService('HttpService'))
local TextService      = cloneref(game:GetService('TextService'))
local RunService       = cloneref(game:GetService('RunService'))
local Lighting         = cloneref(game:GetService('Lighting'))
local Players          = cloneref(game:GetService('Players'))
local CoreGui          = cloneref(game:GetService('CoreGui'))
local Debris           = cloneref(game:GetService('Debris'))

local mouse     = Players.LocalPlayer:GetMouse()
local old_March = CoreGui:FindFirstChild('March')
if old_March then Debris:AddItem(old_March, 0) end
if not isfolder("March") then makefolder("March") end

-- =============================================
-- TWEEN PRESETS
-- =============================================
local TI = {
    Fast   = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.45, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

-- =============================================
-- CONNECTIONS
-- =============================================
local Connections = setmetatable({
    disconnect = function(self, connection)
        if not self[connection] then return end
        self[connection]:Disconnect()
        self[connection] = nil
    end,
    disconnect_all = function(self)
        for _, value in self do
            if typeof(value) == 'function' then continue end
            value:Disconnect()
        end
    end
}, {})

-- =============================================
-- UTIL
-- =============================================
local Util = setmetatable({
    map = function(self, value, in_min, in_max, out_min, out_max)
        return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
    end,
    viewport_point_to_world = function(self, location, distance)
        local unit_ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
        return unit_ray.Origin + unit_ray.Direction * distance
    end,
    get_offset = function(self)
        local vp = workspace.CurrentCamera.ViewportSize.Y
        return self:map(vp, 0, 2560, 8, 56)
    end
}, {})

-- =============================================
-- ACRYLIC BLUR
-- =============================================
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(object)
    local self = setmetatable({ _object = object, _folder = nil, _frame = nil, _root = nil }, AcrylicBlur)
    self:setup()
    return self
end

function AcrylicBlur:create_folder()
    local old = workspace.CurrentCamera:FindFirstChild('AcrylicBlur')
    if old then Debris:AddItem(old, 0) end
    local folder = Instance.new('Folder')
    folder.Name   = 'AcrylicBlur'
    folder.Parent = workspace.CurrentCamera
    self._folder  = folder
end

function AcrylicBlur:create_depth_of_fields()
    local dof = Lighting:FindFirstChild('AcrylicBlur') or Instance.new('DepthOfFieldEffect')
    dof.FarIntensity   = 0
    dof.FocusDistance  = 0.05
    dof.InFocusRadius  = 0.1
    dof.NearIntensity  = 1
    dof.Name           = 'AcrylicBlur'
    dof.Parent         = Lighting
    for _, obj in Lighting:GetChildren() do
        if obj:IsA('DepthOfFieldEffect') and obj ~= dof then
            Connections[obj] = obj:GetPropertyChangedSignal('FarIntensity'):Connect(function() obj.FarIntensity = 0 end)
            obj.FarIntensity = 0
        end
    end
end

function AcrylicBlur:create_frame()
    local frame = Instance.new('Frame')
    frame.Size                = UDim2.new(1, 0, 1, 0)
    frame.Position            = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint         = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Parent              = self._object
    self._frame               = frame
end

function AcrylicBlur:create_root()
    local part = Instance.new('Part')
    part.Name         = 'Root'
    part.Color        = Color3.new(0,0,0)
    part.Material     = Enum.Material.Glass
    part.Size         = Vector3.new(1,1,0)
    part.Anchored     = true
    part.CanCollide   = false
    part.CanQuery     = false
    part.Locked       = true
    part.CastShadow   = false
    part.Transparency = 0.98
    part.Parent       = self._folder
    local sm = Instance.new('SpecialMesh')
    sm.MeshType  = Enum.MeshType.Brick
    sm.Offset    = Vector3.new(0, 0, -0.000001)
    sm.Parent    = part
    self._root   = part
end

function AcrylicBlur:setup()
    self:create_depth_of_fields()
    self:create_folder()
    self:create_root()
    self:create_frame()
    self:render(0.001)
    self:check_quality_level()
end

function AcrylicBlur:render(distance)
    local positions = { top_left = Vector2.new(), top_right = Vector2.new(), bottom_right = Vector2.new() }
    local function update_positions(size, position)
        positions.top_left     = position
        positions.top_right    = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end
    local function update()
        local tl = Util:viewport_point_to_world(positions.top_left,     distance)
        local tr = Util:viewport_point_to_world(positions.top_right,    distance)
        local br = Util:viewport_point_to_world(positions.bottom_right, distance)
        if not self._root then return end
        self._root.CFrame    = CFrame.fromMatrix((tl + br) / 2,
            workspace.CurrentCamera.CFrame.XVector,
            workspace.CurrentCamera.CFrame.YVector,
            workspace.CurrentCamera.CFrame.ZVector)
        self._root.Mesh.Scale = Vector3.new((tr - tl).Magnitude, (tr - br).Magnitude, 0)
    end
    local function on_change()
        local offset   = Util:get_offset()
        local size     = self._frame.AbsoluteSize     - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
        update_positions(size, position)
        task.spawn(update)
    end
    Connections['cframe_update']           = workspace.CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update)
    Connections['viewport_size_update']    = workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(update)
    Connections['field_of_view_update']    = workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(update)
    Connections['frame_absolute_position'] = self._frame:GetPropertyChangedSignal('AbsolutePosition'):Connect(on_change)
    Connections['frame_absolute_size']     = self._frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(on_change)
    task.spawn(update)
end

function AcrylicBlur:check_quality_level()
    local gs = UserSettings().GameSettings
    local ql = gs.SavedQualityLevel.Value
    if ql < 8 then self:change_visiblity(false) end
    Connections['quality_level'] = gs:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        self:change_visiblity(UserSettings().GameSettings.SavedQualityLevel.Value >= 8)
    end)
end

function AcrylicBlur:change_visiblity(state)
    self._root.Transparency = state and 0.98 or 1
end

-- =============================================
-- CONFIG
-- =============================================
local Config = setmetatable({
    save = function(self, file_name, config)
        local ok, err = pcall(function()
            writefile('March/' .. file_name .. '.json', HttpService:JSONEncode(config))
        end)
        if not ok then warn('failed to save config', err) end
    end,
    load = function(self, file_name, config)
        local ok, result = pcall(function()
            if not isfile('March/' .. file_name .. '.json') then
                self:save(file_name, config)
                return
            end
            local flags = readfile('March/' .. file_name .. '.json')
            if not flags then self:save(file_name, config) return end
            return HttpService:JSONDecode(flags)
        end)
        if not ok then warn('failed to load config', result) end
        if not result then result = { _flags = {}, _keybinds = {}, _library = {} } end
        return result
    end
}, {})

-- =============================================
-- NOTIFICATION SYSTEM (upgraded)
-- =============================================
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name             = "GGNotifications"
NotifGui.ResetOnSpawn     = false
NotifGui.IgnoreGuiInset   = true
NotifGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
NotifGui.Parent           = CoreGui

local NotifContainer = Instance.new("Frame")
NotifContainer.Name                = "Container"
NotifContainer.Size                = UDim2.new(0, 310, 1, 0)
NotifContainer.Position            = UDim2.new(1, -320, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ClipsDescendants    = false
NotifContainer.AutomaticSize       = Enum.AutomaticSize.None
NotifContainer.Parent              = NotifGui

local NotifList = Instance.new("UIListLayout")
NotifList.FillDirection        = Enum.FillDirection.Vertical
NotifList.VerticalAlignment    = Enum.VerticalAlignment.Bottom
NotifList.SortOrder            = Enum.SortOrder.LayoutOrder
NotifList.Padding              = UDim.new(0, 8)
NotifList.Parent               = NotifContainer

local UIPad = Instance.new("UIPadding")
UIPad.PaddingBottom = UDim.new(0, 14)
UIPad.PaddingRight  = UDim.new(0, 0)
UIPad.Parent        = NotifContainer

local notifIndex = 0

local function SendNotification(settings)
    notifIndex = notifIndex + 1
    local idx = notifIndex

    -- Outer wrapper (for layout)
    local Wrapper = Instance.new("Frame")
    Wrapper.Name                  = "Notif_" .. idx
    Wrapper.Size                  = UDim2.new(1, 0, 0, 0)
    Wrapper.BackgroundTransparency = 1
    Wrapper.AutomaticSize         = Enum.AutomaticSize.Y
    Wrapper.ClipsDescendants      = false
    Wrapper.LayoutOrder           = idx
    Wrapper.Parent                = NotifContainer

    -- Card
    local Card = Instance.new("Frame")
    Card.Name                  = "Card"
    Card.Size                  = UDim2.new(1, -4, 0, 70)
    Card.Position              = UDim2.new(0, 2, 0, 0)
    Card.BackgroundColor3      = Theme.BG_Secondary
    Card.BackgroundTransparency = 0
    Card.BorderSizePixel       = 0
    Card.AutomaticSize         = Enum.AutomaticSize.Y
    Card.ClipsDescendants      = true
    Card.Parent                = Wrapper

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent       = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color             = Theme.StrokePrimary
    CardStroke.Transparency      = 0.6
    CardStroke.ApplyStrokeMode   = Enum.ApplyStrokeMode.Border
    CardStroke.Thickness         = 1
    CardStroke.Parent            = Card

    -- Left accent bar
    local AccentBar = Instance.new("Frame")
    AccentBar.Name              = "AccentBar"
    AccentBar.Size              = UDim2.new(0, 3, 1, 0)
    AccentBar.Position          = UDim2.new(0, 0, 0, 0)
    AccentBar.BackgroundColor3  = Theme.Accent
    AccentBar.BorderSizePixel   = 0
    AccentBar.Parent            = Card

    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 3)
    AccentCorner.Parent       = AccentBar

    -- Gradient overlay
    local Grad = Instance.new("UIGradient")
    Grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentPurple),
    }
    Grad.Rotation = 90
    Grad.Parent   = AccentBar

    -- Content padding frame
    local Content = Instance.new("Frame")
    Content.Size                  = UDim2.new(1, -18, 1, 0)
    Content.Position              = UDim2.new(0, 14, 0, 0)
    Content.BackgroundTransparency = 1
    Content.AutomaticSize         = Enum.AutomaticSize.Y
    Content.Parent                = Card

    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingTop    = UDim.new(0, 10)
    ContentPad.PaddingBottom = UDim.new(0, 10)
    ContentPad.Parent        = Content

    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding   = UDim.new(0, 3)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent    = Content

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.FontFace         = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    TitleLbl.TextColor3       = Theme.TextPrimary
    TitleLbl.Text             = settings.title or "Notification"
    TitleLbl.TextSize         = 13
    TitleLbl.Size             = UDim2.new(1, 0, 0, 16)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextXAlignment   = Enum.TextXAlignment.Left
    TitleLbl.AutomaticSize    = Enum.AutomaticSize.Y
    TitleLbl.TextWrapped      = true
    TitleLbl.LayoutOrder      = 1
    TitleLbl.Parent           = Content

    local BodyLbl = Instance.new("TextLabel")
    BodyLbl.FontFace           = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    BodyLbl.TextColor3         = Theme.TextSecondary
    BodyLbl.Text               = settings.text or ""
    BodyLbl.TextSize           = 11
    BodyLbl.Size               = UDim2.new(1, 0, 0, 14)
    BodyLbl.BackgroundTransparency = 1
    BodyLbl.TextXAlignment     = Enum.TextXAlignment.Left
    BodyLbl.TextWrapped        = true
    BodyLbl.AutomaticSize      = Enum.AutomaticSize.Y
    BodyLbl.LayoutOrder        = 2
    BodyLbl.Parent             = Content

    -- Progress bar
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size              = UDim2.new(1, 0, 0, 2)
    ProgressBg.Position          = UDim2.new(0, 0, 1, -2)
    ProgressBg.BackgroundColor3  = Theme.StrokeSubtle
    ProgressBg.BorderSizePixel   = 0
    ProgressBg.Parent            = Card

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size             = UDim2.new(1, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Theme.Accent
    ProgressFill.BorderSizePixel  = 0
    ProgressFill.Parent           = ProgressBg

    local ProgGrad = Instance.new("UIGradient")
    ProgGrad.Color    = ColorSequence.new{ ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentPurple) }
    ProgGrad.Rotation = 0
    ProgGrad.Parent   = ProgressFill

    -- Slide in from right
    Card.Position = UDim2.new(1, 20, 0, 0)
    tween(Card, TI.Slow, { Position = UDim2.new(0, 2, 0, 0) })

    local duration = settings.duration or 5
    tween(ProgressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })

    task.delay(duration, function()
        tween(Card, TI.Medium, { Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1 })
        task.wait(0.4)
        Wrapper:Destroy()
    end)
end

Library = {}
Library.__index = Library

-- =============================================
-- LIBRARY
-- =============================================
local LibraryMeta = {
    _config          = Config:load(game.GameId),
    _choosing_keybind = false,
    _device          = nil,
    _ui_open         = true,
    _ui_scale        = 1,
    _ui_loaded       = false,
    _ui              = nil,
    _dragging        = false,
    _drag_start      = nil,
    _container_position = nil,
}
LibraryMeta.__index = LibraryMeta

function Library.new()
    local self = setmetatable({ _loaded = false, _tab = 0 }, LibraryMeta)
    self:create_ui()
    return self
end

Library.SendNotification = SendNotification

function LibraryMeta:get_screen_scale()
    self._ui_scale = workspace.CurrentCamera.ViewportSize.X / 1400
end

function LibraryMeta:get_device()
    local device = 'Unknown'
    if not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
        device = 'PC'
    elseif UserInputService.TouchEnabled then
        device = 'Mobile'
    elseif UserInputService.GamepadEnabled then
        device = 'Console'
    end
    self._device = device
end

function LibraryMeta:removed(action)
    self._ui.AncestryChanged:Once(action)
end

function LibraryMeta:flag_type(flag, flag_type)
    if not LibraryMeta._config._flags[flag] then return end
    return typeof(LibraryMeta._config._flags[flag]) == flag_type
end

function LibraryMeta:remove_table_value(__table, table_value)
    for index, value in __table do
        if value == table_value then table.remove(__table, index) end
    end
end

-- =============================================
-- CREATE UI
-- =============================================
function LibraryMeta:create_ui()
    local old_March = CoreGui:FindFirstChild('March')
    if old_March then Debris:AddItem(old_March, 0) end

    -- Root ScreenGui
    local March = Instance.new('ScreenGui')
    March.ResetOnSpawn  = false
    March.Name          = 'March'
    March.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    March.IgnoreGuiInset = true
    March.Parent        = CoreGui

    -- ── MAIN CONTAINER ──────────────────────────────────
    local Container = Instance.new('Frame')
    Container.ClipsDescendants    = true
    Container.AnchorPoint         = Vector2.new(0.5, 0.5)
    Container.Name                = 'Container'
    Container.BackgroundColor3    = Theme.BG_Primary
    Container.BackgroundTransparency = 0.04
    Container.Position            = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size                = UDim2.new(0, 0, 0, 0)
    Container.Active              = true
    Container.BorderSizePixel     = 0
    Container.Parent              = March

    local ContCorner = Instance.new('UICorner')
    ContCorner.CornerRadius = UDim.new(0, 12)
    ContCorner.Parent       = Container

    -- Subtle outer glow stroke
    local ContStroke = Instance.new('UIStroke')
    ContStroke.Color           = Theme.Accent
    ContStroke.Transparency    = 0.72
    ContStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ContStroke.Thickness       = 1.5
    ContStroke.Parent          = Container

    -- ── HANDLER (layout root) ───────────────────────────
    local Handler = Instance.new('Frame')
    Handler.BackgroundTransparency = 1
    Handler.Name            = 'Handler'
    Handler.Size            = UDim2.new(0, 720, 0, 520)
    Handler.BorderSizePixel = 0
    Handler.Parent          = Container

    -- ── SIDEBAR ─────────────────────────────────────────
    local Sidebar = Instance.new('Frame')
    Sidebar.Name                  = 'Sidebar'
    Sidebar.Size                  = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3      = Theme.BG_Secondary
    Sidebar.BackgroundTransparency = 0.02
    Sidebar.BorderSizePixel       = 0
    Sidebar.Parent                = Handler

    local SidebarCorner = Instance.new('UICorner')
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent       = Sidebar

    -- mask right side corners of sidebar
    local SidebarMask = Instance.new('Frame')
    SidebarMask.Size                  = UDim2.new(0, 12, 1, 0)
    SidebarMask.Position              = UDim2.new(1, -12, 0, 0)
    SidebarMask.BackgroundColor3      = Theme.BG_Secondary
    SidebarMask.BackgroundTransparency = 0.02
    SidebarMask.BorderSizePixel       = 0
    SidebarMask.Parent                = Sidebar

    -- Sidebar gradient overlay (top highlight)
    local SidebarGrad = Instance.new('UIGradient')
    SidebarGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(25, 30, 58)),
        ColorSequenceKeypoint.new(1,   Theme.BG_Secondary),
    }
    SidebarGrad.Rotation = 90
    SidebarGrad.Parent   = Sidebar

    -- Sidebar divider (right edge)
    local SideDivider = Instance.new('Frame')
    SideDivider.Name            = 'SideDivider'
    SideDivider.Size            = UDim2.new(0, 1, 1, 0)
    SideDivider.Position        = UDim2.new(1, 0, 0, 0)
    SideDivider.BackgroundColor3 = Theme.StrokePrimary
    SideDivider.BackgroundTransparency = 0.55
    SideDivider.BorderSizePixel = 0
    SideDivider.Parent          = Handler

    local SideDivGrad = Instance.new('UIGradient')
    SideDivGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0,   1),
        NumberSequenceKeypoint.new(0.2, 0),
        NumberSequenceKeypoint.new(0.8, 0),
        NumberSequenceKeypoint.new(1,   1),
    }
    SideDivGrad.Rotation = 90
    SideDivGrad.Parent   = SideDivider

    -- ── LOGO AREA ───────────────────────────────────────
    local LogoArea = Instance.new('Frame')
    LogoArea.Name                  = 'LogoArea'
    LogoArea.Size                  = UDim2.new(1, 0, 0, 52)
    LogoArea.BackgroundTransparency = 1
    LogoArea.BorderSizePixel       = 0
    LogoArea.Parent                = Sidebar

    local LogoIcon = Instance.new('ImageLabel')
    LogoIcon.Image               = 'rbxassetid://10734887784'
    LogoIcon.ImageColor3         = Theme.Accent
    LogoIcon.ScaleType           = Enum.ScaleType.Fit
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.AnchorPoint         = Vector2.new(0, 0.5)
    LogoIcon.Position            = UDim2.new(0, 14, 0.5, 0)
    LogoIcon.Size                = UDim2.new(0, 20, 0, 20)
    LogoIcon.BorderSizePixel     = 0
    LogoIcon.Parent              = LogoArea

    local LogoText = Instance.new('TextLabel')
    LogoText.FontFace        = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    LogoText.Text            = 'GG HUB'
    LogoText.TextColor3      = Theme.TextPrimary
    LogoText.TextSize        = 14
    LogoText.Size            = UDim2.new(0, 90, 0, 18)
    LogoText.AnchorPoint     = Vector2.new(0, 0.5)
    LogoText.Position        = UDim2.new(0, 40, 0.5, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.TextXAlignment  = Enum.TextXAlignment.Left
    LogoText.Parent          = LogoArea

    local LogoGrad = Instance.new('UIGradient')
    LogoGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.AccentGlow),
        ColorSequenceKeypoint.new(0.5, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentPurple),
    }
    LogoGrad.Rotation = 0
    LogoGrad.Parent   = LogoText

    -- Logo divider
    local LogoDivider = Instance.new('Frame')
    LogoDivider.Size              = UDim2.new(1, -20, 0, 1)
    LogoDivider.Position          = UDim2.new(0, 10, 1, -1)
    LogoDivider.BackgroundColor3  = Theme.StrokePrimary
    LogoDivider.BackgroundTransparency = 0.6
    LogoDivider.BorderSizePixel   = 0
    LogoDivider.Parent            = LogoArea

    local LogoDivGrad = Instance.new('UIGradient')
    LogoDivGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0),
        NumberSequenceKeypoint.new(0.8, 0),
        NumberSequenceKeypoint.new(1, 1),
    }
    LogoDivGrad.Rotation = 0
    LogoDivGrad.Parent   = LogoDivider

    -- Active indicator PIN
    local Pin = Instance.new('Frame')
    Pin.Name            = 'Pin'
    Pin.Size            = UDim2.new(0, 3, 0, 22)
    Pin.Position        = UDim2.new(0, 4, 0, 60)
    Pin.BackgroundColor3 = Theme.Accent
    Pin.BorderSizePixel = 0
    Pin.ZIndex          = 5
    Pin.Parent          = Sidebar

    local PinCorner = Instance.new('UICorner')
    PinCorner.CornerRadius = UDim.new(1, 0)
    PinCorner.Parent       = Pin

    local PinGrad = Instance.new('UIGradient')
    PinGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.AccentGlow),
        ColorSequenceKeypoint.new(1, Theme.AccentPurple),
    }
    PinGrad.Rotation = 90
    PinGrad.Parent   = Pin

    -- ── TABS (scrolling) ────────────────────────────────
    local Tabs = Instance.new('ScrollingFrame')
    Tabs.Name                    = 'Tabs'
    Tabs.ScrollBarImageTransparency = 1
    Tabs.ScrollBarThickness      = 0
    Tabs.Size                    = UDim2.new(1, -8, 0, 400)
    Tabs.Position                = UDim2.new(0, 4, 0, 54)
    Tabs.Selectable              = false
    Tabs.AutomaticCanvasSize     = Enum.AutomaticSize.XY
    Tabs.BackgroundTransparency  = 1
    Tabs.CanvasSize              = UDim2.new(0, 0, 0, 0)
    Tabs.BorderSizePixel         = 0
    Tabs.Parent                  = Sidebar

    local TabsLayout = Instance.new('UIListLayout')
    TabsLayout.Padding    = UDim.new(0, 3)
    TabsLayout.SortOrder  = Enum.SortOrder.LayoutOrder
    TabsLayout.Parent     = Tabs

    -- ── SECTIONS FOLDER ─────────────────────────────────
    local Sections = Instance.new('Folder')
    Sections.Name   = 'Sections'
    Sections.Parent = Handler

    -- ── MINIMIZE BUTTON ─────────────────────────────────
    local Minimize = Instance.new('TextButton')
    Minimize.Name                 = 'Minimize'
    Minimize.Text                 = ''
    Minimize.AutoButtonColor      = false
    Minimize.BackgroundTransparency = 1
    Minimize.Size                 = UDim2.new(0, 28, 0, 28)
    Minimize.Position             = UDim2.new(1, -38, 0, 10)
    Minimize.BorderSizePixel      = 0
    Minimize.Parent               = Handler

    local MinimizeBg = Instance.new('Frame')
    MinimizeBg.Size                  = UDim2.new(1, 0, 1, 0)
    MinimizeBg.BackgroundColor3      = Theme.BG_Tertiary
    MinimizeBg.BackgroundTransparency = 0.3
    MinimizeBg.BorderSizePixel       = 0
    MinimizeBg.Parent                = Minimize

    local MinBgCorner = Instance.new('UICorner')
    MinBgCorner.CornerRadius = UDim.new(0, 7)
    MinBgCorner.Parent       = MinimizeBg

    local MinStroke = Instance.new('UIStroke')
    MinStroke.Color           = Theme.StrokePrimary
    MinStroke.Transparency    = 0.6
    MinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MinStroke.Parent          = MinimizeBg

    local MinIcon = Instance.new('TextLabel')
    MinIcon.Text             = '—'
    MinIcon.TextColor3       = Theme.TextSecondary
    MinIcon.TextSize         = 13
    MinIcon.FontFace         = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    MinIcon.Size             = UDim2.new(1, 0, 1, 0)
    MinIcon.BackgroundTransparency = 1
    MinIcon.Parent           = Minimize

    Minimize.MouseEnter:Connect(function()
        tween(MinimizeBg, TI.Fast, { BackgroundTransparency = 0.1, BackgroundColor3 = Theme.BG_Tertiary })
        tween(MinIcon, TI.Fast, { TextColor3 = Theme.TextPrimary })
    end)
    Minimize.MouseLeave:Connect(function()
        tween(MinimizeBg, TI.Fast, { BackgroundTransparency = 0.3, BackgroundColor3 = Theme.BG_Tertiary })
        tween(MinIcon, TI.Fast, { TextColor3 = Theme.TextSecondary })
    end)

    -- ── DISCORD BUTTON ──────────────────────────────────
    local DiscordButton = Instance.new('TextButton')
    DiscordButton.Name                 = 'DiscordButton'
    DiscordButton.Size                 = UDim2.new(1, -16, 0, 30)
    DiscordButton.Position             = UDim2.new(0, 8, 1, -40)
    DiscordButton.AnchorPoint          = Vector2.new(0, 0)
    DiscordButton.BackgroundColor3     = Theme.Discord
    DiscordButton.BackgroundTransparency = 0.1
    DiscordButton.BorderSizePixel      = 0
    DiscordButton.Text                 = ''
    DiscordButton.AutoButtonColor      = false
    DiscordButton.ZIndex               = 5
    DiscordButton.Parent               = Sidebar

    local DiscordCorner = Instance.new('UICorner')
    DiscordCorner.CornerRadius = UDim.new(0, 7)
    DiscordCorner.Parent       = DiscordButton

    local DiscordStroke = Instance.new('UIStroke')
    DiscordStroke.Color           = Color3.fromRGB(120, 135, 255)
    DiscordStroke.Thickness       = 1
    DiscordStroke.Transparency    = 0.5
    DiscordStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    DiscordStroke.Parent          = DiscordButton

    local DiscordGrad = Instance.new('UIGradient')
    DiscordGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 115, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(68, 81, 200)),
    }
    DiscordGrad.Rotation = 90
    DiscordGrad.Parent   = DiscordButton

    local DiscordIcon = Instance.new('TextLabel')
    DiscordIcon.BackgroundTransparency = 1
    DiscordIcon.Size     = UDim2.new(0, 20, 1, 0)
    DiscordIcon.Position = UDim2.new(0, 8, 0, 0)
    DiscordIcon.Text     = '💬'
    DiscordIcon.TextSize = 14
    DiscordIcon.Font     = Enum.Font.SourceSans
    DiscordIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordIcon.ZIndex   = 6
    DiscordIcon.Parent   = DiscordButton

    local DiscordLabel = Instance.new('TextLabel')
    DiscordLabel.BackgroundTransparency = 1
    DiscordLabel.Size    = UDim2.new(1, -30, 1, 0)
    DiscordLabel.Position = UDim2.new(0, 30, 0, 0)
    DiscordLabel.Text    = 'Join Discord'
    DiscordLabel.TextSize = 11
    DiscordLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    DiscordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
    DiscordLabel.ZIndex  = 6
    DiscordLabel.Parent  = DiscordButton

    DiscordButton.MouseEnter:Connect(function()
        tween(DiscordButton, TI.Fast, { BackgroundColor3 = Theme.DiscordHover })
    end)
    DiscordButton.MouseLeave:Connect(function()
        tween(DiscordButton, TI.Fast, { BackgroundColor3 = Theme.Discord })
    end)
    DiscordButton.MouseButton1Down:Connect(function()
        tween(DiscordButton, TI.Fast, { BackgroundTransparency = 0.3 })
    end)
    DiscordButton.MouseButton1Up:Connect(function()
        tween(DiscordButton, TI.Fast, { BackgroundTransparency = 0.1 })
    end)
    DiscordButton.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
            SendNotification({ title = "Discord", text = "Link copied to clipboard!", duration = 3 })
        else
            SendNotification({ title = "Discord", text = "discord.gg/PNkYMTPq22", duration = 5 })
        end
    end)

    -- ── UISCALE ─────────────────────────────────────────
    local UIScale = Instance.new('UIScale')
    UIScale.Parent = Container

    self._ui = March

    -- ── DRAG ─────────────────────────────────────────────
    local function on_drag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging           = true
            self._drag_start         = input.Position
            self._container_position = Container.Position
            Connections['container_input_ended'] = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then return end
                Connections:disconnect('container_input_ended')
                self._dragging = false
            end)
        end
    end

    local function update_drag(input)
        local delta    = input.Position - self._drag_start
        local position = UDim2.new(
            self._container_position.X.Scale,
            self._container_position.X.Offset + delta.X,
            self._container_position.Y.Scale,
            self._container_position.Y.Offset + delta.Y
        )
        tween(Container, TI.Fast, { Position = position })
    end

    local function drag(input)
        if not self._dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update_drag(input)
        end
    end

    Connections['container_input_began'] = Container.InputBegan:Connect(on_drag)
    Connections['input_changed']         = UserInputService.InputChanged:Connect(drag)

    self:removed(function()
        self._ui = nil
        Connections:disconnect_all()
    end)

    -- ── INTERNAL METHODS ─────────────────────────────────
    function self:Update1Run(a)
        if a == "nil" then
            Container.BackgroundTransparency = 0.04
        else
            pcall(function() Container.BackgroundTransparency = tonumber(a) end)
        end
    end

    function self:UIVisiblity()
        March.Enabled = not March.Enabled
    end

    function self:change_visiblity(state)
        if state then
            tween(Container, TI.Slow, { Size = UDim2.fromOffset(720, 520) })
        else
            tween(Container, TI.Medium, { Size = UDim2.fromOffset(150, 48) })
        end
    end

    function self:load()
        local content = {}
        for _, object in March:GetDescendants() do
            if object:IsA('ImageLabel') then table.insert(content, object) end
        end
        ContentProvider:PreloadAsync(content)
        self:get_device()

        if self._device == 'Mobile' or self._device == 'Unknown' then
            self:get_screen_scale()
            UIScale.Scale = self._ui_scale
            Connections['ui_scale'] = workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
                self:get_screen_scale()
                UIScale.Scale = self._ui_scale
            end)
        end

        tween(Container, TI.Slow, { Size = UDim2.fromOffset(720, 520) })
        AcrylicBlur.new(Container)
        self._ui_loaded = true
    end

    -- ── UPDATE TABS ──────────────────────────────────────
    function self:update_tabs(tab)
        local firstTab = Tabs:FindFirstChild('Tab')
        local targetY  = 0

        for _, object in Tabs:GetChildren() do
            if object.Name ~= 'Tab' then continue end
            local isActive = (object == tab)

            if isActive then
                targetY = object.AbsolutePosition.Y - Tabs.AbsolutePosition.Y + object.AbsoluteSize.Y / 2

                tween(object, TI.Medium, { BackgroundTransparency = 0.78 })
                tween(object.TextLabel, TI.Medium, {
                    TextTransparency = 0,
                    TextColor3       = Theme.Accent,
                })
                tween(object.Icon, TI.Medium, {
                    ImageTransparency = 0,
                    ImageColor3       = Theme.Accent,
                })
            else
                tween(object, TI.Medium, { BackgroundTransparency = 1 })
                tween(object.TextLabel, TI.Medium, {
                    TextTransparency = 0.55,
                    TextColor3       = Theme.TextMuted,
                })
                tween(object.Icon, TI.Medium, {
                    ImageTransparency = 0.65,
                    ImageColor3       = Theme.TextMuted,
                })
            end
        end

        -- Move the pin
        tween(Pin, TI.Spring, {
            Position = UDim2.new(0, 4, 0, 60 + targetY - 11)
        })
    end

    function self:update_sections(left_section, right_section)
        for _, object in Sections:GetChildren() do
            object.Visible = (object == left_section or object == right_section)
        end
    end

    -- ── CREATE TAB ───────────────────────────────────────
    function self:create_tab(title, icon)
        local TabManager  = {}
        local LayoutOrderModule = 0

        local font_params   = Instance.new('GetTextBoundsParams')
        font_params.Text    = title
        font_params.Font    = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        font_params.Size    = 12
        font_params.Width   = 10000
        local font_size     = TextService:GetTextBoundsAsync(font_params)
        local first_tab     = not Tabs:FindFirstChild('Tab')

        -- Tab button
        local Tab = Instance.new('TextButton')
        Tab.FontFace         = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        Tab.TextColor3       = Color3.fromRGB(0,0,0)
        Tab.Text             = ''
        Tab.AutoButtonColor  = false
        Tab.BackgroundTransparency = 1
        Tab.Name             = 'Tab'
        Tab.Size             = UDim2.new(1, -4, 0, 36)
        Tab.BorderSizePixel  = 0
        Tab.BackgroundColor3 = Theme.BG_Tertiary
        Tab.Parent           = Tabs
        Tab.LayoutOrder      = self._tab

        local TabCorner = Instance.new('UICorner')
        TabCorner.CornerRadius = UDim.new(0, 7)
        TabCorner.Parent       = Tab

        local TabStroke = Instance.new('UIStroke')
        TabStroke.Color           = Theme.StrokePrimary
        TabStroke.Transparency    = 0.85
        TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TabStroke.Parent          = Tab

        local TabIcon = Instance.new('ImageLabel')
        TabIcon.ScaleType           = Enum.ScaleType.Fit
        TabIcon.ImageTransparency   = 0.65
        TabIcon.ImageColor3         = Theme.TextMuted
        TabIcon.AnchorPoint         = Vector2.new(0, 0.5)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Position            = UDim2.new(0, 12, 0.5, 0)
        TabIcon.Name                = 'Icon'
        TabIcon.Image               = icon
        TabIcon.Size                = UDim2.new(0, 13, 0, 13)
        TabIcon.BorderSizePixel     = 0
        TabIcon.Parent              = Tab

        local TextLabel = Instance.new('TextLabel')
        TextLabel.FontFace        = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextColor3      = Theme.TextMuted
        TextLabel.TextTransparency = 0.55
        TextLabel.Text            = title
        TextLabel.Size            = UDim2.new(0, font_size.X, 0, 14)
        TextLabel.AnchorPoint     = Vector2.new(0, 0.5)
        TextLabel.Position        = UDim2.new(0, 32, 0.5, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment  = Enum.TextXAlignment.Left
        TextLabel.BorderSizePixel = 0
        TextLabel.TextSize        = 12
        TextLabel.Parent          = Tab

        -- Hover effect
        Tab.MouseEnter:Connect(function()
            if Tab.BackgroundTransparency > 0.5 then
                tween(Tab, TI.Fast, { BackgroundTransparency = 0.88 })
            end
        end)
        Tab.MouseLeave:Connect(function()
            if Tab.BackgroundTransparency < 0.95 and Tab.BackgroundTransparency > 0.5 then
                tween(Tab, TI.Fast, { BackgroundTransparency = 1 })
            end
        end)

        -- Sections
        local function make_section(xPos)
            local Section = Instance.new('ScrollingFrame')
            Section.AutomaticCanvasSize      = Enum.AutomaticSize.XY
            Section.ScrollBarThickness       = 0
            Section.Size                     = UDim2.new(0, 255, 0, 468)
            Section.Selectable               = false
            Section.AnchorPoint              = Vector2.new(0, 0.5)
            Section.ScrollBarImageTransparency = 1
            Section.BackgroundTransparency   = 1
            Section.Position                 = UDim2.new(xPos, 8, 0.5, 0)
            Section.CanvasSize               = UDim2.new(0, 0, 0, 0)
            Section.Visible                  = false
            Section.BorderSizePixel          = 0
            Section.Parent                   = Sections

            local SLayout = Instance.new('UIListLayout')
            SLayout.Padding              = UDim.new(0, 8)
            SLayout.HorizontalAlignment  = Enum.HorizontalAlignment.Center
            SLayout.SortOrder            = Enum.SortOrder.LayoutOrder
            SLayout.Parent               = Section

            local SPad = Instance.new('UIPadding')
            SPad.PaddingTop  = UDim.new(0, 8)
            SPad.PaddingBottom = UDim.new(0, 8)
            SPad.Parent      = Section

            return Section
        end

        local LeftSection  = make_section(0.236)
        LeftSection.Name   = 'LeftSection'
        local RightSection = make_section(0.614)
        RightSection.Name  = 'RightSection'

        self._tab += 1

        if first_tab then
            self:update_tabs(Tab)
            self:update_sections(LeftSection, RightSection)
        end

        Tab.MouseButton1Click:Connect(function()
            self:update_tabs(Tab)
            self:update_sections(LeftSection, RightSection)
        end)

        -- ── CREATE MODULE ────────────────────────────────
        function TabManager:create_module(settings)
            local LOM = 0  -- layout order for module children
            local ModuleManager = { _state = false, _size = 0, _multiplier = 0 }

            settings.section = (settings.section == 'right') and RightSection or LeftSection

            -- Card
            local Module = Instance.new('Frame')
            Module.ClipsDescendants    = true
            Module.BorderColor3        = Color3.fromRGB(0,0,0)
            Module.BackgroundTransparency = 0
            Module.Name                = 'Module'
            Module.Size                = UDim2.new(0, 253, 0, 90)
            Module.BorderSizePixel     = 0
            Module.BackgroundColor3    = Theme.BG_Secondary
            Module.Parent              = settings.section

            local ModCorner = Instance.new('UICorner')
            ModCorner.CornerRadius = UDim.new(0, 8)
            ModCorner.Parent       = Module

            local ModStroke = Instance.new('UIStroke')
            ModStroke.Color           = Theme.StrokePrimary
            ModStroke.Transparency    = 0.62
            ModStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ModStroke.Parent          = Module

            local ModLayout = Instance.new('UIListLayout')
            ModLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ModLayout.Parent    = Module

            -- Header
            local Header = Instance.new('TextButton')
            Header.FontFace         = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            Header.TextColor3       = Color3.fromRGB(0,0,0)
            Header.Text             = ''
            Header.AutoButtonColor  = false
            Header.BackgroundColor3 = Theme.BG_Secondary
            Header.BackgroundTransparency = 0
            Header.Name             = 'Header'
            Header.Size             = UDim2.new(0, 253, 0, 90)
            Header.BorderSizePixel  = 0
            Header.Parent           = Module

            -- Subtle top gradient accent on header
            local HeaderGrad = Instance.new('UIGradient')
            HeaderGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 34, 64)),
                ColorSequenceKeypoint.new(1, Theme.BG_Secondary),
            }
            HeaderGrad.Rotation = 90
            HeaderGrad.Parent   = Header

            -- Module name
            local ModuleName = Instance.new('TextLabel')
            ModuleName.FontFace        = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            ModuleName.TextColor3      = Theme.TextPrimary
            ModuleName.TextTransparency = 0
            ModuleName.Name            = 'ModuleName'
            ModuleName.Size            = UDim2.new(0, 195, 0, 15)
            ModuleName.AnchorPoint     = Vector2.new(0, 0)
            ModuleName.Position        = UDim2.new(0, 14, 0, 14)
            ModuleName.BackgroundTransparency = 1
            ModuleName.TextXAlignment  = Enum.TextXAlignment.Left
            ModuleName.TextSize        = 13
            ModuleName.Parent          = Header

            if not settings.rich then
                ModuleName.Text = settings.title or "Module"
            else
                ModuleName.RichText = true
                ModuleName.Text     = settings.richtext or "<font color='rgb(80,160,255)'>GG</font> Hub"
            end

            -- Description
            local Description = Instance.new('TextLabel')
            Description.FontFace        = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            Description.TextColor3      = Theme.TextSecondary
            Description.TextTransparency = 0.1
            Description.Text            = settings.description or ""
            Description.Name            = 'Description'
            Description.Size            = UDim2.new(0, 195, 0, 12)
            Description.AnchorPoint     = Vector2.new(0, 0)
            Description.Position        = UDim2.new(0, 14, 0, 32)
            Description.BackgroundTransparency = 1
            Description.TextXAlignment  = Enum.TextXAlignment.Left
            Description.TextSize        = 10
            Description.Parent          = Header

            -- Toggle pill
            local Toggle = Instance.new('Frame')
            Toggle.Name             = 'Toggle'
            Toggle.Size             = UDim2.new(0, 28, 0, 14)
            Toggle.Position         = UDim2.new(1, -42, 0, 55)
            Toggle.BackgroundColor3 = Theme.ToggleOff
            Toggle.BackgroundTransparency = 0.3
            Toggle.BorderSizePixel  = 0
            Toggle.Parent           = Header

            local ToggleCorner = Instance.new('UICorner')
            ToggleCorner.CornerRadius = UDim.new(1, 0)
            ToggleCorner.Parent       = Toggle

            local ToggleStroke = Instance.new('UIStroke')
            ToggleStroke.Color           = Theme.StrokePrimary
            ToggleStroke.Transparency    = 0.5
            ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ToggleStroke.Parent          = Toggle

            local Circle = Instance.new('Frame')
            Circle.AnchorPoint      = Vector2.new(0, 0.5)
            Circle.Position         = UDim2.new(0, 2, 0.5, 0)
            Circle.Name             = 'Circle'
            Circle.Size             = UDim2.new(0, 10, 0, 10)
            Circle.BackgroundColor3 = Theme.TextMuted
            Circle.BorderSizePixel  = 0
            Circle.Parent           = Toggle

            local CircleCorner = Instance.new('UICorner')
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent       = Circle

            -- Keybind badge
            local Keybind = Instance.new('Frame')
            Keybind.Name             = 'Keybind'
            Keybind.Size             = UDim2.new(0, 32, 0, 14)
            Keybind.Position         = UDim2.new(0, 14, 0, 58)
            Keybind.BackgroundColor3 = Theme.Accent
            Keybind.BackgroundTransparency = 0.6
            Keybind.BorderSizePixel  = 0
            Keybind.Parent           = Header

            local KBCorner = Instance.new('UICorner')
            KBCorner.CornerRadius = UDim.new(0, 4)
            KBCorner.Parent       = Keybind

            local KBStroke = Instance.new('UIStroke')
            KBStroke.Color           = Theme.Accent
            KBStroke.Transparency    = 0.5
            KBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            KBStroke.Parent          = Keybind

            local KBLabel = Instance.new('TextLabel')
            KBLabel.FontFace        = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            KBLabel.TextColor3      = Theme.TextPrimary
            KBLabel.Text            = 'None'
            KBLabel.AnchorPoint     = Vector2.new(0.5, 0.5)
            KBLabel.Size            = UDim2.new(1, -4, 1, 0)
            KBLabel.BackgroundTransparency = 1
            KBLabel.Position        = UDim2.new(0.5, 0, 0.5, 0)
            KBLabel.TextSize        = 9
            KBLabel.Parent          = Keybind

            -- Bottom divider inside header
            local HDivider = Instance.new('Frame')
            HDivider.AnchorPoint        = Vector2.new(0.5, 0)
            HDivider.Position           = UDim2.new(0.5, 0, 1, -1)
            HDivider.Size               = UDim2.new(1, -16, 0, 1)
            HDivider.BackgroundColor3   = Theme.StrokePrimary
            HDivider.BackgroundTransparency = 0.5
            HDivider.BorderSizePixel    = 0
            HDivider.Name               = 'Divider'
            HDivider.Parent             = Header

            local HDivGrad = Instance.new('UIGradient')
            HDivGrad.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.2, 0),
                NumberSequenceKeypoint.new(0.8, 0),
                NumberSequenceKeypoint.new(1, 1),
            }
            HDivGrad.Rotation = 0
            HDivGrad.Parent   = HDivider

            -- Status icon (bottom left of header)
            local StatusIcon = Instance.new('ImageLabel')
            StatusIcon.ImageColor3         = Theme.Accent
            StatusIcon.ScaleType           = Enum.ScaleType.Fit
            StatusIcon.ImageTransparency   = 0.5
            StatusIcon.AnchorPoint         = Vector2.new(0, 0.5)
            StatusIcon.Image               = 'rbxassetid://79095934438045'
            StatusIcon.BackgroundTransparency = 1
            StatusIcon.Position            = UDim2.new(0, 14, 0, 72)
            StatusIcon.Name                = 'Icon'
            StatusIcon.Size                = UDim2.new(0, 13, 0, 13)
            StatusIcon.BorderSizePixel     = 0
            StatusIcon.Parent              = Header

            -- Options container
            local Options = Instance.new('Frame')
            Options.Name               = 'Options'
            Options.BackgroundTransparency = 1
            Options.Position           = UDim2.new(0, 0, 1, 0)
            Options.Size               = UDim2.new(0, 253, 0, 0)
            Options.BorderSizePixel    = 0
            Options.Parent             = Module

            local OptPad = Instance.new('UIPadding')
            OptPad.PaddingTop    = UDim.new(0, 8)
            OptPad.PaddingBottom = UDim.new(0, 8)
            OptPad.Parent        = Options

            local OptLayout = Instance.new('UIListLayout')
            OptLayout.Padding             = UDim.new(0, 5)
            OptLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            OptLayout.SortOrder           = Enum.SortOrder.LayoutOrder
            OptLayout.Parent              = Options

            -- Hover glow on module
            Header.MouseEnter:Connect(function()
                tween(ModStroke, TI.Fast, { Transparency = 0.35 })
            end)
            Header.MouseLeave:Connect(function()
                tween(ModStroke, TI.Fast, { Transparency = 0.62 })
            end)

            -- ── MODULE MANAGER METHODS ───────────────────
            function ModuleManager:change_state(state)
                self._state = state
                if self._state then
                    tween(Module, TI.Medium, { Size = UDim2.fromOffset(253, 90 + self._size + self._multiplier) })
                    tween(Toggle, TI.Medium, { BackgroundColor3 = Theme.ToggleOn, BackgroundTransparency = 0 })
                    tween(Circle, TI.Spring, { BackgroundColor3 = Color3.fromRGB(255,255,255), Position = UDim2.new(1, -12, 0.5, 0) })
                    tween(StatusIcon, TI.Medium, { ImageTransparency = 0, ImageColor3 = Theme.Accent })
                    tween(ToggleStroke, TI.Medium, { Transparency = 0.8 })
                else
                    tween(Module, TI.Medium, { Size = UDim2.fromOffset(253, 90) })
                    tween(Toggle, TI.Medium, { BackgroundColor3 = Theme.ToggleOff, BackgroundTransparency = 0.3 })
                    tween(Circle, TI.Spring, { BackgroundColor3 = Theme.TextMuted, Position = UDim2.new(0, 2, 0.5, 0) })
                    tween(StatusIcon, TI.Medium, { ImageTransparency = 0.5, ImageColor3 = Theme.Accent })
                    tween(ToggleStroke, TI.Medium, { Transparency = 0.5 })
                end
                LibraryMeta._config._flags[settings.flag] = self._state
                Config:save(game.GameId, LibraryMeta._config)
                settings.callback(self._state)
            end

            function ModuleManager:connect_keybind()
                if not LibraryMeta._config._keybinds[settings.flag] then return end
                Connections[settings.flag..'_keybind'] = UserInputService.InputBegan:Connect(function(input, process)
                    if process then return end
                    if tostring(input.KeyCode) ~= LibraryMeta._config._keybinds[settings.flag] then return end
                    self:change_state(not self._state)
                end)
            end

            function ModuleManager:scale_keybind(empty)
                if LibraryMeta._config._keybinds[settings.flag] and not empty then
                    local ks = string.gsub(tostring(LibraryMeta._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                    local fp = Instance.new('GetTextBoundsParams')
                    fp.Text  = ks
                    fp.Font  = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold)
                    fp.Size  = 9
                    fp.Width = 10000
                    local fs = TextService:GetTextBoundsAsync(fp)
                    Keybind.Size = UDim2.fromOffset(fs.X + 8, 14)
                    KBLabel.Size = UDim2.new(1, -4, 1, 0)
                else
                    Keybind.Size = UDim2.fromOffset(32, 14)
                end
            end

            if LibraryMeta:flag_type(settings.flag, 'boolean') then
                ModuleManager._state = true
                settings.callback(ModuleManager._state)
                Toggle.BackgroundColor3     = Theme.ToggleOn
                Toggle.BackgroundTransparency = 0
                Circle.BackgroundColor3     = Color3.fromRGB(255,255,255)
                Circle.Position             = UDim2.new(1, -12, 0.5, 0)
                StatusIcon.ImageTransparency = 0
            end

            if LibraryMeta._config._keybinds[settings.flag] then
                KBLabel.Text = string.gsub(tostring(LibraryMeta._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                ModuleManager:connect_keybind()
                ModuleManager:scale_keybind()
            end

            -- Middle-click keybind selection
            Connections[settings.flag..'_input_began'] = Header.InputBegan:Connect(function(input)
                if LibraryMeta._choosing_keybind then return end
                if input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                LibraryMeta._choosing_keybind = true
                KBLabel.Text = '...'

                Connections['keybind_choose_start'] = UserInputService.InputBegan:Connect(function(input, process)
                    if process then return end
                    if input.KeyCode == Enum.KeyCode.Unknown then return end
                    if input.KeyCode == Enum.KeyCode.Backspace then
                        ModuleManager:scale_keybind(true)
                        LibraryMeta._config._keybinds[settings.flag] = nil
                        Config:save(game.GameId, LibraryMeta._config)
                        KBLabel.Text = 'None'
                        if Connections[settings.flag..'_keybind'] then
                            Connections[settings.flag..'_keybind']:Disconnect()
                            Connections[settings.flag..'_keybind'] = nil
                        end
                        Connections['keybind_choose_start']:Disconnect()
                        Connections['keybind_choose_start'] = nil
                        LibraryMeta._choosing_keybind = false
                        return
                    end
                    Connections['keybind_choose_start']:Disconnect()
                    Connections['keybind_choose_start'] = nil
                    LibraryMeta._config._keybinds[settings.flag] = tostring(input.KeyCode)
                    Config:save(game.GameId, LibraryMeta._config)
                    if Connections[settings.flag..'_keybind'] then
                        Connections[settings.flag..'_keybind']:Disconnect()
                        Connections[settings.flag..'_keybind'] = nil
                    end
                    ModuleManager:connect_keybind()
                    ModuleManager:scale_keybind()
                    LibraryMeta._choosing_keybind = false
                    KBLabel.Text = string.gsub(tostring(LibraryMeta._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                end)
            end)

            Header.MouseButton1Click:Connect(function()
                ModuleManager:change_state(not ModuleManager._state)
            end)

            -- ── PARAGRAPH ────────────────────────────────
            function ModuleManager:create_paragraph(settings)
                LOM += 1
                local ParagraphManager = {}
                if self._size == 0 then self._size = 8 end
                self._size += settings.customScale or 72
                if ModuleManager._state then Module.Size = UDim2.fromOffset(253, 90 + self._size) end
                Options.Size = UDim2.fromOffset(253, self._size)

                local Para = Instance.new('Frame')
                Para.BackgroundColor3      = Theme.BG_Tertiary
                Para.BackgroundTransparency = 0.1
                Para.Size                  = UDim2.new(0, 221, 0, 32)
                Para.BorderSizePixel       = 0
                Para.AutomaticSize         = Enum.AutomaticSize.Y
                Para.LayoutOrder           = LOM
                Para.Parent                = Options

                local ParaCorner = Instance.new('UICorner')
                ParaCorner.CornerRadius = UDim.new(0, 6)
                ParaCorner.Parent       = Para

                local ParaStroke = Instance.new('UIStroke')
                ParaStroke.Color           = Theme.StrokeSubtle
                ParaStroke.Transparency    = 0.3
                ParaStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ParaStroke.Parent          = Para

                local ParaPad = Instance.new('UIPadding')
                ParaPad.PaddingTop    = UDim.new(0, 8)
                ParaPad.PaddingBottom = UDim.new(0, 8)
                ParaPad.PaddingLeft   = UDim.new(0, 10)
                ParaPad.PaddingRight  = UDim.new(0, 10)
                ParaPad.Parent        = Para

                local ParaLayout = Instance.new('UIListLayout')
                ParaLayout.Padding   = UDim.new(0, 4)
                ParaLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ParaLayout.Parent    = Para

                local PTitleLbl = Instance.new('TextLabel')
                PTitleLbl.FontFace   = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                PTitleLbl.TextColor3 = Theme.TextPrimary
                PTitleLbl.Text       = settings.title or "Title"
                PTitleLbl.TextSize   = 12
                PTitleLbl.Size       = UDim2.new(1, 0, 0, 14)
                PTitleLbl.BackgroundTransparency = 1
                PTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                PTitleLbl.AutomaticSize = Enum.AutomaticSize.Y
                PTitleLbl.TextWrapped = true
                PTitleLbl.LayoutOrder = 1
                PTitleLbl.Parent     = Para

                local PBodyLbl = Instance.new('TextLabel')
                PBodyLbl.FontFace   = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                PBodyLbl.TextColor3 = Theme.TextSecondary
                PBodyLbl.TextSize   = 10
                PBodyLbl.Size       = UDim2.new(1, 0, 0, 14)
                PBodyLbl.BackgroundTransparency = 1
                PBodyLbl.TextXAlignment = Enum.TextXAlignment.Left
                PBodyLbl.TextWrapped = true
                PBodyLbl.AutomaticSize = Enum.AutomaticSize.Y
                PBodyLbl.LayoutOrder = 2
                PBodyLbl.Parent     = Para

                if not settings.rich then
                    PBodyLbl.Text = settings.text or ""
                else
                    PBodyLbl.RichText = true
                    PBodyLbl.Text     = settings.richtext or ""
                end

                Para.MouseEnter:Connect(function()
                    tween(Para, TI.Fast, { BackgroundColor3 = Color3.fromRGB(30, 37, 70) })
                end)
                Para.MouseLeave:Connect(function()
                    tween(Para, TI.Fast, { BackgroundColor3 = Theme.BG_Tertiary })
                end)

                return ParagraphManager
            end

            -- ── TEXT ─────────────────────────────────────
            function ModuleManager:create_text(settings)
                LOM += 1
                local TextManager = {}
                if self._size == 0 then self._size = 8 end
                self._size += settings.customScale or 40
                if ModuleManager._state then Module.Size = UDim2.fromOffset(253, 90 + self._size) end
                Options.Size = UDim2.fromOffset(253, self._size)

                local TF = Instance.new('Frame')
                TF.BackgroundColor3      = Theme.BG_Tertiary
                TF.BackgroundTransparency = 0.1
                TF.Size                  = UDim2.new(0, 221, 0, settings.CustomYSize or 28)
                TF.BorderSizePixel       = 0
                TF.AutomaticSize         = Enum.AutomaticSize.Y
                TF.LayoutOrder           = LOM
                TF.Parent                = Options

                local TFCorner = Instance.new('UICorner')
                TFCorner.CornerRadius = UDim.new(0, 6)
                TFCorner.Parent       = TF

                local TFPad = Instance.new('UIPadding')
                TFPad.PaddingTop   = UDim.new(0, 6)
                TFPad.PaddingBottom = UDim.new(0, 6)
                TFPad.PaddingLeft  = UDim.new(0, 10)
                TFPad.PaddingRight = UDim.new(0, 10)
                TFPad.Parent       = TF

                local TFBody = Instance.new('TextLabel')
                TFBody.FontFace   = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                TFBody.TextColor3 = Theme.TextSecondary
                TFBody.TextSize   = 10
                TFBody.Size       = UDim2.new(1, 0, 1, 0)
                TFBody.BackgroundTransparency = 1
                TFBody.TextXAlignment = Enum.TextXAlignment.Left
                TFBody.TextYAlignment = Enum.TextYAlignment.Top
                TFBody.TextWrapped = true
                TFBody.AutomaticSize = Enum.AutomaticSize.Y
                TFBody.Parent      = TF

                if not settings.rich then
                    TFBody.Text = settings.text or ""
                else
                    TFBody.RichText = true
                    TFBody.Text     = settings.richtext or ""
                end

                function TextManager:Set(ns)
                    if not ns.rich then
                        TFBody.Text = ns.text or ""
                    else
                        TFBody.RichText = true
                        TFBody.Text     = ns.richtext or ""
                    end
                end

                return TextManager
            end

            -- ── TEXTBOX ──────────────────────────────────
            function ModuleManager:create_textbox(settings)
                LOM += 1
                local TextboxManager = { _text = "" }
                if self._size == 0 then self._size = 8 end
                self._size += 34
                if ModuleManager._state then Module.Size = UDim2.fromOffset(253, 90 + self._size) end
                Options.Size = UDim2.fromOffset(253, self._size)

                local TBWrap = Instance.new('Frame')
                TBWrap.BackgroundTransparency = 1
                TBWrap.Size      = UDim2.new(0, 221, 0, 30)
                TBWrap.LayoutOrder = LOM
                TBWrap.Parent    = Options

                local TBLayout = Instance.new('UIListLayout')
                TBLayout.Padding   = UDim.new(0, 3)
                TBLayout.SortOrder = Enum.SortOrder.LayoutOrder
                TBLayout.Parent    = TBWrap

                local TBTitle = Instance.new('TextLabel')
                TBTitle.FontFace  = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                TBTitle.TextColor3 = Theme.TextSecondary
                TBTitle.Text      = settings.title or "Enter text"
                TBTitle.TextSize  = 9
                TBTitle.Size      = UDim2.new(1, 0, 0, 11)
                TBTitle.BackgroundTransparency = 1
                TBTitle.TextXAlignment = Enum.TextXAlignment.Left
                TBTitle.LayoutOrder = 1
                TBTitle.Parent    = TBWrap

                local Textbox = Instance.new('TextBox')
                Textbox.FontFace  = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Textbox.TextColor3 = Theme.TextPrimary
                Textbox.PlaceholderText = settings.placeholder or "Type here..."
                Textbox.PlaceholderColor3 = Theme.TextMuted
                Textbox.Text      = LibraryMeta._config._flags[settings.flag] or ""
                Textbox.Name      = 'Textbox'
                Textbox.Size      = UDim2.new(1, 0, 0, 18)
                Textbox.BorderSizePixel = 0
                Textbox.TextSize  = 10
                Textbox.BackgroundColor3 = Theme.BG_Tertiary
                Textbox.BackgroundTransparency = 0
                Textbox.ClearTextOnFocus = false
                Textbox.TextXAlignment   = Enum.TextXAlignment.Left
                Textbox.LayoutOrder      = 2
                Textbox.Parent           = TBWrap

                local TBCorner = Instance.new('UICorner')
                TBCorner.CornerRadius = UDim.new(0, 5)
                TBCorner.Parent       = Textbox

                local TBStroke = Instance.new('UIStroke')
                TBStroke.Color           = Theme.StrokePrimary
                TBStroke.Transparency    = 0.6
                TBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                TBStroke.Parent          = Textbox

                local TBPad = Instance.new('UIPadding')
                TBPad.PaddingLeft  = UDim.new(0, 7)
                TBPad.PaddingRight = UDim.new(0, 7)
                TBPad.Parent       = Textbox

                Textbox.Focused:Connect(function()
                    tween(TBStroke, TI.Fast, { Transparency = 0.1, Color = Theme.Accent })
                end)
                Textbox.FocusLost:Connect(function()
                    tween(TBStroke, TI.Fast, { Transparency = 0.6, Color = Theme.StrokePrimary })
                    TextboxManager._text = Textbox.Text
                    LibraryMeta._config._flags[settings.flag] = TextboxManager._text
                    Config:save(game.GameId, LibraryMeta._config)
                    settings.callback(TextboxManager._text)
                end)

                if LibraryMeta:flag_type(settings.flag, 'string') then
                    TextboxManager._text = LibraryMeta._config._flags[settings.flag]
                    LibraryMeta._config._flags[settings.flag] = TextboxManager._text
                    Config:save(game.GameId, LibraryMeta._config)
                    settings.callback(TextboxManager._text)
                end

                return TextboxManager
            end

            -- ── CHECKBOX ─────────────────────────────────
            function ModuleManager:create_checkbox(settings)
                LOM += 1
                local CheckboxManager = { _state = false }
                if self._size == 0 then self._size = 8 end
                self._size += 22
                if ModuleManager._state then Module.Size = UDim2.fromOffset(253, 90 + self._size) end
                Options.Size = UDim2.fromOffset(253, self._size)

                local CB = Instance.new("TextButton")
                CB.AutoButtonColor      = false
                CB.BackgroundTransparency = 1
                CB.Name                 = "Checkbox"
                CB.Size                 = UDim2.new(0, 221, 0, 17)
                CB.BorderSizePixel      = 0
                CB.LayoutOrder          = LOM
                CB.Parent               = Options

                local CBTitle = Instance.new("TextLabel")
                CBTitle.FontFace         = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                CBTitle.TextColor3       = Theme.TextPrimary
                CBTitle.TextTransparency = 0.05
                CBTitle.Text             = settings.title or "Option"
                CBTitle.TextSize         = 11
                CBTitle.Size             = UDim2.new(1, -55, 0, 14)
                CBTitle.AnchorPoint      = Vector2.new(0, 0.5)
                CBTitle.Position         = UDim2.new(0, 0, 0.5, 0)
                CBTitle.BackgroundTransparency = 1
                CBTitle.TextXAlignment   = Enum.TextXAlignment.Left
                CBTitle.Parent           = CB

                -- Keybind badge
                local CBKeyBox = Instance.new("Frame")
                CBKeyBox.Size             = UDim2.fromOffset(16, 14)
                CBKeyBox.Position         = UDim2.new(1, -35, 0.5, 0)
                CBKeyBox.AnchorPoint      = Vector2.new(0, 0.5)
                CBKeyBox.BackgroundColor3 = Theme.Accent
                CBKeyBox.BackgroundTransparency = 0.4
                CBKeyBox.BorderSizePixel  = 0
                CBKeyBox.Parent           = CB

                local CBKeyCorner = Instance.new("UICorner")
                CBKeyCorner.CornerRadius = UDim.new(0, 4)
                CBKeyCorner.Parent       = CBKeyBox

                local CBKeyStroke = Instance.new("UIStroke")
                CBKeyStroke.Color           = Theme.Accent
                CBKeyStroke.Transparency    = 0.5
                CBKeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                CBKeyStroke.Parent          = CBKeyBox

                local CBKeyLabel = Instance.new("TextLabel")
                CBKeyLabel.Size                  = UDim2.new(1, 0, 1, 0)
                CBKeyLabel.BackgroundTransparency = 1
                CBKeyLabel.TextColor3            = Theme.TextPrimary
                CBKeyLabel.TextSize              = 8
                CBKeyLabel.FontFace              = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold)
                CBKeyLabel.Text                  = LibraryMeta._config._keybinds[settings.flag]
                    and string.gsub(tostring(LibraryMeta._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                    or "..."
                CBKeyLabel.Parent = CBKeyBox

                -- Checkbox box
                local Box = Instance.new("Frame")
                Box.AnchorPoint      = Vector2.new(1, 0.5)
                Box.BackgroundColor3 = Theme.Accent
                Box.BackgroundTransparency = 0.88
                Box.Position         = UDim2.new(1, 0, 0.5, 0)
                Box.Size             = UDim2.new(0, 15, 0, 15)
                Box.BorderSizePixel  = 0
                Box.Parent           = CB

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 4)
                BoxCorner.Parent       = Box

                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color           = Theme.Accent
                BoxStroke.Transparency    = 0.5
                BoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                BoxStroke.Parent          = Box

                local Fill = Instance.new("Frame")
                Fill.AnchorPoint      = Vector2.new(0.5, 0.5)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.BackgroundTransparency = 0
                Fill.Position         = UDim2.new(0.5, 0, 0.5, 0)
                Fill.Size             = UDim2.fromOffset(0, 0)
                Fill.BorderSizePixel  = 0
                Fill.Parent           = Box

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 3)
                FillCorner.Parent       = Fill

                function CheckboxManager:change_state(state)
                    self._state = state
                    if self._state then
                        tween(Box,  TI.Medium, { BackgroundTransparency = 0.6 })
                        tween(Fill, TI.Spring, { Size = UDim2.fromOffset(9, 9) })
                        tween(CBTitle, TI.Fast, { TextColor3 = Theme.AccentGlow })
                    else
                        tween(Box,  TI.Medium, { BackgroundTransparency = 0.88 })
                        tween(Fill, TI.Spring, { Size = UDim2.fromOffset(0, 0) })
                        tween(CBTitle, TI.Fast, { TextColor3 = Theme.TextPrimary })
                    end
                    LibraryMeta._config._flags[settings.flag] = self._state
                    Config:save(game.GameId, LibraryMeta._config)
                    settings.callback(self._state)
                end

                if LibraryMeta:flag_type(settings.flag, "boolean") then
                    CheckboxManager:change_state(LibraryMeta._config._flags[settings.flag])
                end

                CB.MouseButton1Click:Connect(function()
                    CheckboxManager:change_state(not CheckboxManager._state)
                end)

                -- Keybind via middle-click
                CB.InputBegan:Connect(function(input, gp)
                    if gp or input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                    if LibraryMeta._choosing_keybind then return end
                    LibraryMeta._choosing_keybind = true
                    CBKeyLabel.Text = "..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(ki, kp)
                        if kp or ki.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if ki.KeyCode == Enum.KeyCode.Unknown then return end
                        if ki.KeyCode == Enum.KeyCode.Backspace then
                            LibraryMeta._config._keybinds[settings.flag] = nil
                            Config:save(game.GameId, LibraryMeta._config)
                            CBKeyLabel.Text = "..."
                            if Connections[settings.flag.."_keybind"] then Connections[settings.flag.."_keybind"]:Disconnect() Connections[settings.flag.."_keybind"] = nil end
                            conn:Disconnect(); LibraryMeta._choosing_keybind = false; return
                        end
                        conn:Disconnect()
                        LibraryMeta._config._keybinds[settings.flag] = tostring(ki.KeyCode)
                        Config:save(game.GameId, LibraryMeta._config)
                        if Connections[settings.flag.."_keybind"] then Connections[settings.flag.."_keybind"]:Disconnect() Connections[settings.flag.."_keybind"] = nil end
                        ModuleManager:connect_keybind(); ModuleManager:scale_keybind(); LibraryMeta._choosing_keybind = false
                        CBKeyLabel.Text = string.gsub(tostring(LibraryMeta._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                    end)
                end)

                Connections[settings.flag.."_keypress"] = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    local sk = LibraryMeta._config._keybinds[settings.flag]
                    if sk and tostring(input.KeyCode) == sk then CheckboxManager:change_state(not CheckboxManager._state) end
                end)

                return CheckboxManager
            end

            -- ── DIVIDER ──────────────────────────────────
            function ModuleManager:create_divider(settings)
                LOM += 1
                if self._size == 0 then self._size = 8 end
                self._size += 20
                if ModuleManager._state then Module.Size = UDim2.fromOffset(253, 90 + self._size) end

                local Outer = Instance.new('Frame')
                Outer.Size                  = UDim2.new(0, 221, 0, 18)
                Outer.BackgroundTransparency = 1
                Outer.LayoutOrder           = LOM
                Outer.Parent                = Options

                if settings and settings.showtopic then
                    local TopicLbl = Instance.new('TextLabel')
                    TopicLbl.FontFace   = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TopicLbl.TextColor3 = Theme.TextSecondary
                    TopicLbl.Text       = settings.title or ""
                    TopicLbl.TextSize   = 9
                    TopicLbl.Size       = UDim2.new(0, 120, 0, 12)
                    TopicLbl.AnchorPoint = Vector2.new(0.5, 0.5)
                    TopicLbl.Position   = UDim2.new(0.5, 0, 0.5, 0)
                    TopicLbl.BackgroundColor3 = Theme.BG_Secondary
                    TopicLbl.BackgroundTransparency = 0
                    TopicLbl.TextXAlignment = Enum.TextXAlignment.Center
                    TopicLbl.ZIndex     = 3
                    TopicLbl.Parent     = Outer
                end

                if not settings or not settings.disableline then
                    local DivLine = Instance.new('Frame')
                    DivLine.Size             = UDim2.new(1, 0, 0, 1)
                    DivLine.AnchorPoint      = Vector2.new(0, 0.5)
                    DivLine.Position         = UDim2.new(0, 0, 0.5, 0)
                    DivLine.BackgroundColor3 = Theme.Accent
                    DivLine.BackgroundTransparency = 0.5
                    DivLine.BorderSizePixel  = 0
                    DivLine.ZIndex           = 2
                    DivLine.Parent           = Outer

                    local DG = Instance.new('UIGradient')
                    DG.Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.25, 0),
                        NumberSequenceKeypoint.new(0.75, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    }
                    DG.Rotation = 0
                    DG.Parent   = DivLine
                end

                return true
            end

            -- ── SLIDER ───────────────────────────────────
            function ModuleManager:create_slider(settings)
                LOM += 1
                local SliderManager = {}
                if self._size == 0 then self._size = 8 end
                self._size += 30
                if ModuleManager._state then Module.Size = UDim2.fromOffset(253, 90 + self._size) end
                Options.Size = UDim2.fromOffset(253, self._size)

                local SliderBtn = Instance.new('TextButton')
                SliderBtn.Text              = ''
                SliderBtn.AutoButtonColor   = false
                SliderBtn.BackgroundTransparency = 1
                SliderBtn.Name              = 'Slider'
                SliderBtn.Size              = UDim2.new(0, 221, 0, 25)
                SliderBtn.BorderSizePixel   = 0
                SliderBtn.LayoutOrder       = LOM
                SliderBtn.Parent            = Options

                local STitle = Instance.new('TextLabel')
                STitle.FontFace   = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                STitle.TextColor3 = Theme.TextSecondary
                STitle.Text       = settings.title
                STitle.TextSize   = 10
                STitle.Size       = UDim2.new(0, 160, 0, 12)
                STitle.Position   = UDim2.new(0, 0, 0, 1)
                STitle.BackgroundTransparency = 1
                STitle.TextXAlignment = Enum.TextXAlignment.Left
                STitle.Parent     = SliderBtn

                local SValue = Instance.new('TextLabel')
                SValue.FontFace   = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                SValue.TextColor3 = Theme.Accent
                SValue.Text       = tostring(settings.value or 50)
                SValue.TextSize   = 10
                SValue.Size       = UDim2.new(0, 48, 0, 12)
                SValue.AnchorPoint = Vector2.new(1, 0)
                SValue.Position   = UDim2.new(1, 0, 0, 1)
                SValue.BackgroundTransparency = 1
                SValue.TextXAlignment = Enum.TextXAlignment.Right
                SValue.Name       = 'Value'
                SValue.Parent     = SliderBtn

                local Track = Instance.new('Frame')
                Track.AnchorPoint      = Vector2.new(0.5, 1)
                Track.Position         = UDim2.new(0.5, 0, 1, 0)
                Track.Size             = UDim2.new(1, 0, 0, 5)
                Track.BackgroundColor3 = Theme.BG_Tertiary
                Track.BackgroundTransparency = 0.2
                Track.BorderSizePixel  = 0
                Track.Name             = 'Drag'
                Track.Parent           = SliderBtn

                local TrackCorner = Instance.new('UICorner')
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent       = Track

                local Fill = Instance.new('Frame')
                Fill.AnchorPoint      = Vector2.new(0, 0.5)
                Fill.Position         = UDim2.new(0, 0, 0.5, 0)
                Fill.Size             = UDim2.new(0.5, 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.BackgroundTransparency = 0.1
                Fill.BorderSizePixel  = 0
                Fill.Name             = 'Fill'
                Fill.Parent           = Track

                local FillCorner = Instance.new('UICorner')
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent       = Fill

                local FillGrad = Instance.new('UIGradient')
                FillGrad.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentPurple),
                }
                FillGrad.Rotation = 0
                FillGrad.Parent   = Fill

                local Thumb = Instance.new('Frame')
                Thumb.AnchorPoint      = Vector2.new(1, 0.5)
                Thumb.Position         = UDim2.new(1, 0, 0.5, 0)
                Thumb.Size             = UDim2.new(0, 9, 0, 9)
                Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Thumb.BorderSizePixel  = 0
                Thumb.Name             = 'Circle'
                Thumb.Parent           = Fill

                local ThumbCorner = Instance.new('UICorner')
                ThumbCorner.CornerRadius = UDim.new(1, 0)
                ThumbCorner.Parent       = Thumb

                local ThumbShadow = Instance.new('UIStroke')
                ThumbShadow.Color           = Theme.Accent
                ThumbShadow.Transparency    = 0.6
                ThumbShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ThumbShadow.Parent          = Thumb

                function SliderManager:set_percentage(percentage)
                    local rounded = settings.round_number
                        and math.floor(percentage)
                        or  math.floor(percentage * 10) / 10
                    percentage = (percentage - settings.minimum_value) / (settings.maximum_value - settings.minimum_value)
                    local slider_size  = math.clamp(percentage, 0.02, 1) * Track.Size.X.Offset
                    local clamped      = math.clamp(rounded, settings.minimum_value, settings.maximum_value)
                    LibraryMeta._config._flags[settings.flag] = clamped
                    SValue.Text = tostring(clamped)
                    tween(Fill, TI.Medium, { Size = UDim2.fromOffset(slider_size, Track.Size.Y.Offset) })
                    settings.callback(clamped)
                end

                function SliderManager:update()
                    local mp  = (mouse.X - Track.AbsolutePosition.X) / Track.Size.X.Offset
                    local pct = settings.minimum_value + (settings.maximum_value - settings.minimum_value) * mp
                    self:set_percentage(pct)
                end

                function SliderManager:input()
                    SliderManager:update()
                    Connections['slider_drag_'..settings.flag] = mouse.Move:Connect(function()
                        SliderManager:update()
                    end)
                    Connections['slider_input_'..settings.flag] = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
                        Connections:disconnect('slider_drag_'..settings.flag)
                        Connections:disconnect('slider_input_'..settings.flag)
                        if not settings.ignoresaved then Config:save(game.GameId, LibraryMeta._config) end
                    end)
                end

                -- Thumb hover
                SliderBtn.MouseEnter:Connect(function()
                    tween(Thumb, TI.Fast, { Size = UDim2.fromOffset(11, 11) })
                    tween(ThumbShadow, TI.Fast, { Transparency = 0.2 })
                end)
                SliderBtn.MouseLeave:Connect(function()
                    tween(Thumb, TI.Fast, { Size = UDim2.fromOffset(9, 9) })
                    tween(ThumbShadow, TI.Fast, { Transparency = 0.6 })
                end)

                if LibraryMeta:flag_type(settings.flag, 'number') then
                    if not settings.ignoresaved then
                        SliderManager:set_percentage(LibraryMeta._config._flags[settings.flag])
                    else
                        SliderManager:set_percentage(settings.value)
                    end
                else
                    SliderManager:set_percentage(settings.value)
                end

                SliderBtn.MouseButton1Down:Connect(function()
                    SliderManager:input()
                end)

                return SliderManager
            end

            -- ── DROPDOWN ─────────────────────────────────
            function ModuleManager:create_dropdown(settings)
                if not settings.Order then LOM += 1 end
                local DropdownManager = { _state = false, _size = 0 }

                if not settings.Order then
                    if self._size == 0 then self._size = 8 end
                    self._size += 46
                end

                if not settings.Order then
                    if ModuleManager._state then Module.Size = UDim2.fromOffset(253, 90 + self._size) end
                    Options.Size = UDim2.fromOffset(253, self._size)
                end

                local DD = Instance.new('TextButton')
                DD.Text              = ''
                DD.AutoButtonColor   = false
                DD.BackgroundTransparency = 1
                DD.Name              = 'Dropdown'
                DD.Size              = UDim2.new(0, 221, 0, 40)
                DD.BorderSizePixel   = 0
                DD.LayoutOrder       = settings.Order and settings.OrderValue or LOM
                DD.Parent            = Options

                if not LibraryMeta._config._flags[settings.flag] then
                    LibraryMeta._config._flags[settings.flag] = {}
                end

                local DDTitle = Instance.new('TextLabel')
                DDTitle.FontFace  = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                DDTitle.TextColor3 = Theme.TextSecondary
                DDTitle.Text      = settings.title
                DDTitle.TextSize  = 9
                DDTitle.Size      = UDim2.new(1, 0, 0, 11)
                DDTitle.Position  = UDim2.new(0, 0, 0, 0)
                DDTitle.BackgroundTransparency = 1
                DDTitle.TextXAlignment = Enum.TextXAlignment.Left
                DDTitle.Parent    = DD

                local Box = Instance.new('Frame')
                Box.ClipsDescendants    = true
                Box.AnchorPoint         = Vector2.new(0.5, 0)
                Box.Position            = UDim2.new(0.5, 0, 0, 14)
                Box.Size                = UDim2.new(1, 0, 0, 22)
                Box.BackgroundColor3    = Theme.BG_Tertiary
                Box.BackgroundTransparency = 0
                Box.BorderSizePixel     = 0
                Box.Name                = 'Box'
                Box.Parent              = DD

                local BoxCorner = Instance.new('UICorner')
                BoxCorner.CornerRadius = UDim.new(0, 6)
                BoxCorner.Parent       = Box

                local BoxStroke = Instance.new('UIStroke')
                BoxStroke.Color           = Theme.StrokePrimary
                BoxStroke.Transparency    = 0.55
                BoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                BoxStroke.Parent          = Box

                local BoxLayout = Instance.new('UIListLayout')
                BoxLayout.SortOrder = Enum.SortOrder.LayoutOrder
                BoxLayout.Parent    = Box

                local BoxHeader = Instance.new('Frame')
                BoxHeader.AnchorPoint      = Vector2.new(0.5, 0)
                BoxHeader.Position         = UDim2.new(0.5, 0, 0, 0)
                BoxHeader.Size             = UDim2.new(1, 0, 0, 22)
                BoxHeader.BackgroundTransparency = 1
                BoxHeader.BorderSizePixel  = 0
                BoxHeader.LayoutOrder      = 1
                BoxHeader.Parent           = Box

                local CurrentOption = Instance.new('TextLabel')
                CurrentOption.FontFace   = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                CurrentOption.TextColor3 = Theme.TextPrimary
                CurrentOption.TextTransparency = 0
                CurrentOption.Name       = 'CurrentOption'
                CurrentOption.Size       = UDim2.new(0, 170, 0, 13)
                CurrentOption.AnchorPoint = Vector2.new(0, 0.5)
                CurrentOption.Position   = UDim2.new(0, 10, 0.5, 0)
                CurrentOption.BackgroundTransparency = 1
                CurrentOption.TextXAlignment = Enum.TextXAlignment.Left
                CurrentOption.TextSize   = 10
                CurrentOption.Parent     = BoxHeader

                local Arrow = Instance.new('TextLabel')
                Arrow.FontFace   = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                Arrow.TextColor3 = Theme.Accent
                Arrow.Text       = '▾'
                Arrow.TextSize   = 12
                Arrow.Size       = UDim2.new(0, 12, 0, 12)
                Arrow.AnchorPoint = Vector2.new(1, 0.5)
                Arrow.Position   = UDim2.new(1, -10, 0.5, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.Name       = 'Arrow'
                Arrow.Parent     = BoxHeader

                local OptionsFrame = Instance.new('ScrollingFrame')
                OptionsFrame.ScrollBarImageTransparency = 1
                OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
                OptionsFrame.ScrollBarThickness  = 0
                OptionsFrame.Name                = 'Options'
                OptionsFrame.Size                = UDim2.new(1, 0, 0, 0)
                OptionsFrame.BackgroundTransparency = 1
                OptionsFrame.CanvasSize          = UDim2.new(0, 0, 0, 0)
                OptionsFrame.BorderSizePixel     = 0
                OptionsFrame.LayoutOrder         = 2
                OptionsFrame.Parent              = Box

                local OptListLayout = Instance.new('UIListLayout')
                OptListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptListLayout.Parent    = OptionsFrame

                local OptPad = Instance.new('UIPadding')
                OptPad.PaddingLeft  = UDim.new(0, 10)
                OptPad.PaddingTop   = UDim.new(0, 2)
                OptPad.PaddingBottom = UDim.new(0, 4)
                OptPad.Parent       = OptionsFrame

                function DropdownManager:update(option)
                    if settings.multi_dropdown then
                        if not LibraryMeta._config._flags[settings.flag] then LibraryMeta._config._flags[settings.flag] = {} end
                        local selected = {}
                        local current = convertStringToTable(CurrentOption.Text)
                        for _, v in pairs(current) do if v ~= "Label" then table.insert(selected, v) end end
                        local optName = (typeof(option) == "string" and option) or option.Name
                        local found = false
                        for i, v in pairs(selected) do if v == optName then table.remove(selected, i); found = true; break end end
                        if not found then table.insert(selected, optName) end
                        CurrentOption.Text = table.concat(selected, ", ")
                        for _, object in OptionsFrame:GetChildren() do
                            if object.Name == "Option" then
                                object.TextTransparency = table.find(selected, object.Text) and 0.1 or 0.6
                            end
                        end
                        LibraryMeta._config._flags[settings.flag] = convertStringToTable(CurrentOption.Text)
                    else
                        CurrentOption.Text = (typeof(option) == "string" and option) or option.Name
                        for _, object in OptionsFrame:GetChildren() do
                            if object.Name == "Option" then
                                object.TextTransparency = (object.Text == CurrentOption.Text) and 0.1 or 0.6
                            end
                        end
                        LibraryMeta._config._flags[settings.flag] = option
                    end
                    Config:save(game.GameId, LibraryMeta._config)
                    settings.callback(option)
                end

                local CurrentDropSize = 0

                function DropdownManager:unfold_settings()
                    self._state = not self._state
                    if self._state then
                        ModuleManager._multiplier += self._size
                        CurrentDropSize = self._size
                        tween(Module, TI.Medium, { Size = UDim2.fromOffset(253, 90 + ModuleManager._size + ModuleManager._multiplier) })
                        tween(Module.Options, TI.Medium, { Size = UDim2.fromOffset(253, ModuleManager._size + ModuleManager._multiplier) })
                        tween(DD, TI.Medium, { Size = UDim2.fromOffset(221, 40 + self._size) })
                        tween(Box, TI.Medium, { Size = UDim2.fromOffset(221, 22 + self._size) })
                        tween(OptionsFrame, TI.Medium, { Size = UDim2.fromOffset(221, self._size) })
                        tween(Arrow, TI.Medium, { Rotation = 180, TextColor3 = Theme.AccentGlow })
                        tween(BoxStroke, TI.Fast, { Transparency = 0.2, Color = Theme.Accent })
                    else
                        ModuleManager._multiplier -= self._size
                        CurrentDropSize = 0
                        tween(Module, TI.Medium, { Size = UDim2.fromOffset(253, 90 + ModuleManager._size + ModuleManager._multiplier) })
                        tween(Module.Options, TI.Medium, { Size = UDim2.fromOffset(253, ModuleManager._size + ModuleManager._multiplier) })
                        tween(DD, TI.Medium, { Size = UDim2.fromOffset(221, 40) })
                        tween(Box, TI.Medium, { Size = UDim2.fromOffset(221, 22) })
                        tween(OptionsFrame, TI.Medium, { Size = UDim2.fromOffset(221, 0) })
                        tween(Arrow, TI.Medium, { Rotation = 0, TextColor3 = Theme.Accent })
                        tween(BoxStroke, TI.Fast, { Transparency = 0.55, Color = Theme.StrokePrimary })
                    end
                end

                if #settings.options > 0 then
                    DropdownManager._size = 6
                    for index, value in settings.options do
                        local Opt = Instance.new('TextButton')
                        Opt.FontFace         = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                        Opt.Active           = false
                        Opt.TextTransparency = 0.6
                        Opt.TextSize         = 10
                        Opt.Size             = UDim2.new(0, 200, 0, 16)
                        Opt.TextColor3       = Theme.TextPrimary
                        Opt.Text             = (typeof(value) == "string" and value) or value.Name
                        Opt.AutoButtonColor  = false
                        Opt.Name             = 'Option'
                        Opt.BackgroundTransparency = 1
                        Opt.TextXAlignment   = Enum.TextXAlignment.Left
                        Opt.Selectable       = false
                        Opt.BorderSizePixel  = 0
                        Opt.Parent           = OptionsFrame

                        Opt.MouseEnter:Connect(function()
                            tween(Opt, TI.Fast, { TextTransparency = 0, TextColor3 = Theme.AccentGlow })
                        end)
                        Opt.MouseLeave:Connect(function()
                            local isSelected = settings.multi_dropdown
                                and table.find(convertStringToTable(CurrentOption.Text), Opt.Text) ~= nil
                                or  Opt.Text == CurrentOption.Text
                            tween(Opt, TI.Fast, { TextTransparency = isSelected and 0.1 or 0.6, TextColor3 = Theme.TextPrimary })
                        end)

                        Opt.MouseButton1Click:Connect(function()
                            if settings.multi_dropdown then
                                local flags = LibraryMeta._config._flags[settings.flag] or {}
                                if table.find(flags, value) then LibraryMeta:remove_table_value(flags, value)
                                else table.insert(flags, value) end
                            end
                            DropdownManager:update(value)
                        end)

                        if index <= settings.maximum_options then
                            DropdownManager._size += 16
                        end
                    end
                end

                function DropdownManager:New(value)
                    DD:Destroy()
                    value.OrderValue = DD.LayoutOrder
                    ModuleManager._multiplier -= CurrentDropSize
                    return ModuleManager:create_dropdown(value)
                end

                if LibraryMeta:flag_type(settings.flag, 'string') then
                    DropdownManager:update(LibraryMeta._config._flags[settings.flag])
                else
                    DropdownManager:update(settings.options[1])
                end

                DD.MouseButton1Click:Connect(function()
                    DropdownManager:unfold_settings()
                end)

                DD.MouseEnter:Connect(function()
                    tween(BoxStroke, TI.Fast, { Transparency = 0.3 })
                end)
                DD.MouseLeave:Connect(function()
                    if not DropdownManager._state then
                        tween(BoxStroke, TI.Fast, { Transparency = 0.55 })
                    end
                end)

                return DropdownManager
            end

            -- ── FEATURE ──────────────────────────────────
            function ModuleManager:create_feature(settings)
                LOM += 1
                local checked = false
                if self._size == 0 then self._size = 8 end
                self._size += 22
                if ModuleManager._state then Module.Size = UDim2.fromOffset(253, 90 + self._size) end
                Options.Size = UDim2.fromOffset(253, self._size)

                local FC = Instance.new("Frame")
                FC.Size               = UDim2.new(0, 221, 0, 18)
                FC.BackgroundTransparency = 1
                FC.LayoutOrder        = LOM
                FC.Parent             = Options

                local FCLayout = Instance.new("UIListLayout")
                FCLayout.FillDirection = Enum.FillDirection.Horizontal
                FCLayout.SortOrder    = Enum.SortOrder.LayoutOrder
                FCLayout.Parent       = FC

                local FBtn = Instance.new("TextButton")
                FBtn.FontFace    = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                FBtn.TextSize    = 10
                FBtn.Size        = UDim2.new(1, -38, 0, 18)
                FBtn.BackgroundColor3 = Theme.BG_Tertiary
                FBtn.BackgroundTransparency = 0.2
                FBtn.TextColor3  = Theme.TextPrimary
                FBtn.Text        = "  " .. (settings.title or "Feature")
                FBtn.AutoButtonColor = false
                FBtn.TextXAlignment = Enum.TextXAlignment.Left
                FBtn.TextTransparency = 0
                FBtn.BorderSizePixel = 0
                FBtn.Parent      = FC

                local FBtnCorner = Instance.new("UICorner")
                FBtnCorner.CornerRadius = UDim.new(0, 5)
                FBtnCorner.Parent       = FBtn

                local RightC = Instance.new("Frame")
                RightC.Size               = UDim2.new(0, 38, 0, 18)
                RightC.BackgroundTransparency = 1
                RightC.Parent             = FC

                local RightLayout = Instance.new("UIListLayout")
                RightLayout.Padding          = UDim.new(0, 3)
                RightLayout.FillDirection    = Enum.FillDirection.Horizontal
                RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                RightLayout.SortOrder        = Enum.SortOrder.LayoutOrder
                RightLayout.Parent           = RightC

                local KBBox = Instance.new("TextLabel")
                KBBox.FontFace   = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                KBBox.Size       = UDim2.new(0, 17, 0, 17)
                KBBox.BackgroundColor3 = Theme.Accent
                KBBox.BackgroundTransparency = 0.5
                KBBox.TextColor3 = Theme.TextPrimary
                KBBox.TextSize   = 8
                KBBox.LayoutOrder = 2
                KBBox.BorderSizePixel = 0
                KBBox.Parent     = RightC

                local KBBoxCorner = Instance.new("UICorner")
                KBBoxCorner.CornerRadius = UDim.new(0, 4)
                KBBoxCorner.Parent       = KBBox

                local KBBoxStroke = Instance.new("UIStroke")
                KBBoxStroke.Color           = Theme.Accent
                KBBoxStroke.Transparency    = 0.4
                KBBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                KBBoxStroke.Parent          = KBBox

                local KBBtn = Instance.new("TextButton")
                KBBtn.Size               = UDim2.new(1, 0, 1, 0)
                KBBtn.BackgroundTransparency = 1
                KBBtn.TextTransparency   = 1
                KBBtn.Text               = ''
                KBBtn.Parent             = KBBox

                if not LibraryMeta._config._flags then LibraryMeta._config._flags = {} end
                if not LibraryMeta._config._flags[settings.flag] then
                    LibraryMeta._config._flags[settings.flag] = { checked = false, BIND = settings.default or "Unknown" }
                end

                checked      = LibraryMeta._config._flags[settings.flag].checked
                local bindTxt = LibraryMeta._config._flags[settings.flag].BIND
                KBBox.Text   = (bindTxt == "Unknown") and "..." or bindTxt

                local UseF_Var = nil

                if not settings.disablecheck then
                    local CBBtn = Instance.new("TextButton")
                    CBBtn.Size             = UDim2.new(0, 17, 0, 17)
                    CBBtn.BackgroundColor3 = checked and Theme.ToggleOn or Theme.BG_Tertiary
                    CBBtn.Text             = ""
                    CBBtn.BorderSizePixel  = 0
                    CBBtn.LayoutOrder      = 1
                    CBBtn.Parent           = RightC

                    local CBBtnCorner = Instance.new("UICorner")
                    CBBtnCorner.CornerRadius = UDim.new(0, 4)
                    CBBtnCorner.Parent       = CBBtn

                    local CBBtnStroke = Instance.new("UIStroke")
                    CBBtnStroke.Color           = Theme.Accent
                    CBBtnStroke.Transparency    = 0.4
                    CBBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    CBBtnStroke.Parent          = CBBtn

                    local function toggleState()
                        checked = not checked
                        tween(CBBtn, TI.Fast, { BackgroundColor3 = checked and Theme.ToggleOn or Theme.BG_Tertiary })
                        LibraryMeta._config._flags[settings.flag].checked = checked
                        Config:save(game.GameId, LibraryMeta._config)
                        if settings.callback then settings.callback(checked) end
                    end

                    UseF_Var = toggleState
                    CBBtn.MouseButton1Click:Connect(toggleState)
                else
                    UseF_Var = function() settings.button_callback() end
                end

                KBBtn.MouseButton1Click:Connect(function()
                    KBBox.Text = "..."
                    local ic
                    ic = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local nk = input.KeyCode.Name
                            LibraryMeta._config._flags[settings.flag].BIND = nk
                            KBBox.Text = (nk ~= "Unknown") and nk or "..."
                            Config:save(game.GameId, LibraryMeta._config)
                            ic:Disconnect()
                        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                            LibraryMeta._config._flags[settings.flag].BIND = "Unknown"
                            KBBox.Text = "..."
                            Config:save(game.GameId, LibraryMeta._config)
                            ic:Disconnect()
                        end
                    end)
                    Connections["keybind_input_"..settings.flag] = ic
                end)

                Connections["keybind_press_"..settings.flag] = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode.Name == LibraryMeta._config._flags[settings.flag].BIND then UseF_Var() end
                    end
                end)

                FBtn.MouseButton1Click:Connect(function()
                    if settings.button_callback then settings.button_callback() end
                end)
                FBtn.MouseEnter:Connect(function()
                    tween(FBtn, TI.Fast, { BackgroundTransparency = 0 })
                end)
                FBtn.MouseLeave:Connect(function()
                    tween(FBtn, TI.Fast, { BackgroundTransparency = 0.2 })
                end)

                if not settings.disablecheck then settings.callback(checked) end

                return FC
            end

            return ModuleManager
        end -- create_module

        return TabManager
    end -- create_tab

    -- ── KEYBOARD TOGGLE ──────────────────────────────────
    Connections['library_visiblity'] = UserInputService.InputBegan:Connect(function(input, process)
        if input.KeyCode ~= Enum.KeyCode.Insert then return end
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    Minimize.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    return self
end -- create_ui

return Library
