-- ============================================================
--   Farm EB do Delta  |  by CoiledTom
--   UI: WindUI v2
-- ============================================================

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ============================================================
--   SERVIÇOS
-- ============================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local VirtualInput     = game:GetService("VirtualInputManager")

local LocalPlayer      = Players.LocalPlayer
local Character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP              = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
--   CONFIGURAÇÃO DA UI
-- ============================================================

WindUI.TransparencyValue = 0.5  -- transparência (0 = opaco | 1 = invisível)

local Window = WindUI:CreateWindow({
    Title        = "Farm EB do Delta",
    Icon         = "pickaxe",
    Author       = "by CoiledTom",
    Keybind      = Enum.KeyCode.RightControl,
    SaveConfig   = true,
    ConfigFolder = "CoiledTomHub",
    DisableBar   = true,   -- remove a barra de minimizar
})

local Tabs = {
    Farm    = Window:Tab({ Title = "Farm",    Icon = "hammer" }),
    Configs = Window:Tab({ Title = "Configs", Icon = "settings" }),
}

-- ============================================================
--   VARIÁVEIS DE CONTROLE
-- ============================================================

local farmAtivo        = false
local trabalhoIniciado = false
local farmThread       = nil

-- ============================================================
--   COORDENADAS
-- ============================================================

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

-- ============================================================
--   FUNÇÕES UTILITÁRIAS
-- ============================================================

-- Atualiza referências ao personagem (seguro contra morte)
local function atualizarPersonagem()
    Character = LocalPlayer.Character
    if Character then
        HRP = Character:FindFirstChild("HumanoidRootPart")
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
end)

-- Move o personagem via TweenService até a posição desejada
local function mover(posicao, velocidade)
    atualizarPersonagem()
    if not Character or not HRP then return end

    velocidade = velocidade or 0.6  -- duração em segundos (ajuste conforme necessário)

    local tween = TweenService:Create(
        HRP,
        TweenInfo.new(velocidade, Enum.EasingStyle.Linear),
        { CFrame = CFrame.new(posicao) }
    )

    tween:Play()
    tween.Completed:Wait()
    task.wait(0.2)
end

-- Simula pressionar a tecla E
local function pressionarE()
    VirtualInput:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    task.wait(0.4)
end

-- Clica em botão da UI do jogo pelo nome
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

-- ============================================================
--   LÓGICA: PEGAR TRABALHO (apenas uma vez)
-- ============================================================

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

-- ============================================================
--   LÓGICA: LOOP DE FARM
-- ============================================================

local function loopFarm()
    if not trabalhoIniciado then
        pegarTrabalho()
    end

    local indice = 1

    while farmAtivo do
        atualizarPersonagem()
        if not Character or not HRP then
            task.wait(1)
            continue
        end

        -- 1. Ir até ponto de construção via Tween
        mover(COORDS_CONSTRUCAO[indice])

        -- 2. Interagir no ponto
        pressionarE()

        -- 3. Ir até entrega via Tween
        mover(COORD_ENTREGA)

        -- 4. Entregar
        pressionarE()

        -- 5. Próxima coordenada (loop circular)
        indice = indice % #COORDS_CONSTRUCAO + 1
    end
end

-- ============================================================
--   UI — ABA FARM
-- ============================================================

Tabs.Farm:Toggle({
    Title       = "Farm construção",
    Description = "leval +0",
    Default     = false,
    Callback    = function(estado)
        farmAtivo = estado

        if estado then
            farmThread = task.spawn(loopFarm)
        else
            if farmThread then
                task.cancel(farmThread)
                farmThread = nil
            end
        end
    end,
})

-- ============================================================
--   UI — ABA CONFIGS
-- ============================================================

Tabs.Configs:Button({
    Title       = "Resetar Trabalho",
    Description = "Força buscar o trabalho na próxima ativação",
    Callback    = function()
        trabalhoIniciado = false
        WindUI:Notify({
            Title   = "Farm EB",
            Content = "Trabalho resetado com sucesso.",
            Icon    = "rotate-ccw",
            Time    = 3,
        })
    end,
})

Tabs.Configs:Paragraph({
    Title   = "Farm EB do Delta",
    Content = "by CoiledTom · RightCtrl para ocultar/mostrar",
})

-- ============================================================
--   NOTIFICAÇÃO DE CARREGAMENTO
-- ============================================================

WindUI:Notify({
    Title   = "Farm EB do Delta",
    Content = "Carregado com sucesso! by CoiledTom",
    Icon    = "check-circle",
    Time    = 5,
})
