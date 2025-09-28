-- LocalScript: JoinPrivateServer.lua
-- Colocar en StarterPlayerScripts (ejecución en cliente)
-- Reemplaza TARGET_PLACE_ID con el placeId numérico si el enlace pertenece a otro Place.

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- Link de server privado (el que me diste)
local shareUrl = "https://www.roblox.com/share?code=211f5472b043d54baefff34b70e54812&type=Server"

-- Si conoces el PlaceId del juego objetivo, ponlo aquí (por ejemplo: 123456789)
-- Si el server privado es del mismo Place donde corre el script, déjalo en nil para usar game.PlaceId
local TARGET_PLACE_ID = nil

-- función para leer parámetros query de la URL
local function getQueryParam(url, key)
	if not url or not key then return nil end
	local pattern = key .. "=([^&]+)"
	return string.match(url, pattern)
end

local code = getQueryParam(shareUrl, "code")
local typ  = getQueryParam(shareUrl, "type")
local placeId = TARGET_PLACE_ID or tonumber(game.PlaceId)

-- Intentar teletransportar al servidor privado
if not code then
	warn("[JoinPrivateServer] No se encontró el parámetro 'code' en la URL. Imposible unirse automáticamente.")
	return
end

if not placeId then
	warn("[JoinPrivateServer] placeId desconocido. Si este link pertenece a otro Place, asigna TARGET_PLACE_ID con el placeId numérico.")
	return
end

-- Intentamos TeleportToPlaceInstance
local ok, err = pcall(function()
	TeleportService:TeleportToPlaceInstance(placeId, code, player)
end)

if ok then
	print("[JoinPrivateServer] Intentando unirse al servidor privado (instanceId = "..tostring(code)..").")
else
	warn("[JoinPrivateServer] Error al intentar TeleportToPlaceInstance: "..tostring(err))
end

-- Opcional: si prefieres que esto se haga con un botón en vez de ejecutarse automáticamente,
-- cambia el comportamiento para crear una GUI y llamar al Teleport desde el MouseButton1Click.
