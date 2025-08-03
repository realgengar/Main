--[[do
local screenGui = Instance.new("ScreenGui")
local textLabel = Instance.new("TextLabel")

screenGui.Name = "UpdateNotification"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

textLabel.Name = "UpdateLabel"
textLabel.Parent = screenGui
textLabel.BackgroundTransparency = 1
textLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
textLabel.Size = UDim2.new(0, 300, 0, 50)
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.Font = Enum.Font.SourceSansBold
textLabel.Text = "Script Atualizado | Funcionando"
textLabel.TextColor3 = Color3.fromRGB(128, 0, 128)
textLabel.TextScaled = true
textLabel.TextStrokeTransparency = 0
textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

task.spawn(function()
    for i = 1, 5 do
        textLabel.Visible = false
        task.wait(0.3)
        textLabel.Visible = true
        task.wait(0.3)
    end
    
    task.wait(0.5)
    screenGui:Destroy()
end)
end]]

-- Client Games
local ClientSource = {
	{
		PlacesIds = {4924922222}, 
		ScriptUrl = "https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/Gui%20Version.Lua", true,
		Enabled = true
	},
	{
		PlacesIds = {3101667897},
		ScriptUrl = "https://raw.githubusercontent.com/realgengar/SpeedLegends-/refs/heads/main/Source.lua", true,
		Enabled = true
	}
}

local fetcher = {}
local _ENV = (getgenv or getrenv or getfenv)()

do
	local last_exec = _ENV.script_execute_debounce
	
	if last_exec and (os.clock() - last_exec) <= 3 then
		print("Script executado recentemente. Aguarde...")
		return nil
	end
	
	_ENV.script_execute_debounce = os.clock()
end

local function CreateErrorMessage(Text)
	_ENV.loadedScript = nil
	_ENV.OnScript = false
	local Message = Instance.new("Message", workspace)
	Message.Text = Text
	_ENV.error_message = Message
	game:GetService("Debris"):AddItem(Message, 5)
	error(Text, 2)
end

function fetcher.get(Url)
	local success, response = pcall(function()
		return game:HttpGet(Url)
	end)
	
	if success then
		return response
	else
		CreateErrorMessage("parou miséria: " .. Url .. "\nErro: " .. tostring(response))
	end
end

-- Função para carregar e executar script
function fetcher.load(Url)
	print("carrega logo: " .. Url)
	
	local raw = fetcher.get(Url)
	if not raw then return end
	
	local runFunction, errorText = loadstring(raw)
	
	if type(runFunction) ~= "function" then
		CreateErrorMessage("outro erro aaaa: " .. Url .. "\nErro: " .. tostring(errorText))
	else
		return runFunction
	end
end

local function IsValidPlace(Script)
	if not Script.Enabled then
		return false
	end
	
	if Script.PlacesIds then
		for _, placeId in ipairs(Script.PlacesIds) do
			if placeId == game.PlaceId then
				return true
			end
		end
	end
	
	return false
end

local function GetGameInfo()
	local gameInfo = {
		PlaceId = game.PlaceId,
		GameId = game.GameId,
		JobId = game.JobId,
		Name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Desconhecido"
	}
	
	return gameInfo
end

local function CarrgarDripp()
	local gameInfo = GetGameInfo()
	print("Achouuu: " .. gameInfo.Name .. " (ID: " .. gameInfo.PlaceId .. ")")
	
	for _, Script in ipairs(ClientSource) do
		if IsValidPlace(Script) then
			print("caregando nossa senhora")
			print("aqui carregadu: " .. Script.ScriptUrl)
			
			local scriptFunction = fetcher.load(Script.ScriptUrl)
			if scriptFunction then
				local success, result = pcall(scriptFunction)
				if success then
					print("deu bom")
					_ENV.loadedScript = true
					_ENV.OnScript = true
					return true
				else
					CreateErrorMessage("deu erro dnv: " .. tostring(result))
				end
			end
			return false
		end
	end
	
	local supportedGames = {}
	for _, Script in ipairs(ClientSource) do
		if Script.Enabled then
			for _, placeId in ipairs(Script.PlacesIds) do
				local success, info = pcall(function()
					return game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
				end)
				if success then
					table.insert(supportedGames, info .. " (" .. placeId .. ")")
				end
			end
		end
	end
	
	local message = "não executa que nn te script: " .. gameInfo.Name .. " (" .. gameInfo.PlaceId .. ")\n\n"
	message = message .. "Jogos Que funciona:\n" .. table.concat(supportedGames, "\n")
	
	print(message)
	
	local Message = Instance.new("Message", workspace)
	Message.Text = ""
	game:GetService("Debris"):AddItem(Message, 8)
	
	return false
end

--[[
do
	local executor = syn or fluxus
	local queueteleport = queue_on_teleport or (executor and executor.queue_on_teleport)
	
	if not _ENV.added_teleport_queue and type(queueteleport) == "function" then
		_ENV.added_teleport_queue = true
		
		local scriptCode = string.format("loadstring(game:HttpGet('%s'))()", "https://raw.githubusercontent.com/SeuUsuario/SeuRepositorio/main/script-loader.lua")
		pcall(queueteleport, scriptCode)
		print("miséria caregadaaaa!")
	end
end
--]]

-- chama que nem a minha mãe 
return CarrgarDripp()
