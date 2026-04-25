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

-- Replace the SelectedLanguage with a reference to GG.Language
local SelectedLanguage = GG.Language

function convertStringToTable(inputString)
    local result = {}
    for value in string.gmatch(inputString, "([^,]+)") do
        local trimmedValue = value:match("^%s*(.-)%s*$")
        tablein(result, trimmedValue)
    end

    return result
end

function convertTableToString(inputTable)
    return table.concat(inputTable, ", ")
end

local UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider = cloneref(game:GetService('ContentProvider'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Lighting = cloneref(game:GetService('Lighting'))
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))
local LocalPlayer = Players.LocalPlayer

local RawFromRGB = Color3.fromRGB

local ThemePalette = {
    background = RawFromRGB(9, 9, 16),
    surface = RawFromRGB(17, 16, 28),
    surfaceAlt = RawFromRGB(23, 21, 38),
    surfaceSoft = RawFromRGB(30, 27, 47),
    accent = RawFromRGB(118, 87, 255),
    accentSoft = RawFromRGB(149, 122, 255),
    accentDeep = RawFromRGB(90, 63, 204),
    text = RawFromRGB(238, 234, 255),
    textSoft = RawFromRGB(219, 210, 255),
    textMuted = RawFromRGB(170, 160, 212),
    placeholder = RawFromRGB(133, 124, 177),
    toggleOff = RawFromRGB(34, 30, 54),
    toggleKnob = RawFromRGB(90, 78, 142)
}

local ThemeMap = {
    ["14,16,28"] = ThemePalette.background,
    ["19,22,42"] = ThemePalette.surface,
    ["25,30,55"] = ThemePalette.surfaceAlt,
    ["25,30,58"] = ThemePalette.surfaceAlt,
    ["28,33,62"] = ThemePalette.surfaceSoft,
    ["28,35,65"] = RawFromRGB(34, 30, 54),
    ["30,30,50"] = ThemePalette.toggleOff,
    ["30,40,70"] = RawFromRGB(48, 39, 79),
    ["35,42,75"] = RawFromRGB(39, 33, 64),
    ["35,45,80"] = RawFromRGB(44, 37, 71),
    ["50,70,120"] = ThemePalette.toggleKnob,
    ["50,80,160"] = ThemePalette.accentDeep,
    ["80,120,200"] = ThemePalette.accentSoft,
    ["88,101,242"] = ThemePalette.accent,
    ["100,140,230"] = ThemePalette.accentSoft,
    ["100,160,255"] = ThemePalette.accentSoft,
    ["100,185,255"] = ThemePalette.accent,
    ["120,150,200"] = ThemePalette.textMuted,
    ["120,160,220"] = ThemePalette.textSoft,
    ["140,155,255"] = ThemePalette.accentSoft,
    ["160,195,230"] = ThemePalette.textMuted,
    ["160,200,255"] = ThemePalette.textSoft,
    ["160,210,255"] = ThemePalette.accentSoft,
    ["160,215,255"] = ThemePalette.accentSoft,
    ["180,200,230"] = ThemePalette.textMuted,
    ["190,225,255"] = ThemePalette.textSoft,
    ["200,225,255"] = ThemePalette.textSoft,
    ["200,210,255"] = ThemePalette.textSoft,
    ["200,220,255"] = ThemePalette.textSoft,
    ["210,235,255"] = ThemePalette.text,
    ["220,235,255"] = ThemePalette.text,
    ["220,240,255"] = ThemePalette.text,
    ["225,240,255"] = ThemePalette.text,
    ["230,242,255"] = ThemePalette.text
}

local function ThemeRGB(red, green, blue)
    return ThemeMap[string.format("%d,%d,%d", red, green, blue)] or RawFromRGB(red, green, blue)
end

local mouse = LocalPlayer:GetMouse()
local new_VicoX = CoreGui:FindFirstChild('VicoX')

if new_VicoX then
    Debris:AddItem(new_VicoX, 0)
end

if not isfolder("VicoX") then
    makefolder("VicoX")
end


local Connections = setmetatable({
    disconnect = function(self, connection)
        if not self[connection] then
            return
        end
    
        self[connection]:Disconnect()
        self[connection] = nil
    end,
    disconnect_all = function(self)
        for _, value in self do
            if typeof(value) == 'function' then
                continue
            end
    
            value:Disconnect()
        end
    end
}, Connections)


local Util = setmetatable({
    map = function(self: any, value: number, in_minimum: number, in_maximum: number, out_minimum: number, out_maximum: number)
        return (value - in_minimum) * (out_maximum - out_minimum) / (in_maximum - in_minimum) + out_minimum
    end,
    viewport_point_to_world = function(self: any, location: any, distance: number)
        local unit_ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)

        return unit_ray.Origin + unit_ray.Direction * distance
    end,
    get_offset = function(self: any)
        local viewport_size_Y = workspace.CurrentCamera.ViewportSize.Y

        return self:map(viewport_size_Y, 0, 2560, 8, 56)
    end
}, Util)


local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur


function AcrylicBlur.new(object: GuiObject)
    local self = setmetatable({
        _object = object,
        _folder = nil,
        _frame = nil,
        _root = nil
    }, AcrylicBlur)

    self:setup()

    return self
end


function AcrylicBlur:create_folder()
    local old_folder = workspace.CurrentCamera:FindFirstChild('AcrylicBlur')

    if old_folder then
        Debris:AddItem(old_folder, 0)
    end

    local folder = Instance.new('Folder')
    folder.Name = 'AcrylicBlur'
    folder.Parent = workspace.CurrentCamera

    self._folder = folder
end


function AcrylicBlur:create_depth_of_fields()
    local depth_of_fields = Lighting:FindFirstChild('AcrylicBlur') or Instance.new('DepthOfFieldEffect')
    depth_of_fields.FarIntensity = 0
    depth_of_fields.FocusDistance = 0.05
    depth_of_fields.InFocusRadius = 0.1
    depth_of_fields.NearIntensity = 1
    depth_of_fields.Name = 'AcrylicBlur'
    depth_of_fields.Parent = Lighting

    for _, object in Lighting:GetChildren() do
        if not object:IsA('DepthOfFieldEffect') then
            continue
        end

        if object == depth_of_fields then
            continue
        end

        Connections[object] = object:GetPropertyChangedSignal('FarIntensity'):Connect(function()
            object.FarIntensity = 0
        end)

        object.FarIntensity = 0
    end
end


function AcrylicBlur:create_frame()
    local frame = Instance.new('Frame')
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Parent = self._object

    self._frame = frame
end


function AcrylicBlur:create_root()
    local part = Instance.new('Part')
    part.Name = 'Root'
    part.Color = Color3.new(0, 0, 0)
    part.Material = Enum.Material.Glass
    part.Size = Vector3.new(1, 1, 0)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Locked = true
    part.CastShadow = false
    part.Transparency = 0.98
    part.Parent = self._folder

    local specialMesh = Instance.new('SpecialMesh')
    specialMesh.MeshType = Enum.MeshType.Brick
    specialMesh.Offset = Vector3.new(0, 0, -0.000001) 
    specialMesh.Parent = part

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


function AcrylicBlur:render(distance: number)
    local positions = {
        top_left = Vector2.new(),
        top_right = Vector2.new(),
        bottom_right = Vector2.new(),
    }

    local function update_positions(size: any, position: any)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end

    local function update()
        local top_left = positions.top_left
        local top_right = positions.top_right
        local bottom_right = positions.bottom_right

        local top_left3D = Util:viewport_point_to_world(top_left, distance)
        local top_right3D = Util:viewport_point_to_world(top_right, distance)
        local bottom_right3D = Util:viewport_point_to_world(bottom_right, distance)

        local width = (top_right3D - top_left3D).Magnitude
        local height = (top_right3D - bottom_right3D).Magnitude

        if not self._root then
            return
        end

        self._root.CFrame = CFrame.fromMatrix((top_left3D + bottom_right3D) / 2, workspace.CurrentCamera.CFrame.XVector, workspace.CurrentCamera.CFrame.YVector, workspace.CurrentCamera.CFrame.ZVector)
        self._root.Mesh.Scale = Vector3.new(width, height, 0)
    end

    local function on_change()
        local offset = Util:get_offset()
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)

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
    local game_settings = UserSettings().GameSettings
    local quality_level = game_settings.SavedQualityLevel.Value

    if quality_level < 8 then
        self:change_visiblity(false)
    end

    Connections['quality_level'] = game_settings:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        local game_settings = UserSettings().GameSettings
        local quality_level = game_settings.SavedQualityLevel.Value

        self:change_visiblity(quality_level >= 8)
    end)
end


function AcrylicBlur:change_visiblity(state: boolean)
    self._root.Transparency = state and 0.98 or 1
end


local Config = setmetatable({
    save = function(self: any, file_name: any, config: any)
        local success_save, result = pcall(function()
            local flags = HttpService:JSONEncode(config)
            writefile('VicoX/'..file_name..'.json', flags)
        end)
    
        if not success_save then
            warn('failed to save config', result)
        end
    end,
    load = function(self: any, file_name: any, config: any)
        local success_load, result = pcall(function()
            if not isfile('VicoX/'..file_name..'.json') then
                self:save(file_name, config)
        
                return
            end
        
            local flags = readfile('VicoX/'..file_name..'.json')
        
            if not flags then
                self:save(file_name, config)
        
                return
            end

            return HttpService:JSONDecode(flags)
        end)
    
        if not success_load then
            warn('failed to load config', result)
        end
    
        if not result then
            result = {
                _flags = {},
                _keybinds = {},
                _library = {}
            }
        end
    
        return result
    end
}, Config)


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


function Library.new()
    local self = setmetatable({
        _loaded = false,
        _tab = 0,
    }, Library)
    
    self:create_ui()

    return self
end

-- ============================================================
-- NOTIFICATION SYSTEM (Redesigned - matching UI theme)
-- ============================================================

local NotificationContainer = Instance.new("ScreenGui")
NotificationContainer.Name = "VicoXNotifications"
NotificationContainer.ResetOnSpawn = false
NotificationContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotificationContainer.DisplayOrder = 9999
NotificationContainer.IgnoreGuiInset = true
NotificationContainer.Parent = CoreGui

local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "NotifHolder"
NotifHolder.Size = UDim2.new(0, 320, 1, 0)
NotifHolder.Position = UDim2.new(1, -330, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = NotificationContainer

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.FillDirection = Enum.FillDirection.Vertical
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifHolder

local NotifPadding = Instance.new("UIPadding")
NotifPadding.PaddingBottom = UDim.new(0, 16)
NotifPadding.PaddingRight = UDim.new(0, 0)
NotifPadding.Parent = NotifHolder

local notifCount = 0

function Library.SendNotification(settings)
    notifCount += 1
    local order = notifCount

    -- Outer wrapper (for slide animation)
    local Wrapper = Instance.new("Frame")
    Wrapper.Name = "Notif_" .. order
    Wrapper.Size = UDim2.new(1, 0, 0, 70)
    Wrapper.BackgroundTransparency = 1
    Wrapper.ClipsDescendants = false
    Wrapper.LayoutOrder = order
    Wrapper.Position = UDim2.new(1, 0, 0, 0) -- start off-screen right
    Wrapper.Parent = NotifHolder

    -- Main card
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 1, 0)
    Card.BackgroundColor3 = ThemeRGB(14, 16, 28)
    Card.BackgroundTransparency = 0
    Card.BorderSizePixel = 0
    Card.Parent = Wrapper

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = ThemeRGB(50, 80, 160)
    CardStroke.Transparency = 0.4
    CardStroke.Thickness = 1
    CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    CardStroke.Parent = Card

    -- Accent left bar
    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, 3, 0.7, 0)
    AccentBar.AnchorPoint = Vector2.new(0, 0.5)
    AccentBar.Position = UDim2.new(0, 8, 0.5, 0)
    AccentBar.BackgroundColor3 = ThemeRGB(100, 185, 255)
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = Card

    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(1, 0)
    AccentCorner.Parent = AccentBar

    -- Glow gradient behind accent
    local GlowFrame = Instance.new("Frame")
    GlowFrame.Size = UDim2.new(0, 80, 1, 0)
    GlowFrame.Position = UDim2.new(0, 0, 0, 0)
    GlowFrame.BackgroundColor3 = ThemeRGB(100, 185, 255)
    GlowFrame.BackgroundTransparency = 0.88
    GlowFrame.BorderSizePixel = 0
    GlowFrame.ZIndex = 0
    GlowFrame.Parent = Card

    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(0, 8)
    GlowCorner.Parent = GlowFrame

    local GlowGradient = Instance.new("UIGradient")
    GlowGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    }
    GlowGradient.Parent = GlowFrame

    -- Icon area
    local IconBg = Instance.new("Frame")
    IconBg.Size = UDim2.new(0, 32, 0, 32)
    IconBg.AnchorPoint = Vector2.new(0, 0.5)
    IconBg.Position = UDim2.new(0, 18, 0.5, 0)
    IconBg.BackgroundColor3 = ThemeRGB(100, 185, 255)
    IconBg.BackgroundTransparency = 0.75
    IconBg.BorderSizePixel = 0
    IconBg.ZIndex = 2
    IconBg.Parent = Card

    local IconBgCorner = Instance.new("UICorner")
    IconBgCorner.CornerRadius = UDim.new(1, 0)
    IconBgCorner.Parent = IconBg

    local NotifIcon = Instance.new("ImageLabel")
    NotifIcon.Image = settings.icon or "rbxassetid://10653372143"
    NotifIcon.Size = UDim2.new(0, 18, 0, 18)
    NotifIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    NotifIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    NotifIcon.BackgroundTransparency = 1
    NotifIcon.ImageColor3 = ThemeRGB(255, 255, 255)
    NotifIcon.ScaleType = Enum.ScaleType.Fit
    NotifIcon.ZIndex = 3
    NotifIcon.Parent = IconBg

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = settings.title or "Notification"
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextSize = 13
    Title.TextColor3 = ThemeRGB(220, 235, 255)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -70, 0, 16)
    Title.Position = UDim2.new(0, 62, 0, 10)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 2
    Title.Parent = Card

    -- Body
    local Body = Instance.new("TextLabel")
    Body.Text = settings.text or ""
    Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Body.TextSize = 11
    Body.TextColor3 = ThemeRGB(160, 195, 230)
    Body.BackgroundTransparency = 1
    Body.Size = UDim2.new(1, -70, 0, 30)
    Body.Position = UDim2.new(0, 62, 0, 28)
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.TextWrapped = true
    Body.ZIndex = 2
    Body.Parent = Card

    -- Progress bar (bottom)
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, -16, 0, 2)
    ProgressBg.AnchorPoint = Vector2.new(0.5, 1)
    ProgressBg.Position = UDim2.new(0.5, 0, 1, -6)
    ProgressBg.BackgroundColor3 = ThemeRGB(30, 40, 70)
    ProgressBg.BorderSizePixel = 0
    ProgressBg.ZIndex = 2
    ProgressBg.Parent = Card

    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBg

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.new(1, 0, 1, 0)
    ProgressFill.BackgroundColor3 = ThemeRGB(100, 185, 255)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.ZIndex = 3
    ProgressFill.Parent = ProgressBg

    local ProgressFillCorner = Instance.new("UICorner")
    ProgressFillCorner.CornerRadius = UDim.new(1, 0)
    ProgressFillCorner.Parent = ProgressFill

    local ProgressGradient = Instance.new("UIGradient")
    ProgressGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ThemeRGB(160, 210, 255)),
        ColorSequenceKeypoint.new(1, ThemeRGB(80, 140, 230)),
    }
    ProgressGradient.Parent = ProgressFill

    -- Animate in (slide from right)
    task.spawn(function()
        TweenService:Create(Wrapper, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        local duration = settings.duration or 5

        -- Shrink progress bar over duration
        task.wait(0.5)
        TweenService:Create(ProgressFill, TweenInfo.new(duration - 0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 1, 0)
        }):Play()

        task.wait(duration - 0.5)

        -- Fade out + slide right
        TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(Wrapper, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1.1, 0, 0, 0)
        }):Play()

        task.wait(0.45)
        Wrapper:Destroy()
    end)
end

function Library:get_screen_scale()
    local viewport_size_x = workspace.CurrentCamera.ViewportSize.X

    self._ui_scale = viewport_size_x / 1400
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


function Library:removed(action: any)
    self._ui.AncestryChanged:Once(action)
end


function Library:flag_type(flag: any, flag_type: any)
    if not Library._config._flags[flag] then
        return
    end

    return typeof(Library._config._flags[flag]) == flag_type
end


function Library:remove_table_value(__table: any, table_value: string)
    for index, value in __table do
        if value ~= table_value then
            continue
        end

        table.remove(__table, index)
    end
end


function Library:create_ui()
    local new_VicoX = CoreGui:FindFirstChild('VicoX')

    if new_VicoX then
        Debris:AddItem(new_VicoX, 0)
    end

    local VicoX = Instance.new('ScreenGui')
    VicoX.ResetOnSpawn = false
    VicoX.Name = 'VicoX'
    VicoX.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    VicoX.Parent = CoreGui

    -- (Intro animation removed)

    local Container = Instance.new('Frame')
    Container.ClipsDescendants = true
    Container.BorderColor3 = ThemeRGB(0, 0, 0)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Name = 'Container'
    Container.BackgroundTransparency = 0.05
    Container.BackgroundColor3 = ThemeRGB(14, 16, 28)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 0, 0, 0)
    Container.Active = true
    Container.BorderSizePixel = 0
    Container.Parent = VicoX
    
    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Container
    
    local UIStroke = Instance.new('UIStroke')
    UIStroke.Color = ThemeRGB(50, 80, 160)
    UIStroke.Transparency = 0.5
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Container
    
    local Handler = Instance.new('Frame')
    Handler.BackgroundTransparency = 1
    Handler.Name = 'Handler'
    Handler.Size = UDim2.new(0, 698, 0, 560)
    Handler.Parent = Container

    local ContentTopOffset = 62
    local ContentBottomPadding = 17
    local ContentSectionHeight = Handler.Size.Y.Offset - ContentTopOffset - ContentBottomPadding
    local ContentLeftOffset = 181
    local ContentRightOffset = 439
    local SearchBarOffsetY = 18
    local SearchBarWidth = Handler.Size.X.Offset - ContentLeftOffset - 16

    local CollapsedHeader = Instance.new('TextButton')
    CollapsedHeader.Name = 'CollapsedHeader'
    CollapsedHeader.AutoButtonColor = false
    CollapsedHeader.Text = ''
    CollapsedHeader.BackgroundTransparency = 1
    CollapsedHeader.Size = UDim2.fromScale(1, 1)
    CollapsedHeader.Visible = false
    CollapsedHeader.ZIndex = 5
    CollapsedHeader.Parent = Container

    local CollapsedTitle = Instance.new('TextLabel')
    CollapsedTitle.Name = 'CollapsedTitle'
    CollapsedTitle.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold)
    CollapsedTitle.TextColor3 = ThemeRGB(255, 255, 255)
    CollapsedTitle.TextTransparency = 0.02
    CollapsedTitle.Text = 'Rev.'
    CollapsedTitle.Size = UDim2.new(1, -16, 1, 0)
    CollapsedTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    CollapsedTitle.Position = UDim2.new(0.5, 0, 0.5, 0)
    CollapsedTitle.BackgroundTransparency = 1
    CollapsedTitle.TextXAlignment = Enum.TextXAlignment.Center
    CollapsedTitle.TextYAlignment = Enum.TextYAlignment.Center
    CollapsedTitle.TextSize = 26
    CollapsedTitle.ZIndex = 6
    CollapsedTitle.Parent = CollapsedHeader
    
    local Tabs = Instance.new('ScrollingFrame')
    Tabs.ScrollBarImageTransparency = 1
    Tabs.ScrollBarThickness = 0
    Tabs.Name = 'Tabs'
    Tabs.Size = UDim2.new(0, 129, 0, 320)
    Tabs.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Tabs.BackgroundTransparency = 1
    Tabs.Position = UDim2.new(0.026, 0, 0.111, 0)
    Tabs.CanvasSize = UDim2.new(0, 0, 0.5, 0)
    Tabs.Parent = Handler
    
    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Tabs

    local ClientName = Instance.new('TextLabel')
    ClientName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold)
    ClientName.TextColor3 = ThemeRGB(255, 255, 255)
    ClientName.TextTransparency = 0.05
    ClientName.Text = 'Rev.'
    ClientName.Name = 'ClientName'
    ClientName.Size = UDim2.new(0, 124, 0, 28)
    ClientName.AnchorPoint = Vector2.new(0, 0.5)
    ClientName.Position = UDim2.new(0, 18, 0, 30)
    ClientName.BackgroundTransparency = 1
    ClientName.TextXAlignment = Enum.TextXAlignment.Left
    ClientName.TextSize = 24
    ClientName.Parent = Handler
    
    local UIGradient = Instance.new('UIGradient')
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ThemePalette.accentSoft),
        ColorSequenceKeypoint.new(0.45, ThemePalette.background),
        ColorSequenceKeypoint.new(1, ThemePalette.accent)
    }
    UIGradient.Offset = Vector2.new(-1, 0)
    UIGradient.Parent = ClientName

    local CollapsedGradient = Instance.new('UIGradient')
    CollapsedGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ThemePalette.accentSoft),
        ColorSequenceKeypoint.new(0.45, ThemePalette.background),
        ColorSequenceKeypoint.new(1, ThemePalette.accent)
    }
    CollapsedGradient.Offset = Vector2.new(-1, 0)
    CollapsedGradient.Parent = CollapsedTitle

    task.spawn(function()
        while ClientName and ClientName.Parent and UIGradient.Parent do
            local tween_in = TweenService:Create(UIGradient, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Offset = Vector2.new(1, 0)
            })
            tween_in:Play()
            tween_in.Completed:Wait()

            local tween_out = TweenService:Create(UIGradient, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Offset = Vector2.new(-1, 0)
            })
            tween_out:Play()
            tween_out.Completed:Wait()
        end
    end)

    task.spawn(function()
        while CollapsedTitle and CollapsedTitle.Parent and CollapsedGradient.Parent do
            local tween_in = TweenService:Create(CollapsedGradient, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Offset = Vector2.new(1, 0)
            })
            tween_in:Play()
            tween_in.Completed:Wait()

            local tween_out = TweenService:Create(CollapsedGradient, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Offset = Vector2.new(-1, 0)
            })
            tween_out:Play()
            tween_out.Completed:Wait()
        end
    end)
    
    local Pin = Instance.new('Frame')
    Pin.Name = 'Pin'
    Pin.Position = UDim2.new(0.026, 0, 0.136, 0)
    Pin.Size = UDim2.new(0, 2, 0, 16)
    Pin.BackgroundColor3 = ThemeRGB(100, 185, 255)
    Pin.Parent = Handler
    
    local UICorner2 = Instance.new('UICorner')
    UICorner2.CornerRadius = UDim.new(1, 0)
    UICorner2.Parent = Pin

    local Divider = Instance.new('Frame')
    Divider.Name = 'Divider'
    Divider.BackgroundTransparency = 0.5
    Divider.Position = UDim2.new(0.23499999940395355, 0, 0, 0)
    Divider.BorderColor3 = ThemeRGB(0, 0, 0)
    Divider.Size = UDim2.new(0, 1, 0, 560)
    Divider.BorderSizePixel = 0
    Divider.BackgroundColor3 = ThemeRGB(50, 80, 160)
    Divider.Parent = Handler
    
    local Sections = Instance.new('Folder')
    Sections.Name = 'Sections'
    Sections.Parent = Handler

    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.fromOffset(SearchBarWidth, 34)
    SearchFrame.Position = UDim2.fromOffset(ContentLeftOffset, SearchBarOffsetY)
    SearchFrame.BackgroundColor3 = ThemePalette.surface
    SearchFrame.BackgroundTransparency = 0.08
    SearchFrame.BorderSizePixel = 0
    SearchFrame.Parent = Handler

    local SearchFrameCorner = Instance.new("UICorner")
    SearchFrameCorner.CornerRadius = UDim.new(0, 8)
    SearchFrameCorner.Parent = SearchFrame

    local SearchFrameStroke = Instance.new("UIStroke")
    SearchFrameStroke.Color = ThemeRGB(50, 80, 160)
    SearchFrameStroke.Transparency = 0.35
    SearchFrameStroke.Thickness = 1
    SearchFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SearchFrameStroke.Parent = SearchFrame

    local SearchAccent = Instance.new("Frame")
    SearchAccent.Size = UDim2.new(0, 3, 0.58, 0)
    SearchAccent.AnchorPoint = Vector2.new(0, 0.5)
    SearchAccent.Position = UDim2.new(0, 8, 0.5, 0)
    SearchAccent.BackgroundColor3 = ThemeRGB(100, 185, 255)
    SearchAccent.BorderSizePixel = 0
    SearchAccent.Parent = SearchFrame

    local SearchAccentCorner = Instance.new("UICorner")
    SearchAccentCorner.CornerRadius = UDim.new(1, 0)
    SearchAccentCorner.Parent = SearchAccent

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -22, 1, 0)
    SearchBox.Position = UDim2.new(0, 18, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.ClearTextOnFocus = false
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search modules..."
    SearchBox.PlaceholderColor3 = ThemePalette.placeholder
    SearchBox.TextColor3 = ThemePalette.text
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    SearchBox.TextSize = 12
    SearchBox.Parent = SearchFrame

    local SearchPadding = Instance.new("UIPadding")
    SearchPadding.PaddingLeft = UDim.new(0, 10)
    SearchPadding.PaddingRight = UDim.new(0, 6)
    SearchPadding.Parent = SearchBox

    local function module_matches_search(module: Instance, query: string)
        if query == "" then
            return true
        end

        local title = string.lower(tostring(module:GetAttribute("SearchTitle") or ""))
        local description = string.lower(tostring(module:GetAttribute("SearchDescription") or ""))

        return string.find(title, query, 1, true) ~= nil or string.find(description, query, 1, true) ~= nil
    end

    local function apply_module_search()
        local query = string.lower(SearchBox.Text or "")

        for _, section in Sections:GetChildren() do
            if not section:IsA("ScrollingFrame") then
                continue
            end

            local storage = section:FindFirstChild("SearchStorage")
            if not storage then
                continue
            end

            local modules = {}

            for _, child in section:GetChildren() do
                if child.Name == "Module" then
                    table.insert(modules, child)
                end
            end

            for _, child in storage:GetChildren() do
                if child.Name == "Module" then
                    table.insert(modules, child)
                end
            end

            for _, module in modules do
                local target_parent = module_matches_search(module, query) and section or storage

                if module.Parent ~= target_parent then
                    module.Parent = target_parent
                end
            end
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(apply_module_search)

    local playerPing = "Ping -- ms"
    pcall(function()
        playerPing = string.format("Ping %d ms", math.floor(LocalPlayer:GetNetworkPing() * 1000))
    end)

    local playerThumbnail = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    pcall(function()
        local thumbnail = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        if thumbnail and thumbnail ~= "" then
            playerThumbnail = thumbnail
        end
    end)

    local PlayerCard = Instance.new("Frame")
    PlayerCard.Name = "PlayerCard"
    PlayerCard.Size = UDim2.new(0, 120, 0, 156)
    PlayerCard.AnchorPoint = Vector2.new(0.5, 0)
    PlayerCard.Position = UDim2.new(0.1175, 0, 0, 394)
    PlayerCard.BackgroundColor3 = ThemePalette.surface
    PlayerCard.BorderSizePixel = 0
    PlayerCard.Parent = Handler

    local PlayerCardCorner = Instance.new("UICorner")
    PlayerCardCorner.CornerRadius = UDim.new(0, 10)
    PlayerCardCorner.Parent = PlayerCard

    local PlayerCardStroke = Instance.new("UIStroke")
    PlayerCardStroke.Color = ThemePalette.accentDeep
    PlayerCardStroke.Transparency = 0.35
    PlayerCardStroke.Parent = PlayerCard

    local PlayerGlow = Instance.new("Frame")
    PlayerGlow.Size = UDim2.new(0, 70, 0, 70)
    PlayerGlow.AnchorPoint = Vector2.new(0.5, 0)
    PlayerGlow.Position = UDim2.new(0.5, 0, 0, 8)
    PlayerGlow.BackgroundColor3 = ThemePalette.accent
    PlayerGlow.BackgroundTransparency = 0.82
    PlayerGlow.BorderSizePixel = 0
    PlayerGlow.Parent = PlayerCard

    local PlayerGlowCorner = Instance.new("UICorner")
    PlayerGlowCorner.CornerRadius = UDim.new(1, 0)
    PlayerGlowCorner.Parent = PlayerGlow

    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Name = "AvatarFrame"
    AvatarFrame.Size = UDim2.new(0, 58, 0, 58)
    AvatarFrame.AnchorPoint = Vector2.new(0.5, 0)
    AvatarFrame.Position = UDim2.new(0.5, 0, 0, 12)
    AvatarFrame.BackgroundColor3 = ThemePalette.surfaceAlt
    AvatarFrame.BorderSizePixel = 0
    AvatarFrame.Parent = PlayerCard

    local AvatarFrameCorner = Instance.new("UICorner")
    AvatarFrameCorner.CornerRadius = UDim.new(0, 16)
    AvatarFrameCorner.Parent = AvatarFrame

    local AvatarFrameStroke = Instance.new("UIStroke")
    AvatarFrameStroke.Color = ThemePalette.accent
    AvatarFrameStroke.Transparency = 0.2
    AvatarFrameStroke.Thickness = 1.5
    AvatarFrameStroke.Parent = AvatarFrame

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.Size = UDim2.new(1, -8, 1, -8)
    AvatarImage.Position = UDim2.new(0, 4, 0, 4)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = playerThumbnail
    AvatarImage.ScaleType = Enum.ScaleType.Crop
    AvatarImage.Parent = AvatarFrame

    local AvatarImageCorner = Instance.new("UICorner")
    AvatarImageCorner.CornerRadius = UDim.new(0, 13)
    AvatarImageCorner.Parent = AvatarImage

    local PlayerName = Instance.new("TextLabel")
    PlayerName.Name = "PlayerName"
    PlayerName.Size = UDim2.new(1, -12, 0, 16)
    PlayerName.Position = UDim2.new(0, 6, 0, 76)
    PlayerName.BackgroundTransparency = 1
    PlayerName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold)
    PlayerName.TextColor3 = ThemePalette.text
    PlayerName.TextSize = 12
    PlayerName.TextXAlignment = Enum.TextXAlignment.Center
    PlayerName.Text = "@" .. LocalPlayer.Name
    PlayerName.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerName.Parent = PlayerCard

    local PlayerStatus = Instance.new("TextLabel")
    PlayerStatus.Name = "PlayerStatus"
    PlayerStatus.Size = UDim2.new(1, -12, 0, 14)
    PlayerStatus.Position = UDim2.new(0, 6, 0, 96)
    PlayerStatus.BackgroundTransparency = 1
    PlayerStatus.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Medium)
    PlayerStatus.TextColor3 = ThemePalette.textSoft
    PlayerStatus.TextSize = 10
    PlayerStatus.TextXAlignment = Enum.TextXAlignment.Center
    PlayerStatus.Text = LocalPlayer.DisplayName ~= LocalPlayer.Name and LocalPlayer.DisplayName or "Rev User"
    PlayerStatus.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerStatus.Parent = PlayerCard

    local PlayerMeta = Instance.new("TextLabel")
    PlayerMeta.Name = "PlayerMeta"
    PlayerMeta.Size = UDim2.new(1, -12, 0, 12)
    PlayerMeta.Position = UDim2.new(0, 6, 0, 111)
    PlayerMeta.BackgroundTransparency = 1
    PlayerMeta.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Medium)
    PlayerMeta.TextColor3 = ThemePalette.placeholder
    PlayerMeta.TextSize = 9
    PlayerMeta.TextXAlignment = Enum.TextXAlignment.Center
    PlayerMeta.Text = playerPing
    PlayerMeta.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerMeta.Parent = PlayerCard
    
    local Minimize = Instance.new('TextButton')
    Minimize.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Minimize.TextColor3 = ThemeRGB(0, 0, 0)
    Minimize.BorderColor3 = ThemeRGB(0, 0, 0)
    Minimize.Text = ''
    Minimize.AutoButtonColor = false
    Minimize.Name = 'Minimize'
    Minimize.BackgroundTransparency = 1
    Minimize.Position = UDim2.new(0.020057305693626404, 0, 0.02922755666077137, 0)
    Minimize.Size = UDim2.new(0, 24, 0, 24)
    Minimize.BorderSizePixel = 0
    Minimize.TextSize = 14
    Minimize.BackgroundColor3 = ThemeRGB(255, 255, 255)
    Minimize.Parent = Handler
    
    -- ============================================================
    -- DISCORD BUTTON (Redesigned - matching UI theme)
    -- ============================================================
    local DiscordBtn = Instance.new("TextButton")
    DiscordBtn.Name = "DiscordBtn"
    DiscordBtn.Size = UDim2.new(1, -16, 0, 24)
    DiscordBtn.Position = UDim2.new(0, 8, 1, -32)
    DiscordBtn.BackgroundColor3 = ThemeRGB(25, 30, 55)
    DiscordBtn.BorderSizePixel = 0
    DiscordBtn.Text = ""
    DiscordBtn.AutoButtonColor = false
    DiscordBtn.ZIndex = 10
    DiscordBtn.Parent = PlayerCard

    local DBtnCorner = Instance.new("UICorner")
    DBtnCorner.CornerRadius = UDim.new(0, 8)
    DBtnCorner.Parent = DiscordBtn

    -- Outer stroke matching UI theme
    local DBtnStroke = Instance.new("UIStroke")
    DBtnStroke.Color = ThemeRGB(50, 80, 160)
    DBtnStroke.Transparency = 0.4
    DBtnStroke.Thickness = 1
    DBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    DBtnStroke.Parent = DiscordBtn

    -- Left glow accent bar
    local DBtnAccent = Instance.new("Frame")
    DBtnAccent.Size = UDim2.new(0, 3, 0.6, 0)
    DBtnAccent.AnchorPoint = Vector2.new(0, 0.5)
    DBtnAccent.Position = UDim2.new(0, 6, 0.5, 0)
    DBtnAccent.BackgroundColor3 = ThemeRGB(88, 101, 242)
    DBtnAccent.BorderSizePixel = 0
    DBtnAccent.ZIndex = 11
    DBtnAccent.Parent = DiscordBtn

    local DBtnAccentCorner = Instance.new("UICorner")
    DBtnAccentCorner.CornerRadius = UDim.new(1, 0)
    DBtnAccentCorner.Parent = DBtnAccent

    -- Subtle glow behind accent
    local DBtnGlow = Instance.new("Frame")
    DBtnGlow.Size = UDim2.new(0, 36, 1, 0)
    DBtnGlow.Position = UDim2.new(0, 0, 0, 0)
    DBtnGlow.BackgroundColor3 = ThemeRGB(88, 101, 242)
    DBtnGlow.BackgroundTransparency = 0.88
    DBtnGlow.BorderSizePixel = 0
    DBtnGlow.ZIndex = 10
    DBtnGlow.Parent = DiscordBtn

    local DBtnGlowCorner = Instance.new("UICorner")
    DBtnGlowCorner.CornerRadius = UDim.new(0, 8)
    DBtnGlowCorner.Parent = DBtnGlow

    local DBtnGlowGrad = Instance.new("UIGradient")
    DBtnGlowGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    }
    DBtnGlowGrad.Parent = DBtnGlow

    -- Discord icon
    local DiscordIcon = Instance.new("ImageLabel")
    DiscordIcon.Image = "rbxassetid://112538196670712"
    DiscordIcon.Size = UDim2.new(0, 14, 0, 14)
    DiscordIcon.AnchorPoint = Vector2.new(0, 0.5)
    DiscordIcon.Position = UDim2.new(0, 14, 0.5, 0)
    DiscordIcon.BackgroundTransparency = 1
    DiscordIcon.ImageColor3 = ThemeRGB(140, 155, 255)
    DiscordIcon.ZIndex = 12
    DiscordIcon.Parent = DiscordBtn

    -- Label
    local DiscordLabel = Instance.new("TextLabel")
    DiscordLabel.Text = "Discord"
    DiscordLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold)
    DiscordLabel.TextSize = 10
    DiscordLabel.TextColor3 = ThemeRGB(200, 210, 255)
    DiscordLabel.BackgroundTransparency = 1
    DiscordLabel.Size = UDim2.new(0, 58, 1, 0)
    DiscordLabel.Position = UDim2.new(0, 34, 0, 0)
    DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
    DiscordLabel.ZIndex = 12
    DiscordLabel.Parent = DiscordBtn

    -- Hover: lighten border + bg
    DiscordBtn.MouseEnter:Connect(function()
        TweenService:Create(DiscordBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = ThemePalette.surfaceSoft
        }):Play()
        TweenService:Create(DBtnStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Transparency = 0.1
        }):Play()
    end)
    DiscordBtn.MouseLeave:Connect(function()
        TweenService:Create(DiscordBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = ThemePalette.surfaceAlt
        }):Play()
        TweenService:Create(DBtnStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Transparency = 0.4
        }):Play()
    end)

    DiscordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/gngstore")
        Library.SendNotification({
            title = "Discord",
            text = "Discord link copied to clipboard!",
            icon = "rbxassetid://112538196670712",
            duration = 4
        })
    end)

    local UIScale = Instance.new('UIScale')
    UIScale.Parent = Container    
    
    self._ui = VicoX

    local function on_drag(input: InputObject, process: boolean)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            self._dragging = true
            self._drag_start = input.Position
            self._container_position = Container.Position

            Connections['container_input_ended'] = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Connections:disconnect('container_input_ended')
                self._dragging = false
            end)
        end
    end


    local function update_drag(input: any)
        local delta = input.Position - self._drag_start
        local position = UDim2.new(self._container_position.X.Scale, self._container_position.X.Offset + delta.X, self._container_position.Y.Scale, self._container_position.Y.Offset + delta.Y)

        TweenService:Create(Container, TweenInfo.new(0.2), {
            Position = position
        }):Play()
    end

    local function drag(input: InputObject, process: boolean)
        if not self._dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update_drag(input)
        end
    end

    Connections['container_input_began'] = Container.InputBegan:Connect(on_drag)
    Connections['input_changed'] = UserInputService.InputChanged:Connect(drag)

    self:removed(function()
        self._ui = nil
        Connections:disconnect_all()
    end)

    function self:Update1Run(a)
        if a == "nil" then
            Container.BackgroundTransparency = 0.05000000074505806;
        else
            pcall(function()
                Container.BackgroundTransparency = tonumber(a);
            end);
        end;
    end;

    function self:UIVisiblity()
        VicoX.Enabled = not VicoX.Enabled;
    end;

    local function set_ui_mode(expanded: boolean)
        Handler.Visible = expanded
        CollapsedHeader.Visible = not expanded
    end

    function self:change_visiblity(state: boolean)
        set_ui_mode(state)

        if state then
            TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(698, 560)
            }):Play()
        else
            TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(104.5, 52)
            }):Play()
        end
    end

    set_ui_mode(self._ui_open)
    

    function self:load()
        local content = {}
    
        for _, object in VicoX:GetDescendants() do
            if not object:IsA('ImageLabel') then
                continue
            end
    
            table.insert(content, object)
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
    
        TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(698, 560)
        }):Play()

        AcrylicBlur.new(Container)
        self._ui_loaded = true
    end

    function self:update_tabs(tab: TextButton)
        for index, object in Tabs:GetChildren() do
            if object.Name ~= 'Tab' then
                continue
            end

            if object == tab then
                if object.BackgroundTransparency ~= 0.5 then
                    local offset = object.LayoutOrder * (0.113 / 1.3)

                    TweenService:Create(Pin, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Position = UDim2.fromScale(0.026, 0.135 + offset)
                    }):Play()    

                    TweenService:Create(object, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.5
                    }):Play()

                    TweenService:Create(object.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        TextTransparency = 0.2,
                        TextColor3 = ThemeRGB(100, 185, 255)
                    }):Play()

                    TweenService:Create(object.TextLabel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Offset = Vector2.new(1, 0)
                    }):Play()

                    TweenService:Create(object.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        ImageTransparency = 0.2,
                        ImageColor3 = ThemeRGB(100, 185, 255)
                    }):Play()
                end

                continue
            end

            if object.BackgroundTransparency ~= 1 then
                TweenService:Create(object, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                }):Play()
                
                TweenService:Create(object.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    TextTransparency = 0.7,
                    TextColor3 = ThemeRGB(255, 255, 255)
                }):Play()

                TweenService:Create(object.TextLabel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Offset = Vector2.new(0, 0)
                }):Play()

                TweenService:Create(object.Icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    ImageTransparency = 0.8,
                    ImageColor3 = ThemeRGB(255, 255, 255)
                }):Play()
            end
        end
    end

    function self:update_sections(left_section: ScrollingFrame, right_section: ScrollingFrame)
        for _, object in Sections:GetChildren() do
            if object == left_section or object == right_section then
                object.Visible = true

                continue
            end

            object.Visible = false
        end

        apply_module_search()
    end

    function self:create_tab(title: string, icon: string)
        local TabManager = {}

        local LayoutOrder = 0;

        local font_params = Instance.new('GetTextBoundsParams')
        font_params.Text = title
        font_params.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        font_params.Size = 13
        font_params.Width = 10000

        local font_size = TextService:GetTextBoundsAsync(font_params)
        local first_tab = not Tabs:FindFirstChild('Tab')

        local Tab = Instance.new('TextButton')
        Tab.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        Tab.TextColor3 = ThemeRGB(0, 0, 0)
        Tab.BorderColor3 = ThemeRGB(0, 0, 0)
        Tab.Text = ''
        Tab.AutoButtonColor = false
        Tab.BackgroundTransparency = 1
        Tab.Name = 'Tab'
        Tab.Size = UDim2.new(0, 129, 0, 38)
        Tab.BorderSizePixel = 0
        Tab.TextSize = 14
        Tab.BackgroundColor3 = ThemeRGB(25, 30, 55)
        Tab.Parent = Tabs
        Tab.LayoutOrder = self._tab
        
        local UICorner = Instance.new('UICorner')
        UICorner.CornerRadius = UDim.new(0, 5)
        UICorner.Parent = Tab
        
        local TextLabel = Instance.new('TextLabel')
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextColor3 = ThemeRGB(255, 255, 255)
        TextLabel.TextTransparency = 0.7
        TextLabel.Text = title
        TextLabel.Size = UDim2.new(0, font_size.X, 0, 16)
        TextLabel.AnchorPoint = Vector2.new(0, 0.5)
        TextLabel.Position = UDim2.new(0.2400001734495163, 0, 0.5, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BorderSizePixel = 0
        TextLabel.BorderColor3 = ThemeRGB(0, 0, 0)
        TextLabel.TextSize = 13
        TextLabel.BackgroundColor3 = ThemeRGB(255, 255, 255)
        TextLabel.Parent = Tab
        
        local UIGradient = Instance.new('UIGradient')
        UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ThemeRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.7, ThemeRGB(200, 220, 255)),
            ColorSequenceKeypoint.new(1, ThemeRGB(120, 150, 200))
        }
        UIGradient.Parent = TextLabel
        
        local Icon = Instance.new('ImageLabel')
        Icon.ScaleType = Enum.ScaleType.Fit
        Icon.ImageTransparency = 0.800000011920929
        Icon.BorderColor3 = ThemeRGB(0, 0, 0)
        Icon.AnchorPoint = Vector2.new(0, 0.5)
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0.10000000149011612, 0, 0.5, 0)
        Icon.Name = 'Icon'
        Icon.Image = icon
        Icon.Size = UDim2.new(0, 12, 0, 12)
        Icon.BorderSizePixel = 0
        Icon.BackgroundColor3 = ThemeRGB(255, 255, 255)
        Icon.Parent = Tab

        local LeftSection = Instance.new('ScrollingFrame')
        LeftSection.Name = 'LeftSection'
        LeftSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        LeftSection.ScrollBarThickness = 0
        LeftSection.Size = UDim2.fromOffset(243, ContentSectionHeight)
        LeftSection.Selectable = false
        LeftSection.AnchorPoint = Vector2.new(0, 0)
        LeftSection.ScrollBarImageTransparency = 1
        LeftSection.BackgroundTransparency = 1
        LeftSection.Position = UDim2.fromOffset(ContentLeftOffset, ContentTopOffset)
        LeftSection.BorderColor3 = ThemeRGB(0, 0, 0)
        LeftSection.BackgroundColor3 = ThemeRGB(255, 255, 255)
        LeftSection.BorderSizePixel = 0
        LeftSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        LeftSection.Visible = false
        LeftSection.Parent = Sections
        
        local UIListLayout = Instance.new('UIListLayout')
        UIListLayout.Padding = UDim.new(0, 11)
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = LeftSection
        
        local UIPadding = Instance.new('UIPadding')
        UIPadding.PaddingTop = UDim.new(0, 1)
        UIPadding.Parent = LeftSection

        local LeftSectionStorage = Instance.new("Folder")
        LeftSectionStorage.Name = "SearchStorage"
        LeftSectionStorage.Parent = LeftSection

        local RightSection = Instance.new('ScrollingFrame')
        RightSection.Name = 'RightSection'
        RightSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        RightSection.ScrollBarThickness = 0
        RightSection.Size = UDim2.fromOffset(243, ContentSectionHeight)
        RightSection.Selectable = false
        RightSection.AnchorPoint = Vector2.new(0, 0)
        RightSection.ScrollBarImageTransparency = 1
        RightSection.BackgroundTransparency = 1
        RightSection.Position = UDim2.fromOffset(ContentRightOffset, ContentTopOffset)
        RightSection.BorderColor3 = ThemeRGB(0, 0, 0)
        RightSection.BackgroundColor3 = ThemeRGB(255, 255, 255)
        RightSection.BorderSizePixel = 0
        RightSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        RightSection.Visible = false
        RightSection.Parent = Sections
        
        local UIListLayout = Instance.new('UIListLayout')
        UIListLayout.Padding = UDim.new(0, 11)
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = RightSection
        
        local UIPadding = Instance.new('UIPadding')
        UIPadding.PaddingTop = UDim.new(0, 1)
        UIPadding.Parent = RightSection

        local RightSectionStorage = Instance.new("Folder")
        RightSectionStorage.Name = "SearchStorage"
        RightSectionStorage.Parent = RightSection

        self._tab += 1

        if first_tab then
            self:update_tabs(Tab, LeftSection, RightSection)
            self:update_sections(LeftSection, RightSection)
        end

        Tab.MouseButton1Click:Connect(function()
            self:update_tabs(Tab, LeftSection, RightSection)
            self:update_sections(LeftSection, RightSection)
        end)

        function TabManager:create_module(settings: any)

            local LayoutOrderModule = 0;

            local ModuleManager = {
                _state = false,
                _size = 0,
                _multiplier = 0
            }

            if settings.section == 'right' then
                settings.section = RightSection
            else
                settings.section = LeftSection
            end

            local Module = Instance.new('Frame')
            Module.ClipsDescendants = true
            Module.BorderColor3 = ThemeRGB(0, 0, 0)
            Module.BackgroundTransparency = 0.5
            Module.Position = UDim2.new(0.004115226212888956, 0, 0, 0)
            Module.Name = 'Module'
            Module.Size = UDim2.new(0, 241, 0, 93)
            Module.BorderSizePixel = 0
            Module:SetAttribute('SearchTitle', tostring(settings.title or settings.richtext or ""))
            Module:SetAttribute('SearchDescription', tostring(settings.description or ""))
            Module.BackgroundColor3 = ThemeRGB(19, 22, 42)
            Module.Parent = settings.section

            apply_module_search()

            local UIListLayout = Instance.new('UIListLayout')
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Parent = Module
            
            local UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(0, 5)
            UICorner.Parent = Module
            
            local UIStroke = Instance.new('UIStroke')
            UIStroke.Color = ThemeRGB(50, 80, 160)
            UIStroke.Transparency = 0.5
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            UIStroke.Parent = Module
            
            local Header = Instance.new('TextButton')
            Header.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            Header.TextColor3 = ThemeRGB(0, 0, 0)
            Header.BorderColor3 = ThemeRGB(0, 0, 0)
            Header.Text = ''
            Header.AutoButtonColor = false
            Header.BackgroundTransparency = 1
            Header.Name = 'Header'
            Header.Size = UDim2.new(0, 241, 0, 93)
            Header.BorderSizePixel = 0
            Header.TextSize = 14
            Header.BackgroundColor3 = ThemeRGB(255, 255, 255)
            Header.Parent = Module
            
            local Icon = Instance.new('ImageLabel')
            Icon.ImageColor3 = ThemeRGB(100, 185, 255)
            Icon.ScaleType = Enum.ScaleType.Fit
            Icon.ImageTransparency = 0.699999988079071
            Icon.BorderColor3 = ThemeRGB(0, 0, 0)
            Icon.AnchorPoint = Vector2.new(0, 0.5)
            Icon.Image = 'rbxassetid://79095934438045'
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(0.07100000232458115, 0, 0.8199999928474426, 0)
            Icon.Name = 'Icon'
            Icon.Size = UDim2.new(0, 15, 0, 15)
            Icon.BorderSizePixel = 0
            Icon.BackgroundColor3 = ThemeRGB(255, 255, 255)
            Icon.Parent = Header
            
            local ModuleName = Instance.new('TextLabel')
            ModuleName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            ModuleName.TextColor3 = ThemeRGB(230, 242, 255)
            ModuleName.TextTransparency = 0.05
            if not settings.rich then
                ModuleName.Text = settings.title or "Skibidi"
            else
                ModuleName.RichText = true
                ModuleName.Text = settings.richtext or "<font color='rgb(255,0,0)'>VicoX</font> user"
            end;
            ModuleName.Name = 'ModuleName'
            ModuleName.Size = UDim2.new(0, 205, 0, 13)
            ModuleName.AnchorPoint = Vector2.new(0, 0.5)
            ModuleName.Position = UDim2.new(0.0729999989271164, 0, 0.23999999463558197, 0)
            ModuleName.BackgroundTransparency = 1
            ModuleName.TextXAlignment = Enum.TextXAlignment.Left
            ModuleName.BorderSizePixel = 0
            ModuleName.BorderColor3 = ThemeRGB(0, 0, 0)
            ModuleName.TextSize = 13
            ModuleName.BackgroundColor3 = ThemeRGB(255, 255, 255)
            ModuleName.Parent = Header
            
            local Description = Instance.new('TextLabel')
            Description.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            Description.TextColor3 = ThemeRGB(160, 215, 255)
            Description.TextTransparency = 0.15
            Description.Text = settings.description
            Description.Name = 'Description'
            Description.Size = UDim2.new(0, 205, 0, 13)
            Description.AnchorPoint = Vector2.new(0, 0.5)
            Description.Position = UDim2.new(0.0729999989271164, 0, 0.41999998688697815, 0)
            Description.BackgroundTransparency = 1
            Description.TextXAlignment = Enum.TextXAlignment.Left
            Description.BorderSizePixel = 0
            Description.BorderColor3 = ThemeRGB(0, 0, 0)
            Description.TextSize = 10
            Description.BackgroundColor3 = ThemeRGB(255, 255, 255)
            Description.Parent = Header
            
            local Toggle = Instance.new('Frame')
            Toggle.Name = 'Toggle'
            Toggle.BackgroundTransparency = 0.699999988079071
            Toggle.Position = UDim2.new(0.8199999928474426, 0, 0.7570000290870667, 0)
            Toggle.BorderColor3 = ThemeRGB(0, 0, 0)
            Toggle.Size = UDim2.new(0, 25, 0, 12)
            Toggle.BorderSizePixel = 0
            Toggle.BackgroundColor3 = ThemeRGB(30, 30, 50)
            Toggle.Parent = Header
            
            local UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = Toggle
            
            local Circle = Instance.new('Frame')
            Circle.BorderColor3 = ThemeRGB(0, 0, 0)
            Circle.AnchorPoint = Vector2.new(0, 0.5)
            Circle.BackgroundTransparency = 0.20000000298023224
            Circle.Position = UDim2.new(0, 0, 0.5, 0)
            Circle.Name = 'Circle'
            Circle.Size = UDim2.new(0, 12, 0, 12)
            Circle.BorderSizePixel = 0
            Circle.BackgroundColor3 = ThemeRGB(50, 70, 120)
            Circle.Parent = Toggle
            
            local UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = Circle
            
            local Keybind = Instance.new('Frame')
            Keybind.Name = 'Keybind'
            Keybind.BackgroundTransparency = 0.699999988079071
            Keybind.Position = UDim2.new(0.15000000596046448, 0, 0.7350000143051147, 0)
            Keybind.BorderColor3 = ThemeRGB(0, 0, 0)
            Keybind.Size = UDim2.new(0, 33, 0, 15)
            Keybind.BorderSizePixel = 0
            Keybind.BackgroundColor3 = ThemeRGB(100, 185, 255)
            Keybind.Parent = Header
            
            local UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(0, 3)
            UICorner.Parent = Keybind
            
            local TextLabel = Instance.new('TextLabel')
            TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            TextLabel.TextColor3 = ThemeRGB(210, 235, 255)
            TextLabel.BorderColor3 = ThemeRGB(0, 0, 0)
            TextLabel.Text = 'None'
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.Size = UDim2.new(0, 25, 0, 13)
            TextLabel.BackgroundTransparency = 1
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextLabel.BorderSizePixel = 0
            TextLabel.TextSize = 10
            TextLabel.BackgroundColor3 = ThemeRGB(255, 255, 255)
            TextLabel.Parent = Keybind
            
            local Divider = Instance.new('Frame')
            Divider.BorderColor3 = ThemeRGB(0, 0, 0)
            Divider.AnchorPoint = Vector2.new(0.5, 0)
            Divider.BackgroundTransparency = 0.5
            Divider.Position = UDim2.new(0.5, 0, 0.6200000047683716, 0)
            Divider.Name = 'Divider'
            Divider.Size = UDim2.new(0, 241, 0, 1)
            Divider.BorderSizePixel = 0
            Divider.BackgroundColor3 = ThemeRGB(50, 80, 160)
            Divider.Parent = Header
            
            local Divider = Instance.new('Frame')
            Divider.BorderColor3 = ThemeRGB(0, 0, 0)
            Divider.AnchorPoint = Vector2.new(0.5, 0)
            Divider.BackgroundTransparency = 0.5
            Divider.Position = UDim2.new(0.5, 0, 1, 0)
            Divider.Name = 'Divider'
            Divider.Size = UDim2.new(0, 241, 0, 1)
            Divider.BorderSizePixel = 0
            Divider.BackgroundColor3 = ThemeRGB(50, 80, 160)
            Divider.Parent = Header
            
            local Options = Instance.new('Frame')
            Options.Name = 'Options'
            Options.BackgroundTransparency = 1
            Options.Position = UDim2.new(0, 0, 1, 0)
            Options.BorderColor3 = ThemeRGB(0, 0, 0)
            Options.Size = UDim2.new(0, 241, 0, 8)
            Options.BorderSizePixel = 0
            Options.BackgroundColor3 = ThemeRGB(255, 255, 255)
            Options.Parent = Module

            local UIPadding = Instance.new('UIPadding')
            UIPadding.PaddingTop = UDim.new(0, 8)
            UIPadding.Parent = Options

            local UIListLayout = Instance.new('UIListLayout')
            UIListLayout.Padding = UDim.new(0, 5)
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Parent = Options

            function ModuleManager:change_state(state: boolean)
                self._state = state

                if self._state then
                    TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.fromOffset(241, 93 + self._size + self._multiplier)
                    }):Play()

                    TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(100, 185, 255)
                    }):Play()

                    TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(100, 185, 255),
                        Position = UDim2.fromScale(0.53, 0.5)
                    }):Play()
                else
                    TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.fromOffset(241, 93)
                    }):Play()

                    TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(30, 30, 50)
                    }):Play()

                    TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(50, 70, 120),
                        Position = UDim2.fromScale(0, 0.5)
                    }):Play()
                end

                Library._config._flags[settings.flag] = self._state
                Config:save(game.GameId, Library._config)

                settings.callback(self._state)
            end
            
            function ModuleManager:connect_keybind()
                if not Library._config._keybinds[settings.flag] then
                    return
                end

                Connections[settings.flag..'_keybind'] = UserInputService.InputBegan:Connect(function(input: InputObject, process: boolean)
                    if process then
                        return
                    end
                    
                    if tostring(input.KeyCode) ~= Library._config._keybinds[settings.flag] then
                        return
                    end
                    
                    self:change_state(not self._state)
                end)
            end

            function ModuleManager:scale_keybind(empty: boolean)
                if Library._config._keybinds[settings.flag] and not empty then
                    local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')

                    local font_params = Instance.new('GetTextBoundsParams')
                    font_params.Text = keybind_string
                    font_params.Font = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold)
                    font_params.Size = 10
                    font_params.Width = 10000
            
                    local font_size = TextService:GetTextBoundsAsync(font_params)
                    
                    Keybind.Size = UDim2.fromOffset(font_size.X + 6, 15)
                    TextLabel.Size = UDim2.fromOffset(font_size.X, 13)
                else
                    Keybind.Size = UDim2.fromOffset(31, 15)
                    TextLabel.Size = UDim2.fromOffset(25, 13)
                end
            end

            if Library:flag_type(settings.flag, 'boolean') then
                ModuleManager._state = true
                settings.callback(ModuleManager._state)

                Toggle.BackgroundColor3 = ThemeRGB(100, 185, 255)
                Circle.BackgroundColor3 = ThemeRGB(100, 185, 255)
                Circle.Position = UDim2.fromScale(0.53, 0.5)
            end

            if Library._config._keybinds[settings.flag] then
                local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                TextLabel.Text = keybind_string

                ModuleManager:connect_keybind()
                ModuleManager:scale_keybind()
            end

            Connections[settings.flag..'_input_began'] = Header.InputBegan:Connect(function(input: InputObject)
                if Library._choosing_keybind then
                    return
                end

                if input.UserInputType ~= Enum.UserInputType.MouseButton3 then
                    return
                end
                
                Library._choosing_keybind = true
                
                Connections['keybind_choose_start'] = UserInputService.InputBegan:Connect(function(input: InputObject, process: boolean)
                    if process then
                        return
                    end
                    
                    if input == Enum.UserInputState or input == Enum.UserInputType then
                        return
                    end

                    if input.KeyCode == Enum.KeyCode.Unknown then
                        return
                    end

                    if input.KeyCode == Enum.KeyCode.Backspace then
                        ModuleManager:scale_keybind(true)

                        Library._config._keybinds[settings.flag] = nil
                        Config:save(game.GameId, Library._config)

                        TextLabel.Text = 'None'
                        
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

                    local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                    TextLabel.Text = keybind_string
                end)
            end)

            Header.MouseButton1Click:Connect(function()
                ModuleManager:change_state(not ModuleManager._state)
            end)

            function ModuleManager:create_paragraph(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1;

                local ParagraphManager = {}
                
                if self._size == 0 then
                    self._size = 11
                end
            
                self._size += settings.customScale or 70
            
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end
            
                Options.Size = UDim2.fromOffset(241, self._size)
            
                local Paragraph = Instance.new('Frame')
                Paragraph.BackgroundColor3 = ThemeRGB(28, 35, 65)
                Paragraph.BackgroundTransparency = 0.1
                Paragraph.Size = UDim2.new(0, 207, 0, 30)
                Paragraph.BorderSizePixel = 0
                Paragraph.Name = "Paragraph"
                Paragraph.AutomaticSize = Enum.AutomaticSize.Y
                Paragraph.Parent = Options
                Paragraph.LayoutOrder = LayoutOrderModule;
            
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Paragraph
            
                local Title = Instance.new('TextLabel')
                Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Title.TextColor3 = ThemeRGB(220, 235, 255)
                Title.Text = settings.title or "Title"
                Title.Size = UDim2.new(1, -10, 0, 20)
                Title.Position = UDim2.new(0, 5, 0, 5)
                Title.BackgroundTransparency = 1
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.TextYAlignment = Enum.TextYAlignment.Center
                Title.TextSize = 12
                Title.AutomaticSize = Enum.AutomaticSize.XY
                Title.Parent = Paragraph
            
                local Body = Instance.new('TextLabel')
                Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Body.TextColor3 = ThemeRGB(180, 200, 230)
                
                if not settings.rich then
                    Body.Text = settings.text or "Skibidi"
                else
                    Body.RichText = true
                    Body.Text = settings.richtext or "<font color='rgb(255,0,0)'>VicoX</font> user"
                end
                
                Body.Size = UDim2.new(1, -10, 0, 20)
                Body.Position = UDim2.new(0, 5, 0, 30)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 11
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY
                Body.Parent = Paragraph
            
                Paragraph.MouseEnter:Connect(function()
                    TweenService:Create(Paragraph, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(35, 45, 80)
                    }):Play()
                end)
            
                Paragraph.MouseLeave:Connect(function()
                    TweenService:Create(Paragraph, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(28, 35, 65)
                    }):Play()
                end)

                return ParagraphManager
            end

            function ModuleManager:create_button(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1

                if self._size == 0 then
                    self._size = 11
                end
                self._size += 25

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(0, 207, 0, 20)
                Row.BackgroundTransparency = 1
                Row.BorderSizePixel = 0
                Row.LayoutOrder = LayoutOrderModule
                Row.Parent = Options

                local Title = Instance.new("TextLabel")
                Title.Text = settings.title or "Button"
                Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold)
                Title.TextSize = 11
                Title.TextColor3 = ThemeRGB(230, 242, 255)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(1, -40, 1, 0)
                Title.Parent = Row

                local SmallBtn = Instance.new("Frame")
                SmallBtn.Size = UDim2.new(0, 25, 0, 25)
                SmallBtn.Position = UDim2.new(1, -22, 0.5, 0)
                SmallBtn.AnchorPoint = Vector2.new(0, 0.5)
                SmallBtn.BackgroundColor3 = ThemeRGB(50, 80, 160)
                SmallBtn.BorderSizePixel = 0
                SmallBtn.Parent = Row

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 8)
                UICorner.Parent = SmallBtn

                local Icon = Instance.new("ImageLabel")
                Icon.Image = "rbxassetid://139650104834071"
                Icon.BackgroundTransparency = 1
                Icon.AnchorPoint = Vector2.new(0.5, 0.5)
                Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
                Icon.Size = UDim2.new(0.7, 0, 0.7, 0)
                Icon.Parent = SmallBtn

                SmallBtn.MouseEnter:Connect(function()
                    TweenService:Create(SmallBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(80, 120, 200)
                    }):Play()
                end)

                SmallBtn.MouseLeave:Connect(function()
                    TweenService:Create(SmallBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(50, 80, 160)
                    }):Play()
                end)

                task.spawn(function()
                    while Icon and Icon.Parent do
                        TweenService:Create(Icon, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                            Rotation = Icon.Rotation + 360
                        }):Play()
                        task.wait(2)
                    end
                end)

                local ClickDetector = Instance.new("TextButton")
                ClickDetector.Size = UDim2.fromScale(1, 1)
                ClickDetector.BackgroundTransparency = 1
                ClickDetector.Text = ""
                ClickDetector.Parent = SmallBtn

                ClickDetector.MouseButton1Click:Connect(function()
                    if settings.callback then
                        settings.callback()
                    end
                end)

                return Row
            end

            function ModuleManager:create_display(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1

                if self._size == 0 then
                    self._size = 11
                end
                self._size += (settings.height or 120)

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local DisplayFrame = Instance.new("Frame")
                DisplayFrame.Size = UDim2.new(0, 207, 0, settings.height or 120)
                DisplayFrame.BackgroundColor3 = ThemeRGB(25, 30, 58)
                DisplayFrame.BackgroundTransparency = 0.05
                DisplayFrame.BorderSizePixel = 0
                DisplayFrame.LayoutOrder = LayoutOrderModule
                DisplayFrame.Parent = Options

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = DisplayFrame

                local Img = Instance.new("ImageLabel")
                Img.Size = UDim2.new(1, -10, 1, -25)
                Img.Position = UDim2.new(0.5, 0, 0, 5)
                Img.AnchorPoint = Vector2.new(0.5, 0)
                Img.BackgroundTransparency = 1
                Img.Image = settings.image or "rbxassetid://11835491319"
                Img.ScaleType = Enum.ScaleType.Fit
                Img.Parent = DisplayFrame

                local Label = Instance.new("TextLabel")
                Label.Text = settings.text or "Image Preview"
                Label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold)
                Label.TextSize = 12
                Label.TextColor3 = ThemeRGB(210, 235, 255)
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(1, -10, 0, 18)

                if settings.textPosition == "center" then
                    Label.AnchorPoint = Vector2.new(0.5,0.5)
                    Label.Position = UDim2.new(0.5,0,0.5,0)
                else
                    Label.AnchorPoint = Vector2.new(0.5,1)
                    Label.Position = UDim2.new(0.5,0,1,-2)
                end

                Label.Parent = DisplayFrame

                if settings.glow then
                    local UIStroke = Instance.new("UIStroke")
                    UIStroke.Thickness = 2
                    UIStroke.Color = ThemeRGB(100, 185, 255)
                    UIStroke.Transparency = 0.3
                    UIStroke.Parent = Label
                end

                return DisplayFrame
            end

            function ModuleManager:create_colorpicker(settings: any)
                local UserInputService = game:GetService("UserInputService")
                local TweenService = game:GetService("TweenService")
                local Players = game:GetService("Players")
                local Mouse = Players.LocalPlayer:GetMouse()

                LayoutOrderModule += 1
                if self._size == 0 then self._size = 11 end
                self._size += 30
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end
                Options.Size = UDim2.fromOffset(241, self._size)

                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(0,207,0,25)
                Row.BackgroundTransparency = 1
                Row.LayoutOrder = LayoutOrderModule
                Row.Parent = Options

                local Title = Instance.new("TextLabel")
                Title.Text = settings.title or "Color"
                Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold)
                Title.TextSize = 11
                Title.TextColor3 = ThemeRGB(230, 242, 255)
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(1,-40,1,0)
                Title.Parent = Row

                local Preview = Instance.new("TextButton")
                Preview.Size = UDim2.new(0,25,0,25)
                Preview.Position = UDim2.new(1,-25,0,0)
                Preview.BackgroundColor3 = settings.default or Color3.new(1,1,1)
                Preview.Text = ""
                Preview.Parent = Row
                Instance.new("UICorner", Preview).CornerRadius = UDim.new(0,5)

                local VicoX = game:GetService("CoreGui"):FindFirstChild("VicoX")
                local Popup = Instance.new("Frame")
                Popup.Size = UDim2.new(0,330,0,300)
                Popup.AnchorPoint = Vector2.new(0.5,0.5)
                Popup.Position = UDim2.new(0.5,0,0.5,0)
                Popup.BackgroundColor3 = ThemeRGB(19, 22, 42)
                Popup.Visible = false
                Popup.ZIndex = 9999
                Popup.Parent = VicoX
                Instance.new("UICorner", Popup).CornerRadius = UDim.new(0,12)

                local TitleLbl = Instance.new("TextLabel")
                TitleLbl.Text = "Pick a color"
                TitleLbl.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold)
                TitleLbl.TextSize = 14
                TitleLbl.TextColor3 = ThemeRGB(220, 235, 255)
                TitleLbl.BackgroundTransparency = 1
                TitleLbl.Size = UDim2.new(1,0,0,30)
                TitleLbl.Parent = Popup
                TitleLbl.ZIndex = 10000

                local HSBox = Instance.new("Frame")
                HSBox.Size = UDim2.new(0,200,0,200)
                HSBox.Position = UDim2.new(0,15,0,40)
                HSBox.BackgroundColor3 = Color3.fromHSV(0,1,1)
                HSBox.BorderSizePixel = 0
                HSBox.Parent = Popup
                HSBox.ZIndex = 10000
                Instance.new("UICorner", HSBox).CornerRadius = UDim.new(0,6)

                local Overlay = Instance.new("ImageLabel")
                Overlay.Size = UDim2.new(1,0,1,0)
                Overlay.BackgroundTransparency = 1
                Overlay.Image = "rbxassetid://4155801252"
                Overlay.ScaleType = Enum.ScaleType.Stretch
                Overlay.Parent = HSBox
                Overlay.ZIndex = 10001
                Overlay.Active = false

                local Selector = Instance.new("Frame")
                Selector.Size = UDim2.new(0,14,0,14)
                Selector.AnchorPoint = Vector2.new(0.5,0.5)
                Selector.BackgroundColor3 = Color3.new(1,1,1)
                Selector.BorderSizePixel = 0
                Selector.Parent = HSBox
                Selector.ZIndex = 10002
                Instance.new("UICorner", Selector).CornerRadius = UDim.new(1,0)

                local HueBar = Instance.new("Frame")
                HueBar.Size = UDim2.new(0,20,0,200)
                HueBar.Position = UDim2.new(0,230,0,40)
                HueBar.BorderSizePixel = 0
                HueBar.Parent = Popup
                HueBar.ZIndex = 10000

                local HueGradient = Instance.new("UIGradient")
                local seq = {}
                for i=0,1,0.1 do
                    table.insert(seq, ColorSequenceKeypoint.new(i, Color3.fromHSV(i,1,1)))
                end
                HueGradient.Color = ColorSequence.new(seq)
                HueGradient.Rotation = 90
                HueGradient.Parent = HueBar

                local HueMarker = Instance.new("Frame")
                HueMarker.Size = UDim2.new(1,0,0,2)
                HueMarker.BackgroundColor3 = Color3.new(1,1,1)
                HueMarker.BorderSizePixel = 0
                HueMarker.Parent = HueBar
                HueMarker.ZIndex = 10001

                local AlphaBar = Instance.new("Frame")
                AlphaBar.Size = UDim2.new(0,200,0,15)
                AlphaBar.Position = UDim2.new(0,15,0,250)
                AlphaBar.BorderSizePixel = 0
                AlphaBar.Parent = Popup
                AlphaBar.ZIndex = 10000

                local AlphaGradient = Instance.new("UIGradient")
                AlphaGradient.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }
                AlphaGradient.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
                AlphaGradient.Parent = AlphaBar

                local AlphaMarker = Instance.new("Frame")
                AlphaMarker.Size = UDim2.new(0,2,1,0)
                AlphaMarker.BackgroundColor3 = Color3.new(1,1,1)
                AlphaMarker.BorderSizePixel = 0
                AlphaMarker.Parent = AlphaBar
                AlphaMarker.ZIndex = 10001

                local HexLbl = Instance.new("TextLabel")
                HexLbl.Size = UDim2.new(0,120,0,30)
                HexLbl.Position = UDim2.new(0,15,1,-35)
                HexLbl.BackgroundTransparency = 1
                HexLbl.TextColor3 = ThemeRGB(220, 235, 255)
                HexLbl.Font = Enum.Font.Code
                HexLbl.TextSize = 14
                HexLbl.Text = "#FFFFFF"
                HexLbl.TextXAlignment = Enum.TextXAlignment.Left
                HexLbl.Parent = Popup
                HexLbl.ZIndex = 10002

                local RgbLbl = Instance.new("TextLabel")
                RgbLbl.Size = UDim2.new(0,200,0,30)
                RgbLbl.Position = UDim2.new(0,150,1,-35)
                RgbLbl.BackgroundTransparency = 1
                RgbLbl.TextColor3 = ThemeRGB(180, 200, 230)
                RgbLbl.Font = Enum.Font.Code
                RgbLbl.TextSize = 14
                RgbLbl.Text = "R:255 G:255 B:255 A:100%"
                RgbLbl.TextXAlignment = Enum.TextXAlignment.Left
                RgbLbl.Parent = Popup
                RgbLbl.ZIndex = 10002

                local CloseBtn = Instance.new("ImageButton")
                CloseBtn.Image = "rbxassetid://10030850935"
                CloseBtn.Size = UDim2.new(0,20,0,20)
                CloseBtn.Position = UDim2.new(1,-30,0,5)
                CloseBtn.BackgroundTransparency = 1
                CloseBtn.Parent = Popup
                CloseBtn.ZIndex = 10001

                local YesBtn = Instance.new("ImageButton")
                YesBtn.Image = "rbxassetid://10030902360"
                YesBtn.Size = UDim2.new(0,20,0,20)
                YesBtn.Position = UDim2.new(1,-55,0,5)
                YesBtn.BackgroundTransparency = 1
                YesBtn.Parent = Popup
                YesBtn.ZIndex = 10001

                local hue, sat, val, alpha = 0,1,1,1
                local draggingHS, draggingHue, draggingAlpha = false, false, false

                local function updateColor()
                    local col = Color3.fromHSV(hue,sat,val)
                    HSBox.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                    Selector.Position = UDim2.new(sat,0,1-val,0)
                    Preview.BackgroundColor3 = col
                    HexLbl.Text = "#" .. col:ToHex():upper()
                    RgbLbl.Text = ("R:%d G:%d B:%d A:%d%%"):format(
                        math.floor(col.R*255),
                        math.floor(col.G*255),
                        math.floor(col.B*255),
                        alpha*100
                    )
                    return col
                end

                HSBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHS = true end
                end)
                HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true end
                end)
                AlphaBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingAlpha = true end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingHS, draggingHue, draggingAlpha = false,false,false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        local pos = input.Position
                        if draggingHS then
                            local minX,maxX = HSBox.AbsolutePosition.X, HSBox.AbsolutePosition.X + HSBox.AbsoluteSize.X
                            local minY,maxY = HSBox.AbsolutePosition.Y, HSBox.AbsolutePosition.Y + HSBox.AbsoluteSize.Y
                            local mouseX = math.clamp(pos.X, minX, maxX)
                            local mouseY = math.clamp(pos.Y, minY, maxY)
                            sat = (mouseX - minX)/(maxX - minX)
                            val = 1 - ((mouseY - minY)/(maxY - minY))
                            updateColor()
                        elseif draggingHue then
                            local minY,maxY = HueBar.AbsolutePosition.Y, HueBar.AbsolutePosition.Y + HueBar.AbsoluteSize.Y
                            local mouseY = math.clamp(pos.Y, minY, maxY)
                            hue = (mouseY - minY)/(maxY - minY)
                            HueMarker.Position = UDim2.new(0,0,hue,0)
                            updateColor()
                        elseif draggingAlpha then
                            local minX,maxX = AlphaBar.AbsolutePosition.X, AlphaBar.AbsolutePosition.X + AlphaBar.AbsoluteSize.X
                            local mouseX = math.clamp(pos.X, minX, maxX)
                            alpha = (mouseX - minX)/(maxX - minX)
                            AlphaMarker.Position = UDim2.new(alpha,0,0,0)
                            updateColor()
                        end
                    end
                end)

                Preview.MouseButton1Click:Connect(function()
                    Popup.Visible = true
                    Popup.Size = UDim2.new(0,280,0,230)
                    Popup.BackgroundTransparency = 1
                    TweenService:Create(Popup, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0,
                        Size = UDim2.new(0,330,0,300)
                    }):Play()
                end)
                CloseBtn.MouseButton1Click:Connect(function() Popup.Visible = false end)
                YesBtn.MouseButton1Click:Connect(function()
                    local col = updateColor()
                    if settings.callback then settings.callback(col, alpha) end
                    Popup.Visible = false
                end)

                return { 
                    Set = function(_,c) 
                        Preview.BackgroundColor3 = c 
                    end 
                }
            end

            function ModuleManager:create_3dview(settings: any)
                local TweenService = game:GetService("TweenService")

                LayoutOrderModule += 1
                if self._size == 0 then self._size = 11 end
                self._size += 260
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end
                Options.Size = UDim2.fromOffset(241, self._size)

                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(0, 207, 0, 260)
                Row.BackgroundTransparency = 1
                Row.LayoutOrder = LayoutOrderModule
                Row.Parent = Options

                local Title = Instance.new("TextLabel")
                Title.Text = settings.title or "3D View"
                Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold)
                Title.TextSize = 12
                Title.TextColor3 = ThemeRGB(230, 242, 255)
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(1,0,0,20)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = Row

                local Holder = Instance.new("Frame")
                Holder.Size = UDim2.new(1,0,1,-20)
                Holder.Position = UDim2.new(0,0,0,20)
                Holder.BackgroundColor3 = ThemeRGB(14, 16, 28)
                Holder.ClipsDescendants = true
                Holder.Parent = Row
                Instance.new("UICorner", Holder).CornerRadius = UDim.new(0,6)

                local ImageView = Instance.new("ImageLabel")
                ImageView.Size = UDim2.new(0,150,0,150)
                ImageView.AnchorPoint = Vector2.new(0.5,0.5)
                ImageView.Position = UDim2.new(0.5,0,0.5,0)
                ImageView.BackgroundTransparency = 1
                ImageView.Image = settings.image or "rbxassetid://5791744848"
                ImageView.ScaleType = Enum.ScaleType.Fit
                ImageView.Visible = false
                ImageView.Parent = Holder

                local Viewport = Instance.new("ViewportFrame")
                Viewport.Size = UDim2.new(1,0,1,0)
                Viewport.BackgroundColor3 = ThemeRGB(14, 16, 28)
                Viewport.Visible = false
                Viewport.Parent = Holder
                Instance.new("UICorner", Viewport).CornerRadius = UDim.new(0,6)

                local cam = Instance.new("Camera")
                cam.Parent = Viewport
                Viewport.CurrentCamera = cam

                local currentObj
                local is3D = false
                local zoomLevel = 1
                local baseDistance, currentDistance, originPos, maxDim

                local function showImage()
                    if currentObj then currentObj:Destroy() end
                    is3D = false
                    ImageView.Visible = true
                    Viewport.Visible = false
                    zoomLevel = 1
                    ImageView.Position = UDim2.new(0.5,0,0.5,0)
                    ImageView.Size = UDim2.new(0,150,0,150)
                end

                local function showModel(obj: Instance)
                    if currentObj then currentObj:Destroy() end
                    Viewport:ClearAllChildren()

                    obj.Archivable = true
                    local clone = obj:Clone()
                    clone.Parent = Viewport
                    currentObj = clone

                    local cf, size
                    if clone:IsA("Model") then
                        cf, size = clone:GetBoundingBox()
                        originPos = clone:GetPivot().Position
                    elseif clone:IsA("BasePart") then
                        cf, size = clone.CFrame, clone.Size
                        originPos = clone.Position
                    else
                        return showImage()
                    end

                    maxDim = math.max(size.X, size.Y, size.Z)
                    baseDistance = maxDim * 2.5
                    currentDistance = baseDistance

                    cam.CFrame = CFrame.new(originPos + Vector3.new(0, maxDim/2, currentDistance), originPos)

                    zoomLevel = 1
                    Viewport.Visible = true
                    ImageView.Visible = false
                    is3D = true
                end

                local function showMeshPart(meshId, texId)
                    local meshPart = Instance.new("MeshPart")
                    meshPart.Size = Vector3.new(5,5,5)
                    meshPart.MeshId = "rbxassetid://"..meshId
                    meshPart.TextureID = "rbxassetid://"..texId
                    showModel(meshPart)
                end

                if settings.model and (settings.model:IsA("Model") or settings.model:IsA("BasePart")) then
                    showModel(settings.model)
                elseif settings.meshId and settings.texId then
                    showMeshPart(settings.meshId, settings.texId)
                else
                    showImage()
                end

                local icons = {
                    up    = "rbxassetid://138007024966757",
                    down  = "rbxassetid://13360801719",
                    left  = "rbxassetid://100152237482023",
                    right = "rbxassetid://140701802205656",
                    zoomIn  = "rbxassetid://126943351764139",
                    zoomOut = "rbxassetid://110884638624335",
                    reset   = "rbxassetid://6723921202",
                }

                local function makeIcon(id, pos)
                    local b = Instance.new("ImageButton")
                    b.Image = id
                    b.Size = UDim2.new(0,24,0,24)
                    b.BackgroundTransparency = 0.3
                    b.BackgroundColor3 = ThemeRGB(19, 22, 42)
                    b.Position = pos
                    b.Parent = Viewport
                    b.ZIndex = 10
                    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
                    return b
                end

                local upBtn    = makeIcon(icons.up,    UDim2.new(0.5,-12,0,5))
                local downBtn  = makeIcon(icons.down,  UDim2.new(0.5,-12,1,-29))
                local leftBtn  = makeIcon(icons.left,  UDim2.new(0,5,0.5,-12))
                local rightBtn = makeIcon(icons.right, UDim2.new(1,-29,0.5,-12))
                local zoomInBtn  = makeIcon(icons.zoomIn,  UDim2.new(1,-80,1,-30))
                local zoomOutBtn = makeIcon(icons.zoomOut, UDim2.new(1,-55,1,-30))
                local resetBtn   = makeIcon(icons.reset,   UDim2.new(1,-30,1,-30))

                local function rotateOrMove(x,y)
                    if is3D and currentObj then
                        if currentObj:IsA("Model") then
                            currentObj:PivotTo(currentObj:GetPivot() * CFrame.Angles(0, math.rad(x), math.rad(y)))
                        elseif currentObj:IsA("BasePart") then
                            currentObj.CFrame = currentObj.CFrame * CFrame.Angles(0, math.rad(x), math.rad(y))
                        end
                    else
                        ImageView.Position = ImageView.Position + UDim2.new(0,x*5,0,-y*5)
                    end
                end

                local function smoothZoom(targetDist)
                    if not (is3D and originPos) then return end
                    currentDistance = math.clamp(targetDist, maxDim*0.5, maxDim*6)
                    local goalCF = CFrame.new(originPos + Vector3.new(0, maxDim/2, currentDistance), originPos)
                    TweenService:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        CFrame = goalCF
                    }):Play()
                end

                local function resetView()
                    if is3D and currentObj and originPos then
                        smoothZoom(baseDistance)
                    else
                        zoomLevel = 1
                        ImageView.Position = UDim2.new(0.5,0,0.5,0)
                        ImageView.Size = UDim2.new(0,150,0,150)
                    end
                end

                upBtn.MouseButton1Click:Connect(function() rotateOrMove(0,10) end)
                downBtn.MouseButton1Click:Connect(function() rotateOrMove(0,-10) end)
                leftBtn.MouseButton1Click:Connect(function() rotateOrMove(-10,0) end)
                rightBtn.MouseButton1Click:Connect(function() rotateOrMove(10,0) end)
                zoomInBtn.MouseButton1Click:Connect(function() smoothZoom(currentDistance - 0.5*maxDim) end)
                zoomOutBtn.MouseButton1Click:Connect(function() smoothZoom(currentDistance + 0.5*maxDim) end)
                resetBtn.MouseButton1Click:Connect(resetView)

                return {
                    SetModel = function(_,m) if m and (m:IsA("Model") or m:IsA("BasePart")) then showModel(m) end end,
                    SetMesh = function(_,meshId,texId) showMeshPart(meshId,texId) end,
                    SetImage = function(_,img) settings.image = img; showImage() end
                }
            end

            function ModuleManager:create_text(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1
            
                local TextManager = {}
            
                if self._size == 0 then
                    self._size = 11
                end
            
                self._size += settings.customScale or 50
            
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end
            
                Options.Size = UDim2.fromOffset(241, self._size)
            
                local TextFrame = Instance.new('Frame')
                TextFrame.BackgroundColor3 = ThemeRGB(25, 30, 58)
                TextFrame.BackgroundTransparency = 0.1
                TextFrame.Size = UDim2.new(0, 207, 0, settings.CustomYSize)
                TextFrame.BorderSizePixel = 0
                TextFrame.Name = "Text"
                TextFrame.AutomaticSize = Enum.AutomaticSize.Y
                TextFrame.Parent = Options
                TextFrame.LayoutOrder = LayoutOrderModule
            
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = TextFrame
            
                local Body = Instance.new('TextLabel')
                Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Body.TextColor3 = ThemeRGB(180, 200, 230)
            
                if not settings.rich then
                    Body.Text = settings.text or "Skibidi"
                else
                    Body.RichText = true
                    Body.Text = settings.richtext or "<font color='rgb(255,0,0)'>VicoX</font> user"
                end
            
                Body.Size = UDim2.new(1, -10, 1, 0)
                Body.Position = UDim2.new(0, 5, 0, 5)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = 10
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY
                Body.Parent = TextFrame
            
                TextFrame.MouseEnter:Connect(function()
                    TweenService:Create(TextFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(35, 42, 75)
                    }):Play()
                end)
            
                TextFrame.MouseLeave:Connect(function()
                    TweenService:Create(TextFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = ThemeRGB(25, 30, 58)
                    }):Play()
                end)

                function TextManager:Set(new_settings)
                    if not new_settings.rich then
                        Body.Text = new_settings.text or "Skibidi"
                    else
                        Body.RichText = true
                        Body.Text = new_settings.richtext or "<font color='rgb(255,0,0)'>VicoX</font> user"
                    end
                end;
            
                return TextManager
            end

            function ModuleManager:create_textbox(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1
            
                local TextboxManager = {
                    _text = ""
                }
            
                if self._size == 0 then
                    self._size = 11
                end
            
                self._size += 32
            
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end
            
                Options.Size = UDim2.fromOffset(241, self._size)
            
                local Label = Instance.new('TextLabel')
                Label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Label.TextColor3 = ThemeRGB(230, 242, 255)
                Label.TextTransparency = 0.2
                Label.Text = settings.title or "Enter text"
                Label.Size = UDim2.new(0, 207, 0, 13)
                Label.AnchorPoint = Vector2.new(0, 0)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BorderSizePixel = 0
                Label.Parent = Options
                Label.TextSize = 10;
                Label.LayoutOrder = LayoutOrderModule
            
                local Textbox = Instance.new('TextBox')
                Textbox.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Textbox.TextColor3 = ThemeRGB(220, 235, 255)
                Textbox.BorderColor3 = ThemeRGB(0, 0, 0)
                Textbox.PlaceholderText = settings.placeholder or "Enter text..."
                Textbox.Text = Library._config._flags[settings.flag] or ""
                Textbox.Name = 'Textbox'
                Textbox.Size = UDim2.new(0, 207, 0, 15)
                Textbox.BorderSizePixel = 0
                Textbox.TextSize = 10
                Textbox.BackgroundColor3 = ThemeRGB(100, 185, 255)
                Textbox.BackgroundTransparency = 0.9
                Textbox.ClearTextOnFocus = false
                Textbox.Parent = Options
                Textbox.LayoutOrder = LayoutOrderModule
            
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Textbox
            
                function TextboxManager:update_text(text: string)
                    self._text = text
                    Library._config._flags[settings.flag] = self._text
                    Config:save(game.GameId, Library._config)
                    settings.callback(self._text)
                end
            
                if Library:flag_type(settings.flag, 'string') then
                    TextboxManager:update_text(Library._config._flags[settings.flag])
                end
            
                Textbox.FocusLost:Connect(function()
                    TextboxManager:update_text(Textbox.Text)
                end)
            
                return TextboxManager
            end   

            function ModuleManager:create_checkbox(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1
                local CheckboxManager = { _state = false }
            
                if self._size == 0 then
                    self._size = 11
                end
                self._size += 20
            
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end
                Options.Size = UDim2.fromOffset(241, self._size)
            
                local Checkbox = Instance.new("TextButton")
                Checkbox.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Checkbox.TextColor3 = ThemeRGB(0, 0, 0)
                Checkbox.BorderColor3 = ThemeRGB(0, 0, 0)
                Checkbox.Text = ""
                Checkbox.AutoButtonColor = false
                Checkbox.BackgroundTransparency = 1
                Checkbox.Name = "Checkbox"
                Checkbox.Size = UDim2.new(0, 207, 0, 15)
                Checkbox.BorderSizePixel = 0
                Checkbox.TextSize = 14
                Checkbox.BackgroundColor3 = ThemeRGB(0, 0, 0)
                Checkbox.Parent = Options
                Checkbox.LayoutOrder = LayoutOrderModule
            
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Name = "TitleLabel"
                if SelectedLanguage == "th" then
                    TitleLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TitleLabel.TextSize = 13
                else
                    TitleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TitleLabel.TextSize = 11
                end
                TitleLabel.TextColor3 = ThemeRGB(230, 242, 255)
                TitleLabel.TextTransparency = 0.05
                TitleLabel.Text = settings.title or "Skibidi"
                TitleLabel.Size = UDim2.new(0, 142, 0, 13)
                TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
                TitleLabel.Position = UDim2.new(0, 0, 0.5, 0)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.Parent = Checkbox

                local KeybindBox = Instance.new("Frame")
                KeybindBox.Name = "KeybindBox"
                KeybindBox.Size = UDim2.fromOffset(14, 14)
                KeybindBox.Position = UDim2.new(1, -35, 0.5, 0)
                KeybindBox.AnchorPoint = Vector2.new(0, 0.5)
                KeybindBox.BackgroundColor3 = ThemeRGB(100, 185, 255)
                KeybindBox.BorderSizePixel = 0
                KeybindBox.Parent = Checkbox
            
                local KeybindCorner = Instance.new("UICorner")
                KeybindCorner.CornerRadius = UDim.new(0, 4)
                KeybindCorner.Parent = KeybindBox
            
                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.Name = "KeybindLabel"
                KeybindLabel.Size = UDim2.new(1, 0, 1, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.TextColor3 = ThemeRGB(220, 240, 255)
                KeybindLabel.TextScaled = false
                KeybindLabel.TextSize = 10
                KeybindLabel.Font = Enum.Font.SourceSans
                KeybindLabel.Text = Library._config._keybinds[settings.flag] 
                    and string.gsub(tostring(Library._config._keybinds[settings.flag]), "Enum.KeyCode.", "") 
                    or "..."
                KeybindLabel.Parent = KeybindBox
            
                local Box = Instance.new("Frame")
                Box.BorderColor3 = ThemeRGB(0, 0, 0)
                Box.AnchorPoint = Vector2.new(1, 0.5)
                Box.BackgroundTransparency = 0.9
                Box.Position = UDim2.new(1, 0, 0.5, 0)
                Box.Name = "Box"
                Box.Size = UDim2.new(0, 15, 0, 15)
                Box.BorderSizePixel = 0
                Box.BackgroundColor3 = ThemeRGB(100, 185, 255)
                Box.Parent = Checkbox
            
                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 4)
                BoxCorner.Parent = Box
            
                local Fill = Instance.new("Frame")
                Fill.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill.BackgroundTransparency = 0.2
                Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                Fill.BorderColor3 = ThemeRGB(0, 0, 0)
                Fill.Name = "Fill"
                Fill.BorderSizePixel = 0
                Fill.BackgroundColor3 = ThemeRGB(100, 185, 255)
                Fill.Parent = Box
            
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 3)
                FillCorner.Parent = Fill
            
                function CheckboxManager:change_state(state: boolean)
                    self._state = state
                    if self._state then
                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.7
                        }):Play()
                        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(9, 9)
                        }):Play()
                    else
                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.9
                        }):Play()
                        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(0, 0)
                        }):Play()
                    end
                    Library._config._flags[settings.flag] = self._state
                    Config:save(game.GameId, Library._config)
                    settings.callback(self._state)
                end
            
                if Library:flag_type(settings.flag, "boolean") then
                    CheckboxManager:change_state(Library._config._flags[settings.flag])
                end
            
                Checkbox.MouseButton1Click:Connect(function()
                    CheckboxManager:change_state(not CheckboxManager._state)
                end)
            
                Checkbox.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                    if Library._choosing_keybind then return end
            
                    Library._choosing_keybind = true
                    local chooseConnection
                    chooseConnection = UserInputService.InputBegan:Connect(function(keyInput, processed)
                        if processed then return end
                        if keyInput.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if keyInput.KeyCode == Enum.KeyCode.Unknown then return end
            
                        if keyInput.KeyCode == Enum.KeyCode.Backspace then
                            ModuleManager:scale_keybind(true)
                            Library._config._keybinds[settings.flag] = nil
                            Config:save(game.GameId, Library._config)
                            KeybindLabel.Text = "..."
                            if Connections[settings.flag .. "_keybind"] then
                                Connections[settings.flag .. "_keybind"]:Disconnect()
                                Connections[settings.flag .. "_keybind"] = nil
                            end
                            chooseConnection:Disconnect()
                            Library._choosing_keybind = false
                            return
                        end
            
                        chooseConnection:Disconnect()
                        Library._config._keybinds[settings.flag] = tostring(keyInput.KeyCode)
                        Config:save(game.GameId, Library._config)
                        if Connections[settings.flag .. "_keybind"] then
                            Connections[settings.flag .. "_keybind"]:Disconnect()
                            Connections[settings.flag .. "_keybind"] = nil
                        end
                        ModuleManager:connect_keybind()
                        ModuleManager:scale_keybind()
                        Library._choosing_keybind = false
            
                        local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                        KeybindLabel.Text = keybind_string
                    end)
                end)
            
                local keyPressConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local storedKey = Library._config._keybinds[settings.flag]
                        if storedKey and tostring(input.KeyCode) == storedKey then
                            CheckboxManager:change_state(not CheckboxManager._state)
                        end
                    end
                end)
                Connections[settings.flag .. "_keypress"] = keyPressConnection
            
                return CheckboxManager
            end

            function ModuleManager:create_divider(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1;
            
                if self._size == 0 then
                    self._size = 11
                end
            
                self._size += 27
            
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                local dividerHeight = 1
                local dividerWidth = 207
            
                local OuterFrame = Instance.new('Frame')
                OuterFrame.Size = UDim2.new(0, dividerWidth, 0, 20)
                OuterFrame.BackgroundTransparency = 1
                OuterFrame.Name = 'OuterFrame'
                OuterFrame.Parent = Options
                OuterFrame.LayoutOrder = LayoutOrderModule

                if settings and settings.showtopic then
                    local TextLabel = Instance.new('TextLabel')
                    TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel.TextColor3 = ThemeRGB(200, 225, 255)
                    TextLabel.TextTransparency = 0
                    TextLabel.Text = settings.title
                    TextLabel.Size = UDim2.new(0, 153, 0, 13)
                    TextLabel.Position = UDim2.new(0.5, 0, 0.501, 0)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                    TextLabel.BorderSizePixel = 0
                    TextLabel.AnchorPoint = Vector2.new(0.5,0.5)
                    TextLabel.BorderColor3 = ThemeRGB(0, 0, 0)
                    TextLabel.TextSize = 11
                    TextLabel.BackgroundColor3 = ThemeRGB(255, 255, 255)
                    TextLabel.ZIndex = 3;
                    TextLabel.TextStrokeTransparency = 0;
                    TextLabel.Parent = OuterFrame
                end;
                
                if not settings or settings and not settings.disableline then
                    local Divider = Instance.new('Frame')
                    Divider.Size = UDim2.new(1, 0, 0, dividerHeight)
                    Divider.BackgroundColor3 = ThemeRGB(100, 160, 255)
                    Divider.BorderSizePixel = 0
                    Divider.Name = 'Divider'
                    Divider.Parent = OuterFrame
                    Divider.ZIndex = 2;
                    Divider.Position = UDim2.new(0, 0, 0.5, -dividerHeight / 2)
                
                    local Gradient = Instance.new('UIGradient')
                    Gradient.Parent = Divider
                    Gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, ThemeRGB(100, 160, 255)),
                        ColorSequenceKeypoint.new(0.5, ThemeRGB(100, 160, 255)),
                        ColorSequenceKeypoint.new(1, ThemeRGB(100, 160, 255))
                    })
                    Gradient.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),   
                        NumberSequenceKeypoint.new(0.5, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                    Gradient.Rotation = 0
                
                    local UICorner = Instance.new('UICorner')
                    UICorner.CornerRadius = UDim.new(0, 2)
                    UICorner.Parent = Divider
                end;
            
                return true;
            end
            
            function ModuleManager:create_slider(settings: any)

                LayoutOrderModule = LayoutOrderModule + 1

                local SliderManager = {}

                if self._size == 0 then
                    self._size = 11
                end

                self._size += 27

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size)
                end

                Options.Size = UDim2.fromOffset(241, self._size)

                local Slider = Instance.new('TextButton')
                Slider.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal);
                Slider.TextSize = 14;
                Slider.TextColor3 = ThemeRGB(0, 0, 0)
                Slider.BorderColor3 = ThemeRGB(0, 0, 0)
                Slider.Text = ''
                Slider.AutoButtonColor = false
                Slider.BackgroundTransparency = 1
                Slider.Name = 'Slider'
                Slider.Size = UDim2.new(0, 207, 0, 22)
                Slider.BorderSizePixel = 0
                Slider.BackgroundColor3 = ThemeRGB(0, 0, 0)
                Slider.Parent = Options
                Slider.LayoutOrder = LayoutOrderModule
                
                local TextLabel = Instance.new('TextLabel')
                if GG.SelectedLanguage == "th" then
                    TextLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel.TextSize = 13;
                else
                    TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel.TextSize = 11;
                end;
                TextLabel.TextColor3 = ThemeRGB(230, 242, 255)
                TextLabel.TextTransparency = 0.20000000298023224
                TextLabel.Text = settings.title
                TextLabel.Size = UDim2.new(0, 153, 0, 13)
                TextLabel.Position = UDim2.new(0, 0, 0.05000000074505806, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.BorderSizePixel = 0
                TextLabel.BorderColor3 = ThemeRGB(0, 0, 0)
                TextLabel.BackgroundColor3 = ThemeRGB(255, 255, 255)
                TextLabel.Parent = Slider
                
                local Drag = Instance.new('Frame')
                Drag.BorderColor3 = ThemeRGB(0, 0, 0)
                Drag.AnchorPoint = Vector2.new(0.5, 1)
                Drag.BackgroundTransparency = 0.8999999761581421
                Drag.Position = UDim2.new(0.5, 0, 0.949999988079071, 0)
                Drag.Name = 'Drag'
                Drag.Size = UDim2.new(0, 207, 0, 4)
                Drag.BorderSizePixel = 0
                Drag.BackgroundColor3 = ThemeRGB(100, 185, 255)
                Drag.Parent = Slider
                
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = Drag
                
                local Fill = Instance.new('Frame')
                Fill.BorderColor3 = ThemeRGB(0, 0, 0)
                Fill.AnchorPoint = Vector2.new(0, 0.5)
                Fill.BackgroundTransparency = 0.5
                Fill.Position = UDim2.new(0, 0, 0.5, 0)
                Fill.Name = 'Fill'
                Fill.Size = UDim2.new(0, 103, 0, 4)
                Fill.BorderSizePixel = 0
                Fill.BackgroundColor3 = ThemeRGB(100, 185, 255)
                Fill.Parent = Drag
                
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 3)
                UICorner.Parent = Fill
                
                local UIGradient = Instance.new('UIGradient')
                UIGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, ThemeRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, ThemeRGB(120, 160, 220))
                }
                UIGradient.Parent = Fill
                
                local Circle = Instance.new('Frame')
                Circle.AnchorPoint = Vector2.new(1, 0.5)
                Circle.Name = 'Circle'
                Circle.Position = UDim2.new(1, 0, 0.5, 0)
                Circle.BorderColor3 = ThemeRGB(0, 0, 0)
                Circle.Size = UDim2.new(0, 6, 0, 6)
                Circle.BorderSizePixel = 0
                Circle.BackgroundColor3 = ThemeRGB(255, 255, 255)
                Circle.Parent = Fill
                
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = Circle
                
                local Value = Instance.new('TextLabel')
                Value.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Value.TextColor3 = ThemeRGB(190, 225, 255)
                Value.TextTransparency = 0.0
                Value.Text = '50'
                Value.Name = 'Value'
                Value.Size = UDim2.new(0, 42, 0, 13)
                Value.AnchorPoint = Vector2.new(1, 0)
                Value.Position = UDim2.new(1, 0, 0, 0)
                Value.BackgroundTransparency = 1
                Value.TextXAlignment = Enum.TextXAlignment.Right
                Value.BorderSizePixel = 0
                Value.BorderColor3 = ThemeRGB(0, 0, 0)
                Value.TextSize = 10
                Value.BackgroundColor3 = ThemeRGB(255, 255, 255)
                Value.Parent = Slider

                function SliderManager:set_percentage(percentage: number)
                    if percentage == nil or type(percentage) ~= "number" then     
                        return
                    end

                    local rounded_number = 0

                    if settings.round_number then
                        rounded_number = math.floor(percentage)
                    else
                        rounded_number = math.floor(percentage * 10) / 10
                    end

                    percentage = (percentage - settings.minimum_value) / (settings.maximum_value - settings.minimum_value)

                    local slider_size = math.clamp(percentage, 0.02, 1) * Drag.Size.X.Offset
                    local number_threshold = math.clamp(rounded_number, settings.minimum_value, settings.maximum_value)

                    Library._config._flags[settings.flag] = number_threshold
                    Value.Text = number_threshold

                    TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.fromOffset(slider_size, Drag.Size.Y.Offset)
                    }):Play()

                    if settings.callback then
                        settings.callback(number_threshold)
                    end
                end

                function SliderManager:update()
                    local mouse_position = (mouse.X - Drag.AbsolutePosition.X) / Drag.Size.X.Offset
                    local percentage = settings.minimum_value + (settings.maximum_value - settings.minimum_value) * mouse_position

                    self:set_percentage(percentage)
                end

                function SliderManager:input()
                    SliderManager:update()
    
                    Connections['slider_drag_'..settings.flag] = mouse.Move:Connect(function()
                        SliderManager:update()
                    end)
                    
                    Connections['slider_input_'..settings.flag] = UserInputService.InputEnded:Connect(function(input: InputObject, process: boolean)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                            return
                        end
    
                        Connections:disconnect('slider_drag_'..settings.flag)
                        Connections:disconnect('slider_input_'..settings.flag)

                        if not settings.ignoresaved then
                            Config:save(game.GameId, Library._config);
                        end;
                    end)
                end

                if Library:flag_type(settings.flag, 'number') then
                    if not settings.ignoresaved then
                        SliderManager:set_percentage(Library._config._flags[settings.flag]);
                    else
                        SliderManager:set_percentage(settings.value);
                    end;
                else
                    SliderManager:set_percentage(settings.value);
                end;
    
                Slider.MouseButton1Down:Connect(function()
                    SliderManager:input()
                end)

                return SliderManager
            end

            function ModuleManager:create_dropdown(settings: any)

                if not settings.Order then
                    LayoutOrderModule = LayoutOrderModule + 1;
                end;

                local DropdownManager = {
                    _state = false,
                    _size = 0
                }

                if not settings.Order then
                    if self._size == 0 then
                        self._size = 11
                    end

                    self._size += 44
                end;

                if not settings.Order then
                    if ModuleManager._state then
                        Module.Size = UDim2.fromOffset(241, 93 + self._size)
                    end
                    Options.Size = UDim2.fromOffset(241, self._size)
                end

                local Dropdown = Instance.new('TextButton')
                Dropdown.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Dropdown.TextColor3 = ThemeRGB(0, 0, 0)
                Dropdown.BorderColor3 = ThemeRGB(0, 0, 0)
                Dropdown.Text = ''
                Dropdown.AutoButtonColor = false
                Dropdown.BackgroundTransparency = 1
                Dropdown.Name = 'Dropdown'
                Dropdown.Size = UDim2.new(0, 207, 0, 39)
                Dropdown.BorderSizePixel = 0
                Dropdown.TextSize = 14
                Dropdown.BackgroundColor3 = ThemeRGB(0, 0, 0)
                Dropdown.Parent = Options

                if not settings.Order then
                    Dropdown.LayoutOrder = LayoutOrderModule;
                else
                    Dropdown.LayoutOrder = settings.OrderValue;
                end;

                if not Library._config._flags[settings.flag] then
                    Library._config._flags[settings.flag] = {};
                end;
                
                local TextLabel = Instance.new('TextLabel')
                if GG.SelectedLanguage == "th" then
                    TextLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TextLabel.TextSize = 13;
                else
                    TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
                    TextLabel.TextSize = 11;
                end;
                TextLabel.TextColor3 = ThemeRGB(230, 242, 255)
                TextLabel.TextTransparency = 0.20000000298023224
                TextLabel.Text = settings.title
                TextLabel.Size = UDim2.new(0, 207, 0, 13)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.BorderSizePixel = 0
                TextLabel.BorderColor3 = ThemeRGB(0, 0, 0)
                TextLabel.BackgroundColor3 = ThemeRGB(255, 255, 255)
                TextLabel.Parent = Dropdown
                
                local Box = Instance.new('Frame')
                Box.ClipsDescendants = true
                Box.BorderColor3 = ThemeRGB(0, 0, 0)
                Box.AnchorPoint = Vector2.new(0.5, 0)
                Box.BackgroundTransparency = 0.8999999761581421
                Box.Position = UDim2.new(0.5, 0, 1.2000000476837158, 0)
                Box.Name = 'Box'
                Box.Size = UDim2.new(0, 207, 0, 22)
                Box.BorderSizePixel = 0
                Box.BackgroundColor3 = ThemeRGB(100, 185, 255)
                Box.Parent = TextLabel
                
                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Box
                
                local Header = Instance.new('Frame')
                Header.BorderColor3 = ThemeRGB(0, 0, 0)
                Header.AnchorPoint = Vector2.new(0.5, 0)
                Header.BackgroundTransparency = 1
                Header.Position = UDim2.new(0.5, 0, 0, 0)
                Header.Name = 'Header'
                Header.Size = UDim2.new(0, 207, 0, 22)
                Header.BorderSizePixel = 0
                Header.BackgroundColor3 = ThemeRGB(255, 255, 255)
                Header.Parent = Box
                
                local CurrentOption = Instance.new('TextLabel')
                CurrentOption.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                CurrentOption.TextColor3 = ThemeRGB(220, 235, 255)
                CurrentOption.TextTransparency = 0.05
                CurrentOption.Name = 'CurrentOption'
                CurrentOption.Size = UDim2.new(0, 161, 0, 13)
                CurrentOption.AnchorPoint = Vector2.new(0, 0.5)
                CurrentOption.Position = UDim2.new(0.04999988153576851, 0, 0.5, 0)
                CurrentOption.BackgroundTransparency = 1
                CurrentOption.TextXAlignment = Enum.TextXAlignment.Left
                CurrentOption.BorderSizePixel = 0
                CurrentOption.BorderColor3 = ThemeRGB(0, 0, 0)
                CurrentOption.TextSize = 10
                CurrentOption.BackgroundColor3 = ThemeRGB(255, 255, 255)
                CurrentOption.Parent = Header
                local UIGradient = Instance.new('UIGradient')
                UIGradient.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(0.704, 0),
                    NumberSequenceKeypoint.new(0.872, 0.36250001192092896),
                    NumberSequenceKeypoint.new(1, 1)
                }
                UIGradient.Parent = CurrentOption
                
                local Arrow = Instance.new('ImageLabel')
                Arrow.BorderColor3 = ThemeRGB(0, 0, 0)
                Arrow.AnchorPoint = Vector2.new(0, 0.5)
                Arrow.Image = 'rbxassetid://84232453189324'
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(0.9100000262260437, 0, 0.5, 0)
                Arrow.Name = 'Arrow'
                Arrow.Size = UDim2.new(0, 8, 0, 8)
                Arrow.BorderSizePixel = 0
                Arrow.BackgroundColor3 = ThemeRGB(255, 255, 255)
                Arrow.Parent = Header
                
                local Options = Instance.new('ScrollingFrame')
                Options.ScrollBarImageColor3 = ThemeRGB(0, 0, 0)
                Options.Active = true
                Options.ScrollBarImageTransparency = 1
                Options.AutomaticCanvasSize = Enum.AutomaticSize.XY
                Options.ScrollBarThickness = 0
                Options.Name = 'Options'
                Options.Size = UDim2.new(0, 207, 0, 0)
                Options.BackgroundTransparency = 1
                Options.Position = UDim2.new(0, 0, 1, 0)
                Options.BackgroundColor3 = ThemeRGB(255, 255, 255)
                Options.BorderColor3 = ThemeRGB(0, 0, 0)
                Options.BorderSizePixel = 0
                Options.CanvasSize = UDim2.new(0, 0, 0.5, 0)
                Options.Parent = Box
                
                local UIListLayout = Instance.new('UIListLayout')
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Parent = Options
                
                local UIPadding = Instance.new('UIPadding')
                UIPadding.PaddingTop = UDim.new(0, -1)
                UIPadding.PaddingLeft = UDim.new(0, 10)
                UIPadding.Parent = Options
                
                local UIListLayout = Instance.new('UIListLayout')
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Parent = Box

                function DropdownManager:update(option: string)
                    if settings.multi_dropdown then
                        if not Library._config._flags[settings.flag] then
                            Library._config._flags[settings.flag] = {};
                        end;

                        local CurrentTargetValue = nil;
                        
                        if #Library._config._flags[settings.flag] > 0 then
                            CurrentTargetValue = convertTableToString(Library._config._flags[settings.flag]);
                        end;

                        local selected = {}

                        if CurrentTargetValue then
                            for value in string.gmatch(CurrentTargetValue, "([^,]+)") do
                                local trimmedValue = value:match("^%s*(.-)%s*$")
                                
                                if trimmedValue ~= "Label" then
                                    table.insert(selected, trimmedValue)
                                end
                            end
                        else
                            for value in string.gmatch(CurrentOption.Text, "([^,]+)") do
                                local trimmedValue = value:match("^%s*(.-)%s*$")
                                
                                if trimmedValue ~= "Label" then
                                    table.insert(selected, trimmedValue)
                                end
                            end
                        end;
                
                        local CurrentTextGet = convertStringToTable(CurrentOption.Text);

                        optionSkibidi = "nil";
                        if typeof(option) ~= 'string' then
                            optionSkibidi = option.Name;
                        else
                            optionSkibidi = option;
                        end;

                        local found = false
                        for i, v in pairs(CurrentTextGet) do
                            if v == optionSkibidi then
                                table.remove(CurrentTextGet, i);
                                break;
                            end
                        end

                        CurrentOption.Text = table.concat(selected, ", ")
                        local OptionsChild = {}
                        for _, object in Options:GetChildren() do
                            if object.Name == "Option" then
                                table.insert(OptionsChild, object.Text)
                                if table.find(selected, object.Text) then
                                    object.TextTransparency = 0.2
                                else
                                    object.TextTransparency = 0.6
                                end
                            end
                        end

                        CurrentTargetValue = convertStringToTable(CurrentOption.Text);

                        for _, v in CurrentTargetValue do
                            if not table.find(OptionsChild, v) and table.find(selected, v) then
                                table.remove(selected, _)
                            end;
                        end;

                        CurrentOption.Text = table.concat(selected, ", ");
                
                        Library._config._flags[settings.flag] = convertStringToTable(CurrentOption.Text);
                    else
                        CurrentOption.Text = (typeof(option) == "string" and option) or option.Name
                        for _, object in Options:GetChildren() do
                            if object.Name == "Option" then
                                if object.Text == CurrentOption.Text then
                                    object.TextTransparency = 0.2
                                else
                                    object.TextTransparency = 0.6
                                end
                            end
                        end
                        Library._config._flags[settings.flag] = option
                    end
                    
                    Config:save(game.GameId, Library._config)
                    settings.callback(option)
                end
                
                local CurrentDropSizeState = 0;

                function DropdownManager:unfold_settings()
                    self._state = not self._state

                    if self._state then
                        ModuleManager._multiplier += self._size

                        CurrentDropSizeState = self._size;

                        TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, 93 + ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Module.Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(207, 39 + self._size)
                        }):Play()

                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(207, 22 + self._size)
                        }):Play()

                        TweenService:Create(Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Rotation = 180
                        }):Play()
                    else
                        ModuleManager._multiplier -= self._size

                        CurrentDropSizeState = 0;

                        TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, 93 + ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Module.Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(241, ModuleManager._size + ModuleManager._multiplier)
                        }):Play()

                        TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(207, 39)
                        }):Play()

                        TweenService:Create(Box, TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(207, 22)
                        }):Play())

                        TweenService:Create(Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Rotation = 0
                        }):Play()
                    end
                end

                if #settings.options > 0 then
                    DropdownManager._size = 3

                    for index, value in settings.options do
                        local Option = Instance.new('TextButton')
                        Option.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                        Option.Active = false
                        Option.TextTransparency = 0.6000000238418579
                        Option.AnchorPoint = Vector2.new(0, 0.5)
                        Option.TextSize = 10
                        Option.Size = UDim2.new(0, 186, 0, 16)
                        Option.TextColor3 = ThemeRGB(220, 235, 255)
                        Option.BorderColor3 = ThemeRGB(0, 0, 0)
                        Option.Text = (typeof(value) == "string" and value) or value.Name;
                        Option.AutoButtonColor = false
                        Option.Name = 'Option'
                        Option.BackgroundTransparency = 1
                        Option.TextXAlignment = Enum.TextXAlignment.Left
                        Option.Selectable = false
                        Option.Position = UDim2.new(0.04999988153576851, 0, 0.34210526943206787, 0)
                        Option.BorderSizePixel = 0
                        Option.BackgroundColor3 = ThemeRGB(255, 255, 255)
                        Option.Parent = Options
                        
                        local UIGradient = Instance.new('UIGradient')
                        UIGradient.Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.704, 0),
                            NumberSequenceKeypoint.new(0.872, 0.36250001192092896),
                            NumberSequenceKeypoint.new(1, 1)
                        }
                        UIGradient.Parent = Option

                        Option.MouseButton1Click:Connect(function()
                            if not Library._config._flags[settings.flag] then
                                Library._config._flags[settings.flag] = {};
                            end;

                            if settings.multi_dropdown then
                                if table.find(Library._config._flags[settings.flag], value) then
                                    Library:remove_table_value(Library._config._flags[settings.flag], value)
                                else
                                    table.insert(Library._config._flags[settings.flag], value)
                                end
                            end

                            DropdownManager:update(value)
                        end)

                        settings.maximum_options = settings.maximum_options or #settings.options
    
                        if index > settings.maximum_options then
                            continue
                        end
    
                        DropdownManager._size += 16
                        Options.Size = UDim2.fromOffset(207, DropdownManager._size)
                    end
                end

                function DropdownManager:New(value)
                    Dropdown:Destroy(true);
                    value.OrderValue = Dropdown.LayoutOrder
                    ModuleManager._multiplier -= CurrentDropSizeState
                    return ModuleManager:create_dropdown(value)
                end;

                if Library:flag_type(settings.flag, 'string') then
                    DropdownManager:update(Library._config._flags[settings.flag])
                else
                    DropdownManager:update(settings.options[1])
                end
    
                Dropdown.MouseButton1Click:Connect(function()
                    DropdownManager:unfold_settings()
                end)

                return DropdownManager
            end

            function ModuleManager:create_feature(settings)

                local checked = false;
                
                LayoutOrderModule = LayoutOrderModule + 1
            
                if self._size == 0 then
                    self._size = 11
                end
            
                self._size += 20
            
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(241, 93 + self._size);
                end
            
                Options.Size = UDim2.fromOffset(241, self._size);
            
                local FeatureContainer = Instance.new("Frame")
                FeatureContainer.Size = UDim2.new(0, 207, 0, 16)
                FeatureContainer.BackgroundTransparency = 1
                FeatureContainer.Parent = Options
                FeatureContainer.LayoutOrder = LayoutOrderModule
            
                local UIListLayout = Instance.new("UIListLayout")
                UIListLayout.FillDirection = Enum.FillDirection.Horizontal
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Parent = FeatureContainer
            
                local FeatureButton = Instance.new("TextButton")
                FeatureButton.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
                FeatureButton.TextSize = 11;
                FeatureButton.Size = UDim2.new(1, -35, 0, 16)
                FeatureButton.BackgroundColor3 = ThemeRGB(25, 30, 55)
                FeatureButton.TextColor3 = ThemeRGB(225, 240, 255)
                FeatureButton.Text = "    " .. settings.title or "    " .. "Feature"
                FeatureButton.AutoButtonColor = false
                FeatureButton.TextXAlignment = Enum.TextXAlignment.Left
                FeatureButton.TextTransparency = 0.05
                FeatureButton.Parent = FeatureContainer
            
                local RightContainer = Instance.new("Frame")
                RightContainer.Size = UDim2.new(0, 45, 0, 16)
                RightContainer.BackgroundTransparency = 1
                RightContainer.Parent = FeatureContainer
            
                local RightLayout = Instance.new("UIListLayout")
                RightLayout.Padding = UDim.new(0.1, 0)
                RightLayout.FillDirection = Enum.FillDirection.Horizontal
                RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
                RightLayout.Parent = RightContainer
            
                local KeybindBox = Instance.new("TextLabel")
                KeybindBox.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
                KeybindBox.Size = UDim2.new(0, 15, 0, 15)
                KeybindBox.BackgroundColor3 = ThemeRGB(100, 185, 255)
                KeybindBox.TextColor3 = ThemeRGB(220, 240, 255)
                KeybindBox.TextSize = 11
                KeybindBox.BackgroundTransparency = 1
                KeybindBox.LayoutOrder = 2;
                KeybindBox.Parent = RightContainer
            
                local KeybindButton = Instance.new("TextButton")
                KeybindButton.Size = UDim2.new(1, 0, 1, 0)
                KeybindButton.BackgroundTransparency = 1
                KeybindButton.TextTransparency = 1
                KeybindButton.Parent = KeybindBox

                local CheckboxCorner = Instance.new("UICorner", KeybindBox)
                CheckboxCorner.CornerRadius = UDim.new(0, 3)

                local UIStroke = Instance.new("UIStroke", KeybindBox)
                UIStroke.Color = ThemeRGB(100, 185, 255)
                UIStroke.Thickness = 1
                UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            
                if not Library._config._flags then
                    Library._config._flags = {}
                end
            
                if not Library._config._flags[settings.flag] then
                    Library._config._flags[settings.flag] = {
                        checked = false,
                        BIND = settings.default or "Unknown"
                    }
                end
            
                checked = Library._config._flags[settings.flag].checked
                KeybindBox.Text = Library._config._flags[settings.flag].BIND

                if KeybindBox.Text == "Unknown" then
                    KeybindBox.Text = "...";
                end;

                local UseF_Var = nil;
            
                if not settings.disablecheck then
                    local Checkbox = Instance.new("TextButton")
                    Checkbox.Size = UDim2.new(0, 15, 0, 15)
                    Checkbox.BackgroundColor3 = checked and ThemeRGB(100, 185, 255) or ThemeRGB(19, 22, 42)
                    Checkbox.Text = ""
                    Checkbox.Parent = RightContainer
                    Checkbox.LayoutOrder = 1;

                    local UIStroke = Instance.new("UIStroke", Checkbox)
                    UIStroke.Color = ThemeRGB(100, 185, 255)
                    UIStroke.Thickness = 1
                    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                    local CheckboxCorner = Instance.new("UICorner")
                    CheckboxCorner.CornerRadius = UDim.new(0, 3)
                    CheckboxCorner.Parent = Checkbox
            
                    local function toggleState()
                        checked = not checked
                        Checkbox.BackgroundColor3 = checked and ThemeRGB(100, 185, 255) or ThemeRGB(19, 22, 42)
                        Library._config._flags[settings.flag].checked = checked
                        Config:save(game.GameId, Library._config)
                        if settings.callback then
                            settings.callback(checked)
                        end
                    end

                    UseF_Var = toggleState
                
                    Checkbox.MouseButton1Click:Connect(toggleState)

                else

                    UseF_Var = function()
                        settings.button_callback();
                    end;

                end;
            
                KeybindButton.MouseButton1Click:Connect(function()
                    KeybindBox.Text = "..."
                    local inputConnection
                    inputConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local newKey = input.KeyCode.Name
                            Library._config._flags[settings.flag].BIND = newKey
                            if newKey ~= "Unknown" then
                                KeybindBox.Text = newKey;
                            end;
                            Config:save(game.GameId, Library._config)
                            inputConnection:Disconnect()
                        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                            Library._config._flags[settings.flag].BIND = "Unknown"
                            KeybindBox.Text = "..."
                            Config:save(game.GameId, Library._config)
                            inputConnection:Disconnect()
                        end
                    end)
                    Connections["keybind_input_" .. settings.flag] = inputConnection
                end)
            
                local keyPressConnection
                keyPressConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode.Name == Library._config._flags[settings.flag].BIND then
                            UseF_Var();
                        end
                    end
                end)
                Connections["keybind_press_" .. settings.flag] = keyPressConnection
            
                FeatureButton.MouseButton1Click:Connect(function()
                    if settings.button_callback then
                        settings.button_callback()
                    end
                end)

                if not settings.disablecheck then
                    settings.callback(checked);
                end;
            
                return FeatureContainer
            end                    

            return ModuleManager
        end

        return TabManager
    end

    Connections['library_visiblity'] = UserInputService.InputBegan:Connect(function(input: InputObject, process: boolean)
        if input.KeyCode ~= Enum.KeyCode.Insert then
            return
        end

        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    CollapsedHeader.MouseButton1Click:Connect(function()
        self._ui_open = true
        self:change_visiblity(true)
    end)

    self._ui.Container.Handler.Minimize.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    return self
end

return Library
