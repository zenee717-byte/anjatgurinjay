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

local SelectedLanguage = GG.Language

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
-- THEME CONFIG (mudah diganti)
-- =============================================
local THEME = {
    BG_PRIMARY       = Color3.fromRGB(10, 11, 20),
    BG_SECONDARY     = Color3.fromRGB(14, 16, 30),
    BG_TERTIARY      = Color3.fromRGB(18, 21, 40),
    BG_MODULE        = Color3.fromRGB(16, 19, 36),
    ACCENT           = Color3.fromRGB(80, 200, 255),
    ACCENT_DIM       = Color3.fromRGB(40, 120, 200),
    ACCENT_GLOW      = Color3.fromRGB(60, 170, 240),
    ACCENT_SECONDARY = Color3.fromRGB(130, 80, 255),
    TEXT_PRIMARY     = Color3.fromRGB(220, 238, 255),
    TEXT_SECONDARY   = Color3.fromRGB(140, 175, 220),
    TEXT_MUTED       = Color3.fromRGB(80, 110, 160),
    DIVIDER          = Color3.fromRGB(35, 55, 110),
    BORDER           = Color3.fromRGB(45, 70, 130),
    SUCCESS          = Color3.fromRGB(60, 220, 140),
    WARNING          = Color3.fromRGB(255, 180, 50),
    ERROR            = Color3.fromRGB(255, 70, 90),
    DISCORD          = Color3.fromRGB(88, 101, 242),
    TOGGLE_OFF       = Color3.fromRGB(22, 26, 50),
    TOGGLE_CIRCLE_OFF= Color3.fromRGB(50, 65, 110),
    TOGGLE_ON        = Color3.fromRGB(80, 200, 255),
    TOGGLE_CIRCLE_ON = Color3.fromRGB(255, 255, 255),
}
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

local mouse = Players.LocalPlayer:GetMouse()

local old_March = CoreGui:FindFirstChild('March')
if old_March then Debris:AddItem(old_March, 0) end

if not isfolder("March") then makefolder("March") end

-- =============================================
-- HELPER: Tween shortcut
-- =============================================
local function Tween(obj, info, props)
    return TweenService:Create(obj, info, props)
end

local function TweenQ(obj, t, props, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir   = dir   or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
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
local Util = {}
Util.__index = Util

function Util:map(value, in_min, in_max, out_min, out_max)
    return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function Util:viewport_point_to_world(location, distance)
    local unit_ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
    return unit_ray.Origin + unit_ray.Direction * distance
end

function Util:get_offset()
    local vy = workspace.CurrentCamera.ViewportSize.Y
    return self:map(vy, 0, 2560, 8, 56)
end

setmetatable(Util, Util)

-- =============================================
-- ACRYLIC BLUR (unchanged logic, kept)
-- =============================================
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(object)
    local self = setmetatable({ _object=object, _folder=nil, _frame=nil, _root=nil }, AcrylicBlur)
    self:setup()
    return self
end

function AcrylicBlur:create_folder()
    local old = workspace.CurrentCamera:FindFirstChild('AcrylicBlur')
    if old then Debris:AddItem(old, 0) end
    local folder = Instance.new('Folder')
    folder.Name = 'AcrylicBlur'
    folder.Parent = workspace.CurrentCamera
    self._folder = folder
end

function AcrylicBlur:create_depth_of_fields()
    local dof = Lighting:FindFirstChild('AcrylicBlur') or Instance.new('DepthOfFieldEffect')
    dof.FarIntensity = 0
    dof.FocusDistance = 0.05
    dof.InFocusRadius = 0.1
    dof.NearIntensity = 1
    dof.Name = 'AcrylicBlur'
    dof.Parent = Lighting
    for _, obj in Lighting:GetChildren() do
        if obj:IsA('DepthOfFieldEffect') and obj ~= dof then
            Connections[obj] = obj:GetPropertyChangedSignal('FarIntensity'):Connect(function()
                obj.FarIntensity = 0
            end)
            obj.FarIntensity = 0
        end
    end
end

function AcrylicBlur:create_frame()
    local frame = Instance.new('Frame')
    frame.Size = UDim2.new(1,0,1,0)
    frame.Position = UDim2.new(0.5,0,0.5,0)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.BackgroundTransparency = 1
    frame.Parent = self._object
    self._frame = frame
end

function AcrylicBlur:create_root()
    local part = Instance.new('Part')
    part.Name = 'Root'
    part.Color = Color3.new(0,0,0)
    part.Material = Enum.Material.Glass
    part.Size = Vector3.new(1,1,0)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Locked = true
    part.CastShadow = false
    part.Transparency = 0.98
    part.Parent = self._folder
    local sm = Instance.new('SpecialMesh')
    sm.MeshType = Enum.MeshType.Brick
    sm.Offset = Vector3.new(0,0,-0.000001)
    sm.Parent = part
    self._root = part
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
    local positions = { top_left=Vector2.new(), top_right=Vector2.new(), bottom_right=Vector2.new() }
    local function update_positions(size, position)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end
    local function update()
        local tl = positions.top_left
        local tr = positions.top_right
        local br = positions.bottom_right
        local tl3 = Util:viewport_point_to_world(tl, distance)
        local tr3 = Util:viewport_point_to_world(tr, distance)
        local br3 = Util:viewport_point_to_world(br, distance)
        local w = (tr3-tl3).Magnitude
        local h = (tr3-br3).Magnitude
        if not self._root then return end
        self._root.CFrame = CFrame.fromMatrix((tl3+br3)/2, workspace.CurrentCamera.CFrame.XVector, workspace.CurrentCamera.CFrame.YVector, workspace.CurrentCamera.CFrame.ZVector)
        self._root.Mesh.Scale = Vector3.new(w,h,0)
    end
    local function on_change()
        local offset = Util:get_offset()
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset/2, offset/2)
        update_positions(size, position)
        task.spawn(update)
    end
    Connections['cframe_update'] = workspace.CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update)
    Connections['viewport_size_update'] = workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(update)
    Connections['field_of_view_update'] = workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(update)
    Connections['frame_absolute_position'] = self._frame:GetPropertyChangedSignal('AbsolutePosition'):Connect(on_change)
    Connections['frame_absolute_size'] = self._frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(on_change)
    task.spawn(update)
end

function AcrylicBlur:check_quality_level()
    local gs = UserSettings().GameSettings
    local ql = gs.SavedQualityLevel.Value
    if ql < 8 then self:change_visiblity(false) end
    Connections['quality_level'] = gs:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        local gs2 = UserSettings().GameSettings
        self:change_visiblity(gs2.SavedQualityLevel.Value >= 8)
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
            local flags = HttpService:JSONEncode(config)
            writefile('March/'..file_name..'.json', flags)
        end)
        if not ok then warn('failed to save config', err) end
    end,
    load = function(self, file_name, config)
        local ok, result = pcall(function()
            if not isfile('March/'..file_name..'.json') then
                self:save(file_name, config)
                return
            end
            local flags = readfile('March/'..file_name..'.json')
            if not flags then
                self:save(file_name, config)
                return
            end
            return HttpService:JSONDecode(flags)
        end)
        if not ok then warn('failed to load config', result) end
        if not result then
            result = { _flags = {}, _keybinds = {}, _library = {} }
        end
        return result
    end
}, {})

-- =============================================
-- NOTIFICATION SYSTEM (upgraded)
-- =============================================
local NotifScreen = Instance.new("ScreenGui")
NotifScreen.Name = "GGNotifications"
NotifScreen.ResetOnSpawn = false
NotifScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifScreen.Parent = CoreGui

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotifContainer"
NotificationContainer.Size = UDim2.new(0, 320, 1, 0)
NotificationContainer.Position = UDim2.new(1, -330, 0, 0)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ClipsDescendants = false
NotificationContainer.Parent = NotifScreen

local NotifList = Instance.new("UIListLayout")
NotifList.FillDirection = Enum.FillDirection.Vertical
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.Padding = UDim.new(0, 8)
NotifList.Parent = NotificationContainer

local NotifPad = Instance.new("UIPadding")
NotifPad.PaddingBottom = UDim.new(0, 14)
NotifPad.PaddingRight = UDim.new(0, 4)
NotifPad.Parent = NotificationContainer

local notifOrder = 0

local function SendNotification(settings)
    notifOrder = notifOrder + 1
    local duration = settings.duration or 5
    local ntype = settings.type or "info" -- info, success, warning, error

    local accentColor = THEME.ACCENT
    if ntype == "success" then accentColor = THEME.SUCCESS
    elseif ntype == "warning" then accentColor = THEME.WARNING
    elseif ntype == "error" then accentColor = THEME.ERROR end

    -- Wrapper
    local Wrapper = Instance.new("Frame")
    Wrapper.Name = "Notif"
    Wrapper.Size = UDim2.new(1, 0, 0, 70)
    Wrapper.BackgroundTransparency = 1
    Wrapper.ClipsDescendants = false
    Wrapper.AutomaticSize = Enum.AutomaticSize.Y
    Wrapper.LayoutOrder = notifOrder
    Wrapper.Parent = NotificationContainer

    -- Card
    local Card = Instance.new("Frame")
    Card.Name = "Card"
    Card.Size = UDim2.new(1, 0, 0, 64)
    Card.Position = UDim2.new(1, 10, 0, 0)
    Card.BackgroundColor3 = THEME.BG_TERTIARY
    Card.BackgroundTransparency = 0.06
    Card.BorderSizePixel = 0
    Card.AutomaticSize = Enum.AutomaticSize.Y
    Card.ClipsDescendants = false
    Card.Parent = Wrapper

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = accentColor
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.55
    CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    CardStroke.Parent = Card

    -- Left accent bar
    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, 3, 1, -12)
    AccentBar.Position = UDim2.new(0, 8, 0, 6)
    AccentBar.BackgroundColor3 = accentColor
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = Card

    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(1, 0)
    AccentCorner.Parent = AccentBar

    -- Title
    local Title = Instance.new("TextLabel")
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    Title.TextColor3 = THEME.TEXT_PRIMARY
    Title.Text = settings.title or "Notification"
    Title.TextSize = 13
    Title.Size = UDim2.new(1, -26, 0, 18)
    Title.Position = UDim2.new(0, 18, 0, 8)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    -- Body
    local Body = Instance.new("TextLabel")
    Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Body.TextColor3 = THEME.TEXT_SECONDARY
    Body.Text = settings.text or ""
    Body.TextSize = 11
    Body.Size = UDim2.new(1, -26, 0, 0)
    Body.Position = UDim2.new(0, 18, 0, 28)
    Body.BackgroundTransparency = 1
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.TextWrapped = true
    Body.AutomaticSize = Enum.AutomaticSize.Y
    Body.Parent = Card

    -- Progress bar
    local ProgressBG = Instance.new("Frame")
    ProgressBG.Size = UDim2.new(1, -16, 0, 2)
    ProgressBG.Position = UDim2.new(0, 8, 1, -6)
    ProgressBG.BackgroundColor3 = THEME.DIVIDER
    ProgressBG.BackgroundTransparency = 0.3
    ProgressBG.BorderSizePixel = 0
    ProgressBG.AnchorPoint = Vector2.new(0, 1)
    ProgressBG.Parent = Card

    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBG

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.new(1, 0, 1, 0)
    ProgressFill.BackgroundColor3 = accentColor
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBG

    local ProgressFillCorner = Instance.new("UICorner")
    ProgressFillCorner.CornerRadius = UDim.new(1, 0)
    ProgressFillCorner.Parent = ProgressFill

    task.spawn(function()
        -- Slide in
        TweenQ(Card, 0.45, { Position = UDim2.new(0, 0, 0, 0) }):Play()
        task.wait(0.1)
        -- Progress drain
        TweenQ(ProgressFill, duration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear, Enum.EasingDirection.In):Play()
        task.wait(duration)
        -- Slide out
        local out = TweenQ(Card, 0.35, { Position = UDim2.new(1, 15, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        out:Play()
        out.Completed:Wait()
        Wrapper:Destroy()
    end)
end

-- =============================================
-- LIBRARY
-- =============================================
local Library = {
    _config = Config:load(game.GameId),
    _choosing_keybind = false,
    _device = nil,
    _ui_open = true,
    _ui_scale = 1,
    _ui_loaded = false,
    _ui = nil,
    _dragging = false,
    _drag_start = nil,
    _container_position = nil
}
Library.__index = Library

Library.SendNotification = SendNotification

function Library.new()
    local self = setmetatable({ _loaded=false, _tab=0 }, Library)
    self:create_ui()
    return self
end

function Library:get_screen_scale()
    self._ui_scale = workspace.CurrentCamera.ViewportSize.X / 1400
end

function Library:get_device()
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

function Library:removed(action)
    self._ui.AncestryChanged:Once(action)
end

function Library:flag_type(flag, flag_type)
    if not Library._config._flags[flag] then return end
    return typeof(Library._config._flags[flag]) == flag_type
end

function Library:remove_table_value(__table, table_value)
    for index, value in __table do
        if value ~= table_value then continue end
        table.remove(__table, index)
    end
end

-- =============================================
-- HELPER: make a UIStroke
-- =============================================
local function MakeStroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.BORDER
    s.Transparency = transparency or 0.5
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 6)
    c.Parent = parent
    return c
end

-- =============================================
-- CREATE UI
-- =============================================
function Library:create_ui()
    local old_March = CoreGui:FindFirstChild('March')
    if old_March then Debris:AddItem(old_March, 0) end

    -- Root ScreenGui
    local March = Instance.new('ScreenGui')
    March.ResetOnSpawn = false
    March.Name = 'March'
    March.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    March.Parent = CoreGui

    -- Main container
    local Container = Instance.new('Frame')
    Container.ClipsDescendants = true
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Name = 'Container'
    Container.BackgroundColor3 = THEME.BG_PRIMARY
    Container.BackgroundTransparency = 0.04
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 0, 0, 0)
    Container.Active = true
    Container.BorderSizePixel = 0
    Container.Parent = March

    MakeCorner(Container, UDim.new(0, 14))
    MakeStroke(Container, THEME.BORDER, 0.35, 1.2)

    -- Subtle gradient overlay on container
    local ContainerGrad = Instance.new("UIGradient")
    ContainerGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 22, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 22))
    }
    ContainerGrad.Rotation = 135
    ContainerGrad.Parent = Container

    -- Handler (inner layout frame)
    local Handler = Instance.new('Frame')
    Handler.BackgroundTransparency = 1
    Handler.Name = 'Handler'
    Handler.BorderSizePixel = 0
    Handler.Size = UDim2.new(0, 720, 0, 520)
    Handler.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Handler.Parent = Container

    -- ========== SIDEBAR ==========
    local Sidebar = Instance.new('Frame')
    Sidebar.Name = 'Sidebar'
    Sidebar.Size = UDim2.new(0, 158, 1, 0)
    Sidebar.BackgroundColor3 = THEME.BG_SECONDARY
    Sidebar.BackgroundTransparency = 0.0
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Handler

    -- Sidebar gradient
    local SidebarGrad = Instance.new("UIGradient")
    SidebarGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 20, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 14, 28))
    }
    SidebarGrad.Rotation = 90
    SidebarGrad.Parent = Sidebar

    -- Sidebar right border
    local SidebarBorder = Instance.new('Frame')
    SidebarBorder.Name = 'SidebarBorder'
    SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarBorder.Position = UDim2.new(1, -1, 0, 0)
    SidebarBorder.BackgroundColor3 = THEME.BORDER
    SidebarBorder.BackgroundTransparency = 0.4
    SidebarBorder.BorderSizePixel = 0
    SidebarBorder.Parent = Sidebar

    local SidebarBorderGrad = Instance.new("UIGradient")
    SidebarBorderGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 130, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 130, 255))
    }
    SidebarBorderGrad.Rotation = 90
    SidebarBorderGrad.Parent = SidebarBorder

    -- Logo area
    local LogoArea = Instance.new('Frame')
    LogoArea.Name = 'LogoArea'
    LogoArea.Size = UDim2.new(1, 0, 0, 58)
    LogoArea.BackgroundTransparency = 1
    LogoArea.BorderSizePixel = 0
    LogoArea.Parent = Sidebar

    local LogoIcon = Instance.new('ImageLabel')
    LogoIcon.ImageColor3 = THEME.ACCENT
    LogoIcon.ScaleType = Enum.ScaleType.Fit
    LogoIcon.Image = 'rbxassetid://10734887784'
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Position = UDim2.new(0, 14, 0.5, 0)
    LogoIcon.AnchorPoint = Vector2.new(0, 0.5)
    LogoIcon.Name = 'Icon'
    LogoIcon.Size = UDim2.new(0, 20, 0, 20)
    LogoIcon.BorderSizePixel = 0
    LogoIcon.Parent = LogoArea

    local LogoGlow = Instance.new("ImageLabel")
    LogoGlow.Image = "rbxassetid://5028857084"
    LogoGlow.ImageColor3 = THEME.ACCENT
    LogoGlow.ImageTransparency = 0.65
    LogoGlow.Size = UDim2.new(0, 40, 0, 40)
    LogoGlow.Position = UDim2.new(0, 4, 0.5, 0)
    LogoGlow.AnchorPoint = Vector2.new(0, 0.5)
    LogoGlow.BackgroundTransparency = 1
    LogoGlow.BorderSizePixel = 0
    LogoGlow.ZIndex = 0
    LogoGlow.Parent = LogoArea

    local ClientName = Instance.new('TextLabel')
    ClientName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    ClientName.TextColor3 = THEME.TEXT_PRIMARY
    ClientName.Text = 'GG HUB'
    ClientName.Name = 'ClientName'
    ClientName.Size = UDim2.new(0, 80, 0, 16)
    ClientName.AnchorPoint = Vector2.new(0, 0.5)
    ClientName.Position = UDim2.new(0, 42, 0.5, -2)
    ClientName.BackgroundTransparency = 1
    ClientName.TextXAlignment = Enum.TextXAlignment.Left
    ClientName.BorderSizePixel = 0
    ClientName.TextSize = 14
    ClientName.BackgroundColor3 = Color3.fromRGB(255,255,255)
    ClientName.Parent = LogoArea

    local ClientNameGrad = Instance.new('UIGradient')
    ClientNameGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, THEME.ACCENT),
        ColorSequenceKeypoint.new(1, THEME.TEXT_PRIMARY)
    }
    ClientNameGrad.Parent = ClientName

    local ClientSub = Instance.new('TextLabel')
    ClientSub.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    ClientSub.TextColor3 = THEME.TEXT_MUTED
    ClientSub.Text = 'v2.0  •  exploit hub'
    ClientSub.Size = UDim2.new(0, 100, 0, 12)
    ClientSub.AnchorPoint = Vector2.new(0, 0.5)
    ClientSub.Position = UDim2.new(0, 42, 0.5, 10)
    ClientSub.BackgroundTransparency = 1
    ClientSub.TextXAlignment = Enum.TextXAlignment.Left
    ClientSub.BorderSizePixel = 0
    ClientSub.TextSize = 9
    ClientSub.BackgroundColor3 = Color3.fromRGB(255,255,255)
    ClientSub.Parent = LogoArea

    -- Separator under logo
    local LogoDivider = Instance.new('Frame')
    LogoDivider.Size = UDim2.new(1, -28, 0, 1)
    LogoDivider.Position = UDim2.new(0, 14, 0, 58)
    LogoDivider.BackgroundColor3 = THEME.DIVIDER
    LogoDivider.BackgroundTransparency = 0.3
    LogoDivider.BorderSizePixel = 0
    LogoDivider.Parent = Sidebar

    local LogoDivGrad = Instance.new('UIGradient')
    LogoDivGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0),
        NumberSequenceKeypoint.new(0.8, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    LogoDivGrad.Parent = LogoDivider

    -- Active tab indicator pill
    local Pin = Instance.new('Frame')
    Pin.Name = 'Pin'
    Pin.Position = UDim2.new(0, 6, 0, 70)
    Pin.BorderColor3 = Color3.fromRGB(0,0,0)
    Pin.Size = UDim2.new(0, 3, 0, 30)
    Pin.BorderSizePixel = 0
    Pin.BackgroundColor3 = THEME.ACCENT
    Pin.Parent = Sidebar
    Pin.ZIndex = 5

    MakeCorner(Pin, UDim.new(1,0))

    local PinGlow = Instance.new('ImageLabel')
    PinGlow.Image = "rbxassetid://5028857084"
    PinGlow.ImageColor3 = THEME.ACCENT
    PinGlow.ImageTransparency = 0.5
    PinGlow.Size = UDim2.new(0, 18, 0, 36)
    PinGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    PinGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    PinGlow.BackgroundTransparency = 1
    PinGlow.BorderSizePixel = 0
    PinGlow.ZIndex = 4
    PinGlow.Parent = Pin

    -- Tabs scrolling frame
    local Tabs = Instance.new('ScrollingFrame')
    Tabs.ScrollBarImageTransparency = 1
    Tabs.ScrollBarThickness = 0
    Tabs.Name = 'Tabs'
    Tabs.Size = UDim2.new(1, -14, 0, 380)
    Tabs.Position = UDim2.new(0, 7, 0, 66)
    Tabs.Selectable = false
    Tabs.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Tabs.BackgroundTransparency = 1
    Tabs.BorderSizePixel = 0
    Tabs.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Tabs.CanvasSize = UDim2.new(0,0,0.5,0)
    Tabs.Parent = Sidebar

    local TabsListLayout = Instance.new('UIListLayout')
    TabsListLayout.Padding = UDim.new(0, 3)
    TabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsListLayout.Parent = Tabs

    -- Separator above discord button
    local BottomDivider = Instance.new('Frame')
    BottomDivider.Size = UDim2.new(1, -28, 0, 1)
    BottomDivider.Position = UDim2.new(0, 14, 1, -46)
    BottomDivider.BackgroundColor3 = THEME.DIVIDER
    BottomDivider.BackgroundTransparency = 0.4
    BottomDivider.BorderSizePixel = 0
    BottomDivider.Parent = Sidebar

    local BotDivGrad = Instance.new('UIGradient')
    BotDivGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0),
        NumberSequenceKeypoint.new(0.8, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    BotDivGrad.Parent = BottomDivider

    -- Discord button (bottom of sidebar)
    local DiscordButton = Instance.new('TextButton')
    DiscordButton.Name = 'DiscordButton'
    DiscordButton.Size = UDim2.new(1, -14, 0, 30)
    DiscordButton.Position = UDim2.new(0, 7, 1, -40)
    DiscordButton.AnchorPoint = Vector2.new(0, 0)
    DiscordButton.BackgroundColor3 = THEME.DISCORD
    DiscordButton.BorderSizePixel = 0
    DiscordButton.Text = ''
    DiscordButton.AutoButtonColor = false
    DiscordButton.ZIndex = 5
    DiscordButton.Parent = Sidebar

    MakeCorner(DiscordButton, UDim.new(0, 7))
    MakeStroke(DiscordButton, Color3.fromRGB(130, 140, 255), 0.5, 1)

    local DiscordGrad = Instance.new('UIGradient')
    DiscordGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 110, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 84, 220))
    }
    DiscordGrad.Rotation = 135
    DiscordGrad.Parent = DiscordButton

    local DiscordIcon = Instance.new('TextLabel')
    DiscordIcon.BackgroundTransparency = 1
    DiscordIcon.Size = UDim2.new(0, 20, 1, 0)
    DiscordIcon.Position = UDim2.new(0, 8, 0, 0)
    DiscordIcon.Text = '💬'
    DiscordIcon.TextSize = 13
    DiscordIcon.Font = Enum.Font.SourceSans
    DiscordIcon.TextColor3 = Color3.fromRGB(255,255,255)
    DiscordIcon.ZIndex = 6
    DiscordIcon.Parent = DiscordButton

    local DiscordLabel = Instance.new('TextLabel')
    DiscordLabel.BackgroundTransparency = 1
    DiscordLabel.Size = UDim2.new(1, -32, 1, 0)
    DiscordLabel.Position = UDim2.new(0, 28, 0, 0)
    DiscordLabel.Text = 'Join Discord'
    DiscordLabel.TextSize = 11
    DiscordLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    DiscordLabel.TextColor3 = Color3.fromRGB(255,255,255)
    DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
    DiscordLabel.ZIndex = 6
    DiscordLabel.Parent = DiscordButton

    DiscordButton.MouseEnter:Connect(function()
        TweenQ(DiscordButton, 0.2, { BackgroundColor3 = Color3.fromRGB(110,122,255), Size = UDim2.new(1,-12,0,31) }):Play()
    end)
    DiscordButton.MouseLeave:Connect(function()
        TweenQ(DiscordButton, 0.2, { BackgroundColor3 = THEME.DISCORD, Size = UDim2.new(1,-14,0,30) }):Play()
    end)
    DiscordButton.MouseButton1Down:Connect(function()
        TweenQ(DiscordButton, 0.1, { Size = UDim2.new(1,-16,0,28) }):Play()
    end)
    DiscordButton.MouseButton1Up:Connect(function()
        TweenQ(DiscordButton, 0.12, { Size = UDim2.new(1,-14,0,30) }):Play()
    end)
    DiscordButton.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
            SendNotification({ title="Discord", text="Invite link copied to clipboard!", type="success", duration=4 })
        else
            SendNotification({ title="Discord", text="discord.gg/PNkYMTPq22", type="info", duration=6 })
        end
    end)

    -- ========== CONTENT AREA ==========
    local ContentArea = Instance.new('Frame')
    ContentArea.Name = 'ContentArea'
    ContentArea.Size = UDim2.new(1, -158, 1, 0)
    ContentArea.Position = UDim2.new(0, 158, 0, 0)
    ContentArea.BackgroundColor3 = THEME.BG_PRIMARY
    ContentArea.BackgroundTransparency = 0.0
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = Handler

    local ContentGrad = Instance.new("UIGradient")
    ContentGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(13,15,28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10,11,22))
    }
    ContentGrad.Rotation = 135
    ContentGrad.Parent = ContentArea

    -- Topbar in content area
    local Topbar = Instance.new('Frame')
    Topbar.Name = 'Topbar'
    Topbar.Size = UDim2.new(1, 0, 0, 46)
    Topbar.BackgroundColor3 = THEME.BG_SECONDARY
    Topbar.BackgroundTransparency = 0.3
    Topbar.BorderSizePixel = 0
    Topbar.Parent = ContentArea

    local TopbarDivider = Instance.new('Frame')
    TopbarDivider.Size = UDim2.new(1, 0, 0, 1)
    TopbarDivider.Position = UDim2.new(0, 0, 1, -1)
    TopbarDivider.BackgroundColor3 = THEME.DIVIDER
    TopbarDivider.BackgroundTransparency = 0.3
    TopbarDivider.BorderSizePixel = 0
    TopbarDivider.Parent = Topbar

    local TopbarGrad = Instance.new("UIGradient")
    TopbarGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    TopbarGrad.Parent = TopbarDivider

    -- Active page label in topbar
    local ActivePageLabel = Instance.new('TextLabel')
    ActivePageLabel.Name = 'ActivePageLabel'
    ActivePageLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    ActivePageLabel.TextColor3 = THEME.TEXT_PRIMARY
    ActivePageLabel.Text = ''
    ActivePageLabel.TextSize = 13
    ActivePageLabel.Size = UDim2.new(1, -80, 1, 0)
    ActivePageLabel.Position = UDim2.new(0, 14, 0, 0)
    ActivePageLabel.BackgroundTransparency = 1
    ActivePageLabel.TextXAlignment = Enum.TextXAlignment.Left
    ActivePageLabel.Parent = Topbar

    -- Minimize button
    local Minimize = Instance.new('TextButton')
    Minimize.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Minimize.TextColor3 = THEME.TEXT_MUTED
    Minimize.Text = '—'
    Minimize.TextSize = 14
    Minimize.AutoButtonColor = false
    Minimize.Name = 'Minimize'
    Minimize.BackgroundColor3 = THEME.BG_TERTIARY
    Minimize.BackgroundTransparency = 0.5
    Minimize.Position = UDim2.new(1, -36, 0.5, 0)
    Minimize.AnchorPoint = Vector2.new(0, 0.5)
    Minimize.Size = UDim2.new(0, 24, 0, 24)
    Minimize.BorderSizePixel = 0
    Minimize.Parent = Topbar
    MakeCorner(Minimize, UDim.new(0, 6))

    Minimize.MouseEnter:Connect(function()
        TweenQ(Minimize, 0.2, { TextColor3 = THEME.TEXT_PRIMARY, BackgroundTransparency = 0.2 }):Play()
    end)
    Minimize.MouseLeave:Connect(function()
        TweenQ(Minimize, 0.2, { TextColor3 = THEME.TEXT_MUTED, BackgroundTransparency = 0.5 }):Play()
    end)

    -- Sections folder
    local Sections = Instance.new('Folder')
    Sections.Name = 'Sections'
    Sections.Parent = ContentArea

    -- UIScale for mobile
    local UIScale = Instance.new('UIScale')
    UIScale.Parent = Container

    self._ui = March

    -- Drag logic
    local function on_drag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = true
            self._drag_start = input.Position
            self._container_position = Container.Position
            Connections['container_input_ended'] = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then return end
                Connections:disconnect('container_input_ended')
                self._dragging = false
            end)
        end
    end

    local function update_drag(input)
        local delta = input.Position - self._drag_start
        local position = UDim2.new(
            self._container_position.X.Scale, self._container_position.X.Offset + delta.X,
            self._container_position.Y.Scale, self._container_position.Y.Offset + delta.Y
        )
        TweenQ(Container, 0.15, { Position = position }):Play()
    end

    local function drag(input)
        if not self._dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update_drag(input)
        end
    end

    -- Allow drag from sidebar or topbar
    Connections['sidebar_drag'] = Sidebar.InputBegan:Connect(on_drag)
    Connections['topbar_drag'] = Topbar.InputBegan:Connect(on_drag)
    Connections['input_changed'] = UserInputService.InputChanged:Connect(drag)

    self:removed(function()
        self._ui = nil
        Connections:disconnect_all()
    end)

    -- Public API methods
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
            TweenQ(Container, 0.5, { Size = UDim2.fromOffset(720, 520) }):Play()
        else
            TweenQ(Container, 0.5, { Size = UDim2.fromOffset(158, 56) }):Play()
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
        TweenQ(Container, 0.6, { Size = UDim2.fromOffset(720, 520) }):Play()
        AcrylicBlur.new(Container)
        self._ui_loaded = true
    end

    -- Tab highlight logic
    function self:update_tabs(tab)
        for _, object in Tabs:GetChildren() do
            if object.Name ~= 'Tab' then continue end
            local isActive = (object == tab)
            if isActive then
                local offset = (object.LayoutOrder) * (38 + 3)
                TweenQ(Pin, 0.45, { Position = UDim2.new(0, 6, 0, 70 + offset) }):Play()
                TweenQ(object, 0.35, {
                    BackgroundColor3 = THEME.BG_TERTIARY,
                    BackgroundTransparency = 0.0
                }):Play()
                TweenQ(object.TextLabel, 0.35, {
                    TextTransparency = 0,
                    TextColor3 = THEME.ACCENT
                }):Play()
                TweenQ(object.Icon, 0.35, {
                    ImageTransparency = 0,
                    ImageColor3 = THEME.ACCENT
                }):Play()
                -- Update page label
                ActivePageLabel.Text = object.TextLabel.Text
            else
                TweenQ(object, 0.35, {
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BackgroundTransparency = 1
                }):Play()
                TweenQ(object.TextLabel, 0.35, {
                    TextTransparency = 0.55,
                    TextColor3 = THEME.TEXT_SECONDARY
                }):Play()
                TweenQ(object.Icon, 0.35, {
                    ImageTransparency = 0.7,
                    ImageColor3 = THEME.TEXT_SECONDARY
                }):Play()
            end
        end
    end

    function self:update_sections(left_section, right_section)
        for _, object in Sections:GetChildren() do
            object.Visible = (object == left_section or object == right_section)
        end
    end

    -- =============================================
    -- CREATE TAB
    -- =============================================
    function self:create_tab(title, icon)
        local TabManager = {}
        local LayoutOrderModule = 0

        local font_params = Instance.new('GetTextBoundsParams')
        font_params.Text = title
        font_params.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        font_params.Size = 12
        font_params.Width = 10000
        local font_size = TextService:GetTextBoundsAsync(font_params)

        local first_tab = not Tabs:FindFirstChild('Tab')

        local Tab = Instance.new('TextButton')
        Tab.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        Tab.TextColor3 = Color3.fromRGB(0,0,0)
        Tab.BorderColor3 = Color3.fromRGB(0,0,0)
        Tab.Text = ''
        Tab.AutoButtonColor = false
        Tab.BackgroundTransparency = 1
        Tab.Name = 'Tab'
        Tab.Size = UDim2.new(1, 0, 0, 38)
        Tab.BorderSizePixel = 0
        Tab.TextSize = 14
        Tab.BackgroundColor3 = THEME.BG_TERTIARY
        Tab.Parent = Tabs
        Tab.LayoutOrder = self._tab

        MakeCorner(Tab, UDim.new(0, 7))

        local TabTextLabel = Instance.new('TextLabel')
        TabTextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TabTextLabel.TextColor3 = THEME.TEXT_SECONDARY
        TabTextLabel.TextTransparency = 0.55
        TabTextLabel.Text = title
        TabTextLabel.Size = UDim2.new(0, font_size.X, 0, 14)
        TabTextLabel.AnchorPoint = Vector2.new(0, 0.5)
        TabTextLabel.Position = UDim2.new(0, 38, 0.5, 0)
        TabTextLabel.BackgroundTransparency = 1
        TabTextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabTextLabel.BorderSizePixel = 0
        TabTextLabel.TextSize = 12
        TabTextLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
        TabTextLabel.Parent = Tab
        TabTextLabel.Name = 'TextLabel'

        local TabIcon = Instance.new('ImageLabel')
        TabIcon.ScaleType = Enum.ScaleType.Fit
        TabIcon.ImageTransparency = 0.7
        TabIcon.ImageColor3 = THEME.TEXT_SECONDARY
        TabIcon.BorderColor3 = Color3.fromRGB(0,0,0)
        TabIcon.AnchorPoint = Vector2.new(0, 0.5)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Position = UDim2.new(0, 12, 0.5, 0)
        TabIcon.Name = 'Icon'
        TabIcon.Image = icon
        TabIcon.Size = UDim2.new(0, 14, 0, 14)
        TabIcon.BorderSizePixel = 0
        TabIcon.BackgroundColor3 = Color3.fromRGB(255,255,255)
        TabIcon.Parent = Tab

        -- Hover glow
        Tab.MouseEnter:Connect(function()
            if Tab.BackgroundTransparency ~= 0 then
                TweenQ(Tab, 0.2, { BackgroundColor3 = THEME.BG_TERTIARY, BackgroundTransparency = 0.5 }):Play()
            end
        end)
        Tab.MouseLeave:Connect(function()
            if Tab.BackgroundTransparency ~= 0 then
                TweenQ(Tab, 0.2, { BackgroundTransparency = 1 }):Play()
            end
        end)

        -- Sections
        local function makeSection(xPos)
            local Section = Instance.new('ScrollingFrame')
            Section.AutomaticCanvasSize = Enum.AutomaticSize.XY
            Section.ScrollBarThickness = 2
            Section.ScrollBarImageColor3 = THEME.ACCENT
            Section.ScrollBarImageTransparency = 0.7
            Section.Size = UDim2.new(0, 256, 0, 462)
            Section.Selectable = false
            Section.AnchorPoint = Vector2.new(0, 0.5)
            Section.BackgroundTransparency = 1
            Section.Position = UDim2.new(0, xPos, 0.5, 5)
            Section.BorderSizePixel = 0
            Section.CanvasSize = UDim2.new(0,0,0.5,0)
            Section.Visible = false
            Section.Parent = Sections

            local SectionList = Instance.new('UIListLayout')
            SectionList.Padding = UDim.new(0, 10)
            SectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            SectionList.SortOrder = Enum.SortOrder.LayoutOrder
            SectionList.Parent = Section

            local SectionPad = Instance.new('UIPadding')
            SectionPad.PaddingTop = UDim.new(0, 2)
            SectionPad.PaddingBottom = UDim.new(0, 8)
            SectionPad.Parent = Section

            return Section
        end

        local LeftSection  = makeSection(8)
        LeftSection.Name  = 'LeftSection'
        local RightSection = makeSection(270)
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

        -- =============================================
        -- CREATE MODULE
        -- =============================================
        function TabManager:create_module(settings)
            LayoutOrderModule = 0
            local ModuleManager = { _state=false, _size=0, _multiplier=0 }

            if settings.section == 'right' then
                settings.section = RightSection
            else
                settings.section = LeftSection
            end

            local Module = Instance.new('Frame')
            Module.ClipsDescendants = true
            Module.BorderSizePixel = 0
            Module.BackgroundColor3 = THEME.BG_MODULE
            Module.BackgroundTransparency = 0.0
            Module.Position = UDim2.new(0,0,0,0)
            Module.Name = 'Module'
            Module.Size = UDim2.new(0, 252, 0, 94)
            Module.Parent = settings.section

            MakeCorner(Module, UDim.new(0, 8))
            MakeStroke(Module, THEME.BORDER, 0.6, 1)

            local ModuleList = Instance.new('UIListLayout')
            ModuleList.SortOrder = Enum.SortOrder.LayoutOrder
            ModuleList.Parent = Module

            local Header = Instance.new('TextButton')
            Header.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            Header.TextColor3 = Color3.fromRGB(0,0,0)
            Header.Text = ''
            Header.AutoButtonColor = false
            Header.BackgroundTransparency = 1
            Header.Name = 'Header'
            Header.Size = UDim2.new(0, 252, 0, 94)
            Header.BorderSizePixel = 0
            Header.TextSize = 14
            Header.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Header.Parent = Module

            -- Module icon (small accent dot)
            local ModuleAccent = Instance.new('Frame')
            ModuleAccent.Size = UDim2.new(0, 3, 0, 20)
            ModuleAccent.Position = UDim2.new(0, 10, 0, 16)
            ModuleAccent.BackgroundColor3 = THEME.ACCENT
            ModuleAccent.BackgroundTransparency = 0.4
            ModuleAccent.BorderSizePixel = 0
            ModuleAccent.ZIndex = 2
            ModuleAccent.Parent = Header
            MakeCorner(ModuleAccent, UDim.new(1,0))

            local HeaderIcon = Instance.new('ImageLabel')
            HeaderIcon.ImageColor3 = THEME.ACCENT
            HeaderIcon.ScaleType = Enum.ScaleType.Fit
            HeaderIcon.ImageTransparency = 0.5
            HeaderIcon.Image = 'rbxassetid://79095934438045'
            HeaderIcon.BackgroundTransparency = 1
            HeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
            HeaderIcon.Position = UDim2.new(0, 18, 0.78, 0)
            HeaderIcon.Name = 'Icon'
            HeaderIcon.Size = UDim2.new(0, 14, 0, 14)
            HeaderIcon.BorderSizePixel = 0
            HeaderIcon.Parent = Header

            local ModuleName = Instance.new('TextLabel')
            ModuleName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            ModuleName.TextColor3 = THEME.TEXT_PRIMARY
            ModuleName.TextTransparency = 0.0
            if not settings.rich then
                ModuleName.Text = settings.title or "Module"
            else
                ModuleName.RichText = true
                ModuleName.Text = settings.richtext or "<font color='rgb(80,200,255)'>GG</font> Hub"
            end
            ModuleName.Name = 'ModuleName'
            ModuleName.Size = UDim2.new(0, 180, 0, 15)
            ModuleName.AnchorPoint = Vector2.new(0, 0.5)
            ModuleName.Position = UDim2.new(0, 22, 0.23, 0)
            ModuleName.BackgroundTransparency = 1
            ModuleName.TextXAlignment = Enum.TextXAlignment.Left
            ModuleName.BorderSizePixel = 0
            ModuleName.TextSize = 13
            ModuleName.BackgroundColor3 = Color3.fromRGB(255,255,255)
            ModuleName.Parent = Header

            local Description = Instance.new('TextLabel')
            Description.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            Description.TextColor3 = THEME.TEXT_SECONDARY
            Description.TextTransparency = 0.1
            Description.Text = settings.description or ""
            Description.Name = 'Description'
            Description.Size = UDim2.new(0, 190, 0, 12)
            Description.AnchorPoint = Vector2.new(0, 0.5)
            Description.Position = UDim2.new(0, 22, 0.42, 0)
            Description.BackgroundTransparency = 1
            Description.TextXAlignment = Enum.TextXAlignment.Left
            Description.BorderSizePixel = 0
            Description.TextSize = 10
            Description.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Description.Parent = Header

            -- Toggle switch (modern pill)
            local Toggle = Instance.new('Frame')
            Toggle.Name = 'Toggle'
            Toggle.BackgroundColor3 = THEME.TOGGLE_OFF
            Toggle.BackgroundTransparency = 0.0
            Toggle.Position = UDim2.new(0, 206, 0, 64)
            Toggle.BorderSizePixel = 0
            Toggle.Size = UDim2.new(0, 28, 0, 14)
            Toggle.Parent = Header
            MakeCorner(Toggle, UDim.new(1, 0))
            MakeStroke(Toggle, THEME.BORDER, 0.5, 1)

            local Circle = Instance.new('Frame')
            Circle.AnchorPoint = Vector2.new(0, 0.5)
            Circle.BackgroundColor3 = THEME.TOGGLE_CIRCLE_OFF
            Circle.Position = UDim2.new(0, 1, 0.5, 0)
            Circle.Name = 'Circle'
            Circle.Size = UDim2.new(0, 12, 0, 12)
            Circle.BorderSizePixel = 0
            Circle.Parent = Toggle
            MakeCorner(Circle, UDim.new(1, 0))

            -- Keybind tag
            local Keybind = Instance.new('Frame')
            Keybind.Name = 'Keybind'
            Keybind.BackgroundColor3 = THEME.ACCENT_DIM
            Keybind.BackgroundTransparency = 0.55
            Keybind.Position = UDim2.new(0, 20, 0, 66)
            Keybind.BorderSizePixel = 0
            Keybind.Size = UDim2.new(0, 33, 0, 14)
            Keybind.Parent = Header
            MakeCorner(Keybind, UDim.new(0, 4))

            local KeybindText = Instance.new('TextLabel')
            KeybindText.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            KeybindText.TextColor3 = THEME.ACCENT
            KeybindText.Text = 'None'
            KeybindText.AnchorPoint = Vector2.new(0.5, 0.5)
            KeybindText.Size = UDim2.new(1, -4, 1, 0)
            KeybindText.BackgroundTransparency = 1
            KeybindText.TextXAlignment = Enum.TextXAlignment.Center
            KeybindText.Position = UDim2.new(0.5, 0, 0.5, 0)
            KeybindText.BorderSizePixel = 0
            KeybindText.TextSize = 9
            KeybindText.BackgroundColor3 = Color3.fromRGB(255,255,255)
            KeybindText.Parent = Keybind

            -- Dividers
            local function AddDivider(ypos, parent)
                local d = Instance.new('Frame')
                d.AnchorPoint = Vector2.new(0.5, 0)
                d.BackgroundColor3 = THEME.DIVIDER
                d.BackgroundTransparency = 0.4
                d.Position = UDim2.new(0.5, 0, ypos, 0)
                d.Size = UDim2.new(1, -20, 0, 1)
                d.BorderSizePixel = 0
                d.Name = 'Divider'
                d.Parent = parent or Header
                local dg = Instance.new("UIGradient")
                dg.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.2, 0),
                    NumberSequenceKeypoint.new(0.8, 0),
                    NumberSequenceKeypoint.new(1, 1)
                }
                dg.Parent = d
                return d
            end

            AddDivider(0.62)
            AddDivider(1.0)

            -- Module hover
            Header.MouseEnter:Connect(function()
                TweenQ(Module, 0.25, { BackgroundColor3 = Color3.fromRGB(20, 23, 44) }):Play()
            end)
            Header.MouseLeave:Connect(function()
                TweenQ(Module, 0.25, { BackgroundColor3 = THEME.BG_MODULE }):Play()
            end)

            -- Options container
            local Options = Instance.new('Frame')
            Options.Name = 'Options'
            Options.BackgroundTransparency = 1
            Options.Position = UDim2.new(0, 0, 1, 0)
            Options.BorderSizePixel = 0
            Options.Size = UDim2.new(0, 252, 0, 8)
            Options.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Options.Parent = Module

            local OptPad = Instance.new('UIPadding')
            OptPad.PaddingTop = UDim.new(0, 8)
            OptPad.PaddingBottom = UDim.new(0, 8)
            OptPad.Parent = Options

            local OptList = Instance.new('UIListLayout')
            OptList.Padding = UDim.new(0, 5)
            OptList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            OptList.SortOrder = Enum.SortOrder.LayoutOrder
            OptList.Parent = Options

            -- =============================================
            -- MODULE STATE MANAGEMENT
            -- =============================================
            function ModuleManager:change_state(state)
                self._state = state
                if self._state then
                    TweenQ(Module, 0.45, { Size = UDim2.fromOffset(252, 94 + self._size + self._multiplier) }):Play()
                    TweenQ(Toggle, 0.4, { BackgroundColor3 = THEME.TOGGLE_ON }):Play()
                    TweenQ(Circle, 0.4, { BackgroundColor3 = THEME.TOGGLE_CIRCLE_ON, Position = UDim2.fromScale(0.55, 0.5) }):Play()
                    TweenQ(ModuleAccent, 0.4, { BackgroundTransparency = 0.0, BackgroundColor3 = THEME.ACCENT }):Play()
                else
                    TweenQ(Module, 0.45, { Size = UDim2.fromOffset(252, 94) }):Play()
                    TweenQ(Toggle, 0.4, { BackgroundColor3 = THEME.TOGGLE_OFF }):Play()
                    TweenQ(Circle, 0.4, { BackgroundColor3 = THEME.TOGGLE_CIRCLE_OFF, Position = UDim2.fromScale(0, 0.5) }):Play()
                    TweenQ(ModuleAccent, 0.4, { BackgroundTransparency = 0.4, BackgroundColor3 = THEME.ACCENT }):Play()
                end
                Library._config._flags[settings.flag] = self._state
                Config:save(game.GameId, Library._config)
                settings.callback(self._state)
            end

            function ModuleManager:connect_keybind()
                if not Library._config._keybinds[settings.flag] then return end
                Connections[settings.flag..'_keybind'] = UserInputService.InputBegan:Connect(function(input, process)
                    if process then return end
                    if tostring(input.KeyCode) ~= Library._config._keybinds[settings.flag] then return end
                    self:change_state(not self._state)
                end)
            end

            function ModuleManager:scale_keybind(empty)
                if Library._config._keybinds[settings.flag] and not empty then
                    local ks = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                    local fp = Instance.new('GetTextBoundsParams')
                    fp.Text = ks
                    fp.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold)
                    fp.Size = 9
                    fp.Width = 10000
                    local fs = TextService:GetTextBoundsAsync(fp)
                    Keybind.Size = UDim2.fromOffset(fs.X + 8, 14)
                    KeybindText.Size = UDim2.fromOffset(fs.X + 4, 12)
                else
                    Keybind.Size = UDim2.fromOffset(33, 14)
                    KeybindText.Size = UDim2.fromOffset(29, 12)
                end
            end

            if Library:flag_type(settings.flag, 'boolean') then
                ModuleManager._state = true
                settings.callback(ModuleManager._state)
                Toggle.BackgroundColor3 = THEME.TOGGLE_ON
                Circle.BackgroundColor3 = THEME.TOGGLE_CIRCLE_ON
                Circle.Position = UDim2.fromScale(0.55, 0.5)
                ModuleAccent.BackgroundTransparency = 0.0
            end

            if Library._config._keybinds[settings.flag] then
                local ks = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                KeybindText.Text = ks
                ModuleManager:connect_keybind()
                ModuleManager:scale_keybind()
            end

            Connections[settings.flag..'_input_began'] = Header.InputBegan:Connect(function(input)
                if Library._choosing_keybind then return end
                if input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                Library._choosing_keybind = true
                Connections['keybind_choose_start'] = UserInputService.InputBegan:Connect(function(input, process)
                    if process then return end
                    if input == Enum.UserInputState or input == Enum.UserInputType then return end
                    if input.KeyCode == Enum.KeyCode.Unknown then return end
                    if input.KeyCode == Enum.KeyCode.Backspace then
                        ModuleManager:scale_keybind(true)
                        Library._config._keybinds[settings.flag] = nil
                        Config:save(game.GameId, Library._config)
                        KeybindText.Text = 'None'
                        if Connections[settings.flag..'_keybind'] then
                            Connections[settings.flag..'_keybind']:Disconnect()
                            Connections[settings.flag..'_keybind'] = nil
                        end
                        Connections['keybind_choose_start']:Disconnect()
                        Connections['keybind_choose_start'] = nil
                        Library._choosing_keybind = false
                        return
                    end
                    Connections['keybind_choose_start']:Disconnect()
                    Connections['keybind_choose_start'] = nil
                    Library._config._keybinds[settings.flag] = tostring(input.KeyCode)
                    Config:save(game.GameId, Library._config)
                    if Connections[settings.flag..'_keybind'] then
                        Connections[settings.flag..'_keybind']:Disconnect()
                        Connections[settings.flag..'_keybind'] = nil
                    end
                    ModuleManager:connect_keybind()
                    ModuleManager:scale_keybind()
                    Library._choosing_keybind = false
                    local ks = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                    KeybindText.Text = ks
                end)
            end)

            Header.MouseButton1Click:Connect(function()
                ModuleManager:change_state(not ModuleManager._state)
            end)

            -- =============================================
            -- PARAGRAPH
            -- =============================================
            function ModuleManager:create_paragraph(settings)
                LayoutOrderModule = LayoutOrderModule + 1
                local ParagraphManager = {}
                if self._size == 0 then self._size = 11 end
                self._size += settings.customScale or 68
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(252, 94 + self._size)
                end
                Options.Size = UDim2.fromOffset(252, self._size)

                local Para = Instance.new('Frame')
                Para.BackgroundColor3 = THEME.BG_TERTIARY
                Para.BackgroundTransparency = 0.2
                Para.Size = UDim2.new(0, 218, 0, 30)
                Para.BorderSizePixel = 0
                Para.Name = "Paragraph"
                Para.AutomaticSize = Enum.AutomaticSize.Y
                Para.Parent = Options
                Para.LayoutOrder = LayoutOrderModule
                MakeCorner(Para, UDim.new(0, 5))

                local ParaTitle = Instance.new('TextLabel')
                ParaTitle.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                ParaTitle.TextColor3 = THEME.TEXT_PRIMARY
                ParaTitle.Text = settings.title or "Title"
                ParaTitle.Size = UDim2.new(1, -10, 0, 20)
                ParaTitle.Position = UDim2.new(0, 8, 0, 5)
                ParaTitle.BackgroundTransparency = 1
                ParaTitle.TextXAlignment = Enum.TextXAlignment.Left
                ParaTitle.TextYAlignment = Enum.TextYAlignment.Center
                ParaTitle.TextSize = 12
                ParaTitle.AutomaticSize = Enum.AutomaticSize.XY
                ParaTitle.Parent = Para

                local ParaBody = Instance.new('TextLabel')
                ParaBody.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                ParaBody.TextColor3 = THEME.TEXT_SECONDARY
                if not settings.rich then
                    ParaBody.Text = settings.text or ""
                else
                    ParaBody.RichText = true
                    ParaBody.Text = settings.richtext or ""
                end
                ParaBody.Size = UDim2.new(1, -10, 0, 20)
                ParaBody.Position = UDim2.new(0, 8, 0, 28)
                ParaBody.BackgroundTransparency = 1
                ParaBody.TextXAlignment = Enum.TextXAlignment.Left
                ParaBody.TextYAlignment = Enum.TextYAlignment.Top
                ParaBody.TextSize = 10
                ParaBody.TextWrapped = true
                ParaBody.AutomaticSize = Enum.AutomaticSize.XY
                ParaBody.Parent = Para

                Para.MouseEnter:Connect(function()
                    TweenQ(Para, 0.25, { BackgroundColor3 = Color3.fromRGB(28, 34, 62), BackgroundTransparency = 0.0 }):Play()
                end)
                Para.MouseLeave:Connect(function()
                    TweenQ(Para, 0.25, { BackgroundColor3 = THEME.BG_TERTIARY, BackgroundTransparency = 0.2 }):Play()
                end)

                return ParagraphManager
            end

            -- =============================================
            -- TEXT
            -- =============================================
            function ModuleManager:create_text(settings)
                LayoutOrderModule = LayoutOrderModule + 1
                local TextManager = {}
                if self._size == 0 then self._size = 11 end
                self._size += settings.customScale or 48
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(252, 94 + self._size)
                end
                Options.Size = UDim2.fromOffset(252, self._size)

                local TextFrame = Instance.new('Frame')
                TextFrame.BackgroundColor3 = THEME.BG_TERTIARY
                TextFrame.BackgroundTransparency = 0.25
                TextFrame.Size = UDim2.new(0, 218, 0, settings.CustomYSize or 30)
                TextFrame.BorderSizePixel = 0
                TextFrame.Name = "Text"
                TextFrame.AutomaticSize = Enum.AutomaticSize.Y
                TextFrame.Parent = Options
                TextFrame.LayoutOrder = LayoutOrderModule
                MakeCorner(TextFrame, UDim.new(0, 5))

                local TFBody = Instance.new('TextLabel')
                TFBody.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                TFBody.TextColor3 = THEME.TEXT_SECONDARY
                if not settings.rich then
                    TFBody.Text = settings.text or ""
                else
                    TFBody.RichText = true
                    TFBody.Text = settings.richtext or ""
                end
                TFBody.Size = UDim2.new(1, -10, 1, 0)
                TFBody.Position = UDim2.new(0, 8, 0, 6)
                TFBody.BackgroundTransparency = 1
                TFBody.TextXAlignment = Enum.TextXAlignment.Left
                TFBody.TextYAlignment = Enum.TextYAlignment.Top
                TFBody.TextSize = 10
                TFBody.TextWrapped = true
                TFBody.AutomaticSize = Enum.AutomaticSize.XY
                TFBody.Parent = TextFrame

                TextFrame.MouseEnter:Connect(function()
                    TweenQ(TextFrame, 0.25, { BackgroundTransparency = 0.0 }):Play()
                end)
                TextFrame.MouseLeave:Connect(function()
                    TweenQ(TextFrame, 0.25, { BackgroundTransparency = 0.25 }):Play()
                end)

                function TextManager:Set(new_settings)
                    if not new_settings.rich then
                        TFBody.Text = new_settings.text or ""
                    else
                        TFBody.RichText = true
                        TFBody.Text = new_settings.richtext or ""
                    end
                end

                return TextManager
            end

            -- =============================================
            -- TEXTBOX
            -- =============================================
            function ModuleManager:create_textbox(settings)
                LayoutOrderModule = LayoutOrderModule + 1
                local TextboxManager = { _text = "" }
                if self._size == 0 then self._size = 11 end
                self._size += 34
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(252, 94 + self._size)
                end
                Options.Size = UDim2.fromOffset(252, self._size)

                local TbLabel = Instance.new('TextLabel')
                TbLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                TbLabel.TextColor3 = THEME.TEXT_SECONDARY
                TbLabel.TextTransparency = 0.1
                TbLabel.Text = settings.title or "Enter text"
                TbLabel.Size = UDim2.new(0, 218, 0, 13)
                TbLabel.Position = UDim2.new(0, 0, 0, 0)
                TbLabel.BackgroundTransparency = 1
                TbLabel.TextXAlignment = Enum.TextXAlignment.Left
                TbLabel.BorderSizePixel = 0
                TbLabel.Parent = Options
                TbLabel.TextSize = 10
                TbLabel.LayoutOrder = LayoutOrderModule

                local Textbox = Instance.new('TextBox')
                Textbox.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Textbox.TextColor3 = THEME.TEXT_PRIMARY
                Textbox.PlaceholderColor3 = THEME.TEXT_MUTED
                Textbox.BorderColor3 = Color3.fromRGB(0,0,0)
                Textbox.PlaceholderText = settings.placeholder or "Type here..."
                Textbox.Text = Library._config._flags[settings.flag] or ""
                Textbox.Name = 'Textbox'
                Textbox.Size = UDim2.new(0, 218, 0, 18)
                Textbox.BorderSizePixel = 0
                Textbox.TextSize = 10
                Textbox.BackgroundColor3 = THEME.BG_TERTIARY
                Textbox.BackgroundTransparency = 0.0
                Textbox.ClearTextOnFocus = false
                Textbox.Parent = Options
                Textbox.LayoutOrder = LayoutOrderModule
                MakeCorner(Textbox, UDim.new(0, 5))
                MakeStroke(Textbox, THEME.BORDER, 0.5, 1)

                Textbox.Focused:Connect(function()
                    TweenQ(Textbox, 0.2, { BackgroundColor3 = Color3.fromRGB(22, 26, 50) }):Play()
                end)
                Textbox.FocusLost:Connect(function()
                    TweenQ(Textbox, 0.2, { BackgroundColor3 = THEME.BG_TERTIARY }):Play()
                    TextboxManager._text = Textbox.Text
                    Library._config._flags[settings.flag] = TextboxManager._text
                    Config:save(game.GameId, Library._config)
                    settings.callback(TextboxManager._text)
                end)

                if Library:flag_type(settings.flag, 'string') then
                    TextboxManager._text = Library._config._flags[settings.flag]
                    settings.callback(TextboxManager._text)
                end

                return TextboxManager
            end

            -- =============================================
            -- CHECKBOX
            -- =============================================
            function ModuleManager:create_checkbox(settings)
                LayoutOrderModule = LayoutOrderModule + 1
                local CheckboxManager = { _state = false }
                if self._size == 0 then self._size = 11 end
                self._size += 22
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(252, 94 + self._size)
                end
                Options.Size = UDim2.fromOffset(252, self._size)

                local CB = Instance.new("TextButton")
                CB.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                CB.TextColor3 = Color3.fromRGB(0,0,0)
                CB.Text = ""
                CB.AutoButtonColor = false
                CB.BackgroundTransparency = 1
                CB.Name = "Checkbox"
                CB.Size = UDim2.new(0, 218, 0, 18)
                CB.BorderSizePixel = 0
                CB.TextSize = 14
                CB.BackgroundColor3 = Color3.fromRGB(0,0,0)
                CB.Parent = Options
                CB.LayoutOrder = LayoutOrderModule

                local CBTitle = Instance.new("TextLabel")
                CBTitle.Name = "TitleLabel"
                if SelectedLanguage == "th" then
                    CBTitle.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    CBTitle.TextSize = 13
                else
                    CBTitle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    CBTitle.TextSize = 11
                end
                CBTitle.TextColor3 = THEME.TEXT_PRIMARY
                CBTitle.TextTransparency = 0.0
                CBTitle.Text = settings.title or "Option"
                CBTitle.Size = UDim2.new(0, 148, 0, 14)
                CBTitle.AnchorPoint = Vector2.new(0, 0.5)
                CBTitle.Position = UDim2.new(0, 0, 0.5, 0)
                CBTitle.BackgroundTransparency = 1
                CBTitle.TextXAlignment = Enum.TextXAlignment.Left
                CBTitle.Parent = CB

                -- Keybind box
                local CBKeybindBox = Instance.new("Frame")
                CBKeybindBox.Name = "KeybindBox"
                CBKeybindBox.Size = UDim2.fromOffset(30, 14)
                CBKeybindBox.Position = UDim2.new(1, -50, 0.5, 0)
                CBKeybindBox.AnchorPoint = Vector2.new(0, 0.5)
                CBKeybindBox.BackgroundColor3 = THEME.ACCENT_DIM
                CBKeybindBox.BackgroundTransparency = 0.6
                CBKeybindBox.BorderSizePixel = 0
                CBKeybindBox.Parent = CB
                MakeCorner(CBKeybindBox, UDim.new(0, 4))

                local CBKeybindLabel = Instance.new("TextLabel")
                CBKeybindLabel.Size = UDim2.new(1, 0, 1, 0)
                CBKeybindLabel.BackgroundTransparency = 1
                CBKeybindLabel.TextColor3 = THEME.ACCENT
                CBKeybindLabel.TextSize = 9
                CBKeybindLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                CBKeybindLabel.Text = Library._config._keybinds[settings.flag]
                    and string.gsub(tostring(Library._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                    or "..."
                CBKeybindLabel.Parent = CBKeybindBox

                -- Checkbox box (modern)
                local CBBox = Instance.new("Frame")
                CBBox.AnchorPoint = Vector2.new(1, 0.5)
                CBBox.BackgroundColor3 = THEME.BG_TERTIARY
                CBBox.BackgroundTransparency = 0.0
                CBBox.Position = UDim2.new(1, 0, 0.5, 0)
                CBBox.Name = "Box"
                CBBox.Size = UDim2.new(0, 16, 0, 16)
                CBBox.BorderSizePixel = 0
                CBBox.Parent = CB
                MakeCorner(CBBox, UDim.new(0, 4))
                MakeStroke(CBBox, THEME.ACCENT, 0.5, 1)

                local CBFill = Instance.new("Frame")
                CBFill.AnchorPoint = Vector2.new(0.5, 0.5)
                CBFill.BackgroundColor3 = THEME.ACCENT
                CBFill.BackgroundTransparency = 0.0
                CBFill.Position = UDim2.new(0.5, 0, 0.5, 0)
                CBFill.BorderSizePixel = 0
                CBFill.Name = "Fill"
                CBFill.Size = UDim2.fromOffset(0, 0)
                CBFill.Parent = CBBox
                MakeCorner(CBFill, UDim.new(0, 3))

                function CheckboxManager:change_state(state)
                    self._state = state
                    if self._state then
                        TweenQ(CBBox, 0.35, { BackgroundColor3 = THEME.ACCENT, BackgroundTransparency = 0.7 }):Play()
                        TweenQ(CBFill, 0.35, { Size = UDim2.fromOffset(9, 9) }):Play()
                    else
                        TweenQ(CBBox, 0.35, { BackgroundColor3 = THEME.BG_TERTIARY, BackgroundTransparency = 0.0 }):Play()
                        TweenQ(CBFill, 0.35, { Size = UDim2.fromOffset(0, 0) }):Play()
                    end
                    Library._config._flags[settings.flag] = self._state
                    Config:save(game.GameId, Library._config)
                    settings.callback(self._state)
                end

                if Library:flag_type(settings.flag, "boolean") then
                    CheckboxManager:change_state(Library._config._flags[settings.flag])
                end

                CB.MouseButton1Click:Connect(function()
                    CheckboxManager:change_state(not CheckboxManager._state)
                end)

                CB.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                    if Library._choosing_keybind then return end
                    Library._choosing_keybind = true
                    local cc
                    cc = UserInputService.InputBegan:Connect(function(ki, proc)
                        if proc then return end
                        if ki.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if ki.KeyCode == Enum.KeyCode.Unknown then return end
                        if ki.KeyCode == Enum.KeyCode.Backspace then
                            Library._config._keybinds[settings.flag] = nil
                            Config:save(game.GameId, Library._config)
                            CBKeybindLabel.Text = "..."
                            if Connections[settings.flag.."_keybind"] then
                                Connections[settings.flag.."_keybind"]:Disconnect()
                                Connections[settings.flag.."_keybind"] = nil
                            end
                            cc:Disconnect()
                            Library._choosing_keybind = false
                            return
                        end
                        cc:Disconnect()
                        Library._config._keybinds[settings.flag] = tostring(ki.KeyCode)
                        Config:save(game.GameId, Library._config)
                        if Connections[settings.flag.."_keybind"] then
                            Connections[settings.flag.."_keybind"]:Disconnect()
                            Connections[settings.flag.."_keybind"] = nil
                        end
                        Library._choosing_keybind = false
                        local ks = string.gsub(tostring(Library._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                        CBKeybindLabel.Text = ks
                    end)
                end)

                local kpc = UserInputService.InputBegan:Connect(function(input, proc)
                    if proc then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local sk = Library._config._keybinds[settings.flag]
                        if sk and tostring(input.KeyCode) == sk then
                            CheckboxManager:change_state(not CheckboxManager._state)
                        end
                    end
                end)
                Connections[settings.flag.."_keypress"] = kpc

                return CheckboxManager
            end

            -- =============================================
            -- DIVIDER
            -- =============================================
            function ModuleManager:create_divider(settings)
                LayoutOrderModule = LayoutOrderModule + 1
                if self._size == 0 then self._size = 11 end
                self._size += 24
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(252, 94 + self._size)
                end

                local OuterFrame = Instance.new('Frame')
                OuterFrame.Size = UDim2.new(0, 218, 0, 18)
                OuterFrame.BackgroundTransparency = 1
                OuterFrame.Name = 'OuterFrame'
                OuterFrame.Parent = Options
                OuterFrame.LayoutOrder = LayoutOrderModule

                if settings and settings.showtopic then
                    local DivText = Instance.new('TextLabel')
                    DivText.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    DivText.TextColor3 = THEME.ACCENT
                    DivText.TextTransparency = 0.2
                    DivText.Text = settings.title or ""
                    DivText.Size = UDim2.new(0, 100, 0, 14)
                    DivText.Position = UDim2.new(0.5, 0, 0.5, 0)
                    DivText.BackgroundTransparency = 1
                    DivText.TextXAlignment = Enum.TextXAlignment.Center
                    DivText.AnchorPoint = Vector2.new(0.5, 0.5)
                    DivText.TextSize = 10
                    DivText.ZIndex = 3
                    DivText.Parent = OuterFrame
                end

                if not settings or not settings.disableline then
                    local DivLine = Instance.new('Frame')
                    DivLine.Size = UDim2.new(1, 0, 0, 1)
                    DivLine.BackgroundColor3 = THEME.DIVIDER
                    DivLine.BackgroundTransparency = 0.2
                    DivLine.BorderSizePixel = 0
                    DivLine.Name = 'Divider'
                    DivLine.ZIndex = 2
                    DivLine.Position = UDim2.new(0, 0, 0.5, 0)
                    DivLine.Parent = OuterFrame
                    MakeCorner(DivLine, UDim.new(1, 0))
                    local dg = Instance.new('UIGradient')
                    dg.Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.15, 0),
                        NumberSequenceKeypoint.new(0.85, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }
                    dg.Parent = DivLine
                end

                return true
            end

            -- =============================================
            -- SLIDER
            -- =============================================
            function ModuleManager:create_slider(settings)
                LayoutOrderModule = LayoutOrderModule + 1
                local SliderManager = {}
                if self._size == 0 then self._size = 11 end
                self._size += 30
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(252, 94 + self._size)
                end
                Options.Size = UDim2.fromOffset(252, self._size)

                local SliderFrame = Instance.new('Frame')
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Name = 'Slider'
                SliderFrame.Size = UDim2.new(0, 218, 0, 25)
                SliderFrame.BorderSizePixel = 0
                SliderFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
                SliderFrame.Parent = Options
                SliderFrame.LayoutOrder = LayoutOrderModule

                local SliderLabel = Instance.new('TextLabel')
                if SelectedLanguage == "th" then
                    SliderLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    SliderLabel.TextSize = 13
                else
                    SliderLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    SliderLabel.TextSize = 11
                end
                SliderLabel.TextColor3 = THEME.TEXT_SECONDARY
                SliderLabel.TextTransparency = 0.1
                SliderLabel.Text = settings.title
                SliderLabel.Size = UDim2.new(0, 160, 0, 14)
                SliderLabel.Position = UDim2.new(0, 0, 0, 0)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.BorderSizePixel = 0
                SliderLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
                SliderLabel.Parent = SliderFrame

                local SliderValue = Instance.new('TextLabel')
                SliderValue.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                SliderValue.TextColor3 = THEME.ACCENT
                SliderValue.TextTransparency = 0.0
                SliderValue.Text = '50'
                SliderValue.Name = 'Value'
                SliderValue.Size = UDim2.new(0, 48, 0, 14)
                SliderValue.AnchorPoint = Vector2.new(1, 0)
                SliderValue.Position = UDim2.new(1, 0, 0, 0)
                SliderValue.BackgroundTransparency = 1
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.BorderSizePixel = 0
                SliderValue.TextSize = 11
                SliderValue.BackgroundColor3 = Color3.fromRGB(255,255,255)
                SliderValue.Parent = SliderFrame

                -- Track
                local Track = Instance.new('Frame')
                Track.AnchorPoint = Vector2.new(0.5, 1)
                Track.BackgroundColor3 = THEME.BG_TERTIARY
                Track.BackgroundTransparency = 0.0
                Track.Position = UDim2.new(0.5, 0, 1, 0)
                Track.Name = 'Drag'
                Track.Size = UDim2.new(1, 0, 0, 5)
                Track.BorderSizePixel = 0
                Track.Parent = SliderFrame
                MakeCorner(Track, UDim.new(1, 0))
                MakeStroke(Track, THEME.BORDER, 0.6, 1)

                -- Fill
                local Fill = Instance.new('Frame')
                Fill.AnchorPoint = Vector2.new(0, 0.5)
                Fill.BackgroundColor3 = THEME.ACCENT
                Fill.BackgroundTransparency = 0.0
                Fill.Position = UDim2.new(0, 0, 0.5, 0)
                Fill.Name = 'Fill'
                Fill.Size = UDim2.new(0.5, 0, 1, 0)
                Fill.BorderSizePixel = 0
                Fill.Parent = Track
                MakeCorner(Fill, UDim.new(1, 0))

                local FillGrad = Instance.new('UIGradient')
                FillGrad.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, THEME.ACCENT),
                    ColorSequenceKeypoint.new(1, THEME.ACCENT_SECONDARY)
                }
                FillGrad.Parent = Fill

                -- Circle handle
                local Handle = Instance.new('Frame')
                Handle.AnchorPoint = Vector2.new(1, 0.5)
                Handle.Name = 'Circle'
                Handle.Position = UDim2.new(1, 0, 0.5, 0)
                Handle.BorderSizePixel = 0
                Handle.Size = UDim2.new(0, 10, 0, 10)
                Handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
                Handle.Parent = Fill
                MakeCorner(Handle, UDim.new(1, 0))

                local HandleGlow = Instance.new("UIStroke")
                HandleGlow.Color = THEME.ACCENT
                HandleGlow.Thickness = 2
                HandleGlow.Transparency = 0.5
                HandleGlow.Parent = Handle

                function SliderManager:set_percentage(percentage)
                    local rounded = settings.round_number and math.floor(percentage) or (math.floor(percentage * 10) / 10)
                    local pct = (percentage - settings.minimum_value) / (settings.maximum_value - settings.minimum_value)
                    local slider_size = math.clamp(pct, 0.02, 1) * Track.Size.X.Offset
                    local clamped = math.clamp(rounded, settings.minimum_value, settings.maximum_value)
                    Library._config._flags[settings.flag] = clamped
                    SliderValue.Text = tostring(clamped)
                    TweenQ(Fill, 0.4, { Size = UDim2.fromOffset(slider_size, Track.Size.Y.Offset) }):Play()
                    settings.callback(clamped)
                end

                function SliderManager:update()
                    local mp = (mouse.X - Track.AbsolutePosition.X) / Track.Size.X.Offset
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
                        if not settings.ignoresaved then
                            Config:save(game.GameId, Library._config)
                        end
                    end)
                end

                if Library:flag_type(settings.flag, 'number') then
                    if not settings.ignoresaved then
                        SliderManager:set_percentage(Library._config._flags[settings.flag])
                    else
                        SliderManager:set_percentage(settings.value)
                    end
                else
                    SliderManager:set_percentage(settings.value)
                end

                SliderFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        SliderManager:input()
                    end
                end)

                return SliderManager
            end

            -- =============================================
            -- DROPDOWN
            -- =============================================
            function ModuleManager:create_dropdown(settings)
                if not settings.Order then
                    LayoutOrderModule = LayoutOrderModule + 1
                end
                local DropdownManager = { _state=false, _size=0 }

                if not settings.Order then
                    if self._size == 0 then self._size = 11 end
                    self._size += 44
                end

                if not settings.Order then
                    if ModuleManager._state then
                        Module.Size = UDim2.fromOffset(252, 94 + self._size)
                    end
                    Options.Size = UDim2.fromOffset(252, self._size)
                end

                if not Library._config._flags[settings.flag] then
                    Library._config._flags[settings.flag] = {}
                end

                local DropFrame = Instance.new('Frame')
                DropFrame.BackgroundTransparency = 1
                DropFrame.Name = 'Dropdown'
                DropFrame.Size = UDim2.new(0, 218, 0, 39)
                DropFrame.BorderSizePixel = 0
                DropFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
                DropFrame.Parent = Options

                if not settings.Order then
                    DropFrame.LayoutOrder = LayoutOrderModule
                else
                    DropFrame.LayoutOrder = settings.OrderValue
                end

                local DropLabel = Instance.new('TextLabel')
                if SelectedLanguage == "th" then
                    DropLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    DropLabel.TextSize = 13
                else
                    DropLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    DropLabel.TextSize = 11
                end
                DropLabel.TextColor3 = THEME.TEXT_SECONDARY
                DropLabel.TextTransparency = 0.1
                DropLabel.Text = settings.title
                DropLabel.Size = UDim2.new(1, 0, 0, 14)
                DropLabel.Position = UDim2.new(0, 0, 0, 0)
                DropLabel.BackgroundTransparency = 1
                DropLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropLabel.BorderSizePixel = 0
                DropLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
                DropLabel.Parent = DropFrame

                local DropBox = Instance.new('Frame')
                DropBox.ClipsDescendants = true
                DropBox.AnchorPoint = Vector2.new(0, 0)
                DropBox.BackgroundColor3 = THEME.BG_TERTIARY
                DropBox.BackgroundTransparency = 0.0
                DropBox.Position = UDim2.new(0, 0, 0, 16)
                DropBox.Name = 'Box'
                DropBox.Size = UDim2.new(1, 0, 0, 22)
                DropBox.BorderSizePixel = 0
                DropBox.Parent = DropFrame
                MakeCorner(DropBox, UDim.new(0, 6))
                MakeStroke(DropBox, THEME.BORDER, 0.5, 1)

                local DropHeader = Instance.new('Frame')
                DropHeader.BackgroundTransparency = 1
                DropHeader.AnchorPoint = Vector2.new(0, 0)
                DropHeader.Position = UDim2.new(0, 0, 0, 0)
                DropHeader.Name = 'Header'
                DropHeader.Size = UDim2.new(1, 0, 0, 22)
                DropHeader.BorderSizePixel = 0
                DropHeader.BackgroundColor3 = Color3.fromRGB(255,255,255)
                DropHeader.Parent = DropBox

                local CurrentOption = Instance.new('TextLabel')
                CurrentOption.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                CurrentOption.TextColor3 = THEME.TEXT_PRIMARY
                CurrentOption.TextTransparency = 0.05
                CurrentOption.Name = 'CurrentOption'
                CurrentOption.Size = UDim2.new(0, 168, 0, 14)
                CurrentOption.AnchorPoint = Vector2.new(0, 0.5)
                CurrentOption.Position = UDim2.new(0, 10, 0.5, 0)
                CurrentOption.BackgroundTransparency = 1
                CurrentOption.TextXAlignment = Enum.TextXAlignment.Left
                CurrentOption.BorderSizePixel = 0
                CurrentOption.TextSize = 10
                CurrentOption.BackgroundColor3 = Color3.fromRGB(255,255,255)
                CurrentOption.Parent = DropHeader

                local DropArrow = Instance.new('ImageLabel')
                DropArrow.Image = 'rbxassetid://84232453189324'
                DropArrow.BackgroundTransparency = 1
                DropArrow.AnchorPoint = Vector2.new(0, 0.5)
                DropArrow.Position = UDim2.new(1, -14, 0.5, 0)
                DropArrow.Name = 'Arrow'
                DropArrow.Size = UDim2.new(0, 8, 0, 8)
                DropArrow.BorderSizePixel = 0
                DropArrow.ImageColor3 = THEME.ACCENT
                DropArrow.BackgroundColor3 = Color3.fromRGB(255,255,255)
                DropArrow.Parent = DropHeader

                local DropOptions = Instance.new('ScrollingFrame')
                DropOptions.ScrollBarImageColor3 = THEME.ACCENT
                DropOptions.Active = true
                DropOptions.ScrollBarImageTransparency = 0.6
                DropOptions.AutomaticCanvasSize = Enum.AutomaticSize.XY
                DropOptions.ScrollBarThickness = 2
                DropOptions.Name = 'Options'
                DropOptions.Size = UDim2.new(1, 0, 0, 0)
                DropOptions.BackgroundTransparency = 1
                DropOptions.Position = UDim2.new(0, 0, 1, 0)
                DropOptions.BackgroundColor3 = Color3.fromRGB(255,255,255)
                DropOptions.BorderSizePixel = 0
                DropOptions.CanvasSize = UDim2.new(0,0,0.5,0)
                DropOptions.Parent = DropBox

                local DropOptList = Instance.new('UIListLayout')
                DropOptList.SortOrder = Enum.SortOrder.LayoutOrder
                DropOptList.Parent = DropOptions

                local DropOptPad = Instance.new('UIPadding')
                DropOptPad.PaddingTop = UDim.new(0, 2)
                DropOptPad.PaddingLeft = UDim.new(0, 10)
                DropOptPad.Parent = DropOptions

                local DropBoxList = Instance.new('UIListLayout')
                DropBoxList.SortOrder = Enum.SortOrder.LayoutOrder
                DropBoxList.Parent = DropBox

                function DropdownManager:update(option)
                    if settings.multi_dropdown then
                        if not Library._config._flags[settings.flag] then
                            Library._config._flags[settings.flag] = {}
                        end
                        local CurrentTargetValue = nil
                        if #Library._config._flags[settings.flag] > 0 then
                            CurrentTargetValue = convertTableToString(Library._config._flags[settings.flag])
                        end
                        local selected = {}
                        if CurrentTargetValue then
                            for value in string.gmatch(CurrentTargetValue, "([^,]+)") do
                                local tv = value:match("^%s*(.-)%s*$")
                                if tv ~= "Label" then table.insert(selected, tv) end
                            end
                        else
                            for value in string.gmatch(CurrentOption.Text, "([^,]+)") do
                                local tv = value:match("^%s*(.-)%s*$")
                                if tv ~= "Label" then table.insert(selected, tv) end
                            end
                        end
                        local optName = typeof(option) ~= 'string' and option.Name or option
                        local ct = convertStringToTable(CurrentOption.Text)
                        for i, v in pairs(ct) do
                            if v == optName then table.remove(ct, i); break end
                        end
                        CurrentOption.Text = table.concat(selected, ", ")
                        local OC = {}
                        for _, object in DropOptions:GetChildren() do
                            if object.Name == "Option" then
                                table.insert(OC, object.Text)
                                if table.find(selected, object.Text) then
                                    object.TextTransparency = 0.1
                                else
                                    object.TextTransparency = 0.55
                                end
                            end
                        end
                        local ctv = convertStringToTable(CurrentOption.Text)
                        for i, v in ctv do
                            if not table.find(OC, v) and table.find(selected, v) then
                                table.remove(selected, i)
                            end
                        end
                        CurrentOption.Text = table.concat(selected, ", ")
                        Library._config._flags[settings.flag] = convertStringToTable(CurrentOption.Text)
                    else
                        CurrentOption.Text = (typeof(option) == "string" and option) or option.Name
                        for _, object in DropOptions:GetChildren() do
                            if object.Name == "Option" then
                                object.TextTransparency = (object.Text == CurrentOption.Text) and 0.1 or 0.55
                            end
                        end
                        Library._config._flags[settings.flag] = option
                    end
                    Config:save(game.GameId, Library._config)
                    settings.callback(option)
                end

                local CurrentDropSizeState = 0

                function DropdownManager:unfold_settings()
                    self._state = not self._state
                    if self._state then
                        ModuleManager._multiplier += self._size
                        CurrentDropSizeState = self._size
                        TweenQ(Module, 0.45, { Size = UDim2.fromOffset(252, 94 + ModuleManager._size + ModuleManager._multiplier) }):Play()
                        TweenQ(Module.Options, 0.45, { Size = UDim2.fromOffset(252, ModuleManager._size + ModuleManager._multiplier) }):Play()
                        TweenQ(DropFrame, 0.45, { Size = UDim2.fromOffset(218, 39 + self._size) }):Play()
                        TweenQ(DropBox, 0.45, { Size = UDim2.fromOffset(218, 22 + self._size) }):Play()
                        TweenQ(DropArrow, 0.35, { Rotation = 180 }):Play()
                    else
                        ModuleManager._multiplier -= self._size
                        CurrentDropSizeState = 0
                        TweenQ(Module, 0.45, { Size = UDim2.fromOffset(252, 94 + ModuleManager._size + ModuleManager._multiplier) }):Play()
                        TweenQ(Module.Options, 0.45, { Size = UDim2.fromOffset(252, ModuleManager._size + ModuleManager._multiplier) }):Play()
                        TweenQ(DropFrame, 0.45, { Size = UDim2.fromOffset(218, 39) }):Play()
                        TweenQ(DropBox, 0.45, { Size = UDim2.fromOffset(218, 22) }):Play()
                        TweenQ(DropArrow, 0.35, { Rotation = 0 }):Play()
                    end
                end

                if #settings.options > 0 then
                    DropdownManager._size = 4
                    for index, value in settings.options do
                        local Opt = Instance.new('TextButton')
                        Opt.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                        Opt.Active = false
                        Opt.TextTransparency = 0.55
                        Opt.AnchorPoint = Vector2.new(0, 0.5)
                        Opt.TextSize = 10
                        Opt.Size = UDim2.new(0, 196, 0, 16)
                        Opt.TextColor3 = THEME.TEXT_PRIMARY
                        Opt.Text = (typeof(value) == "string" and value) or value.Name
                        Opt.AutoButtonColor = false
                        Opt.Name = 'Option'
                        Opt.BackgroundTransparency = 1
                        Opt.TextXAlignment = Enum.TextXAlignment.Left
                        Opt.Selectable = false
                        Opt.BorderSizePixel = 0
                        Opt.BackgroundColor3 = Color3.fromRGB(255,255,255)
                        Opt.Parent = DropOptions

                        Opt.MouseEnter:Connect(function()
                            TweenQ(Opt, 0.15, { TextColor3 = THEME.ACCENT }):Play()
                        end)
                        Opt.MouseLeave:Connect(function()
                            TweenQ(Opt, 0.15, { TextColor3 = THEME.TEXT_PRIMARY }):Play()
                        end)

                        Opt.MouseButton1Click:Connect(function()
                            if not Library._config._flags[settings.flag] then
                                Library._config._flags[settings.flag] = {}
                            end
                            if settings.multi_dropdown then
                                if table.find(Library._config._flags[settings.flag], value) then
                                    Library:remove_table_value(Library._config._flags[settings.flag], value)
                                else
                                    table.insert(Library._config._flags[settings.flag], value)
                                end
                            end
                            DropdownManager:update(value)
                        end)

                        if index > settings.maximum_options then continue end
                        DropdownManager._size += 16
                        DropOptions.Size = UDim2.fromOffset(218, DropdownManager._size)
                    end
                end

                function DropdownManager:New(value)
                    DropFrame:Destroy()
                    value.OrderValue = DropFrame.LayoutOrder
                    ModuleManager._multiplier -= CurrentDropSizeState
                    return ModuleManager:create_dropdown(value)
                end

                if Library:flag_type(settings.flag, 'string') then
                    DropdownManager:update(Library._config._flags[settings.flag])
                else
                    DropdownManager:update(settings.options[1])
                end

                -- Click on box header
                DropHeader.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        DropdownManager:unfold_settings()
                    end
                end)

                return DropdownManager
            end

            -- =============================================
            -- FEATURE (checkbox + keybind combo)
            -- =============================================
            function ModuleManager:create_feature(settings)
                local checked = false
                LayoutOrderModule = LayoutOrderModule + 1
                if self._size == 0 then self._size = 11 end
                self._size += 22
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(252, 94 + self._size)
                end
                Options.Size = UDim2.fromOffset(252, self._size)

                local FeatContainer = Instance.new("Frame")
                FeatContainer.Size = UDim2.new(0, 218, 0, 18)
                FeatContainer.BackgroundTransparency = 1
                FeatContainer.Parent = Options
                FeatContainer.LayoutOrder = LayoutOrderModule

                local FeatLayout = Instance.new("UIListLayout")
                FeatLayout.FillDirection = Enum.FillDirection.Horizontal
                FeatLayout.SortOrder = Enum.SortOrder.LayoutOrder
                FeatLayout.Parent = FeatContainer

                local FeatButton = Instance.new("TextButton")
                FeatButton.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                FeatButton.TextSize = 11
                FeatButton.Size = UDim2.new(1, -38, 0, 18)
                FeatButton.BackgroundColor3 = THEME.BG_TERTIARY
                FeatButton.BackgroundTransparency = 0.3
                FeatButton.TextColor3 = THEME.TEXT_PRIMARY
                FeatButton.Text = "  " .. (settings.title or "Feature")
                FeatButton.AutoButtonColor = false
                FeatButton.TextXAlignment = Enum.TextXAlignment.Left
                FeatButton.TextTransparency = 0.0
                FeatButton.Parent = FeatContainer
                MakeCorner(FeatButton, UDim.new(0, 5))

                FeatButton.MouseEnter:Connect(function()
                    TweenQ(FeatButton, 0.2, { BackgroundTransparency = 0.1 }):Play()
                end)
                FeatButton.MouseLeave:Connect(function()
                    TweenQ(FeatButton, 0.2, { BackgroundTransparency = 0.3 }):Play()
                end)

                local RightContainer = Instance.new("Frame")
                RightContainer.Size = UDim2.new(0, 38, 0, 18)
                RightContainer.BackgroundTransparency = 1
                RightContainer.Parent = FeatContainer

                local RightLayout = Instance.new("UIListLayout")
                RightLayout.Padding = UDim.new(0, 2)
                RightLayout.FillDirection = Enum.FillDirection.Horizontal
                RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
                RightLayout.Parent = RightContainer

                local FeatKeybindBox = Instance.new("TextLabel")
                FeatKeybindBox.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                FeatKeybindBox.Size = UDim2.new(0, 16, 0, 16)
                FeatKeybindBox.BackgroundColor3 = THEME.ACCENT_DIM
                FeatKeybindBox.BackgroundTransparency = 0.5
                FeatKeybindBox.TextColor3 = THEME.ACCENT
                FeatKeybindBox.TextSize = 9
                FeatKeybindBox.LayoutOrder = 2
                FeatKeybindBox.Parent = RightContainer
                MakeCorner(FeatKeybindBox, UDim.new(0, 4))
                MakeStroke(FeatKeybindBox, THEME.ACCENT, 0.5, 1)

                local FeatKeybindBtn = Instance.new("TextButton")
                FeatKeybindBtn.Size = UDim2.new(1,0,1,0)
                FeatKeybindBtn.BackgroundTransparency = 1
                FeatKeybindBtn.TextTransparency = 1
                FeatKeybindBtn.Text = ""
                FeatKeybindBtn.Parent = FeatKeybindBox

                if not Library._config._flags then Library._config._flags = {} end
                if not Library._config._flags[settings.flag] then
                    Library._config._flags[settings.flag] = { checked=false, BIND=settings.default or "Unknown" }
                end

                checked = Library._config._flags[settings.flag].checked
                FeatKeybindBox.Text = Library._config._flags[settings.flag].BIND
                if FeatKeybindBox.Text == "Unknown" then FeatKeybindBox.Text = "..." end

                local UseF_Var = nil

                if not settings.disablecheck then
                    local FeatCheckbox = Instance.new("TextButton")
                    FeatCheckbox.Size = UDim2.new(0, 16, 0, 16)
                    FeatCheckbox.BackgroundColor3 = checked and THEME.ACCENT or THEME.BG_TERTIARY
                    FeatCheckbox.Text = ""
                    FeatCheckbox.Parent = RightContainer
                    FeatCheckbox.LayoutOrder = 1
                    MakeCorner(FeatCheckbox, UDim.new(0, 4))
                    MakeStroke(FeatCheckbox, THEME.ACCENT, 0.5, 1)

                    local function toggleState()
                        checked = not checked
                        TweenQ(FeatCheckbox, 0.3, { BackgroundColor3 = checked and THEME.ACCENT or THEME.BG_TERTIARY }):Play()
                        Library._config._flags[settings.flag].checked = checked
                        Config:save(game.GameId, Library._config)
                        if settings.callback then settings.callback(checked) end
                    end

                    UseF_Var = toggleState
                    FeatCheckbox.MouseButton1Click:Connect(toggleState)
                else
                    UseF_Var = function() settings.button_callback() end
                end

                FeatKeybindBtn.MouseButton1Click:Connect(function()
                    FeatKeybindBox.Text = "..."
                    local ic
                    ic = UserInputService.InputBegan:Connect(function(input, proc)
                        if proc then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local nk = input.KeyCode.Name
                            Library._config._flags[settings.flag].BIND = nk
                            FeatKeybindBox.Text = (nk ~= "Unknown") and nk or "..."
                            Config:save(game.GameId, Library._config)
                            ic:Disconnect()
                        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                            Library._config._flags[settings.flag].BIND = "Unknown"
                            FeatKeybindBox.Text = "..."
                            Config:save(game.GameId, Library._config)
                            ic:Disconnect()
                        end
                    end)
                    Connections["keybind_input_"..settings.flag] = ic
                end)

                local kpc = UserInputService.InputBegan:Connect(function(input, proc)
                    if proc then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode.Name == Library._config._flags[settings.flag].BIND then
                            UseF_Var()
                        end
                    end
                end)
                Connections["keybind_press_"..settings.flag] = kpc

                FeatButton.MouseButton1Click:Connect(function()
                    if settings.button_callback then settings.button_callback() end
                end)

                if not settings.disablecheck then
                    settings.callback(checked)
                end

                return FeatContainer
            end

            return ModuleManager
        end

        return TabManager
    end

    -- UI visibility toggle (Insert key)
    Connections['library_visibility'] = UserInputService.InputBegan:Connect(function(input, process)
        if input.KeyCode ~= Enum.KeyCode.Insert then return end
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    -- Minimize button
    Minimize.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    return self
end

return Library
