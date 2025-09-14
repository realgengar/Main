local ScriptDatabase = {
    {
        PlaceIds = {4924922222}, -- Brookhaven
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/Brookhaven/refs/heads/main/Source.Lua",
        GameName = "Brookhaven RP",
        Enabled = true
    },
    {
        PlaceIds = {3101667897}, -- Speed Legends
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/SpeedLegends-/refs/heads/main/Source.lua",
        GameName = "Speed Legends",
        Enabled = true
    },
    {
        PlaceIds = {10260193230}, -- Meme Sea
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/MemeSea/refs/heads/main/Source.lua",
        GameName = "Meme Sea",
        Enabled = true
    },
    {
        PlaceIds = {13864661000}, -- Break In 2
        ScriptUrl = "https://raw.githubusercontent.com/realgengar/BreakIn2/refs/heads/main/Source.lua",
        GameName = "Break In 2",
        Enabled = true
    }
}

local UniversalScriptUrl = "https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/Games.Lua"

-- Sistema de cache e debounce
local Environment = getgenv and getgenv() or _G
local DEBOUNCE_TIME = 3

-- Verificação de debounce
local function checkDebounce()
    local lastExec = Environment.script_execute_debounce
    if lastExec and (tick() - lastExec) <= DEBOUNCE_TIME then
        warn("Script executado recentemente. Aguarde " .. DEBOUNCE_TIME .. " segundos.")
        return false
    end
    Environment.script_execute_debounce = tick()
    return true
end

-- Sistema de notificações
local function createNotification(text, duration, isError)
    local message = Instance.new("Message")
    message.Text = text
    message.Parent = workspace
    
    if isError then
        warn("ERRO: " .. text)
    else
        print("INFO: " .. text)
    end
    
    game:GetService("Debris"):AddItem(message, duration or 3)
    return message
end

-- Fetcher melhorado com retry
local HttpService = game:GetService("HttpService")
local function fetchScript(url, maxRetries)
    maxRetries = maxRetries or 3
    
    for attempt = 1, maxRetries do
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success and response and #response > 0 then
            return response
        else
            warn("Tentativa " .. attempt .. " falhou para: " .. url)
            if attempt < maxRetries then
                wait(1) -- Aguarda antes de tentar novamente
            end
        end
    end
    
    createNotification("Falha ao baixar script: " .. url, 5, true)
    return nil
end

-- Carregador de script com validação
local function loadScript(url)
    print("Carregando script de: " .. url)
    
    local scriptContent = fetchScript(url)
    if not scriptContent then
        return nil
    end
    
    local scriptFunction, errorMessage = loadstring(scriptContent)
    if not scriptFunction then
        createNotification("Erro ao compilar script: " .. tostring(errorMessage), 5, true)
        return nil
    end
    
    return scriptFunction
end

-- Executor de script com tratamento de erro
local function executeScript(scriptFunction, scriptName)
    local success, result = pcall(scriptFunction)
    
    if success then
        createNotification("Script " .. scriptName .. " carregado com sucesso!", 3)
        Environment.loadedScript = true
        Environment.OnScript = true
        return true
    else
        createNotification("Erro ao executar " .. scriptName .. ": " .. tostring(result), 5, true)
        return false
    end
end

-- Verificar se o jogo atual tem script específico
local function findSpecificScript()
    local currentPlaceId = game.PlaceId
    
    for i, scriptData in pairs(ScriptDatabase) do
        if scriptData.Enabled then
            for j, placeId in pairs(scriptData.PlaceIds) do
                if placeId == currentPlaceId then
                    return scriptData
                end
            end
        end
    end
    
    return nil
end

-- Obter informações do jogo atual
local function getGameInfo()
    local MarketplaceService = game:GetService("MarketplaceService")
    local gameName = "Jogo Desconhecido"
    
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    
    if success and info then
        gameName = info.Name
    end
    
    return {
        PlaceId = game.PlaceId,
        GameId = game.GameId,
        JobId = game.JobId,
        Name = gameName
    }
end

-- Executar script específico do jogo
local function executeSpecificScript(scriptData)
    print("Executando script específico para: " .. (scriptData.GameName or "Jogo"))
    
    local scriptFunction = loadScript(scriptData.ScriptUrl)
    if scriptFunction then
        return executeScript(scriptFunction, scriptData.GameName or "Específico")
    end
    
    return false
end

-- Executar script universal
local function executeUniversalScript()
    local gameInfo = getGameInfo()
    print("Executando script universal para: " .. gameInfo.Name)
    
    local scriptFunction = loadScript(UniversalScriptUrl)
    if scriptFunction then
        return executeScript(scriptFunction, "Universal")
    end
    
    return false
end

-- Mostrar jogos suportados
local function showSupportedGames()
    print("=== JOGOS SUPORTADOS ===")
    local MarketplaceService = game:GetService("MarketplaceService")
    
    for i, scriptData in pairs(ScriptDatabase) do
        if scriptData.Enabled then
            for j, placeId in pairs(scriptData.PlaceIds) do
                local success, info = pcall(function()
                    return MarketplaceService:GetProductInfo(placeId)
                end)
                
                local gameName = success and info.Name or "Nome não encontrado"
                print("- " .. gameName .. " (ID: " .. placeId .. ")")
            end
        end
    end
    print("========================")
end

-- Função principal
local function initializeScriptLoader()
    -- Verificar debounce
    if not checkDebounce() then
        return false
    end
    
    -- Limpar estados anteriores
    Environment.loadedScript = nil
    Environment.OnScript = false
    
    -- Obter info do jogo atual
    local gameInfo = getGameInfo()
    print("Detectado: " .. gameInfo.Name .. " (ID: " .. gameInfo.PlaceId .. ")")
    
    -- Verificar se existe script específico
    local specificScript = findSpecificScript()
    
    if specificScript then
        print("Script específico encontrado!")
        return executeSpecificScript(specificScript)
    else
        print("Nenhum script específico encontrado. Usando universal.")
        return executeUniversalScript()
    end
end

-- Executar validação de usuário (se necessário)
local function loadUserValidation()
    spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/users.lua"))()
        end)
    end)
end

--[[ Sistema de auto-execução em teleporte (opcional)
local function setupAutoTeleport()
    local queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport)
    
    if queueteleport and not Environment.added_teleport_queue then
        Environment.added_teleport_queue = true
        
        local reloadScript = [[
            wait(2)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/loader.lua"))()
        
        
        pcall(queueteleport, reloadScript)
        print("Auto-reload configurado para teleportes!")
    end
end]]

showSupportedGames()
loadUserValidation()
--setupAutoTeleport()
return initializeScriptLoader()
