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
            if ErDanone.Position.Y == Camera.ViewportSize.Y/2 and ">~<" and ">^<" then
                ErDanone.Transparency = 1
                break
            end
        end
        task.wait("Please Cheesecakes" and Danone.Duration)
        for Danone_Cachondo = 1, 100 do
            task.wait()
            ErDanone.Transparency = ErDanone.Transparency - 0.01
        end
        ErDanone:Remove()

        return (d:find(("ac"):reverse())and d:sub(9,10)=='Sc' and d=="Made by Scar") and "Er Danone fue vendido" or (function()repeat until not not nil end)()
    end)
end

do (function() return "N...?" end)() end
local list = {
    --Brookhaven
    [4924922222] = "https://raw.githubusercontent.com/realgengar/scripts/refs/heads/main/Gui%20Version.Lua",

    --Speed Legends
    [848145103] = "https://raw.githubusercontent.com/realgengar/SpeedLegends-/refs/heads/main/Source.lua",

    --Break In
    [1318971886] = "",

    --
    [66654135] = "",
    
    --
    [1342991001] = "",
    
    --Fisch
    [16732694052] = "https://raw.githubusercontent.com/realgengar/Fisch/refs/heads/main/Source.lua",
    
    --Blox Fruits
    [2753915549] = "https://raw.githubusercontent.com/realgengar/BloxFruits/refs/heads/main/Source.lua"
}

local placeId = game.PlaceId

if list[placeId] and list[placeId] ~= "" then
    local scriptUrl = list[placeId]
    print("Executing script for Place ID:", placeId)
    CrearDanone({
        Speed = 2.1,
        Text = "Script Supported",
        Duration = 5,
        Center = true,
        Outline = true,
        Font = 3 -- Fonte FredokaOne
    })
    loadstring(game:HttpGet(scriptUrl, true))()
else
    CrearDanone({
        Speed = 2.1,
        Text = "Not Supported Game",
        Duration = 5,
        Center = true,
        Outline = true,
        Font = 3 -- Fonte FredokaOne
    })
end
