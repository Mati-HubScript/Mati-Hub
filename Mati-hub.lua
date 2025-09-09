local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

---------------------------------------------------------------------
-- 🔴 Highlight + nombres + tag Owner
---------------------------------------------------------------------
local function addHighlightToCharacter(character, targetPlayer)
	if character:FindFirstChild("Highlight") then return end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = character
	highlight.Parent = character

	local head = character:WaitForChild("Head", 5)
	if head then
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = head
		billboard.Adornee = head
		billboard.Size = UDim2.new(0, 200, 0, 60)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Parent = billboard
		nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
		nameLabel.Position = UDim2.new(0, 0, 0.5, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = targetPlayer.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextScaled = true

		if targetPlayer.Name == "mojica_contreras" then
			local ownerTag = Instance.new("TextLabel")
			ownerTag.Parent = billboard
			ownerTag.Size = UDim2.new(1, 0, 0.5, 0)
			ownerTag.Position = UDim2.new(0, 0, 0, 0)
			ownerTag.BackgroundTransparency = 1
			ownerTag.Text = "👑 Owner 👑"
			ownerTag.TextColor3 = Color3.fromRGB(255, 215, 0)
			ownerTag.TextStrokeTransparency = 0.3
			ownerTag.Font = Enum.Font.SourceSansBold
			ownerTag.TextScaled = true
		end
	end
end

for _, plr in pairs(Players:GetPlayers()) do
	if plr.Character then
		addHighlightToCharacter(plr.Character, plr)
	end
	plr.CharacterAdded:Connect(function(char)
		addHighlightToCharacter(char, plr)
	end)
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		addHighlightToCharacter(char, plr)
	end)
end)

---------------------------------------------------------------------
-- 🌈 UI principal Mati Hub
---------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MatiHubUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 0, 40)
title.Position = UDim2.new(1, -210, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Mati Hub"
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = screenGui

local hue = 0
RunService.RenderStepped:Connect(function()
	hue = (hue + 1) % 360
	title.TextColor3 = Color3.fromHSV(hue/360, 1, 1)
end)

---------------------------------------------------------------------
-- 🔘 Botón Part
---------------------------------------------------------------------
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 40)
button.Position = UDim2.new(1, -160, 0, 60)
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.Text = "Part OFF"
button.TextScaled = true
button.Font = Enum.Font.SourceSansBold
button.TextColor3 = Color3.new(1,1,1)
button.Parent = screenGui

---------------------------------------------------------------------
-- 🟦 Plataforma que sube y sigue al jugador
---------------------------------------------------------------------
local active = false
local part = nil
local connection = nil
local height = 0

button.MouseButton1Click:Connect(function()
	active = not active
	if active then
		button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		button.Text = "Part ON"

		part = Instance.new("Part")
		part.Size = Vector3.new(6, 0.5, 6)
		part.Anchored = false
		part.Color = Color3.fromRGB(200, 0, 0)
		part.Material = Enum.Material.Neon
		part.CanCollide = true
		part.Position = humanoidRootPart.Position - Vector3.new(0, 3, 0)
		part.Parent = workspace

		local bodyPos = Instance.new("BodyPosition")
		bodyPos.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bodyPos.P = 8000
		bodyPos.Parent = part

		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		bodyGyro.CFrame = CFrame.new()
		bodyGyro.P = 5000
		bodyGyro.Parent = part

		height = humanoidRootPart.Position.Y - 3

		connection = RunService.RenderStepped:Connect(function()
			if part and humanoidRootPart then
				height += 0.05
				local pos = humanoidRootPart.Position
				bodyPos.Position = Vector3.new(pos.X, height, pos.Z)
				bodyGyro.CFrame = CFrame.new()
			end
		end)
	else
		button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		button.Text = "Part OFF"
		if connection then connection:Disconnect() connection = nil end
		if part then part:Destroy() part = nil end
	end
end)

---------------------------------------------------------------------
-- 🏃 Speed Boost con TextBox
---------------------------------------------------------------------
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 120, 0, 40)
speedBox.Position = UDim2.new(1, -160, 0, 110)
speedBox.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
speedBox.Text = "Speed (max 45)"
speedBox.TextScaled = true
speedBox.Font = Enum.Font.SourceSansBold
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.ClearTextOnFocus = true
speedBox.Parent = screenGui

speedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local value = tonumber(speedBox.Text)
		if value then
			if value > 45 then value = 45 end
			if value < 1 then value = 1 end
			humanoid.WalkSpeed = value
		else
			speedBox.Text = "Invalid"
		end
	end
end)

---------------------------------------------------------------------
-- 🟢 Inf Jump Toggle
---------------------------------------------------------------------
local infJumpActive = false

local infJumpBtn = Instance.new("TextButton")
infJumpBtn.Size = UDim2.new(0, 120, 0, 40)
infJumpBtn.Position = UDim2.new(1, -160, 0, 160)
infJumpBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
infJumpBtn.Text = "Inf Jump OFF"
infJumpBtn.TextScaled = true
infJumpBtn.Font = Enum.Font.SourceSansBold
infJumpBtn.TextColor3 = Color3.new(1,1,1)
infJumpBtn.Parent = screenGui

infJumpBtn.MouseButton1Click:Connect(function()
	infJumpActive = not infJumpActive
	if infJumpActive then
		infJumpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		infJumpBtn.Text = "Inf Jump ON"
	else
		infJumpBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		infJumpBtn.Text = "Inf Jump OFF"
	end
end)

UserInputService.JumpRequest:Connect(function()
	if infJumpActive then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

---------------------------------------------------------------------
-- ❌ Botón para ocultar/mostrar UIs secundarias
---------------------------------------------------------------------
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 150, 0, 40)
closeBtn.Position = UDim2.new(0.5, -75, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "Ocultar UIs"
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = screenGui

local uisVisible = true
closeBtn.MouseButton1Click:Connect(function()
	uisVisible = not uisVisible

	button.Visible = uisVisible       -- Part
	speedBox.Visible = uisVisible     -- Speed Boost
	infJumpBtn.Visible = uisVisible   -- Inf Jump

	if uisVisible then
		closeBtn.Text = "Ocultar UIs"
	else
		closeBtn.Text = "Mostrar UIs"
	end
end)
