-- LEGACY PIECE — OVER HEAVEN
-- Host this file as loader.lua on a public URL and load it with:
-- loadstring(game:HttpGet("https://SEU-DOMINIO/loader.lua"))()
--
-- IMPORTANT:
-- This script keeps the actual in-game APIs abstracted behind GameAdapter.
-- Replace the stubs with the real methods from your target game.
-- Do not invent RemoteEvents, coordinates, or mechanics.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player and player:WaitForChild("PlayerGui")

local THEME = {
	Black = Color3.fromRGB(8, 8, 12),
	BlackAlt = Color3.fromRGB(16, 16, 22),
	Gold = Color3.fromRGB(212, 175, 55),
	Purple = Color3.fromRGB(124, 79, 255),
	Red = Color3.fromRGB(200, 55, 55),
	Green = Color3.fromRGB(70, 200, 120),
	Gray = Color3.fromRGB(165, 165, 170),
	White = Color3.fromRGB(240, 240, 255),
	Muted = Color3.fromRGB(128, 128, 136),
}

local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

local function setCornerRadius(instance, radius)
	if instance then
		instance.CornerRadius = UDim.new(0, radius)
	end
end

local function tweenObject(instance, properties, duration, easingStyle, easingDirection)
	if not instance then
		return nil
	end

	local tweenInfo = TweenInfo.new(duration or 0.18, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

local function create(instanceType, properties, parent)
	local instance = Instance.new(instanceType)
	for key, value in pairs(properties or {}) do
		instance[key] = value
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

local NotificationQueue = {}
local notificationRunning = false

local function pushNotification(text, accentColor)
	table.insert(NotificationQueue, {
		Text = text,
		Color = accentColor or THEME.Gold,
	})

	if notificationRunning then
		return
	end

	notificationRunning = true
	task.spawn(function()
		while #NotificationQueue > 0 do
			local data = table.remove(NotificationQueue, 1)
			if _G.__LegacyPieceNotification then
				_G.__LegacyPieceNotification.Text = data.Text
				_G.__LegacyPieceNotification.TextColor3 = data.Color
				_G.__LegacyPieceNotification.Visible = true
				_G.__LegacyPieceNotification.BackgroundTransparency = 0.12
				tweenObject(_G.__LegacyPieceNotification, {
					Position = UDim2.new(1, -260, 0, 36),
				}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				task.wait(2.2)
				tweenObject(_G.__LegacyPieceNotification, {
					Position = UDim2.new(1, 16, 0, 36),
				}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				task.wait(0.2)
				_G.__LegacyPieceNotification.Visible = false
			end
		end
		notificationRunning = false
	end)
end

local UIState = {
	WindowOpen = true,
	Routines = {
		Dungeon = { Active = false, Status = "IDLE", Stage = 0, Enemies = 0, Progress = 0, LastBeat = "Awaiting..." },
		Ychwach = { Active = false, Status = "IDLE", Objective = "Awaiting task...", Progress = 0, State = "WAITING" },
		GirMagician = { Active = false, Status = "IDLE", Objective = "Awaiting task...", Progress = 0, State = "WAITING" },
	},
}

local function setRoutineStatus(routineName, newStatus)
	UIState.Routines[routineName].Status = newStatus
	if _G.__LEGACY_UI and _G.__LEGACY_UI.RoutineLabels[routineName] then
		_G.__LEGACY_UI.RoutineLabels[routineName].Text = newStatus
		_G.__LEGACY_UI.RoutineLabels[routineName].TextColor3 = newStatus == "RUNNING" and THEME.Gold or newStatus == "COMPLETED" and THEME.Green or newStatus == "IDLE" and THEME.Gray or THEME.Red
	end
end

local function setRoutineObjective(routineName, objectiveText)
	UIState.Routines[routineName].Objective = objectiveText
	if _G.__LEGACY_UI and _G.__LEGACY_UI.Objectives[routineName] then
		_G.__LEGACY_UI.Objectives[routineName].Text = "Objective: " .. tostring(objectiveText)
	end
end

local function setRoutineProgress(routineName, value)
	UIState.Routines[routineName].Progress = clamp(value, 0, 100)
	if _G.__LEGACY_UI and _G.__LEGACY_UI.ProgressBars[routineName] then
		_G.__LEGACY_UI.ProgressBars[routineName].Size = UDim2.new(UIState.Routines[routineName].Progress / 100, 0, 1, 0)
	end
end

local function updateDungeonUI()
	if not _G.__LEGACY_UI then
		return
	end
	_G.__LEGACY_UI.Stage.Text = "Stage: " .. tostring(UIState.Routines.Dungeon.Stage)
	_G.__LEGACY_UI.Enemies.Text = "Enemies: " .. tostring(UIState.Routines.Dungeon.Enemies)
	_G.__LEGACY_UI.ProgressBars.Dungeon.Size = UDim2.new(UIState.Routines.Dungeon.Progress / 100, 0, 1, 0)
	_G.__LEGACY_UI.Objectives.Dungeon.Text = "Objective: " .. tostring(UIState.Routines.Dungeon.LastBeat)
end

local function safeRun(callback, ...)
	if type(callback) ~= "function" then
		return nil
	end
	local success, result = pcall(callback, ...)
	if not success then
		warn("[LEGACY PIECE] Callback failed:", result)
		return nil
	end
	return result
end

-- =====================================================
-- GameAdapter: replace these stubs with real game APIs.
-- Keep them generic and honest. No fake remoters.
-- =====================================================
local GameAdapter = {
	Dungeon = {
		Start = function()
			return true
		end,
		Stop = function()
			return true
		end,
		GetProgress = function()
			return {
				Stage = 0,
				EnemiesDefeated = 0,
				Progress = 0,
				CurrentObjective = "Awaiting dungeon state...",
			}
		end,
		AdvanceStage = function()
			return true
		end,
		IsRunning = function()
			return false
		end,
	},
	Ychwach = {
		Start = function()
			return true
		end,
		Stop = function()
			return true
		end,
		GetStatus = function()
			return {
				Running = false,
				State = "WAITING",
				Objective = "Awaiting event state...",
				Progress = 0,
			}
		end,
		CompleteObjective = function()
			return true
		end,
	},
	GirMagician = {
		Start = function()
			return true
		end,
		Stop = function()
			return true
		end,
		GetStatus = function()
			return {
				Running = false,
				State = "WAITING",
				Objective = "Awaiting objective...",
				Progress = 0,
			}
		end,
		CompleteObjective = function()
			return true
		end,
	},
}

local activeTasks = {}

local function hasTask(name)
	return activeTasks[name] ~= nil
end

local function stopTask(name)
	if activeTasks[name] then
		task.cancel(activeTasks[name])
		activeTasks[name] = nil
	end
end

local function beginTask(name, callback)
	if hasTask(name) then
		return false
	end
	local handle = task.spawn(callback)
	activeTasks[name] = handle
	return true
end

-- =====================================================
-- DUNGEON ROUTINE
-- =====================================================
local function runDungeonRoutine()
	while UIState.Routines.Dungeon.Active do
		local status = GameAdapter.Dungeon.GetProgress()
		UIState.Routines.Dungeon.Stage = tonumber(status.Stage or 0) or 0
		UIState.Routines.Dungeon.Enemies = tonumber(status.EnemiesDefeated or 0) or 0
		UIState.Routines.Dungeon.Progress = clamp(tonumber(status.Progress or 0) or 0, 0, 100)
		UIState.Routines.Dungeon.LastBeat = tostring(status.CurrentObjective or "Awaiting...")
		updateDungeonUI()

		if GameAdapter.Dungeon.IsRunning and GameAdapter.Dungeon.IsRunning() then
			setRoutineStatus("Dungeon", "RUNNING")
		else
			setRoutineStatus("Dungeon", "IDLE")
		end

		if UIState.Routines.Dungeon.Stage > 0 and UIState.Routines.Dungeon.Progress >= 100 then
			local advanced = safeRun(GameAdapter.Dungeon.AdvanceStage)
			if advanced ~= false then
				pushNotification("Dungeon stage cleared.", THEME.Gold)
			end
		end

		if UIState.Routines.Dungeon.Enemies > 0 and UIState.Routines.Dungeon.Enemies % 25 == 0 then
			pushNotification("DIO Over Heaven has been defeated.", THEME.Red)
		end

		task.wait(0.35)
	end
end

local function startDungeon()
	if UIState.Routines.Dungeon.Active then
		return
	end

	UIState.Routines.Dungeon.Active = true
	setRoutineStatus("Dungeon", "RUNNING")
	if _G.__LEGACY_UI and _G.__LEGACY_UI.Buttons and _G.__LEGACY_UI.Buttons.DungeonStart then
		_G.__LEGACY_UI.Buttons.DungeonStart.Text = "RUNNING"
		_G.__LEGACY_UI.Buttons.DungeonStart.BackgroundColor3 = THEME.Gold
	end

	local started = safeRun(GameAdapter.Dungeon.Start)
	if started == false then
		UIState.Routines.Dungeon.Active = false
		setRoutineStatus("Dungeon", "IDLE")
		return
	end

	if hasTask("Dungeon") then
		stopTask("Dungeon")
	end
	beginTask("Dungeon", runDungeonRoutine)
	pushNotification("Dungeon routine started.", THEME.Gold)
end

local function stopDungeon()
	if not UIState.Routines.Dungeon.Active then
		return
	end

	UIState.Routines.Dungeon.Active = false
	stopTask("Dungeon")
	setRoutineStatus("Dungeon", "IDLE")
	safeRun(GameAdapter.Dungeon.Stop)
	if _G.__LEGACY_UI and _G.__LEGACY_UI.Buttons and _G.__LEGACY_UI.Buttons.DungeonStart then
		_G.__LEGACY_UI.Buttons.DungeonStart.Text = "START DUNGEON"
		_G.__LEGACY_UI.Buttons.DungeonStart.BackgroundColor3 = THEME.Purple
	end
	pushNotification("Dungeon routine stopped.", THEME.Red)
end

-- =====================================================
-- YCHWACH ROUTINE
-- =====================================================
local function runYchwachRoutine()
	while UIState.Routines.Ychwach.Active do
		local status = GameAdapter.Ychwach.GetStatus()
		UIState.Routines.Ychwach.Objective = tostring(status.Objective or "Awaiting task...")
		UIState.Routines.Ychwach.Progress = clamp(tonumber(status.Progress or 0) or 0, 0, 100)
		UIState.Routines.Ychwach.State = tostring(status.State or "WAITING")
		setRoutineObjective("Ychwach", UIState.Routines.Ychwach.Objective)
		setRoutineProgress("Ychwach", UIState.Routines.Ychwach.Progress)

		if tostring(status.State or "WAITING"):upper() == "COMPLETED" then
			setRoutineStatus("Ychwach", "COMPLETED")
			safeRun(GameAdapter.Ychwach.CompleteObjective)
			pushNotification("Ychwach event completed.", THEME.Green)
			break
		end

		if tostring(status.State or "WAITING"):upper() == "RUNNING" then
			setRoutineStatus("Ychwach", "RUNNING")
		else
			setRoutineStatus("Ychwach", "IDLE")
		end

		task.wait(0.35)
	end

	if UIState.Routines.Ychwach.Active then
		UIState.Routines.Ychwach.Active = false
		setRoutineStatus("Ychwach", "IDLE")
		if _G.__LEGACY_UI and _G.__LEGACY_UI.Buttons and _G.__LEGACY_UI.Buttons.YchwachStart then
			_G.__LEGACY_UI.Buttons.YchwachStart.Text = "START AUTO YCHWACH"
			_G.__LEGACY_UI.Buttons.YchwachStart.BackgroundColor3 = THEME.Purple
		end
	end
end

local function startYchwach()
	if UIState.Routines.Ychwach.Active then
		return
	end

	UIState.Routines.Ychwach.Active = true
	setRoutineStatus("Ychwach", "RUNNING")
	if _G.__LEGACY_UI and _G.__LEGACY_UI.Buttons and _G.__LEGACY_UI.Buttons.YchwachStart then
		_G.__LEGACY_UI.Buttons.YchwachStart.Text = "RUNNING"
		_G.__LEGACY_UI.Buttons.YchwachStart.BackgroundColor3 = THEME.Gold
	end

	local started = safeRun(GameAdapter.Ychwach.Start)
	if started == false then
		UIState.Routines.Ychwach.Active = false
		setRoutineStatus("Ychwach", "IDLE")
		return
	end

	if hasTask("Ychwach") then
		stopTask("Ychwach")
	end
	beginTask("Ychwach", runYchwachRoutine)
	pushNotification("Ychwach routine started.", THEME.Purple)
end

local function stopYchwach()
	if not UIState.Routines.Ychwach.Active then
		return
	end

	UIState.Routines.Ychwach.Active = false
	stopTask("Ychwach")
	setRoutineStatus("Ychwach", "IDLE")
	safeRun(GameAdapter.Ychwach.Stop)
	if _G.__LEGACY_UI and _G.__LEGACY_UI.Buttons and _G.__LEGACY_UI.Buttons.YchwachStart then
		_G.__LEGACY_UI.Buttons.YchwachStart.Text = "START AUTO YCHWACH"
		_G.__LEGACY_UI.Buttons.YchwachStart.BackgroundColor3 = THEME.Purple
	end
	pushNotification("Ychwach routine stopped.", THEME.Red)
end

-- =====================================================
-- GIR MAGICIAN ROUTINE
-- =====================================================
local function runGirRoutine()
	while UIState.Routines.GirMagician.Active do
		local status = GameAdapter.GirMagician.GetStatus()
		UIState.Routines.GirMagician.Objective = tostring(status.Objective or "Awaiting objective...")
		UIState.Routines.GirMagician.Progress = clamp(tonumber(status.Progress or 0) or 0, 0, 100)
		UIState.Routines.GirMagician.State = tostring(status.State or "WAITING")
		setRoutineObjective("GirMagician", UIState.Routines.GirMagician.Objective)
		setRoutineProgress("GirMagician", UIState.Routines.GirMagician.Progress)

		if tostring(status.State or "WAITING"):upper() == "FOUND" then
			pushNotification("Gir Magician objective found.", THEME.Gold)
		end

		if tostring(status.State or "WAITING"):upper() == "COMPLETED" then
			setRoutineStatus("GirMagician", "COMPLETED")
			safeRun(GameAdapter.GirMagician.CompleteObjective)
			pushNotification("Gir Magician objective completed.", THEME.Green)
			break
		end

		if tostring(status.State or "WAITING"):upper() == "RUNNING" then
			setRoutineStatus("GirMagician", "RUNNING")
		else
			setRoutineStatus("GirMagician", "IDLE")
		end

		task.wait(0.35)
	end

	if UIState.Routines.GirMagician.Active then
		UIState.Routines.GirMagician.Active = false
		setRoutineStatus("GirMagician", "IDLE")
		if _G.__LEGACY_UI and _G.__LEGACY_UI.Buttons and _G.__LEGACY_UI.Buttons.GirStart then
			_G.__LEGACY_UI.Buttons.GirStart.Text = "START AUTO GIR MAGICIAN"
			_G.__LEGACY_UI.Buttons.GirStart.BackgroundColor3 = THEME.Purple
		end
	end
end

local function startGirRoutine()
	if UIState.Routines.GirMagician.Active then
		return
	end

	UIState.Routines.GirMagician.Active = true
	setRoutineStatus("GirMagician", "RUNNING")
	if _G.__LEGACY_UI and _G.__LEGACY_UI.Buttons and _G.__LEGACY_UI.Buttons.GirStart then
		_G.__LEGACY_UI.Buttons.GirStart.Text = "RUNNING"
		_G.__LEGACY_UI.Buttons.GirStart.BackgroundColor3 = THEME.Gold
	end

	local started = safeRun(GameAdapter.GirMagician.Start)
	if started == false then
		UIState.Routines.GirMagician.Active = false
		setRoutineStatus("GirMagician", "IDLE")
		return
	end

	if hasTask("GirMagician") then
		stopTask("GirMagician")
	end
	beginTask("GirMagician", runGirRoutine)
	pushNotification("Gir Magician routine started.", THEME.Purple)
end

local function stopGirRoutine()
	if not UIState.Routines.GirMagician.Active then
		return
	end

	UIState.Routines.GirMagician.Active = false
	stopTask("GirMagician")
	setRoutineStatus("GirMagician", "IDLE")
	safeRun(GameAdapter.GirMagician.Stop)
	if _G.__LEGACY_UI and _G.__LEGACY_UI.Buttons and _G.__LEGACY_UI.Buttons.GirStart then
		_G.__LEGACY_UI.Buttons.GirStart.Text = "START AUTO GIR MAGICIAN"
		_G.__LEGACY_UI.Buttons.GirStart.BackgroundColor3 = THEME.Purple
	end
	pushNotification("Gir Magician routine stopped.", THEME.Red)
end

-- =====================================================
-- GENERAL CONTROLS
-- =====================================================
local function startAll()
	if UIState.Routines.Dungeon.Active or UIState.Routines.Ychwach.Active or UIState.Routines.GirMagician.Active then
		return
	end

	startDungeon()
	task.wait(0.08)
	startYchwach()
	task.wait(0.08)
	startGirRoutine()
	pushNotification("All routines started.", THEME.Green)
end

local function stopAll()
	stopDungeon()
	stopYchwach()
	stopGirRoutine()
	pushNotification("All routines stopped.", THEME.Red)
end

-- =====================================================
-- UI BUILD
-- =====================================================
local function buildUI()
	local root = create("ScreenGui", {
		Name = "LEGACY_PIECE_OVER_HEAVEN",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		Enabled = true,
	}, playerGui)

	local window = create("Frame", {
		Name = "Window",
		BackgroundColor3 = THEME.Black,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 520, 0, 430),
		ClipsDescendants = true,
	}, root)

	local shadow = create("Frame", {
		Name = "Shadow",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 0.45,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 18),
		Size = UDim2.new(1, 18, 1, 18),
		ZIndex = 0,
	}, window)
	setCornerRadius(window, 18)
	setCornerRadius(shadow, 18)

	local accent = create("Frame", {
		Name = "Accent",
		BackgroundColor3 = THEME.Gold,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 4),
	}, window)

	local header = create("Frame", {
		Name = "Header",
		BackgroundColor3 = THEME.BlackAlt,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 4),
		Size = UDim2.new(1, 0, 0, 42),
	}, window)

	local title = create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 18, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "LEGACY PIECE — OVER HEAVEN",
		TextColor3 = THEME.Gold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, header)

	local closeButton = create("TextButton", {
		Name = "Close",
		BackgroundColor3 = THEME.Red,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -32, 0.5, -10),
		Size = UDim2.new(0, 20, 0, 20),
		AutoButtonColor = false,
		Text = "X",
		TextColor3 = THEME.White,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
	}, header)
	setCornerRadius(closeButton, 8)

	local minimizeButton = create("TextButton", {
		Name = "Minimize",
		BackgroundColor3 = THEME.Purple,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -58, 0.5, -10),
		Size = UDim2.new(0, 20, 0, 20),
		AutoButtonColor = false,
		Text = "_",
		TextColor3 = THEME.White,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
	}, header)
	setCornerRadius(minimizeButton, 8)

	local body = create("Frame", {
		Name = "Body",
		BackgroundColor3 = THEME.Black,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(1, 0, 1, -46),
	}, window)

	local statusStrip = create("Frame", {
		Name = "StatusStrip",
		BackgroundColor3 = THEME.BlackAlt,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 8),
		Size = UDim2.new(1, -20, 0, 38),
	}, body)
	setCornerRadius(statusStrip, 10)

	local statusTitle = create("TextLabel", {
		Name = "StatusTitle",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0.2, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "STATUS",
		TextColor3 = THEME.Gold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, statusStrip)

	local statusBadges = {}
	local statusInfos = {
		{ Key = "Dungeon", Label = "DUNGEON", PosX = 0.26 },
		{ Key = "Ychwach", Label = "YCHWACH", PosX = 0.52 },
		{ Key = "GirMagician", Label = "GIR", PosX = 0.78 },
	}

	for _, info in ipairs(statusInfos) do
		local badge = create("Frame", {
			Name = info.Key .. "Badge",
			BackgroundColor3 = THEME.Black,
			BorderSizePixel = 0,
			Position = UDim2.new(info.PosX, 0, 0.5, -12),
			Size = UDim2.new(0, 120, 0, 24),
		}, statusStrip)
		setCornerRadius(badge, 8)

		local label = create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -12, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = info.Label,
			TextColor3 = THEME.Gray,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, badge)

		local state = create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -60, 0, 0),
			Size = UDim2.new(0, 48, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = "IDLE",
			TextColor3 = THEME.Gray,
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Right,
		}, badge)

		statusBadges[info.Key] = { Badge = badge, Label = label, State = state }
	end

	local panels = create("Frame", {
		Name = "Panels",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 54),
		Size = UDim2.new(1, -20, 1, -64),
	}, body)

	local RoutineLabels = {}
	local Objectives = {}
	local ProgressBars = {}

	local function sectionPanel(sectionName, titleText, accentColor, yPosition)
		local panel = create("Frame", {
			Name = sectionName .. "Panel",
			BackgroundColor3 = THEME.BlackAlt,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, yPosition),
			Size = UDim2.new(1, 0, 0, 120),
		}, panels)
		setCornerRadius(panel, 12)

		local accentLine = create("Frame", {
			Name = "AccentLine",
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 3),
		}, panel)

		local titleLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 0, 8),
			Size = UDim2.new(1, -24, 0, 18),
			Font = Enum.Font.GothamBold,
			Text = titleText,
			TextColor3 = accentColor,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, panel)

		local status = create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -80, 0, 8),
			Size = UDim2.new(0, 70, 0, 18),
			Font = Enum.Font.GothamBold,
			Text = "IDLE",
			TextColor3 = THEME.Gray,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Right,
		}, panel)
		RoutineLabels[sectionName] = status

		local objective = create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 0, 30),
			Size = UDim2.new(1, -24, 0, 16),
			Font = Enum.Font.Gotham,
			Text = "Objective: Awaiting state...",
			TextColor3 = THEME.White,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, panel)
		Objectives[sectionName] = objective

		local barBack = create("Frame", {
			BackgroundColor3 = THEME.Black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 0, 56),
			Size = UDim2.new(1, -24, 0, 10),
		}, panel)
		setCornerRadius(barBack, 6)

		local barFill = create("Frame", {
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, 0, 1, 0),
		}, barBack)
		ProgressBars[sectionName] = barFill

		local stageText = create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 0, 76),
			Size = UDim2.new(0.5, 0, 0, 18),
			Font = Enum.Font.Gotham,
			Text = "Stage: 0",
			TextColor3 = THEME.White,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, panel)

		local enemyText = create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 76),
			Size = UDim2.new(0.5, -12, 0, 18),
			Font = Enum.Font.Gotham,
			Text = "Enemies: 0",
			TextColor3 = THEME.White,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Right,
		}, panel)

		local buttonHolder = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 0, 92),
			Size = UDim2.new(1, -24, 0, 26),
		}, panel)

		local startButtonText = sectionName == "Dungeon" and "START DUNGEON" or sectionName == "Ychwach" and "START AUTO YCHWACH" or "START AUTO GIR MAGICIAN"
		local stopButtonText = sectionName == "Dungeon" and "STOP DUNGEON" or sectionName == "Ychwach" and "STOP AUTO YCHWACH" or "STOP AUTO GIR MAGICIAN"

		local startBtn = create("TextButton", {
			BackgroundColor3 = THEME.Purple,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0.48, -4, 1, 0),
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = startButtonText,
			TextColor3 = THEME.White,
			TextSize = 10,
		}, buttonHolder)
		setCornerRadius(startBtn, 8)

		local stopBtn = create("TextButton", {
			BackgroundColor3 = THEME.Red,
			BorderSizePixel = 0,
			Position = UDim2.new(0.52, 0, 0, 0),
			Size = UDim2.new(0.48, -4, 1, 0),
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = stopButtonText,
			TextColor3 = THEME.White,
			TextSize = 10,
		}, buttonHolder)
		setCornerRadius(stopBtn, 8)

		if sectionName == "Dungeon" then
			startBtn.MouseButton1Click:Connect(startDungeon)
			stopBtn.MouseButton1Click:Connect(stopDungeon)
		elseif sectionName == "Ychwach" then
			startBtn.MouseButton1Click:Connect(startYchwach)
			stopBtn.MouseButton1Click:Connect(stopYchwach)
		elseif sectionName == "GirMagician" then
			startBtn.MouseButton1Click:Connect(startGirRoutine)
			stopBtn.MouseButton1Click:Connect(stopGirRoutine)
		end

		return {
			Stage = stageText,
			Enemies = enemyText,
			Buttons = {
				Start = startBtn,
				Stop = stopBtn,
			},
		}
	end

	local dungeonUI = sectionPanel("Dungeon", "DIO OVER HEAVEN DUNGEON", THEME.Gold, 0)
	local ychwachUI = sectionPanel("Ychwach", "AUTO YCHWACH — WORLD EVENT", THEME.Purple, 128)
	local girUI = sectionPanel("GirMagician", "AUTO GIR MAGICIAN", THEME.Red, 246)

	local generalPanel = create("Frame", {
		Name = "GeneralPanel",
		BackgroundColor3 = THEME.BlackAlt,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -58),
		Size = UDim2.new(1, 0, 0, 50),
	}, body)
	setCornerRadius(generalPanel, 12)

	local startAllBtn = create("TextButton", {
		BackgroundColor3 = THEME.Green,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(0.48, -18, 0, 26),
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		Text = "START ALL",
		TextColor3 = THEME.White,
		TextSize = 11,
	}, generalPanel)
	setCornerRadius(startAllBtn, 8)

	local stopAllBtn = create("TextButton", {
		BackgroundColor3 = THEME.Red,
		BorderSizePixel = 0,
		Position = UDim2.new(0.52, 6, 0, 12),
		Size = UDim2.new(0.48, -18, 0, 26),
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		Text = "STOP ALL",
		TextColor3 = THEME.White,
		TextSize = 11,
	}, generalPanel)
	setCornerRadius(stopAllBtn, 8)

	startAllBtn.MouseButton1Click:Connect(startAll)
	stopAllBtn.MouseButton1Click:Connect(stopAll)

	local notification = create("Frame", {
		Name = "Notification",
		BackgroundColor3 = THEME.BlackAlt,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 16, 0, 36),
		Size = UDim2.new(0, 220, 0, 34),
		Visible = false,
	}, root)
	setCornerRadius(notification, 10)
	notification.BackgroundTransparency = 0.12

	local notifText = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "READY",
		TextColor3 = THEME.Gold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, notification)

	_G.__LegacyPieceNotification = notification
	_G.__LEGACY_UI = {
		ProgressBars = ProgressBars,
		Objectives = Objectives,
		RoutineLabels = RoutineLabels,
		Buttons = {
			DungeonStart = dungeonUI.Buttons.Start,
			YchwachStart = ychwachUI.Buttons.Start,
			GirStart = girUI.Buttons.Start,
		},
		Stage = dungeonUI.Stage,
		Enemies = dungeonUI.Enemies,
	}

	local dragging = false
	local dragStart = nil
	local startPos = nil

	closeButton.MouseButton1Click:Connect(function()
		UIState.WindowOpen = false
		root.Enabled = false
	end)

	minimizeButton.MouseButton1Click:Connect(function()
		window.Visible = not window.Visible
	end)

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = window.Position
		end
	end)

	header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	setRoutineStatus("Dungeon", "IDLE")
	setRoutineStatus("Ychwach", "IDLE")
	setRoutineStatus("GirMagician", "IDLE")
	setRoutineProgress("Dungeon", 0)
	setRoutineProgress("Ychwach", 0)
	setRoutineProgress("GirMagician", 0)
	setRoutineObjective("Dungeon", "Awaiting dungeon state...")
	setRoutineObjective("Ychwach", "Awaiting event state...")
	setRoutineObjective("GirMagician", "Awaiting objective...")
	updateDungeonUI()

	return root
end

local function initialize()
	if _G.__LEGACY_PIECE_LOADED then
		return
	end
	_G.__LEGACY_PIECE_LOADED = true
	buildUI()
	pushNotification("SYSTEM READY", THEME.Gold)
end

initialize()

return true
