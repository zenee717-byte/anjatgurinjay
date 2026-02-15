--// Gnnrs UI Library (Fixed + Keybind Support)

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Library = {
    connections = {},
    Flags = {},
    Enabled = true,
    core = nil
}

local FolderName = "Gnnrs"
local SaveFlagsG = true

if not isfolder(FolderName) then
    makefolder(FolderName)
end

function Library:SaveFlags()
    if not SaveFlagsG then return end

    pcall(function()
        writefile(
            FolderName.."/"..game.GameId..".json",
            HttpService:JSONEncode(self.Flags)
        )
    end)
end

function Library:LoadFlags()
    if not SaveFlagsG then return end

    pcall(function()
        local path = FolderName.."/"..game.GameId..".json"

        if isfile(path) then
            self.Flags = HttpService:JSONDecode(readfile(path))
        end
    end)
end

function Library:ToggleUI()

    self.Enabled = not self.Enabled

    if self.Container then
        self.Container.Visible = self.Enabled
    end

    if self.Shadow then
        self.Shadow.Visible = self.Enabled
    end

end

function Library:CreateWindow(title)

    self:LoadFlags()

    if self.core then
        self.core:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Gnnrs"
    ScreenGui.Parent = CoreGui

    self.core = ScreenGui

    local Shadow = Instance.new("Frame")
    Shadow.Parent = ScreenGui
    Shadow.Size = UDim2.new(0,700,0,430)
    Shadow.Position = UDim2.new(0.5,-350,0.5,-215)
    Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Shadow.BackgroundTransparency = 0.3

    self.Shadow = Shadow

    local Container = Instance.new("Frame")
    Container.Parent = ScreenGui
    Container.Size = UDim2.new(0,700,0,430)
    Container.Position = UDim2.new(0.5,-350,0.5,-215)
    Container.BackgroundColor3 = Color3.fromRGB(19,20,24)

    Instance.new("UICorner",Container).CornerRadius = UDim.new(0,12)

    self.Container = Container

    local Title = Instance.new("TextLabel")
    Title.Parent = Container
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Gnnrs"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16

    local TabsFrame = Instance.new("Frame")
    TabsFrame.Parent = Container
    TabsFrame.Size = UDim2.new(0,180,1,-40)
    TabsFrame.Position = UDim2.new(0,0,0,40)
    TabsFrame.BackgroundTransparency = 1

    local UIList = Instance.new("UIListLayout",TabsFrame)
    UIList.Padding = UDim.new(0,4)

    local Pages = Instance.new("Frame")
    Pages.Parent = Container
    Pages.Size = UDim2.new(1,-180,1,-40)
    Pages.Position = UDim2.new(0,180,0,40)
    Pages.BackgroundTransparency = 1

    local Window = {}

    Window.Tabs = {}

    function Window:CreateTab(name)

        local Button = Instance.new("TextButton")
        Button.Parent = TabsFrame
        Button.Size = UDim2.new(1,0,0,35)
        Button.Text = name
        Button.BackgroundColor3 = Color3.fromRGB(30,30,35)
        Button.TextColor3 = Color3.new(1,1,1)

        Instance.new("UICorner",Button)

        local Page = Instance.new("Frame")
        Page.Parent = Pages
        Page.Size = UDim2.new(1,0,1,0)
        Page.Visible = false
        Page.BackgroundTransparency = 1

        local Layout = Instance.new("UIListLayout",Page)
        Layout.Padding = UDim.new(0,5)

        Button.MouseButton1Click:Connect(function()

            for _,v in pairs(Pages:GetChildren()) do
                if v:IsA("Frame") then
                    v.Visible = false
                end
            end

            Page.Visible = true

        end)

        local Tab = {}

        function Tab:AddToggleWithKeybind(cfg)

            local Flag = cfg.Flag or cfg.Name

            if Library.Flags[Flag] == nil then
                Library.Flags[Flag] = cfg.Default or false
            end

            local Enabled = Library.Flags[Flag]
            local Keybind = cfg.Keybind or Enum.KeyCode.E
            local Waiting = false

            local Holder = Instance.new("Frame")
            Holder.Parent = Page
            Holder.Size = UDim2.new(1,-10,0,30)
            Holder.BackgroundTransparency = 1

            local Label = Instance.new("TextLabel")
            Label.Parent = Holder
            Label.Size = UDim2.new(0.6,0,1,0)
            Label.BackgroundTransparency = 1
            Label.Text = cfg.Name
            Label.TextColor3 = Color3.new(1,1,1)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Parent = Holder
            KeyBtn.Size = UDim2.new(0,40,0,20)
            KeyBtn.Position = UDim2.new(0.65,0,0.5,-10)
            KeyBtn.Text = Keybind.Name
            KeyBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            KeyBtn.TextColor3 = Color3.new(1,1,1)

            Instance.new("UICorner",KeyBtn)

            local Toggle = Instance.new("TextButton")
            Toggle.Parent = Holder
            Toggle.Size = UDim2.new(0,40,0,20)
            Toggle.Position = UDim2.new(0.85,0,0.5,-10)
            Toggle.BackgroundColor3 =
                Enabled and Color3.fromRGB(140,70,255)
                or Color3.fromRGB(60,60,60)

            Instance.new("UICorner",Toggle)

            local function Set(state)

                Enabled = state
                Library.Flags[Flag] = state

                Toggle.BackgroundColor3 =
                    state and Color3.fromRGB(140,70,255)
                    or Color3.fromRGB(60,60,60)

                Library:SaveFlags()

                if cfg.Callback then
                    cfg.Callback(state)
                end

            end

            Toggle.MouseButton1Click:Connect(function()
                Set(not Enabled)
            end)

            KeyBtn.MouseButton1Click:Connect(function()

                Waiting = true
                KeyBtn.Text = "..."

            end)

            UserInputService.InputBegan:Connect(function(input,gpe)

                if gpe then return end

                if Waiting then

                    if input.KeyCode ~= Enum.KeyCode.Unknown then

                        Keybind = input.KeyCode
                        KeyBtn.Text = Keybind.Name
                        Waiting = false

                    end

                    return
                end

                if input.KeyCode == Keybind then
                    Set(not Enabled)
                end

            end)

            if cfg.Callback then
                cfg.Callback(Enabled)
            end

        end

        return Tab

    end

    local Mobile = Instance.new("TextButton")
    Mobile.Parent = ScreenGui
    Mobile.Size = UDim2.new(0,50,0,50)
    Mobile.Position = UDim2.new(0,20,0.8,0)
    Mobile.Text = "G"

    Instance.new("UICorner",Mobile)

    Mobile.MouseButton1Click:Connect(function()
        Library:ToggleUI()
    end)

    UserInputService.InputBegan:Connect(function(input,gpe)

        if gpe then return end

        if input.KeyCode == Enum.KeyCode.RightControl then
            Library:ToggleUI()
        end

    end)

    return Window

end

return Library
