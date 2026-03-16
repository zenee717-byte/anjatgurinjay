--[[
    ╔═══════════════════════════════════════════╗
    ║         NOVA UI LIBRARY v1.0              ║
    ║   Redesigned by: Nova Team               ║
    ║   Horizontal tabs · Cyan accent · Dark   ║
    ╚═══════════════════════════════════════════╝
    
    API matches VicoX/GG Library:
    - Library.new() → lib
    - lib:load()
    - lib:create_tab(title, icon) → TabManager
    - TabManager:create_module(settings) → ModuleManager
    - ModuleManager:create_checkbox / slider / dropdown /
        button / textbox / paragraph / text / divider /
        colorpicker / 3dview / feature / display
    - Library.SendNotification(settings)
]]

getgenv().GG = {
    Language = {
        CheckboxEnabled  = "Enabled",
        CheckboxDisabled = "Disabled",
        SliderValue      = "Value",
        DropdownSelect   = "Select",
        DropdownNone     = "None",
        DropdownSelected = "Selected",
        ButtonClick      = "Click",
        TextboxEnter     = "Enter",
        ModuleEnabled    = "Enabled",
        ModuleDisabled   = "Disabled",
        TabGeneral       = "General",
        TabSettings      = "Settings",
        Loading          = "Loading...",
        Error            = "Error",
        Success          = "Success"
    }
}

local SelectedLanguage = GG.Language

-- ──────────────────────────────────────────────────────────
--  PALETTE
-- ──────────────────────────────────────────────────────────
local C = {
    BG          = Color3.fromRGB(9,  9,  21),
    CARD        = Color3.fromRGB(14, 14, 33),
    CARD2       = Color3.fromRGB(19, 19, 44),
    ELEM        = Color3.fromRGB(24, 24, 54),
    HOVER       = Color3.fromRGB(30, 30, 68),
    ACCENT      = Color3.fromRGB(0,  210, 255),
    ACCENT2     = Color3.fromRGB(155,80, 255),
    ACCENT_DIM  = Color3.fromRGB(0,  130, 160),
    STROKE      = Color3.fromRGB(38, 42, 100),
    STROKE2     = Color3.fromRGB(55, 60, 140),
    TXT         = Color3.fromRGB(235,240,255),
    TXT2        = Color3.fromRGB(155,165,215),
    TXT3        = Color3.fromRGB(100,110,170),
    RED         = Color3.fromRGB(255, 75, 100),
    GREEN       = Color3.fromRGB(60,  220,140),
    TOGGLE_OFF  = Color3.fromRGB(28, 28, 60),
    TOGGLE_ON   = Color3.fromRGB(0,  210, 255),
}

-- ──────────────────────────────────────────────────────────
--  HELPERS
-- ──────────────────────────────────────────────────────────
local function tinert(t, v) table.insert(t, v) end

function convertStringToTable(s)
    local r = {}
    for v in string.gmatch(s, "([^,]+)") do
        tinert(r, v:match("^%s*(.-)%s*$"))
    end
    return r
end

function convertTableToString(t)
    return table.concat(t, ", ")
end

-- ──────────────────────────────────────────────────────────
--  SERVICES
-- ──────────────────────────────────────────────────────────
local UIS      = cloneref(game:GetService("UserInputService"))
local CP       = cloneref(game:GetService("ContentProvider"))
local TS       = cloneref(game:GetService("TweenService"))
local HTTP     = cloneref(game:GetService("HttpService"))
local TXT_SVC  = cloneref(game:GetService("TextService"))
local RS       = cloneref(game:GetService("RunService"))
local LIGHT    = cloneref(game:GetService("Lighting"))
local PLAYERS  = cloneref(game:GetService("Players"))
local COREGUI  = cloneref(game:GetService("CoreGui"))
local DEBRIS   = cloneref(game:GetService("Debris"))

local mouse = PLAYERS.LocalPlayer:GetMouse()

do
    local old = COREGUI:FindFirstChild("Nova")
    if old then DEBRIS:AddItem(old, 0) end
end
if not isfolder("Nova") then makefolder("Nova") end

-- ──────────────────────────────────────────────────────────
--  CONNECTIONS
-- ──────────────────────────────────────────────────────────
local Connections = setmetatable({}, {
    __index = {
        disconnect = function(self, key)
            if self[key] then self[key]:Disconnect(); self[key] = nil end
        end,
        disconnect_all = function(self)
            for k, v in pairs(self) do
                if type(v) ~= "function" and typeof(v) ~= "string" then
                    pcall(function() v:Disconnect() end)
                end
            end
        end
    }
})

-- ──────────────────────────────────────────────────────────
--  UTIL
-- ──────────────────────────────────────────────────────────
local Util = {}
function Util:map(v,a,b,c,d) return (v-a)*(d-c)/(b-a)+c end
function Util:vp2w(loc, dist)
    local ray = workspace.CurrentCamera:ScreenPointToRay(loc.X, loc.Y)
    return ray.Origin + ray.Direction * dist
end
function Util:offset()
    return self:map(workspace.CurrentCamera.ViewportSize.Y, 0, 2560, 8, 56)
end

-- ──────────────────────────────────────────────────────────
--  ACRYLIC BLUR (same logic, kept functional)
-- ──────────────────────────────────────────────────────────
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(obj)
    local self = setmetatable({_obj=obj,_folder=nil,_frame=nil,_root=nil}, AcrylicBlur)
    self:setup(); return self
end
function AcrylicBlur:_mkfolder()
    local old = workspace.CurrentCamera:FindFirstChild("NovaBlur")
    if old then DEBRIS:AddItem(old,0) end
    local f = Instance.new("Folder"); f.Name="NovaBlur"; f.Parent=workspace.CurrentCamera
    self._folder = f
end
function AcrylicBlur:_mkdof()
    local dof = LIGHT:FindFirstChild("NovaBlur") or Instance.new("DepthOfFieldEffect")
    dof.FarIntensity=0; dof.FocusDistance=0.05; dof.InFocusRadius=0.1; dof.NearIntensity=1
    dof.Name="NovaBlur"; dof.Parent=LIGHT
    for _,o in LIGHT:GetChildren() do
        if o:IsA("DepthOfFieldEffect") and o ~= dof then
            Connections["dof_"..tostring(o)] = o:GetPropertyChangedSignal("FarIntensity"):Connect(function() o.FarIntensity=0 end)
            o.FarIntensity=0
        end
    end
end
function AcrylicBlur:_mkframe()
    local f = Instance.new("Frame")
    f.Size=UDim2.new(1,0,1,0); f.Position=UDim2.new(.5,0,.5,0)
    f.AnchorPoint=Vector2.new(.5,.5); f.BackgroundTransparency=1; f.Parent=self._obj
    self._frame=f
end
function AcrylicBlur:_mkroot()
    local p = Instance.new("Part")
    p.Name="Root"; p.Color=Color3.new(0,0,0); p.Material=Enum.Material.Glass
    p.Size=Vector3.new(1,1,0); p.Anchored=true; p.CanCollide=false
    p.CanQuery=false; p.Locked=true; p.CastShadow=false; p.Transparency=0.98
    p.Parent=self._folder
    local sm=Instance.new("SpecialMesh"); sm.MeshType=Enum.MeshType.Brick
    sm.Offset=Vector3.new(0,0,-.000001); sm.Parent=p
    self._root=p
end
function AcrylicBlur:setup()
    self:_mkdof(); self:_mkfolder(); self:_mkroot(); self:_mkframe()
    self:render(.001); self:_qualcheck()
end
function AcrylicBlur:render(dist)
    local tl,tr,br = Vector2.new(),Vector2.new(),Vector2.new()
    local function upd_pos(sz,pos) tl=pos; tr=pos+Vector2.new(sz.X,0); br=pos+sz end
    local function update()
        local tl3=Util:vp2w(tl,dist); local tr3=Util:vp2w(tr,dist); local br3=Util:vp2w(br,dist)
        local w=(tr3-tl3).Magnitude; local h=(tr3-br3).Magnitude
        if not self._root then return end
        local cam=workspace.CurrentCamera
        self._root.CFrame=CFrame.fromMatrix((tl3+br3)/2,cam.CFrame.XVector,cam.CFrame.YVector,cam.CFrame.ZVector)
        self._root.Mesh.Scale=Vector3.new(w,h,0)
    end
    local function onchg()
        local off=Util:offset()
        local sz=self._frame.AbsoluteSize-Vector2.new(off,off)
        local pos=self._frame.AbsolutePosition+Vector2.new(off/2,off/2)
        upd_pos(sz,pos); task.spawn(update)
    end
    Connections["ab_cf"]=workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(update)
    Connections["ab_vp"]=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    Connections["ab_fv"]=workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(update)
    Connections["ab_ap"]=self._frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(onchg)
    Connections["ab_as"]=self._frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(onchg)
    task.spawn(update)
end
function AcrylicBlur:_qualcheck()
    local gs=UserSettings().GameSettings
    local ql=gs.SavedQualityLevel.Value
    if ql<8 then self._root.Transparency=1 end
    Connections["ab_ql"]=gs:GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
        local v=UserSettings().GameSettings.SavedQualityLevel.Value
        self._root.Transparency=v>=8 and 0.98 or 1
    end)
end

-- ──────────────────────────────────────────────────────────
--  CONFIG
-- ──────────────────────────────────────────────────────────
local Config = {}
function Config:save(name, cfg)
    local ok,e=pcall(function()
        writefile("Nova/"..name..".json", HTTP:JSONEncode(cfg))
    end)
    if not ok then warn("Nova: save failed", e) end
end
function Config:load(name, cfg)
    local ok,r=pcall(function()
        if not isfile("Nova/"..name..".json") then self:save(name,cfg); return end
        local d=readfile("Nova/"..name..".json")
        if not d then self:save(name,cfg); return end
        return HTTP:JSONDecode(d)
    end)
    if not ok then warn("Nova: load failed", r) end
    return r or {_flags={},_keybinds={},_library={}}
end

-- ──────────────────────────────────────────────────────────
--  TWEEN SHORTHAND
-- ──────────────────────────────────────────────────────────
local function tween(obj, t, props, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir   = dir   or Enum.EasingDirection.Out
    TS:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

-- ──────────────────────────────────────────────────────────
--  NOVA NOTIFICATION SYSTEM  (bottom-left, minimal pill)
-- ──────────────────────────────────────────────────────────
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "NovaNotifications"
NotifGui.ResetOnSpawn = false
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifGui.DisplayOrder = 9999
NotifGui.IgnoreGuiInset = true
NotifGui.Parent = COREGUI

local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "Holder"
NotifHolder.Size = UDim2.new(0, 300, 1, 0)
NotifHolder.Position = UDim2.new(0, 12, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = NotifGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.FillDirection = Enum.FillDirection.Vertical
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 6)
NotifLayout.Parent = NotifHolder

local NotifPad = Instance.new("UIPadding")
NotifPad.PaddingBottom = UDim.new(0, 14)
NotifPad.Parent = NotifHolder

local nCount = 0

local Library = {}
Library.__index = Library

function Library.SendNotification(s)
    nCount += 1

    -- type → accent color
    local typeColor = C.ACCENT
    if s.type == "error"   then typeColor = C.RED   end
    if s.type == "success" then typeColor = C.GREEN  end
    if s.type == "warning" then typeColor = Color3.fromRGB(255, 190, 50) end

    -- Wrapper (for slide-in from left)
    local Wrap = Instance.new("Frame")
    Wrap.Name     = "N_"..nCount
    Wrap.Size     = UDim2.new(1, 0, 0, 64)
    Wrap.BackgroundTransparency = 1
    Wrap.ClipsDescendants = false
    Wrap.LayoutOrder = nCount
    Wrap.Position = UDim2.new(-1.2, 0, 0, 0)
    Wrap.Parent = NotifHolder

    -- Card
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 1, 0)
    Card.BackgroundColor3 = C.CARD
    Card.BorderSizePixel = 0
    Card.Parent = Wrap
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = typeColor
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Card

    -- Left colored bar
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 3, 0.65, 0)
    Bar.AnchorPoint = Vector2.new(0, 0.5)
    Bar.Position = UDim2.new(0, 8, 0.5, 0)
    Bar.BackgroundColor3 = typeColor
    Bar.BorderSizePixel = 0
    Bar.Parent = Card
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    -- Icon circle
    local IcBg = Instance.new("Frame")
    IcBg.Size = UDim2.new(0, 30, 0, 30)
    IcBg.AnchorPoint = Vector2.new(0, 0.5)
    IcBg.Position = UDim2.new(0, 18, 0.5, 0)
    IcBg.BackgroundColor3 = typeColor
    IcBg.BackgroundTransparency = 0.78
    IcBg.BorderSizePixel = 0
    IcBg.Parent = Card
    Instance.new("UICorner", IcBg).CornerRadius = UDim.new(1, 0)

    local Ic = Instance.new("ImageLabel")
    Ic.Image = s.icon or "rbxassetid://10653372143"
    Ic.Size = UDim2.new(0, 16, 0, 16)
    Ic.AnchorPoint = Vector2.new(0.5, 0.5)
    Ic.Position = UDim2.new(0.5, 0, 0.5, 0)
    Ic.BackgroundTransparency = 1
    Ic.ImageColor3 = Color3.new(1, 1, 1)
    Ic.ScaleType = Enum.ScaleType.Fit
    Ic.ZIndex = 2
    Ic.Parent = IcBg

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = s.title or "Nova"
    Title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    Title.TextSize = 13
    Title.TextColor3 = C.TXT
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -70, 0, 15)
    Title.Position = UDim2.new(0, 58, 0, 10)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Body = Instance.new("TextLabel")
    Body.Text = s.text or ""
    Body.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
    Body.TextSize = 11
    Body.TextColor3 = C.TXT2
    Body.BackgroundTransparency = 1
    Body.Size = UDim2.new(1, -70, 0, 28)
    Body.Position = UDim2.new(0, 58, 0, 26)
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.TextWrapped = true
    Body.Parent = Card

    -- Progress strip (bottom)
    local PBg = Instance.new("Frame")
    PBg.Size = UDim2.new(1, -16, 0, 2)
    PBg.AnchorPoint = Vector2.new(0.5, 1)
    PBg.Position = UDim2.new(0.5, 0, 1, -5)
    PBg.BackgroundColor3 = C.ELEM
    PBg.BorderSizePixel = 0
    PBg.ZIndex = 2
    PBg.Parent = Card
    Instance.new("UICorner", PBg).CornerRadius = UDim.new(1, 0)

    local PFill = Instance.new("Frame")
    PFill.Size = UDim2.new(1, 0, 1, 0)
    PFill.BackgroundColor3 = typeColor
    PFill.BorderSizePixel = 0
    PFill.ZIndex = 3
    PFill.Parent = PBg
    Instance.new("UICorner", PFill).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        tween(Wrap, 0.4, {Position = UDim2.new(0, 0, 0, 0)})
        local dur = s.duration or 5
        task.wait(0.45)
        tween(PFill, dur - 0.5, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
        task.wait(dur - 0.5)
        tween(Card, 0.35, {BackgroundTransparency = 1})
        tween(Wrap, 0.35, {Position = UDim2.new(-1.2, 0, 0, 0)})
        task.wait(0.4)
        Wrap:Destroy()
    end)
end

-- ──────────────────────────────────────────────────────────
--  LIBRARY
-- ──────────────────────────────────────────────────────────
Library._config         = Config:load(tostring(game.GameId))
Library._choosing_kb    = false
Library._device         = nil
Library._ui_open        = true
Library._ui_scale       = 1
Library._ui_loaded      = false
Library._ui             = nil
Library._dragging       = false
Library._drag_start     = nil
Library._drag_pos       = nil
Library._tab_btns       = {}   -- horizontal tab buttons list
Library._active_tab     = nil

function Library.new()
    local self = setmetatable({_loaded=false, _tab=0}, Library)
    self:create_ui()
    return self
end

function Library:get_screen_scale()
    self._ui_scale = workspace.CurrentCamera.ViewportSize.X / 1400
end

function Library:get_device()
    if not UIS.TouchEnabled and UIS.KeyboardEnabled and UIS.MouseEnabled then
        self._device = "PC"
    elseif UIS.TouchEnabled then
        self._device = "Mobile"
    elseif UIS.GamepadEnabled then
        self._device = "Console"
    else
        self._device = "Unknown"
    end
end

function Library:removed(action) self._ui.AncestryChanged:Once(action) end

function Library:flag_type(flag, t)
    if not Library._config._flags[flag] then return end
    return typeof(Library._config._flags[flag]) == t
end

function Library:remove_table_value(tbl, val)
    for i,v in tbl do
        if v == val then table.remove(tbl, i); break end
    end
end

-- ──────────────────────────────────────────────────────────
--  UI CREATION  (NOVA layout — horizontal tabs at top)
-- ──────────────────────────────────────────────────────────
function Library:create_ui()
    local old = COREGUI:FindFirstChild("Nova")
    if old then DEBRIS:AddItem(old, 0) end

    -- Root ScreenGui
    local Nova = Instance.new("ScreenGui")
    Nova.Name = "Nova"
    Nova.ResetOnSpawn = false
    Nova.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Nova.Parent = COREGUI

    -- ── Main Window Container ──────────────────────────────
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 0, 0, 0)           -- expanded on load
    Container.BackgroundColor3 = C.BG
    Container.BackgroundTransparency = 0.04
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Active = true
    Container.Parent = Nova
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 14)

    local WinStroke = Instance.new("UIStroke")
    WinStroke.Color = C.STROKE2
    WinStroke.Transparency = 0.35
    WinStroke.Thickness = 1.5
    WinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    WinStroke.Parent = Container

    local UIScale = Instance.new("UIScale")
    UIScale.Parent = Container

    -- ── Top Bar (52px) ────────────────────────────────────
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 52)
    TopBar.BackgroundColor3 = C.CARD
    TopBar.BackgroundTransparency = 0
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Container

    -- No UICorner on the top bar alone; the container clips it

    -- Gradient underline on TopBar
    local TBLine = Instance.new("Frame")
    TBLine.Name = "Line"
    TBLine.Size = UDim2.new(1, 0, 0, 1)
    TBLine.Position = UDim2.new(0, 0, 1, -1)
    TBLine.BorderSizePixel = 0
    TBLine.BackgroundColor3 = C.ACCENT
    TBLine.BackgroundTransparency = 0
    TBLine.Parent = TopBar
    Instance.new("UIGradient", TBLine).Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.15, 0),
        NumberSequenceKeypoint.new(0.85, 0),
        NumberSequenceKeypoint.new(1, 1)
    }

    -- Logo area (left)
    local LogoFrame = Instance.new("Frame")
    LogoFrame.Size = UDim2.new(0, 120, 1, 0)
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.Parent = TopBar

    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Image = "rbxassetid://10653372143"
    LogoIcon.Size = UDim2.new(0, 20, 0, 20)
    LogoIcon.AnchorPoint = Vector2.new(0, 0.5)
    LogoIcon.Position = UDim2.new(0, 14, 0.5, 0)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.ImageColor3 = C.ACCENT
    LogoIcon.ScaleType = Enum.ScaleType.Fit
    LogoIcon.Parent = LogoFrame

    -- pulsing logo animation
    task.spawn(function()
        while LogoIcon and LogoIcon.Parent do
            tween(LogoIcon, 1.2, {ImageTransparency = 0.3}, Enum.EasingStyle.Sine)
            task.wait(1.2)
            tween(LogoIcon, 1.2, {ImageTransparency = 0}, Enum.EasingStyle.Sine)
            task.wait(1.2)
        end
    end)

    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Text = "NOVA"
    LogoLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    LogoLabel.TextSize = 15
    LogoLabel.TextColor3 = C.TXT
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Size = UDim2.new(0, 60, 0, 18)
    LogoLabel.Position = UDim2.new(0, 40, 0.5, -9)
    LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogoLabel.Parent = LogoFrame

    local LogoGrad = Instance.new("UIGradient")
    LogoGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.ACCENT),
        ColorSequenceKeypoint.new(1, C.ACCENT2)
    }
    LogoGrad.Parent = LogoLabel

    -- Horizontal tab bar (center, scrollable)
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Name = "TabScroll"
    TabScroll.Size = UDim2.new(1, -270, 1, -8)
    TabScroll.Position = UDim2.new(0, 120, 0, 4)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.ScrollBarImageTransparency = 1
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.ScrollingDirection = Enum.ScrollingDirection.X
    TabScroll.Parent = TopBar

    local TabRowLayout = Instance.new("UIListLayout")
    TabRowLayout.FillDirection = Enum.FillDirection.Horizontal
    TabRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabRowLayout.Padding = UDim.new(0, 4)
    TabRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabRowLayout.Parent = TabScroll

    -- Right controls
    local CtrlFrame = Instance.new("Frame")
    CtrlFrame.Size = UDim2.new(0, 140, 1, 0)
    CtrlFrame.Position = UDim2.new(1, -144, 0, 0)
    CtrlFrame.BackgroundTransparency = 1
    CtrlFrame.Parent = TopBar

    -- Discord button (right side of TopBar)
    local DBtn = Instance.new("TextButton")
    DBtn.Size = UDim2.new(0, 90, 0, 30)
    DBtn.AnchorPoint = Vector2.new(0, 0.5)
    DBtn.Position = UDim2.new(0, 4, 0.5, 0)
    DBtn.BackgroundColor3 = C.CARD2
    DBtn.BorderSizePixel = 0
    DBtn.Text = ""
    DBtn.AutoButtonColor = false
    DBtn.Parent = CtrlFrame
    Instance.new("UICorner", DBtn).CornerRadius = UDim.new(0, 8)
    local DBtnStroke = Instance.new("UIStroke")
    DBtnStroke.Color = Color3.fromRGB(88, 101, 242)
    DBtnStroke.Transparency = 0.4; DBtnStroke.Thickness = 1
    DBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    DBtnStroke.Parent = DBtn

    local DIcon = Instance.new("ImageLabel")
    DIcon.Image = "rbxassetid://112538196670712"
    DIcon.Size = UDim2.new(0, 14, 0, 14)
    DIcon.AnchorPoint = Vector2.new(0, 0.5)
    DIcon.Position = UDim2.new(0, 10, 0.5, 0)
    DIcon.BackgroundTransparency = 1
    DIcon.ImageColor3 = Color3.fromRGB(140, 155, 255)
    DIcon.Parent = DBtn

    local DLbl = Instance.new("TextLabel")
    DLbl.Text = "Discord"
    DLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
    DLbl.TextSize = 11
    DLbl.TextColor3 = Color3.fromRGB(200, 210, 255)
    DLbl.BackgroundTransparency = 1
    DLbl.Size = UDim2.new(0, 55, 1, 0)
    DLbl.Position = UDim2.new(0, 28, 0, 0)
    DLbl.TextXAlignment = Enum.TextXAlignment.Left
    DLbl.Parent = DBtn

    DBtn.MouseEnter:Connect(function() tween(DBtn, 0.2, {BackgroundColor3 = C.HOVER}) end)
    DBtn.MouseLeave:Connect(function() tween(DBtn, 0.2, {BackgroundColor3 = C.CARD2}) end)
    DBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/gngstore")
        Library.SendNotification({title="Discord", text="Invite link copied!", icon="rbxassetid://112538196670712", duration=4})
    end)

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.AnchorPoint = Vector2.new(0, 0.5)
    MinBtn.Position = UDim2.new(0, 100, 0.5, 0)
    MinBtn.BackgroundColor3 = C.CARD2
    MinBtn.BorderSizePixel = 0
    MinBtn.Text = ""
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = CtrlFrame
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", MinBtn).Color = C.STROKE2

    local MinIcon = Instance.new("ImageLabel")
    MinIcon.Image = "rbxassetid://7072706796"
    MinIcon.Size = UDim2.new(0, 14, 0, 14)
    MinIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinIcon.BackgroundTransparency = 1
    MinIcon.ImageColor3 = C.TXT2
    MinIcon.Parent = MinBtn

    MinBtn.MouseEnter:Connect(function() tween(MinBtn, 0.2, {BackgroundColor3 = C.HOVER}) end)
    MinBtn.MouseLeave:Connect(function() tween(MinBtn, 0.2, {BackgroundColor3 = C.CARD2}) end)

    -- ── Content Area (below TopBar) ────────────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, 0, 1, -53)
    ContentArea.Position = UDim2.new(0, 0, 0, 53)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Container

    -- vertical divider between Left/Right
    local VDiv = Instance.new("Frame")
    VDiv.Name = "VDiv"
    VDiv.Size = UDim2.new(0, 1, 1, -16)
    VDiv.AnchorPoint = Vector2.new(0.5, 0.5)
    VDiv.Position = UDim2.new(0.5, 0, 0.5, 0)
    VDiv.BackgroundColor3 = C.STROKE2
    VDiv.BackgroundTransparency = 0.45
    VDiv.BorderSizePixel = 0
    VDiv.Parent = ContentArea

    local VDivGrad = Instance.new("UIGradient")
    VDivGrad.Rotation = 90
    VDivGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0),
        NumberSequenceKeypoint.new(0.8, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    VDivGrad.Parent = VDiv

    -- Sections folder
    local Sections = Instance.new("Folder")
    Sections.Name = "Sections"
    Sections.Parent = ContentArea

    -- active tab underline indicator
    local TabIndicator = Instance.new("Frame")
    TabIndicator.Name = "TabIndicator"
    TabIndicator.Size = UDim2.new(0, 60, 0, 2)
    TabIndicator.Position = UDim2.new(0, 0, 1, -1)
    TabIndicator.BackgroundColor3 = C.ACCENT
    TabIndicator.BorderSizePixel = 0
    TabIndicator.ZIndex = 10
    TabIndicator.Parent = TabScroll
    Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(1, 0)

    self._ui = Nova

    -- ── Drag ──────────────────────────────────────────────
    local function onDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = true
            self._drag_start = input.Position
            self._drag_pos = Container.Position
            Connections["drag_end"] = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Connections:disconnect("drag_end")
                    self._dragging = false
                end
            end)
        end
    end
    local function doDrag(input)
        if not self._dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - self._drag_start
            tween(Container, 0.15, {
                Position = UDim2.new(
                    self._drag_pos.X.Scale, self._drag_pos.X.Offset + d.X,
                    self._drag_pos.Y.Scale, self._drag_pos.Y.Offset + d.Y
                )
            })
        end
    end
    Connections["drag_begin"] = Container.InputBegan:Connect(onDrag)
    Connections["drag_move"]  = UIS.InputChanged:Connect(doDrag)

    self:removed(function()
        self._ui = nil
        Connections:disconnect_all()
    end)

    -- ── Visibility helpers ────────────────────────────────
    function self:UIVisiblity()
        Nova.Enabled = not Nova.Enabled
    end

    function self:Update1Run(a)
        if a == "nil" then
            Container.BackgroundTransparency = 0.04
        else
            pcall(function() Container.BackgroundTransparency = tonumber(a) end)
        end
    end

    function self:change_visiblity(state)
        if state then
            tween(Container, 0.45, {Size = UDim2.fromOffset(780, 460)})
        else
            tween(Container, 0.45, {Size = UDim2.fromOffset(152, 52)})
        end
    end

    -- ── Load ─────────────────────────────────────────────
    function self:load()
        local imgs = {}
        for _,o in Nova:GetDescendants() do
            if o:IsA("ImageLabel") then tinert(imgs, o) end
        end
        CP:PreloadAsync(imgs)
        self:get_device()

        if self._device == "Mobile" or self._device == "Unknown" then
            self:get_screen_scale()
            UIScale.Scale = self._ui_scale
            Connections["scale_vp"] = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                self:get_screen_scale(); UIScale.Scale = self._ui_scale
            end)
        end

        tween(Container, 0.5, {Size = UDim2.fromOffset(780, 460)})
        AcrylicBlur.new(Container)
        self._ui_loaded = true
    end

    -- ── Tab switching ─────────────────────────────────────
    function self:update_tabs(activeBtn)
        for _, btn in ipairs(self._tab_btns) do
            if btn == activeBtn then
                tween(btn, 0.3, {BackgroundTransparency = 0.75, BackgroundColor3 = C.ACCENT})
                tween(btn.TextLabel, 0.3, {TextColor3 = C.ACCENT, TextTransparency = 0})
                tween(btn.Icon, 0.3, {ImageColor3 = C.ACCENT, ImageTransparency = 0.1})
                -- move indicator
                tween(TabIndicator, 0.35, {
                    Position = UDim2.new(0, btn.Position.X.Offset, 1, -1),
                    Size     = UDim2.new(0, btn.AbsoluteSize.X, 0, 2)
                })
            else
                tween(btn, 0.3, {BackgroundTransparency = 1, BackgroundColor3 = C.CARD})
                tween(btn.TextLabel, 0.3, {TextColor3 = C.TXT3, TextTransparency = 0.2})
                tween(btn.Icon, 0.3, {ImageColor3 = C.TXT3, ImageTransparency = 0.6})
            end
        end
    end

    function self:update_sections(L, R)
        for _,o in Sections:GetChildren() do
            o.Visible = (o == L or o == R)
        end
    end

    -- ── Create Tab ────────────────────────────────────────
    function self:create_tab(title, icon)
        local TabManager = {}
        local LayoutOrderModule = 0

        local firstTab = #self._tab_btns == 0

        -- Measure text
        local fp = Instance.new("GetTextBoundsParams")
        fp.Text  = title
        fp.Font  = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
        fp.Size  = 12; fp.Width = 10000
        local fsz = TXT_SVC:GetTextBoundsAsync(fp)

        -- Tab pill button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab"
        TabBtn.Size = UDim2.new(0, math.max(70, fsz.X + 44), 0, 34)
        TabBtn.BackgroundColor3 = C.CARD
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.LayoutOrder = self._tab
        TabBtn.Parent = TabScroll
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 7)

        local TBIcon = Instance.new("ImageLabel")
        TBIcon.Name = "Icon"
        TBIcon.Image = icon
        TBIcon.Size = UDim2.new(0, 12, 0, 12)
        TBIcon.AnchorPoint = Vector2.new(0, 0.5)
        TBIcon.Position = UDim2.new(0, 10, 0.5, 0)
        TBIcon.BackgroundTransparency = 1
        TBIcon.ImageColor3 = C.TXT3
        TBIcon.ImageTransparency = 0.6
        TBIcon.ScaleType = Enum.ScaleType.Fit
        TBIcon.Parent = TabBtn

        local TBLbl = Instance.new("TextLabel")
        TBLbl.Name = "TextLabel"
        TBLbl.Text = title
        TBLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
        TBLbl.TextSize = 12
        TBLbl.TextColor3 = C.TXT3
        TBLbl.TextTransparency = 0.2
        TBLbl.BackgroundTransparency = 1
        TBLbl.Size = UDim2.new(0, fsz.X, 0, 16)
        TBLbl.AnchorPoint = Vector2.new(0, 0.5)
        TBLbl.Position = UDim2.new(0, 27, 0.5, 0)
        TBLbl.TextXAlignment = Enum.TextXAlignment.Left
        TBLbl.Parent = TabBtn

        tinert(self._tab_btns, TabBtn)

        -- Sections for this tab
        local LeftSec = Instance.new("ScrollingFrame")
        LeftSec.Name = "LeftSection"
        LeftSec.Size = UDim2.new(0, 374, 1, -12)
        LeftSec.Position = UDim2.new(0, 6, 0, 6)
        LeftSec.BackgroundTransparency = 1
        LeftSec.BorderSizePixel = 0
        LeftSec.ScrollBarThickness = 0
        LeftSec.ScrollBarImageTransparency = 1
        LeftSec.AutomaticCanvasSize = Enum.AutomaticSize.Y
        LeftSec.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        LeftSec.Selectable = false
        LeftSec.Visible = false
        LeftSec.Parent = Sections

        local LL = Instance.new("UIListLayout")
        LL.Padding = UDim.new(0, 8)
        LL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        LL.SortOrder = Enum.SortOrder.LayoutOrder
        LL.Parent = LeftSec
        Instance.new("UIPadding", LeftSec).PaddingTop = UDim.new(0, 2)

        local RightSec = Instance.new("ScrollingFrame")
        RightSec.Name = "RightSection"
        RightSec.Size = UDim2.new(0, 374, 1, -12)
        RightSec.Position = UDim2.new(0.5, 4, 0, 6)
        RightSec.BackgroundTransparency = 1
        RightSec.BorderSizePixel = 0
        RightSec.ScrollBarThickness = 0
        RightSec.ScrollBarImageTransparency = 1
        RightSec.AutomaticCanvasSize = Enum.AutomaticSize.Y
        RightSec.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        RightSec.Selectable = false
        RightSec.Visible = false
        RightSec.Parent = Sections

        local RL = Instance.new("UIListLayout")
        RL.Padding = UDim.new(0, 8)
        RL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        RL.SortOrder = Enum.SortOrder.LayoutOrder
        RL.Parent = RightSec
        Instance.new("UIPadding", RightSec).PaddingTop = UDim.new(0, 2)

        self._tab += 1

        if firstTab then
            self:update_tabs(TabBtn)
            self:update_sections(LeftSec, RightSec)
        end

        TabBtn.MouseButton1Click:Connect(function()
            self:update_tabs(TabBtn)
            self:update_sections(LeftSec, RightSec)
        end)

        TabBtn.MouseEnter:Connect(function()
            if TabBtn.BackgroundTransparency == 1 then
                tween(TabBtn, 0.2, {BackgroundTransparency = 0.9})
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if TabBtn.BackgroundTransparency ~= 0.75 then
                tween(TabBtn, 0.2, {BackgroundTransparency = 1})
            end
        end)

        -- ── Create Module ─────────────────────────────────
        function TabManager:create_module(settings)
            LayoutOrderModule = 0

            local ModuleManager = {_state=false, _size=0, _multiplier=0}

            if settings.section == "right" then
                settings.section = RightSec
            else
                settings.section = LeftSec
            end

            -- Module outer card
            local Module = Instance.new("Frame")
            Module.Name = "Module"
            Module.Size = UDim2.new(0, 358, 0, 80)
            Module.BackgroundColor3 = C.CARD
            Module.BackgroundTransparency = 0.08
            Module.BorderSizePixel = 0
            Module.ClipsDescendants = true
            Module.Parent = settings.section
            Instance.new("UICorner", Module).CornerRadius = UDim.new(0, 8)

            local ModStroke = Instance.new("UIStroke")
            ModStroke.Color = C.STROKE
            ModStroke.Transparency = 0.4
            ModStroke.Thickness = 1
            ModStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ModStroke.Parent = Module

            local ML = Instance.new("UIListLayout")
            ML.SortOrder = Enum.SortOrder.LayoutOrder
            ML.Parent = Module

            -- Left accent strip
            local Strip = Instance.new("Frame")
            Strip.Name = "Strip"
            Strip.Size = UDim2.new(0, 3, 0.55, 0)
            Strip.AnchorPoint = Vector2.new(0, 0.5)
            Strip.Position = UDim2.new(0, 0, 0.5, 0)
            Strip.BackgroundColor3 = C.ACCENT
            Strip.BorderSizePixel = 0
            Strip.ZIndex = 4
            Strip.Parent = Module
            Instance.new("UICorner", Strip).CornerRadius = UDim.new(1, 0)

            -- Subtle left glow
            local Glow = Instance.new("Frame")
            Glow.Size = UDim2.new(0, 60, 1, 0)
            Glow.BackgroundColor3 = C.ACCENT
            Glow.BackgroundTransparency = 0.92
            Glow.BorderSizePixel = 0
            Glow.ZIndex = 0
            Glow.Parent = Module
            Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 8)
            local GlowGrad = Instance.new("UIGradient")
            GlowGrad.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            }
            GlowGrad.Parent = Glow

            -- Header
            local Header = Instance.new("TextButton")
            Header.Name = "Header"
            Header.Size = UDim2.new(1, 0, 0, 80)
            Header.BackgroundTransparency = 1
            Header.Text = ""
            Header.AutoButtonColor = false
            Header.BorderSizePixel = 0
            Header.Parent = Module

            -- Module name
            local ModName = Instance.new("TextLabel")
            ModName.Name = "ModuleName"
            if not settings.rich then
                ModName.Text = settings.title or "Module"
            else
                ModName.RichText = true
                ModName.Text = settings.richtext or "Module"
            end
            ModName.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
            ModName.TextSize = 13
            ModName.TextColor3 = C.TXT
            ModName.TextTransparency = 0.05
            ModName.BackgroundTransparency = 1
            ModName.Size = UDim2.new(0, 250, 0, 16)
            ModName.AnchorPoint = Vector2.new(0, 0.5)
            ModName.Position = UDim2.new(0, 18, 0.28, 0)
            ModName.TextXAlignment = Enum.TextXAlignment.Left
            ModName.Parent = Header

            -- Description
            local Desc = Instance.new("TextLabel")
            Desc.Name = "Description"
            Desc.Text = settings.description or ""
            Desc.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
            Desc.TextSize = 10
            Desc.TextColor3 = C.TXT2
            Desc.TextTransparency = 0.1
            Desc.BackgroundTransparency = 1
            Desc.Size = UDim2.new(0, 240, 0, 12)
            Desc.AnchorPoint = Vector2.new(0, 0.5)
            Desc.Position = UDim2.new(0, 18, 0.52, 0)
            Desc.TextXAlignment = Enum.TextXAlignment.Left
            Desc.Parent = Header

            -- State toggle (glowing dot style)
            local DotBg = Instance.new("Frame")
            DotBg.Name = "DotBg"
            DotBg.Size = UDim2.new(0, 28, 0, 14)
            DotBg.AnchorPoint = Vector2.new(1, 0.5)
            DotBg.Position = UDim2.new(1, -12, 0.72, 0)
            DotBg.BackgroundColor3 = C.TOGGLE_OFF
            DotBg.BorderSizePixel = 0
            DotBg.Parent = Header
            Instance.new("UICorner", DotBg).CornerRadius = UDim.new(1, 0)

            local DotCircle = Instance.new("Frame")
            DotCircle.Name = "Circle"
            DotCircle.Size = UDim2.new(0, 10, 0, 10)
            DotCircle.AnchorPoint = Vector2.new(0, 0.5)
            DotCircle.Position = UDim2.new(0, 2, 0.5, 0)
            DotCircle.BackgroundColor3 = C.TXT3
            DotCircle.BorderSizePixel = 0
            DotCircle.Parent = DotBg
            Instance.new("UICorner", DotCircle).CornerRadius = UDim.new(1, 0)

            -- Keybind badge
            local KBadge = Instance.new("Frame")
            KBadge.Name = "Keybind"
            KBadge.Size = UDim2.new(0, 36, 0, 14)
            KBadge.AnchorPoint = Vector2.new(1, 0.5)
            KBadge.Position = UDim2.new(1, -46, 0.72, 0)
            KBadge.BackgroundColor3 = C.ELEM
            KBadge.BorderSizePixel = 0
            KBadge.BackgroundTransparency = 0.3
            KBadge.Parent = Header
            Instance.new("UICorner", KBadge).CornerRadius = UDim.new(0, 4)
            local KLbl = Instance.new("TextLabel")
            KLbl.Text = "None"
            KLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
            KLbl.TextSize = 9
            KLbl.TextColor3 = C.TXT2
            KLbl.BackgroundTransparency = 1
            KLbl.Size = UDim2.new(1, -4, 1, 0)
            KLbl.Position = UDim2.new(0, 2, 0, 0)
            KLbl.TextXAlignment = Enum.TextXAlignment.Center
            KLbl.Parent = KBadge

            -- Divider inside header
            local HDivider = Instance.new("Frame")
            HDivider.Size = UDim2.new(1, 0, 0, 1)
            HDivider.AnchorPoint = Vector2.new(0.5, 1)
            HDivider.Position = UDim2.new(0.5, 0, 1, 0)
            HDivider.BackgroundColor3 = C.STROKE
            HDivider.BackgroundTransparency = 0.4
            HDivider.BorderSizePixel = 0
            HDivider.Parent = Header
            local HDivGrad = Instance.new("UIGradient")
            HDivGrad.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.15, 0),
                NumberSequenceKeypoint.new(0.85, 0),
                NumberSequenceKeypoint.new(1, 1)
            }
            HDivGrad.Parent = HDivider

            -- Options container
            local Options = Instance.new("Frame")
            Options.Name = "Options"
            Options.Size = UDim2.new(1, 0, 0, 0)
            Options.BackgroundTransparency = 1
            Options.BorderSizePixel = 0
            Options.Parent = Module

            local OPad = Instance.new("UIPadding")
            OPad.PaddingTop = UDim.new(0, 8)
            OPad.Parent = Options

            local OL = Instance.new("UIListLayout")
            OL.Padding = UDim.new(0, 5)
            OL.HorizontalAlignment = Enum.HorizontalAlignment.Center
            OL.SortOrder = Enum.SortOrder.LayoutOrder
            OL.Parent = Options

            -- ── change_state ────────────────────────────────
            function ModuleManager:change_state(state)
                self._state = state
                if self._state then
                    tween(Module, 0.45, {Size = UDim2.fromOffset(358, 80 + self._size + self._multiplier)})
                    tween(DotBg, 0.4, {BackgroundColor3 = C.ACCENT})
                    tween(DotCircle, 0.4, {
                        BackgroundColor3 = Color3.new(1,1,1),
                        Position = UDim2.new(0, 16, 0.5, 0)
                    })
                    tween(Strip, 0.4, {BackgroundColor3 = C.ACCENT})
                else
                    tween(Module, 0.45, {Size = UDim2.fromOffset(358, 80)})
                    tween(DotBg, 0.4, {BackgroundColor3 = C.TOGGLE_OFF})
                    tween(DotCircle, 0.4, {
                        BackgroundColor3 = C.TXT3,
                        Position = UDim2.new(0, 2, 0.5, 0)
                    })
                    tween(Strip, 0.4, {BackgroundColor3 = C.ACCENT_DIM})
                end
                Library._config._flags[settings.flag] = self._state
                Config:save(game.GameId, Library._config)
                settings.callback(self._state)
            end

            function ModuleManager:connect_keybind()
                if not Library._config._keybinds[settings.flag] then return end
                Connections[settings.flag.."_kb"] = UIS.InputBegan:Connect(function(inp, proc)
                    if proc then return end
                    if tostring(inp.KeyCode) ~= Library._config._keybinds[settings.flag] then return end
                    self:change_state(not self._state)
                end)
            end

            function ModuleManager:scale_keybind(empty)
                if Library._config._keybinds[settings.flag] and not empty then
                    local ks = string.gsub(tostring(Library._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                    local fp2 = Instance.new("GetTextBoundsParams")
                    fp2.Text = ks
                    fp2.Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                    fp2.Size = 9; fp2.Width = 10000
                    local fs2 = TXT_SVC:GetTextBoundsAsync(fp2)
                    KBadge.Size = UDim2.fromOffset(fs2.X + 10, 14)
                else
                    KBadge.Size = UDim2.fromOffset(36, 14)
                end
            end

            if Library:flag_type(settings.flag, "boolean") then
                ModuleManager._state = true
                settings.callback(ModuleManager._state)
                DotBg.BackgroundColor3 = C.ACCENT
                DotCircle.BackgroundColor3 = Color3.new(1,1,1)
                DotCircle.Position = UDim2.new(0, 16, 0.5, 0)
                Strip.BackgroundColor3 = C.ACCENT
            end

            if Library._config._keybinds[settings.flag] then
                local ks = string.gsub(tostring(Library._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                KLbl.Text = ks
                ModuleManager:connect_keybind()
                ModuleManager:scale_keybind()
            end

            -- Middle-click to set keybind
            Connections[settings.flag.."_kbset"] = Header.InputBegan:Connect(function(inp)
                if Library._choosing_kb then return end
                if inp.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                Library._choosing_kb = true
                Connections["kb_choose"] = UIS.InputBegan:Connect(function(ki, kp)
                    if kp then return end
                    if ki.KeyCode == Enum.KeyCode.Unknown then return end
                    if ki.KeyCode == Enum.KeyCode.Backspace then
                        ModuleManager:scale_keybind(true)
                        Library._config._keybinds[settings.flag] = nil
                        Config:save(game.GameId, Library._config)
                        KLbl.Text = "None"
                        if Connections[settings.flag.."_kb"] then
                            Connections[settings.flag.."_kb"]:Disconnect()
                            Connections[settings.flag.."_kb"] = nil
                        end
                        Connections:disconnect("kb_choose")
                        Library._choosing_kb = false
                        return
                    end
                    Connections:disconnect("kb_choose")
                    Library._config._keybinds[settings.flag] = tostring(ki.KeyCode)
                    Config:save(game.GameId, Library._config)
                    if Connections[settings.flag.."_kb"] then
                        Connections[settings.flag.."_kb"]:Disconnect()
                        Connections[settings.flag.."_kb"] = nil
                    end
                    ModuleManager:connect_keybind()
                    ModuleManager:scale_keybind()
                    Library._choosing_kb = false
                    KLbl.Text = string.gsub(tostring(Library._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                end)
            end)

            Header.MouseButton1Click:Connect(function()
                ModuleManager:change_state(not ModuleManager._state)
            end)

            -- ── ELEMENTS ──────────────────────────────────

            -- Helper: ensure row sizing
            local function growModule(extra)
                LayoutOrderModule += 1
                if ModuleManager._size == 0 then ModuleManager._size = 8 end
                ModuleManager._size += extra
                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset(358, 80 + ModuleManager._size)
                end
                Options.Size = UDim2.fromOffset(358, ModuleManager._size)
                return LayoutOrderModule
            end

            -- ── Paragraph ────────────────────────────────
            function ModuleManager:create_paragraph(s)
                local order = growModule(s.customScale or 60)
                local P = Instance.new("Frame")
                P.Size = UDim2.new(0, 330, 0, 30)
                P.BackgroundColor3 = C.CARD2
                P.BackgroundTransparency = 0.15
                P.BorderSizePixel = 0
                P.AutomaticSize = Enum.AutomaticSize.Y
                P.LayoutOrder = order
                P.Parent = Options
                Instance.new("UICorner", P).CornerRadius = UDim.new(0, 6)

                local PT = Instance.new("TextLabel")
                PT.Text = s.title or "Title"
                PT.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
                PT.TextSize = 12; PT.TextColor3 = C.TXT
                PT.BackgroundTransparency = 1
                PT.Size = UDim2.new(1, -10, 0, 18)
                PT.Position = UDim2.new(0, 8, 0, 5)
                PT.TextXAlignment = Enum.TextXAlignment.Left
                PT.AutomaticSize = Enum.AutomaticSize.XY
                PT.Parent = P

                local PB = Instance.new("TextLabel")
                PB.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
                PB.TextSize = 10; PB.TextColor3 = C.TXT2
                PB.BackgroundTransparency = 1
                PB.Size = UDim2.new(1, -16, 0, 20)
                PB.Position = UDim2.new(0, 8, 0, 24)
                PB.TextXAlignment = Enum.TextXAlignment.Left
                PB.TextYAlignment = Enum.TextYAlignment.Top
                PB.TextWrapped = true
                PB.AutomaticSize = Enum.AutomaticSize.XY
                if not s.rich then PB.Text = s.text or ""
                else PB.RichText = true; PB.Text = s.richtext or "" end
                PB.Parent = P

                P.MouseEnter:Connect(function() tween(P, 0.25, {BackgroundColor3 = C.HOVER}) end)
                P.MouseLeave:Connect(function() tween(P, 0.25, {BackgroundColor3 = C.CARD2}) end)
                return {}
            end

            -- ── Button ───────────────────────────────────
            function ModuleManager:create_button(s)
                local order = growModule(28)
                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(0, 330, 0, 22)
                Row.BackgroundTransparency = 1
                Row.LayoutOrder = order
                Row.Parent = Options

                local BLbl = Instance.new("TextLabel")
                BLbl.Text = s.title or "Button"
                BLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                BLbl.TextSize = 11; BLbl.TextColor3 = C.TXT
                BLbl.BackgroundTransparency = 1
                BLbl.Size = UDim2.new(1, -36, 1, 0)
                BLbl.TextXAlignment = Enum.TextXAlignment.Left
                BLbl.Parent = Row

                local BBtn = Instance.new("TextButton")
                BBtn.Size = UDim2.new(0, 26, 0, 22)
                BBtn.AnchorPoint = Vector2.new(1, 0.5)
                BBtn.Position = UDim2.new(1, 0, 0.5, 0)
                BBtn.BackgroundColor3 = C.ACCENT
                BBtn.BackgroundTransparency = 0.6
                BBtn.BorderSizePixel = 0
                BBtn.Text = ""
                BBtn.AutoButtonColor = false
                BBtn.Parent = Row
                Instance.new("UICorner", BBtn).CornerRadius = UDim.new(0, 6)

                local BIc = Instance.new("ImageLabel")
                BIc.Image = "rbxassetid://139650104834071"
                BIc.Size = UDim2.new(0.65, 0, 0.65, 0)
                BIc.AnchorPoint = Vector2.new(0.5, 0.5)
                BIc.Position = UDim2.new(0.5, 0, 0.5, 0)
                BIc.BackgroundTransparency = 1
                BIc.Parent = BBtn

                task.spawn(function()
                    while BIc and BIc.Parent do
                        tween(BIc, 1.5, {Rotation = BIc.Rotation + 360}, Enum.EasingStyle.Linear)
                        task.wait(1.5)
                    end
                end)

                BBtn.MouseEnter:Connect(function() tween(BBtn, 0.2, {BackgroundTransparency = 0.2}) end)
                BBtn.MouseLeave:Connect(function() tween(BBtn, 0.2, {BackgroundTransparency = 0.6}) end)
                BBtn.MouseButton1Click:Connect(function() if s.callback then s.callback() end end)
                return Row
            end

            -- ── Text display ─────────────────────────────
            function ModuleManager:create_text(s)
                local order = growModule(s.customScale or 42)
                local TF = Instance.new("Frame")
                TF.Size = UDim2.new(0, 330, 0, s.CustomYSize or 34)
                TF.BackgroundColor3 = C.CARD2
                TF.BackgroundTransparency = 0.2
                TF.BorderSizePixel = 0
                TF.AutomaticSize = Enum.AutomaticSize.Y
                TF.LayoutOrder = order; TF.Parent = Options
                Instance.new("UICorner", TF).CornerRadius = UDim.new(0, 6)

                local TB = Instance.new("TextLabel")
                TB.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
                TB.TextSize = 10; TB.TextColor3 = C.TXT2
                TB.BackgroundTransparency = 1
                TB.Size = UDim2.new(1, -12, 1, 0)
                TB.Position = UDim2.new(0, 6, 0, 5)
                TB.TextXAlignment = Enum.TextXAlignment.Left
                TB.TextYAlignment = Enum.TextYAlignment.Top
                TB.TextWrapped = true; TB.AutomaticSize = Enum.AutomaticSize.XY
                if not s.rich then TB.Text = s.text or ""
                else TB.RichText = true; TB.Text = s.richtext or "" end
                TB.Parent = TF

                TF.MouseEnter:Connect(function() tween(TF, 0.2, {BackgroundColor3 = C.HOVER}) end)
                TF.MouseLeave:Connect(function() tween(TF, 0.2, {BackgroundColor3 = C.CARD2}) end)

                local Mgr = {}
                function Mgr:Set(ns)
                    if not ns.rich then TB.Text = ns.text or ""
                    else TB.RichText = true; TB.Text = ns.richtext or "" end
                end
                return Mgr
            end

            -- ── Textbox ──────────────────────────────────
            function ModuleManager:create_textbox(s)
                local order = growModule(34)
                local TM = {_text = ""}

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = s.title or "Input"
                Lbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                Lbl.TextSize = 10; Lbl.TextColor3 = C.TXT
                Lbl.TextTransparency = 0.1
                Lbl.BackgroundTransparency = 1
                Lbl.Size = UDim2.new(0, 330, 0, 12)
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.LayoutOrder = order
                Lbl.Parent = Options

                local TB = Instance.new("TextBox")
                TB.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
                TB.TextSize = 10; TB.TextColor3 = C.TXT
                TB.PlaceholderText = s.placeholder or "Type here..."
                TB.Text = Library._config._flags[s.flag] or ""
                TB.BackgroundColor3 = C.ELEM
                TB.BackgroundTransparency = 0.2
                TB.BorderSizePixel = 0
                TB.ClearTextOnFocus = false
                TB.Size = UDim2.new(0, 330, 0, 18)
                TB.LayoutOrder = order
                TB.Parent = Options
                Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 5)
                local TBStroke = Instance.new("UIStroke")
                TBStroke.Color = C.STROKE; TBStroke.Thickness = 1
                TBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                TBStroke.Parent = TB

                TB.Focused:Connect(function() tween(TBStroke, 0.2, {Color = C.ACCENT}) end)
                TB.FocusLost:Connect(function()
                    tween(TBStroke, 0.2, {Color = C.STROKE})
                    TM._text = TB.Text
                    Library._config._flags[s.flag] = TM._text
                    Config:save(game.GameId, Library._config)
                    s.callback(TM._text)
                end)

                if Library:flag_type(s.flag, "string") then
                    TM._text = Library._config._flags[s.flag]
                    s.callback(TM._text)
                end
                return TM
            end

            -- ── Checkbox ─────────────────────────────────
            function ModuleManager:create_checkbox(s)
                local order = growModule(22)
                local CM = {_state = false}

                local Row = Instance.new("TextButton")
                Row.Size = UDim2.new(0, 330, 0, 18)
                Row.BackgroundTransparency = 1
                Row.Text = ""; Row.AutoButtonColor = false
                Row.LayoutOrder = order; Row.Parent = Options

                local CTit = Instance.new("TextLabel")
                CTit.Text = s.title or "Toggle"
                CTit.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                CTit.TextSize = 11; CTit.TextColor3 = C.TXT
                CTit.TextTransparency = 0.05
                CTit.BackgroundTransparency = 1
                CTit.Size = UDim2.new(1, -60, 1, 0)
                CTit.TextXAlignment = Enum.TextXAlignment.Left
                CTit.Parent = Row

                -- Keybind chip
                local CKB = Instance.new("Frame")
                CKB.Size = UDim2.new(0, 30, 0, 14)
                CKB.AnchorPoint = Vector2.new(1, 0.5)
                CKB.Position = UDim2.new(1, -22, 0.5, 0)
                CKB.BackgroundColor3 = C.ELEM
                CKB.BackgroundTransparency = 0.3
                CKB.BorderSizePixel = 0; CKB.Parent = Row
                Instance.new("UICorner", CKB).CornerRadius = UDim.new(0, 4)

                local CKBLbl = Instance.new("TextLabel")
                CKBLbl.Size = UDim2.new(1, 0, 1, 0)
                CKBLbl.BackgroundTransparency = 1
                CKBLbl.TextColor3 = C.TXT2; CKBLbl.TextSize = 9
                CKBLbl.Font = Enum.Font.SourceSans
                CKBLbl.Text = Library._config._keybinds[s.flag] and
                    string.gsub(tostring(Library._config._keybinds[s.flag]),"Enum.KeyCode.","") or "..."
                CKBLbl.Parent = CKB

                -- Square checkbox
                local CBox = Instance.new("Frame")
                CBox.Size = UDim2.new(0, 16, 0, 16)
                CBox.AnchorPoint = Vector2.new(1, 0.5)
                CBox.Position = UDim2.new(1, 0, 0.5, 0)
                CBox.BackgroundColor3 = C.ELEM
                CBox.BackgroundTransparency = 0.1
                CBox.BorderSizePixel = 0; CBox.Parent = Row
                Instance.new("UICorner", CBox).CornerRadius = UDim.new(0, 4)
                local CBoxStroke = Instance.new("UIStroke")
                CBoxStroke.Color = C.STROKE2; CBoxStroke.Thickness = 1.2
                CBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                CBoxStroke.Parent = CBox

                local CFill = Instance.new("Frame")
                CFill.Size = UDim2.new(0, 0, 0, 0)
                CFill.AnchorPoint = Vector2.new(0.5, 0.5)
                CFill.Position = UDim2.new(0.5, 0, 0.5, 0)
                CFill.BackgroundColor3 = C.ACCENT
                CFill.BorderSizePixel = 0; CFill.Parent = CBox
                Instance.new("UICorner", CFill).CornerRadius = UDim.new(0, 3)

                function CM:change_state(state)
                    self._state = state
                    if self._state then
                        tween(CBoxStroke, 0.3, {Color = C.ACCENT})
                        tween(CFill, 0.3, {Size = UDim2.fromOffset(10, 10), BackgroundColor3 = C.ACCENT})
                    else
                        tween(CBoxStroke, 0.3, {Color = C.STROKE2})
                        tween(CFill, 0.3, {Size = UDim2.fromOffset(0, 0)})
                    end
                    Library._config._flags[s.flag] = self._state
                    Config:save(game.GameId, Library._config)
                    s.callback(self._state)
                end

                if Library:flag_type(s.flag, "boolean") then
                    CM:change_state(Library._config._flags[s.flag])
                end

                Row.MouseButton1Click:Connect(function() CM:change_state(not CM._state) end)

                Row.InputBegan:Connect(function(inp, gp)
                    if gp or inp.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
                    if Library._choosing_kb then return end
                    Library._choosing_kb = true
                    local conn
                    conn = UIS.InputBegan:Connect(function(ki, kp)
                        if kp then return end
                        if ki.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if ki.KeyCode == Enum.KeyCode.Unknown then return end
                        if ki.KeyCode == Enum.KeyCode.Backspace then
                            Library._config._keybinds[s.flag] = nil
                            Config:save(game.GameId, Library._config)
                            CKBLbl.Text = "..."
                            conn:Disconnect(); Library._choosing_kb = false; return
                        end
                        conn:Disconnect()
                        Library._config._keybinds[s.flag] = tostring(ki.KeyCode)
                        Config:save(game.GameId, Library._config)
                        CKBLbl.Text = string.gsub(tostring(Library._config._keybinds[s.flag]),"Enum.KeyCode.","")
                        Library._choosing_kb = false
                    end)
                end)

                Connections[s.flag.."_ckbp"] = UIS.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    local stored = Library._config._keybinds[s.flag]
                    if stored and tostring(inp.KeyCode) == stored then CM:change_state(not CM._state) end
                end)

                return CM
            end

            -- ── Divider ──────────────────────────────────
            function ModuleManager:create_divider(s)
                local order = growModule(22)
                local Outer = Instance.new("Frame")
                Outer.Size = UDim2.new(0, 330, 0, 16)
                Outer.BackgroundTransparency = 1
                Outer.LayoutOrder = order; Outer.Parent = Options

                if s and s.showtopic then
                    local DTxt = Instance.new("TextLabel")
                    DTxt.Text = s.title or ""
                    DTxt.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                    DTxt.TextSize = 10; DTxt.TextColor3 = C.ACCENT
                    DTxt.BackgroundColor3 = C.BG
                    DTxt.BackgroundTransparency = 0
                    DTxt.Size = UDim2.new(0, 80, 0, 12)
                    DTxt.AnchorPoint = Vector2.new(0.5, 0.5)
                    DTxt.Position = UDim2.new(0.5, 0, 0.5, 0)
                    DTxt.TextXAlignment = Enum.TextXAlignment.Center
                    DTxt.ZIndex = 3
                    DTxt.Parent = Outer
                end

                if not s or not s.disableline then
                    local DLine = Instance.new("Frame")
                    DLine.Size = UDim2.new(1, 0, 0, 1)
                    DLine.AnchorPoint = Vector2.new(0.5, 0.5)
                    DLine.Position = UDim2.new(0.5, 0, 0.5, 0)
                    DLine.BackgroundColor3 = C.ACCENT
                    DLine.BackgroundTransparency = 0.3
                    DLine.BorderSizePixel = 0
                    DLine.ZIndex = 2; DLine.Parent = Outer
                    Instance.new("UICorner", DLine).CornerRadius = UDim.new(1, 0)
                    local DG = Instance.new("UIGradient")
                    DG.Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.15, 0),
                        NumberSequenceKeypoint.new(0.85, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }
                    DG.Parent = DLine
                end
                return true
            end

            -- ── Slider ───────────────────────────────────
            function ModuleManager:create_slider(s)
                local order = growModule(30)
                local SM = {}

                local Slider = Instance.new("TextButton")
                Slider.Text = ""; Slider.AutoButtonColor = false
                Slider.BackgroundTransparency = 1
                Slider.Size = UDim2.new(0, 330, 0, 24)
                Slider.LayoutOrder = order; Slider.Parent = Options

                local SLbl = Instance.new("TextLabel")
                if GG.SelectedLanguage == "th" then
                    SLbl.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold)
                    SLbl.TextSize = 12
                else
                    SLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                    SLbl.TextSize = 11
                end
                SLbl.Text = s.title; SLbl.TextColor3 = C.TXT
                SLbl.TextTransparency = 0.1
                SLbl.BackgroundTransparency = 1
                SLbl.Size = UDim2.new(0, 240, 0, 14)
                SLbl.Position = UDim2.new(0, 0, 0, 0)
                SLbl.TextXAlignment = Enum.TextXAlignment.Left
                SLbl.Parent = Slider

                local SVLbl = Instance.new("TextLabel")
                SVLbl.Name = "Value"; SVLbl.Text = "0"
                SVLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
                SVLbl.TextSize = 10; SVLbl.TextColor3 = C.ACCENT
                SVLbl.BackgroundTransparency = 1
                SVLbl.Size = UDim2.new(0, 60, 0, 14)
                SVLbl.AnchorPoint = Vector2.new(1, 0)
                SVLbl.Position = UDim2.new(1, 0, 0, 0)
                SVLbl.TextXAlignment = Enum.TextXAlignment.Right
                SVLbl.Parent = Slider

                local Track = Instance.new("Frame")
                Track.Name = "Drag"
                Track.Size = UDim2.new(1, 0, 0, 4)
                Track.AnchorPoint = Vector2.new(0.5, 1)
                Track.Position = UDim2.new(0.5, 0, 1, 0)
                Track.BackgroundColor3 = C.ELEM
                Track.BorderSizePixel = 0; Track.Parent = Slider
                Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

                local Fill = Instance.new("Frame")
                Fill.Name = "Fill"
                Fill.Size = UDim2.new(0.5, 0, 1, 0)
                Fill.BackgroundColor3 = C.ACCENT
                Fill.BorderSizePixel = 0; Fill.Parent = Track
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
                local FG = Instance.new("UIGradient")
                FG.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, C.ACCENT2),
                    ColorSequenceKeypoint.new(1, C.ACCENT)
                }
                FG.Parent = Fill

                local Knob = Instance.new("Frame")
                Knob.Name = "Circle"
                Knob.Size = UDim2.new(0, 10, 0, 10)
                Knob.AnchorPoint = Vector2.new(1, 0.5)
                Knob.Position = UDim2.new(1, 0, 0.5, 0)
                Knob.BackgroundColor3 = Color3.new(1, 1, 1)
                Knob.BorderSizePixel = 0; Knob.Parent = Fill
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                function SM:set_percentage(pct)
                    if type(pct) ~= "number" then return end
                    local rounded = s.round_number and math.floor(pct) or (math.floor(pct * 10) / 10)
                    local norm = (pct - s.minimum_value) / (s.maximum_value - s.minimum_value)
                    local sz = math.clamp(norm, 0.02, 1) * Track.Size.X.Offset
                    local clamped = math.clamp(rounded, s.minimum_value, s.maximum_value)
                    Library._config._flags[s.flag] = clamped
                    SVLbl.Text = tostring(clamped)
                    tween(Fill, 0.4, {Size = UDim2.fromOffset(sz, Track.Size.Y.Offset)})
                    if s.callback then s.callback(clamped) end
                end

                function SM:update()
                    local mp = (mouse.X - Track.AbsolutePosition.X) / Track.Size.X.Offset
                    self:set_percentage(s.minimum_value + (s.maximum_value - s.minimum_value) * mp)
                end

                function SM:input()
                    self:update()
                    Connections["sl_drag_"..s.flag] = mouse.Move:Connect(function() self:update() end)
                    Connections["sl_end_"..s.flag] = UIS.InputEnded:Connect(function(inp)
                        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
                        Connections:disconnect("sl_drag_"..s.flag)
                        Connections:disconnect("sl_end_"..s.flag)
                        if not s.ignoresaved then Config:save(game.GameId, Library._config) end
                    end)
                end

                if Library:flag_type(s.flag, "number") and not s.ignoresaved then
                    SM:set_percentage(Library._config._flags[s.flag])
                else
                    SM:set_percentage(s.value)
                end

                Slider.MouseButton1Down:Connect(function() SM:input() end)
                return SM
            end

            -- ── Dropdown ─────────────────────────────────
            function ModuleManager:create_dropdown(s)
                if not s.Order then LayoutOrderModule += 1 end
                local DM = {_state = false, _size = 0}

                if not s.Order then
                    if ModuleManager._size == 0 then ModuleManager._size = 8 end
                    ModuleManager._size += 48
                    if ModuleManager._state then
                        Module.Size = UDim2.fromOffset(358, 80 + ModuleManager._size)
                    end
                    Options.Size = UDim2.fromOffset(358, ModuleManager._size)
                end

                if not Library._config._flags[s.flag] then Library._config._flags[s.flag] = {} end

                local DDWrap = Instance.new("Frame")
                DDWrap.BackgroundTransparency = 1
                DDWrap.Size = UDim2.new(0, 330, 0, 44)
                DDWrap.Name = "Dropdown"
                if not s.Order then DDWrap.LayoutOrder = LayoutOrderModule
                else DDWrap.LayoutOrder = s.OrderValue end
                DDWrap.Parent = Options

                local DDLbl = Instance.new("TextLabel")
                DDLbl.Text = s.title
                if GG.SelectedLanguage == "th" then
                    DDLbl.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold)
                    DDLbl.TextSize = 12
                else
                    DDLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                    DDLbl.TextSize = 11
                end
                DDLbl.TextColor3 = C.TXT; DDLbl.BackgroundTransparency = 1
                DDLbl.Size = UDim2.new(1, 0, 0, 14)
                DDLbl.TextXAlignment = Enum.TextXAlignment.Left
                DDLbl.Parent = DDWrap

                local DDBox = Instance.new("Frame")
                DDBox.ClipsDescendants = true
                DDBox.Size = UDim2.new(1, 0, 0, 26)
                DDBox.Position = UDim2.new(0, 0, 0, 16)
                DDBox.BackgroundColor3 = C.ELEM
                DDBox.BackgroundTransparency = 0.2
                DDBox.BorderSizePixel = 0
                DDBox.Name = "Box"; DDBox.Parent = DDWrap
                Instance.new("UICorner", DDBox).CornerRadius = UDim.new(0, 6)
                local DDStroke = Instance.new("UIStroke")
                DDStroke.Color = C.STROKE; DDStroke.Thickness = 1
                DDStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                DDStroke.Parent = DDBox

                local DDBoxInner = Instance.new("Frame")
                DDBoxInner.Name = "Header"
                DDBoxInner.Size = UDim2.new(1, 0, 0, 26)
                DDBoxInner.BackgroundTransparency = 1
                DDBoxInner.Parent = DDBox

                local DDCurrent = Instance.new("TextLabel")
                DDCurrent.Name = "CurrentOption"
                DDCurrent.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                DDCurrent.TextSize = 10; DDCurrent.TextColor3 = C.TXT
                DDCurrent.BackgroundTransparency = 1
                DDCurrent.Size = UDim2.new(1, -28, 1, 0)
                DDCurrent.Position = UDim2.new(0, 10, 0, 0)
                DDCurrent.TextXAlignment = Enum.TextXAlignment.Left
                DDCurrent.Parent = DDBoxInner
                local DDGrad = Instance.new("UIGradient")
                DDGrad.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0,0),
                    NumberSequenceKeypoint.new(0.75,0),
                    NumberSequenceKeypoint.new(0.95,0.7),
                    NumberSequenceKeypoint.new(1,1)
                }
                DDGrad.Parent = DDCurrent

                local DDArrow = Instance.new("ImageLabel")
                DDArrow.Name = "Arrow"
                DDArrow.Image = "rbxassetid://84232453189324"
                DDArrow.Size = UDim2.new(0, 8, 0, 8)
                DDArrow.AnchorPoint = Vector2.new(1, 0.5)
                DDArrow.Position = UDim2.new(1, -8, 0.5, 0)
                DDArrow.BackgroundTransparency = 1
                DDArrow.ImageColor3 = C.TXT2
                DDArrow.Parent = DDBoxInner

                local DDOpts = Instance.new("ScrollingFrame")
                DDOpts.Name = "Options"
                DDOpts.Size = UDim2.new(1, 0, 0, 0)
                DDOpts.Position = UDim2.new(0, 0, 1, 0)
                DDOpts.BackgroundTransparency = 1
                DDOpts.ScrollBarThickness = 0
                DDOpts.ScrollBarImageTransparency = 1
                DDOpts.AutomaticCanvasSize = Enum.AutomaticSize.XY
                DDOpts.CanvasSize = UDim2.new(0, 0, 0.5, 0)
                DDOpts.Parent = DDBox

                local DDOptsL = Instance.new("UIListLayout")
                DDOptsL.SortOrder = Enum.SortOrder.LayoutOrder
                DDOptsL.Parent = DDOpts
                Instance.new("UIPadding", DDOpts).PaddingLeft = UDim.new(0, 10)

                Instance.new("UIListLayout", DDBox).SortOrder = Enum.SortOrder.LayoutOrder

                local DDBtn = Instance.new("TextButton")
                DDBtn.Size = UDim2.new(1, 0, 1, 0)
                DDBtn.BackgroundTransparency = 1; DDBtn.Text = ""
                DDBtn.Parent = DDBoxInner

                function DM:update(opt)
                    if s.multi_dropdown then
                        if not Library._config._flags[s.flag] then Library._config._flags[s.flag] = {} end
                        local selected = {}
                        local curStr = convertTableToString(Library._config._flags[s.flag])
                        for v in string.gmatch(curStr, "([^,]+)") do
                            local t2 = v:match("^%s*(.-)%s*$")
                            if t2 ~= "Label" then tinert(selected, t2) end
                        end
                        local optName = type(opt) == "string" and opt or opt.Name
                        local fi = nil
                        for i,v in ipairs(selected) do if v == optName then fi=i break end end
                        if fi then table.remove(selected, fi) else tinert(selected, optName) end
                        DDCurrent.Text = table.concat(selected, ", ")
                        for _,o in DDOpts:GetChildren() do
                            if o.Name == "Option" then
                                o.TextTransparency = table.find(selected, o.Text) and 0 or 0.55
                            end
                        end
                        Library._config._flags[s.flag] = convertStringToTable(DDCurrent.Text)
                    else
                        DDCurrent.Text = (type(opt) == "string" and opt) or opt.Name
                        for _,o in DDOpts:GetChildren() do
                            if o.Name == "Option" then
                                o.TextTransparency = o.Text == DDCurrent.Text and 0 or 0.55
                            end
                        end
                        Library._config._flags[s.flag] = opt
                    end
                    Config:save(game.GameId, Library._config)
                    s.callback(opt)
                end

                local curDDS = 0

                function DM:unfold_settings()
                    self._state = not self._state
                    if self._state then
                        ModuleManager._multiplier += self._size; curDDS = self._size
                        tween(Module, 0.4, {Size = UDim2.fromOffset(358, 80 + ModuleManager._size + ModuleManager._multiplier)})
                        tween(Module.Options, 0.4, {Size = UDim2.fromOffset(358, ModuleManager._size + ModuleManager._multiplier)})
                        tween(DDWrap, 0.4, {Size = UDim2.fromOffset(330, 44 + self._size)})
                        tween(DDBox, 0.4, {Size = UDim2.fromOffset(330, 26 + self._size)})
                        tween(DDArrow, 0.4, {Rotation = 180})
                        tween(DDStroke, 0.3, {Color = C.ACCENT})
                    else
                        ModuleManager._multiplier -= self._size; curDDS = 0
                        tween(Module, 0.4, {Size = UDim2.fromOffset(358, 80 + ModuleManager._size + ModuleManager._multiplier)})
                        tween(Module.Options, 0.4, {Size = UDim2.fromOffset(358, ModuleManager._size + ModuleManager._multiplier)})
                        tween(DDWrap, 0.4, {Size = UDim2.fromOffset(330, 44)})
                        tween(DDBox, 0.4, {Size = UDim2.fromOffset(330, 26)})
                        tween(DDArrow, 0.4, {Rotation = 0})
                        tween(DDStroke, 0.3, {Color = C.STROKE})
                    end
                end

                if #s.options > 0 then
                    DM._size = 4
                    local maxOpts = s.maximum_options or #s.options
                    for idx, val in s.options do
                        local Opt = Instance.new("TextButton")
                        Opt.Name = "Option"
                        Opt.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                        Opt.TextSize = 10; Opt.TextColor3 = C.TXT
                        Opt.TextTransparency = 0.55
                        Opt.Text = (type(val) == "string" and val) or val.Name
                        Opt.BackgroundTransparency = 1
                        Opt.Size = UDim2.new(0, 300, 0, 16)
                        Opt.TextXAlignment = Enum.TextXAlignment.Left
                        Opt.AutoButtonColor = false; Opt.Active = false; Opt.Selectable = false
                        Opt.Parent = DDOpts
                        local OG = Instance.new("UIGradient")
                        OG.Transparency = NumberSequence.new{
                            NumberSequenceKeypoint.new(0,0),
                            NumberSequenceKeypoint.new(0.8,0),
                            NumberSequenceKeypoint.new(1,1)
                        }
                        OG.Parent = Opt

                        Opt.MouseEnter:Connect(function() tween(Opt, 0.15, {TextTransparency = 0}) end)
                        Opt.MouseLeave:Connect(function()
                            local sel = s.multi_dropdown and table.find(Library._config._flags[s.flag] or {}, val)
                                        or (DDCurrent.Text == Opt.Text)
                            tween(Opt, 0.15, {TextTransparency = sel and 0 or 0.55})
                        end)

                        Opt.MouseButton1Click:Connect(function()
                            if not Library._config._flags[s.flag] then Library._config._flags[s.flag] = {} end
                            if s.multi_dropdown then
                                if table.find(Library._config._flags[s.flag], val) then
                                    Library:remove_table_value(Library._config._flags[s.flag], val)
                                else
                                    tinert(Library._config._flags[s.flag], val)
                                end
                            end
                            DM:update(val)
                        end)

                        if idx <= maxOpts then DM._size += 16 end
                        DDOpts.Size = UDim2.fromOffset(310, DM._size)
                    end
                end

                function DM:New(v)
                    DDWrap:Destroy()
                    v.OrderValue = DDWrap.LayoutOrder
                    ModuleManager._multiplier -= curDDS
                    return ModuleManager:create_dropdown(v)
                end

                if Library:flag_type(s.flag, "string") then DM:update(Library._config._flags[s.flag])
                else DM:update(s.options[1]) end

                DDBtn.MouseButton1Click:Connect(function() DM:unfold_settings() end)
                return DM
            end

            -- ── Display ──────────────────────────────────
            function ModuleManager:create_display(s)
                local order = growModule(s.height or 110)
                local DF = Instance.new("Frame")
                DF.Size = UDim2.new(0, 330, 0, s.height or 110)
                DF.BackgroundColor3 = C.CARD2
                DF.BackgroundTransparency = 0.1
                DF.BorderSizePixel = 0
                DF.LayoutOrder = order; DF.Parent = Options
                Instance.new("UICorner", DF).CornerRadius = UDim.new(0, 8)

                local DFImg = Instance.new("ImageLabel")
                DFImg.Size = UDim2.new(1, -10, 1, -22)
                DFImg.Position = UDim2.new(0.5, 0, 0, 4)
                DFImg.AnchorPoint = Vector2.new(0.5, 0)
                DFImg.BackgroundTransparency = 1
                DFImg.Image = s.image or "rbxassetid://11835491319"
                DFImg.ScaleType = Enum.ScaleType.Fit
                DFImg.Parent = DF

                local DFLbl = Instance.new("TextLabel")
                DFLbl.Text = s.text or ""
                DFLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                DFLbl.TextSize = 11; DFLbl.TextColor3 = C.TXT
                DFLbl.BackgroundTransparency = 1
                DFLbl.Size = UDim2.new(1, -10, 0, 16)
                DFLbl.AnchorPoint = Vector2.new(0.5, 1)
                DFLbl.Position = UDim2.new(0.5, 0, 1, -2)
                DFLbl.Parent = DF

                if s.glow then
                    local US = Instance.new("UIStroke", DFLbl)
                    US.Thickness = 1.5; US.Color = C.ACCENT; US.Transparency = 0.3
                end
                return DF
            end

            -- ── Color Picker ─────────────────────────────
            function ModuleManager:create_colorpicker(s)
                local order = growModule(30)
                local CPM = {}

                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(0, 330, 0, 24)
                Row.BackgroundTransparency = 1
                Row.LayoutOrder = order; Row.Parent = Options

                local CPLbl = Instance.new("TextLabel")
                CPLbl.Text = s.title or "Color"
                CPLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                CPLbl.TextSize = 11; CPLbl.TextColor3 = C.TXT
                CPLbl.BackgroundTransparency = 1
                CPLbl.Size = UDim2.new(1, -32, 1, 0)
                CPLbl.TextXAlignment = Enum.TextXAlignment.Left
                CPLbl.Parent = Row

                local Preview = Instance.new("TextButton")
                Preview.Size = UDim2.new(0, 26, 0, 22)
                Preview.AnchorPoint = Vector2.new(1, 0.5)
                Preview.Position = UDim2.new(1, 0, 0.5, 0)
                Preview.BackgroundColor3 = s.default or Color3.new(1,1,1)
                Preview.Text = ""; Preview.Parent = Row
                Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 6)

                local NovaGui = COREGUI:FindFirstChild("Nova")
                local Popup = Instance.new("Frame")
                Popup.Size = UDim2.new(0, 320, 0, 290)
                Popup.AnchorPoint = Vector2.new(0.5, 0.5)
                Popup.Position = UDim2.new(0.5, 0, 0.5, 0)
                Popup.BackgroundColor3 = C.CARD
                Popup.Visible = false; Popup.ZIndex = 9999
                Popup.Parent = NovaGui
                Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 12)
                Instance.new("UIStroke", Popup).Color = C.STROKE2

                local PTit = Instance.new("TextLabel")
                PTit.Text = "Pick Color"
                PTit.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
                PTit.TextSize = 13; PTit.TextColor3 = C.TXT
                PTit.BackgroundTransparency = 1
                PTit.Size = UDim2.new(1, 0, 0, 28); PTit.ZIndex = 10000; PTit.Parent = Popup

                local HSB = Instance.new("Frame")
                HSB.Size = UDim2.new(0, 195, 0, 195)
                HSB.Position = UDim2.new(0, 14, 0, 34)
                HSB.BackgroundColor3 = Color3.fromHSV(0,1,1)
                HSB.BorderSizePixel = 0; HSB.ZIndex = 10000; HSB.Parent = Popup
                Instance.new("UICorner", HSB).CornerRadius = UDim.new(0, 6)
                local OvIm = Instance.new("ImageLabel")
                OvIm.Size = UDim2.new(1,0,1,0); OvIm.BackgroundTransparency = 1
                OvIm.Image = "rbxassetid://4155801252"; OvIm.ZIndex = 10001; OvIm.Parent = HSB

                local Sel = Instance.new("Frame")
                Sel.Size = UDim2.new(0,12,0,12); Sel.AnchorPoint = Vector2.new(0.5,0.5)
                Sel.BackgroundColor3 = Color3.new(1,1,1); Sel.BorderSizePixel = 0
                Sel.ZIndex = 10002; Sel.Parent = HSB
                Instance.new("UICorner", Sel).CornerRadius = UDim.new(1,0)

                local HBar = Instance.new("Frame")
                HBar.Size = UDim2.new(0,18,0,195)
                HBar.Position = UDim2.new(0,220,0,34)
                HBar.BorderSizePixel = 0; HBar.ZIndex = 10000; HBar.Parent = Popup
                local HG = Instance.new("UIGradient"); HG.Rotation = 90
                local ks2 = {}
                for i=0,1,0.1 do tinert(ks2, ColorSequenceKeypoint.new(i, Color3.fromHSV(i,1,1))) end
                HG.Color = ColorSequence.new(ks2); HG.Parent = HBar
                Instance.new("UICorner", HBar).CornerRadius = UDim.new(0, 4)

                local HMark = Instance.new("Frame")
                HMark.Size = UDim2.new(1,0,0,2); HMark.BackgroundColor3 = Color3.new(1,1,1)
                HMark.BorderSizePixel = 0; HMark.ZIndex = 10001; HMark.Parent = HBar

                local ABar = Instance.new("Frame")
                ABar.Size = UDim2.new(0,195,0,12)
                ABar.Position = UDim2.new(0,14,0,238)
                ABar.BorderSizePixel = 0; ABar.ZIndex = 10000; ABar.Parent = Popup
                local AG = Instance.new("UIGradient")
                AG.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}
                AG.Color = ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1))
                AG.Parent = ABar
                Instance.new("UICorner", ABar).CornerRadius = UDim.new(1, 0)

                local AMark = Instance.new("Frame")
                AMark.Size = UDim2.new(0,2,1,0); AMark.BackgroundColor3 = Color3.new(1,1,1)
                AMark.BorderSizePixel = 0; AMark.ZIndex = 10001; AMark.Parent = ABar

                local HexLbl = Instance.new("TextLabel")
                HexLbl.Size = UDim2.new(0,100,0,20); HexLbl.Position = UDim2.new(0,14,1,-26)
                HexLbl.BackgroundTransparency = 1; HexLbl.TextColor3 = C.ACCENT
                HexLbl.Font = Enum.Font.Code; HexLbl.TextSize = 12; HexLbl.Text = "#FFFFFF"
                HexLbl.TextXAlignment = Enum.TextXAlignment.Left; HexLbl.ZIndex = 10002; HexLbl.Parent = Popup

                local CloseBtn = Instance.new("ImageButton")
                CloseBtn.Image = "rbxassetid://10030850935"; CloseBtn.Size = UDim2.new(0,18,0,18)
                CloseBtn.Position = UDim2.new(1,-26,0,5); CloseBtn.BackgroundTransparency = 1
                CloseBtn.ZIndex = 10001; CloseBtn.Parent = Popup
                local YesBtn = Instance.new("ImageButton")
                YesBtn.Image = "rbxassetid://10030902360"; YesBtn.Size = UDim2.new(0,18,0,18)
                YesBtn.Position = UDim2.new(1,-48,0,5); YesBtn.BackgroundTransparency = 1
                YesBtn.ZIndex = 10001; YesBtn.Parent = Popup

                local h2,sat2,val2,alpha2 = 0,1,1,1
                local dragHS,dragH,dragA = false,false,false

                local function updateCP()
                    local col = Color3.fromHSV(h2,sat2,val2)
                    HSB.BackgroundColor3 = Color3.fromHSV(h2,1,1)
                    Sel.Position = UDim2.new(sat2,0,1-val2,0)
                    Preview.BackgroundColor3 = col
                    HexLbl.Text = "#"..col:ToHex():upper()
                    return col
                end

                HSB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragHS=true end end)
                HBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragH=true end end)
                ABar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragA=true end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragHS=false;dragH=false;dragA=false end end)
                UIS.InputChanged:Connect(function(i)
                    if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
                    local p = i.Position
                    if dragHS then
                        local mnX,mxX = HSB.AbsolutePosition.X, HSB.AbsolutePosition.X+HSB.AbsoluteSize.X
                        local mnY,mxY = HSB.AbsolutePosition.Y, HSB.AbsolutePosition.Y+HSB.AbsoluteSize.Y
                        sat2=(math.clamp(p.X,mnX,mxX)-mnX)/(mxX-mnX)
                        val2=1-((math.clamp(p.Y,mnY,mxY)-mnY)/(mxY-mnY))
                        updateCP()
                    elseif dragH then
                        local mnY,mxY = HBar.AbsolutePosition.Y, HBar.AbsolutePosition.Y+HBar.AbsoluteSize.Y
                        h2=(math.clamp(p.Y,mnY,mxY)-mnY)/(mxY-mnY)
                        HMark.Position = UDim2.new(0,0,h2,0); updateCP()
                    elseif dragA then
                        local mnX,mxX = ABar.AbsolutePosition.X, ABar.AbsolutePosition.X+ABar.AbsoluteSize.X
                        alpha2=(math.clamp(p.X,mnX,mxX)-mnX)/(mxX-mnX)
                        AMark.Position = UDim2.new(alpha2,0,0,0); updateCP()
                    end
                end)

                Preview.MouseButton1Click:Connect(function()
                    Popup.Visible = true
                    Popup.BackgroundTransparency = 1
                    tween(Popup, 0.25, {BackgroundTransparency = 0})
                end)
                CloseBtn.MouseButton1Click:Connect(function() Popup.Visible = false end)
                YesBtn.MouseButton1Click:Connect(function()
                    local col = updateCP()
                    if s.callback then s.callback(col, alpha2) end
                    Popup.Visible = false
                end)

                function CPM:Set(c) Preview.BackgroundColor3 = c end
                return CPM
            end

            -- ── 3D View ──────────────────────────────────
            function ModuleManager:create_3dview(s)
                local order = growModule(250)
                local V3M = {}

                local VRow = Instance.new("Frame")
                VRow.Size = UDim2.new(0, 330, 0, 250)
                VRow.BackgroundTransparency = 1
                VRow.LayoutOrder = order; VRow.Parent = Options

                local VTit = Instance.new("TextLabel")
                VTit.Text = s.title or "3D View"
                VTit.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                VTit.TextSize = 11; VTit.TextColor3 = C.TXT
                VTit.BackgroundTransparency = 1
                VTit.Size = UDim2.new(1, 0, 0, 18)
                VTit.TextXAlignment = Enum.TextXAlignment.Left; VTit.Parent = VRow

                local VHolder = Instance.new("Frame")
                VHolder.Size = UDim2.new(1,0,1,-18); VHolder.Position = UDim2.new(0,0,0,18)
                VHolder.BackgroundColor3 = C.CARD2; VHolder.ClipsDescendants = true
                VHolder.Parent = VRow
                Instance.new("UICorner", VHolder).CornerRadius = UDim.new(0, 8)

                local VImg = Instance.new("ImageLabel")
                VImg.Size = UDim2.new(0,140,0,140); VImg.AnchorPoint = Vector2.new(0.5,0.5)
                VImg.Position = UDim2.new(0.5,0,0.5,0); VImg.BackgroundTransparency = 1
                VImg.Image = s.image or "rbxassetid://5791744848"
                VImg.ScaleType = Enum.ScaleType.Fit; VImg.Visible = false; VImg.Parent = VHolder

                local VP = Instance.new("ViewportFrame")
                VP.Size = UDim2.new(1,0,1,0); VP.BackgroundColor3 = C.BG
                VP.Visible = false; VP.Parent = VHolder
                Instance.new("UICorner", VP).CornerRadius = UDim.new(0,8)
                local VPCam = Instance.new("Camera"); VPCam.Parent = VP; VP.CurrentCamera = VPCam

                local curObj, is3D2, zl, bDist, cDist, origP, maxD2

                local function showImg2()
                    if curObj then curObj:Destroy() end
                    is3D2=false; VImg.Visible=true; VP.Visible=false
                end
                local function showMdl(obj)
                    if curObj then curObj:Destroy() end
                    VP:ClearAllChildren()
                    obj.Archivable=true; local cl=obj:Clone(); cl.Parent=VP; curObj=cl
                    local cf2, sz
                    if cl:IsA("Model") then cf2,sz=cl:GetBoundingBox(); origP=cl:GetPivot().Position
                    elseif cl:IsA("BasePart") then cf2,sz=cl.CFrame,cl.Size; origP=cl.Position
                    else return showImg2() end
                    maxD2=math.max(sz.X,sz.Y,sz.Z); bDist=maxD2*2.5; cDist=bDist
                    VPCam.CFrame=CFrame.new(origP+Vector3.new(0,maxD2/2,cDist),origP)
                    VPCam.Parent=VP; VP.CurrentCamera=VPCam
                    VP.Visible=true; VImg.Visible=false; is3D2=true
                end
                local function showMesh(mid,tid)
                    local mp=Instance.new("MeshPart"); mp.Size=Vector3.new(5,5,5)
                    mp.MeshId="rbxassetid://"..mid; mp.TextureID="rbxassetid://"..tid
                    showMdl(mp)
                end

                if s.model and (s.model:IsA("Model") or s.model:IsA("BasePart")) then showMdl(s.model)
                elseif s.meshId and s.texId then showMesh(s.meshId, s.texId)
                else showImg2() end

                local function mkIcBtn(img, pos)
                    local b = Instance.new("ImageButton")
                    b.Image=img; b.Size=UDim2.new(0,22,0,22)
                    b.BackgroundTransparency=0.4; b.BackgroundColor3=C.CARD
                    b.Position=pos; b.Parent=VP; b.ZIndex=10
                    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
                    return b
                end

                local up2   = mkIcBtn("rbxassetid://138007024966757", UDim2.new(0.5,-11,0,4))
                local dn2   = mkIcBtn("rbxassetid://13360801719",    UDim2.new(0.5,-11,1,-26))
                local lt2   = mkIcBtn("rbxassetid://100152237482023",UDim2.new(0,4,0.5,-11))
                local rt2   = mkIcBtn("rbxassetid://140701802205656",UDim2.new(1,-26,0.5,-11))
                local zin2  = mkIcBtn("rbxassetid://126943351764139",UDim2.new(1,-74,1,-27))
                local zout2 = mkIcBtn("rbxassetid://110884638624335",UDim2.new(1,-50,1,-27))
                local rst2  = mkIcBtn("rbxassetid://6723921202",     UDim2.new(1,-26,1,-27))

                local function rotMov(x2,y2)
                    if is3D2 and curObj then
                        if curObj:IsA("Model") then curObj:PivotTo(curObj:GetPivot()*CFrame.Angles(0,math.rad(x2),math.rad(y2)))
                        elseif curObj:IsA("BasePart") then curObj.CFrame=curObj.CFrame*CFrame.Angles(0,math.rad(x2),math.rad(y2)) end
                    else VImg.Position=VImg.Position+UDim2.new(0,x2*5,0,-y2*5) end
                end
                local function smZoom(td)
                    if not (is3D2 and origP) then return end
                    cDist=math.clamp(td,maxD2*0.5,maxD2*6)
                    local gCF=CFrame.new(origP+Vector3.new(0,maxD2/2,cDist),origP)
                    tween(VPCam, 0.3, {CFrame=gCF})
                end
                local function resetV()
                    if is3D2 and origP then smZoom(bDist)
                    else VImg.Position=UDim2.new(0.5,0,0.5,0); VImg.Size=UDim2.new(0,140,0,140) end
                end

                up2.MouseButton1Click:Connect(function() rotMov(0,10) end)
                dn2.MouseButton1Click:Connect(function() rotMov(0,-10) end)
                lt2.MouseButton1Click:Connect(function() rotMov(-10,0) end)
                rt2.MouseButton1Click:Connect(function() rotMov(10,0) end)
                zin2.MouseButton1Click:Connect(function() smZoom(cDist-0.5*(maxD2 or 5)) end)
                zout2.MouseButton1Click:Connect(function() smZoom(cDist+0.5*(maxD2 or 5)) end)
                rst2.MouseButton1Click:Connect(resetV)

                function V3M:SetModel(m) if m then showMdl(m) end end
                function V3M:SetMesh(m,t) showMesh(m,t) end
                function V3M:SetImage(i) s.image=i; showImg2() end
                return V3M
            end

            -- ── Feature ──────────────────────────────────
            function ModuleManager:create_feature(s)
                local order = growModule(22)
                local checked2 = false

                local FC = Instance.new("Frame")
                FC.Size = UDim2.new(0, 330, 0, 18)
                FC.BackgroundTransparency = 1
                FC.LayoutOrder = order; FC.Parent = Options

                local FBtnRow = Instance.new("UIListLayout")
                FBtnRow.FillDirection = Enum.FillDirection.Horizontal
                FBtnRow.SortOrder = Enum.SortOrder.LayoutOrder; FBtnRow.Parent = FC

                local FBtn = Instance.new("TextButton")
                FBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                FBtn.TextSize = 11; FBtn.Size = UDim2.new(1,-42,0,18)
                FBtn.BackgroundColor3 = C.CARD2; FBtn.BackgroundTransparency = 0.4
                FBtn.TextColor3 = C.TXT; FBtn.Text = "    "..(s.title or "Feature")
                FBtn.AutoButtonColor = false; FBtn.TextXAlignment = Enum.TextXAlignment.Left
                FBtn.TextTransparency = 0.05; FBtn.Parent = FC
                Instance.new("UICorner", FBtn).CornerRadius = UDim.new(0, 4)

                local FRight = Instance.new("Frame")
                FRight.Size = UDim2.new(0, 42, 0, 18); FRight.BackgroundTransparency = 1; FRight.Parent = FC
                local FRL = Instance.new("UIListLayout"); FRL.FillDirection = Enum.FillDirection.Horizontal
                FRL.Padding = UDim.new(0,2); FRL.HorizontalAlignment = Enum.HorizontalAlignment.Right; FRL.Parent = FRight

                local FKB = Instance.new("TextLabel")
                FKB.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                FKB.Size = UDim2.new(0,18,0,18); FKB.BackgroundColor3 = C.ELEM
                FKB.BackgroundTransparency = 0.2; FKB.TextColor3 = C.TXT2; FKB.TextSize = 9
                FKB.LayoutOrder = 2; FKB.Parent = FRight
                Instance.new("UICorner", FKB).CornerRadius = UDim.new(0,3)
                Instance.new("UIStroke", FKB).Color = C.STROKE2

                local FKBBtn = Instance.new("TextButton")
                FKBBtn.Size = UDim2.new(1,0,1,0); FKBBtn.BackgroundTransparency = 1
                FKBBtn.TextTransparency = 1; FKBBtn.Parent = FKB

                if not Library._config._flags then Library._config._flags = {} end
                if not Library._config._flags[s.flag] then
                    Library._config._flags[s.flag] = {checked=false, BIND=s.default or "Unknown"}
                end

                checked2 = Library._config._flags[s.flag].checked
                FKB.Text = Library._config._flags[s.flag].BIND
                if FKB.Text == "Unknown" then FKB.Text = "..." end

                local UseF2 = nil

                if not s.disablecheck then
                    local FCB = Instance.new("TextButton")
                    FCB.Size = UDim2.new(0,18,0,18)
                    FCB.BackgroundColor3 = checked2 and C.ACCENT or C.ELEM
                    FCB.BackgroundTransparency = checked2 and 0.3 or 0.2
                    FCB.Text = ""; FCB.LayoutOrder = 1; FCB.Parent = FRight
                    Instance.new("UICorner", FCB).CornerRadius = UDim.new(0,3)
                    local FCBS = Instance.new("UIStroke", FCB); FCBS.Color = C.STROKE2; FCBS.Thickness = 1
                    FCBS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                    local function toggleF()
                        checked2 = not checked2
                        tween(FCB, 0.25, {BackgroundColor3 = checked2 and C.ACCENT or C.ELEM})
                        tween(FCBS, 0.25, {Color = checked2 and C.ACCENT or C.STROKE2})
                        Library._config._flags[s.flag].checked = checked2
                        Config:save(game.GameId, Library._config)
                        if s.callback then s.callback(checked2) end
                    end
                    UseF2 = toggleF
                    FCB.MouseButton1Click:Connect(toggleF)
                else
                    UseF2 = function() if s.button_callback then s.button_callback() end end
                end

                FKBBtn.MouseButton1Click:Connect(function()
                    FKB.Text = "..."
                    local conn
                    conn = UIS.InputBegan:Connect(function(inp, gp)
                        if gp then return end
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            local nk = inp.KeyCode.Name
                            Library._config._flags[s.flag].BIND = nk
                            FKB.Text = nk ~= "Unknown" and nk or "..."
                            Config:save(game.GameId, Library._config)
                            conn:Disconnect()
                        elseif inp.UserInputType == Enum.UserInputType.MouseButton3 then
                            Library._config._flags[s.flag].BIND = "Unknown"
                            FKB.Text = "..."
                            Config:save(game.GameId, Library._config)
                            conn:Disconnect()
                        end
                    end)
                end)

                Connections["fkbp_"..s.flag] = UIS.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        if inp.KeyCode.Name == Library._config._flags[s.flag].BIND then
                            UseF2()
                        end
                    end
                end)

                FBtn.MouseButton1Click:Connect(function() if s.button_callback then s.button_callback() end end)
                FBtn.MouseEnter:Connect(function() tween(FBtn, 0.2, {BackgroundColor3 = C.HOVER}) end)
                FBtn.MouseLeave:Connect(function() tween(FBtn, 0.2, {BackgroundColor3 = C.CARD2}) end)

                if not s.disablecheck then s.callback(checked2) end
                return FC
            end

            return ModuleManager
        end -- create_module

        return TabManager
    end -- create_tab

    -- ── Toggle visibility on Insert ───────────────────────
    Connections["lib_vis"] = UIS.InputBegan:Connect(function(inp, proc)
        if inp.KeyCode ~= Enum.KeyCode.Insert then return end
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    MinBtn.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    return self
end -- create_ui

return Library
