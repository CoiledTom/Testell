--[[
╔═══════════════════════════════════════════════════════╗
║          Farm EB do Delta  |  WindUI v2               ║
║              by CoiledTom                             ║
╚═══════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════
--  LOAD WindUI v2
-- ═══════════════════════════════════
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- ═══════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer  = Players.LocalPlayer
local Character    = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP          = Character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════
local Window = WindUI:CreateWindow({
    Title       = "Farm EB do Delta",
    Icon        = "solar:planet-bold",
    Author      = "by CoiledTom",
    Folder      = "CoiledTomHub",
    Size        = UDim2.fromOffset(600, 500),
    Theme       = "Dark",
    Transparent = true,
})

-- ═══════════════════════════════════
--  TABS
-- ═══════════════════════════════════
local TabFarm     = Window:Tab({ Title = "Farm",    Icon = "solar:hammer-bold"        })
local TabConfigs  = Window:Tab({ Title = "Configs", Icon = "solar:settings-bold"      })

-- ═══════════════════════════════════
--  ESTADO
-- ═══════════════════════════════════
local farmAtivo        = false
local trabalhoIniciado = false
local farmThread       = nil

-- ═══════════════════════════════════
--  COORDENADAS
-- ═══════════════════════════════════
local COORD_PEGAR_TRABALHO = Vector3.new(-1444, 13,  -63)
local COORD_ENTREGA        = Vector3.new(-1417, 11,  -87)

local COORDS_CONSTRUCAO = {
    Vector3.new(-1398,  8,  -98),
    Vector3.new(-1375,  7,  -95),
    Vector3.new(-1353,  4, -131),
    Vector3.new(-1414,  5, -132),
    Vector3.new(-1453,  4, -141),
    Vector3.new(-1329,  6, -109),
    Vector3.new(-1354,  5,  -56),
    Vector3.new(-1339,  4,  -39),
    Vector3.new(-1310,  5,  -50),
    Vector3.new(-1284,  5,  -35),
    Vector3.new(-1265,  5,  -78),
    Vector3.new(-1239,  6, -104),
    Vector3.new(-1295,  5, -112),
}

-- ═══════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════
local function getChar()
    return LocalPlayer.Character
end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
end)

-- Move via TweenService — velocidade baseada em studs/s (250)
local SPEED = 250  -- studs por segundo

local function mover(posicao)
    local root = getRoot()
    if not root then return end

    local distancia = (root.Position - posicao).Magnitude
    local duracao   = math.max(distancia / SPEED, 0.05)

    local tween = TweenService:Create(
        root,
        TweenInfo.new(duracao, Enum.EasingStyle.Linear),
        { CFrame = CFrame.new(posicao) }
    )
    tween:Play()
    tween.Completed:Wait()
    task.wait(0.15)
end

-- Simula pressionar E
local function pressionarE()
    VirtualInput:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    task.wait(0.35)
end

-- Clica botão da UI do jogo pelo nome
local function clicarBotaoUI(nomeBotao)
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return false end
    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Name == nomeBotao then
            gui.MouseButton1Click:Fire()
            task.wait(0.1)
            return true
        end
    end
    return false
end

-- ═══════════════════════════════════
--  PEGAR TRABALHO (apenas 1x)
-- ═══════════════════════════════════
local function pegarTrabalho()
    mover(COORD_PEGAR_TRABALHO)
    task.wait(0.5)

    pressionarE()
    task.wait(0.8)

    clicarBotaoUI("LeftOption")
    task.wait(1)
    clicarBotaoUI("LeftOption")
    task.wait(0.5)

    trabalhoIniciado = true
end

-- ═══════════════════════════════════
--  LOOP DE FARM
-- ═══════════════════════════════════
local function loopFarm()
    if not trabalhoIniciado then
        pegarTrabalho()
    end

    local indice = 1

    while farmAtivo do
        if not getRoot() then
            task.wait(1)
            continue
        end

        -- 1. Ir até ponto de construção
        mover(COORDS_CONSTRUCAO[indice])

        -- 2. Interagir
        pressionarE()

        -- 3. Ir até entrega
        mover(COORD_ENTREGA)

        -- 4. Entregar
        pressionarE()

        -- 5. Próxima coordenada (loop circular)
        indice = indice % #COORDS_CONSTRUCAO + 1
    end
end

-- ══════════════════════════════════════════════════════
--  ABA: FARM
-- ══════════════════════════════════════════════════════
do
    TabFarm:Section({ Title = "🏗️ Construção" })

    TabFarm:Toggle({
        Title    = "Farm construção",
        Desc     = "leval +0",
        Icon     = "solar:hammer-bold",
        Value    = false,
        Callback = function(v)
            farmAtivo = v
            if v then
                farmThread = task.spawn(loopFarm)
            else
                if farmThread then
                    task.cancel(farmThread)
                    farmThread = nil
                end
            end
        end,
    })
end

-- ══════════════════════════════════════════════════════
--  ABA: CONFIGS
-- ══════════════════════════════════════════════════════
do
    TabConfigs:Section({ Title = "⚙️ Sistema" })

    TabConfigs:Button({
        Title    = "Resetar Trabalho",
        Desc     = "Força buscar o trabalho na próxima ativação",
        Icon     = "solar:refresh-bold",
        Callback = function()
            trabalhoIniciado = false
            WindUI:Notify({
                Title    = "Farm EB",
                Content  = "Trabalho resetado com sucesso.",
                Duration = 3,
            })
        end,
    })

    TabConfigs:Section({ Title = "ℹ️ Info" })

    TabConfigs:Section({ Title = "Farm EB do Delta  |  by CoiledTom\nRightShift para ocultar/mostrar a UI." })
end

-- ══════════════════════════════════════════════════════
--  NOTIFICAÇÃO INICIAL
-- ══════════════════════════════════════════════════════
WindUI:Notify({
    Title    = "Farm EB do Delta",
    Content  = "Carregado! by CoiledTom",
    Duration = 5,
})
