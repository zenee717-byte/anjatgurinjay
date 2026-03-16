-- ============================================================
-- REVERCES UI LIBRARY v1.0
-- Crimson / dark redesign — horizontal tabs, card modules
-- ============================================================

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

-- helpers
function convertStringToTable(s)
    local r={}
    for v in string.gmatch(s,"([^,]+)") do table.insert(r, v:match("^%s*(.-)%s*$")) end
    return r
end
function convertTableToString(t) return table.concat(t,", ") end

-- services
local UIS  = cloneref(game:GetService("UserInputService"))
local CP   = cloneref(game:GetService("ContentProvider"))
local TS   = cloneref(game:GetService("TweenService"))
local HTTP = cloneref(game:GetService("HttpService"))
local TXT  = cloneref(game:GetService("TextService"))
local RS   = cloneref(game:GetService("RunService"))
local LIG  = cloneref(game:GetService("Lighting"))
local PLR  = cloneref(game:GetService("Players"))
local CG   = cloneref(game:GetService("CoreGui"))
local DEB  = cloneref(game:GetService("Debris"))
local mouse = PLR.LocalPlayer:GetMouse()

do local e=CG:FindFirstChild("reverces") if e then DEB:AddItem(e,0) end end
if not isfolder("reverces") then makefolder("reverces") end

-- connections
local Connections = setmetatable({
    disconnect = function(self,k)
        if not self[k] then return end
        self[k]:Disconnect(); self[k]=nil
    end,
    disconnect_all = function(self)
        for _,v in self do if typeof(v)~="function" then v:Disconnect() end end
    end
},{})

-- util
local Util={}
function Util:map(v,a,b,c,d) return (v-a)*(d-c)/(b-a)+c end
function Util:vp2w(loc,dist)
    local r=workspace.CurrentCamera:ScreenPointToRay(loc.X,loc.Y)
    return r.Origin+r.Direction*dist
end
function Util:offset() return self:map(workspace.CurrentCamera.ViewportSize.Y,0,2560,8,56) end

-- acrylic blur
local AB={}; AB.__index=AB
function AB.new(obj) local s=setmetatable({_obj=obj,_folder=nil,_frame=nil,_root=nil},AB); s:setup(); return s end
function AB:mk_folder()
    local o=workspace.CurrentCamera:FindFirstChild("RVBlur"); if o then DEB:AddItem(o,0) end
    local f=Instance.new("Folder"); f.Name="RVBlur"; f.Parent=workspace.CurrentCamera; self._folder=f
end
function AB:mk_dof()
    local d=LIG:FindFirstChild("RVBlur") or Instance.new("DepthOfFieldEffect")
    d.FarIntensity=0; d.FocusDistance=0.05; d.InFocusRadius=0.1; d.NearIntensity=1
    d.Name="RVBlur"; d.Parent=LIG
    for _,o in LIG:GetChildren() do
        if not o:IsA("DepthOfFieldEffect") or o==d then continue end
        Connections[o]=o:GetPropertyChangedSignal("FarIntensity"):Connect(function() o.FarIntensity=0 end)
        o.FarIntensity=0
    end
end
function AB:mk_frame()
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,1,0); f.Position=UDim2.new(0.5,0,0.5,0)
    f.AnchorPoint=Vector2.new(0.5,0.5); f.BackgroundTransparency=1; f.Parent=self._obj; self._frame=f
end
function AB:mk_root()
    local p=Instance.new("Part"); p.Name="Root"; p.Color=Color3.new(0,0,0)
    p.Material=Enum.Material.Glass; p.Size=Vector3.new(1,1,0); p.Anchored=true
    p.CanCollide=false; p.CanQuery=false; p.Locked=true; p.CastShadow=false; p.Transparency=0.98; p.Parent=self._folder
    local m=Instance.new("SpecialMesh"); m.MeshType=Enum.MeshType.Brick; m.Offset=Vector3.new(0,0,-0.000001); m.Parent=p
    self._root=p
end
function AB:setup() self:mk_dof(); self:mk_folder(); self:mk_root(); self:mk_frame(); self:render(0.001); self:chkQ() end
function AB:render(dist)
    local pos={tl=Vector2.new(),tr=Vector2.new(),br=Vector2.new()}
    local function upPos(sz,p) pos.tl=p; pos.tr=p+Vector2.new(sz.X,0); pos.br=p+sz end
    local function upd()
        local tl=Util:vp2w(pos.tl,dist); local tr=Util:vp2w(pos.tr,dist); local br=Util:vp2w(pos.br,dist)
        if not self._root then return end
        local cam=workspace.CurrentCamera
        self._root.CFrame=CFrame.fromMatrix((tl+br)/2,cam.CFrame.XVector,cam.CFrame.YVector,cam.CFrame.ZVector)
        self._root.Mesh.Scale=Vector3.new((tr-tl).Magnitude,(tr-br).Magnitude,0)
    end
    local function onChange()
        local off=Util:offset()
        upPos(self._frame.AbsoluteSize-Vector2.new(off,off), self._frame.AbsolutePosition+Vector2.new(off/2,off/2))
        task.spawn(upd)
    end
    Connections.cfu=workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(upd)
    Connections.vsu=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(upd)
    Connections.fov=workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(upd)
    Connections.fap=self._frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(onChange)
    Connections.fas=self._frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(onChange)
    task.spawn(upd)
end
function AB:chkQ()
    local gs=UserSettings().GameSettings
    if gs.SavedQualityLevel.Value<8 then self:vis(false) end
    Connections.ql=gs:GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
        self:vis(UserSettings().GameSettings.SavedQualityLevel.Value>=8)
    end)
end
function AB:vis(s) self._root.Transparency=s and 0.98 or 1 end

-- config
local Cfg=setmetatable({
    save=function(self,n,c)
        local ok,e=pcall(function() writefile("reverces/"..tostring(n)..".json",HTTP:JSONEncode(c)) end)
        if not ok then warn("reverces save:",e) end
    end,
    load=function(self,n)
        local ok,r=pcall(function()
            if not isfile("reverces/"..tostring(n)..".json") then return end
            local raw=readfile("reverces/"..tostring(n)..".json"); if not raw then return end
            return HTTP:JSONDecode(raw)
        end)
        if not ok then warn("reverces load:",r) end
        return r or {_flags={},_keybinds={},_library={}}
    end
},{})

-- theme
local C={
    bg     =Color3.fromRGB(10,11,18),
    surf   =Color3.fromRGB(16,18,30),
    surf2  =Color3.fromRGB(20,23,38),
    surf3  =Color3.fromRGB(24,28,46),
    acc    =Color3.fromRGB(255,48,68),
    acc2   =Color3.fromRGB(255,122,48),
    txt    =Color3.fromRGB(235,235,255),
    dim    =Color3.fromRGB(110,118,155),
    bdr    =Color3.fromRGB(36,40,65),
}
local QT =TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
local QL =TweenInfo.new(0.40,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
local function tw(o,i,p) TS:Create(o,i,p):Play() end
local function corner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=r or UDim.new(0,5); c.Parent=p; return c end
local function stroke(p,col,th,tr)
    local s=Instance.new("UIStroke"); s.Color=col or C.bdr; s.Thickness=th or 1
    s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s
end
local function accGrad(p)
    local g=Instance.new("UIGradient")
    g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.acc),ColorSequenceKeypoint.new(1,C.acc2)}
    g.Rotation=90; g.Parent=p; return g
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local NGui=Instance.new("ScreenGui"); NGui.Name="RVNotifs"; NGui.ResetOnSpawn=false
NGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; NGui.DisplayOrder=9999
NGui.IgnoreGuiInset=true; NGui.Parent=CG

local NH=Instance.new("Frame"); NH.Name="NH"; NH.Size=UDim2.new(0,300,1,0)
NH.Position=UDim2.new(0,12,0,0); NH.BackgroundTransparency=1; NH.Parent=NGui
local NLL=Instance.new("UIListLayout",NH); NLL.FillDirection=Enum.FillDirection.Vertical
NLL.VerticalAlignment=Enum.VerticalAlignment.Bottom; NLL.SortOrder=Enum.SortOrder.LayoutOrder
NLL.Padding=UDim.new(0,6)
local NPad=Instance.new("UIPadding",NH); NPad.PaddingBottom=UDim.new(0,14)
local nCnt=0

-- ============================================================
-- LIBRARY
-- ============================================================
local Library={
    _config=Cfg:load(game.GameId),
    _choosing_keybind=false, _device=nil,
    _ui_open=true, _ui_scale=1, _ui_loaded=false, _ui=nil,
    _dragging=false, _drag_start=nil, _container_position=nil,
}
Library.__index=Library

function Library.SendNotification(s)
    nCnt+=1; local ord=nCnt
    local W=Instance.new("Frame"); W.Size=UDim2.new(1,0,0,64); W.BackgroundTransparency=1
    W.ClipsDescendants=false; W.LayoutOrder=ord; W.Position=UDim2.new(-1.4,0,0,0); W.Parent=NH

    local Card=Instance.new("Frame"); Card.Size=UDim2.new(1,0,1,0)
    Card.BackgroundColor3=C.surf; Card.BorderSizePixel=0; Card.Parent=W
    corner(Card,UDim.new(0,7))
    local cStr=stroke(Card,C.bdr,1)

    -- accent bar
    local Bar=Instance.new("Frame"); Bar.Size=UDim2.new(0,3,0.6,0); Bar.AnchorPoint=Vector2.new(0,0.5)
    Bar.Position=UDim2.new(0,0,0.5,0); Bar.BackgroundColor3=C.acc; Bar.BorderSizePixel=0; Bar.Parent=Card
    corner(Bar,UDim.new(1,0)); accGrad(Bar)

    -- icon
    local IB=Instance.new("Frame"); IB.Size=UDim2.fromOffset(28,28); IB.AnchorPoint=Vector2.new(0,0.5)
    IB.Position=UDim2.new(0,12,0.5,0); IB.BackgroundColor3=C.acc; IB.BackgroundTransparency=0.8
    IB.BorderSizePixel=0; IB.ZIndex=2; IB.Parent=Card; corner(IB,UDim.new(1,0))
    local NI=Instance.new("ImageLabel"); NI.Image=s.icon or "rbxassetid://10653372143"
    NI.Size=UDim2.fromOffset(14,14); NI.AnchorPoint=Vector2.new(0.5,0.5); NI.Position=UDim2.new(0.5,0,0.5,0)
    NI.BackgroundTransparency=1; NI.ImageColor3=C.acc; NI.ZIndex=3; NI.Parent=IB

    local NT=Instance.new("TextLabel"); NT.Text=s.title or "Notice"
    NT.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold)
    NT.TextSize=12; NT.TextColor3=C.txt; NT.BackgroundTransparency=1
    NT.Size=UDim2.new(1,-52,0,14); NT.Position=UDim2.new(0,50,0,10)
    NT.TextXAlignment=Enum.TextXAlignment.Left; NT.ZIndex=2; NT.Parent=Card

    local NB=Instance.new("TextLabel"); NB.Text=s.text or ""
    NB.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular)
    NB.TextSize=10; NB.TextColor3=C.dim; NB.BackgroundTransparency=1
    NB.Size=UDim2.new(1,-52,0,24); NB.Position=UDim2.new(0,50,0,27)
    NB.TextXAlignment=Enum.TextXAlignment.Left; NB.TextYAlignment=Enum.TextYAlignment.Top
    NB.TextWrapped=true; NB.ZIndex=2; NB.Parent=Card

    local PBg=Instance.new("Frame"); PBg.Size=UDim2.new(1,-14,0,2); PBg.AnchorPoint=Vector2.new(0.5,1)
    PBg.Position=UDim2.new(0.5,0,1,-4); PBg.BackgroundColor3=C.bdr; PBg.BorderSizePixel=0; PBg.ZIndex=2; PBg.Parent=Card
    corner(PBg,UDim.new(1,0))
    local PF=Instance.new("Frame"); PF.Size=UDim2.new(1,0,1,0); PF.BackgroundColor3=C.acc
    PF.BorderSizePixel=0; PF.ZIndex=3; PF.Parent=PBg; corner(PF,UDim.new(1,0)); accGrad(PF)

    task.spawn(function()
        tw(W,TweenInfo.new(0.38,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})
        local dur=s.duration or 5; task.wait(0.42)
        tw(PF,TweenInfo.new(dur-0.42,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)})
        task.wait(dur-0.42)
        tw(Card,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{BackgroundTransparency=1})
        tw(W,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position=UDim2.new(-1.4,0,0,0)})
        task.wait(0.35); W:Destroy()
    end)
end

function Library:get_screen_scale() self._ui_scale=workspace.CurrentCamera.ViewportSize.X/1400 end
function Library:get_device()
    if not UIS.TouchEnabled and UIS.KeyboardEnabled then self._device="PC"
    elseif UIS.TouchEnabled then self._device="Mobile"
    elseif UIS.GamepadEnabled then self._device="Console"
    else self._device="Unknown" end
end
function Library:removed(fn) self._ui.AncestryChanged:Once(fn) end
function Library:flag_type(flag,ft)
    if not Library._config._flags[flag] then return end
    return typeof(Library._config._flags[flag])==ft
end
function Library:remove_table_value(tbl,val)
    for i,v in tbl do if v==val then table.remove(tbl,i); break end end
end

function Library.new()
    local self=setmetatable({_loaded=false,_tab=0},Library)
    self:create_ui(); return self
end

-- ============================================================
-- CREATE UI
-- ============================================================
function Library:create_ui()
    local old=CG:FindFirstChild("reverces"); if old then DEB:AddItem(old,0) end

    local SG=Instance.new("ScreenGui"); SG.ResetOnSpawn=false; SG.Name="reverces"
    SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=CG

    -- Container 720x460
    local Con=Instance.new("Frame"); Con.Name="Container"
    Con.Size=UDim2.fromOffset(0,0); Con.Position=UDim2.new(0.5,0,0.5,0)
    Con.AnchorPoint=Vector2.new(0.5,0.5); Con.BackgroundColor3=C.bg
    Con.BorderSizePixel=0; Con.ClipsDescendants=true; Con.Active=true; Con.Parent=SG
    corner(Con,UDim.new(0,8)); stroke(Con,C.bdr,1)

    local Han=Instance.new("Frame"); Han.Name="Handler"
    Han.Size=UDim2.fromOffset(720,460); Han.BackgroundTransparency=1; Han.Parent=Con

    -- ═══════════════════════ TOP BAR ═══════════════════════
    local TB=Instance.new("Frame"); TB.Name="TopBar"
    TB.Size=UDim2.fromOffset(720,46); TB.BackgroundColor3=C.surf; TB.BorderSizePixel=0; TB.Parent=Han
    local TBBot=Instance.new("Frame"); TBBot.Size=UDim2.new(1,0,0,1); TBBot.AnchorPoint=Vector2.new(0,1)
    TBBot.Position=UDim2.new(0,0,1,0); TBBot.BackgroundColor3=C.bdr; TBBot.BorderSizePixel=0; TBBot.Parent=TB

    -- Diamond logo
    local LD=Instance.new("Frame"); LD.Size=UDim2.fromOffset(18,18); LD.AnchorPoint=Vector2.new(0,0.5)
    LD.Position=UDim2.new(0,14,0.5,0); LD.Rotation=45; LD.BackgroundColor3=C.acc; LD.BorderSizePixel=0; LD.Parent=TB
    corner(LD,UDim.new(0,3))
    local LI=Instance.new("Frame"); LI.Size=UDim2.fromOffset(8,8); LI.AnchorPoint=Vector2.new(0.5,0.5)
    LI.Position=UDim2.new(0.5,0,0.5,0); LI.BackgroundColor3=C.bg; LI.BorderSizePixel=0; LI.Parent=LD
    corner(LI,UDim.new(0,2))
    task.spawn(function()
        while LD and LD.Parent do
            tw(LD,TweenInfo.new(1.4,Enum.EasingStyle.Sine),{BackgroundColor3=C.acc2}); task.wait(1.4)
            tw(LD,TweenInfo.new(1.4,Enum.EasingStyle.Sine),{BackgroundColor3=C.acc}); task.wait(1.4)
        end
    end)

    -- Title
    local TL=Instance.new("TextLabel"); TL.Text="REVERCES"
    TL.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold)
    TL.TextSize=14; TL.TextColor3=C.txt; TL.BackgroundTransparency=1
    TL.Size=UDim2.fromOffset(135,20); TL.AnchorPoint=Vector2.new(0,0.5); TL.Position=UDim2.new(0,42,0.5,0)
    TL.TextXAlignment=Enum.TextXAlignment.Left; TL.Parent=TB
    local TG=Instance.new("UIGradient"); TG.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,C.txt), ColorSequenceKeypoint.new(0.55,Color3.fromRGB(255,185,195)),
        ColorSequenceKeypoint.new(1,C.acc)}; TG.Parent=TL

    -- Version badge
    local VB=Instance.new("Frame"); VB.Size=UDim2.fromOffset(36,15); VB.AnchorPoint=Vector2.new(0,0.5)
    VB.Position=UDim2.new(0,182,0.5,0); VB.BackgroundColor3=C.acc; VB.BackgroundTransparency=0.85
    VB.BorderSizePixel=0; VB.Parent=TB; corner(VB,UDim.new(1,0)); stroke(VB,C.acc,1,0.5)
    local VT=Instance.new("TextLabel"); VT.Text="v1.0"
    VT.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold)
    VT.TextSize=9; VT.TextColor3=C.acc; VT.BackgroundTransparency=1; VT.Size=UDim2.new(1,0,1,0); VT.Parent=VB

    -- Discord button
    local DB=Instance.new("TextButton"); DB.Size=UDim2.fromOffset(88,26); DB.AnchorPoint=Vector2.new(1,0.5)
    DB.Position=UDim2.new(1,-44,0.5,0); DB.BackgroundColor3=C.surf2; DB.BorderSizePixel=0
    DB.Text=""; DB.AutoButtonColor=false; DB.Parent=TB; corner(DB,UDim.new(0,5))
    local DStr=stroke(DB,C.bdr,1)
    local DIco=Instance.new("ImageLabel"); DIco.Image="rbxassetid://112538196670712"
    DIco.Size=UDim2.fromOffset(13,13); DIco.AnchorPoint=Vector2.new(0,0.5); DIco.Position=UDim2.new(0,8,0.5,0)
    DIco.BackgroundTransparency=1; DIco.ImageColor3=C.dim; DIco.ZIndex=2; DIco.Parent=DB
    local DLb=Instance.new("TextLabel"); DLb.Text="Discord"
    DLb.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
    DLb.TextSize=10; DLb.TextColor3=C.dim; DLb.BackgroundTransparency=1
    DLb.Size=UDim2.fromOffset(55,26); DLb.Position=UDim2.new(0,27,0,0); DLb.TextXAlignment=Enum.TextXAlignment.Left
    DLb.ZIndex=2; DLb.Parent=DB
    DB.MouseEnter:Connect(function() tw(DB,QT,{BackgroundColor3=C.surf3}); tw(DStr,QT,{Transparency=0.4}); tw(DIco,QT,{ImageColor3=C.acc}); tw(DLb,QT,{TextColor3=C.txt}) end)
    DB.MouseLeave:Connect(function() tw(DB,QT,{BackgroundColor3=C.surf2}); tw(DStr,QT,{Transparency=0}); tw(DIco,QT,{ImageColor3=C.dim}); tw(DLb,QT,{TextColor3=C.dim}) end)
    DB.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/gngstore")
        Library.SendNotification({title="Discord",text="Link copied!",icon="rbxassetid://112538196670712",duration=3})
    end)

    -- Minimize
    local Min=Instance.new("TextButton"); Min.Name="Minimize"; Min.Size=UDim2.fromOffset(26,26)
    Min.AnchorPoint=Vector2.new(1,0.5); Min.Position=UDim2.new(1,-10,0.5,0)
    Min.BackgroundColor3=C.surf2; Min.BorderSizePixel=0; Min.Text=""; Min.AutoButtonColor=false; Min.Parent=TB
    corner(Min,UDim.new(0,5)); stroke(Min,C.bdr,1)
    local MI=Instance.new("ImageLabel"); MI.Image="rbxassetid://10030850935"
    MI.Size=UDim2.fromOffset(12,12); MI.AnchorPoint=Vector2.new(0.5,0.5); MI.Position=UDim2.new(0.5,0,0.5,0)
    MI.BackgroundTransparency=1; MI.ImageColor3=C.dim; MI.ZIndex=2; MI.Parent=Min
    Min.MouseEnter:Connect(function() tw(Min,QT,{BackgroundColor3=C.acc}); tw(MI,QT,{ImageColor3=C.txt}) end)
    Min.MouseLeave:Connect(function() tw(Min,QT,{BackgroundColor3=C.surf2}); tw(MI,QT,{ImageColor3=C.dim}) end)

    -- ═══════════════════════ TAB BAR ═══════════════════════
    local TBF=Instance.new("Frame"); TBF.Name="TabBarFrame"
    TBF.Size=UDim2.fromOffset(720,36); TBF.Position=UDim2.fromOffset(0,46)
    TBF.BackgroundColor3=C.surf; TBF.BorderSizePixel=0; TBF.Parent=Han
    local TBFBot=Instance.new("Frame"); TBFBot.Size=UDim2.new(1,0,0,1); TBFBot.AnchorPoint=Vector2.new(0,1)
    TBFBot.Position=UDim2.new(0,0,1,0); TBFBot.BackgroundColor3=C.bdr; TBFBot.BorderSizePixel=0; TBFBot.Parent=TBF

    local Tabs=Instance.new("ScrollingFrame"); Tabs.Name="Tabs"
    Tabs.Size=UDim2.new(1,-20,1,0); Tabs.Position=UDim2.fromOffset(10,0)
    Tabs.BackgroundTransparency=1; Tabs.BorderSizePixel=0; Tabs.ScrollBarThickness=0
    Tabs.ScrollBarImageTransparency=1; Tabs.AutomaticCanvasSize=Enum.AutomaticSize.X
    Tabs.CanvasSize=UDim2.new(0,0,1,0); Tabs.Parent=TBF
    local TbL=Instance.new("UIListLayout",Tabs); TbL.FillDirection=Enum.FillDirection.Horizontal
    TbL.VerticalAlignment=Enum.VerticalAlignment.Center; TbL.SortOrder=Enum.SortOrder.LayoutOrder
    TbL.Padding=UDim.new(0,2)

    -- sliding indicator
    local Ind=Instance.new("Frame"); Ind.Name="Indicator"
    Ind.Size=UDim2.fromOffset(50,2); Ind.AnchorPoint=Vector2.new(0,1)
    Ind.Position=UDim2.new(0,10,1,0); Ind.BackgroundColor3=C.acc; Ind.BorderSizePixel=0
    Ind.ZIndex=3; Ind.Parent=TBF; corner(Ind,UDim.new(1,0)); accGrad(Ind)

    -- ═══════════════════════ CONTENT ═══════════════════════
    local CA=Instance.new("Frame"); CA.Name="ContentArea"
    CA.Size=UDim2.fromOffset(720,378); CA.Position=UDim2.fromOffset(0,82)
    CA.BackgroundTransparency=1; CA.BorderSizePixel=0; CA.Parent=Han

    -- center divider
    local CD=Instance.new("Frame"); CD.Size=UDim2.new(0,1,1,-20); CD.AnchorPoint=Vector2.new(0.5,0.5)
    CD.Position=UDim2.new(0.5,0,0.5,0); CD.BackgroundColor3=C.bdr; CD.BorderSizePixel=0; CD.Parent=CA

    -- Sections folder
    local Secs=Instance.new("Folder"); Secs.Name="Sections"; Secs.Parent=CA

    local UIScale=Instance.new("UIScale"); UIScale.Parent=Con
    self._ui=SG

    -- drag (TopBar)
    local function onDrag(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        self._dragging=true; self._drag_start=input.Position; self._container_position=Con.Position
        Connections.cie=input.Changed:Connect(function()
            if input.UserInputState~=Enum.UserInputState.End then return end
            Connections:disconnect("cie"); self._dragging=false
        end)
    end
    local function onMove(input)
        if not self._dragging then return end
        if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
        local d=input.Position-self._drag_start
        tw(Con,TweenInfo.new(0.12),{Position=UDim2.new(
            self._container_position.X.Scale, self._container_position.X.Offset+d.X,
            self._container_position.Y.Scale, self._container_position.Y.Offset+d.Y)})
    end
    Connections.drag_start=TB.InputBegan:Connect(onDrag)
    Connections.drag_move=UIS.InputChanged:Connect(onMove)
    self:removed(function() self._ui=nil; Connections:disconnect_all() end)

    function self:Update1Run(a)
        if a=="nil" then Con.BackgroundTransparency=0.05
        else pcall(function() Con.BackgroundTransparency=tonumber(a) end) end
    end
    function self:UIVisiblity() SG.Enabled=not SG.Enabled end
    function self:change_visiblity(state)
        if state then tw(Con,QL,{Size=UDim2.fromOffset(720,460)})
        else tw(Con,QL,{Size=UDim2.fromOffset(220,46)}) end
    end
    function self:load()
        local ct={}
        for _,o in SG:GetDescendants() do if o:IsA("ImageLabel") then table.insert(ct,o) end end
        CP:PreloadAsync(ct); self:get_device()
        if self._device=="Mobile" or self._device=="Unknown" then
            self:get_screen_scale(); UIScale.Scale=self._ui_scale
            Connections.uiscale=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                self:get_screen_scale(); UIScale.Scale=self._ui_scale
            end)
        end
        tw(Con,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(720,460)})
        AB.new(Con); self._ui_loaded=true
    end

    function self:update_tabs(activeTab)
        for _,obj in Tabs:GetChildren() do
            if obj.Name~="Tab" then continue end
            if obj==activeTab then
                tw(obj,QT,{BackgroundTransparency=0.86}); tw(obj.TL,QT,{TextColor3=C.txt,TextTransparency=0})
                tw(obj.TI,QT,{ImageColor3=C.acc,ImageTransparency=0.1})
                task.spawn(function()
                    task.wait(0.04)
                    local x=obj.AbsolutePosition.X-TBF.AbsolutePosition.X
                    tw(Ind,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{
                        Position=UDim2.new(0,x+5,1,0),
                        Size=UDim2.new(0,obj.AbsoluteSize.X-10,0,2)})
                end)
            else
                tw(obj,QT,{BackgroundTransparency=1}); tw(obj.TL,QT,{TextColor3=C.dim,TextTransparency=0.3})
                tw(obj.TI,QT,{ImageColor3=C.dim,ImageTransparency=0.7})
            end
        end
    end

    function self:update_sections(L,R)
        for _,o in Secs:GetChildren() do o.Visible=(o==L or o==R) end
    end

    -- ══════════════════════════════════════════════
    --  CREATE TAB
    -- ══════════════════════════════════════════════
    function self:create_tab(title,icon)
        local TM={}
        local fp=Instance.new("GetTextBoundsParams"); fp.Text=title
        fp.Font=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
        fp.Size=11; fp.Width=10000
        local fw=TXT:GetTextBoundsAsync(fp).X
        local first=not Tabs:FindFirstChild("Tab")

        local Tab=Instance.new("TextButton"); Tab.Name="Tab"
        Tab.Size=UDim2.new(0,fw+36,0,28); Tab.BackgroundColor3=C.acc
        Tab.BackgroundTransparency=1; Tab.BorderSizePixel=0; Tab.Text=""
        Tab.AutoButtonColor=false; Tab.LayoutOrder=self._tab; Tab.Parent=Tabs
        corner(Tab,UDim.new(0,5))

        local TI=Instance.new("ImageLabel"); TI.Name="TI"; TI.Image=icon
        TI.Size=UDim2.fromOffset(11,11); TI.AnchorPoint=Vector2.new(0,0.5)
        TI.Position=UDim2.new(0,7,0.5,0); TI.BackgroundTransparency=1
        TI.ImageColor3=C.dim; TI.ImageTransparency=0.7; TI.ScaleType=Enum.ScaleType.Fit; TI.Parent=Tab

        local TLabel=Instance.new("TextLabel"); TLabel.Name="TL"; TLabel.Text=title
        TLabel.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
        TLabel.TextSize=11; TLabel.TextColor3=C.dim; TLabel.TextTransparency=0.3
        TLabel.BackgroundTransparency=1; TLabel.Size=UDim2.new(1,-22,1,0)
        TLabel.Position=UDim2.new(0,22,0,0); TLabel.TextXAlignment=Enum.TextXAlignment.Left; TLabel.Parent=Tab

        -- Left section  (x=8, w=348)
        local LS=Instance.new("ScrollingFrame"); LS.Name="LS"
        LS.Size=UDim2.fromOffset(348,370); LS.Position=UDim2.fromOffset(8,4)
        LS.BackgroundTransparency=1; LS.BorderSizePixel=0; LS.ScrollBarThickness=0
        LS.ScrollBarImageTransparency=1; LS.AutomaticCanvasSize=Enum.AutomaticSize.Y
        LS.CanvasSize=UDim2.new(0,0,0,0); LS.Visible=false; LS.Parent=Secs
        local LSL=Instance.new("UIListLayout",LS); LSL.Padding=UDim.new(0,8)
        LSL.HorizontalAlignment=Enum.HorizontalAlignment.Center; LSL.SortOrder=Enum.SortOrder.LayoutOrder
        local LSP=Instance.new("UIPadding",LS); LSP.PaddingTop=UDim.new(0,5)

        -- Right section (x=368, w=348)
        local RS=Instance.new("ScrollingFrame"); RS.Name="RS"
        RS.Size=UDim2.fromOffset(348,370); RS.Position=UDim2.fromOffset(368,4)
        RS.BackgroundTransparency=1; RS.BorderSizePixel=0; RS.ScrollBarThickness=0
        RS.ScrollBarImageTransparency=1; RS.AutomaticCanvasSize=Enum.AutomaticSize.Y
        RS.CanvasSize=UDim2.new(0,0,0,0); RS.Visible=false; RS.Parent=Secs
        local RSL=Instance.new("UIListLayout",RS); RSL.Padding=UDim.new(0,8)
        RSL.HorizontalAlignment=Enum.HorizontalAlignment.Center; RSL.SortOrder=Enum.SortOrder.LayoutOrder
        local RSP=Instance.new("UIPadding",RS); RSP.PaddingTop=UDim.new(0,5)

        self._tab+=1
        if first then self:update_tabs(Tab); self:update_sections(LS,RS) end
        Tab.MouseButton1Click:Connect(function() self:update_tabs(Tab); self:update_sections(LS,RS) end)

        -- ════════════════════════════════════════
        --  CREATE MODULE
        -- ════════════════════════════════════════
        function TM:create_module(cfg)
            local LOM=0
            local MM={_state=false,_size=0,_multiplier=0}

            cfg.section=(cfg.section=="right") and RS or LS

            local Mod=Instance.new("Frame"); Mod.Name="Module"
            Mod.Size=UDim2.fromOffset(330,80); Mod.BackgroundColor3=C.surf2
            Mod.BorderSizePixel=0; Mod.ClipsDescendants=true; Mod.Parent=cfg.section
            corner(Mod,UDim.new(0,6))
            local ModStr=stroke(Mod,C.bdr,1)

            local ModL=Instance.new("UIListLayout",Mod); ModL.SortOrder=Enum.SortOrder.LayoutOrder

            -- accent bar left edge
            local Acc=Instance.new("Frame"); Acc.Size=UDim2.new(0,3,0.6,0); Acc.AnchorPoint=Vector2.new(0,0.5)
            Acc.Position=UDim2.new(0,0,0.24,0); Acc.BackgroundColor3=C.acc; Acc.BorderSizePixel=0; Acc.Parent=Mod
            corner(Acc,UDim.new(1,0)); accGrad(Acc)

            local Hdr=Instance.new("TextButton"); Hdr.Name="Header"
            Hdr.Size=UDim2.fromOffset(330,80); Hdr.BackgroundTransparency=1
            Hdr.Text=""; Hdr.AutoButtonColor=false; Hdr.BorderSizePixel=0; Hdr.Parent=Mod

            -- icon bg circle
            local IcBg=Instance.new("Frame"); IcBg.Size=UDim2.fromOffset(30,30); IcBg.AnchorPoint=Vector2.new(0,0.5)
            IcBg.Position=UDim2.new(0,14,0.33,0); IcBg.BackgroundColor3=C.acc; IcBg.BackgroundTransparency=0.82
            IcBg.BorderSizePixel=0; IcBg.Parent=Hdr; corner(IcBg,UDim.new(0,6))
            local MIco=Instance.new("ImageLabel"); MIco.Image="rbxassetid://79095934438045"
            MIco.Size=UDim2.fromOffset(15,15); MIco.AnchorPoint=Vector2.new(0.5,0.5); MIco.Position=UDim2.new(0.5,0,0.5,0)
            MIco.BackgroundTransparency=1; MIco.ImageColor3=C.acc; MIco.Parent=IcBg

            local MN=Instance.new("TextLabel"); MN.Name="ModuleName"
            MN.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold)
            MN.TextColor3=C.txt; MN.TextTransparency=0; MN.TextSize=12
            MN.TextXAlignment=Enum.TextXAlignment.Left; MN.BackgroundTransparency=1
            MN.Size=UDim2.fromOffset(210,14); MN.AnchorPoint=Vector2.new(0,0.5); MN.Position=UDim2.new(0,54,0.28,0)
            if not cfg.rich then MN.Text=cfg.title or "Module"
            else MN.RichText=true; MN.Text=cfg.richtext or "Module" end; MN.Parent=Hdr

            local Des=Instance.new("TextLabel")
            Des.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular)
            Des.TextColor3=C.dim; Des.TextSize=10
            Des.TextXAlignment=Enum.TextXAlignment.Left; Des.BackgroundTransparency=1
            Des.Size=UDim2.fromOffset(210,12); Des.AnchorPoint=Vector2.new(0,0.5); Des.Position=UDim2.new(0,54,0.50,0)
            Des.Text=cfg.description or ""; Des.Parent=Hdr

            -- toggle pill
            local Tog=Instance.new("Frame"); Tog.Name="Toggle"
            Tog.Size=UDim2.fromOffset(28,14); Tog.AnchorPoint=Vector2.new(1,0.5)
            Tog.Position=UDim2.new(1,-12,0.34,0); Tog.BackgroundColor3=C.bdr; Tog.BorderSizePixel=0; Tog.Parent=Hdr
            corner(Tog,UDim.new(1,0))
            local Cir=Instance.new("Frame"); Cir.Name="Circle"
            Cir.Size=UDim2.fromOffset(10,10); Cir.AnchorPoint=Vector2.new(0,0.5)
            Cir.Position=UDim2.new(0,2,0.5,0); Cir.BackgroundColor3=C.dim; Cir.BorderSizePixel=0; Cir.Parent=Tog
            corner(Cir,UDim.new(1,0))

            -- keybind badge
            local KB=Instance.new("Frame"); KB.Name="Keybind"
            KB.Size=UDim2.fromOffset(30,14); KB.AnchorPoint=Vector2.new(1,0.5); KB.Position=UDim2.new(1,-48,0.34,0)
            KB.BackgroundColor3=C.surf; KB.BorderSizePixel=0; KB.Parent=Hdr
            corner(KB,UDim.new(0,3)); stroke(KB,C.bdr,1)
            local KBL=Instance.new("TextLabel"); KBL.Text="None"
            KBL.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
            KBL.TextSize=9; KBL.TextColor3=C.dim; KBL.BackgroundTransparency=1; KBL.Size=UDim2.new(1,0,1,0); KBL.Parent=KB

            -- header divider
            local HDiv=Instance.new("Frame"); HDiv.Size=UDim2.new(1,-26,0,1); HDiv.AnchorPoint=Vector2.new(0.5,1)
            HDiv.Position=UDim2.new(0.5,0,1,0); HDiv.BackgroundColor3=C.bdr; HDiv.BorderSizePixel=0; HDiv.Parent=Hdr

            -- options
            local Opts=Instance.new("Frame"); Opts.Name="Options"
            Opts.Size=UDim2.fromOffset(330,0); Opts.BackgroundTransparency=1; Opts.BorderSizePixel=0; Opts.Parent=Mod
            local OP=Instance.new("UIPadding",Opts); OP.PaddingTop=UDim.new(0,8); OP.PaddingBottom=UDim.new(0,8)
            local OL=Instance.new("UIListLayout",Opts); OL.Padding=UDim.new(0,5)
            OL.HorizontalAlignment=Enum.HorizontalAlignment.Center; OL.SortOrder=Enum.SortOrder.LayoutOrder

            -- ──────────── change_state ────────────
            function MM:change_state(st)
                self._state=st
                if st then
                    tw(Mod,QL,{Size=UDim2.fromOffset(330,80+self._size+self._multiplier)})
                    tw(Tog,QL,{BackgroundColor3=C.acc}); tw(Cir,QL,{BackgroundColor3=C.txt,Position=UDim2.new(1,-12,0.5,0)})
                    tw(ModStr,QL,{Color=C.acc})
                else
                    tw(Mod,QL,{Size=UDim2.fromOffset(330,80)})
                    tw(Tog,QL,{BackgroundColor3=C.bdr}); tw(Cir,QL,{BackgroundColor3=C.dim,Position=UDim2.new(0,2,0.5,0)})
                    tw(ModStr,QL,{Color=C.bdr})
                end
                Library._config._flags[cfg.flag]=self._state
                Cfg:save(game.GameId,Library._config); cfg.callback(self._state)
            end

            function MM:connect_keybind()
                if not Library._config._keybinds[cfg.flag] then return end
                Connections[cfg.flag.."_kb"]=UIS.InputBegan:Connect(function(inp,proc)
                    if proc then return end
                    if tostring(inp.KeyCode)~=Library._config._keybinds[cfg.flag] then return end
                    self:change_state(not self._state)
                end)
            end

            function MM:scale_keybind(empty)
                if Library._config._keybinds[cfg.flag] and not empty then
                    local ks=string.gsub(tostring(Library._config._keybinds[cfg.flag]),"Enum.KeyCode.","")
                    local fp2=Instance.new("GetTextBoundsParams"); fp2.Text=ks
                    fp2.Font=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                    fp2.Size=9; fp2.Width=10000
                    local fs=TXT:GetTextBoundsAsync(fp2)
                    KB.Size=UDim2.fromOffset(fs.X+8,14)
                else KB.Size=UDim2.fromOffset(30,14) end
            end

            if Library:flag_type(cfg.flag,"boolean") then
                MM._state=true; cfg.callback(true)
                Tog.BackgroundColor3=C.acc; Cir.BackgroundColor3=C.txt
                Cir.Position=UDim2.new(1,-12,0.5,0); ModStr.Color=C.acc
            end
            if Library._config._keybinds[cfg.flag] then
                KBL.Text=string.gsub(tostring(Library._config._keybinds[cfg.flag]),"Enum.KeyCode.","")
                MM:connect_keybind(); MM:scale_keybind()
            end

            Connections[cfg.flag.."_ib"]=Hdr.InputBegan:Connect(function(inp)
                if Library._choosing_keybind then return end
                if inp.UserInputType~=Enum.UserInputType.MouseButton3 then return end
                Library._choosing_keybind=true
                Connections["kcs"]=UIS.InputBegan:Connect(function(ki,proc)
                    if proc then return end
                    if ki.KeyCode==Enum.KeyCode.Unknown then return end
                    if ki.KeyCode==Enum.KeyCode.Backspace then
                        MM:scale_keybind(true); Library._config._keybinds[cfg.flag]=nil
                        Cfg:save(game.GameId,Library._config); KBL.Text="None"
                        if Connections[cfg.flag.."_kb"] then Connections[cfg.flag.."_kb"]:Disconnect(); Connections[cfg.flag.."_kb"]=nil end
                        Connections.kcs:Disconnect(); Connections.kcs=nil; Library._choosing_keybind=false; return
                    end
                    Connections.kcs:Disconnect(); Connections.kcs=nil
                    Library._config._keybinds[cfg.flag]=tostring(ki.KeyCode); Cfg:save(game.GameId,Library._config)
                    if Connections[cfg.flag.."_kb"] then Connections[cfg.flag.."_kb"]:Disconnect(); Connections[cfg.flag.."_kb"]=nil end
                    MM:connect_keybind(); MM:scale_keybind()
                    KBL.Text=string.gsub(tostring(Library._config._keybinds[cfg.flag]),"Enum.KeyCode.","")
                    Library._choosing_keybind=false
                end)
            end)
            Hdr.MouseButton1Click:Connect(function() MM:change_state(not MM._state) end)

            -- ──────────────── PARAGRAPH ────────────────
            function MM:create_paragraph(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+= s.customScale or 56
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local P=Instance.new("Frame"); P.Size=UDim2.fromOffset(308,26)
                P.BackgroundColor3=C.surf3; P.BackgroundTransparency=0.1; P.BorderSizePixel=0
                P.AutomaticSize=Enum.AutomaticSize.Y; P.LayoutOrder=LOM; P.Parent=Opts
                corner(P,UDim.new(0,4))
                local PA=Instance.new("Frame"); PA.Size=UDim2.new(0,2,0.5,0); PA.AnchorPoint=Vector2.new(0,0.5)
                PA.Position=UDim2.new(0,0,0.5,0); PA.BackgroundColor3=C.acc; PA.BorderSizePixel=0; PA.Parent=P; corner(PA,UDim.new(1,0))
                local PT=Instance.new("TextLabel"); PT.Text=s.title or "Title"
                PT.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold)
                PT.TextSize=11; PT.TextColor3=C.txt; PT.BackgroundTransparency=1
                PT.Size=UDim2.new(1,-12,0,17); PT.Position=UDim2.new(0,10,0,5)
                PT.TextXAlignment=Enum.TextXAlignment.Left; PT.AutomaticSize=Enum.AutomaticSize.XY; PT.Parent=P
                local PB=Instance.new("TextLabel")
                PB.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular)
                PB.TextColor3=C.dim; PB.TextSize=10
                if not s.rich then PB.Text=s.text or "" else PB.RichText=true; PB.Text=s.richtext or "" end
                PB.Size=UDim2.new(1,-12,0,12); PB.Position=UDim2.new(0,10,0,24)
                PB.BackgroundTransparency=1; PB.TextXAlignment=Enum.TextXAlignment.Left
                PB.TextYAlignment=Enum.TextYAlignment.Top; PB.TextWrapped=true; PB.AutomaticSize=Enum.AutomaticSize.XY; PB.Parent=P
                P.MouseEnter:Connect(function() tw(P,QT,{BackgroundColor3=Color3.fromRGB(22,26,44)}) end)
                P.MouseLeave:Connect(function() tw(P,QT,{BackgroundColor3=C.surf3}) end)
                return {}
            end

            -- ──────────────── BUTTON ────────────────
            function MM:create_button(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+=26
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local Row=Instance.new("Frame"); Row.Size=UDim2.fromOffset(308,22)
                Row.BackgroundTransparency=1; Row.LayoutOrder=LOM; Row.Parent=Opts
                local BT=Instance.new("TextLabel"); BT.Text=s.title or "Action"
                BT.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                BT.TextSize=10; BT.TextColor3=C.txt; BT.BackgroundTransparency=1
                BT.Size=UDim2.new(1,-30,1,0); BT.TextXAlignment=Enum.TextXAlignment.Left; BT.Parent=Row
                local BB=Instance.new("TextButton"); BB.Size=UDim2.fromOffset(22,22); BB.AnchorPoint=Vector2.new(1,0.5)
                BB.Position=UDim2.new(1,0,0.5,0); BB.BackgroundColor3=C.acc; BB.BackgroundTransparency=0.2
                BB.BorderSizePixel=0; BB.Text=""; BB.AutoButtonColor=false; BB.Parent=Row
                corner(BB,UDim.new(0,5)); stroke(BB,C.acc,1,0.5)
                local BI=Instance.new("ImageLabel"); BI.Image="rbxassetid://139650104834071"
                BI.Size=UDim2.fromOffset(11,11); BI.AnchorPoint=Vector2.new(0.5,0.5); BI.Position=UDim2.new(0.5,0,0.5,0)
                BI.BackgroundTransparency=1; BI.ImageColor3=C.acc; BI.Parent=BB
                task.spawn(function() while BI and BI.Parent do tw(BI,TweenInfo.new(2,Enum.EasingStyle.Linear),{Rotation=BI.Rotation+360}); task.wait(2) end end)
                BB.MouseEnter:Connect(function() tw(BB,QT,{BackgroundTransparency=0}) end)
                BB.MouseLeave:Connect(function() tw(BB,QT,{BackgroundTransparency=0.2}) end)
                BB.MouseButton1Click:Connect(function() if s.callback then s.callback() end end)
                return Row
            end

            -- ──────────────── DISPLAY ────────────────
            function MM:create_display(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                local h=s.height or 106; self._size+=h
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local DF=Instance.new("Frame"); DF.Size=UDim2.fromOffset(308,h)
                DF.BackgroundColor3=C.surf; DF.BackgroundTransparency=0.08; DF.BorderSizePixel=0
                DF.LayoutOrder=LOM; DF.Parent=Opts; corner(DF,UDim.new(0,5))
                local DI=Instance.new("ImageLabel"); DI.Size=UDim2.new(1,-12,1,-20)
                DI.Position=UDim2.new(0.5,0,0,4); DI.AnchorPoint=Vector2.new(0.5,0); DI.BackgroundTransparency=1
                DI.Image=s.image or ""; DI.ScaleType=Enum.ScaleType.Fit; DI.Parent=DF
                local DL=Instance.new("TextLabel"); DL.Text=s.text or ""
                DL.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                DL.TextSize=10; DL.TextColor3=C.dim; DL.BackgroundTransparency=1
                DL.Size=UDim2.new(1,-10,0,16); DL.AnchorPoint=Vector2.new(0.5,1); DL.Position=UDim2.new(0.5,0,1,-2); DL.Parent=DF
                if s.glow then stroke(DL,C.acc,1,0.4) end
                return DF
            end

            -- ──────────────── COLOR PICKER ────────────────
            function MM:create_colorpicker(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+=26
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local Row=Instance.new("Frame"); Row.Size=UDim2.fromOffset(308,22)
                Row.BackgroundTransparency=1; Row.LayoutOrder=LOM; Row.Parent=Opts
                local CT=Instance.new("TextLabel"); CT.Text=s.title or "Color"
                CT.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                CT.TextSize=10; CT.TextColor3=C.txt; CT.BackgroundTransparency=1
                CT.Size=UDim2.new(1,-30,1,0); CT.TextXAlignment=Enum.TextXAlignment.Left; CT.Parent=Row
                local Prev=Instance.new("TextButton"); Prev.Size=UDim2.fromOffset(22,22); Prev.AnchorPoint=Vector2.new(1,0.5)
                Prev.Position=UDim2.new(1,0,0.5,0); Prev.BackgroundColor3=s.default or Color3.new(1,1,1)
                Prev.Text=""; Prev.BorderSizePixel=0; Prev.Parent=Row; corner(Prev,UDim.new(0,4)); stroke(Prev,C.bdr,1)
                local Pop=Instance.new("Frame"); Pop.Size=UDim2.fromOffset(310,285); Pop.AnchorPoint=Vector2.new(0.5,0.5)
                Pop.Position=UDim2.new(0.5,0,0.5,0); Pop.BackgroundColor3=C.surf; Pop.Visible=false
                Pop.ZIndex=9999; Pop.Parent=SG; corner(Pop,UDim.new(0,8)); stroke(Pop,C.acc,1,0.45)
                local PT=Instance.new("TextLabel"); PT.Text="Pick Color"
                PT.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold)
                PT.TextSize=13; PT.TextColor3=C.txt; PT.BackgroundTransparency=1
                PT.Size=UDim2.new(1,0,0,30); PT.ZIndex=10000; PT.Parent=Pop
                local HSB=Instance.new("Frame"); HSB.Size=UDim2.fromOffset(190,190); HSB.Position=UDim2.fromOffset(12,34)
                HSB.BackgroundColor3=Color3.fromHSV(0,1,1); HSB.BorderSizePixel=0; HSB.ZIndex=10000; HSB.Parent=Pop; corner(HSB,UDim.new(0,4))
                local Ov=Instance.new("ImageLabel"); Ov.Size=UDim2.new(1,0,1,0); Ov.BackgroundTransparency=1
                Ov.Image="rbxassetid://4155801252"; Ov.ZIndex=10001; Ov.Active=false; Ov.Parent=HSB
                local Sel=Instance.new("Frame"); Sel.Size=UDim2.fromOffset(12,12); Sel.AnchorPoint=Vector2.new(0.5,0.5)
                Sel.BackgroundColor3=Color3.new(1,1,1); Sel.BorderSizePixel=0; Sel.ZIndex=10002; Sel.Parent=HSB
                corner(Sel,UDim.new(1,0)); stroke(Sel,Color3.new(0,0,0),1.5)
                local HBar=Instance.new("Frame"); HBar.Size=UDim2.fromOffset(18,190); HBar.Position=UDim2.fromOffset(214,34)
                HBar.BorderSizePixel=0; HBar.ZIndex=10000; HBar.Parent=Pop; corner(HBar,UDim.new(0,4))
                local seq={}; for i=0,1,0.1 do table.insert(seq,ColorSequenceKeypoint.new(i,Color3.fromHSV(i,1,1))) end
                local HG=Instance.new("UIGradient"); HG.Color=ColorSequence.new(seq); HG.Rotation=90; HG.Parent=HBar
                local HM=Instance.new("Frame"); HM.Size=UDim2.new(1,4,0,3); HM.Position=UDim2.new(0,-2,0,0)
                HM.BackgroundColor3=Color3.new(1,1,1); HM.BorderSizePixel=0; HM.ZIndex=10001; HM.Parent=HBar; corner(HM,UDim.new(1,0))
                local ABar=Instance.new("Frame"); ABar.Size=UDim2.fromOffset(190,12); ABar.Position=UDim2.fromOffset(12,232)
                ABar.BorderSizePixel=0; ABar.ZIndex=10000; ABar.Parent=Pop; corner(ABar,UDim.new(0,3))
                local AG=Instance.new("UIGradient")
                AG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}; AG.Parent=ABar
                local AM=Instance.new("Frame"); AM.Size=UDim2.new(0,3,1,4); AM.AnchorPoint=Vector2.new(0.5,0.5)
                AM.Position=UDim2.new(1,0,0.5,0); AM.BackgroundColor3=Color3.new(1,1,1); AM.BorderSizePixel=0; AM.ZIndex=10001; AM.Parent=ABar; corner(AM,UDim.new(1,0))
                local HL=Instance.new("TextLabel"); HL.Size=UDim2.fromOffset(100,22); HL.Position=UDim2.new(0,12,1,-32)
                HL.BackgroundTransparency=1; HL.TextColor3=C.txt; HL.Font=Enum.Font.Code; HL.TextSize=11; HL.Text="#FFFFFF"
                HL.TextXAlignment=Enum.TextXAlignment.Left; HL.ZIndex=10002; HL.Parent=Pop
                local RL=Instance.new("TextLabel"); RL.Size=UDim2.fromOffset(190,22); RL.Position=UDim2.new(0,120,1,-32)
                RL.BackgroundTransparency=1; RL.TextColor3=C.dim; RL.Font=Enum.Font.Code; RL.TextSize=11; RL.Text="255 255 255 100%"
                RL.TextXAlignment=Enum.TextXAlignment.Left; RL.ZIndex=10002; RL.Parent=Pop
                local CB=Instance.new("ImageButton"); CB.Image="rbxassetid://10030850935"; CB.Size=UDim2.fromOffset(18,18)
                CB.Position=UDim2.new(1,-24,0,6); CB.BackgroundTransparency=1; CB.ZIndex=10001; CB.Parent=Pop
                local YB=Instance.new("ImageButton"); YB.Image="rbxassetid://10030902360"; YB.Size=UDim2.fromOffset(18,18)
                YB.Position=UDim2.new(1,-46,0,6); YB.BackgroundTransparency=1; YB.ZIndex=10001; YB.Parent=Pop
                local hue,sat,val,alpha=0,1,1,1; local dHS,dH,dA=false,false,false
                local function upd()
                    local col=Color3.fromHSV(hue,sat,val); HSB.BackgroundColor3=Color3.fromHSV(hue,1,1)
                    Sel.Position=UDim2.new(sat,0,1-val,0); Prev.BackgroundColor3=col
                    HL.Text="#"..col:ToHex():upper()
                    RL.Text=("%d %d %d %d%%"):format(col.R*255,col.G*255,col.B*255,math.floor(alpha*100))
                    return col
                end
                HSB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHS=true end end)
                HBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dH=true end end)
                ABar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dA=true end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHS,dH,dA=false,false,false end end)
                UIS.InputChanged:Connect(function(i)
                    if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
                    local p=i.Position
                    if dHS then
                        local mx,ax=HSB.AbsolutePosition.X,HSB.AbsolutePosition.X+HSB.AbsoluteSize.X
                        local my,ay=HSB.AbsolutePosition.Y,HSB.AbsolutePosition.Y+HSB.AbsoluteSize.Y
                        sat=(math.clamp(p.X,mx,ax)-mx)/(ax-mx); val=1-(math.clamp(p.Y,my,ay)-my)/(ay-my); upd()
                    elseif dH then
                        local my,ay=HBar.AbsolutePosition.Y,HBar.AbsolutePosition.Y+HBar.AbsoluteSize.Y
                        hue=(math.clamp(p.Y,my,ay)-my)/(ay-my); HM.Position=UDim2.new(0,-2,hue,0); upd()
                    elseif dA then
                        local mx,ax=ABar.AbsolutePosition.X,ABar.AbsolutePosition.X+ABar.AbsoluteSize.X
                        alpha=(math.clamp(p.X,mx,ax)-mx)/(ax-mx); AM.Position=UDim2.new(alpha,0,0.5,0); upd()
                    end
                end)
                Prev.MouseButton1Click:Connect(function() Pop.Visible=true; Pop.BackgroundTransparency=1; tw(Pop,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundTransparency=0}) end)
                CB.MouseButton1Click:Connect(function() Pop.Visible=false end)
                YB.MouseButton1Click:Connect(function() local col=upd(); if s.callback then s.callback(col,alpha) end; Pop.Visible=false end)
                return {Set=function(_,c) Prev.BackgroundColor3=c end}
            end

            -- ──────────────── 3D VIEW ────────────────
            function MM:create_3dview(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+=220
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local Row=Instance.new("Frame"); Row.Size=UDim2.fromOffset(308,220); Row.BackgroundTransparency=1; Row.LayoutOrder=LOM; Row.Parent=Opts
                local VT=Instance.new("TextLabel"); VT.Text=s.title or "3D View"
                VT.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                VT.TextSize=10; VT.TextColor3=C.txt; VT.BackgroundTransparency=1
                VT.Size=UDim2.new(1,0,0,16); VT.TextXAlignment=Enum.TextXAlignment.Left; VT.Parent=Row
                local Hold=Instance.new("Frame"); Hold.Size=UDim2.new(1,0,1,-16); Hold.Position=UDim2.fromOffset(0,16)
                Hold.BackgroundColor3=C.bg; Hold.ClipsDescendants=true; Hold.BorderSizePixel=0; Hold.Parent=Row
                corner(Hold,UDim.new(0,5)); stroke(Hold,C.bdr,1)
                local ImV=Instance.new("ImageLabel"); ImV.Size=UDim2.fromOffset(120,120); ImV.AnchorPoint=Vector2.new(0.5,0.5)
                ImV.Position=UDim2.new(0.5,0,0.5,0); ImV.BackgroundTransparency=1; ImV.Image=s.image or ""
                ImV.ScaleType=Enum.ScaleType.Fit; ImV.Visible=false; ImV.Parent=Hold
                local VP=Instance.new("ViewportFrame"); VP.Size=UDim2.new(1,0,1,0); VP.BackgroundColor3=C.bg; VP.Visible=false; VP.Parent=Hold; corner(VP,UDim.new(0,5))
                local vpCam=Instance.new("Camera"); vpCam.Parent=VP; VP.CurrentCamera=vpCam
                local curObj,is3D,baseD,curD,oriP,mxD=nil,false,0,0,nil,0
                local function showImg() if curObj then curObj:Destroy() end; is3D=false; ImV.Visible=true; VP.Visible=false end
                local function showMdl(obj)
                    if curObj then curObj:Destroy() end; VP:ClearAllChildren()
                    local nc=Instance.new("Camera"); nc.Parent=VP; VP.CurrentCamera=nc; vpCam=nc
                    obj.Archivable=true; local cl=obj:Clone(); cl.Parent=VP; curObj=cl
                    local cf,sz
                    if cl:IsA("Model") then cf,sz=cl:GetBoundingBox(); oriP=cl:GetPivot().Position
                    elseif cl:IsA("BasePart") then cf,sz=cl.CFrame,cl.Size; oriP=cl.Position
                    else return showImg() end
                    mxD=math.max(sz.X,sz.Y,sz.Z); baseD=mxD*2.5; curD=baseD
                    vpCam.CFrame=CFrame.new(oriP+Vector3.new(0,mxD/2,curD),oriP)
                    VP.Visible=true; ImV.Visible=false; is3D=true
                end
                local function showMsh(mId,tId) local mp=Instance.new("MeshPart"); mp.Size=Vector3.new(5,5,5); mp.MeshId="rbxassetid://"..mId; mp.TextureID="rbxassetid://"..tId; showMdl(mp) end
                if s.model then showMdl(s.model) elseif s.meshId and s.texId then showMsh(s.meshId,s.texId) else showImg() end
                local function mkB(img,pos)
                    local b=Instance.new("ImageButton"); b.Image=img; b.Size=UDim2.fromOffset(20,20)
                    b.BackgroundColor3=C.surf2; b.BackgroundTransparency=0.15; b.Position=pos; b.ZIndex=10; b.Parent=VP
                    corner(b,UDim.new(1,0)); return b
                end
                local uB=mkB("rbxassetid://138007024966757",UDim2.new(0.5,-10,0,4))
                local dB=mkB("rbxassetid://13360801719",    UDim2.new(0.5,-10,1,-24))
                local lB=mkB("rbxassetid://100152237482023",UDim2.new(0,4,0.5,-10))
                local rB=mkB("rbxassetid://140701802205656",UDim2.new(1,-24,0.5,-10))
                local ziB=mkB("rbxassetid://126943351764139",UDim2.new(1,-74,1,-24))
                local zoB=mkB("rbxassetid://110884638624335",UDim2.new(1,-50,1,-24))
                local reB=mkB("rbxassetid://6723921202",     UDim2.new(1,-26,1,-24))
                local function rot(x,y)
                    if is3D and curObj then
                        if curObj:IsA("Model") then curObj:PivotTo(curObj:GetPivot()*CFrame.Angles(0,math.rad(x),math.rad(y)))
                        elseif curObj:IsA("BasePart") then curObj.CFrame=curObj.CFrame*CFrame.Angles(0,math.rad(x),math.rad(y)) end
                    else ImV.Position=ImV.Position+UDim2.new(0,x*5,0,-y*5) end
                end
                local function zoom(td)
                    if not (is3D and oriP) then return end
                    curD=math.clamp(td,mxD*0.5,mxD*6)
                    tw(vpCam,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{CFrame=CFrame.new(oriP+Vector3.new(0,mxD/2,curD),oriP)})
                end
                uB.MouseButton1Click:Connect(function() rot(0,10) end)
                dB.MouseButton1Click:Connect(function() rot(0,-10) end)
                lB.MouseButton1Click:Connect(function() rot(-10,0) end)
                rB.MouseButton1Click:Connect(function() rot(10,0) end)
                ziB.MouseButton1Click:Connect(function() zoom(curD-0.5*mxD) end)
                zoB.MouseButton1Click:Connect(function() zoom(curD+0.5*mxD) end)
                reB.MouseButton1Click:Connect(function() if is3D then zoom(baseD) else ImV.Position=UDim2.new(0.5,0,0.5,0) end end)
                return {SetModel=function(_,m) if m then showMdl(m) end end, SetMesh=function(_,mi,ti) showMsh(mi,ti) end, SetImage=function(_,i) s.image=i; showImg() end}
            end

            -- ──────────────── TEXT ────────────────
            function MM:create_text(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+= s.customScale or 46
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local TF=Instance.new("Frame"); TF.Size=UDim2.fromOffset(308,s.CustomYSize or 30)
                TF.BackgroundColor3=C.surf3; TF.BackgroundTransparency=0.1; TF.BorderSizePixel=0
                TF.AutomaticSize=Enum.AutomaticSize.Y; TF.LayoutOrder=LOM; TF.Parent=Opts; corner(TF,UDim.new(0,4))
                local TB2=Instance.new("TextLabel")
                TB2.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular)
                TB2.TextColor3=C.dim; TB2.TextSize=10
                if not s.rich then TB2.Text=s.text or "" else TB2.RichText=true; TB2.Text=s.richtext or "" end
                TB2.Size=UDim2.new(1,-10,1,0); TB2.Position=UDim2.new(0,5,0,5); TB2.BackgroundTransparency=1
                TB2.TextXAlignment=Enum.TextXAlignment.Left; TB2.TextYAlignment=Enum.TextYAlignment.Top
                TB2.TextWrapped=true; TB2.AutomaticSize=Enum.AutomaticSize.XY; TB2.Parent=TF
                TF.MouseEnter:Connect(function() tw(TF,QT,{BackgroundColor3=Color3.fromRGB(22,26,44)}) end)
                TF.MouseLeave:Connect(function() tw(TF,QT,{BackgroundColor3=C.surf3}) end)
                local TxM={}
                function TxM:Set(ns)
                    if not ns.rich then TB2.Text=ns.text or "" else TB2.RichText=true; TB2.Text=ns.richtext or "" end
                end
                return TxM
            end

            -- ──────────────── TEXTBOX ────────────────
            function MM:create_textbox(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+=30
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local Lbl=Instance.new("TextLabel"); Lbl.Text=s.title or "Enter text"
                Lbl.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                Lbl.TextSize=10; Lbl.TextColor3=C.dim; Lbl.BackgroundTransparency=1
                Lbl.Size=UDim2.fromOffset(308,13); Lbl.TextXAlignment=Enum.TextXAlignment.Left
                Lbl.LayoutOrder=LOM; Lbl.Parent=Opts
                local TBox=Instance.new("TextBox"); TBox.Name="Textbox"
                TBox.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular)
                TBox.TextColor3=C.txt; TBox.PlaceholderText=s.placeholder or "Type here..."
                TBox.Text=Library._config._flags[s.flag] or ""; TBox.TextSize=10
                TBox.Size=UDim2.fromOffset(308,16); TBox.BackgroundColor3=C.acc; TBox.BackgroundTransparency=0.88
                TBox.BorderSizePixel=0; TBox.ClearTextOnFocus=false; TBox.LayoutOrder=LOM; TBox.Parent=Opts
                corner(TBox,UDim.new(0,4)); stroke(TBox,C.bdr,1)
                TBox.Focused:Connect(function() tw(TBox,QT,{BackgroundTransparency=0.75}) end)
                TBox.FocusLost:Connect(function()
                    tw(TBox,QT,{BackgroundTransparency=0.88})
                    Library._config._flags[s.flag]=TBox.Text; Cfg:save(game.GameId,Library._config)
                    if s.callback then s.callback(TBox.Text) end
                end)
                if Library:flag_type(s.flag,"string") then
                    TBox.Text=Library._config._flags[s.flag]
                    if s.callback then s.callback(TBox.Text) end
                end
                return {_text=TBox.Text}
            end

            -- ──────────────── CHECKBOX ────────────────
            function MM:create_checkbox(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+=20
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local CM={_state=false}
                local Chk=Instance.new("TextButton"); Chk.Name="Checkbox"
                Chk.Size=UDim2.fromOffset(308,16); Chk.BackgroundTransparency=1; Chk.Text=""
                Chk.AutoButtonColor=false; Chk.BorderSizePixel=0; Chk.LayoutOrder=LOM; Chk.Parent=Opts
                local ChkL=Instance.new("TextLabel")
                ChkL.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                ChkL.TextSize=10; ChkL.TextColor3=C.txt; ChkL.TextTransparency=0.05; ChkL.Text=s.title or ""
                ChkL.Size=UDim2.new(1,-46,1,0); ChkL.AnchorPoint=Vector2.new(0,0.5); ChkL.Position=UDim2.new(0,0,0.5,0)
                ChkL.BackgroundTransparency=1; ChkL.TextXAlignment=Enum.TextXAlignment.Left; ChkL.Parent=Chk
                -- keybind box
                local KBx=Instance.new("Frame"); KBx.Size=UDim2.fromOffset(14,14); KBx.AnchorPoint=Vector2.new(1,0.5)
                KBx.Position=UDim2.new(1,-22,0.5,0); KBx.BackgroundColor3=C.surf; KBx.BorderSizePixel=0; KBx.Parent=Chk
                corner(KBx,UDim.new(0,3)); stroke(KBx,C.bdr,1)
                local KBxL=Instance.new("TextLabel"); KBxL.Size=UDim2.new(1,0,1,0); KBxL.BackgroundTransparency=1
                KBxL.TextColor3=C.dim; KBxL.TextSize=9; KBxL.Font=Enum.Font.SourceSans
                KBxL.Text=Library._config._keybinds[s.flag] and string.gsub(tostring(Library._config._keybinds[s.flag]),"Enum.KeyCode.","") or "..."
                KBxL.Parent=KBx
                -- checkbox square
                local Box=Instance.new("Frame"); Box.Size=UDim2.fromOffset(14,14); Box.AnchorPoint=Vector2.new(1,0.5)
                Box.Position=UDim2.new(1,-2,0.5,0); Box.BackgroundColor3=C.surf; Box.BackgroundTransparency=0.9
                Box.BorderSizePixel=0; Box.Parent=Chk; corner(Box,UDim.new(0,3)); stroke(Box,C.bdr,1)
                local Fill=Instance.new("Frame"); Fill.AnchorPoint=Vector2.new(0.5,0.5); Fill.Position=UDim2.new(0.5,0,0.5,0)
                Fill.Size=UDim2.fromOffset(0,0); Fill.BackgroundColor3=C.acc; Fill.BorderSizePixel=0; Fill.Parent=Box; corner(Fill,UDim.new(0,2))
                function CM:change_state(st)
                    self._state=st
                    if st then tw(Box,QT,{BackgroundTransparency=0.7}); tw(Fill,QT,{Size=UDim2.fromOffset(8,8)})
                    else tw(Box,QT,{BackgroundTransparency=0.9}); tw(Fill,QT,{Size=UDim2.fromOffset(0,0)}) end
                    Library._config._flags[s.flag]=self._state; Cfg:save(game.GameId,Library._config); s.callback(self._state)
                end
                if Library:flag_type(s.flag,"boolean") then CM:change_state(Library._config._flags[s.flag]) end
                Chk.MouseButton1Click:Connect(function() CM:change_state(not CM._state) end)
                Chk.InputBegan:Connect(function(inp,gp)
                    if gp or inp.UserInputType~=Enum.UserInputType.MouseButton3 or Library._choosing_keybind then return end
                    Library._choosing_keybind=true
                    local cc; cc=UIS.InputBegan:Connect(function(ki,proc)
                        if proc or ki.UserInputType~=Enum.UserInputType.Keyboard or ki.KeyCode==Enum.KeyCode.Unknown then return end
                        if ki.KeyCode==Enum.KeyCode.Backspace then
                            Library._config._keybinds[s.flag]=nil; Cfg:save(game.GameId,Library._config); KBxL.Text="..."
                            if Connections[s.flag.."_ckb"] then Connections[s.flag.."_ckb"]:Disconnect(); Connections[s.flag.."_ckb"]=nil end
                            cc:Disconnect(); Library._choosing_keybind=false; return
                        end
                        cc:Disconnect(); Library._config._keybinds[s.flag]=tostring(ki.KeyCode); Cfg:save(game.GameId,Library._config)
                        if Connections[s.flag.."_ckb"] then Connections[s.flag.."_ckb"]:Disconnect(); Connections[s.flag.."_ckb"]=nil end
                        Connections[s.flag.."_ckb"]=UIS.InputBegan:Connect(function(i2,p2)
                            if p2 then return end
                            if tostring(i2.KeyCode)==Library._config._keybinds[s.flag] then CM:change_state(not CM._state) end
                        end)
                        KBxL.Text=string.gsub(tostring(Library._config._keybinds[s.flag]),"Enum.KeyCode.",""); Library._choosing_keybind=false
                    end)
                end)
                Connections[s.flag.."_ckp"]=UIS.InputBegan:Connect(function(inp,gp)
                    if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                    local sk=Library._config._keybinds[s.flag]
                    if sk and tostring(inp.KeyCode)==sk then CM:change_state(not CM._state) end
                end)
                return CM
            end

            -- ──────────────── DIVIDER ────────────────
            function MM:create_divider(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+=24
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local OF=Instance.new("Frame"); OF.Size=UDim2.fromOffset(308,18); OF.BackgroundTransparency=1
                OF.LayoutOrder=LOM; OF.Parent=Opts
                if s and s.showtopic then
                    local SL=Instance.new("TextLabel"); SL.Text=s.title or ""
                    SL.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                    SL.TextSize=10; SL.TextColor3=C.dim; SL.BackgroundTransparency=1
                    SL.Size=UDim2.new(0,130,1,0); SL.AnchorPoint=Vector2.new(0.5,0.5); SL.Position=UDim2.new(0.5,0,0.5,0)
                    SL.TextXAlignment=Enum.TextXAlignment.Center; SL.ZIndex=3; SL.TextStrokeTransparency=0; SL.Parent=OF
                end
                if not s or not s.disableline then
                    local Div=Instance.new("Frame"); Div.Size=UDim2.new(1,0,0,1); Div.Position=UDim2.new(0,0,0.5,-1)
                    Div.BackgroundColor3=C.acc; Div.BorderSizePixel=0; Div.ZIndex=2; Div.Parent=OF; corner(Div,UDim.new(0,1))
                    local DG=Instance.new("UIGradient"); DG.Parent=Div
                    DG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}
                    DG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.acc),ColorSequenceKeypoint.new(1,C.acc2)}
                end
                return true
            end

            -- ──────────────── SLIDER ────────────────
            function MM:create_slider(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+=28
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local SM={}
                local Sld=Instance.new("TextButton"); Sld.Name="Slider"
                Sld.Size=UDim2.fromOffset(308,24); Sld.BackgroundTransparency=1; Sld.Text=""; Sld.AutoButtonColor=false
                Sld.BorderSizePixel=0; Sld.LayoutOrder=LOM; Sld.Parent=Opts
                local STL=Instance.new("TextLabel")
                if GG.SelectedLanguage=="th" then
                    STL.FontFace=Font.new("rbxasset://fonts/families/NotoSansThai.json",Enum.FontWeight.SemiBold); STL.TextSize=12
                else STL.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold); STL.TextSize=10 end
                STL.TextColor3=C.txt; STL.TextTransparency=0.2; STL.Text=s.title
                STL.Size=UDim2.fromOffset(200,13); STL.Position=UDim2.new(0,0,0,0)
                STL.BackgroundTransparency=1; STL.TextXAlignment=Enum.TextXAlignment.Left; STL.Parent=Sld
                local SVL=Instance.new("TextLabel"); SVL.Text="0"; SVL.Name="Value"
                SVL.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                SVL.TextSize=10; SVL.TextColor3=C.acc; SVL.BackgroundTransparency=1
                SVL.Size=UDim2.fromOffset(50,13); SVL.AnchorPoint=Vector2.new(1,0); SVL.Position=UDim2.new(1,0,0,0)
                SVL.TextXAlignment=Enum.TextXAlignment.Right; SVL.Parent=Sld
                local Drg=Instance.new("Frame"); Drg.Name="Drag"; Drg.AnchorPoint=Vector2.new(0.5,1)
                Drg.Size=UDim2.fromOffset(308,4); Drg.Position=UDim2.new(0.5,0,1,0)
                Drg.BackgroundColor3=C.bdr; Drg.BackgroundTransparency=0.4; Drg.BorderSizePixel=0; Drg.Parent=Sld; corner(Drg,UDim.new(1,0))
                local Fil=Instance.new("Frame"); Fil.Name="Fill"; Fil.AnchorPoint=Vector2.new(0,0.5)
                Fil.Size=UDim2.fromOffset(100,4); Fil.Position=UDim2.new(0,0,0.5,0)
                Fil.BackgroundColor3=C.acc; Fil.BorderSizePixel=0; Fil.Parent=Drg; corner(Fil,UDim.new(1,0)); accGrad(Fil)
                local Knob=Instance.new("Frame"); Knob.Name="Circle"; Knob.AnchorPoint=Vector2.new(1,0.5)
                Knob.Size=UDim2.fromOffset(8,8); Knob.Position=UDim2.new(1,0,0.5,0)
                Knob.BackgroundColor3=Color3.new(1,1,1); Knob.BorderSizePixel=0; Knob.Parent=Fil; corner(Knob,UDim.new(1,0))
                function SM:set_percentage(pct)
                    if pct==nil or type(pct)~="number" then return end
                    local rn = s.round_number and math.floor(pct) or math.floor(pct*10)/10
                    local norm=(pct-s.minimum_value)/(s.maximum_value-s.minimum_value)
                    local sz=math.clamp(norm,0.02,1)*Drg.Size.X.Offset
                    local clamp=math.clamp(rn,s.minimum_value,s.maximum_value)
                    Library._config._flags[s.flag]=clamp; SVL.Text=clamp
                    tw(Fil,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(sz,Drg.Size.Y.Offset)})
                    if s.callback then s.callback(clamp) end
                end
                function SM:update()
                    local mp=(mouse.X-Drg.AbsolutePosition.X)/Drg.Size.X.Offset
                    self:set_percentage(s.minimum_value+(s.maximum_value-s.minimum_value)*mp)
                end
                function SM:input()
                    SM:update()
                    Connections["sdrag_"..s.flag]=mouse.Move:Connect(function() SM:update() end)
                    Connections["sinp_"..s.flag]=UIS.InputEnded:Connect(function(inp)
                        if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
                        Connections:disconnect("sdrag_"..s.flag); Connections:disconnect("sinp_"..s.flag)
                        if not s.ignoresaved then Cfg:save(game.GameId,Library._config) end
                    end)
                end
                if Library:flag_type(s.flag,"number") then
                    if not s.ignoresaved then SM:set_percentage(Library._config._flags[s.flag]) else SM:set_percentage(s.value) end
                else SM:set_percentage(s.value) end
                Sld.MouseButton1Down:Connect(function() SM:input() end)
                return SM
            end

            -- ──────────────── DROPDOWN ────────────────
            function MM:create_dropdown(s)
                if not s.Order then LOM+=1 end
                local DM={_state=false,_size=0}
                if not s.Order then
                    if self._size==0 then self._size=8 end
                    self._size+=44
                    if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                    Opts.Size=UDim2.fromOffset(330,self._size)
                end
                local DD=Instance.new("TextButton"); DD.Name="Dropdown"
                DD.Size=UDim2.fromOffset(308,40); DD.BackgroundTransparency=1; DD.Text=""; DD.AutoButtonColor=false
                DD.BorderSizePixel=0; DD.Parent=Opts
                if not s.Order then DD.LayoutOrder=LOM else DD.LayoutOrder=s.OrderValue end
                if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={} end
                local DTL=Instance.new("TextLabel"); DTL.Text=s.title
                if GG.SelectedLanguage=="th" then
                    DTL.FontFace=Font.new("rbxasset://fonts/families/NotoSansThai.json",Enum.FontWeight.SemiBold); DTL.TextSize=12
                else DTL.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold); DTL.TextSize=10 end
                DTL.TextColor3=C.txt; DTL.TextTransparency=0.2
                DTL.Size=UDim2.fromOffset(308,14); DTL.BackgroundTransparency=1
                DTL.TextXAlignment=Enum.TextXAlignment.Left; DTL.Parent=DD
                local DBox=Instance.new("Frame"); DBox.Name="Box"; DBox.ClipsDescendants=true
                DBox.AnchorPoint=Vector2.new(0.5,0); DBox.BackgroundColor3=C.surf; DBox.BackgroundTransparency=0.6
                DBox.Position=UDim2.new(0.5,0,1.15,0); DBox.Size=UDim2.fromOffset(308,22)
                DBox.BorderSizePixel=0; DBox.Parent=DTL; corner(DBox,UDim.new(0,4)); stroke(DBox,C.bdr,1)
                local DHdr=Instance.new("Frame"); DHdr.AnchorPoint=Vector2.new(0.5,0); DHdr.BackgroundTransparency=1
                DHdr.Position=UDim2.new(0.5,0,0,0); DHdr.Size=UDim2.fromOffset(308,22); DHdr.Parent=DBox
                local DCO=Instance.new("TextLabel"); DCO.Name="CurrentOption"
                DCO.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                DCO.TextColor3=C.txt; DCO.TextTransparency=0.05; DCO.TextSize=10
                DCO.Size=UDim2.fromOffset(270,13); DCO.AnchorPoint=Vector2.new(0,0.5); DCO.Position=UDim2.new(0,8,0.5,0)
                DCO.BackgroundTransparency=1; DCO.TextXAlignment=Enum.TextXAlignment.Left; DCO.Parent=DHdr
                local DCG=Instance.new("UIGradient"); DCG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.72,0),NumberSequenceKeypoint.new(0.9,0.4),NumberSequenceKeypoint.new(1,1)}; DCG.Parent=DCO
                local DAr=Instance.new("ImageLabel"); DAr.Image="rbxassetid://84232453189324"; DAr.AnchorPoint=Vector2.new(0,0.5)
                DAr.BackgroundTransparency=1; DAr.Position=UDim2.new(1,-18,0.5,0); DAr.Size=UDim2.fromOffset(8,8); DAr.Parent=DHdr
                local DOpts=Instance.new("ScrollingFrame"); DOpts.Name="Options"; DOpts.Active=true
                DOpts.AutomaticCanvasSize=Enum.AutomaticSize.XY; DOpts.ScrollBarThickness=0
                DOpts.ScrollBarImageTransparency=1; DOpts.Size=UDim2.fromOffset(308,0)
                DOpts.BackgroundTransparency=1; DOpts.Position=UDim2.new(0,0,1,0); DOpts.CanvasSize=UDim2.new(0,0,0.5,0)
                DOpts.Parent=DBox
                local DOL=Instance.new("UIListLayout",DOpts); DOL.SortOrder=Enum.SortOrder.LayoutOrder
                local DOP=Instance.new("UIPadding",DOpts); DOP.PaddingLeft=UDim.new(0,8)
                Instance.new("UIListLayout",DBox).SortOrder=Enum.SortOrder.LayoutOrder

                function DM:update(opt)
                    if s.multi_dropdown then
                        if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={} end
                        local sel={}
                        if #Library._config._flags[s.flag]>0 then
                            for _,v in convertStringToTable(convertTableToString(Library._config._flags[s.flag])) do table.insert(sel,v) end
                        else for v in string.gmatch(DCO.Text,"([^,]+)") do table.insert(sel,v:match("^%s*(.-)%s*$")) end end
                        local optN=typeof(opt)~="string" and opt.Name or opt
                        local found=false
                        for i,v in sel do if v==optN then table.remove(sel,i); found=true; break end end
                        if not found then table.insert(sel,optN) end
                        DCO.Text=table.concat(sel,", ")
                        for _,o in DOpts:GetChildren() do
                            if o.Name=="Option" then o.TextTransparency=table.find(sel,o.Text) and 0.2 or 0.6 end
                        end
                        Library._config._flags[s.flag]=convertStringToTable(DCO.Text)
                    else
                        DCO.Text=typeof(opt)=="string" and opt or opt.Name
                        for _,o in DOpts:GetChildren() do
                            if o.Name=="Option" then o.TextTransparency=o.Text==DCO.Text and 0.2 or 0.6 end
                        end
                        Library._config._flags[s.flag]=opt
                    end
                    Cfg:save(game.GameId,Library._config); s.callback(opt)
                end

                local CDS=0
                function DM:unfold_settings()
                    self._state=not self._state
                    if self._state then
                        MM._multiplier+=self._size; CDS=self._size
                        tw(Mod,QL,{Size=UDim2.fromOffset(330,80+MM._size+MM._multiplier)})
                        tw(Mod.Options,QL,{Size=UDim2.fromOffset(330,MM._size+MM._multiplier)})
                        tw(DD,QL,{Size=UDim2.fromOffset(308,40+self._size)})
                        tw(DBox,QL,{Size=UDim2.fromOffset(308,22+self._size)})
                        tw(DAr,QL,{Rotation=180})
                    else
                        MM._multiplier-=self._size; CDS=0
                        tw(Mod,QL,{Size=UDim2.fromOffset(330,80+MM._size+MM._multiplier)})
                        tw(Mod.Options,QL,{Size=UDim2.fromOffset(330,MM._size+MM._multiplier)})
                        tw(DD,QL,{Size=UDim2.fromOffset(308,40)})
                        tw(DBox,QL,{Size=UDim2.fromOffset(308,22)})
                        tw(DAr,QL,{Rotation=0})
                    end
                end

                if #s.options>0 then
                    DM._size=3
                    local maxO=s.maximum_options or #s.options
                    for idx,val in s.options do
                        local Opt=Instance.new("TextButton"); Opt.Name="Option"
                        Opt.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold)
                        Opt.Active=false; Opt.TextTransparency=0.6; Opt.TextSize=10
                        Opt.Size=UDim2.fromOffset(285,16); Opt.TextColor3=C.txt; Opt.BorderSizePixel=0
                        Opt.Text=typeof(val)=="string" and val or val.Name
                        Opt.AutoButtonColor=false; Opt.BackgroundTransparency=1; Opt.TextXAlignment=Enum.TextXAlignment.Left
                        Opt.Selectable=false; Opt.Parent=DOpts
                        local OG=Instance.new("UIGradient"); OG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.7,0),NumberSequenceKeypoint.new(0.9,0.4),NumberSequenceKeypoint.new(1,1)}; OG.Parent=Opt
                        Opt.MouseEnter:Connect(function() tw(Opt,QT,{TextTransparency=0}) end)
                        Opt.MouseLeave:Connect(function() tw(Opt,QT,{TextTransparency=0.6}) end)
                        Opt.MouseButton1Click:Connect(function()
                            if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={} end
                            if s.multi_dropdown then
                                if table.find(Library._config._flags[s.flag],val) then Library:remove_table_value(Library._config._flags[s.flag],val)
                                else table.insert(Library._config._flags[s.flag],val) end
                            end
                            DM:update(val)
                        end)
                        if idx<=maxO then DM._size+=16; DOpts.Size=UDim2.fromOffset(285,DM._size) end
                    end
                end

                function DM:New(v)
                    DD:Destroy(); v.OrderValue=DD.LayoutOrder; MM._multiplier-=CDS
                    return MM:create_dropdown(v)
                end

                if Library:flag_type(s.flag,"string") then DM:update(Library._config._flags[s.flag])
                else DM:update(s.options[1]) end
                DD.MouseButton1Click:Connect(function() DM:unfold_settings() end)
                return DM
            end

            -- ──────────────── FEATURE ────────────────
            function MM:create_feature(s)
                LOM+=1
                if self._size==0 then self._size=8 end
                self._size+=20
                if MM._state then Mod.Size=UDim2.fromOffset(330,80+self._size) end
                Opts.Size=UDim2.fromOffset(330,self._size)
                local checked=false
                local FC=Instance.new("Frame"); FC.Size=UDim2.fromOffset(308,16); FC.BackgroundTransparency=1
                FC.LayoutOrder=LOM; FC.Parent=Opts
                local FCL=Instance.new("UIListLayout",FC); FCL.FillDirection=Enum.FillDirection.Horizontal; FCL.SortOrder=Enum.SortOrder.LayoutOrder
                local FB=Instance.new("TextButton"); FB.Size=UDim2.new(1,-38,0,16); FB.BackgroundColor3=C.surf3
                FB.TextColor3=C.txt; FB.Text="    "..(s.title or "Feature"); FB.AutoButtonColor=false
                FB.TextXAlignment=Enum.TextXAlignment.Left; FB.TextTransparency=0.05
                FB.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold); FB.TextSize=10; FB.Parent=FC
                local RC=Instance.new("Frame"); RC.Size=UDim2.fromOffset(38,16); RC.BackgroundTransparency=1; RC.Parent=FC
                local RL=Instance.new("UIListLayout",RC); RL.Padding=UDim.new(0.08,0); RL.FillDirection=Enum.FillDirection.Horizontal; RL.HorizontalAlignment=Enum.HorizontalAlignment.Right; RL.SortOrder=Enum.SortOrder.LayoutOrder
                local KBxF=Instance.new("TextLabel"); KBxF.Size=UDim2.fromOffset(15,15); KBxF.BackgroundColor3=C.surf
                KBxF.TextColor3=C.dim; KBxF.TextSize=10; KBxF.BackgroundTransparency=1; KBxF.LayoutOrder=2
                KBxF.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold); KBxF.Parent=RC
                local KBBtn=Instance.new("TextButton"); KBBtn.Size=UDim2.new(1,0,1,0); KBBtn.BackgroundTransparency=1; KBBtn.TextTransparency=1; KBBtn.Parent=KBxF
                corner(KBxF,UDim.new(0,3)); stroke(KBxF,C.bdr,1)
                if not Library._config._flags then Library._config._flags={} end
                if not Library._config._flags[s.flag] then Library._config._flags[s.flag]={checked=false,BIND=s.default or "Unknown"} end
                checked=Library._config._flags[s.flag].checked
                KBxF.Text=Library._config._flags[s.flag].BIND=="Unknown" and "..." or Library._config._flags[s.flag].BIND
                local UseF
                if not s.disablecheck then
                    local CB2=Instance.new("TextButton"); CB2.Size=UDim2.fromOffset(15,15)
                    CB2.BackgroundColor3=checked and C.acc or C.surf; CB2.Text=""; CB2.LayoutOrder=1; CB2.Parent=RC
                    stroke(CB2,C.bdr,1); corner(CB2,UDim.new(0,3))
                    local function tog() checked=not checked; CB2.BackgroundColor3=checked and C.acc or C.surf; Library._config._flags[s.flag].checked=checked; Cfg:save(game.GameId,Library._config); if s.callback then s.callback(checked) end end
                    UseF=tog; CB2.MouseButton1Click:Connect(tog)
                else UseF=function() s.button_callback() end end
                KBBtn.MouseButton1Click:Connect(function()
                    KBxF.Text="..."
                    local ic; ic=UIS.InputBegan:Connect(function(inp,gp)
                        if gp then return end
                        if inp.UserInputType==Enum.UserInputType.Keyboard then
                            local nk=inp.KeyCode.Name; Library._config._flags[s.flag].BIND=nk
                            KBxF.Text=nk~="Unknown" and nk or "..."; Cfg:save(game.GameId,Library._config); ic:Disconnect()
                        elseif inp.UserInputType==Enum.UserInputType.MouseButton3 then
                            Library._config._flags[s.flag].BIND="Unknown"; KBxF.Text="..."; Cfg:save(game.GameId,Library._config); ic:Disconnect()
                        end
                    end); Connections["kbf_"..s.flag]=ic
                end)
                Connections["kbfp_"..s.flag]=UIS.InputBegan:Connect(function(inp,gp)
                    if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode.Name==Library._config._flags[s.flag].BIND then UseF() end
                end)
                FB.MouseButton1Click:Connect(function() if s.button_callback then s.button_callback() end end)
                if not s.disablecheck then s.callback(checked) end
                return FC
            end

            return MM
        end -- create_module

        return TM
    end -- create_tab

    -- toggle visibility
    Connections.vis=UIS.InputBegan:Connect(function(inp,proc)
        if inp.KeyCode~=Enum.KeyCode.Insert then return end
        self._ui_open=not self._ui_open; self:change_visiblity(self._ui_open)
    end)
    Min.MouseButton1Click:Connect(function()
        self._ui_open=not self._ui_open; self:change_visiblity(self._ui_open)
    end)

    return self
end -- create_ui

return Library
