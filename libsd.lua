--[[
  ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
  ██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
  ██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
  ██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
  ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝
  UI Library v3 — Teal / Coral — Sidebar Layout
  Full GG/VicoX API compatible
]]

getgenv().GG = {
    Language = {
        CheckboxEnabled  = "Enabled",  CheckboxDisabled = "Disabled",
        SliderValue      = "Value",    DropdownSelect   = "Select",
        DropdownNone     = "None",     DropdownSelected = "Selected",
        ButtonClick      = "Click",    TextboxEnter     = "Enter",
        ModuleEnabled    = "Enabled",  ModuleDisabled   = "Disabled",
        TabGeneral       = "General",  TabSettings      = "Settings",
        Loading          = "Loading...", Error          = "Error",
        Success          = "Success"
    }
}
local SelectedLanguage = GG.Language

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  COLORS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local C = {
    WIN    = Color3.fromRGB(7,   12,  15),
    SIDE   = Color3.fromRGB(10,  16,  20),
    CARD   = Color3.fromRGB(13,  20,  26),
    CARD2  = Color3.fromRGB(18,  27,  35),
    ELEM   = Color3.fromRGB(24,  36,  46),
    HOVER  = Color3.fromRGB(32,  46,  58),

    ACC    = Color3.fromRGB(0,   210, 190),   -- teal
    ACC2   = Color3.fromRGB(255, 110,  80),   -- coral
    ACC3   = Color3.fromRGB(80,  190, 255),   -- sky

    SDIV   = Color3.fromRGB(22,  36,  46),
    STR    = Color3.fromRGB(30,  50,  65),
    STR2   = Color3.fromRGB(45,  75,  95),

    TXT    = Color3.fromRGB(230, 245, 245),
    TXT2   = Color3.fromRGB(140, 175, 185),
    TXT3   = Color3.fromRGB(75,  110, 125),

    ON     = Color3.fromRGB(0,   210, 190),
    OFF    = Color3.fromRGB(24,  36,  46),

    OK     = Color3.fromRGB(60,  220, 130),
    ERR    = Color3.fromRGB(255,  70,  90),
    WARN   = Color3.fromRGB(255, 185,  50),
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SERVICES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local UIS    = cloneref(game:GetService("UserInputService"))
local CP     = cloneref(game:GetService("ContentProvider"))
local TS     = cloneref(game:GetService("TweenService"))
local HTTP   = cloneref(game:GetService("HttpService"))
local TXTS   = cloneref(game:GetService("TextService"))
local LIGHT  = cloneref(game:GetService("Lighting"))
local PLR    = cloneref(game:GetService("Players"))
local CG     = cloneref(game:GetService("CoreGui"))
local DEB    = cloneref(game:GetService("Debris"))
local mouse  = PLR.LocalPlayer:GetMouse()

for _, n in {"Phantom","PhantomNotif"} do
    local o = CG:FindFirstChild(n); if o then DEB:AddItem(o,0) end
end
if not isfolder("Phantom") then makefolder("Phantom") end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  CONNECTIONS TABLE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Conns = {}
function Conns:off(k) if self[k] then self[k]:Disconnect(); self[k]=nil end end
function Conns:offAll()
    for k,v in pairs(self) do if type(v)~="function" then pcall(function() v:Disconnect() end) end end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  UTILITIES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local function tw(o,t,p,s,d)
    TS:Create(o,TweenInfo.new(t,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p):Play()
end
local function mk(cls,pr,par)
    local o=Instance.new(cls); for k,v in pairs(pr or {}) do o[k]=v end
    if par then o.Parent=par end; return o
end
local function corner(r,p) mk("UICorner",{CornerRadius=UDim.new(0,r),Parent=p}) end
local function uistroke(c,t,p) mk("UIStroke",{Color=c,Thickness=t or 1,Transparency=0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p}) end
local function pad(top,left,par) mk("UIPadding",{PaddingTop=UDim.new(0,top or 0),PaddingLeft=UDim.new(0,left or 0),Parent=par}) end
local function uill(gap,ha,par)
    mk("UIListLayout",{Padding=UDim.new(0,gap or 0),
        HorizontalAlignment=ha or Enum.HorizontalAlignment.Left,
        SortOrder=Enum.SortOrder.LayoutOrder,Parent=par})
end
local function fadeH(p)
    mk("UIGradient",{Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.1,0),
        NumberSequenceKeypoint.new(0.9,0),NumberSequenceKeypoint.new(1,1)},Parent=p})
end

function convertStringToTable(s)
    local r={}; for v in s:gmatch("([^,]+)") do r[#r+1]=v:match("^%s*(.-)%s*$") end; return r
end
function convertTableToString(t) return table.concat(t,", ") end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ACRYLIC BLUR
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur
function AcrylicBlur.new(obj)
    local self=setmetatable({_o=obj,_f=nil,_fr=nil,_r=nil},AcrylicBlur)
    local dof=LIGHT:FindFirstChild("PhanBlur") or Instance.new("DepthOfFieldEffect")
    dof.FarIntensity=0;dof.FocusDistance=0.05;dof.InFocusRadius=0.1;dof.NearIntensity=1
    dof.Name="PhanBlur";dof.Parent=LIGHT
    local old=workspace.CurrentCamera:FindFirstChild("PhanBlur"); if old then DEB:AddItem(old,0) end
    self._f=mk("Folder",{Name="PhanBlur"},workspace.CurrentCamera)
    local p=Instance.new("Part");p.Name="R";p.Color=Color3.new(0,0,0);p.Material=Enum.Material.Glass
    p.Size=Vector3.new(1,1,0);p.Anchored=true;p.CanCollide=false;p.CanQuery=false
    p.Locked=true;p.CastShadow=false;p.Transparency=0.98;p.Parent=self._f
    local sm=Instance.new("SpecialMesh");sm.MeshType=Enum.MeshType.Brick;sm.Offset=Vector3.new(0,0,-.000001);sm.Parent=p;self._r=p
    self._fr=mk("Frame",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(.5,0,.5,0),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1},obj)
    local function upd()
        local cam=workspace.CurrentCamera
        local function v2w(l) local r2=cam:ScreenPointToRay(l.X,l.Y); return r2.Origin+r2.Direction*.001 end
        local off=math.max(8,cam.ViewportSize.Y/45)
        local sz=self._fr.AbsoluteSize-Vector2.new(off,off)
        local pt=self._fr.AbsolutePosition+Vector2.new(off/2,off/2)
        local tl3,tr3,br3=v2w(pt),v2w(pt+Vector2.new(sz.X,0)),v2w(pt+sz)
        if not self._r then return end
        self._r.CFrame=CFrame.fromMatrix((tl3+br3)/2,cam.CFrame.XVector,cam.CFrame.YVector,cam.CFrame.ZVector)
        self._r.Mesh.Scale=Vector3.new((tr3-tl3).Magnitude,(tr3-br3).Magnitude,0)
    end
    Conns["bl_cf"]=workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(upd)
    Conns["bl_vp"]=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(upd)
    Conns["bl_ap"]=self._fr:GetPropertyChangedSignal("AbsolutePosition"):Connect(upd)
    Conns["bl_as"]=self._fr:GetPropertyChangedSignal("AbsoluteSize"):Connect(upd)
    task.spawn(upd)
    local gs=UserSettings().GameSettings
    if gs.SavedQualityLevel.Value<8 then self._r.Transparency=1 end
    Conns["bl_ql"]=gs:GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
        self._r.Transparency=UserSettings().GameSettings.SavedQualityLevel.Value>=8 and 0.98 or 1
    end)
    return self
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  CONFIG
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Cfg={}
function Cfg:save(n,c) pcall(function() writefile("Phantom/"..n..".json",HTTP:JSONEncode(c)) end) end
function Cfg:load(n)
    local ok,r=pcall(function()
        if not isfile("Phantom/"..n..".json") then return nil end
        local d=readfile("Phantom/"..n..".json"); if not d then return nil end
        return HTTP:JSONDecode(d)
    end)
    return (ok and r) or {_flags={},_keybinds={},_library={}}
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  NOTIFICATION
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local NGui=mk("ScreenGui",{Name="PhantomNotif",ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=9999,IgnoreGuiInset=true},CG)
local NH=mk("Frame",{Size=UDim2.new(0,290,1,0),Position=UDim2.new(1,-298,0,0),BackgroundTransparency=1},NGui)
mk("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,VerticalAlignment=Enum.VerticalAlignment.Bottom,
    SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=NH})
mk("UIPadding",{PaddingBottom=UDim.new(0,14),Parent=NH})
local nC=0

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  LIBRARY
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Library={
    _config      = Cfg:load(tostring(game.GameId)),
    _choosing_kb = false,
    _device      = nil,
    _ui_open     = true,
    _ui_scale    = 1,
    _ui_loaded   = false,
    _ui          = nil,
    _dragging    = false,
    _drag_start  = nil,
    _drag_pos    = nil,
    _tab_btns    = {},
    _tab         = 0,
    _active_tab  = nil,
}
Library.__index = Library

-- ── SendNotification ─────────────────────────────────────
function Library.SendNotification(s)
    nC+=1
    local ac=s.type=="error" and C.ERR or s.type=="success" and C.OK or s.type=="warning" and C.WARN or C.ACC
    local W=mk("Frame",{Name="N"..nC,Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,
        ClipsDescendants=false,LayoutOrder=nC,Position=UDim2.new(1.3,0,0,0)},NH)
    local Card=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.CARD,BorderSizePixel=0},W)
    corner(9,Card)
    mk("UIStroke",{Color=ac,Transparency=0.5,Thickness=1.2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=Card})
    mk("Frame",{Size=UDim2.new(0,3,0,26),AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,7,0.5,0),
        BackgroundColor3=ac,BorderSizePixel=0,Parent=Card})
    local IB=mk("Frame",{Size=UDim2.fromOffset(26,26),AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,14,0.5,0),BackgroundColor3=ac,BackgroundTransparency=0.8,BorderSizePixel=0},Card)
    corner(13,IB)
    mk("ImageLabel",{Image=s.icon or "rbxassetid://10653372143",Size=UDim2.fromOffset(14,14),
        AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,
        ImageColor3=Color3.new(1,1,1),ScaleType=Enum.ScaleType.Fit,ZIndex=2,Parent=IB})
    mk("TextLabel",{Text=s.title or "Phantom",
        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
        TextSize=12,TextColor3=C.TXT,BackgroundTransparency=1,
        Size=UDim2.new(1,-56,0,14),Position=UDim2.new(0,50,0,8),
        TextXAlignment=Enum.TextXAlignment.Left,Parent=Card})
    mk("TextLabel",{Text=s.text or "",
        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
        TextSize=10,TextColor3=C.TXT2,BackgroundTransparency=1,
        Size=UDim2.new(1,-56,0,24),Position=UDim2.new(0,50,0,24),
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=Card})
    local PBg=mk("Frame",{Size=UDim2.new(1,-14,0,2),AnchorPoint=Vector2.new(0.5,1),
        Position=UDim2.new(0.5,0,1,-4),BackgroundColor3=C.ELEM,BorderSizePixel=0,ZIndex=2},Card)
    corner(1,PBg)
    local PF=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=ac,BorderSizePixel=0,ZIndex=3},PBg)
    corner(1,PF)
    task.spawn(function()
        tw(W,0.38,{Position=UDim2.new(0,0,0,0)})
        local dur=s.duration or 5; task.wait(0.42)
        tw(PF,dur-0.5,{Size=UDim2.new(0,0,1,0)},Enum.EasingStyle.Linear,Enum.EasingDirection.In)
        task.wait(dur-0.5)
        tw(Card,0.28,{BackgroundTransparency=1}); tw(W,0.28,{Position=UDim2.new(1.3,0,0,0)})
        task.wait(0.3); W:Destroy()
    end)
end

-- ── Library.new ──────────────────────────────────────────
function Library.new()
    local self=setmetatable({},Library)
    self:_create_ui()
    return self
end

function Library:get_screen_scale() self._ui_scale=workspace.CurrentCamera.ViewportSize.X/1400 end
function Library:get_device()
    if not UIS.TouchEnabled and UIS.KeyboardEnabled then self._device="PC"
    elseif UIS.TouchEnabled then self._device="Mobile"
    else self._device="Unknown" end
end
function Library:removed(fn) self._ui.AncestryChanged:Once(fn) end
function Library:flag_type(flag,t)
    if not Library._config._flags[flag] then return end
    return typeof(Library._config._flags[flag])==t
end
function Library:remove_table_value(tbl,val)
    for i,v in ipairs(tbl) do if v==val then table.remove(tbl,i); break end end
end

-- ═══════════════════════════════════════════
--  _create_ui  (Sidebar layout)
-- ═══════════════════════════════════════════
-- Layout:
--   Window 700 x 480
--   Left sidebar: 155px  (logo + tabs + discord)
--   Vertical divider: 1px
--   Content area: 540px  (two ScrollingFrame columns)
-- ═══════════════════════════════════════════
local WIN_W, WIN_H  = 700, 480
local SIDE_W        = 155
local MOD_W         = 248   -- width of each module card
local HEADER_H      = 78    -- module header height

function Library:_create_ui()
    local Gui=mk("ScreenGui",{Name="Phantom",ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling},CG)
    self._ui=Gui

    -- ── Window ───────────────────────────────────────────
    local Win=mk("Frame",{
        Name="Win",AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,0,0,0),
        BackgroundColor3=C.WIN,BackgroundTransparency=0.05,
        BorderSizePixel=0,ClipsDescendants=true,Active=true
    },Gui)
    corner(12,Win)
    mk("UIStroke",{Color=C.STR2,Transparency=0.35,Thickness=1.5,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=Win})
    local UIScale=mk("UIScale",{},Win)

    -- ── Sidebar ──────────────────────────────────────────
    local Sidebar=mk("Frame",{
        Name="Sidebar",Size=UDim2.new(0,SIDE_W,1,0),
        BackgroundColor3=C.SIDE,BackgroundTransparency=0,BorderSizePixel=0
    },Win)

    -- sidebar right border
    local SDiv=mk("Frame",{
        Size=UDim2.new(0,1,1,0),AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,0,0,0),BackgroundColor3=C.STR,
        BackgroundTransparency=0.2,BorderSizePixel=0
    },Sidebar)

    -- Logo area
    local LogoArea=mk("Frame",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1},Sidebar)
    local LogoIc=mk("ImageLabel",{
        Image="rbxassetid://10653372143",Size=UDim2.fromOffset(22,22),
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,14,0.5,0),
        BackgroundTransparency=1,ImageColor3=C.ACC,ScaleType=Enum.ScaleType.Fit
    },LogoArea)
    -- pulse logo color
    task.spawn(function()
        while LogoIc and LogoIc.Parent do
            tw(LogoIc,1.8,{ImageColor3=C.ACC2},Enum.EasingStyle.Sine)
            task.wait(1.8); tw(LogoIc,1.8,{ImageColor3=C.ACC},Enum.EasingStyle.Sine); task.wait(1.8)
        end
    end)
    local LogoLbl=mk("TextLabel",{
        Text="PHANTOM",
        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
        TextSize=13,TextColor3=C.TXT,BackgroundTransparency=1,
        Size=UDim2.new(0,80,0,16),Position=UDim2.new(0,42,0.5,-8),
        TextXAlignment=Enum.TextXAlignment.Left
    },LogoArea)
    mk("UIGradient",{Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,C.ACC),ColorSequenceKeypoint.new(1,C.ACC2)
    },Parent=LogoLbl})

    -- Separator line under logo
    local SepLine=mk("Frame",{
        Size=UDim2.new(1,-20,0,1),AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,52),BackgroundColor3=C.STR,
        BackgroundTransparency=0.1,BorderSizePixel=0
    },Sidebar)

    -- Tab list (scrollable vertical)
    local TabList=mk("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-110),Position=UDim2.new(0,0,0,58),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=0,ScrollBarImageTransparency=1,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.new(0,0,0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y
    },Sidebar)
    uill(4,Enum.HorizontalAlignment.Left,TabList)
    pad(6,0,TabList)

    -- Active tab indicator bar (left accent)
    local TabBar=mk("Frame",{
        Name="TabBar",Size=UDim2.new(0,3,0,28),
        Position=UDim2.new(0,0,0,70),
        BackgroundColor3=C.ACC,BackgroundTransparency=0,BorderSizePixel=0
    },Sidebar)
    corner(2,TabBar)

    -- Sidebar bottom: Discord button
    local DiscordBtn=mk("TextButton",{
        Size=UDim2.new(1,-20,0,34),AnchorPoint=Vector2.new(0.5,1),
        Position=UDim2.new(0.5,0,1,-12),
        BackgroundColor3=C.CARD2,BackgroundTransparency=0.1,
        BorderSizePixel=0,Text="",AutoButtonColor=false
    },Sidebar)
    corner(8,DiscordBtn)
    mk("UIStroke",{Color=Color3.fromRGB(88,101,242),Transparency=0.5,Thickness=1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=DiscordBtn})
    -- discord left bar
    local DB_bar=mk("Frame",{Size=UDim2.fromOffset(3,18),AnchorPoint=Vector2.new(0,0.5),
        Position=UDim2.new(0,7,0.5,0),BackgroundColor3=Color3.fromRGB(88,101,242),
        BorderSizePixel=0},DiscordBtn)
    corner(2,DB_bar)
    mk("ImageLabel",{Image="rbxassetid://112538196670712",Size=UDim2.fromOffset(14,14),
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,15,0.5,0),
        BackgroundTransparency=1,ImageColor3=Color3.fromRGB(140,155,255)},DiscordBtn)
    mk("TextLabel",{Text="Join Discord",
        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
        TextSize=11,TextColor3=Color3.fromRGB(200,210,255),BackgroundTransparency=1,
        Size=UDim2.new(1,-38,1,0),Position=UDim2.new(0,34,0,0),
        TextXAlignment=Enum.TextXAlignment.Left},DiscordBtn)
    DiscordBtn.MouseEnter:Connect(function() tw(DiscordBtn,0.2,{BackgroundColor3=C.HOVER}) end)
    DiscordBtn.MouseLeave:Connect(function() tw(DiscordBtn,0.2,{BackgroundColor3=C.CARD2}) end)
    DiscordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/gngstore")
        Library.SendNotification({title="Discord",text="Invite link copied!",icon="rbxassetid://112538196670712",duration=4,type="success"})
    end)

    -- ── Content area (right of sidebar) ──────────────────
    local CA=mk("Frame",{
        Name="CA",Size=UDim2.new(1,-SIDE_W-1,1,0),
        Position=UDim2.new(0,SIDE_W+1,0,0),
        BackgroundTransparency=1
    },Win)

    -- Sections folder
    local Sects=mk("Folder",{Name="Sects"},CA)

    -- ── Drag (on sidebar top area) ────────────────────────
    LogoArea.Active=true
    LogoArea.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            self._dragging=true; self._drag_start=inp.Position; self._drag_pos=Win.Position
            Conns["de"]=inp.Changed:Connect(function()
                if inp.UserInputState==Enum.UserInputState.End then Conns:off("de"); self._dragging=false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not self._dragging then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local d=inp.Position-self._drag_start
            tw(Win,0.1,{Position=UDim2.new(self._drag_pos.X.Scale,self._drag_pos.X.Offset+d.X,
                self._drag_pos.Y.Scale,self._drag_pos.Y.Offset+d.Y)})
        end
    end)

    self:removed(function() self._ui=nil; Conns:offAll() end)

    -- ── Methods ───────────────────────────────────────────
    function self:UIVisiblity() Gui.Enabled=not Gui.Enabled end
    function self:Update1Run(a) Win.BackgroundTransparency=(a=="nil") and 0.05 or (tonumber(a) or 0.05) end

    function self:change_visiblity(state)
        if state then tw(Win,0.42,{Size=UDim2.fromOffset(WIN_W,WIN_H)})
        else tw(Win,0.42,{Size=UDim2.fromOffset(SIDE_W,52)}) end
    end

    function self:load()
        local imgs={}
        for _,o in Gui:GetDescendants() do if o:IsA("ImageLabel") then imgs[#imgs+1]=o end end
        CP:PreloadAsync(imgs); self:get_device()
        if self._device~="PC" then
            self:get_screen_scale(); UIScale.Scale=self._ui_scale
            Conns["sc"]=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                self:get_screen_scale(); UIScale.Scale=self._ui_scale
            end)
        end
        tw(Win,0.5,{Size=UDim2.fromOffset(WIN_W,WIN_H)})
        AcrylicBlur.new(Win); self._ui_loaded=true
    end

    -- ── Tab switching ─────────────────────────────────────
    function self:update_tabs(activeBtn)
        local tabH = 36
        for i,btn in ipairs(self._tab_btns) do
            if btn==activeBtn then
                tw(btn,0.3,{BackgroundTransparency=0.82,BackgroundColor3=C.ACC})
                tw(btn:FindFirstChildOfClass("TextLabel"),0.3,{TextColor3=C.TXT,TextTransparency=0})
                tw(btn:FindFirstChild("BtnIc"),0.3,{ImageColor3=C.ACC,ImageTransparency=0.05})
                -- move tab bar indicator
                local yOff = 58 + (i-1)*(tabH+4) + (tabH/2) - 14
                tw(TabBar,0.38,{Position=UDim2.new(0,0,0,yOff)})
            else
                tw(btn,0.3,{BackgroundTransparency=1,BackgroundColor3=C.CARD})
                tw(btn:FindFirstChildOfClass("TextLabel"),0.3,{TextColor3=C.TXT3,TextTransparency=0.1})
                tw(btn:FindFirstChild("BtnIc"),0.3,{ImageColor3=C.TXT3,ImageTransparency=0.5})
            end
        end
    end

    function self:update_sects(L,R)
        for _,o in Sects:GetChildren() do o.Visible=(o==L or o==R) end
    end

    -- ═══════════════════════════════════════
    --  create_tab
    -- ═══════════════════════════════════════
    function self:create_tab(title, icon)
        local TM={}
        local firstTab=#self._tab_btns==0

        -- Tab button in sidebar
        local TabBtn=mk("TextButton",{
            Name="Tab",LayoutOrder=self._tab,
            Size=UDim2.new(1,-10,0,36),
            BackgroundColor3=C.CARD,BackgroundTransparency=1,
            BorderSizePixel=0,Text="",AutoButtonColor=false,
        },TabList)
        corner(7,TabBtn)

        mk("ImageLabel",{Name="BtnIc",Image=icon,
            Size=UDim2.fromOffset(14,14),AnchorPoint=Vector2.new(0,0.5),
            Position=UDim2.new(0,12,0.5,0),BackgroundTransparency=1,
            ImageColor3=C.TXT3,ImageTransparency=0.5,ScaleType=Enum.ScaleType.Fit},TabBtn)
        mk("TextLabel",{Text=title,
            FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
            TextSize=12,TextColor3=C.TXT3,TextTransparency=0.1,BackgroundTransparency=1,
            Size=UDim2.new(1,-32,1,0),AnchorPoint=Vector2.new(0,0.5),
            Position=UDim2.new(0,32,0.5,0),TextXAlignment=Enum.TextXAlignment.Left},TabBtn)

        self._tab_btns[#self._tab_btns+1]=TabBtn

        -- Content sections (two columns)
        local colW = math.floor((WIN_W-SIDE_W-2)/2) - 8  -- ~263

        local LS=mk("ScrollingFrame",{
            Name="LS",Size=UDim2.new(0,colW,1,-8),
            Position=UDim2.new(0,4,0,4),
            BackgroundTransparency=1,BorderSizePixel=0,
            ScrollBarThickness=0,ScrollBarImageTransparency=1,
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            CanvasSize=UDim2.new(0,0,0,0),
            Selectable=false,Visible=false
        },Sects)
        uill(8,Enum.HorizontalAlignment.Center,LS); pad(4,0,LS)

        local RS=mk("ScrollingFrame",{
            Name="RS",Size=UDim2.new(0,colW,1,-8),
            Position=UDim2.new(0.5,4,0,4),
            BackgroundTransparency=1,BorderSizePixel=0,
            ScrollBarThickness=0,ScrollBarImageTransparency=1,
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            CanvasSize=UDim2.new(0,0,0,0),
            Selectable=false,Visible=false
        },Sects)
        uill(8,Enum.HorizontalAlignment.Center,RS); pad(4,0,RS)

        self._tab+=1

        if firstTab then self:update_tabs(TabBtn); self:update_sects(LS,RS) end

        TabBtn.MouseButton1Click:Connect(function()
            self:update_tabs(TabBtn); self:update_sects(LS,RS)
        end)
        TabBtn.MouseEnter:Connect(function()
            if TabBtn.BackgroundTransparency~=0.82 then tw(TabBtn,0.15,{BackgroundTransparency=0.92}) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if TabBtn.BackgroundTransparency~=0.82 then tw(TabBtn,0.15,{BackgroundTransparency=1}) end
        end)

        -- ═══════════════════════════════════
        --  create_module
        -- ═══════════════════════════════════
        -- IMPORTANT: _state defaults TRUE so content is visible immediately
        function TM:create_module(s)
            local MM={_state=true, _size=0, _mult=0}
            local eOrd=0

            local sec=(s.section=="right") and RS or LS

            -- Module card
            local Mod=mk("Frame",{
                Name="Mod",Size=UDim2.new(0,MOD_W,0,HEADER_H),
                BackgroundColor3=C.CARD,BackgroundTransparency=0.05,
                BorderSizePixel=0,ClipsDescendants=true
            },sec)
            corner(9,Mod)
            local ModSt=mk("UIStroke",{Color=C.STR,Transparency=0.4,Thickness=1.2,
                ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=Mod})
            uill(0,Enum.HorizontalAlignment.Left,Mod)

            -- left accent strip
            local Strip=mk("Frame",{
                Size=UDim2.fromOffset(3,24),AnchorPoint=Vector2.new(0,0.5),
                Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.ACC,
                BorderSizePixel=0,ZIndex=4
            },Mod)
            corner(2,Strip)

            -- subtle teal glow wash (left fade)
            local GW=mk("Frame",{
                Size=UDim2.new(0,70,1,0),BackgroundColor3=C.ACC,
                BackgroundTransparency=0.93,BorderSizePixel=0,ZIndex=0
            },Mod)
            corner(9,GW)
            mk("UIGradient",{Transparency=NumberSequence.new{
                NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)},Parent=GW})

            -- Header (clickable to expand/collapse)
            local Head=mk("TextButton",{
                Name="Head",Size=UDim2.new(1,0,0,HEADER_H),
                BackgroundTransparency=1,Text="",AutoButtonColor=false,
                BorderSizePixel=0,LayoutOrder=1
            },Mod)

            -- Module title
            local MTit=mk("TextLabel",{
                Text=(not s.rich) and (s.title or "Module") or "",
                FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                TextSize=13,TextColor3=C.TXT,TextTransparency=0.05,
                BackgroundTransparency=1,Size=UDim2.new(0,185,0,15),
                AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,16,0.26,0),
                TextXAlignment=Enum.TextXAlignment.Left
            },Head)
            if s.rich then MTit.RichText=true; MTit.Text=s.richtext or "Module" end

            -- Description
            mk("TextLabel",{
                Text=s.description or "",
                FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
                TextSize=10,TextColor3=C.TXT2,TextTransparency=0.1,
                BackgroundTransparency=1,Size=UDim2.new(0,180,0,11),
                AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,16,0.5,0),
                TextXAlignment=Enum.TextXAlignment.Left
            },Head)

            -- Toggle switch
            local TBg=mk("Frame",{
                Size=UDim2.fromOffset(30,16),AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-10,0.76,0),BackgroundColor3=C.ACC,  -- ON by default
                BorderSizePixel=0
            },Head)
            corner(8,TBg)
            local TDot=mk("Frame",{
                Size=UDim2.fromOffset(12,12),AnchorPoint=Vector2.new(0,0.5),
                Position=UDim2.new(0,16,0.5,0),   -- ON position by default
                BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0
            },TBg)
            corner(6,TDot)

            -- Keybind badge
            local KB=mk("Frame",{
                Size=UDim2.fromOffset(36,14),AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-46,0.76,0),
                BackgroundColor3=C.ELEM,BackgroundTransparency=0.15,BorderSizePixel=0
            },Head)
            corner(4,KB)
            mk("UIStroke",{Color=C.STR2,Transparency=0.5,Thickness=1,
                ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=KB})
            local KBLbl=mk("TextLabel",{Text="None",
                FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                TextSize=8,TextColor3=C.TXT2,BackgroundTransparency=1,
                Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Center},KB)

            -- Header bottom divider
            local HDv=mk("Frame",{Size=UDim2.new(1,0,0,1),AnchorPoint=Vector2.new(0.5,1),
                Position=UDim2.new(0.5,0,1,0),BackgroundColor3=C.STR,
                BackgroundTransparency=0.2,BorderSizePixel=0},Head)
            fadeH(HDv)

            -- Options container
            local Opts=mk("Frame",{
                Name="Options",Size=UDim2.new(1,0,0,0),
                BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=2
            },Mod)
            pad(8,0,Opts)
            uill(5,Enum.HorizontalAlignment.Center,Opts)

            -- ── change_state ─────────────────────────────
            function MM:change_state(state)
                self._state=state
                if state then
                    tw(Mod,0.4,{Size=UDim2.fromOffset(MOD_W,HEADER_H+self._size+self._mult)})
                    tw(TBg,0.35,{BackgroundColor3=C.ON}); tw(TDot,0.35,{BackgroundColor3=Color3.new(1,1,1),Position=UDim2.new(0,16,0.5,0)})
                    tw(Strip,0.35,{BackgroundColor3=C.ACC}); tw(ModSt,0.35,{Color=C.ACC,Transparency=0.55})
                else
                    tw(Mod,0.4,{Size=UDim2.fromOffset(MOD_W,HEADER_H)})
                    tw(TBg,0.35,{BackgroundColor3=C.OFF}); tw(TDot,0.35,{BackgroundColor3=C.TXT3,Position=UDim2.new(0,2,0.5,0)})
                    tw(Strip,0.35,{BackgroundColor3=C.STR2}); tw(ModSt,0.35,{Color=C.STR,Transparency=0.4})
                end
                Library._config._flags[s.flag]=self._state
                Cfg:save(game.GameId,Library._config); s.callback(self._state)
            end

            function MM:connect_keybind()
                if not Library._config._keybinds[s.flag] then return end
                Conns[s.flag.."_kb"]=UIS.InputBegan:Connect(function(inp,proc)
                    if proc then return end
                    if tostring(inp.KeyCode)~=Library._config._keybinds[s.flag] then return end
                    self:change_state(not self._state)
                end)
            end
            function MM:scale_keybind(empty)
                if Library._config._keybinds[s.flag] and not empty then
                    local ks=Library._config._keybinds[s.flag]:gsub("Enum.KeyCode.","")
                    local fp=Instance.new("GetTextBoundsParams"); fp.Text=ks
                    fp.Font=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                    fp.Size=8; fp.Width=10000
                    local fs=TXTS:GetTextBoundsAsync(fp)
                    KB.Size=UDim2.fromOffset(fs.X+10,14)
                else KB.Size=UDim2.fromOffset(36,14) end
            end

            -- load saved flag
            if Library:flag_type(s.flag,"boolean") then
                if Library._config._flags[s.flag]==false then
                    MM._state=false; TBg.BackgroundColor3=C.OFF
                    TDot.BackgroundColor3=C.TXT3; TDot.Position=UDim2.new(0,2,0.5,0)
                    Strip.BackgroundColor3=C.STR2; ModSt.Color=C.STR; ModSt.Transparency=0.4
                else
                    s.callback(true)
                end
            else
                s.callback(true)   -- default call with true
            end

            if Library._config._keybinds[s.flag] then
                KBLbl.Text=Library._config._keybinds[s.flag]:gsub("Enum.KeyCode.","")
                MM:connect_keybind(); MM:scale_keybind()
            end

            -- middle-click keybind
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
                        if Conns[s.flag.."_kb"] then Conns:off(s.flag.."_kb") end
                        c:Disconnect(); Library._choosing_kb=false; return
                    end
                    c:Disconnect(); Library._config._keybinds[s.flag]=tostring(ki.KeyCode)
                    Cfg:save(game.GameId,Library._config)
                    if Conns[s.flag.."_kb"] then Conns:off(s.flag.."_kb") end
                    MM:connect_keybind(); MM:scale_keybind(); Library._choosing_kb=false
                    KBLbl.Text=Library._config._keybinds[s.flag]:gsub("Enum.KeyCode.","")
                end)
            end)
            Head.MouseButton1Click:Connect(function() MM:change_state(not MM._state) end)

            -- ── grow helper ───────────────────────────────
            -- Called every time an element is added.
            -- Because _state=true by default, module expands immediately.
            local function grow(extra)
                eOrd+=1
                if MM._size==0 then MM._size=8 end
                MM._size+=extra
                -- ALWAYS resize (state starts true)
                if MM._state then
                    Mod.Size=UDim2.fromOffset(MOD_W,HEADER_H+MM._size+MM._mult)
                end
                Opts.Size=UDim2.fromOffset(MOD_W,MM._size)
                return eOrd
            end

            -- ════════════════ ELEMENTS ════════════════════

            -- ── Paragraph ────────────────────────────────
            function MM:create_paragraph(s)
                local ord=grow(s.customScale or 56)
                local Pf=mk("Frame",{Size=UDim2.new(0,MOD_W-14,0,28),BackgroundColor3=C.CARD2,
                    BackgroundTransparency=0.1,BorderSizePixel=0,
                    AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=ord},Opts)
                corner(6,Pf)
                mk("TextLabel",{Text=s.title or "",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                    TextSize=11,TextColor3=C.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-12,0,14),Position=UDim2.new(0,8,0,5),
                    TextXAlignment=Enum.TextXAlignment.Left,AutomaticSize=Enum.AutomaticSize.XY},Pf)
                local PBd=mk("TextLabel",{
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
                    TextSize=10,TextColor3=C.TXT2,BackgroundTransparency=1,
                    Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,0,20),
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
                    TextWrapped=true,AutomaticSize=Enum.AutomaticSize.XY},Pf)
                if not s.rich then PBd.Text=s.text or "" else PBd.RichText=true; PBd.Text=s.richtext or "" end
                Pf.MouseEnter:Connect(function() tw(Pf,0.2,{BackgroundColor3=C.HOVER}) end)
                Pf.MouseLeave:Connect(function() tw(Pf,0.2,{BackgroundColor3=C.CARD2}) end)
                return {}
            end

            -- ── Button ───────────────────────────────────
            function MM:create_button(s)
                local ord=grow(26)
                local Row=mk("Frame",{Size=UDim2.new(0,MOD_W-14,0,20),BackgroundTransparency=1,LayoutOrder=ord},Opts)
                mk("TextLabel",{Text=s.title or "Button",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=11,TextColor3=C.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-32,1,0),TextXAlignment=Enum.TextXAlignment.Left},Row)
                local Btn=mk("TextButton",{Size=UDim2.fromOffset(24,20),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,0,0.5,0),BackgroundColor3=C.ACC,BackgroundTransparency=0.5,
                    BorderSizePixel=0,Text="",AutoButtonColor=false},Row)
                corner(5,Btn)
                local BIc=mk("ImageLabel",{Image="rbxassetid://139650104834071",Size=UDim2.new(0.6,0,0.6,0),
                    AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=1},Btn)
                task.spawn(function() while BIc and BIc.Parent do tw(BIc,1.5,{Rotation=BIc.Rotation+360},Enum.EasingStyle.Linear); task.wait(1.5) end end)
                Btn.MouseEnter:Connect(function() tw(Btn,0.18,{BackgroundTransparency=0.1}) end)
                Btn.MouseLeave:Connect(function() tw(Btn,0.18,{BackgroundTransparency=0.5}) end)
                Btn.MouseButton1Click:Connect(function() if s.callback then s.callback() end end)
                return Row
            end

            -- ── Text ─────────────────────────────────────
            function MM:create_text(s)
                local ord=grow(s.customScale or 38)
                local TFr=mk("Frame",{Size=UDim2.new(0,MOD_W-14,0,s.CustomYSize or 30),
                    BackgroundColor3=C.CARD2,BackgroundTransparency=0.15,BorderSizePixel=0,
                    AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=ord},Opts)
                corner(6,TFr)
                local TLb=mk("TextLabel",{FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
                    TextSize=10,TextColor3=C.TXT2,BackgroundTransparency=1,
                    Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,5),
                    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
                    TextWrapped=true,AutomaticSize=Enum.AutomaticSize.XY},TFr)
                if not s.rich then TLb.Text=s.text or "" else TLb.RichText=true; TLb.Text=s.richtext or "" end
                TFr.MouseEnter:Connect(function() tw(TFr,0.2,{BackgroundColor3=C.HOVER}) end)
                TFr.MouseLeave:Connect(function() tw(TFr,0.2,{BackgroundColor3=C.CARD2}) end)
                local Mg={}
                function Mg:Set(ns)
                    if not ns.rich then TLb.Text=ns.text or "" else TLb.RichText=true; TLb.Text=ns.richtext or "" end
                end
                return Mg
            end

            -- ── Textbox ──────────────────────────────────
            function MM:create_textbox(s)
                local ord=grow(34)
                local TbM={_text=""}
                mk("TextLabel",{Text=s.title or "Input",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=10,TextColor3=C.TXT,TextTransparency=0.1,BackgroundTransparency=1,
                    Size=UDim2.new(0,MOD_W-14,0,12),TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=ord},Opts)
                local TBx=mk("TextBox",{
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular),
                    TextSize=10,TextColor3=C.TXT,PlaceholderText=s.placeholder or "Type here...",
                    Text=Library._config._flags[s.flag] or "",
                    BackgroundColor3=C.ELEM,BackgroundTransparency=0.1,BorderSizePixel=0,
                    ClearTextOnFocus=false,Size=UDim2.new(0,MOD_W-14,0,18),LayoutOrder=ord},Opts)
                corner(5,TBx)
                local TBxSt=mk("UIStroke",{Color=C.STR,Transparency=0.4,Thickness=1,
                    ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=TBx})
                TBx.Focused:Connect(function() tw(TBxSt,0.2,{Color=C.ACC,Transparency=0.2}) end)
                TBx.FocusLost:Connect(function()
                    tw(TBxSt,0.2,{Color=C.STR,Transparency=0.4})
                    TbM._text=TBx.Text; Library._config._flags[s.flag]=TbM._text
                    Cfg:save(game.GameId,Library._config); s.callback(TbM._text)
                end)
                if Library:flag_type(s.flag,"string") then TbM._text=Library._config._flags[s.flag]; s.callback(TbM._text) end
                return TbM
            end

            -- ── Checkbox ─────────────────────────────────
            function MM:create_checkbox(s)
                local ord=grow(20)
                local CbM={_state=false}
                local Row=mk("TextButton",{Size=UDim2.new(0,MOD_W-14,0,16),
                    BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=ord},Opts)
                local if_th=(SelectedLanguage=="th")
                mk("TextLabel",{Text=s.title or "Checkbox",
                    FontFace=Font.new(if_th and "rbxasset://fonts/families/NotoSansThai.json" or
                        "rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=if_th and 12 or 11,TextColor3=C.TXT,TextTransparency=0.05,
                    BackgroundTransparency=1,Size=UDim2.new(1,-52,1,0),
                    TextXAlignment=Enum.TextXAlignment.Left},Row)
                -- keybind chip
                local CKC=mk("Frame",{Size=UDim2.fromOffset(26,14),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,-18,0.5,0),BackgroundColor3=C.ELEM,
                    BackgroundTransparency=0.15,BorderSizePixel=0},Row)
                corner(3,CKC)
                mk("UIStroke",{Color=C.STR2,Transparency=0.5,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=CKC})
                local CKL=mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                    TextColor3=C.TXT2,TextSize=8,Font=Enum.Font.SourceSans,
                    Text=Library._config._keybinds[s.flag] and
                        Library._config._keybinds[s.flag]:gsub("Enum.KeyCode.","") or "..."},CKC)
                -- checkbox box
                local CBox=mk("Frame",{Size=UDim2.fromOffset(15,15),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,0,0.5,0),BackgroundColor3=C.ELEM,
                    BackgroundTransparency=0.1,BorderSizePixel=0},Row)
                corner(4,CBox)
                local CBSt=mk("UIStroke",{Color=C.STR2,Transparency=0.2,Thickness=1.2,
                    ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=CBox})
                local CFl=mk("Frame",{Size=UDim2.fromOffset(0,0),AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=C.ACC,BorderSizePixel=0},CBox)
                corner(3,CFl)

                function CbM:change_state(st)
                    self._state=st
                    if st then
                        tw(CBSt,0.28,{Color=C.ACC,Transparency=0})
                        tw(CFl,0.28,{Size=UDim2.fromOffset(9,9),BackgroundColor3=C.ACC})
                    else
                        tw(CBSt,0.28,{Color=C.STR2,Transparency=0.2})
                        tw(CFl,0.28,{Size=UDim2.fromOffset(0,0)})
                    end
                    Library._config._flags[s.flag]=self._state
                    Cfg:save(game.GameId,Library._config); s.callback(self._state)
                end
                if Library:flag_type(s.flag,"boolean") then CbM:change_state(Library._config._flags[s.flag]) end
                Row.MouseButton1Click:Connect(function() CbM:change_state(not CbM._state) end)
                Row.InputBegan:Connect(function(inp,gp)
                    if gp or inp.UserInputType~=Enum.UserInputType.MouseButton3 then return end
                    if Library._choosing_kb then return end
                    Library._choosing_kb=true
                    local c; c=UIS.InputBegan:Connect(function(ki,kp)
                        if kp then return end
                        if ki.UserInputType~=Enum.UserInputType.Keyboard or ki.KeyCode==Enum.KeyCode.Unknown then return end
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
                Conns[s.flag.."_ckbp"]=UIS.InputBegan:Connect(function(inp,gp)
                    if gp then return end
                    local st=Library._config._keybinds[s.flag]
                    if st and tostring(inp.KeyCode)==st then CbM:change_state(not CbM._state) end
                end)
                return CbM
            end

            -- ── Divider ──────────────────────────────────
            function MM:create_divider(s)
                local ord=grow(20)
                local Dv=mk("Frame",{Size=UDim2.new(0,MOD_W-14,0,14),BackgroundTransparency=1,LayoutOrder=ord},Opts)
                if s and s.showtopic then
                    mk("TextLabel",{Text=s.title or "",
                        FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                        TextSize=9,TextColor3=C.ACC,BackgroundColor3=C.WIN,BackgroundTransparency=0,
                        Size=UDim2.new(0,66,0,11),AnchorPoint=Vector2.new(0.5,0.5),
                        Position=UDim2.new(0.5,0,0.5,0),TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3},Dv)
                end
                if not s or not s.disableline then
                    local DL=mk("Frame",{Size=UDim2.new(1,0,0,1),AnchorPoint=Vector2.new(0.5,0.5),
                        Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=C.ACC,
                        BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=2},Dv)
                    corner(1,DL); fadeH(DL)
                end
                return true
            end

            -- ── Slider ───────────────────────────────────
            function MM:create_slider(s)
                local ord=grow(30)
                local SlM={}
                local SlF=mk("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,
                    Size=UDim2.new(0,MOD_W-14,0,24),LayoutOrder=ord},Opts)
                local if_th=(SelectedLanguage=="th")
                mk("TextLabel",{Text=s.title,
                    FontFace=Font.new(if_th and "rbxasset://fonts/families/NotoSansThai.json" or
                        "rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=if_th and 12 or 11,TextColor3=C.TXT,TextTransparency=0.08,
                    BackgroundTransparency=1,Size=UDim2.new(0,170,0,13),
                    Position=UDim2.new(0,0,0,0),TextXAlignment=Enum.TextXAlignment.Left},SlF)
                local SlVal=mk("TextLabel",{Name="Value",Text="0",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                    TextSize=10,TextColor3=C.ACC,BackgroundTransparency=1,
                    Size=UDim2.new(0,50,0,13),AnchorPoint=Vector2.new(1,0),
                    Position=UDim2.new(1,0,0,0),TextXAlignment=Enum.TextXAlignment.Right},SlF)
                local Trk=mk("Frame",{Name="Drag",Size=UDim2.new(1,0,0,4),AnchorPoint=Vector2.new(0.5,1),
                    Position=UDim2.new(0.5,0,1,0),BackgroundColor3=C.ELEM,BorderSizePixel=0},SlF)
                corner(2,Trk)
                local SlFl=mk("Frame",{Name="Fill",Size=UDim2.new(0.5,0,1,0),BackgroundColor3=C.ACC,
                    BorderSizePixel=0},Trk)
                corner(2,SlFl)
                mk("UIGradient",{Color=ColorSequence.new{
                    ColorSequenceKeypoint.new(0,C.ACC2),ColorSequenceKeypoint.new(1,C.ACC)},Parent=SlFl})
                local SlKn=mk("Frame",{Name="Circle",Size=UDim2.fromOffset(10,10),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,0,0.5,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},SlFl)
                corner(5,SlKn)
                function SlM:set_percentage(pct)
                    if type(pct)~="number" then return end
                    local rnd=s.round_number and math.floor(pct) or (math.floor(pct*10)/10)
                    local norm=(pct-s.minimum_value)/(s.maximum_value-s.minimum_value)
                    local sz=math.clamp(norm,0.02,1)*Trk.Size.X.Offset
                    local cl=math.clamp(rnd,s.minimum_value,s.maximum_value)
                    Library._config._flags[s.flag]=cl; SlVal.Text=tostring(cl)
                    tw(SlFl,0.35,{Size=UDim2.fromOffset(sz,Trk.Size.Y.Offset)})
                    if s.callback then s.callback(cl) end
                end
                function SlM:update()
                    local mp=(mouse.X-Trk.AbsolutePosition.X)/Trk.Size.X.Offset
                    self:set_percentage(s.minimum_value+(s.maximum_value-s.minimum_value)*mp)
                end
                function SlM:input()
                    self:update()
                    Conns["sld_"..s.flag]=mouse.Move:Connect(function() self:update() end)
                    Conns["sle_"..s.flag]=UIS.InputEnded:Connect(function(inp)
                        if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
                        Conns:off("sld_"..s.flag); Conns:off("sle_"..s.flag)
                        if not s.ignoresaved then Cfg:save(game.GameId,Library._config) end
                    end)
                end
                if Library:flag_type(s.flag,"number") and not s.ignoresaved then SlM:set_percentage(Library._config._flags[s.flag])
                else SlM:set_percentage(s.value) end
                SlF.MouseButton1Down:Connect(function() SlM:input() end)
                return SlM
            end

            -- ── Dropdown ─────────────────────────────────
            function MM:create_dropdown(s)
                if not s.Order then eOrd+=1 end
                local DrM={_state=false,_size=0}
                if not s.Order then
                    if MM._size==0 then MM._size=8 end
                    MM._size+=46
                    if MM._state then Mod.Size=UDim2.fromOffset(MOD_W,HEADER_H+MM._size+MM._mult) end
                    Opts.Size=UDim2.fromOffset(MOD_W,MM._size)
                end
                if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={} end

                local DrW=mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,MOD_W-14,0,42),Name="Dropdown",
                    LayoutOrder=s.Order and s.OrderValue or eOrd},Opts)
                local if_th=(SelectedLanguage=="th")
                mk("TextLabel",{Text=s.title,
                    FontFace=Font.new(if_th and "rbxasset://fonts/families/NotoSansThai.json" or
                        "rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=if_th and 12 or 11,TextColor3=C.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,13),TextXAlignment=Enum.TextXAlignment.Left},DrW)
                local DrBox=mk("Frame",{ClipsDescendants=true,Name="Box",
                    Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,15),
                    BackgroundColor3=C.ELEM,BackgroundTransparency=0.1,BorderSizePixel=0},DrW)
                corner(6,DrBox)
                local DrSt=mk("UIStroke",{Color=C.STR,Transparency=0.4,Thickness=1,
                    ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=DrBox})
                local DrHd=mk("Frame",{Name="Header",Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},DrBox)
                mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=DrBox})
                local DrCur=mk("TextLabel",{Name="CurrentOption",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=10,TextColor3=C.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,10,0,0),
                    TextXAlignment=Enum.TextXAlignment.Left},DrHd)
                mk("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),
                    NumberSequenceKeypoint.new(0.75,0),NumberSequenceKeypoint.new(1,1)},Parent=DrCur})
                local DrArr=mk("ImageLabel",{Image="rbxassetid://84232453189324",Name="Arrow",
                    Size=UDim2.fromOffset(8,8),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,-6,0.5,0),BackgroundTransparency=1,ImageColor3=C.TXT2},DrHd)
                local DrOps=mk("ScrollingFrame",{Name="Options",Size=UDim2.new(1,0,0,0),
                    Position=UDim2.new(0,0,1,0),BackgroundTransparency=1,
                    ScrollBarThickness=0,ScrollBarImageTransparency=1,
                    AutomaticCanvasSize=Enum.AutomaticSize.XY,CanvasSize=UDim2.new(0,0,0.5,0)},DrBox)
                mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=DrOps})
                mk("UIPadding",{PaddingLeft=UDim.new(0,10),Parent=DrOps})
                local DrBtn=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""},DrHd)

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
                            if o.Name=="Opt" then o.TextTransparency=o.Text==DrCur.Text and 0 or 0.55 end
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
                        tw(Mod,0.38,{Size=UDim2.fromOffset(MOD_W,HEADER_H+MM._size+MM._mult)})
                        tw(Mod.Options,0.38,{Size=UDim2.fromOffset(MOD_W,MM._size+MM._mult)})
                        tw(DrW,0.38,{Size=UDim2.fromOffset(MOD_W-14,42+self._size)})
                        tw(DrBox,0.38,{Size=UDim2.fromOffset(MOD_W-14,24+self._size)})
                        tw(DrArr,0.35,{Rotation=180}); tw(DrSt,0.28,{Color=C.ACC,Transparency=0.25})
                    else
                        MM._mult-=self._size; curDrS=0
                        tw(Mod,0.38,{Size=UDim2.fromOffset(MOD_W,HEADER_H+MM._size+MM._mult)})
                        tw(Mod.Options,0.38,{Size=UDim2.fromOffset(MOD_W,MM._size+MM._mult)})
                        tw(DrW,0.38,{Size=UDim2.fromOffset(MOD_W-14,42)})
                        tw(DrBox,0.38,{Size=UDim2.fromOffset(MOD_W-14,24)})
                        tw(DrArr,0.35,{Rotation=0}); tw(DrSt,0.28,{Color=C.STR,Transparency=0.4})
                    end
                end

                local maxOpts=s.maximum_options or #s.options
                if #s.options>0 then
                    DrM._size=4
                    for idx,val in s.options do
                        local Opt=mk("TextButton",{Name="Opt",
                            FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                            TextSize=10,TextColor3=C.TXT,TextTransparency=0.55,
                            Text=(type(val)=="string" and val) or val.Name,
                            BackgroundTransparency=1,Size=UDim2.new(0,MOD_W-36,0,16),
                            TextXAlignment=Enum.TextXAlignment.Left,
                            AutoButtonColor=false,Active=false,Selectable=false},DrOps)
                        mk("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),
                            NumberSequenceKeypoint.new(0.8,0),NumberSequenceKeypoint.new(1,1)},Parent=Opt})
                        Opt.MouseEnter:Connect(function() tw(Opt,0.12,{TextTransparency=0,TextColor3=C.ACC}) end)
                        Opt.MouseLeave:Connect(function()
                            local isSel=s.multi_dropdown and table.find(Library._config._flags[s.flag] or {},val)
                                        or (DrCur.Text==Opt.Text)
                            tw(Opt,0.12,{TextTransparency=isSel and 0 or 0.55,TextColor3=C.TXT})
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
                        if idx<=maxOpts then DrM._size+=16; DrOps.Size=UDim2.fromOffset(MOD_W-36,DrM._size) end
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

            -- ── Display ──────────────────────────────────
            function MM:create_display(s)
                local ord=grow(s.height or 100)
                local DF=mk("Frame",{Size=UDim2.new(0,MOD_W-14,0,s.height or 100),BackgroundColor3=C.CARD2,
                    BackgroundTransparency=0.1,BorderSizePixel=0,LayoutOrder=ord},Opts)
                corner(7,DF); mk("UIStroke",{Color=C.STR,Transparency=0.5,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=DF})
                mk("ImageLabel",{Size=UDim2.new(1,-8,1,-18),AnchorPoint=Vector2.new(0.5,0),
                    Position=UDim2.new(0.5,0,0,4),BackgroundTransparency=1,
                    Image=s.image or "rbxassetid://11835491319",ScaleType=Enum.ScaleType.Fit},DF)
                local DLb=mk("TextLabel",{Text=s.text or "",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=10,TextColor3=C.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-8,0,14),AnchorPoint=Vector2.new(0.5,1),
                    Position=UDim2.new(0.5,0,1,-2)},DF)
                if s.glow then mk("UIStroke",{Thickness=1.5,Color=C.ACC,Transparency=0.3,Parent=DLb}) end
                return DF
            end

            -- ── Color Picker ─────────────────────────────
            function MM:create_colorpicker(s)
                local ord=grow(26)
                local CpM={}
                local Row=mk("Frame",{Size=UDim2.new(0,MOD_W-14,0,20),BackgroundTransparency=1,LayoutOrder=ord},Opts)
                mk("TextLabel",{Text=s.title or "Color",
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=11,TextColor3=C.TXT,BackgroundTransparency=1,
                    Size=UDim2.new(1,-28,1,0),TextXAlignment=Enum.TextXAlignment.Left},Row)
                local Prv=mk("TextButton",{Size=UDim2.fromOffset(22,18),AnchorPoint=Vector2.new(1,0.5),
                    Position=UDim2.new(1,0,0.5,0),BackgroundColor3=s.default or Color3.new(1,1,1),
                    Text=""},Row)
                corner(4,Prv)
                local Pop=mk("Frame",{Size=UDim2.fromOffset(300,270),AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=C.CARD,Visible=false,ZIndex=9999},Gui)
                corner(10,Pop); mk("UIStroke",{Color=C.STR2,Transparency=0.3,Thickness=1.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=Pop})
                mk("TextLabel",{Text="Pick Color",FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold),
                    TextSize=12,TextColor3=C.TXT,BackgroundTransparency=1,Size=UDim2.new(1,0,0,26),ZIndex=10000},Pop)
                local HSB=mk("Frame",{Size=UDim2.fromOffset(180,180),Position=UDim2.new(0,10,0,30),
                    BackgroundColor3=Color3.fromHSV(0,1,1),BorderSizePixel=0,ZIndex=10000},Pop)
                corner(5,HSB)
                mk("ImageLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image="rbxassetid://4155801252",ZIndex=10001},HSB)
                local Sel=mk("Frame",{Size=UDim2.fromOffset(10,10),AnchorPoint=Vector2.new(0.5,0.5),
                    BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=10002},HSB); corner(5,Sel)
                local HBar=mk("Frame",{Size=UDim2.fromOffset(16,180),Position=UDim2.new(0,202,0,30),
                    BorderSizePixel=0,ZIndex=10000},Pop); corner(3,HBar)
                local HG=mk("UIGradient",{Rotation=90},HBar)
                local ks2={}; for i=0,1,0.1 do ks2[#ks2+1]=ColorSequenceKeypoint.new(i,Color3.fromHSV(i,1,1)) end
                HG.Color=ColorSequence.new(ks2)
                local HMk=mk("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=10001},HBar)
                local ABar=mk("Frame",{Size=UDim2.fromOffset(180,10),Position=UDim2.new(0,10,0,220),BorderSizePixel=0,ZIndex=10000},Pop); corner(2,ABar)
                mk("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)},
                    Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1))},ABar)
                local AMk=mk("Frame",{Size=UDim2.fromOffset(2,10),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=10001},ABar)
                local HxL=mk("TextLabel",{Size=UDim2.fromOffset(90,18),Position=UDim2.new(0,10,1,-26),
                    BackgroundTransparency=1,TextColor3=C.ACC,Font=Enum.Font.Code,TextSize=11,Text="#FFFFFF",
                    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10002},Pop)
                local ClBtn=mk("ImageButton",{Image="rbxassetid://10030850935",Size=UDim2.fromOffset(16,16),
                    Position=UDim2.new(1,-22,0,5),BackgroundTransparency=1,ZIndex=10001},Pop)
                local OkBtn=mk("ImageButton",{Image="rbxassetid://10030902360",Size=UDim2.fromOffset(16,16),
                    Position=UDim2.new(1,-42,0,5),BackgroundTransparency=1,ZIndex=10001},Pop)
                local h4,s4,v4,a4=0,1,1,1; local dHS,dH,dA=false,false,false
                local function upCP()
                    local col=Color3.fromHSV(h4,s4,v4); HSB.BackgroundColor3=Color3.fromHSV(h4,1,1)
                    Sel.Position=UDim2.new(s4,0,1-v4,0); Prv.BackgroundColor3=col
                    HxL.Text="#"..col:ToHex():upper(); return col
                end
                HSB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHS=true end end)
                HBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dH=true end end)
                ABar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dA=true end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHS=false;dH=false;dA=false end end)
                UIS.InputChanged:Connect(function(i)
                    if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
                    local pp=i.Position
                    if dHS then
                        s4=math.clamp((pp.X-HSB.AbsolutePosition.X)/HSB.AbsoluteSize.X,0,1)
                        v4=1-math.clamp((pp.Y-HSB.AbsolutePosition.Y)/HSB.AbsoluteSize.Y,0,1); upCP()
                    elseif dH then
                        h4=math.clamp((pp.Y-HBar.AbsolutePosition.Y)/HBar.AbsoluteSize.Y,0,1)
                        HMk.Position=UDim2.new(0,0,h4,0); upCP()
                    elseif dA then
                        a4=math.clamp((pp.X-ABar.AbsolutePosition.X)/ABar.AbsoluteSize.X,0,1)
                        AMk.Position=UDim2.new(a4,0,0,0); upCP()
                    end
                end)
                Prv.MouseButton1Click:Connect(function() Pop.Visible=true; Pop.BackgroundTransparency=1; tw(Pop,0.2,{BackgroundTransparency=0}) end)
                ClBtn.MouseButton1Click:Connect(function() Pop.Visible=false end)
                OkBtn.MouseButton1Click:Connect(function() local col=upCP(); if s.callback then s.callback(col,a4) end; Pop.Visible=false end)
                function CpM:Set(col) Prv.BackgroundColor3=col end
                return CpM
            end

            -- ── 3D View ──────────────────────────────────
            function MM:create_3dview(s)
                local ord=grow(230)
                local V3={}
                local VRow=mk("Frame",{Size=UDim2.new(0,MOD_W-14,0,230),BackgroundTransparency=1,LayoutOrder=ord},Opts)
                mk("TextLabel",{Text=s.title or "3D View",FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=11,TextColor3=C.TXT,BackgroundTransparency=1,Size=UDim2.new(1,0,0,14),TextXAlignment=Enum.TextXAlignment.Left},VRow)
                local VH=mk("Frame",{Size=UDim2.new(1,0,1,-14),Position=UDim2.new(0,0,0,14),
                    BackgroundColor3=C.CARD2,ClipsDescendants=true},VRow); corner(7,VH)
                local VImg=mk("ImageLabel",{Size=UDim2.fromOffset(120,120),AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=1,
                    Image=s.image or "rbxassetid://5791744848",ScaleType=Enum.ScaleType.Fit,Visible=false},VH)
                local VP=mk("ViewportFrame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.WIN,Visible=false},VH); corner(7,VP)
                local VCam=mk("Camera",{},VP); VP.CurrentCamera=VCam
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
                local function mB(img,pos)
                    local b=mk("ImageButton",{Image=img,Size=UDim2.fromOffset(18,18),
                        BackgroundTransparency=0.5,BackgroundColor3=C.CARD,Position=pos,ZIndex=10},VP)
                    corner(9,b); return b
                end
                local u=mB("rbxassetid://138007024966757",UDim2.new(0.5,-9,0,3))
                local d=mB("rbxassetid://13360801719",UDim2.new(0.5,-9,1,-21))
                local l=mB("rbxassetid://100152237482023",UDim2.new(0,3,0.5,-9))
                local r=mB("rbxassetid://140701802205656",UDim2.new(1,-21,0.5,-9))
                local zi=mB("rbxassetid://126943351764139",UDim2.new(1,-62,1,-22))
                local zo=mB("rbxassetid://110884638624335",UDim2.new(1,-42,1,-22))
                local re=mB("rbxassetid://6723921202",UDim2.new(1,-22,1,-22))
                local function rot(x2,y2)
                    if is3 and cObj then
                        if cObj:IsA("Model") then cObj:PivotTo(cObj:GetPivot()*CFrame.Angles(0,math.rad(x2),math.rad(y2)))
                        elseif cObj:IsA("BasePart") then cObj.CFrame=cObj.CFrame*CFrame.Angles(0,math.rad(x2),math.rad(y2)) end
                    end
                end
                local function zoom(td)
                    if not(is3 and oP) then return end; cD=math.clamp(td,(mD or 5)*.5,(mD or 5)*6)
                    tw(VCam,0.28,{CFrame=CFrame.new(oP+Vector3.new(0,(mD or 5)/2,cD),oP)})
                end
                u.MouseButton1Click:Connect(function() rot(0,10) end)
                d.MouseButton1Click:Connect(function() rot(0,-10) end)
                l.MouseButton1Click:Connect(function() rot(-10,0) end)
                r.MouseButton1Click:Connect(function() rot(10,0) end)
                zi.MouseButton1Click:Connect(function() zoom(cD-0.5*(mD or 5)) end)
                zo.MouseButton1Click:Connect(function() zoom(cD+0.5*(mD or 5)) end)
                re.MouseButton1Click:Connect(function() if is3 and oP then zoom(bD) end end)
                function V3:SetModel(m) if m then showM(m) end end
                function V3:SetMesh(m2,t2) local mp=Instance.new("MeshPart"); mp.Size=Vector3.new(5,5,5); mp.MeshId="rbxassetid://"..m2; mp.TextureID="rbxassetid://"..t2; showM(mp) end
                function V3:SetImage(i) s.image=i; showI() end
                return V3
            end

            -- ── Feature ──────────────────────────────────
            function MM:create_feature(s)
                local ord=grow(20)
                local chk=false
                local FC=mk("Frame",{Size=UDim2.new(0,MOD_W-14,0,16),BackgroundTransparency=1,LayoutOrder=ord},Opts)
                mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder},FC)
                local FB=mk("TextButton",{
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    TextSize=11,Size=UDim2.new(1,-36,0,16),BackgroundColor3=C.CARD2,BackgroundTransparency=0.25,
                    TextColor3=C.TXT,Text="    "..(s.title or "Feature"),AutoButtonColor=false,
                    TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=0.05},FC)
                corner(4,FB)
                local FR=mk("Frame",{Size=UDim2.fromOffset(36,16),BackgroundTransparency=1},FC)
                mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,2),
                    HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder},FR)
                local FKL=mk("TextLabel",{
                    FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold),
                    Size=UDim2.fromOffset(16,16),BackgroundColor3=C.ELEM,BackgroundTransparency=0.1,
                    TextColor3=C.TXT2,TextSize=8,LayoutOrder=2},FR)
                corner(3,FKL)
                mk("UIStroke",{Color=C.STR2,Transparency=0.4,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=FKL})
                local FKB=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextTransparency=1},FKL)
                if not Library._config._flags then Library._config._flags={} end
                if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={checked=false,BIND=s.default or "Unknown"} end
                chk=Library._config._flags[s.flag].checked
                FKL.Text=Library._config._flags[s.flag].BIND=="Unknown" and "..." or Library._config._flags[s.flag].BIND
                local UseF=nil
                if not s.disablecheck then
                    local FCK=mk("TextButton",{Size=UDim2.fromOffset(16,16),
                        BackgroundColor3=chk and C.ACC or C.ELEM,BackgroundTransparency=chk and 0.1 or 0.1,
                        Text="",LayoutOrder=1},FR)
                    corner(3,FCK)
                    local FCKS=mk("UIStroke",{Color=chk and C.ACC or C.STR2,Transparency=0.3,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=FCK})
                    local function tog()
                        chk=not chk; tw(FCK,0.2,{BackgroundColor3=chk and C.ACC or C.ELEM})
                        tw(FCKS,0.2,{Color=chk and C.ACC or C.STR2})
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
                            local nk=inp.KeyCode.Name; Library._config._flags[s.flag].BIND=nk
                            FKL.Text=nk~="Unknown" and nk or "..."
                            Cfg:save(game.GameId,Library._config); c:Disconnect()
                        elseif inp.UserInputType==Enum.UserInputType.MouseButton3 then
                            Library._config._flags[s.flag].BIND="Unknown"; FKL.Text="..."
                            Cfg:save(game.GameId,Library._config); c:Disconnect()
                        end
                    end)
                end)
                Conns["fkbp_"..s.flag]=UIS.InputBegan:Connect(function(inp,gp)
                    if gp then return end
                    if inp.UserInputType==Enum.UserInputType.Keyboard then
                        if inp.KeyCode.Name==Library._config._flags[s.flag].BIND then UseF() end
                    end
                end)
                FB.MouseButton1Click:Connect(function() if s.button_callback then s.button_callback() end end)
                FB.MouseEnter:Connect(function() tw(FB,0.15,{BackgroundColor3=C.HOVER}) end)
                FB.MouseLeave:Connect(function() tw(FB,0.15,{BackgroundColor3=C.CARD2}) end)
                if not s.disablecheck then s.callback(chk) end
                return FC
            end

            return MM
        end -- create_module

        return TM
    end -- create_tab

    -- ── Insert key toggle ─────────────────────────────────
    Conns["vis"]=UIS.InputBegan:Connect(function(inp,proc)
        if inp.KeyCode~=Enum.KeyCode.Insert then return end
        self._ui_open=not self._ui_open; self:change_visiblity(self._ui_open)
    end)

    return self
end -- _create_ui

return Library
