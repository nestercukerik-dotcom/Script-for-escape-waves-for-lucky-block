--========================================================--
-- Script Name: Escape Waves for Lucky Block HUB
-- Author: tik tok:gde_ja_rbx
-- Platform: Delta Executor (Mobile Friendly)
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

--========================================================--
-- 1. НАСТРОЙКА ИНТЕРФЕЙСА (GUI)
--========================================================--
local parentGui = pcall(function() return CoreGui end) and CoreGui or player:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("GdeJaRbxHub") then
	parentGui.GdeJaRbxHub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GdeJaRbxHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 360)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local topBlock = Instance.new("Frame")
topBlock.Size = UDim2.new(1, 0, 0, 10)
topBlock.Position = UDim2.new(0, 0, 1, -10)
topBlock.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
topBlock.BorderSizePixel = 0
topBlock.Parent = topBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -40, 1, 0)
titleLbl.Position = UDim2.new(0, 10, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "script by tik tok:gde_ja_rbx"
titleLbl.TextColor3 = Color3.fromRGB(200, 150, 255)
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 12
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0, 2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Parent = topBar
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local targetSize = isMinimized and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 360)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	TweenService:Create(mainFrame, tweenInfo, {Size = targetSize}):Play()
	minimizeBtn.Text = isMinimized and "+" or "-"
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -45)
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scrollFrame

local function createButton(text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 190, 0, 35)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	btn.Parent = scrollFrame
	return btn
end

--========================================================--
-- ПЕРЕМЕННЫЕ И ФУНКЦИИ ЛОГИКИ
--========================================================--
local savedCFrame = nil
local espEnabled = false
local espTextSize = 16

local function getRoot()
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function spamTeleport(targetCFrame)
	local root = getRoot()
	if not root then return end
	local finalCFrame = targetCFrame * CFrame.new(0, 3, -3)
	local endTime = tick() + 3
	task.spawn(function()
		while tick() < endTime do
			local currentRoot = getRoot()
			if currentRoot then
				currentRoot.CFrame = finalCFrame
				currentRoot.Velocity = Vector3.new(0, 0, 0)
			end
			task.wait(0.01)
		end
	end)
end

local function findBlock(keyword)
	for _, v in pairs(workspace:GetDescendants()) do
		if (v:IsA("Model") or v:IsA("BasePart")) and v.Name:lower():match(keyword:lower()) then
			if v:IsA("Model") and v.PrimaryPart then
				return v.PrimaryPart.CFrame
			elseif v:IsA("Model") and v:FindFirstChild("Part") then
				return v.Part.CFrame
			elseif v:IsA("BasePart") then
				return v.CFrame
			end
		end
	end
	return nil
end

local function updateEspSize()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local gui = p.Character.HumanoidRootPart:FindFirstChild("GdeJaESP")
			if gui and gui:FindFirstChild("Text") then
				gui.Text.TextSize = espTextSize
			end
		end
	end
end

--========================================================--
-- КНОПКИ
--========================================================--

-- 1. ESP (ВХ)
local btnEsp = createButton("ESP Игроков: ВЫКЛ", Color3.fromRGB(155, 89, 182))
btnEsp.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	btnEsp.Text = espEnabled and "ESP Игроков: ВКЛ" or "ESP Игроков: ВЫКЛ"
	btnEsp.BackgroundColor3 = espEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(155, 89, 182)
	
	if espEnabled then
		RunService:BindToRenderStep("PlayerESP_GdeJaRbx", 1, function()
			local myRoot = getRoot()
			if not myRoot then return end
			
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local targetRoot = p.Character.HumanoidRootPart
					local distance = math.floor((myRoot.Position - targetRoot.Position).Magnitude)
					
					local espGui = targetRoot:FindFirstChild("GdeJaESP")
					if not espGui then
						espGui = Instance.new("BillboardGui")
						espGui.Name = "GdeJaESP"
						espGui.Size = UDim2.new(0, 300, 0, 80)
						espGui.AlwaysOnTop = true
						espGui.MaxDistance = math.huge -- Видно через всю карту
						espGui.Parent = targetRoot
						
						local txt = Instance.new("TextLabel")
						txt.Name = "Text"
						txt.Size = UDim2.new(1, 0, 1, 0)
						txt.BackgroundTransparency = 1
						txt.Font = Enum.Font.GothamBold
						txt.TextSize = espTextSize
						txt.TextColor3 = Color3.fromRGB(255, 255, 255)
						txt.TextStrokeTransparency = 0.2
						txt.TextStrokeColor3 = Color3.fromRGB(155, 89, 182)
						txt.Parent = espGui
					end
					
					espGui.Text.TextSize = espTextSize
					espGui.Text.Text = string.format("%s\n[%d studs]", p.DisplayName, distance)
				end
			end
		end)
	else
		RunService:UnbindFromRenderStep("PlayerESP_GdeJaRbx")
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local gui = p.Character.HumanoidRootPart:FindFirstChild("GdeJaESP")
				if gui then gui:Destroy() end
			end
		end
	end
end)

-- Панель регулировки размера ESP
local sizeFrame = Instance.new("Frame")
sizeFrame.Size = UDim2.new(0, 190, 0, 30)
sizeFrame.BackgroundTransparency = 1
sizeFrame.Parent = scrollFrame

local btnMinus = Instance.new("TextButton")
btnMinus.Size = UDim2.new(0, 30, 0, 30)
btnMinus.Position = UDim2.new(0, 0, 0, 0)
btnMinus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
btnMinus.Text = "-"
btnMinus.TextColor3 = Color3.fromRGB(255,255,255)
btnMinus.Font = Enum.Font.GothamBold
btnMinus.TextSize = 16
Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 6)
btnMinus.Parent = sizeFrame

local lblSize = Instance.new("TextLabel")
lblSize.Size = UDim2.new(0, 120, 0, 30)
lblSize.Position = UDim2.new(0, 35, 0, 0)
lblSize.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
lblSize.Text = "Размер ESP: " .. espTextSize
lblSize.TextColor3 = Color3.fromRGB(255,255,255)
lblSize.Font = Enum.Font.GothamBold
lblSize.TextSize = 12
Instance.new("UICorner", lblSize).CornerRadius = UDim.new(0, 6)
lblSize.Parent = sizeFrame

local btnPlus = Instance.new("TextButton")
btnPlus.Size = UDim2.new(0, 30, 0, 30)
btnPlus.Position = UDim2.new(0, 160, 0, 0)
btnPlus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
btnPlus.Text = "+"
btnPlus.TextColor3 = Color3.fromRGB(255,255,255)
btnPlus.Font = Enum.Font.GothamBold
btnPlus.TextSize = 16
Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 6)
btnPlus.Parent = sizeFrame

btnMinus.MouseButton1Click:Connect(function()
	espTextSize = math.max(8, espTextSize - 2)
	lblSize.Text = "Размер ESP: " .. espTextSize
	updateEspSize()
end)
btnPlus.MouseButton1Click:Connect(function()
	espTextSize = math.min(36, espTextSize + 2)
	lblSize.Text = "Размер ESP: " .. espTextSize
	updateEspSize()
end)

-- 2. OG Lucky Block
local btnOgTp = createButton("ТП к OG Lucky Block", Color3.fromRGB(230, 126, 34))
btnOgTp.MouseButton1Click:Connect(function()
	local pos = findBlock("og lucky") or findBlock("og ")
	if pos then
		btnOgTp.Text = "Телепортирую (3 сек)..."
		spamTeleport(pos)
		task.wait(3)
		btnOgTp.Text = "ТП к OG Lucky Block"
	else
		btnOgTp.Text = "OG не найден!"
		task.wait(1.5)
		btnOgTp.Text = "ТП к OG Lucky Block"
	end
end)

-- 3. Transcendent Lucky Block
local btnTransTp = createButton("ТП к Transcendent", Color3.fromRGB(52, 152, 219))
btnTransTp.MouseButton1Click:Connect(function()
	local pos = findBlock("transcendent")
	if pos then
		btnTransTp.Text = "Телепортирую (3 сек)..."
		spamTeleport(pos)
		task.wait(3)
		btnTransTp.Text = "ТП к Transcendent"
	else
		btnTransTp.Text = "Блок не найден!"
		task.wait(1.5)
		btnTransTp.Text = "ТП к Transcendent"
	end
end)

-- 4. Сохранить телепорт к базе (С Ресетом)
local btnSave = createButton("Сохранить телепорт к базе", Color3.fromRGB(241, 196, 15))
btnSave.MouseButton1Click:Connect(function()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		btnSave.Text = "Ресет и ожидание..."
		player.Character.Humanoid.Health = 0 -- Убиваем персонажа (Ресет)
		
		-- Ждем пока персонаж возродится
		local newChar = player.CharacterAdded:Wait()
		local root = newChar:WaitForChild("HumanoidRootPart", 10)
		
		-- Даем 1 секунду, чтобы персонаж точно прогрузился на спавне/базе
		task.wait(1) 
		
		if root then
			savedCFrame = root.CFrame
			btnSave.Text = "База сохранена!"
		else
			btnSave.Text = "Ошибка сохранения!"
		end
		
		task.wait(2)
		btnSave.Text = "Сохранить телепорт к базе"
	end
end)

-- 5. ТП к базе
local btnLoad = createButton("ТП к базе", Color3.fromRGB(231, 76, 60))
btnLoad.MouseButton1Click:Connect(function()
	if savedCFrame then
		btnLoad.Text = "Возврат (3 сек)..."
		spamTeleport(savedCFrame)
		task.wait(3)
		btnLoad.Text = "ТП к базе"
	else
		btnLoad.Text = "База не задана!"
		task.wait(1.5)
		btnLoad.Text = "ТП к базе"
	end
end)

-- 6. Визуальная смена Skybox (10 Вариантов, исправленные ID)
local skyboxes = {
	{name = "1. Галактика (Galaxy)", id = "rbxassetid://159454299"},
	{name = "2. Неон (Synthwave)", id = "rbxassetid://1417494402"},
	{name = "3. Кровавая луна", id = "rbxassetid://108281045"},
	{name = "4. Фиолетовый космос", id = "rbxassetid://223020661"},
	{name = "5. Звездная ночь", id = "rbxassetid://1013401569"},
	{name = "6. Синий закат", id = "rbxassetid://272186001"},
	{name = "7. Розовый закат", id = "rbxassetid://323493360"},
	{name = "8. Зеленая туманность", id = "rbxassetid://1044732152"},
	{name = "9. Аниме небо (Облака)", id = "rbxassetid://1045964490"},
	{name = "10. Оригинальное небо", id = ""}
}
local skyIndex = 1

local btnSkybox = createButton(skyboxes[skyIndex].name, Color3.fromRGB(44, 62, 80))
btnSkybox.MouseButton1Click:Connect(function()
	skyIndex = skyIndex + 1
	if skyIndex > #skyboxes then skyIndex = 1 end
	
	btnSkybox.Text = skyboxes[skyIndex].name
	
	-- Отключаем туман (Atmosphere), чтобы небо всегда было видно
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("Atmosphere") then
			v.Density = 0
		end
	end
	Lighting.FogEnd = 100000 
	
	local currentSky = Lighting:FindFirstChildOfClass("Sky")
	if not currentSky then
		currentSky = Instance.new("Sky")
		currentSky.Parent = Lighting
	end
	
	local sid = skyboxes[skyIndex].id
	if sid == "" then
		currentSky:Destroy()
	else
		currentSky.SkyboxBk = sid
		currentSky.SkyboxDn = sid
		currentSky.SkyboxFt = sid
		currentSky.SkyboxLf = sid
		currentSky.SkyboxRt = sid
		currentSky.SkyboxUp = sid
	end
end)

print("Hub loaded successfully!")
