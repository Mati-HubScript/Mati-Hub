-- LocalScript: PrivateServerButton.lua
-- Colocar en StarterPlayerScripts

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- URL de share
local shareUrl = "https://www.roblox.com/share?code=7d382796ac8ff64790ddc4fbe898e76d&type=Server"

-- Si conoces el PlaceId del juego, puedes ponerlo aquí
-- Si es el mismo juego actual, se usa game.PlaceId
local TARGET_PLACE_ID = nil 

-- ----- Parsear parámetros de la URL -----
local function getQueryParam(url, key)
	if not url or not key then return nil end
	local pattern = key .. "=([^&]+)"
	local found = string.match(url, pattern)
	return found
end

local code = getQueryParam(shareUrl, "code")
local placeId = TARGET_PLACE_ID or tonumber(game.PlaceId)

-- ----- Crear UI -----
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PrivateServerGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(1, -210, 0, 10) -- esquina superior derecha
button.AnchorPoint = Vector2.new(0, 0) -- anclaje arriba a la derecha
button.Text = "Private Server Free"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.Parent = screenGui
button.AutoButtonColor = true
button.BackgroundTransparency = 0.1
button.BorderSizePixel = 0

-- Efecto hover
button.MouseEnter:Connect(function()
	button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
end)
button.MouseLeave:Connect(function()
	button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end)

-- ----- Acción del botón -----
button.MouseButton1Click:Connect(function()
	if not code then
		warn("No se encontró el parámetro 'code' en la URL.")
		return
	end

	local success, err = pcall(function()
		TeleportService:TeleportToPlaceInstance(placeId, code, player)
	end)

	if not success then
		warn("Error al intentar unirse: " .. tostring(err))
	end
end)
