-- reverse compatibility layer using Obsidian UI

local previous = rawget(getgenv(), "__reverse_obsidian_compat")
if type(previous) == "table" and previous.Unload then
	pcall(function()
		previous:Unload()
	end)
end

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Obsidian = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local gethui = gethui or function()
	return CoreGui
end

Obsidian.ForceCheckbox = false
Obsidian.ShowToggleFrameInKeybinds = true

local Options = Obsidian.Options
local Toggles = Obsidian.Toggles

local WindowMethods = {}
WindowMethods.__index = WindowMethods

local PageMethods = {}
PageMethods.__index = PageMethods

local SectionMethods = {}
SectionMethods.__index = SectionMethods

local CompatRoot = {}
CompatRoot.__index = CompatRoot

local CompatTab = {}
CompatTab.__index = CompatTab

local CompatModule = {}
CompatModule.__index = CompatModule

local Library = {
	Theme = {
		Background = Color3.fromRGB(18, 19, 24),
		Inline = Color3.fromRGB(25, 27, 34),
		Border = Color3.fromRGB(44, 47, 58),
		Accent = Color3.fromRGB(202, 243, 255),
		Text = Color3.fromRGB(235, 235, 240),
		TextDim = Color3.fromRGB(160, 164, 175),
	},
	Flags = {},
	Options = Options,
	Toggles = Toggles,
	MenuKeybind = "LeftControl",
	FallbackMenuKeybind = "LeftControl",
	AutoSaveEnabled = true,
	AutoSaveConfig = "last-session",
	AutoSaveDelay = 0.75,
	AutoLoadDelay = 0.75,
	FadeSpeed = 0.2,
	Tween = {
		Time = 0.2,
		Style = "Quad",
		Direction = "Out",
	},
	_connections = {},
	_windows = {},
	_nextFlag = 0,
	_mainWindow = nil,
	_watermark = nil,
	_keybindList = nil,
	_settingsPages = {},
	_themeManagerReady = false,
	_autoSaveQueued = false,
	_autoSaveReady = false,
	_autoSaveSuspended = false,
	_autoLoadScheduled = false,
}

local function track_connection(connection)
	if connection then
		table.insert(Library._connections, connection)
	end

	return connection
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

local function compose_text(settings, fallback)
	local title = pick(settings, { "title", "Title", "name", "Name" }, nil)
	local body = pick(settings, { "text", "Text", "description", "Description", "richtext", "RichText" }, nil)

	if title ~= nil and body ~= nil and tostring(body) ~= "" then
		return string.format("%s: %s", tostring(title), tostring(body))
	end

	if body ~= nil then
		return tostring(body)
	end

	if title ~= nil then
		return tostring(title)
	end

	return fallback or ""
end

local function clone_list(values)
	local copy = {}
	if type(values) ~= "table" then
		return copy
	end

	for index, value in ipairs(values) do
		copy[index] = value
	end

	return copy
end

local function list_remove(values, target)
	for index = #values, 1, -1 do
		if values[index] == target then
			table.remove(values, index)
		end
	end
end

local function next_flag(prefix)
	Library._nextFlag = Library._nextFlag + 1
	return string.format("%s_%d", prefix or "ReverseFlag", Library._nextFlag)
end

local function normalize_page_name(name)
	return tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
end

local function is_gui_page_name(name)
	return normalize_page_name(name) == "gui"
end

local function strip_enum_prefix(value)
	return tostring(value)
		:gsub("^Enum%.KeyCode%.", "")
		:gsub("^KeyCode%.", "")
		:gsub("^Enum%.UserInputType%.", "")
		:gsub("^UserInputType%.", "")
end

local picker_mouse_map = {
	MouseButton1 = "MB1",
	MouseButton2 = "MB2",
	MouseButton3 = "MB3",
}

local input_mouse_map = {
	MB1 = Enum.UserInputType.MouseButton1,
	MB2 = Enum.UserInputType.MouseButton2,
	MB3 = Enum.UserInputType.MouseButton3,
}

local function normalize_picker_key(value, fallbackMode)
	if value == nil then
		return "None"
	end

	if typeof and typeof(value) == "EnumItem" then
		return picker_mouse_map[value.Name] or value.Name
	end

	if type(value) == "table" then
		local key = normalize_picker_key(value.Key or value.key or value[1], fallbackMode)
		local mode = value.Mode or value.mode or value[2] or fallbackMode
		if mode ~= nil then
			return { key, mode }
		end

		return key
	end

	local cleaned = strip_enum_prefix(value)
	return picker_mouse_map[cleaned] or cleaned
end

local function normalize_keybind_value(value)
	if value == nil then
		return "None"
	end

	if type(value) == "table" then
		return normalize_keybind_value(value.Key or value.key or value[1])
	end

	if typeof and typeof(value) == "EnumItem" then
		return normalize_picker_key(value)
	end

	local cleaned = normalize_picker_key(value)
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

	local mouseInput = input_mouse_map[wanted]
	if mouseInput then
		return input.UserInputType == mouseInput
	end

	return input.KeyCode and input.KeyCode.Name == wanted
end

local function infer_step(...)
	local step

	for _, value in ipairs({ ... }) do
		if type(value) == "number" and value ~= math.floor(value) then
			local formatted = string.format("%.6f", value):gsub("0+$", ""):gsub("%.$", "")
			local decimals = formatted:match("%.(%d+)")
			if decimals then
				local candidate = 10 ^ (-#decimals)
				if step == nil or candidate < step then
					step = candidate
				end
			end
		end
	end

	return step or 1
end

local function step_to_rounding(step)
	if type(step) ~= "number" or step <= 0 then
		return 0
	end

	local formatted = string.format("%.6f", step):gsub("0+$", ""):gsub("%.$", "")
	local decimals = formatted:match("%.(%d+)")
	return decimals and #decimals or 0
end

local function resolve_rounding(settings, minimum, maximum, defaultValue)
	local explicit = pick(settings, { "rounding", "Rounding" }, nil)
	if explicit ~= nil then
		return explicit
	end

	local decimals = pick(settings, { "decimals", "Decimals" }, nil)
	if type(decimals) == "number" then
		return step_to_rounding(decimals)
	end

	if pick(settings, { "round_number", "RoundNumber" }, false) then
		return step_to_rounding(infer_step(minimum, maximum, defaultValue))
	end

	return 1
end

local function resolve_tab_icon(icon)
	if type(icon) == "string" and icon ~= "" and not icon:find("rbxassetid://", 1, true) then
		return icon
	end

	return "user"
end

local function safe_set_visibility(raw, state)
	if raw == nil then
		return
	end

	if type(raw) == "table" and raw.SetVisibility then
		pcall(function()
			raw:SetVisibility(state)
		end)
		return
	end

	if type(raw) == "table" and raw.SetVisible then
		pcall(function()
			raw:SetVisible(state)
		end)
		return
	end

	if type(raw) == "table" and raw.Instance and raw.Instance.Visible ~= nil then
		raw.Instance.Visible = state
		return
	end

	if typeof and typeof(raw) == "Instance" and raw.Visible ~= nil then
		raw.Visible = state
	end
end

local function ensure_option(bucket, flag, fallback)
	local value = bucket[flag]
	if value ~= nil then
		return value
	end

	task.wait()
	return bucket[flag] or fallback
end

local function current_value(raw, fallback)
	if raw == nil then
		return fallback
	end

	if raw.Value ~= nil then
		return raw.Value
	end

	if raw.Get then
		local ok, result = pcall(function()
			return raw:Get()
		end)
		if ok then
			return result
		end
	end

	return fallback
end

local function current_color(raw, fallbackColor, fallbackAlpha)
	local color = fallbackColor or Color3.fromRGB(255, 255, 255)
	local alpha = fallbackAlpha or 0

	if raw ~= nil then
		if raw.Value ~= nil then
			color = raw.Value
		elseif raw.Color ~= nil then
			color = raw.Color
		end

		if raw.Transparency ~= nil then
			alpha = raw.Transparency
		elseif raw.Alpha ~= nil then
			alpha = raw.Alpha
		end
	end

	return color, alpha
end

local function update_keybind_flag(flag, raw, overrideState)
	local key = normalize_keybind_value(raw and raw.Value or "None")
	local mode = raw and raw.Mode or "Toggle"
	local toggled = overrideState

	if toggled == nil and raw and raw.GetState then
		local ok, result = pcall(function()
			return raw:GetState()
		end)
		if ok then
			toggled = result
		end
	end

	if toggled == nil then
		toggled = false
	end

	Library.Flags[flag] = {
		Key = key,
		Value = key,
		Mode = mode,
		Toggled = toggled,
	}

	return Library.Flags[flag]
end

local function create_overlay_shell(name, size, position)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = gethui()

	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = Library.Theme.Background
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local stroke = Instance.new("UIStroke")
	stroke.Color = Library.Theme.Border
	stroke.Thickness = 1
	stroke.Parent = frame

	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.Size = UDim2.new(1, 0, 0, 1)
	accent.BackgroundColor3 = Library.Theme.Accent
	accent.BorderSizePixel = 0
	accent.Parent = frame

	return gui, frame
end

local function create_watermark(text)
	local gui, frame = create_overlay_shell("ReverseWatermark", UDim2.new(0, 220, 0, 26), UDim2.new(0, 12, 0, 12))

	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = frame

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Size = UDim2.new(1, -20, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Library.Theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Code
	label.TextSize = 13
	label.Text = tostring(text or "reverse")
	label.Parent = frame

	local watermark = {
		_gui = gui,
		_frame = frame,
		_label = label,
		_boundWindow = nil,
	}

	function watermark:SetText(value)
		self._label.Text = tostring(value or "")
		return self
	end

	function watermark:SetVisibility(state)
		self._gui.Enabled = state
		return self
	end

	function watermark:BindToggle(window)
		self._boundWindow = window
		return self
	end

	function watermark:Destroy()
		if self._gui then
			self._gui:Destroy()
		end
	end

	track_connection(button.MouseButton1Click:Connect(function()
		if watermark._boundWindow and watermark._boundWindow.Toggle then
			watermark._boundWindow:Toggle()
		end
	end))

	return watermark
end

local function create_keybind_list()
	local gui, frame = create_overlay_shell("ReverseKeybindList", UDim2.new(0, 230, 0, 34), UDim2.new(1, -242, 0, 12))
	frame.AutomaticSize = Enum.AutomaticSize.Y

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.new(0, 10, 0, 0)
	title.Size = UDim2.new(1, -20, 0, 24)
	title.BackgroundTransparency = 1
	title.TextColor3 = Library.Theme.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.Code
	title.TextSize = 13
	title.Text = "Keybinds"
	title.Parent = frame

	local listHolder = Instance.new("Frame")
	listHolder.Name = "ListHolder"
	listHolder.Position = UDim2.new(0, 8, 0, 24)
	listHolder.Size = UDim2.new(1, -16, 0, 0)
	listHolder.BackgroundTransparency = 1
	listHolder.AutomaticSize = Enum.AutomaticSize.Y
	listHolder.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = listHolder

	local list = {
		_gui = gui,
		_frame = frame,
		_holder = listHolder,
		_items = {},
		_manualVisible = true,
		_windowVisible = true,
	}

	function list:RefreshVisibility()
		local visibleCount = 0

		for _, item in ipairs(self._items) do
			if item:IsShown() then
				visibleCount = visibleCount + 1
			end
		end

		self._gui.Enabled = self._manualVisible and self._windowVisible and visibleCount > 0
		return self
	end

	function list:Add(key, name, mode)
		local label = Instance.new("TextLabel")
		label.Name = "KeybindItem"
		label.Size = UDim2.new(1, 0, 0, 18)
		label.BackgroundTransparency = 1
		label.TextColor3 = Library.Theme.TextDim
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.Code
		label.TextSize = 12
		label.Parent = self._holder

		local item = {
			_label = label,
			_owner = self,
			_key = "None",
			_name = "Keybind",
			_mode = "Toggle",
			_active = false,
		}

		function item:IsShown()
			return self._key ~= "None"
		end

		function item:Refresh()
			local shouldShow = self:IsShown()
			self._label.Visible = shouldShow
			self._label.Size = shouldShow and UDim2.new(1, 0, 0, 18) or UDim2.new(1, 0, 0, 0)

			if shouldShow then
				self._label.Text = string.format("[%s] %s (%s)", self._key, self._name, self._mode)
			else
				self._label.Text = ""
			end

			self._owner:RefreshVisibility()
			return self
		end

		function item:SetText(newKey, newName, newMode)
			self._key = normalize_keybind_value(newKey)
			self._mode = tostring(newMode or "Toggle")
			self._name = tostring(newName or "Keybind")
			return self:Refresh()
		end

		function item:SetStatus(isActive)
			self._label.TextColor3 = isActive and Library.Theme.Accent or Library.Theme.TextDim
			self._active = isActive == true
			return self:Refresh()
		end

		function item:Remove()
			if self._label then
				self._label:Destroy()
			end

			for index, existing in ipairs(self._owner._items) do
				if existing == self then
					table.remove(self._owner._items, index)
					break
				end
			end

			self._owner:RefreshVisibility()
		end

		item:SetText(key, name, mode)
		item:SetStatus(false)
		table.insert(self._items, item)
		self:RefreshVisibility()
		return item
	end

	function list:SetVisibility(state)
		self._manualVisible = state == true
		self:RefreshVisibility()
		return self
	end

	function list:SetWindowVisible(state)
		self._windowVisible = state == true
		self:RefreshVisibility()
		return self
	end

	function list:Destroy()
		if self._gui then
			self._gui:Destroy()
		end
	end

	list:RefreshVisibility()

	return list
end

local function create_disabled_watermark()
	local watermark = {
		_disabled = true,
	}

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

local function attach_gui_menu_section(page, keybindList)
	if not page then
		return nil
	end

	if page._reverseGuiMenuAttached then
		return page._reverseGuiMenu
	end

	local menu = page:Section({
		Name = "Menu",
		Side = 1,
	})

	local defaultVisible = Library.Flags.UI_KeybindListVisible
	if defaultVisible == nil then
		defaultVisible = keybindList ~= nil
	end

	local keybindListToggle = menu:Toggle({
		Flag = "UI_KeybindListVisible",
		Name = "Keybind List",
		Default = defaultVisible,
		Callback = function(value)
			if keybindList then
				keybindList:SetVisibility(value)
			end
		end,
	})

	keybindListToggle:Keybind({
		Flag = "UI_KeybindListVisible_Bind",
		Text = "Keybind List",
		Mode = "Toggle",
		SyncToggleState = true,
		Default = pick(Library.Flags, { "UI_KeybindListVisible_Bind" }, nil),
	})

	if keybindList then
		keybindList:SetVisibility(defaultVisible == true)
	end

	page._reverseGuiMenuAttached = true
	page._reverseGuiMenu = menu
	return menu
end

local function try_attach_gui_settings(window, page)
	if not window or window._guiSettingsAttached then
		return false
	end

	local pending = window._pendingGuiSettings
	if not pending then
		return false
	end

	local targetPage = page
	if not targetPage and window._pagesByName then
		targetPage = window._pagesByName.gui
	end

	if not targetPage or not is_gui_page_name(targetPage.Name) then
		return false
	end

	local menu = attach_gui_menu_section(targetPage, pending.keybindList)
	window._guiSettingsAttached = menu ~= nil

	if window._guiSettingsAttached then
		pending.Page = targetPage
		pending.Menu = menu

		if pending.Descriptor then
			pending.Descriptor.Page = targetPage
			pending.Descriptor.Menu = menu
		end
	end

	return window._guiSettingsAttached
end

local function ensure_theme_managers()
	if Library._themeManagerReady then
		return
	end

	ThemeManager:SetLibrary(Obsidian)
	SaveManager:SetLibrary(Obsidian)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({ "UI_MenuKeybind" })
	ThemeManager:SetFolder("reverse")
	SaveManager:SetFolder("reverse/configs")

	Library._themeManagerReady = true
end

local function persistence_supported()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function get_auto_save_name()
	local normalized = Library:NormalizeConfigName(Library.AutoSaveConfig)
	return normalized or "last-session"
end

local function mark_auto_save_ready(delayTime)
	task.delay(delayTime or 0, function()
		if rawget(getgenv(), "__reverse_obsidian_compat") ~= Library then
			return
		end

		Library._autoSaveSuspended = false
		Library._autoSaveReady = true
	end)
end

local function perform_auto_save()
	if not Library.AutoSaveEnabled or not Library._autoSaveReady or Library._autoSaveSuspended or not persistence_supported() then
		return false, "autosave unavailable"
	end

	ensure_theme_managers()

	local configName = get_auto_save_name()
	local ok, err = SaveManager:Save(configName)
	if not ok then
		return false, err
	end

	SaveManager:SaveAutoloadConfig(configName)
	return true, configName
end

local function queue_auto_save()
	if not Library.AutoSaveEnabled or not Library._autoSaveReady or Library._autoSaveSuspended or not persistence_supported() then
		return
	end

	if Library._autoSaveQueued then
		return
	end

	Library._autoSaveQueued = true

	task.delay(Library.AutoSaveDelay or 0.75, function()
		if rawget(getgenv(), "__reverse_obsidian_compat") ~= Library then
			return
		end

		Library._autoSaveQueued = false
		pcall(perform_auto_save)
	end)
end

local function schedule_auto_restore()
	if Library._autoLoadScheduled then
		return
	end

	Library._autoLoadScheduled = true

	if not persistence_supported() then
		Library._autoSaveReady = true
		return
	end

	Library._autoSaveReady = false
	Library._autoSaveSuspended = true

	task.delay(Library.AutoLoadDelay or 0.75, function()
		if rawget(getgenv(), "__reverse_obsidian_compat") ~= Library then
			return
		end

		Library:LoadAutoloadConfig(true)
	end)
end

local function wrap_colorpicker(raw, flag)
	local colorpicker = {
		_raw = raw,
		Flag = flag,
	}

	local function sync()
		local color, alpha = current_color(raw)
		colorpicker.Color = color
		colorpicker.Alpha = alpha
		Library.Flags[flag] = {
			Color = color,
			Alpha = alpha,
			Transparency = alpha,
		}
	end

	sync()

	function colorpicker:Get()
		sync()
		return self.Color, self.Alpha
	end

	function colorpicker:Set(color, alpha)
		if self._raw and self._raw.SetValueRGB then
			pcall(function()
				self._raw:SetValueRGB(color)
			end)
		elseif self._raw and self._raw.SetValue then
			pcall(function()
				self._raw:SetValue(color)
			end)
		end

		if alpha ~= nil and self._raw ~= nil then
			pcall(function()
				self._raw.Transparency = alpha
			end)
		end

		sync()
		return self
	end

	function colorpicker:SetOpen()
		return self
	end

	function colorpicker:SlidePalette()
		return self
	end

	function colorpicker:SlideHue()
		return self
	end

	function colorpicker:SlideAlpha()
		return self
	end

	function colorpicker:Update()
		return self
	end

	function colorpicker:SetVisibility(state)
		safe_set_visibility(self._raw, state)
		return self
	end

	return colorpicker
end

local function wrap_keybind(raw, flag, displayName, showInList)
	local keybind = {
		_raw = raw,
		Flag = flag,
	}

	if Library._keybindList and showInList then
		keybind._listItem = Library._keybindList:Add(raw and raw.Value or "None", displayName or flag, raw and raw.Mode or "Toggle")
	end

	local function sync(overrideState)
		local state = update_keybind_flag(flag, raw, overrideState)
		keybind.Key = state.Key
		keybind.Value = state.Value
		keybind.Mode = state.Mode
		keybind.Toggled = state.Toggled

		if keybind._listItem then
			keybind._listItem:SetText(keybind.Key, displayName or flag, keybind.Mode)
			keybind._listItem:SetStatus(keybind.Toggled)
		end
	end

	keybind._sync = sync
	sync()

	function keybind:Get()
		sync()
		return self.Key, self.Mode, self.Toggled
	end

	function keybind:Set(value)
		local currentMode = self.Mode or "Toggle"
		local normalized = normalize_picker_key(value, currentMode)
		if self._raw and self._raw.SetValue then
			pcall(function()
				self._raw:SetValue(normalized)
			end)
		end

		sync()
		return self
	end

	function keybind:SetMode(mode)
		local key = self.Key or "None"
		if self._raw and self._raw.SetValue then
			pcall(function()
				self._raw:SetValue({ key, mode })
			end)
		end

		sync()
		return self
	end

	function keybind:Press(value)
		sync(value)
		return self
	end

	function keybind:SetVisibility(state)
		safe_set_visibility(self._raw, state)
		return self
	end

	return keybind
end

local function attach_colorpicker(host, settings)
	settings = settings or {}

	local flag = pick(settings, { "flag", "Flag" }, next_flag("Colorpicker"))
	local default = pick(settings, { "default", "Default", "value", "Value" }, Color3.fromRGB(255, 255, 255))
	local alpha = pick(settings, { "alpha", "Alpha", "transparency", "Transparency" }, 0)
	local callback = pick(settings, { "callback", "Callback" }, function() end)

	Library.Flags[flag] = {
		Color = default,
		Alpha = alpha,
		Transparency = alpha,
	}

	host:AddColorPicker(flag, {
		Default = default,
		Title = pick(settings, { "title", "Title", "name", "Name" }, "Color"),
		Transparency = alpha,
		Callback = function(value)
			local raw = ensure_option(Options, flag)
			local _, newAlpha = current_color(raw, value, alpha)
			Library.Flags[flag] = {
				Color = value,
				Alpha = newAlpha,
				Transparency = newAlpha,
			}
			callback(value)
			queue_auto_save()
		end,
	})

	return wrap_colorpicker(ensure_option(Options, flag), flag)
end

local function attach_keybind(host, settings, displayName)
	settings = settings or {}

	local flag = pick(settings, { "flag", "Flag" }, next_flag("Keybind"))
	local callback = pick(settings, { "callback", "Callback" }, function() end)
	local changedCallback = pick(settings, { "changed_callback", "ChangedCallback" }, function() end)
	local pickerNoUI = pick(settings, { "no_ui", "NoUI" }, true)
	local showInList = pick(settings, { "show_in_list", "ShowInList" }, true)
	local wrappedKeybind

	local pickerConfig = {
		SyncToggleState = pick(settings, { "sync_toggle_state", "SyncToggleState" }, false),
		Mode = pick(settings, { "mode", "Mode" }, "Toggle"),
		Text = displayName or pick(settings, { "title", "Title", "text", "Text", "name", "Name" }, "Keybind"),
		NoUI = pickerNoUI,
		Callback = function(state)
			local raw = ensure_option(Options, flag)
			update_keybind_flag(flag, raw, state)
			if wrappedKeybind and wrappedKeybind._sync then
				wrappedKeybind._sync(state)
			end
			callback(state)
			queue_auto_save()
		end,
		ChangedCallback = function(newValue)
			local raw = ensure_option(Options, flag)
			if normalize_keybind_value(newValue) == "Backspace" and raw and raw.SetValue then
				pcall(function()
					raw:SetValue({ "None", raw.Mode or pickerConfig.Mode or "Toggle" })
				end)
			end
			update_keybind_flag(flag, raw)
			if wrappedKeybind and wrappedKeybind._sync then
				wrappedKeybind._sync()
			end
			if normalize_keybind_value(newValue) == "Backspace" then
				changedCallback("None")
				queue_auto_save()
				return
			end
			changedCallback(newValue)
			queue_auto_save()
		end,
	}

	local explicitDefault = pick(settings, { "default", "Default", "key", "Key" }, nil)
	if explicitDefault ~= nil then
		pickerConfig.Default = normalize_picker_key(explicitDefault)
	end

	host:AddKeyPicker(flag, pickerConfig)

	local raw = ensure_option(Options, flag)
	update_keybind_flag(flag, raw)
	wrappedKeybind = wrap_keybind(raw, flag, displayName, showInList)
	if wrappedKeybind._sync then
		wrappedKeybind._sync()
	end
	return wrappedKeybind
end

local function wrap_text(host, raw, initialText)
	local text = {
		_host = host,
		_raw = raw,
		Value = tostring(initialText or ""),
	}

	function text:Get()
		return self.Value
	end

	function text:Set(value)
		if type(value) == "table" then
			self.Value = compose_text(value, "Text")
		else
			self.Value = tostring(value or "")
		end

		if self._raw and self._raw.SetText then
			pcall(function()
				self._raw:SetText(self.Value)
			end)
		elseif self._host and self._host.SetText then
			pcall(function()
				self._host:SetText(self.Value)
			end)
		end

		return self
	end

	text.SetText = text.Set

	function text:SetVisibility(state)
		safe_set_visibility(self._host or self._raw, state)
		return self
	end

	function text:Colorpicker(settings)
		return attach_colorpicker(self._host, settings)
	end

	function text:Keybind(settings)
		return attach_keybind(
			self._host,
			settings,
			pick(settings, { "text", "Text", "title", "Title", "name", "Name" }, self.Value)
		)
	end

	return text
end

local function wrap_toggle(host, raw, flag)
	local toggle = {
		_host = host,
		_raw = raw,
		Flag = flag,
	}

	local function sync()
		toggle.Value = current_value(raw, Library.Flags[flag])
		toggle._state = toggle.Value
		Library.Flags[flag] = toggle.Value
	end

	sync()

	function toggle:Get()
		sync()
		return self.Value
	end

	function toggle:Set(value)
		if self._raw and self._raw.SetValue then
			pcall(function()
				self._raw:SetValue(value)
			end)
		end

		sync()
		return self
	end

	toggle.change_state = toggle.Set

	function toggle:SetText(text)
		if self._host and self._host.SetText then
			pcall(function()
				self._host:SetText(text)
			end)
		end

		return self
	end

	function toggle:SetVisibility(state)
		safe_set_visibility(self._host or self._raw, state)
		return self
	end

	function toggle:Colorpicker(settings)
		return attach_colorpicker(self._host, settings)
	end

	function toggle:Keybind(settings)
		settings = settings or {}
		settings.sync_toggle_state = pick(settings, { "sync_toggle_state", "SyncToggleState" }, false)
		return attach_keybind(self._host, settings, pick(settings, { "text", "Text", "title", "Title" }, nil))
	end

	return toggle
end

local function wrap_slider(host, raw, flag)
	local slider = {
		_host = host,
		_raw = raw,
		Flag = flag,
	}

	local function sync()
		slider.Value = current_value(raw, Library.Flags[flag])
		Library.Flags[flag] = slider.Value
	end

	sync()

	function slider:Get()
		sync()
		return self.Value
	end

	function slider:Set(value)
		if self._raw and self._raw.SetValue then
			pcall(function()
				self._raw:SetValue(value)
			end)
		end

		sync()
		return self
	end

	function slider:SetVisibility(state)
		safe_set_visibility(self._host or self._raw, state)
		return self
	end

	return slider
end

local function wrap_dropdown(host, raw, flag, values)
	local dropdown = {
		_host = host,
		_raw = raw,
		Flag = flag,
		_values = clone_list(values or {}),
	}

	local function sync()
		dropdown.Value = current_value(raw, Library.Flags[flag])
		Library.Flags[flag] = dropdown.Value
	end

	sync()

	function dropdown:Get()
		sync()
		return self.Value
	end

	function dropdown:Set(value)
		if self._raw and self._raw.SetValue then
			pcall(function()
				self._raw:SetValue(value)
			end)
		end

		sync()
		return self
	end

	function dropdown:SetVisibility(state)
		safe_set_visibility(self._host or self._raw, state)
		return self
	end

	function dropdown:_apply_values()
		if self._raw and self._raw.SetValues then
			pcall(function()
				self._raw:SetValues(self._values)
			end)
		elseif self._host and self._host.SetValues then
			pcall(function()
				self._host:SetValues(self._values)
			end)
		elseif self._raw then
			self._raw.Values = self._values
		end
	end

	function dropdown:Add(option)
		table.insert(self._values, option)
		self:_apply_values()
		return {
			Name = option,
		}
	end

	function dropdown:Remove(option)
		list_remove(self._values, option)
		self:_apply_values()
		return self
	end

	function dropdown:Refresh(list)
		self._values = clone_list(list or {})
		self:_apply_values()
		return self
	end

	return dropdown
end

local function wrap_textbox(host, raw, flag)
	local textbox = {
		_host = host,
		_raw = raw,
		Flag = flag,
	}

	local function sync()
		textbox.Value = current_value(raw, Library.Flags[flag])
		Library.Flags[flag] = textbox.Value
	end

	sync()

	function textbox:Get()
		sync()
		return self.Value
	end

	function textbox:Set(value)
		if self._raw and self._raw.SetValue then
			pcall(function()
				self._raw:SetValue(tostring(value or ""))
			end)
		end

		sync()
		return self
	end

	textbox.change_state = textbox.Set

	function textbox:SetVisibility(state)
		safe_set_visibility(self._host or self._raw, state)
		return self
	end

	return textbox
end

function SectionMethods:Toggle(data)
	data = data or {}

	local flag = pick(data, { "Flag", "flag" }, next_flag("Toggle"))
	local defaultValue = pick(data, { "Default", "default", "value", "Value", "enabled", "Enabled" }, false)
	local callback = pick(data, { "Callback", "callback" }, function() end)

	Library.Flags[flag] = defaultValue

	local host = self._group:AddToggle(flag, {
		Text = pick(data, { "Name", "name", "title", "Title", "text", "Text" }, "Toggle"),
		Default = defaultValue,
		Tooltip = pick(data, { "Tooltip", "tooltip" }, nil),
		Disabled = pick(data, { "Disabled", "disabled" }, false),
		Visible = pick(data, { "Visible", "visible" }, true),
		Risky = pick(data, { "Risky", "risky" }, false),
		Callback = function(value)
			Library.Flags[flag] = value
			callback(value)
			queue_auto_save()
		end,
	})

	return wrap_toggle(host, ensure_option(Toggles, flag, host), flag)
end

function SectionMethods:Button()
	local row = {
		_group = self._group,
		_buttons = {},
	}

	function row:Add(name, callback)
		local raw
		if #self._buttons == 0 then
			raw = self._group:AddButton({
				Text = tostring(name or "Button"),
				Func = callback or function() end,
				DoubleClick = false,
			})
		else
			raw = self._buttons[#self._buttons]:AddButton({
				Text = tostring(name or "Button"),
				Func = callback or function() end,
				DoubleClick = false,
			})
		end

		table.insert(self._buttons, raw)
		return raw
	end

	function row:SetVisibility(state)
		for _, button in ipairs(self._buttons) do
			safe_set_visibility(button, state)
		end

		return self
	end

	return row
end

function SectionMethods:Slider(data)
	data = data or {}

	local flag = pick(data, { "Flag", "flag" }, next_flag("Slider"))
	local minimum = pick(data, { "Min", "min", "minimum_value", "MinimumValue" }, 0)
	local maximum = pick(data, { "Max", "max", "maximum_value", "MaximumValue" }, 100)
	local defaultValue = pick(data, { "Default", "default", "value", "Value" }, minimum)
	local callback = pick(data, { "Callback", "callback" }, function() end)

	Library.Flags[flag] = defaultValue

	local host = self._group:AddSlider(flag, {
		Text = pick(data, { "Name", "name", "title", "Title" }, "Slider"),
		Default = defaultValue,
		Min = minimum,
		Max = maximum,
		Suffix = pick(data, { "Suffix", "suffix" }, ""),
		Rounding = resolve_rounding(data, minimum, maximum, defaultValue),
		Compact = pick(data, { "Compact", "compact" }, false),
		HideMax = pick(data, { "HideMax", "hide_max" }, false),
		Tooltip = pick(data, { "Tooltip", "tooltip" }, nil),
		Disabled = pick(data, { "Disabled", "disabled" }, false),
		Visible = pick(data, { "Visible", "visible" }, true),
		Callback = function(value)
			Library.Flags[flag] = value
			callback(value)
			queue_auto_save()
		end,
	})

	return wrap_slider(host, ensure_option(Options, flag, host), flag)
end

function SectionMethods:Dropdown(data)
	data = data or {}

	local flag = pick(data, { "Flag", "flag" }, next_flag("Dropdown"))
	local items = clone_list(pick(data, { "Items", "items", "Values", "values", "Options", "options" }, {}))
	local defaultValue = pick(data, { "Default", "default", "value", "Value" }, nil)
	local callback = pick(data, { "Callback", "callback" }, function() end)

	Library.Flags[flag] = defaultValue

	local host = self._group:AddDropdown(flag, {
		Values = items,
		Default = defaultValue,
		Multi = pick(data, { "Multi", "multi", "multi_dropdown", "MultiDropdown" }, false),
		Text = pick(data, { "Name", "name", "title", "Title" }, "Dropdown"),
		Tooltip = pick(data, { "Tooltip", "tooltip" }, nil),
		Disabled = pick(data, { "Disabled", "disabled" }, false),
		Visible = pick(data, { "Visible", "visible" }, true),
		Searchable = pick(data, { "Searchable", "searchable" }, false),
		Callback = function(value)
			Library.Flags[flag] = value
			callback(value)
			queue_auto_save()
		end,
	})

	return wrap_dropdown(host, ensure_option(Options, flag, host), flag, items)
end

function SectionMethods:Searchbox(data)
	data = data or {}
	data.Searchable = true
	return self:Dropdown(data)
end

function SectionMethods:Label(name)
	local text = tostring(name or "")
	local host = self._group:AddLabel(text)
	return wrap_text(host, host, text)
end

function SectionMethods:Textbox(data)
	data = data or {}

	local flag = pick(data, { "Flag", "flag" }, next_flag("Textbox"))
	local defaultValue = tostring(pick(data, { "Default", "default", "value", "Value" }, ""))
	local callback = pick(data, { "Callback", "callback" }, function() end)

	Library.Flags[flag] = defaultValue

	local host = self._group:AddInput(flag, {
		Default = defaultValue,
		Numeric = pick(data, { "Numeric", "numeric" }, false),
		Finished = pick(data, { "Finished", "finished" }, false),
		ClearTextOnFocus = pick(data, { "ClearTextOnFocus", "clear_text_on_focus" }, false),
		Text = pick(data, { "Name", "name", "title", "Title" }, "Textbox"),
		Tooltip = pick(data, { "Tooltip", "tooltip" }, nil),
		Placeholder = pick(data, { "Placeholder", "placeholder" }, "..."),
		Callback = function(value)
			Library.Flags[flag] = value
			callback(value)
			queue_auto_save()
		end,
	})

	return wrap_textbox(host, ensure_option(Options, flag, host), flag)
end

function SectionMethods:Divider()
	self._group:AddDivider()
	return true
end

function PageMethods:_ensure_tab()
	if self._tab then
		return self._tab
	end

	self._tab = self.Window._raw:AddTab(self.Name, resolve_tab_icon(self.Icon))
	return self._tab
end

function PageMethods:Section(data)
	data = data or {}
	local side = pick(data, { "Side", "side", "section", "Section" }, 1)
	local groupName = pick(data, { "Name", "name", "title", "Title" }, "Section")
	local tab = self:_ensure_tab()

	local group
	if side == 2 or side == "right" or side == "Right" then
		group = tab:AddRightGroupbox(groupName)
	else
		group = tab:AddLeftGroupbox(groupName)
	end

	return setmetatable({
		Window = self.Window,
		Page = self,
		Name = groupName,
		Side = side,
		_group = group,
	}, SectionMethods)
end

function PageMethods:SubPage(data)
	data = data or {}
	local subName = pick(data, { "Name", "name", "title", "Title" }, "SubPage")
	local fullName = string.format("%s / %s", self.Name, subName)

	return setmetatable({
		Window = self.Window,
		Name = fullName,
		Columns = pick(data, { "Columns", "columns" }, 2),
		Icon = pick(data, { "Icon", "icon" }, self.Icon),
		SubPages = false,
		_tab = self.Window._raw:AddTab(fullName, resolve_tab_icon(self.Icon)),
	}, PageMethods)
end

function WindowMethods:_find_gui_root()
	if self._raw and self._raw.ScreenGui and self._raw.ScreenGui.Parent then
		return self._raw.ScreenGui
	end

	if Obsidian.ScreenGui and Obsidian.ScreenGui.Parent then
		return Obsidian.ScreenGui
	end

	if self._guiRoot and self._guiRoot.Parent then
		return self._guiRoot
	end

	local parent = gethui()
	for _, child in ipairs(parent:GetChildren()) do
		if not self._snapshot[child] and child:IsA("ScreenGui") and child.Name ~= "ReverseWatermark" and child.Name ~= "ReverseKeybindList" then
			return child
		end
	end

	return self._guiRoot
end

function WindowMethods:SetOpen(state)
	self.IsOpen = state ~= false
	self._guiRoot = self:_find_gui_root()
	if self._guiRoot then
		if self._guiRoot:IsA("ScreenGui") then
			self._guiRoot.Enabled = self.IsOpen
		elseif self._guiRoot.Visible ~= nil then
			self._guiRoot.Visible = self.IsOpen
		end
	end

	if Library._keybindList and Library._keybindList.SetWindowVisible then
		Library._keybindList:SetWindowVisible(self.IsOpen)
	end

	if Library._watermark then
		Library._watermark:SetVisibility(self.IsOpen)
	end

	return self
end

function WindowMethods:Toggle()
	return self:SetOpen(not self.IsOpen)
end

function WindowMethods:Page(data)
	data = data or {}

	local page = {
		Window = self,
		Name = pick(data, { "Name", "name", "title", "Title" }, "Page"),
		Columns = pick(data, { "Columns", "columns" }, 2),
		SubPages = pick(data, { "SubPages", "subpages" }, false),
		Icon = pick(data, { "Icon", "icon" }, nil),
		_tab = nil,
	}

	if not page.SubPages then
		page._tab = self._raw:AddTab(page.Name, resolve_tab_icon(page.Icon))
	end

	page = setmetatable(page, PageMethods)

	self._pagesByName = self._pagesByName or {}
	self._pagesByName[normalize_page_name(page.Name)] = page

	if is_gui_page_name(page.Name) then
		try_attach_gui_settings(self, page)
	end

	return page
end

function Library:NextFlag()
	return next_flag("ReverseFlag")
end

function Library:SetFlagLoadPriority()
	return nil
end

function Library:NormalizeKeybindValue(key)
	return normalize_keybind_value(key)
end

function Library:NormalizeConfigName(name)
	if name == nil then
		return nil
	end

	local cleaned = tostring(name):gsub("[\\/:*?\"<>|]", ""):gsub("^%s+", ""):gsub("%s+$", "")
	if cleaned == "" then
		return nil
	end

	return cleaned
end

function Library:Notification(title, text, duration)
	Obsidian:Notify({
		Title = tostring(title or "Notification"),
		Description = tostring(text or ""),
		Time = duration or 5,
	})
end

function Library.SendNotification(settings)
	settings = settings or {}
	return Library:Notification(
		pick(settings, { "title", "Title" }, "Notification"),
		pick(settings, { "text", "Text", "description", "Description" }, ""),
		pick(settings, { "duration", "Duration" }, 5)
	)
end

function Library:LoadAutoloadConfig(skipNotification)
	ensure_theme_managers()

	if not persistence_supported() then
		self._autoSaveReady = true
		self._autoSaveSuspended = false
		return false, "persistence unavailable"
	end

	self._autoSaveSuspended = true

	local loadedName = nil
	local result = nil
	local autoloadName = "none"

	pcall(function()
		if SaveManager.GetAutoloadConfig then
			autoloadName = SaveManager:GetAutoloadConfig()
		end
	end)

	if autoloadName ~= nil and autoloadName ~= "" and autoloadName ~= "none" then
		local ok, err = SaveManager:Load(autoloadName)
		if ok then
			loadedName = autoloadName
		else
			result = err
		end
	end

	if loadedName == nil and self.AutoSaveEnabled then
		local autoSaveName = get_auto_save_name()
		local ok, err = SaveManager:Load(autoSaveName)
		if ok then
			loadedName = autoSaveName
			result = err
		elseif result == nil then
			result = err
		end
	end

	mark_auto_save_ready(0.35)

	if loadedName == nil and not skipNotification and result ~= nil and result ~= "invalid file" and result ~= "no config file is selected" then
		self:Notification("Error", tostring(result), 5)
	end

	return loadedName ~= nil, loadedName or result
end

function Library:Watermark(name)
	if self._watermark then
		return self._watermark
	end

	self._watermark = create_disabled_watermark()
	return self._watermark
end

function Library:KeybindList()
	if self._keybindList then
		return self._keybindList
	end

	self._keybindList = create_keybind_list()
	return self._keybindList
end

function Library:CreateSettingsPage(window, watermark, keybindList)
	if not window or not window._raw then
		return nil
	end

	if self._settingsPages[window] then
		return self._settingsPages[window]
	end

	ensure_theme_managers()

	local page = {
		Window = window,
		Name = "Gui",
		Columns = 2,
		SubPages = false,
		Page = nil,
		Menu = nil,
	}

	window._pendingGuiSettings = {
		keybindList = keybindList,
		Descriptor = page,
	}
	window._guiSettingsAttached = false

	if watermark and watermark.SetVisibility then
		watermark:SetVisibility(false)
	end

	try_attach_gui_settings(window)

	pcall(function()
		Library:LoadAutoloadConfig(true)
	end)

	self._settingsPages[window] = page
	return page
end

function Library:Window(data)
	if self._mainWindow then
		return self._mainWindow
	end

	data = data or {}
	ensure_theme_managers()

	local guiParent = gethui()
	local snapshot = {}
	for _, child in ipairs(guiParent:GetChildren()) do
		snapshot[child] = true
	end

	self.MenuKeybind = normalize_keybind_value(pick(data, { "menu_keybind", "MenuKeybind" }, self.MenuKeybind))

	local rawWindow = Obsidian:CreateWindow({
		Title = pick(data, { "Title", "title" }, "reverse"),
		Footer = pick(data, { "Footer", "footer" }, "version: reverse"),
		Icon = pick(data, { "Icon", "icon", "Logo", "logo" }, 95816097006870),
		NotifySide = pick(data, { "NotifySide", "notify_side" }, "Right"),
		ShowCustomCursor = pick(data, { "ShowCustomCursor", "show_custom_cursor" }, false),
		Center = pick(data, { "Center", "center" }, nil),
		AutoShow = pick(data, { "AutoShow", "auto_show" }, nil),
		Resizable = pick(data, { "Resizable", "resizable" }, nil),
		Position = pick(data, { "Position", "position" }, nil),
		Size = pick(data, { "Size", "size" }, nil),
	})

	task.wait()

	local window = setmetatable({
		_raw = rawWindow,
		_snapshot = snapshot,
		_guiRoot = nil,
		IsOpen = true,
		_pagesByName = {},
		_pendingGuiSettings = nil,
		_guiSettingsAttached = false,
	}, WindowMethods)

	window._guiRoot = window:_find_gui_root()
	self._mainWindow = window
	table.insert(self._windows, window)

	track_connection(UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if key_matches_input(Library.MenuKeybind, input)
			or (Library.FallbackMenuKeybind ~= nil and normalize_keybind_value(Library.FallbackMenuKeybind) ~= normalize_keybind_value(Library.MenuKeybind) and key_matches_input(Library.FallbackMenuKeybind, input))
		then
			window:Toggle()
		end
	end))

	schedule_auto_restore()

	return window
end

function Library:Unload()
	pcall(function()
		perform_auto_save()
	end)

	for _, connection in ipairs(self._connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	self._connections = {}
	self._settingsPages = {}
	self._windows = {}
	self._mainWindow = nil
	self._autoSaveQueued = false
	self._autoSaveReady = false
	self._autoSaveSuspended = false
	self._autoLoadScheduled = false

	if self._watermark then
		self._watermark:Destroy()
		self._watermark = nil
	end

	if self._keybindList then
		self._keybindList:Destroy()
		self._keybindList = nil
	end

	pcall(function()
		Obsidian:Unload()
	end)

	if rawget(getgenv(), "__reverse_obsidian_compat") == self then
		getgenv().__reverse_obsidian_compat = nil
	end

	if rawget(getgenv(), "Library") == self then
		getgenv().Library = nil
	end
end

function Library.new(settings)
	settings = settings or {}

	local root = setmetatable({
		_window = Library:Window({
			Title = pick(settings, { "title", "Title" }, "reverse"),
			Footer = pick(settings, { "footer", "Footer" }, "version: reverse"),
			Icon = pick(settings, { "logo", "Logo", "icon", "Icon" }, 95816097006870),
			MenuKeybind = pick(settings, { "menu_keybind", "MenuKeybind" }, Library.MenuKeybind),
		}),
		Flags = Library.Flags,
	}, CompatRoot)

	if pick(settings, { "watermark", "Watermark" }, false) then
		root._watermark = Library:Watermark(pick(settings, { "watermark_text", "WatermarkText" }, "reverse"))
		root._watermark:BindToggle(root._window)
	end

	if pick(settings, { "keybind_list", "KeybindList" }, true) then
		root._keybind_list = Library:KeybindList()
	end

	if pick(settings, { "settings_page", "SettingsPage" }, false) then
		root._settings_page = Library:CreateSettingsPage(root._window, root._watermark, root._keybind_list)
	end

	return root
end

function CompatRoot:create_tab(title, icon)
	local page = self._window:Page({
		Name = title or "Tab",
		Columns = 2,
		Icon = icon,
	})

	return setmetatable({
		_root = self,
		_page = page,
		_title = title,
		_icon = icon,
	}, CompatTab)
end

function CompatRoot:Unload()
	return Library:Unload()
end

function CompatRoot:load()
	task.defer(function()
		if Library then
			Library:LoadAutoloadConfig(true)
		end
	end)

	return self
end

CompatRoot.Load = CompatRoot.load

function CompatRoot:SendNotification(settings)
	return Library.SendNotification(settings)
end

function CompatTab:create_module(settings)
	settings = settings or {}
	local moduleTitle = pick(settings, { "title", "Title", "name", "Name" }, "Module")

	local side = pick(settings, { "section", "Section", "side", "Side" }, "left")
	local section = self._page:Section({
		Name = moduleTitle,
		Side = (side == 2 or side == "right" or side == "Right") and 2 or 1,
	})

	local moduleFlag = pick(settings, { "flag", "Flag" }, next_flag("Module"))
	local module = setmetatable({
		_tab = self,
		_section = section,
		_flag = moduleFlag,
		_state = false,
		_toggle = nil,
		_keybind = nil,
	}, CompatModule)

	local description = pick(settings, { "description", "Description" }, nil)
	if description and tostring(description) ~= "" then
		module._description = section:Label(tostring(description))
	end

	local callback = pick(settings, { "callback", "Callback" }, function() end)
	module._toggle = section:Toggle({
		Name = pick(settings, { "toggle_title", "ToggleTitle" }, "Enabled"),
		Flag = moduleFlag,
		Default = pick(settings, { "default", "Default", "enabled", "Enabled", "value", "Value" }, false),
		Callback = function(value)
			module._state = value
			callback(value)
		end,
	})

	module._state = module._toggle:Get()
	Library:SetFlagLoadPriority(moduleFlag, 100, "module_toggle")

	do
		local keybindLabel = section:Label("Keybind")
		local initialized = false
		local lastToggleState = module._state

		module._keybind_label = keybindLabel
		module._keybind = keybindLabel:Keybind({
			Flag = moduleFlag .. "_keybind",
			Default = pick(settings, { "keybind", "Keybind", "default_keybind", "DefaultKeybind" }, nil),
			Mode = pick(settings, { "keybind_mode", "KeybindMode" }, "Toggle"),
			SyncToggleState = false,
			Text = moduleTitle,
			Callback = function(value)
				if not initialized then
					return
				end

				if value == lastToggleState then
					return
				end

				lastToggleState = value
				module:change_state(value)
			end,
		})

		local _, _, toggled = module._keybind:Get()
		lastToggleState = toggled or module._state
		initialized = true
	end

	return module
end

function CompatModule:Get()
	return self._state
end

function CompatModule:change_state(state)
	self._toggle:Set(state)
	self._state = self._toggle:Get()
	return self
end

CompatModule.Set = CompatModule.change_state

function CompatModule:connect_keybind()
	return self._keybind
end

function CompatModule:scale_keybind()
	return self._keybind
end

function CompatModule:create_paragraph(settings)
	settings = settings or {}
	return self._section:Label(compose_text(settings, "Paragraph"))
end

function CompatModule:create_button(settings)
	settings = settings or {}
	return self._section:Button():Add(
		pick(settings, { "title", "Title", "name", "Name", "text", "Text" }, "Button"),
		pick(settings, { "callback", "Callback", "button_callback", "ButtonCallback" }, function() end)
	)
end

function CompatModule:create_display(settings)
	settings = settings or {}
	local display = self:create_text({
		title = pick(settings, { "title", "Title" }, "Display"),
		text = pick(settings, { "text", "Text", "image", "Image" }, "Preview"),
	})

	function display:SetImage(image)
		return self:Set({
			title = pick(settings, { "title", "Title" }, "Display"),
			text = image and ("Image: " .. tostring(image)) or "Preview",
		})
	end

	return display
end

function CompatModule:create_colorpicker(settings)
	settings = settings or {}
	local host = self._section:Label(pick(settings, { "title", "Title", "name", "Name" }, "Color"))
	return host:Colorpicker(settings)
end

function CompatModule:create_3dview(settings)
	settings = settings or {}
	local display = self:create_text({
		title = pick(settings, { "title", "Title" }, "3D View"),
		text = pick(settings, { "text", "Text", "image", "Image" }, "3D preview is not available in this compatibility layer"),
	})

	function display:SetModel(model)
		return self:Set({
			title = pick(settings, { "title", "Title" }, "3D View"),
			text = model and ("Model: " .. tostring(model)) or "Model cleared",
		})
	end

	function display:SetMesh(meshId, textureId)
		return self:Set({
			title = pick(settings, { "title", "Title" }, "3D View"),
			text = string.format("Mesh: %s | Texture: %s", tostring(meshId), tostring(textureId)),
		})
	end

	function display:SetImage(image)
		return self:Set({
			title = pick(settings, { "title", "Title" }, "3D View"),
			text = image and ("Image: " .. tostring(image)) or "Preview",
		})
	end

	return display
end

function CompatModule:create_text(settings)
	settings = settings or {}
	return self._section:Label(compose_text(settings, "Text"))
end

function CompatModule:create_textbox(settings)
	settings = settings or {}
	return self._section:Textbox({
		Name = pick(settings, { "title", "Title", "name", "Name" }, "Textbox"),
		Flag = pick(settings, { "flag", "Flag" }, next_flag("Textbox")),
		Default = pick(settings, { "default", "Default", "value", "Value" }, ""),
		Numeric = pick(settings, { "numeric", "Numeric" }, false),
		Finished = pick(settings, { "finished", "Finished" }, false),
		Placeholder = pick(settings, { "placeholder", "Placeholder" }, "..."),
		Callback = pick(settings, { "callback", "Callback" }, function() end),
	})
end

function CompatModule:create_checkbox(settings)
	settings = settings or {}
	return self._section:Toggle({
		Name = pick(settings, { "title", "Title", "name", "Name" }, "Checkbox"),
		Flag = pick(settings, { "flag", "Flag" }, next_flag("Checkbox")),
		Default = pick(settings, { "default", "Default", "value", "Value", "enabled", "Enabled", "checked" }, false),
		Callback = pick(settings, { "callback", "Callback" }, function() end),
	})
end

function CompatModule:create_divider(settings)
	settings = settings or {}
	local title = pick(settings, { "title", "Title" }, nil)
	if title ~= nil then
		self._section:Label("----- " .. tostring(title) .. " -----")
		return true
	end

	return self._section:Divider()
end

function CompatModule:create_slider(settings)
	settings = settings or {}
	return self._section:Slider({
		Name = pick(settings, { "title", "Title", "name", "Name" }, "Slider"),
		Flag = pick(settings, { "flag", "Flag" }, next_flag("Slider")),
		Min = pick(settings, { "minimum_value", "MinimumValue", "min", "Min" }, 0),
		Max = pick(settings, { "maximum_value", "MaximumValue", "max", "Max" }, 100),
		Default = pick(settings, { "value", "Value", "default", "Default" }, 0),
		Decimals = pick(settings, { "decimals", "Decimals" }, nil),
		round_number = pick(settings, { "round_number", "RoundNumber" }, false),
		Suffix = pick(settings, { "suffix", "Suffix" }, ""),
		Callback = pick(settings, { "callback", "Callback" }, function() end),
	})
end

function CompatModule:create_dropdown(settings)
	settings = settings or {}
	return self._section:Dropdown({
		Name = pick(settings, { "title", "Title", "name", "Name" }, "Dropdown"),
		Flag = pick(settings, { "flag", "Flag" }, next_flag("Dropdown")),
		Items = pick(settings, { "options", "Options", "items", "Items" }, {}),
		Default = pick(settings, { "default", "Default", "value", "Value" }, nil),
		Multi = pick(settings, { "multi_dropdown", "MultiDropdown", "multi", "Multi" }, false),
		Callback = pick(settings, { "callback", "Callback" }, function() end),
	})
end

function CompatModule:create_feature(settings)
	settings = settings or {}
	if pick(settings, { "disablecheck", "DisableCheck" }, false) then
		return self:create_button({
			title = pick(settings, { "title", "Title", "name", "Name" }, "Feature"),
			callback = pick(settings, { "button_callback", "ButtonCallback", "callback", "Callback" }, function() end),
		})
	end

	return self:create_checkbox({
		title = pick(settings, { "title", "Title", "name", "Name" }, "Feature"),
		flag = pick(settings, { "flag", "Flag" }, next_flag("Feature")),
		default = pick(settings, { "default", "Default", "checked" }, false),
		callback = pick(settings, { "callback", "Callback" }, function() end),
	})
end

getgenv().__reverse_obsidian_compat = Library
getgenv().Library = Library

return Library
