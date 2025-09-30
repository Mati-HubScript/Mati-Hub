-- MatiAimlock.lua
-- LocalScript
-- Aimlock con UI personalizada

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

-- CONFIG
local MAX_DISTANCE = 150
local AIM_CONE_DEG = 40
local SMOOTH_SPEED = 15

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MatiAimlockGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,140,0,40)
toggleBtn.Position = UDim2.new(1,-160,0,12)
toggleBtn.AnchorPoint = Vector2.new(1,0)
toggleBtn.Text = "Mati Aimlock: OFF (P)"
toggleBtn.BackgroundTransparency = 0.15
toggleBtn.BorderSizePixel = 0
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.Parent = screenGui

-- Estado
local enabled = false
local currentTarget = nil

-- Buscar objetivo
local function findAimTarget()
    local camCFrame = camera.CFrame
    local origin = camCFrame.Position
    local lookVec = camCFrame.LookVector

    local best, bestScore = nil, -math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local hrp = p.Character.HumanoidRootPart
                local toTarget = hrp.Position - origin
                local dist = toTarget.Magnitude
                if dist <= MAX_DISTANCE then
                    local dir = toTarget.Unit
                    local dot = lookVec:Dot(dir)
                    local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
                    if angle <= AIM_CONE_DEG then
                        local score = (1 - angle / AIM_CONE_DEG) * 0.7 + (1 - dist / MAX_DISTANCE) * 0.3
                        if score > bestScore then
                            bestScore = score
                            best = hrp
                        end
                    end
                end
            end
        end
    end
    return best
end

-- Seguir objetivo
local function aimAt(target, dt)
    if not target then return end
    local camPos = camera.CFrame.Position
    local head = target.Parent:FindFirstChild("Head")
    local targetPos = head and head.Position or target.Position
    local desired = CFrame.new(camPos, targetPos)
    camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(SMOOTH_SPEED * dt, 0, 1))
end

-- Toggle
local function setEnabled(val)
    enabled = val
    toggleBtn.Text = enabled and "Mati Aimlock: ON (P)" or "Mati Aimlock: OFF (P)"
end

toggleBtn.MouseButton1Click:Connect(function()
    setEnabled(not enabled)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.P then
        setEnabled(not enabled)
    end
end)

-- Loop
local last = tick()
RunService.RenderStepped:Connect(function()
    local now = tick()
    local dt = now - last
    last = now

    if enabled then
        if not currentTarget or not currentTarget.Parent then
            currentTarget = findAimTarget()
        end
        if currentTarget then
            aimAt(currentTarget, dt)
        end
    end
end)
