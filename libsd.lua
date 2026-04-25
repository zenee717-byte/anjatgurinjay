local get_global_env = getgenv or function()
    return _G
end

local SharedEnv = get_global_env()
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local function get_hui()
    local hui = rawget(SharedEnv, "gethui")
    if type(hui) == "function" then
        local ok, result = pcall(hui)
        if ok and result then
            return result
        end
    end

    return CoreGui
end

local function read_source(path)
    if type(readfile) ~= "function" then
        return nil
    end

    if type(isfile) == "function" then
        local ok_exists, exists = pcall(isfile, path)
        if not ok_exists or not exists then
            return nil
        end
    end

    local ok_read, source = pcall(readfile, path)
    if not ok_read or type(source) ~= "string" or source == "" then
        return nil
    end

    return source
end

local function load_source(path)
    local source = read_source(path)
    if not source then
        return nil, "missing source: " .. tostring(path)
    end

    if type(loadstring) ~= "function" then
        return nil, "loadstring unavailable"
    end

    local chunk, compileError = loadstring(source, "@" .. path)
    if not chunk then
        return nil, compileError
    end

    local ok_run, result = pcall(chunk)
    if not ok_run then
        return nil, result
    end

    if type(result) ~= "table" then
        return nil, "library did not return a table"
    end

    return result
end

local function pick(settings, keys, defaultValue)
    if type(settings) ~= "table" then
        return defaultValue
    end

    for _, key in ipairs(keys) do
        local value = settings[key]
        if value ~= nil then
            return value
        end
    end

    return defaultValue
end

local function normalize_config_name(name)
    if name == nil then
        return nil
    end

    local cleaned = tostring(name):gsub("[\\/:*?\"<>|]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if cleaned == "" then
        return nil
    end

    return cleaned
end

local function normalize_keybind_value(value)
    if value == nil then
        return "None"
    end

    if type(value) == "table" then
        return normalize_keybind_value(value.Key or value.key or value[1])
    end

    local valueType = typeof and typeof(value) or type(value)
    if valueType == "EnumItem" then
        return value.Name
    end

    local cleaned = tostring(value)
        :gsub("^Enum%.KeyCode%.", "")
        :gsub("^KeyCode%.", "")
        :gsub("^Enum%.UserInputType%.", "")
        :gsub("^UserInputType%.", "")

    if cleaned == "" then
        return "None"
    end

    return cleaned
end

local function key_matches_input(storedKey, input)
    local wanted = normalize_keybind_value(storedKey)
    if wanted == "None" then
        return false
    end

    if input.KeyCode and input.KeyCode.Name == wanted then
        return true
    end

    return input.UserInputType and input.UserInputType.Name == wanted
end

local function find_descendant(root, name)
    if not root then
        return nil
    end

    local ok_find, result = pcall(function()
        return root:FindFirstChild(name, true)
    end)

    if ok_find then
        return result
    end

    return nil
end

local function create_disabled_watermark()
    local watermark = {}

    function watermark:SetText()
        return self
    end

    function watermark:SetVisibility()
        return self
    end

    function watermark:BindToggle()
        return self
    end

    function watermark:Destroy()
        return self
    end

    return watermark
end

local function create_watermark(text)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ReverseCompatWatermark"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = get_hui()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 26)
    frame.Position = UDim2.new(0, 12, 0, 12)
    frame.BackgroundColor3 = Color3.fromRGB(14, 16, 28)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(50, 80, 160)
    frameStroke.Transparency = 0.35
    frameStroke.Parent = frame

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 1)
    accent.BackgroundColor3 = Color3.fromRGB(100, 185, 255)
    accent.BorderSizePixel = 0
    accent.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(235, 235, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = tostring(text or "REVERSE")
    label.Parent = frame

    local watermark = {
        _gui = gui,
        _label = label,
        _boundWindow = nil,
    }

    function watermark:SetText(value)
        self._label.Text = tostring(value or "")
        return self
    end

    function watermark:SetVisibility(state)
        self._gui.Enabled = state ~= false
        return self
    end

    function watermark:BindToggle(window)
        self._boundWindow = window
        return self
    end

    function watermark:Destroy()
        if self._gui then
            self._gui:Destroy()
            self._gui = nil
        end
        return self
    end

    button.MouseButton1Click:Connect(function()
        local boundWindow = watermark._boundWindow
        if boundWindow and boundWindow.UIVisiblity then
            boundWindow:UIVisiblity()
        end
    end)

    return watermark
end

local function create_keybind_list_stub()
    local list = {}

    function list:Add()
        local item = {}

        function item:SetText()
            return item
        end

        function item:SetStatus()
            return item
        end

        function item:Remove()
            return item
        end

        return item
    end

    function list:SetVisibility()
        return self
    end

    function list:SetWindowVisible()
        return self
    end

    function list:Destroy()
        return self
    end

    return list
end

local function create_settings_page_stub()
    return {
        Window = nil,
        Name = "Gui",
        Columns = 2,
        SubPages = false,
        Page = nil,
        Menu = nil,
    }
end

local previousInstance = rawget(SharedEnv, "__reverse_vico_instance")
if type(previousInstance) == "table" and previousInstance.Unload then
    pcall(function()
        previousInstance:Unload()
    end)
end

local previousBootstrap = rawget(SharedEnv, "__reverse_core_bootstrap")
SharedEnv.__reverse_core_bootstrap = true

local BaseLibrary, loadError = load_source("AUTOPARRYSOURCE/reverselow.lua")

SharedEnv.__reverse_core_bootstrap = previousBootstrap

if not BaseLibrary then
    error("failed to load reverselow core: " .. tostring(loadError))
end

BaseLibrary._compat_next_flag = BaseLibrary._compat_next_flag or 0
BaseLibrary.Options = BaseLibrary.Options or {}
BaseLibrary.Toggles = BaseLibrary.Toggles or {}

local originalNew = BaseLibrary.new

local function augment_module(module)
    if type(module) ~= "table" or module.__reverse_compat_augmented then
        return module
    end

    module.__reverse_compat_augmented = true

    if module.create_searchbox == nil and module.create_dropdown then
        function module:create_searchbox(settings)
            return self:create_dropdown(settings)
        end
    end

    if module.create_label == nil and module.create_text then
        module.create_label = module.create_text
    end

    if module.create_toggle == nil and module.create_checkbox then
        module.create_toggle = module.create_checkbox
    end

    if module.Set == nil and module.change_state then
        module.Set = module.change_state
    end

    if module.Get == nil then
        function module:Get()
            return self._state
        end
    end

    return module
end

local function augment_tab(tab)
    if type(tab) ~= "table" or tab.__reverse_compat_augmented then
        return tab
    end

    tab.__reverse_compat_augmented = true

    local originalCreateModule = tab.create_module
    if type(originalCreateModule) == "function" then
        function tab:create_module(settings)
            settings = settings or {}
            if settings.section == 2 or settings.section == "Right" then
                settings.section = "right"
            elseif settings.section == 1 or settings.section == "Left" then
                settings.section = "left"
            end

            return augment_module(originalCreateModule(self, settings))
        end
    end

    return tab
end

local function apply_branding(instance, settings)
    local titleText = pick(settings, { "watermark_text", "WatermarkText", "title", "Title" }, nil)
    if not titleText then
        return
    end

    local titleLabel = find_descendant(instance._ui, "ClientName")
    if titleLabel and titleLabel:IsA("TextLabel") then
        titleLabel.Text = tostring(titleText)
    end
end

local function bind_extra_menu_key(instance, settings)
    local keybind = pick(settings, { "menu_keybind", "MenuKeybind" }, nil)
    keybind = normalize_keybind_value(keybind)
    if keybind == "None" or keybind == "Insert" then
        return
    end

    instance._compat_menu_connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if not key_matches_input(keybind, input) then
            return
        end

        instance._ui_open = not instance._ui_open
        if instance.change_visiblity then
            instance:change_visiblity(instance._ui_open)
        elseif instance.UIVisiblity then
            instance:UIVisiblity()
        end
    end)
end

function BaseLibrary:NextFlag()
    self._compat_next_flag = (self._compat_next_flag or 0) + 1
    return string.format("ReverseFlag_%d", self._compat_next_flag)
end

function BaseLibrary:SetFlagLoadPriority()
    return nil
end

function BaseLibrary:NormalizeKeybindValue(key)
    return normalize_keybind_value(key)
end

function BaseLibrary:NormalizeConfigName(name)
    return normalize_config_name(name)
end

function BaseLibrary:Notification(title, text, duration)
    return BaseLibrary.SendNotification({
        title = tostring(title or "Notification"),
        text = tostring(text or ""),
        duration = duration or 5,
    })
end

function BaseLibrary:Watermark(name)
    if self._compat_watermark then
        if self._compat_watermark.SetText then
            self._compat_watermark:SetText(name)
        end
        return self._compat_watermark
    end

    self._compat_watermark = create_watermark(name)
    return self._compat_watermark
end

function BaseLibrary:KeybindList()
    if not self._compat_keybind_list then
        self._compat_keybind_list = create_keybind_list_stub()
    end

    return self._compat_keybind_list
end

function BaseLibrary:CreateSettingsPage()
    if not self._compat_settings_page then
        self._compat_settings_page = create_settings_page_stub()
    end

    return self._compat_settings_page
end

function BaseLibrary:LoadAutoloadConfig()
    return true, "reverselow config"
end

function BaseLibrary:Unload()
    if self._compat_menu_connection then
        pcall(function()
            self._compat_menu_connection:Disconnect()
        end)
        self._compat_menu_connection = nil
    end

    if self._compat_watermark and self._compat_watermark.Destroy then
        pcall(function()
            self._compat_watermark:Destroy()
        end)
        self._compat_watermark = nil
    end

    if self._compat_keybind_list and self._compat_keybind_list.Destroy then
        pcall(function()
            self._compat_keybind_list:Destroy()
        end)
        self._compat_keybind_list = nil
    end

    local notificationGui = CoreGui:FindFirstChild("VicoXNotifications")
    if notificationGui then
        pcall(function()
            notificationGui:Destroy()
        end)
    end

    if self._ui then
        pcall(function()
            self._ui:Destroy()
        end)
        self._ui = nil
    end

    if rawget(SharedEnv, "__reverse_vico_instance") == self then
        SharedEnv.__reverse_vico_instance = nil
    end
end

function BaseLibrary.new(settings)
    settings = settings or {}

    local instance = originalNew()
    instance.Flags = BaseLibrary._config and BaseLibrary._config._flags or {}
    instance.Options = BaseLibrary.Options
    instance.Toggles = BaseLibrary.Toggles
    instance.Load = instance.load

    local originalCreateTab = instance.create_tab
    function instance:create_tab(title, icon)
        return augment_tab(originalCreateTab(self, title, icon))
    end

    apply_branding(instance, settings)
    bind_extra_menu_key(instance, settings)

    local fadeValue = pick(settings, { "fade_time", "FadeTime" }, nil)
    if fadeValue ~= nil and instance.Update1Run then
        pcall(function()
            instance:Update1Run(fadeValue)
        end)
    end

    if pick(settings, { "watermark", "Watermark" }, false) then
        local watermarkText = pick(settings, { "watermark_text", "WatermarkText", "title", "Title" }, "REVERSE")
        instance:Watermark(watermarkText):BindToggle(instance)
    end

    if pick(settings, { "keybind_list", "KeybindList" }, false) then
        instance:KeybindList()
    end

    if pick(settings, { "settings_page", "SettingsPage" }, false) then
        instance:CreateSettingsPage()
    end

    SharedEnv.__reverse_vico_instance = instance
    SharedEnv.Library = BaseLibrary
    return instance
end

SharedEnv.Library = BaseLibrary
return BaseLibrary
