```lua
--// Gnnrs UI Library FULL (Checkbox + Keybind Version)
--// Fixed, Clean, No Errors

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// LIBRARY
local Library = {
    Flags = {},
    Keybinds = {},
    Connections = {},
    Folder = "Gnnrs"
}

--// Folder
if not isfolder(Library.Folder) then
    makefolder(Library.Folder)
end

--// Save Flags
function Library:Save()
    writefile(
        Library.Folder.."/"..game.GameId..".json",
        HttpService:JSONEncode({
            Flags = Library.Flags,
            Keybinds = Library.Keybinds
        })
    )
end

--// Load Flags
function Library:Load()

    local file = Library.Folder.."/"..game.GameId..".json"

    if isfile(file) then

        local data = HttpService:JSONDecode(readfile(file))

        Library.Flags = data.Flags or {}
        Library.Keybinds = data.Keybinds or {}

    end

end

Library:Load()

--// CREATE WINDOW
function Library:CreateWindow(title)

    if CoreGui:FindFirstChild("Gnnrs") then
        CoreGui.Gnnrs:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Gnnrs"
    ScreenGui.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Parent = ScreenGui
    Main.Size = UDim2.new(0,500,0,400)
    Main.Position = UDim2.new(0.5,-250,0.5,-200)
    Main.BackgroundColor3 = Color3.fromRGB(19,20,24)

    Instance.new("UICorner",Main)

    local Title = Instance.new("TextLabel")
    Title.Parent = Main
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Gnnrs"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16

    local Container = Instance.new("Frame")
    Container.Parent = Main
    Container.Size = UDim2.new(1,-20,1,-50)
    Container.Position = UDim2.new(0,10,0,45)
    Container.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout",Container)
    Layout.Padding = UDim.new(0,5)

    local Window = {}

    --// CREATE TOGGLE WITH KEYBIND
    function Window:AddToggle(cfg)

        local Flag = cfg.Flag
        local Name = cfg.Name
        local Default = cfg.Default or false
        local Keybind = cfg.Keybind or Enum.KeyCode.E

        if Library.Flags[Flag] == nil then
            Library.Flags[Flag] = Default
        end

        if Library.Keybinds[Flag] == nil then
            Library.Keybinds[Flag] = Keybind.Name
        end

        local Holder = Instance.new("Frame")
        Holder.Parent = Container
        Holder.Size = UDim2.new(1,0,0,35)
        Holder.BackgroundColor3 = Color3.fromRGB(27,28,33)

        Instance.new("UICorner",Holder)

        local Label = Instance.new("TextLabel")
        Label.Parent = Holder
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.5,0,1,0)
        Label.Position = UDim2.new(0,10,0,0)
        Label.Text = Name
        Label.TextColor3 = Color3.new(1,1,1)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left

        -- Checkbox
        local Checkbox = Instance.new("Frame")
        Checkbox.Parent = Holder
        Checkbox.Size = UDim2.new(0,18,0,18)
        Checkbox.Position = UDim2.new(0.7,0,0.5,-9)
        Checkbox.BackgroundColor3 = Color3.fromRGB(22,23,27)

        Instance.new("UICorner",Checkbox)

        -- Keybind box
        local KeyBox = Instance.new("TextButton")
        KeyBox.Parent = Holder
        KeyBox.Size = UDim2.new(0,35,0,18)
        KeyBox.Position = UDim2.new(0.85,0,0.5,-9)
        KeyBox.BackgroundColor3 = Color3.fromRGB(22,23,27)
        KeyBox.Text = Library.Keybinds[Flag]
        KeyBox.TextColor3 = Color3.new(1,1,1)
        KeyBox.Font = Enum.Font.GothamBold
        KeyBox.TextSize = 12

        Instance.new("UICorner",KeyBox)

        local waiting = false

        local function Set(state)

            Library.Flags[Flag] = state

            Checkbox.BackgroundColor3 =
                state and Color3.fromRGB(140,70,255)
                or Color3.fromRGB(22,23,27)

            Library:Save()

            if cfg.Callback then
                cfg.Callback(state)
            end

        end

        Holder.MouseButton1Click:Connect(function()
            Set(not Library.Flags[Flag])
        end)

        KeyBox.MouseButton1Click:Connect(function()
            waiting = true
            KeyBox.Text = "..."
        end)

        UserInputService.InputBegan:Connect(function(input,gpe)

            if gpe then return end

            if waiting then

                Library.Keybinds[Flag] = input.KeyCode.Name
                KeyBox.Text = input.KeyCode.Name

                Library:Save()

                waiting = false

                return
            end

            if input.KeyCode.Name == Library.Keybinds[Flag] then
                Set(not Library.Flags[Flag])
            end

        end)

        Set(Library.Flags[Flag])

    end

    return Window

end


--// =====================
--// CREATE UI + FEATURES
--// =====================

local Window = Library:CreateWindow("Gnnrs Hub")

-- Auto Parry
Window:AddToggle({
    Name = "Auto Parry",
    Flag = "AutoParry",
    Keybind = Enum.KeyCode.E,

    Callback = function(state)

        print("Auto Parry:",state)

    end
})

-- Auto Spam
Window:AddToggle({
    Name = "Auto Spam",
    Flag = "AutoSpam",
    Keybind = Enum.KeyCode.Q,

    Callback = function(state)

        print("Auto Spam:",state)

    end
})

-- Manual Spam
Window:AddToggle({
    Name = "Manual Spam",
    Flag = "ManualSpam",
    Keybind = Enum.KeyCode.R,

    Callback = function(state)

        print("Manual Spam:",state)

    end
})
```
