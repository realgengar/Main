local FonteCliente = {
    {
        IdsLugares = {4924922222}, --gui
        UrlScript = "https://raw.githubusercontent.com/realgengar/Brookhaven/refs/heads/main/Source.Lua",
        Ativo = true
    },
    {
        IdsLugares = {3101667897}, --veloz
        UrlScript = "https://raw.githubusercontent.com/realgengar/SpeedLegends-/refs/heads/main/Source.lua",
        Ativo = true
    },
    {
        IdsLugares = {10260193230}, --meme
        UrlScript = "https://raw.githubusercontent.com/realgengar/MemeSea/refs/heads/main/Source.lua",
        Ativo = true
    },
    {
        IdsLugares = {13864661000}, --breck
        UrlScript = "https://raw.githubusercontent.com/realgengar/BreakIn2/refs/heads/main/Source.lua",
        Ativo = true
    }
}

local ScriptUniversal = "https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/Games.Lua"

local buscador = {}
local ambiente = (getgenv or getrenv or getfenv)()

do
    local ultimaExecucao = ambiente.debounceExecucaoScript

    if ultimaExecucao and (tick() - ultimaExecucao) <= 3 then
        print("executando constantemente")
        return nil
    end

    ambiente.debounceExecucaoScript = tick()
end

local function CriarMensagemErro(texto)
    ambiente.scriptCarregado = nil
    ambiente.scriptAtivo = false
    local mensagem = Instance.new("Message", workspace)
    mensagem.Text = texto
    ambiente.mensagemErro = mensagem
    game:GetService("Debris"):AddItem(mensagem, 5)
    error(texto, 2)
end

function buscador.pegar(url)
    local sucesso, resposta = pcall(function()
        return game:HttpGet(url)
    end)

    if sucesso then
        return resposta
    else
        CriarMensagemErro("falhou: " .. url .. "\nErro: " .. tostring(resposta))
    end
end

function buscador.carregar(url)
    print("carregando: " .. url)
    local bruto = buscador.pegar(url)
    if not bruto then return end

    local funcaoExecutar, textoErro = loadstring(bruto)

    if type(funcaoExecutar) ~= "function" then
        CriarMensagemErro("erro ao carregar: " .. url .. "\nErro: " .. tostring(textoErro))
    else
        return funcaoExecutar
    end
end

local function LugarValido(script)
    if not script.Ativo then
        return false
    end

    if script.IdsLugares then
        for i, idLugar in pairs(script.IdsLugares) do
            if idLugar == game.PlaceId then
                return true
            end
        end
    end

    return false
end

local function TemScriptEspecifico()
    for i, script in pairs(FonteCliente) do
        if LugarValido(script) then
            return true, script
        end
    end
    return false, nil
end

local function InfoJogo()
    local dados = {
        IdLugar = game.PlaceId,
        IdJogo = game.GameId,
        IdSessao = game.JobId,
        Nome = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Desconhecido"
    }

    return dados
end

local function ExecutarScriptUniversal()
    local dados = InfoJogo()
    print("executando universal: " .. dados.Nome .. " (ID: " .. dados.IdLugar .. ")")
    print("carregando de: " .. ScriptUniversal)

    local funcaoScript = buscador.carregar(ScriptUniversal)
    if funcaoScript then
        local sucesso, resultado = pcall(funcaoScript)
        if sucesso then
            print("executado com sucesso")
            ambiente.scriptCarregado = true
            ambiente.scriptAtivo = true

            local mensagem = Instance.new("Message", workspace)
            mensagem.Text = "Script Universal"
            game:GetService("Debris"):AddItem(mensagem, 3)

            return true
        else
            CriarMensagemErro("erro: " .. tostring(resultado))
        end
    end
    return false
end

local function ExecutarScriptEspecifico(script)
    print("carregando específico")
    print("carregando de: " .. script.UrlScript)

    local funcaoScript = buscador.carregar(script.UrlScript)
    if funcaoScript then
        local sucesso, resultado = pcall(funcaoScript)
        if sucesso then
            print("executado com sucesso")
            ambiente.scriptCarregado = true
            ambiente.scriptAtivo = true
            return true
        else
            CriarMensagemErro("erro: " .. tostring(resultado))
        end
    end
    return false
end

local function CarregarDrip()
    local dados = InfoJogo()
    print("Detectado: " .. dados.Nome .. " (ID: " .. dados.IdLugar .. ")")

    local temEspecifico, scriptEspecifico = TemScriptEspecifico()

    if temEspecifico then
        print("executando específico")
        return ExecutarScriptEspecifico(scriptEspecifico)
    else
        print("executando universal")
        return ExecutarScriptUniversal()
    end
end

local function MostrarJogosSuportados()
    local jogos = {}
    for i, script in pairs(FonteCliente) do
        if script.Ativo then
            for j, idLugar in pairs(script.IdsLugares) do
                local sucesso, info = pcall(function()
                    return game:GetService("MarketplaceService"):GetProductInfo(idLugar).Name
                end)
                if sucesso then
                    table.insert(jogos, info .. " (" .. idLugar .. ")")
                end
            end
        end
    end

    print(table.concat(jogos, "\n"))
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/users.lua"))()

return CarregarDrip()
