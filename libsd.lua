--[[
  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗
  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝
  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗
  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║
  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║
  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
  UI Library v2.0 — Purple / Rose Theme
  Full GG API compatibility
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

-- ╔════════════════════════════╗
-- ║  PALETTE                   ║
-- ╚════════════════════════════╝
local P = {
    WIN       = Color3.fromRGB(8,   7,  18),
    TOPBAR    = Color3.fromRGB(12,  10, 26),
    CARD      = Color3.fromRGB(16,  14, 36),
    CARD2     = Color3.fromRGB(22,  19, 48),
    ELEM      = Color3.fromRGB(30,  26, 62),
    HOVER     = Color3.fromRGB(38,  34, 78),

    A1        = Color3.fromRGB(138, 92, 255),  -- primary purple
    A2        = Color3.fromRGB(255, 72, 148),  -- rose/pink
    A3        = Color3.fromRGB(92,  200,255),  -- cyan highlight

    STROKE    = Color3.fromRGB(60,  50, 110),
    STROKE2   = Color3.fromRGB(90,  75, 155),

    TXT       = Color3.fromRGB(245, 242, 255),
    TXT2      = Color3.fromRGB(170, 160, 210),
    TXT3      = Color3.fromRGB(100,  92, 148),

    ON        = Color3.fromRGB(138, 92, 255),
    OFF       = Color3.fromRGB(30,  26, 62),

    SUCCESS   = Color3.fromRGB(72,  220,130),
    ERROR     = Color3.fromRGB(255,  72, 90),
    WARN      = Color3.fromRGB(255, 195,  50),
}

-- ╔════════════════════════════╗
-- ║  SERVICES                  ║
-- ╚════════════════════════════╝
local UIS     = cloneref(game:GetService("UserInputService"))
local CP      = cloneref(game:GetService("ContentProvider"))
local TS      = cloneref(game:GetService("TweenService"))
local HTTP    = cloneref(game:GetService("HttpService"))
local TXTSVC  = cloneref(game:GetService("TextService"))
local LIGHT   = cloneref(game:GetService("Lighting"))
local PLR     = cloneref(game:GetService("Players"))
local CG      = cloneref(game:GetService("CoreGui"))
local DEB     = cloneref(game:GetService("Debris"))

local mouse = PLR.LocalPlayer:GetMouse()

-- cleanup old instances
for _, n in {"Nexus","NexusNotif"} do
    local old = CG:FindFirstChild(n)
    if old then DEB:AddItem(old, 0) end
end
if not isfolder("Nexus") then makefolder("Nexus") end

-- ╔════════════════════════════╗
-- ║  CONNECTIONS               ║
-- ╚════════════════════════════╝
local Conn = {}
Conn.__index = {
    off = function(self,k)
        if self[k] then self[k]:Disconnect(); self[k]=nil end
    end,
    offAll = function(self)
        for k,v in pairs(self) do
            if type(v)~="function" then pcall(function() v:Disconnect() end) end
        end
    end
}
setmetatable(Conn, Conn.__index)

-- ╔════════════════════════════╗
-- ║  HELPERS                   ║
-- ╚════════════════════════════╝
local function tw(obj, t, props, sty, dir)
    TS:Create(obj, TweenInfo.new(t, sty or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
end

local function inst(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k]=v end
    return o
end

local function corner(r, parent)
    inst("UICorner", {CornerRadius=UDim.new(0,r), Parent=parent})
end

local function stroke(c, t, parent)
    inst("UIStroke", {Color=c, Thickness=t or 1, Transparency=0, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=parent})
end

local function gradient(parent, colors, transparent, rot)
    local ks = {}
    for i,v in ipairs(colors or {}) do ks[i]=ColorSequenceKeypoint.new((i-1)/(#colors-1),v) end
    local tks = {}
    for i,v in ipairs(transparent or {}) do tks[i]=NumberSequenceKeypoint.new(v[1],v[2]) end
    inst("UIGradient", {
        Color           = #ks>1 and ColorSequence.new(ks) or nil,
        Transparency    = #tks>1 and NumberSequence.new(tks) or nil,
        Rotation        = rot or 0,
        Parent          = parent
    })
end

local function fadeGrad(parent)
    gradient(parent, nil, {{0,1},{0.12,0},{0.88,0},{1,1}}, 0)
end

function convertStringToTable(s)
    local r={}
    for v in s:gmatch("([^,]+)") do r[#r+1]=v:match("^%s*(.-)%s*$") end
    return r
end

function convertTableToString(t)
    return table.concat(t, ", ")
end

-- ╔════════════════════════════╗
-- ║  ACRYLIC BLUR              ║
-- ╚════════════════════════════╝
local Blur = {}
Blur.__index = Blur
function Blur.new(obj)
    local self = setmetatable({_o=obj,_f=nil,_fr=nil,_r=nil}, Blur)
    self:_init(); return self
end
function Blur:_init()
    -- depth of field
    local dof = LIGHT:FindFirstChild("NexusBlur") or Instance.new("DepthOfFieldEffect")
    dof.FarIntensity=0; dof.FocusDistance=0.05; dof.InFocusRadius=0.1; dof.NearIntensity=1
    dof.Name="NexusBlur"; dof.Parent=LIGHT
    -- folder
    local old=workspace.CurrentCamera:FindFirstChild("NexusBlur")
    if old then DEB:AddItem(old,0) end
    self._f=inst("Folder",{Name="NexusBlur",Parent=workspace.CurrentCamera})
    -- part
    local p=Instance.new("Part")
    p.Name="Root"; p.Color=Color3.new(0,0,0); p.Material=Enum.Material.Glass
    p.Size=Vector3.new(1,1,0); p.Anchored=true; p.CanCollide=false
    p.CanQuery=false; p.Locked=true; p.CastShadow=false; p.Transparency=0.98
    p.Parent=self._f
    local sm=Instance.new("SpecialMesh"); sm.MeshType=Enum.MeshType.Brick
    sm.Offset=Vector3.new(0,0,-.000001); sm.Parent=p; self._r=p
    -- frame
    self._fr=inst("Frame",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(.5,0,.5,0),
        AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Parent=self._o})
    -- render
    local function pos()
        local cam=workspace.CurrentCamera
        local function vp2w(l,d) local r=cam:ScreenPointToRay(l.X,l.Y); return r.Origin+r.Direction*d end
        local off=math.max(8,cam.ViewportSize.Y/45)
        local sz=self._fr.AbsoluteSize-Vector2.new(off,off)
        local pt=self._fr.AbsolutePosition+Vector2.new(off/2,off/2)
        local tl,tr,br=pt,pt+Vector2.new(sz.X,0),pt+sz
        local tl3,tr3,br3=vp2w(tl,.001),vp2w(tr,.001),vp2w(br,.001)
        local w=(tr3-tl3).Magnitude; local h=(tr3-br3).Magnitude
        if not self._r then return end
        self._r.CFrame=CFrame.fromMatrix((tl3+br3)/2,cam.CFrame.XVector,cam.CFrame.YVector,cam.CFrame.ZVector)
        self._r.Mesh.Scale=Vector3.new(w,h,0)
    end
    Conn["bl_cf"]=workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(pos)
    Conn["bl_vp"]=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(pos)
    Conn["bl_ap"]=self._fr:GetPropertyChangedSignal("AbsolutePosition"):Connect(pos)
    Conn["bl_as"]=self._fr:GetPropertyChangedSignal("AbsoluteSize"):Connect(pos)
    task.spawn(pos)
    -- quality check
    local gs=UserSettings().GameSettings
    if gs.SavedQualityLevel.Value < 8 then self._r.Transparency=1 end
    Conn["bl_ql"]=gs:GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
        self._r.Transparency=UserSettings().GameSettings.SavedQualityLevel.Value>=8 and 0.98 or 1
    end)
end

-- ╔════════════════════════════╗
-- ║  CONFIG                    ║
-- ╚════════════════════════════╝
local Cfg = {}
function Cfg:save(n,c)
    pcall(function() writefile("Nexus/"..n..".json", HTTP:JSONEncode(c)) end)
end
function Cfg:load(n)
    local ok,r=pcall(function()
        if not isfile("Nexus/"..n..".json") then return nil end
        local d=readfile("Nexus/"..n..".json"); if not d then return nil end
        return HTTP:JSONDecode(d)
    end)
    return (ok and r) or {_flags={},_keybinds={},_library={}}
end

-- ╔════════════════════════════╗
-- ║  NOTIFICATIONS             ║
-- ╚════════════════════════════╝
local NotifGui = inst("ScreenGui",{
    Name="NexusNotif", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    DisplayOrder=9999, IgnoreGuiInset=true, Parent=CG
})
local NH = inst("Frame",{
    Size=UDim2.new(0,290,1,0), Position=UDim2.new(1,-300,0,0),
    BackgroundTransparency=1, Parent=NotifGui
})
local NL = inst("UIListLayout",{
    FillDirection=Enum.FillDirection.Vertical,
    VerticalAlignment=Enum.VerticalAlignment.Bottom,
    SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6),
    Parent=NH
})
inst("UIPadding",{PaddingBottom=UDim.new(0,14),Parent=NH})
local nCnt=0

-- ╔════════════════════════════╗
-- ║  LIBRARY                   ║
-- ╚════════════════════════════╝
local Library = {
    _config       = Cfg:load(tostring(game.GameId)),
    _choosing_kb  = false,
    _device       = nil,
    _ui_open      = true,
    _ui_scale     = 1,
    _ui_loaded    = false,
    _ui           = nil,
    _dragging     = false,
    _drag_start   = nil,
    _drag_pos     = nil,
    _tab_btns     = {},
    _tab          = 0,
}
Library.__index = Library

-- ── SendNotification ──────────────────────────────────────
function Library.SendNotification(s)
    nCnt+=1
    local ac = s.type=="error" and P.ERROR or s.type=="success" and P.SUCCESS
               or s.type=="warning" and P.WARN or P.A1

    local W = inst("Frame",{
        Name="N"..nCnt, Size=UDim2.new(1,0,0,62),
        BackgroundTransparency=1, ClipsDescendants=false,
        LayoutOrder=nCnt, Position=UDim2.new(1.3,0,0,0), Parent=NH
    })
    local Card = inst("Frame",{
        Size=UDim2.new(1,0,1,0), BackgroundColor3=P.CARD,
        BorderSizePixel=0, Parent=W
    })
    corner(10,Card)
    local CS = inst("UIStroke",{Color=ac,Transparency=0.55,Thickness=1.5,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=Card})
    -- left bar
    local LB = inst("Frame",{
        Size=UDim2.new(0,3,0,30), AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,8,0.5,0), BackgroundColor3=ac,
        BorderSizePixel=0, Parent=Card
    })
    corner(2,LB)
    -- icon
    local IB = inst("Frame",{
        Size=UDim2.new(0,28,0,28), AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,16,0.5,0), BackgroundColor3=ac,
        BackgroundTransparency=0.75, BorderSizePixel=0, Parent=Card
    })
    corner(14,IB)
    inst("ImageLabel",{
        Image=s.icon or "rbxassetid://10653372143",
        Size=UDim2.new(0,16,0,16), AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(.5,0,.5,0), BackgroundTransparency=1,
        ImageColor3=Color3.new(1,1,1), ScaleType=Enum.ScaleType.Fit,
        ZIndex=2, Parent=IB
    })
    -- title + body
    inst("TextLabel",{
        Text=s.title or "Nexus",
        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
        TextSize=13, TextColor3=P.TXT, BackgroundTransparency=1,
        Size=UDim2.new(1,-60,0,14), Position=UDim2.new(0,54,0,9),
        TextXAlignment=Enum.TextXAlignment.Left, Parent=Card
    })
    inst("TextLabel",{
        Text=s.text or "",
        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
        TextSize=10, TextColor3=P.TXT2, BackgroundTransparency=1,
        Size=UDim2.new(1,-60,0,26), Position=UDim2.new(0,54,0,25),
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true, Parent=Card
    })
    -- progress bar
    local PBg = inst("Frame",{
        Size=UDim2.new(1,-14,0,2), AnchorPoint=Vector2.new(0.5,1),
        Position=UDim2.new(0.5,0,1,-4), BackgroundColor3=P.ELEM,
        BorderSizePixel=0, ZIndex=2, Parent=Card
    })
    corner(1,PBg)
    local PFill = inst("Frame",{
        Size=UDim2.new(1,0,1,0), BackgroundColor3=ac,
        BorderSizePixel=0, ZIndex=3, Parent=PBg
    })
    corner(1,PFill)
    gradient(PFill, {ac, P.A2})

    task.spawn(function()
        tw(W,0.4,{Position=UDim2.new(0,0,0,0)})
        local dur=s.duration or 5
        task.wait(0.45)
        tw(PFill,dur-0.5,{Size=UDim2.new(0,0,1,0)},Enum.EasingStyle.Linear,Enum.EasingDirection.In)
        task.wait(dur-0.5)
        tw(Card,0.3,{BackgroundTransparency=1})
        tw(W,0.3,{Position=UDim2.new(1.3,0,0,0)})
        task.wait(0.35); W:Destroy()
    end)
end

-- ── Library.new ───────────────────────────────────────────
function Library.new()
    local self = setmetatable({}, Library)
    self:_create_ui()
    return self
end

function Library:get_screen_scale()
    self._ui_scale = workspace.CurrentCamera.ViewportSize.X / 1400
end

function Library:get_device()
    if not UIS.TouchEnabled and UIS.KeyboardEnabled then self._device="PC"
    elseif UIS.TouchEnabled then self._device="Mobile"
    else self._device="Unknown" end
end

function Library:removed(fn) self._ui.AncestryChanged:Once(fn) end

function Library:flag_type(flag, t)
    if not Library._config._flags[flag] then return end
    return typeof(Library._config._flags[flag]) == t
end

function Library:remove_table_value(tbl, val)
    for i,v in ipairs(tbl) do if v==val then table.remove(tbl,i); break end end
end

-- ═══════════════════════════════════════════════════════════
--  CREATE UI
-- ═══════════════════════════════════════════════════════════
function Library:_create_ui()
    -- root gui
    local Gui = inst("ScreenGui",{
        Name="Nexus", ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling, Parent=CG
    })
    self._ui = Gui

    -- ── Window ────────────────────────────────────────────
    local Win = inst("Frame",{
        Name="Win",
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,0,0,0),
        BackgroundColor3=P.WIN,
        BackgroundTransparency=0.06,
        BorderSizePixel=0,
        ClipsDescendants=true,
        Active=true,
        Parent=Gui
    })
    corner(12,Win)
    -- gradient border via UIStroke
    local WStroke = inst("UIStroke",{
        Color=P.STROKE2, Transparency=0.3, Thickness=1.5,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=Win
    })
    local UIScale = inst("UIScale",{Parent=Win})

    -- ── Top bar (48px) ────────────────────────────────────
    local TB = inst("Frame",{
        Name="TB", Size=UDim2.new(1,0,0,48),
        BackgroundColor3=P.TOPBAR, BackgroundTransparency=0,
        BorderSizePixel=0, Parent=Win
    })
    -- bottom accent line on topbar
    local TBLine = inst("Frame",{
        Size=UDim2.new(1,0,0,1), AnchorPoint=Vector2.new(0,1),
        Position=UDim2.new(0,0,1,0), BackgroundColor3=P.A1,
        BackgroundTransparency=0, BorderSizePixel=0, Parent=TB
    })
    gradient(TBLine, {P.A2,P.A1,P.A3}, {{0,1},{0.1,0.1},{0.9,0.1},{1,1}}, 0)

    -- Logo
    local Logo = inst("Frame",{
        Size=UDim2.new(0,110,1,0), BackgroundTransparency=1, Parent=TB
    })
    local LogoIc = inst("ImageLabel",{
        Image="rbxassetid://10653372143",
        Size=UDim2.new(0,22,0,22), AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,12,0.5,0), BackgroundTransparency=1,
        ImageColor3=P.A1, ScaleType=Enum.ScaleType.Fit, Parent=Logo
    })
    task.spawn(function()
        while LogoIc and LogoIc.Parent do
            tw(LogoIc,1.5,{ImageColor3=P.A2},Enum.EasingStyle.Sine)
            task.wait(1.5)
            tw(LogoIc,1.5,{ImageColor3=P.A1},Enum.EasingStyle.Sine)
            task.wait(1.5)
        end
    end)
    local LogoLbl = inst("TextLabel",{
        Text="NEXUS",
        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
        TextSize=15, BackgroundTransparency=1, TextColor3=P.TXT,
        Size=UDim2.new(0,60,0,18), Position=UDim2.new(0,40,0.5,-9),
        TextXAlignment=Enum.TextXAlignment.Left, Parent=Logo
    })
    gradient(LogoLbl, {P.A1,P.A2})

    -- Tab scroll (center)
    local TabScroll = inst("ScrollingFrame",{
        Name="TabScroll",
        Size=UDim2.new(1,-250,1,-8),
        Position=UDim2.new(0,110,0,4),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=0, ScrollBarImageTransparency=1,
        AutomaticCanvasSize=Enum.AutomaticSize.X,
        CanvasSize=UDim2.new(0,0,0,0),
        ScrollingDirection=Enum.ScrollingDirection.X,
        Parent=TB
    })
    inst("UIListLayout",{
        FillDirection=Enum.FillDirection.Horizontal,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,3),
        VerticalAlignment=Enum.VerticalAlignment.Center,
        Parent=TabScroll
    })
    inst("UIPadding",{PaddingLeft=UDim.new(0,4),Parent=TabScroll})

    -- Active tab underline indicator
    local TInd = inst("Frame",{
        Name="Indicator", Size=UDim2.new(0,60,0,2),
        Position=UDim2.new(0,0,1,-1), BorderSizePixel=0,
        BackgroundColor3=P.A1, ZIndex=10, Parent=TabScroll
    })
    corner(1,TInd)
    gradient(TInd,{P.A2,P.A1,P.A3})

    -- Right controls
    local RCtrl = inst("Frame",{
        Size=UDim2.new(0,130,1,0),
        Position=UDim2.new(1,-133,0,0),
        BackgroundTransparency=1, Parent=TB
    })
    -- Discord btn
    local DBt = inst("TextButton",{
        Size=UDim2.new(0,86,0,30), AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,2,0.5,0),
        BackgroundColor3=P.CARD2, BackgroundTransparency=0.2,
        BorderSizePixel=0, Text="", AutoButtonColor=false, Parent=RCtrl
    })
    corner(8,DBt)
    inst("UIStroke",{Color=Color3.fromRGB(88,101,242),Transparency=0.45,
        Thickness=1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=DBt})
    inst("ImageLabel",{Image="rbxassetid://112538196670712",
        Size=UDim2.new(0,14,0,14),AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,9,0.5,0),BackgroundTransparency=1,
        ImageColor3=Color3.fromRGB(140,155,255),Parent=DBt})
    inst("TextLabel",{Text="Discord",
        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
        TextSize=11,TextColor3=Color3.fromRGB(200,210,255),
        BackgroundTransparency=1,Size=UDim2.new(0,50,1,0),
        Position=UDim2.new(0,27,0,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=DBt})
    DBt.MouseEnter:Connect(function() tw(DBt,0.2,{BackgroundColor3=P.HOVER}) end)
    DBt.MouseLeave:Connect(function() tw(DBt,0.2,{BackgroundColor3=P.CARD2}) end)
    DBt.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/gngstore")
        Library.SendNotification({title="Discord",text="Invite link copied!",icon="rbxassetid://112538196670712",duration=4,type="success"})
    end)
    -- Minimize btn
    local MBt = inst("TextButton",{
        Size=UDim2.new(0,30,0,30), AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,92,0.5,0),
        BackgroundColor3=P.CARD2, BackgroundTransparency=0.2,
        BorderSizePixel=0, Text="", AutoButtonColor=false, Parent=RCtrl
    })
    corner(8,MBt)
    inst("UIStroke",{Color=P.STROKE2,Transparency=0.4,Thickness=1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=MBt})
    inst("ImageLabel",{Image="rbxassetid://7072706796",
        Size=UDim2.new(0,14,0,14),AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=1,
        ImageColor3=P.TXT2,Parent=MBt})
    MBt.MouseEnter:Connect(function() tw(MBt,0.2,{BackgroundColor3=P.HOVER}) end)
    MBt.MouseLeave:Connect(function() tw(MBt,0.2,{BackgroundColor3=P.CARD2}) end)

    -- ── Content area (below topbar) ───────────────────────
    local CA = inst("Frame",{
        Name="CA", Size=UDim2.new(1,0,1,-50),
        Position=UDim2.new(0,0,0,50),
        BackgroundTransparency=1, Parent=Win
    })

    -- vertical center divider
    local VD = inst("Frame",{
        Size=UDim2.new(0,1,1,-16), AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),
        BackgroundColor3=P.STROKE2, BackgroundTransparency=0.4,
        BorderSizePixel=0, Parent=CA
    })
    gradient(VD,nil,{{0,1},{0.15,0},{0.85,0},{1,1}},90)

    -- sections folder
    local Sects = inst("Folder",{Name="Sects",Parent=CA})

    -- ── Drag ──────────────────────────────────────────────
    Win.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            self._dragging=true; self._drag_start=inp.Position; self._drag_pos=Win.Position
            Conn["de"]=inp.Changed:Connect(function()
                if inp.UserInputState==Enum.UserInputState.End then Conn:off("de"); self._dragging=false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not self._dragging then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local d=inp.Position-self._drag_start
            tw(Win,0.12,{Position=UDim2.new(
                self._drag_pos.X.Scale,self._drag_pos.X.Offset+d.X,
                self._drag_pos.Y.Scale,self._drag_pos.Y.Offset+d.Y)})
        end
    end)

    self:removed(function() self._ui=nil; Conn:offAll() end)

    -- ── Methods ───────────────────────────────────────────
    function self:UIVisiblity() Gui.Enabled = not Gui.Enabled end
    function self:Update1Run(a)
        Win.BackgroundTransparency = (a=="nil") and 0.06 or (tonumber(a) or 0.06)
    end

    function self:change_visiblity(state)
        if state then
            tw(Win,0.45,{Size=UDim2.fromOffset(760,470)})
        else
            tw(Win,0.45,{Size=UDim2.fromOffset(138,48)})
        end
    end

    function self:load()
        local imgs={}
        for _,o in Gui:GetDescendants() do if o:IsA("ImageLabel") then imgs[#imgs+1]=o end end
        CP:PreloadAsync(imgs)
        self:get_device()
        if self._device~="PC" then
            self:get_screen_scale(); UIScale.Scale=self._ui_scale
            Conn["sc_vp"]=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                self:get_screen_scale(); UIScale.Scale=self._ui_scale
            end)
        end
        tw(Win,0.5,{Size=UDim2.fromOffset(760,470)})
        Blur.new(Win); self._ui_loaded=true
    end

    -- ── Tab management ────────────────────────────────────
    function self:update_tabs(activeBtn)
        for _,btn in ipairs(self._tab_btns) do
            if btn==activeBtn then
                tw(btn,0.3,{BackgroundTransparency=0.7,BackgroundColor3=P.A1})
                tw(btn:FindFirstChildOfClass("TextLabel"),0.3,{TextColor3=P.TXT,TextTransparency=0})
                tw(btn:FindFirstChild("Ic"),0.3,{ImageColor3=P.TXT,ImageTransparency=0.1})
                tw(TInd,0.35,{Position=UDim2.new(0,btn.Position.X.Offset,1,-1),Size=UDim2.new(0,btn.AbsoluteSize.X,0,2)})
            else
                tw(btn,0.3,{BackgroundTransparency=1,BackgroundColor3=P.ELEM})
                tw(btn:FindFirstChildOfClass("TextLabel"),0.3,{TextColor3=P.TXT3,TextTransparency=0.2})
                tw(btn:FindFirstChild("Ic"),0.3,{ImageColor3=P.TXT3,ImageTransparency=0.55})
            end
        end
    end

    function self:update_sects(L,R)
        for _,o in Sects:GetChildren() do o.Visible=(o==L or o==R) end
    end

    -- ── create_tab ────────────────────────────────────────
    function self:create_tab(title, icon)
        local TM = {}
        local modOrder = 0
        local firstTab = #self._tab_btns == 0

        -- measure title
        local fp=Instance.new("GetTextBoundsParams")
        fp.Text=title
        fp.Font=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
        fp.Size=12; fp.Width=10000
        local fsz=TXTSVC:GetTextBoundsAsync(fp)

        -- tab button
        local TabBtn = inst("TextButton",{
            Name="Tab", LayoutOrder=self._tab,
            Size=UDim2.new(0,math.max(68,fsz.X+40),0,32),
            BackgroundColor3=P.ELEM, BackgroundTransparency=1,
            BorderSizePixel=0, Text="", AutoButtonColor=false,
            Parent=TabScroll
        })
        corner(7,TabBtn)

        local TBIc = inst("ImageLabel",{
            Name="Ic", Image=icon,
            Size=UDim2.new(0,12,0,12), AnchorPoint=Vector2.new(0,0.5),
            Position=UDim2.new(0,10,0.5,0), BackgroundTransparency=1,
            ImageColor3=P.TXT3, ImageTransparency=0.55, ScaleType=Enum.ScaleType.Fit,
            Parent=TabBtn
        })
        local TBLbl = inst("TextLabel",{
            Text=title,
            FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
            TextSize=12, TextColor3=P.TXT3, TextTransparency=0.2, BackgroundTransparency=1,
            Size=UDim2.new(0,fsz.X,0,14), AnchorPoint=Vector2.new(0,0.5),
            Position=UDim2.new(0,26,0.5,0), TextXAlignment=Enum.TextXAlignment.Left,
            Parent=TabBtn
        })

        self._tab_btns[#self._tab_btns+1] = TabBtn

        -- Left section
        local LS = inst("ScrollingFrame",{
            Name="LS", Size=UDim2.new(0,368,1,-10),
            Position=UDim2.new(0,4,0,5), BackgroundTransparency=1,
            BorderSizePixel=0, ScrollBarThickness=0,
            ScrollBarImageTransparency=1,
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            CanvasSize=UDim2.new(0,0,0.5,0),
            Selectable=false, Visible=false, Parent=Sects
        })
        local LSL=inst("UIListLayout",{Padding=UDim.new(0,7),
            HorizontalAlignment=Enum.HorizontalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder,Parent=LS})
        inst("UIPadding",{PaddingTop=UDim.new(0,4),Parent=LS})

        -- Right section
        local RS = inst("ScrollingFrame",{
            Name="RS", Size=UDim2.new(0,368,1,-10),
            Position=UDim2.new(0.5,4,0,5), BackgroundTransparency=1,
            BorderSizePixel=0, ScrollBarThickness=0,
            ScrollBarImageTransparency=1,
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            CanvasSize=UDim2.new(0,0,0.5,0),
            Selectable=false, Visible=false, Parent=Sects
        })
        local RSL=inst("UIListLayout",{Padding=UDim.new(0,7),
            HorizontalAlignment=Enum.HorizontalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder,Parent=RS})
        inst("UIPadding",{PaddingTop=UDim.new(0,4),Parent=RS})

        self._tab += 1

        if firstTab then
            self:update_tabs(TabBtn); self:update_sects(LS,RS)
        end

        TabBtn.MouseButton1Click:Connect(function()
            self:update_tabs(TabBtn); self:update_sects(LS,RS)
        end)
        TabBtn.MouseEnter:Connect(function()
            if TabBtn.BackgroundTransparency ~= 0.7 then tw(TabBtn,0.18,{BackgroundTransparency=0.88}) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if TabBtn.BackgroundTransparency ~= 0.7 then tw(TabBtn,0.18,{BackgroundTransparency=1}) end
        end)

        -- ── create_module ─────────────────────────────────
        function TM:create_module(s)
            local MM = {_state=false, _size=0, _mult=0}
            local elemOrder = 0

            local sec = (s.section=="right") and RS or LS

            -- Outer card
            local Mod = inst("Frame",{
                Name="Mod", Size=UDim2.new(0,352,0,72),
                BackgroundColor3=P.CARD,
                BackgroundTransparency=0.1,
                BorderSizePixel=0,
                ClipsDescendants=true,
                Parent=sec
            })
            corner(10,Mod)
            local ModSt = inst("UIStroke",{
                Color=P.STROKE, Transparency=0.45, Thickness=1.2,
                ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=Mod
            })
            inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=Mod})

            -- Left glow strip
            local Strip = inst("Frame",{
                Size=UDim2.new(0,3,0,28), AnchorPoint=Vector2.new(0,0.5),
                Position=UDim2.new(0,0,0.5,0), BackgroundColor3=P.A1,
                BackgroundTransparency=0.1, BorderSizePixel=0, ZIndex=4, Parent=Mod
            })
            corner(2,Strip)
            gradient(Strip,{P.A2,P.A1},nil,90)

            -- subtle left glow wash
            local GW = inst("Frame",{
                Size=UDim2.new(0,80,1,0), BackgroundColor3=P.A1,
                BackgroundTransparency=0.92, BorderSizePixel=0, ZIndex=0, Parent=Mod
            })
            corner(10,GW)
            gradient(GW,nil,{{0,0},{1,1}},0)

            -- header
            local Head = inst("TextButton",{
                Name="Head", Size=UDim2.new(1,0,0,72),
                BackgroundTransparency=1, Text="",
                AutoButtonColor=false, BorderSizePixel=0,
                LayoutOrder=1, Parent=Mod
            })

            -- title
            local MNm = inst("TextLabel",{
                Text=(not s.rich) and (s.title or "Module") or nil,
                FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                TextSize=13, TextColor3=P.TXT, TextTransparency=0.05,
                BackgroundTransparency=1, Size=UDim2.new(0,230,0,16),
                AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,18,0.3,0),
                TextXAlignment=Enum.TextXAlignment.Left, Parent=Head
            })
            if s.rich then MNm.RichText=true; MNm.Text=s.richtext or "Module" end

            -- description
            local MDsc = inst("TextLabel",{
                Text=s.description or "",
                FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
                TextSize=10, TextColor3=P.TXT2, TextTransparency=0.1,
                BackgroundTransparency=1, Size=UDim2.new(0,220,0,12),
                AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,18,0.58,0),
                TextXAlignment=Enum.TextXAlignment.Left, Parent=Head
            })

            -- toggle switch
            local TSwBg = inst("Frame",{
                Size=UDim2.new(0,30,0,16), AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-12,0.78,0), BackgroundColor3=P.OFF,
                BorderSizePixel=0, Parent=Head
            })
            corner(8,TSwBg)
            local TSwDot = inst("Frame",{
                Size=UDim2.new(0,12,0,12), AnchorPoint=Vector2.new(0,0.5),
                Position=UDim2.new(0,2,0.5,0), BackgroundColor3=P.TXT3,
                BorderSizePixel=0, Parent=TSwBg
            })
            corner(6,TSwDot)

            -- keybind chip
            local KBChip = inst("Frame",{
                Size=UDim2.new(0,36,0,14), AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-48,0.78,0), BackgroundColor3=P.ELEM,
                BackgroundTransparency=0.2, BorderSizePixel=0, Parent=Head
            })
            corner(4,KBChip)
            inst("UIStroke",{Color=P.STROKE,Transparency=0.6,Thickness=1,
                ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=KBChip})
            local KBLbl = inst("TextLabel",{
                Text="None",
                FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                TextSize=8, TextColor3=P.TXT2, BackgroundTransparency=1,
                Size=UDim2.new(1,0,1,0), TextXAlignment=Enum.TextXAlignment.Center,
                Parent=KBChip
            })

            -- head divider
            local HDivF = inst("Frame",{
                Size=UDim2.new(1,0,0,1), AnchorPoint=Vector2.new(0.5,1),
                Position=UDim2.new(0.5,0,1,0), BackgroundColor3=P.STROKE,
                BackgroundTransparency=0.3, BorderSizePixel=0, Parent=Head
            })
            fadeGrad(HDivF)

            -- options container
            local Opts = inst("Frame",{
                Name="Options", Size=UDim2.new(1,0,0,0),
                BackgroundTransparency=1, BorderSizePixel=0,
                LayoutOrder=2, Parent=Mod
            })
            inst("UIPadding",{PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,4),Parent=Opts})
            inst("UIListLayout",{Padding=UDim.new(0,5),
                HorizontalAlignment=Enum.HorizontalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder, Parent=Opts})

            -- ── change_state ───────────────────────────────
            function MM:change_state(state)
                self._state=state
                if state then
                    tw(Mod,0.42,{Size=UDim2.fromOffset(352,72+self._size+self._mult)})
                    tw(TSwBg,0.38,{BackgroundColor3=P.ON})
                    tw(TSwDot,0.38,{BackgroundColor3=Color3.new(1,1,1),Position=UDim2.new(0,16,0.5,0)})
                    tw(Strip,0.38,{BackgroundColor3=P.A1})
                    tw(ModSt,0.38,{Color=P.A1,Transparency=0.55})
                else
                    tw(Mod,0.42,{Size=UDim2.fromOffset(352,72)})
                    tw(TSwBg,0.38,{BackgroundColor3=P.OFF})
                    tw(TSwDot,0.38,{BackgroundColor3=P.TXT3,Position=UDim2.new(0,2,0.5,0)})
                    tw(Strip,0.38,{BackgroundColor3=P.STROKE2})
                    tw(ModSt,0.38,{Color=P.STROKE,Transparency=0.45})
                end
                Library._config._flags[s.flag]=self._state
                Cfg:save(game.GameId,Library._config)
                s.callback(self._state)
            end

            function MM:connect_keybind()
                if not Library._config._keybinds[s.flag] then return end
                Conn[s.flag.."_kb"]=UIS.InputBegan:Connect(function(inp,proc)
                    if proc then return end
                    if tostring(inp.KeyCode)~=Library._config._keybinds[s.flag] then return end
                    self:change_state(not self._state)
                end)
            end

            function MM:scale_keybind(empty)
                if Library._config._keybinds[s.flag] and not empty then
                    local ks=Library._config._keybinds[s.flag]:gsub("Enum.KeyCode.","")
                    local fp2=Instance.new("GetTextBoundsParams")
                    fp2.Text=ks; fp2.Font=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                    fp2.Size=8; fp2.Width=10000
                    local fs2=TXTSVC:GetTextBoundsAsync(fp2)
                    KBChip.Size=UDim2.fromOffset(fs2.X+10,14)
                else
                    KBChip.Size=UDim2.fromOffset(36,14)
                end
            end

            if Library:flag_type(s.flag,"boolean") then
                MM._state=true; s.callback(MM._state)
                TSwBg.BackgroundColor3=P.ON; TSwDot.BackgroundColor3=Color3.new(1,1,1)
                TSwDot.Position=UDim2.new(0,16,0.5,0); Strip.BackgroundColor3=P.A1
                ModSt.Color=P.A1; ModSt.Transparency=0.55
            end

            if Library._config._keybinds[s.flag] then
                KBLbl.Text=Library._config._keybinds[s.flag]:gsub("Enum.KeyCode.","")
                MM:connect_keybind(); MM:scale_keybind()
            end

            -- middle-click → set keybind
            Head.InputBegan:Connect(function(inp)
                if Library._choosing_kb then return end
                if inp.UserInputType~=Enum.UserInputType.MouseButton3 then return end
                Library._choosing_kb=true
                local c; c=UIS.InputBegan:Connect(function(ki,kp)
                    if kp then return end
                    if ki.KeyCode==Enum.KeyCode.Unknown then return end
                    if ki.KeyCode==Enum.KeyCode.Backspace then
                        MM:scale_keybind(true); Library._config._keybinds[s.flag]=nil
                        Cfg:save(game.GameId,Library._config); KBLbl.Text="None"
                        if Conn[s.flag.."_kb"] then Conn:off(s.flag.."_kb") end
                        c:Disconnect(); Library._choosing_kb=false; return
                    end
                    c:Disconnect()
                    Library._config._keybinds[s.flag]=tostring(ki.KeyCode)
                    Cfg:save(game.GameId,Library._config)
                    if Conn[s.flag.."_kb"] then Conn:off(s.flag.."_kb") end
                    MM:connect_keybind(); MM:scale_keybind(); Library._choosing_kb=false
                    KBLbl.Text=Library._config._keybinds[s.flag]:gsub("Enum.KeyCode.","")
                end)
            end)

            Head.MouseButton1Click:Connect(function() MM:change_state(not MM._state) end)

            -- ── helper: grow ────────────────────────────
            local function grow(extra)
                elemOrder+=1
                if MM._size==0 then MM._size=8 end
                MM._size+=extra
                if MM._state then Mod.Size=UDim2.fromOffset(352,72+MM._size+MM._mult) end
                Opts.Size=UDim2.fromOffset(352,MM._size)
                return elemOrder
            end

            -- ═══════════════════ ELEMENTS ═══════════════

            -- ── Paragraph ────────────────────────────────
            function MM:create_paragraph(s)
                local ord=grow(s.customScale or 58)
                local Pf=inst("Frame",{
                    Size=UDim2.new(0,326,0,28), BackgroundColor3=P.CARD2,
                    BackgroundTransparency=0.15, BorderSizePixel=0,
                    AutomaticSize=Enum.AutomaticSize.Y, LayoutOrder=ord, Parent=Opts
                })
                corner(6,Pf)
                inst("TextLabel",{Text=s.title or "",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                    TextSize=12,TextColor3=P.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-12,0,16),Position=UDim2.new(0,8,0,5),
                    TextXAlignment=Enum.TextXAlignment.Left,AutomaticSize=Enum.AutomaticSize.XY,Parent=Pf})
                local PBd=inst("TextLabel",{
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
                    TextSize=10,TextColor3=P.TXT2,BackgroundTransparency=1,
                    Size=UDim2.new(1,-16,0,20),Position=UDim2.new(0,8,0,22),
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
                    TextWrapped=true,AutomaticSize=Enum.AutomaticSize.XY,Parent=Pf})
                if not s.rich then PBd.Text=s.text or "" else PBd.RichText=true; PBd.Text=s.richtext or "" end
                Pf.MouseEnter:Connect(function() tw(Pf,0.2,{BackgroundColor3=P.HOVER}) end)
                Pf.MouseLeave:Connect(function() tw(Pf,0.2,{BackgroundColor3=P.CARD2}) end)
                return {}
            end

            -- ── Button ────────────────────────────────────
            function MM:create_button(s)
                local ord=grow(26)
                local Row=inst("Frame",{Size=UDim2.new(0,326,0,20),BackgroundTransparency=1,LayoutOrder=ord,Parent=Opts})
                inst("TextLabel",{Text=s.title or "Button",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=11,TextColor3=P.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-34,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=Row})
                local Btn=inst("TextButton",{
                    Size=UDim2.new(0,26,0,20),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,0,0.5,0),BackgroundColor3=P.A1,
                    BackgroundTransparency=0.55,BorderSizePixel=0,Text="",
                    AutoButtonColor=false,Parent=Row})
                corner(6,Btn)
                local BIc=inst("ImageLabel",{Image="rbxassetid://139650104834071",
                    Size=UDim2.new(0.6,0,0.6,0),AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=1,Parent=Btn})
                task.spawn(function()
                    while BIc and BIc.Parent do tw(BIc,1.5,{Rotation=BIc.Rotation+360},Enum.EasingStyle.Linear); task.wait(1.5) end
                end)
                Btn.MouseEnter:Connect(function() tw(Btn,0.18,{BackgroundTransparency=0.1}) end)
                Btn.MouseLeave:Connect(function() tw(Btn,0.18,{BackgroundTransparency=0.55}) end)
                Btn.MouseButton1Click:Connect(function() if s.callback then s.callback() end end)
                return Row
            end

            -- ── Text ──────────────────────────────────────
            function MM:create_text(s)
                local ord=grow(s.customScale or 40)
                local TFr=inst("Frame",{Size=UDim2.new(0,326,0,s.CustomYSize or 32),BackgroundColor3=P.CARD2,
                    BackgroundTransparency=0.2,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=ord,Parent=Opts})
                corner(6,TFr)
                local TLb=inst("TextLabel",{FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
                    TextSize=10,TextColor3=P.TXT2,BackgroundTransparency=1,Size=UDim2.new(1,-12,1,0),
                    Position=UDim2.new(0,6,0,5),TextXAlignment=Enum.TextXAlignment.Left,
                    TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.XY,Parent=TFr})
                if not s.rich then TLb.Text=s.text or "" else TLb.RichText=true; TLb.Text=s.richtext or "" end
                TFr.MouseEnter:Connect(function() tw(TFr,0.2,{BackgroundColor3=P.HOVER}) end)
                TFr.MouseLeave:Connect(function() tw(TFr,0.2,{BackgroundColor3=P.CARD2}) end)
                local Mg={}
                function Mg:Set(ns)
                    if not ns.rich then TLb.Text=ns.text or "" else TLb.RichText=true; TLb.Text=ns.richtext or "" end
                end
                return Mg
            end

            -- ── Textbox ───────────────────────────────────
            function MM:create_textbox(s)
                local ord=grow(34)
                local TbM={_text=""}
                local TLbRow=inst("TextLabel",{Text=s.title or "Input",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=10,TextColor3=P.TXT,TextTransparency=0.1,BackgroundTransparency=1,
                    Size=UDim2.new(0,326,0,12),TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=ord,Parent=Opts})
                local TBx=inst("TextBox",{
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
                    TextSize=10,TextColor3=P.TXT,PlaceholderText=s.placeholder or "Type here...",
                    Text=Library._config._flags[s.flag] or "",BackgroundColor3=P.ELEM,
                    BackgroundTransparency=0.15,BorderSizePixel=0,ClearTextOnFocus=false,
                    Size=UDim2.new(0,326,0,18),LayoutOrder=ord,Parent=Opts})
                corner(5,TBx)
                local TBxSt=inst("UIStroke",{Color=P.STROKE,Transparency=0.5,Thickness=1,
                    ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=TBx})
                TBx.Focused:Connect(function() tw(TBxSt,0.2,{Color=P.A1,Transparency=0.2}) end)
                TBx.FocusLost:Connect(function()
                    tw(TBxSt,0.2,{Color=P.STROKE,Transparency=0.5})
                    TbM._text=TBx.Text; Library._config._flags[s.flag]=TbM._text
                    Cfg:save(game.GameId,Library._config); s.callback(TbM._text)
                end)
                if Library:flag_type(s.flag,"string") then TbM._text=Library._config._flags[s.flag]; s.callback(TbM._text) end
                return TbM
            end

            -- ── Checkbox ──────────────────────────────────
            function MM:create_checkbox(s)
                local ord=grow(20)
                local CbM={_state=false}
                local CbRow=inst("TextButton",{Size=UDim2.new(0,326,0,16),BackgroundTransparency=1,
                    Text="",AutoButtonColor=false,LayoutOrder=ord,Parent=Opts})
                local if_th = SelectedLanguage=="th"
                inst("TextLabel",{Text=s.title or "Checkbox",
                    FontFace=Font.new(if_th and "rbxasset://fonts/families/NotoSansThai.json" or
                        "rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=if_th and 13 or 11,TextColor3=P.TXT,TextTransparency=0.05,
                    BackgroundTransparency=1,Size=UDim2.new(1,-56,1,0),
                    TextXAlignment=Enum.TextXAlignment.Left,Parent=CbRow})
                -- keybind chip
                local CKC=inst("Frame",{Size=UDim2.fromOffset(28,14),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,-20,0.5,0),BackgroundColor3=P.ELEM,
                    BackgroundTransparency=0.2,BorderSizePixel=0,Parent=CbRow})
                corner(4,CKC)
                local CKL=inst("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                    TextColor3=P.TXT2,TextSize=8,Font=Enum.Font.SourceSans,
                    Text=Library._config._keybinds[s.flag] and
                        Library._config._keybinds[s.flag]:gsub("Enum.KeyCode.","") or "...",
                    Parent=CKC})
                -- box
                local CBox=inst("Frame",{Size=UDim2.fromOffset(16,16),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,0,0.5,0),BackgroundColor3=P.ELEM,BackgroundTransparency=0.1,
                    BorderSizePixel=0,Parent=CbRow})
                corner(4,CBox)
                local CBSt=inst("UIStroke",{Color=P.STROKE2,Transparency=0.3,Thickness=1.2,
                    ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=CBox})
                local CFl=inst("Frame",{Size=UDim2.fromOffset(0,0),AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=P.A1,BorderSizePixel=0,Parent=CBox})
                corner(3,CFl)

                function CbM:change_state(st)
                    self._state=st
                    if st then
                        tw(CBSt,0.3,{Color=P.A1,Transparency=0.1})
                        tw(CFl,0.3,{Size=UDim2.fromOffset(10,10),BackgroundColor3=P.A1})
                    else
                        tw(CBSt,0.3,{Color=P.STROKE2,Transparency=0.3})
                        tw(CFl,0.3,{Size=UDim2.fromOffset(0,0)})
                    end
                    Library._config._flags[s.flag]=self._state
                    Cfg:save(game.GameId,Library._config); s.callback(self._state)
                end
                if Library:flag_type(s.flag,"boolean") then CbM:change_state(Library._config._flags[s.flag]) end
                CbRow.MouseButton1Click:Connect(function() CbM:change_state(not CbM._state) end)
                CbRow.InputBegan:Connect(function(inp,gp)
                    if gp or inp.UserInputType~=Enum.UserInputType.MouseButton3 then return end
                    if Library._choosing_kb then return end
                    Library._choosing_kb=true
                    local c; c=UIS.InputBegan:Connect(function(ki,kp)
                        if kp then return end
                        if ki.UserInputType~=Enum.UserInputType.Keyboard then return end
                        if ki.KeyCode==Enum.KeyCode.Unknown then return end
                        if ki.KeyCode==Enum.KeyCode.Backspace then
                            Library._config._keybinds[s.flag]=nil
                            Cfg:save(game.GameId,Library._config); CKL.Text="..."
                            c:Disconnect(); Library._choosing_kb=false; return
                        end
                        c:Disconnect(); Library._config._keybinds[s.flag]=tostring(ki.KeyCode)
                        Cfg:save(game.GameId,Library._config)
                        CKL.Text=Library._config._keybinds[s.flag]:gsub("Enum.KeyCode.","")
                        Library._choosing_kb=false
                    end)
                end)
                Conn[s.flag.."_ckbp"]=UIS.InputBegan:Connect(function(inp,gp)
                    if gp then return end
                    local st=Library._config._keybinds[s.flag]
                    if st and tostring(inp.KeyCode)==st then CbM:change_state(not CbM._state) end
                end)
                return CbM
            end

            -- ── Divider ───────────────────────────────────
            function MM:create_divider(s)
                local ord=grow(20)
                local Dv=inst("Frame",{Size=UDim2.new(0,326,0,14),BackgroundTransparency=1,LayoutOrder=ord,Parent=Opts})
                if s and s.showtopic then
                    inst("TextLabel",{Text=s.title or "",
                        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                        TextSize=9,TextColor3=P.A1,BackgroundColor3=P.WIN,BackgroundTransparency=0,
                        Size=UDim2.new(0,70,0,12),AnchorPoint=Vector2.new(0.5,0.5),
                        Position=UDim2.new(0.5,0,0.5,0),TextXAlignment=Enum.TextXAlignment.Center,
                        ZIndex=3,Parent=Dv})
                end
                if not s or not s.disableline then
                    local DL=inst("Frame",{Size=UDim2.new(1,0,0,1),AnchorPoint=Vector2.new(0.5,0.5),
                        Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=P.A1,
                        BackgroundTransparency=0.25,BorderSizePixel=0,ZIndex=2,Parent=Dv})
                    corner(1,DL); fadeGrad(DL)
                end
                return true
            end

            -- ── Slider ────────────────────────────────────
            function MM:create_slider(s)
                local ord=grow(30)
                local SlM={}
                local SlF=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,
                    Size=UDim2.new(0,326,0,24),LayoutOrder=ord,Parent=Opts})
                local if_th=SelectedLanguage=="th"
                inst("TextLabel",{Text=s.title,
                    FontFace=Font.new(if_th and "rbxasset://fonts/families/NotoSansThai.json" or
                        "rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=if_th and 12 or 11,TextColor3=P.TXT,TextTransparency=0.1,
                    BackgroundTransparency=1,Size=UDim2.new(0,240,0,13),
                    Position=UDim2.new(0,0,0,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=SlF})
                local SlVal=inst("TextLabel",{Name="Value",Text="0",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                    TextSize=10,TextColor3=P.A1,BackgroundTransparency=1,
                    Size=UDim2.new(0,60,0,13),AnchorPoint=Vector2.new(1,0),
                    Position=UDim2.new(1,0,0,0),TextXAlignment=Enum.TextXAlignment.Right,Parent=SlF})
                local Trk=inst("Frame",{Name="Drag",Size=UDim2.new(1,0,0,4),AnchorPoint=Vector2.new(0.5,1),
                    Position=UDim2.new(0.5,0,1,0),BackgroundColor3=P.ELEM,BorderSizePixel=0,Parent=SlF})
                corner(2,Trk)
                local SlFl=inst("Frame",{Name="Fill",Size=UDim2.new(0.5,0,1,0),BackgroundColor3=P.A1,
                    BorderSizePixel=0,Parent=Trk})
                corner(2,SlFl)
                gradient(SlFl,{P.A2,P.A1,P.A3})
                local SlKn=inst("Frame",{Name="Circle",Size=UDim2.fromOffset(10,10),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,0,0.5,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=SlFl})
                corner(5,SlKn)
                function SlM:set_percentage(pct)
                    if type(pct)~="number" then return end
                    local rnd=s.round_number and math.floor(pct) or (math.floor(pct*10)/10)
                    local norm=(pct-s.minimum_value)/(s.maximum_value-s.minimum_value)
                    local sz=math.clamp(norm,0.02,1)*Trk.Size.X.Offset
                    local cl=math.clamp(rnd,s.minimum_value,s.maximum_value)
                    Library._config._flags[s.flag]=cl; SlVal.Text=tostring(cl)
                    tw(SlFl,0.38,{Size=UDim2.fromOffset(sz,Trk.Size.Y.Offset)})
                    if s.callback then s.callback(cl) end
                end
                function SlM:update()
                    local mp=(mouse.X-Trk.AbsolutePosition.X)/Trk.Size.X.Offset
                    self:set_percentage(s.minimum_value+(s.maximum_value-s.minimum_value)*mp)
                end
                function SlM:input()
                    self:update()
                    Conn["sl_d_"..s.flag]=mouse.Move:Connect(function() self:update() end)
                    Conn["sl_e_"..s.flag]=UIS.InputEnded:Connect(function(inp)
                        if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
                        Conn:off("sl_d_"..s.flag); Conn:off("sl_e_"..s.flag)
                        if not s.ignoresaved then Cfg:save(game.GameId,Library._config) end
                    end)
                end
                if Library:flag_type(s.flag,"number") and not s.ignoresaved then SlM:set_percentage(Library._config._flags[s.flag])
                else SlM:set_percentage(s.value) end
                SlF.MouseButton1Down:Connect(function() SlM:input() end)
                return SlM
            end

            -- ── Dropdown ──────────────────────────────────
            function MM:create_dropdown(s)
                if not s.Order then elemOrder+=1 end
                local DrM={_state=false,_size=0}
                if not s.Order then
                    if MM._size==0 then MM._size=8 end
                    MM._size+=46
                    if MM._state then Mod.Size=UDim2.fromOffset(352,72+MM._size+MM._mult) end
                    Opts.Size=UDim2.fromOffset(352,MM._size)
                end
                if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={} end

                local DrW=inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,326,0,42),Name="Dropdown",
                    LayoutOrder=s.Order and s.OrderValue or elemOrder,Parent=Opts})
                local if_th=SelectedLanguage=="th"
                inst("TextLabel",{Text=s.title,
                    FontFace=Font.new(if_th and "rbxasset://fonts/families/NotoSansThai.json" or
                        "rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=if_th and 12 or 11,TextColor3=P.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,13),TextXAlignment=Enum.TextXAlignment.Left,Parent=DrW})
                local DrBox=inst("Frame",{ClipsDescendants=true,Name="Box",
                    Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,15),
                    BackgroundColor3=P.ELEM,BackgroundTransparency=0.15,BorderSizePixel=0,Parent=DrW})
                corner(7,DrBox)
                local DrSt=inst("UIStroke",{Color=P.STROKE,Transparency=0.5,Thickness=1,
                    ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=DrBox})

                local DrHd=inst("Frame",{Name="Header",Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Parent=DrBox})
                inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=DrBox})

                local DrCur=inst("TextLabel",{Name="CurrentOption",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=10,TextColor3=P.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-28,1,0),Position=UDim2.new(0,10,0,0),
                    TextXAlignment=Enum.TextXAlignment.Left,Parent=DrHd})
                local DrCurGr=inst("UIGradient",{
                    Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.75,0),NumberSequenceKeypoint.new(1,1)},
                    Parent=DrCur})
                local DrArr=inst("ImageLabel",{Image="rbxassetid://84232453189324",Name="Arrow",
                    Size=UDim2.new(0,8,0,8),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,-8,0.5,0),BackgroundTransparency=1,
                    ImageColor3=P.TXT2,Parent=DrHd})
                local DrOps=inst("ScrollingFrame",{Name="Options",Size=UDim2.new(1,0,0,0),
                    Position=UDim2.new(0,0,1,0),BackgroundTransparency=1,
                    ScrollBarThickness=0,ScrollBarImageTransparency=1,
                    AutomaticCanvasSize=Enum.AutomaticSize.XY,CanvasSize=UDim2.new(0,0,0.5,0),
                    Parent=DrBox})
                inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=DrOps})
                inst("UIPadding",{PaddingLeft=UDim.new(0,10),Parent=DrOps})

                local DrBtn=inst("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=DrHd})

                function DrM:update(opt)
                    if s.multi_dropdown then
                        if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={} end
                        local sel={}
                        for v in convertTableToString(Library._config._flags[s.flag]):gmatch("([^,]+)") do
                            local t2=v:match("^%s*(.-)%s*$"); if t2~="Label" then sel[#sel+1]=t2 end
                        end
                        local oN=type(opt)=="string" and opt or opt.Name
                        local fi=nil; for i,v in ipairs(sel) do if v==oN then fi=i; break end end
                        if fi then table.remove(sel,fi) else sel[#sel+1]=oN end
                        DrCur.Text=table.concat(sel,", ")
                        for _,o in DrOps:GetChildren() do
                            if o.Name=="Opt" then o.TextTransparency=table.find(sel,o.Text) and 0 or 0.55 end
                        end
                        Library._config._flags[s.flag]=convertStringToTable(DrCur.Text)
                    else
                        DrCur.Text=(type(opt)=="string" and opt) or opt.Name
                        for _,o in DrOps:GetChildren() do
                            if o.Name=="Opt" then o.TextTransparency=(o.Text==DrCur.Text) and 0 or 0.55 end
                        end
                        Library._config._flags[s.flag]=opt
                    end
                    Cfg:save(game.GameId,Library._config); s.callback(opt)
                end

                local curDrS=0
                function DrM:unfold_settings()
                    self._state=not self._state
                    if self._state then
                        MM._mult+=self._size; curDrS=self._size
                        tw(Mod,0.4,{Size=UDim2.fromOffset(352,72+MM._size+MM._mult)})
                        tw(Mod.Options,0.4,{Size=UDim2.fromOffset(352,MM._size+MM._mult)})
                        tw(DrW,0.4,{Size=UDim2.fromOffset(326,42+self._size)})
                        tw(DrBox,0.4,{Size=UDim2.fromOffset(326,24+self._size)})
                        tw(DrArr,0.4,{Rotation=180}); tw(DrSt,0.3,{Color=P.A1,Transparency=0.3})
                    else
                        MM._mult-=self._size; curDrS=0
                        tw(Mod,0.4,{Size=UDim2.fromOffset(352,72+MM._size+MM._mult)})
                        tw(Mod.Options,0.4,{Size=UDim2.fromOffset(352,MM._size+MM._mult)})
                        tw(DrW,0.4,{Size=UDim2.fromOffset(326,42)})
                        tw(DrBox,0.4,{Size=UDim2.fromOffset(326,24)})
                        tw(DrArr,0.4,{Rotation=0}); tw(DrSt,0.3,{Color=P.STROKE,Transparency=0.5})
                    end
                end

                local maxOpts=s.maximum_options or #s.options
                if #s.options>0 then
                    DrM._size=4
                    for idx,val in s.options do
                        local Opt=inst("TextButton",{Name="Opt",
                            FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                            TextSize=10,TextColor3=P.TXT,TextTransparency=0.55,
                            Text=(type(val)=="string" and val) or val.Name,
                            BackgroundTransparency=1,Size=UDim2.new(0,300,0,16),
                            TextXAlignment=Enum.TextXAlignment.Left,
                            AutoButtonColor=false,Active=false,Selectable=false,Parent=DrOps})
                        local OGr=inst("UIGradient",{
                            Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.8,0),NumberSequenceKeypoint.new(1,1)},
                            Parent=Opt})
                        Opt.MouseEnter:Connect(function() tw(Opt,0.15,{TextTransparency=0,TextColor3=P.A1}) end)
                        Opt.MouseLeave:Connect(function()
                            local isSel=s.multi_dropdown and table.find(Library._config._flags[s.flag] or {},val)
                                        or (DrCur.Text==Opt.Text)
                            tw(Opt,0.15,{TextTransparency=isSel and 0 or 0.55,TextColor3=P.TXT})
                        end)
                        Opt.MouseButton1Click:Connect(function()
                            if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={} end
                            if s.multi_dropdown then
                                if table.find(Library._config._flags[s.flag],val) then
                                    Library:remove_table_value(Library._config._flags[s.flag],val)
                                else Library._config._flags[s.flag][#Library._config._flags[s.flag]+1]=val end
                            end
                            DrM:update(val)
                        end)
                        if idx<=maxOpts then DrM._size+=16; DrOps.Size=UDim2.fromOffset(306,DrM._size) end
                    end
                end

                function DrM:New(v)
                    DrW:Destroy(); v.OrderValue=DrW.LayoutOrder; MM._mult-=curDrS
                    return MM:create_dropdown(v)
                end

                if Library:flag_type(s.flag,"string") then DrM:update(Library._config._flags[s.flag])
                else DrM:update(s.options[1]) end

                DrBtn.MouseButton1Click:Connect(function() DrM:unfold_settings() end)
                return DrM
            end

            -- ── Display ───────────────────────────────────
            function MM:create_display(s)
                local ord=grow(s.height or 105)
                local DF=inst("Frame",{Size=UDim2.new(0,326,0,s.height or 105),BackgroundColor3=P.CARD2,
                    BackgroundTransparency=0.1,BorderSizePixel=0,LayoutOrder=ord,Parent=Opts})
                corner(8,DF)
                inst("UIStroke",{Color=P.STROKE,Transparency=0.6,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=DF})
                local DFImg=inst("ImageLabel",{Size=UDim2.new(1,-10,1,-20),AnchorPoint=Vector2.new(0.5,0),
                    Position=UDim2.new(0.5,0,0,4),BackgroundTransparency=1,
                    Image=s.image or "rbxassetid://11835491319",ScaleType=Enum.ScaleType.Fit,Parent=DF})
                local DFLbl=inst("TextLabel",{Text=s.text or "",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=10,TextColor3=P.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-10,0,14),AnchorPoint=Vector2.new(0.5,1),
                    Position=UDim2.new(0.5,0,1,-2),Parent=DF})
                if s.glow then inst("UIStroke",{Thickness=1.5,Color=P.A1,Transparency=0.3,Parent=DFLbl}) end
                return DF
            end

            -- ── Color Picker ──────────────────────────────
            function MM:create_colorpicker(s)
                local ord=grow(28)
                local CpM={}
                local Row=inst("Frame",{Size=UDim2.new(0,326,0,22),BackgroundTransparency=1,LayoutOrder=ord,Parent=Opts})
                inst("TextLabel",{Text=s.title or "Color",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=11,TextColor3=P.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-30,1,0),TextXAlignment=Enum.TextXAlignment.Left,Parent=Row})
                local Prv=inst("TextButton",{Size=UDim2.fromOffset(24,20),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,0,0.5,0),BackgroundColor3=s.default or Color3.new(1,1,1),
                    Text="",Parent=Row})
                corner(5,Prv)
                local Popup=inst("Frame",{Size=UDim2.fromOffset(310,280),AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=P.CARD,Visible=false,ZIndex=9999,
                    Parent=Gui})
                corner(12,Popup); stroke(P.STROKE2,1.5,Popup)
                inst("TextLabel",{Text="Pick Color",FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                    TextSize=13,TextColor3=P.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,28),ZIndex=10000,Parent=Popup})
                local HSB=inst("Frame",{Size=UDim2.fromOffset(188,188),Position=UDim2.new(0,12,0,32),
                    BackgroundColor3=Color3.fromHSV(0,1,1),BorderSizePixel=0,ZIndex=10000,Parent=Popup})
                corner(6,HSB)
                inst("ImageLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                    Image="rbxassetid://4155801252",ZIndex=10001,Parent=HSB})
                local Sel=inst("Frame",{Size=UDim2.fromOffset(12,12),AnchorPoint=Vector2.new(0.5,0.5),
                    BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=10002,Parent=HSB})
                corner(6,Sel)
                local HBar=inst("Frame",{Size=UDim2.fromOffset(18,188),Position=UDim2.new(0,212,0,32),
                    BorderSizePixel=0,ZIndex=10000,Parent=Popup})
                corner(4,HBar)
                local HG=inst("UIGradient",{Rotation=90,Parent=HBar})
                local ks2={}; for i=0,1,0.1 do ks2[#ks2+1]=ColorSequenceKeypoint.new(i,Color3.fromHSV(i,1,1)) end
                HG.Color=ColorSequence.new(ks2)
                local HMk=inst("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=10001,Parent=HBar})
                local ABar=inst("Frame",{Size=UDim2.fromOffset(188,12),Position=UDim2.new(0,12,0,230),
                    BorderSizePixel=0,ZIndex=10000,Parent=Popup})
                corner(2,ABar)
                local AG=inst("UIGradient",{
                    Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)},
                    Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1)),Parent=ABar})
                local AMk=inst("Frame",{Size=UDim2.fromOffset(2,12),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=10001,Parent=ABar})
                local HxL=inst("TextLabel",{Size=UDim2.fromOffset(100,20),Position=UDim2.new(0,12,1,-28),
                    BackgroundTransparency=1,TextColor3=P.A1,Font=Enum.Font.Code,TextSize=12,Text="#FFFFFF",
                    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10002,Parent=Popup})
                local ClBtn=inst("ImageButton",{Image="rbxassetid://10030850935",Size=UDim2.fromOffset(18,18),
                    Position=UDim2.new(1,-24,0,5),BackgroundTransparency=1,ZIndex=10001,Parent=Popup})
                local OkBtn=inst("ImageButton",{Image="rbxassetid://10030902360",Size=UDim2.fromOffset(18,18),
                    Position=UDim2.new(1,-46,0,5),BackgroundTransparency=1,ZIndex=10001,Parent=Popup})
                local h3,sa3,va3,al3=0,1,1,1; local dHS,dH,dA=false,false,false
                local function upCP()
                    local c=Color3.fromHSV(h3,sa3,va3); HSB.BackgroundColor3=Color3.fromHSV(h3,1,1)
                    Sel.Position=UDim2.new(sa3,0,1-va3,0); Prv.BackgroundColor3=c
                    HxL.Text="#"..c:ToHex():upper(); return c
                end
                HSB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHS=true end end)
                HBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dH=true end end)
                ABar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dA=true end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHS=false;dH=false;dA=false end end)
                UIS.InputChanged:Connect(function(i)
                    if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
                    local pp=i.Position
                    if dHS then
                        sa3=math.clamp((pp.X-HSB.AbsolutePosition.X)/HSB.AbsoluteSize.X,0,1)
                        va3=1-math.clamp((pp.Y-HSB.AbsolutePosition.Y)/HSB.AbsoluteSize.Y,0,1); upCP()
                    elseif dH then
                        h3=math.clamp((pp.Y-HBar.AbsolutePosition.Y)/HBar.AbsoluteSize.Y,0,1)
                        HMk.Position=UDim2.new(0,0,h3,0); upCP()
                    elseif dA then
                        al3=math.clamp((pp.X-ABar.AbsolutePosition.X)/ABar.AbsoluteSize.X,0,1)
                        AMk.Position=UDim2.new(al3,0,0,0); upCP()
                    end
                end)
                Prv.MouseButton1Click:Connect(function()
                    Popup.Visible=true; Popup.BackgroundTransparency=1
                    tw(Popup,0.22,{BackgroundTransparency=0})
                end)
                ClBtn.MouseButton1Click:Connect(function() Popup.Visible=false end)
                OkBtn.MouseButton1Click:Connect(function()
                    local c=upCP(); if s.callback then s.callback(c,al3) end; Popup.Visible=false
                end)
                function CpM:Set(c) Prv.BackgroundColor3=c end
                return CpM
            end

            -- ── 3D View ───────────────────────────────────
            function MM:create_3dview(s)
                local ord=grow(240)
                local V3={} 
                local VRow=inst("Frame",{Size=UDim2.new(0,326,0,240),BackgroundTransparency=1,LayoutOrder=ord,Parent=Opts})
                inst("TextLabel",{Text=s.title or "3D View",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=11,TextColor3=P.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,16),TextXAlignment=Enum.TextXAlignment.Left,Parent=VRow})
                local VH=inst("Frame",{Size=UDim2.new(1,0,1,-16),Position=UDim2.new(0,0,0,16),
                    BackgroundColor3=P.CARD2,ClipsDescendants=true,Parent=VRow})
                corner(8,VH)
                local VImg=inst("ImageLabel",{Size=UDim2.fromOffset(130,130),AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=1,
                    Image=s.image or "rbxassetid://5791744848",ScaleType=Enum.ScaleType.Fit,Visible=false,Parent=VH})
                local VP=inst("ViewportFrame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=P.WIN,Visible=false,Parent=VH})
                corner(8,VP)
                local VCam=inst("Camera",{Parent=VP}); VP.CurrentCamera=VCam
                local cObj,is3,bD,cD,oP,mD
                local function showI() if cObj then cObj:Destroy() end; is3=false; VImg.Visible=true; VP.Visible=false end
                local function showM(obj)
                    if cObj then cObj:Destroy() end; VP:ClearAllChildren()
                    obj.Archivable=true; local cl=obj:Clone(); cl.Parent=VP; cObj=cl
                    local cf2,sz; if cl:IsA("Model") then cf2,sz=cl:GetBoundingBox(); oP=cl:GetPivot().Position
                    elseif cl:IsA("BasePart") then cf2,sz=cl.CFrame,cl.Size; oP=cl.Position else return showI() end
                    mD=math.max(sz.X,sz.Y,sz.Z); bD=mD*2.5; cD=bD
                    VCam.Parent=VP; VP.CurrentCamera=VCam
                    VCam.CFrame=CFrame.new(oP+Vector3.new(0,mD/2,cD),oP)
                    VP.Visible=true; VImg.Visible=false; is3=true
                end
                if s.model and (s.model:IsA("Model") or s.model:IsA("BasePart")) then showM(s.model)
                elseif s.meshId and s.texId then
                    local mp=Instance.new("MeshPart"); mp.Size=Vector3.new(5,5,5)
                    mp.MeshId="rbxassetid://"..s.meshId; mp.TextureID="rbxassetid://"..s.texId; showM(mp)
                else showI() end
                local function mkB(img,pos)
                    local b=inst("ImageButton",{Image=img,Size=UDim2.fromOffset(20,20),BackgroundTransparency=0.5,
                        BackgroundColor3=P.CARD,Position=pos,ZIndex=10,Parent=VP})
                    corner(10,b); return b
                end
                local u=mkB("rbxassetid://138007024966757",UDim2.new(0.5,-10,0,3))
                local d=mkB("rbxassetid://13360801719",UDim2.new(0.5,-10,1,-23))
                local l=mkB("rbxassetid://100152237482023",UDim2.new(0,3,0.5,-10))
                local r=mkB("rbxassetid://140701802205656",UDim2.new(1,-23,0.5,-10))
                local zi=mkB("rbxassetid://126943351764139",UDim2.new(1,-68,1,-24))
                local zo=mkB("rbxassetid://110884638624335",UDim2.new(1,-46,1,-24))
                local re=mkB("rbxassetid://6723921202",UDim2.new(1,-24,1,-24))
                local function rot(x2,y2)
                    if is3 and cObj then
                        if cObj:IsA("Model") then cObj:PivotTo(cObj:GetPivot()*CFrame.Angles(0,math.rad(x2),math.rad(y2)))
                        elseif cObj:IsA("BasePart") then cObj.CFrame=cObj.CFrame*CFrame.Angles(0,math.rad(x2),math.rad(y2)) end
                    end
                end
                local function zoom(td)
                    if not(is3 and oP) then return end
                    cD=math.clamp(td,(mD or 5)*0.5,(mD or 5)*6)
                    tw(VCam,0.3,{CFrame=CFrame.new(oP+Vector3.new(0,(mD or 5)/2,cD),oP)})
                end
                u.MouseButton1Click:Connect(function() rot(0,10) end)
                d.MouseButton1Click:Connect(function() rot(0,-10) end)
                l.MouseButton1Click:Connect(function() rot(-10,0) end)
                r.MouseButton1Click:Connect(function() rot(10,0) end)
                zi.MouseButton1Click:Connect(function() zoom(cD-0.5*(mD or 5)) end)
                zo.MouseButton1Click:Connect(function() zoom(cD+0.5*(mD or 5)) end)
                re.MouseButton1Click:Connect(function() if is3 and oP then zoom(bD) end end)
                function V3:SetModel(m) if m then showM(m) end end
                function V3:SetMesh(m2,t2)
                    local mp=Instance.new("MeshPart"); mp.Size=Vector3.new(5,5,5)
                    mp.MeshId="rbxassetid://"..m2; mp.TextureID="rbxassetid://"..t2; showM(mp)
                end
                function V3:SetImage(i) s.image=i; showI() end
                return V3
            end

            -- ── Feature ───────────────────────────────────
            function MM:create_feature(s)
                local ord=grow(20)
                local chk=false
                local FC=inst("Frame",{Size=UDim2.new(0,326,0,16),BackgroundTransparency=1,LayoutOrder=ord,Parent=Opts})
                inst("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Parent=FC})
                local FB=inst("TextButton",{
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=11,Size=UDim2.new(1,-38,0,16),BackgroundColor3=P.CARD2,BackgroundTransparency=0.35,
                    TextColor3=P.TXT,Text="    "..(s.title or "Feature"),AutoButtonColor=false,
                    TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=0.05,Parent=FC})
                corner(4,FB)
                local FR=inst("Frame",{Size=UDim2.fromOffset(38,16),BackgroundTransparency=1,Parent=FC})
                inst("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,2),
                    HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder,Parent=FR})
                local FKL=inst("TextLabel",{
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    Size=UDim2.fromOffset(18,16),BackgroundColor3=P.ELEM,BackgroundTransparency=0.15,
                    TextColor3=P.TXT2,TextSize=8,LayoutOrder=2,Parent=FR})
                corner(3,FKL)
                inst("UIStroke",{Color=P.STROKE2,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=FKL})
                local FKB=inst("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextTransparency=1,Parent=FKL})
                if not Library._config._flags then Library._config._flags={} end
                if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={checked=false,BIND=s.default or "Unknown"} end
                chk=Library._config._flags[s.flag].checked
                FKL.Text=Library._config._flags[s.flag].BIND=="Unknown" and "..." or Library._config._flags[s.flag].BIND
                local UseF=nil
                if not s.disablecheck then
                    local FCK=inst("TextButton",{Size=UDim2.fromOffset(18,16),
                        BackgroundColor3=chk and P.A1 or P.ELEM,BackgroundTransparency=chk and 0.2 or 0.15,
                        Text="",LayoutOrder=1,Parent=FR})
                    corner(3,FCK)
                    local FCKS=inst("UIStroke",{Color=chk and P.A1 or P.STROKE2,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=FCK})
                    local function tog()
                        chk=not chk
                        tw(FCK,0.22,{BackgroundColor3=chk and P.A1 or P.ELEM})
                        tw(FCKS,0.22,{Color=chk and P.A1 or P.STROKE2})
                        Library._config._flags[s.flag].checked=chk
                        Cfg:save(game.GameId,Library._config); if s.callback then s.callback(chk) end
                    end
                    UseF=tog; FCK.MouseButton1Click:Connect(tog)
                else UseF=function() if s.button_callback then s.button_callback() end end end
                FKB.MouseButton1Click:Connect(function()
                    FKL.Text="..."
                    local c; c=UIS.InputBegan:Connect(function(inp,gp)
                        if gp then return end
                        if inp.UserInputType==Enum.UserInputType.Keyboard then
                            local nk=inp.KeyCode.Name
                            Library._config._flags[s.flag].BIND=nk
                            FKL.Text=nk~="Unknown" and nk or "..."
                            Cfg:save(game.GameId,Library._config); c:Disconnect()
                        elseif inp.UserInputType==Enum.UserInputType.MouseButton3 then
                            Library._config._flags[s.flag].BIND="Unknown"
                            FKL.Text="..."; Cfg:save(game.GameId,Library._config); c:Disconnect()
                        end
                    end)
                end)
                Conn["fkbp_"..s.flag]=UIS.InputBegan:Connect(function(inp,gp)
                    if gp then return end
                    if inp.UserInputType==Enum.UserInputType.Keyboard then
                        if inp.KeyCode.Name==Library._config._flags[s.flag].BIND then UseF() end
                    end
                end)
                FB.MouseButton1Click:Connect(function() if s.button_callback then s.button_callback() end end)
                FB.MouseEnter:Connect(function() tw(FB,0.18,{BackgroundColor3=P.HOVER}) end)
                FB.MouseLeave:Connect(function() tw(FB,0.18,{BackgroundColor3=P.CARD2}) end)
                if not s.disablecheck then s.callback(chk) end
                return FC
            end

            return MM
        end -- create_module

        return TM
    end -- create_tab

    -- ── Insert to toggle ──────────────────────────────────
    Conn["vis"]=UIS.InputBegan:Connect(function(inp,proc)
        if inp.KeyCode~=Enum.KeyCode.Insert then return end
        self._ui_open=not self._ui_open; self:change_visiblity(self._ui_open)
    end)
    MBt.MouseButton1Click:Connect(function()
        self._ui_open=not self._ui_open; self:change_visiblity(self._ui_open)
    end)

    return self
end -- _create_ui

return Library
