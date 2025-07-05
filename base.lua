getgenv().d = "Made by Scar"
local d = getgenv().d
if not d:lower():find(("racs"):reverse()) then
    do return end
end

local Danones = setmetatable({}, {
    __index = function(Tipo, Sabor)
        return d:lower():find(("racs"):reverse()) and game:GetService(Sabor) or (function()repeat until not not nil end)()
    end
})

local Empresa = Danones.Workspace
local Camera = Workspace.CurrentCamera

function CrearDanone(Options)
    task.spawn(function()
        Options = Options or {}
        if d:lower() ~= "made by scar" then return "you made me mad so code wont load ^u^" end

        local Danone = {
            Text = Options.Text or "Danones patrocina este espacio",
            Color = Options.Color or Color3.fromRGB(111, 0, 255),
            Duration = Options.Duration or 3,
            Center = Options.Center or true,
            Outline = Options.Outline or true,
            Speed = (Options.Speed or 0.5) + 2,
            Font = Options.Font or 3 -- 3 corresponde a FredokaOne
        }

        local ErDanone = Drawing.new("Text")
        ErDanone.Visible = true 
        ErDanone.Font = Danone.Font
        ErDanone.Center = Danone.Center
        ErDanone.Size = 20
        ErDanone.Outline = Danone.Outline 
        ErDanone.Transparency = 1
        ErDanone.Color = Danone.Color
        ErDanone.Text = Danone.Text
        ErDanone.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

        for Danone_Number = 0, 10, Danone.Speed do
            task.wait()
            ErDanone.Position = Vector2.new(ErDanone.Position.X, math.clamp(ErDanone.Position.Y - ((Danone.Speed * 10) * Danone_Number), Camera.ViewportSize.Y/2, math.huge))
            ErDanone.Transparency = (Danone_Number - Danone.Speed) /10
            if ErDanone.Position.Y == Camera.ViewportSize.Y/2 then
                ErDanone.Transparency = 1
                break
            end
        end
        
        task.wait(Danone.Duration)
        for Danone_Cachondo = 1, 100 do
            task.wait()
            ErDanone.Transparency = ErDanone.Transparency - 0.01
        end
        ErDanone:Remove()

        return (d:find(("ac"):reverse())and d:sub(9,10)=='Sc' and d=="Made by Scar") and "Er Danone fue vendido" or nil
    end)
end

local list = {
    [4924922222] = "https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/Gui%20Version.Lua", -- Brookhaven
    [3101667897] = "https://raw.githubusercontent.com/realgengar/SpeedLegends-/refs/heads/main/Source.lua", -- Speed Legends
    [13864661000] = "https://raw.githubusercontent.com/realgengar/BreakIn2/refs/heads/main/Source.lua", -- break
    [3756501373] = "https://raw.githubusercontent.com/realgengar/MemeSea/refs/heads/main/Source.lua" -- Blox Fruits
}

local placeId = game.PlaceId
local scriptFound = false

for id, scriptUrl in pairs(list) do
    if placeId == id then
        scriptFound = true
        if scriptUrl ~= "" then
            CrearDanone({
                Text = "Script Carregado!",
                Color = Color3.fromRGB(0, 255, 0),
                Duration = 3
            })
            
            local success, err = pcall(function()
                loadstring(game:HttpGet(scriptUrl, true))()
            end)
            
            if not success then
                CrearDanone({
                    Text = "Erro ao carregar!",
                    Color = Color3.fromRGB(255, 0, 0),
                    Duration = 5
                })
                warn("Erro:", err)
            end
        else
            CrearDanone({
                Text = "Em breve!",
                Color = Color3.fromRGB(255, 165, 0),
                Duration = 5
            })
        end
        break
    end
end

if not scriptFound then
    CrearDanone({
        Text = "Atualizando ou Não Existe",
        Color = Color3.fromRGB(255, 0, 0),
        Duration = 5
    })
end
