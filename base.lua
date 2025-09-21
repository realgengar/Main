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


 loadstring(game:HttpGet("https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/users.lua"))()
StarterGui:SetCore("SendNotification", {
        Title = "Aviso [ ⚠️ ]",
        Text = "Antes de uso o script leia o aviso, evite golpes fora de nosso discord ofc",
        Duration = 10
    })
return LoadDrip()
