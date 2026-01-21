--==============================
-- SERVICIOS
--==============================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--==============================
-- CONFIGURACIÓN
--==============================
local TWEEN_TIME = 2
local RESTART_WAIT = 10

local points = {
	{Vector3.new(4.3, 14.7, -85.3), 3},
	{Vector3.new(-46.1, 69.8, 8640.1), 3},
	{Vector3.new(-47.9, -359.8, 9403.1), 3},
	{Vector3.new(-55.0, -356.0, 9490.4), 10},
}

--==============================
-- UI
--==============================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmWinsUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 160)
frame.Position = UDim2.new(0.5, -140, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.Active = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 18)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "🏆 Auto Farm Mati 💥"
title.Font = Enum.Font.Cartoon
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.85, 0, 0, 50)
button.Position = UDim2.new(0.075, 0, 0.55, 0)
button.BackgroundColor3 = Color3.fromRGB(40,40,40)
button.Text = "ACTIVAR"
button.Font = Enum.Font.Cartoon
button.TextSize = 20
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Parent = frame

local buttonCorner = Instance.new("UICorner", button)
buttonCorner.CornerRadius = UDim.new(0, 16)

--==============================
-- DRAG (PC + MÓVIL)
--==============================
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

--==============================
-- FLOTAR
--==============================
local active = false
local floatForce, gyro

local function enableFloat(hrp)
	floatForce = Instance.new("BodyVelocity")
	floatForce.Velocity = Vector3.zero
	floatForce.MaxForce = Vector3.new(0, math.huge, 0)
	floatForce.Parent = hrp

	gyro = Instance.new("BodyGyro")
	gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	gyro.CFrame = hrp.CFrame
	gyro.Parent = hrp
end

local function disableFloat()
	if floatForce then floatForce:Destroy() end
	if gyro then gyro:Destroy() end
end

--==============================
-- MOVIMIENTO
--==============================
local function tweenTo(hrp, position)
	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(position)}
	)
	tween:Play()
	tween.Completed:Wait()
end

--==============================
-- CICLO PRINCIPAL
--==============================
local function startFarm()
	while active do
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")

		enableFloat(hrp)

		for _, data in ipairs(points) do
			if not active then break end
			tweenTo(hrp, data[1])
			task.wait(data[2])
		end

		task.wait(RESTART_WAIT)
	end
end

--==============================
-- BOTÓN
--==============================
button.MouseButton1Click:Connect(function()
	active = not active

	if active then
		button.Text = "DESACTIVAR"
		button.BackgroundColor3 = Color3.fromRGB(70,120,70)
		task.spawn(startFarm)
	else
		button.Text = "ACTIVAR"
		button.BackgroundColor3 = Color3.fromRGB(40,40,40)
		disableFloat()
	end
end)
