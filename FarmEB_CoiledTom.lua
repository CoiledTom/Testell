-- ============================================================
--   Farm EB do Delta  |  by CoiledTom
--   Script: Farm de Construção
--   UI: WindUI v2
-- ============================================================

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ============================================================
--   SERVIÇOS
-- ============================================================

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer   = Players.LocalPlayer
local Character     = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP           = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
--   CONFIGURAÇÃO DA UI
-- ============================================================

local Window = WindUI:CreateWindow({
    Title        = "Farm EB do Delta",
    Icon         = "pickaxe",        -- ícone Lucide compatível com WindUI v2
    Author       = "by CoiledTom",
    Keybind      = Enum.KeyCode.RightControl,
    SaveConfig   = true,
    ConfigFolder = "CoiledTomHub",
})

local Tabs = {
    Farm    = Window:Tab({ Title = "Farm",    Icon = "hammer" }),
    Configs = Window:Tab({ Title = "Configs", Icon = "settings" }),
}

-- ============================================================
--   VARIÁVEIS DE CONTROLE
-- ============================================================

local farmAtivo      = false
local trabalhoIniciado = false
local farmThread     = nil

-- ============================================================
--   DADOS DAS COORDENADAS
-- ============================================================

local COORD_PEGAR_TRABALHO = Vector3.new(-1444, 13, -63)
local COORD_ENTREGA        = Vector3.new(-1417, 11, -87)

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

-- Atualiza referência ao personagem (seguro contra morte)
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

-- Teleporte seguro — aguarda HRP válido
local function teleportar(posicao)
    atualizarPersonagem()
    if not Character or not HRP then return end
    HRP.CFrame = CFrame.new(posicao)
    task.wait(0.3)
end

-- Simula pressionamento da tecla E
local function pressionarE()
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
    task.wait(0.1)
    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    task.wait(0.4)
end

-- Clica em um botão de UI do jogo pelo nome
local function clicarBotaoUI(nomeBotao)
    -- Tenta encontrar o botão dentro de qualquer ScreenGui ou PlayerGui
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end

    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            if gui.Name == nomeBotao then
                local oldVisible = gui.Visible
                -- Dispara clique via método interno
                gui.MouseButton1Click:Fire()
                task.wait(0.1)
                return true
            end
        end
    end
    return false
end

-- ============================================================
--   LÓGICA: PEGAR TRABALHO (executa apenas uma vez)
-- ============================================================

local function pegarTrabalho()
    teleportar(COORD_PEGAR_TRABALHO)
    task.wait(0.5)

    pressionarE()          -- abre menu de trabalho
    task.wait(0.8)

    -- Clica em "LeftOption" duas vezes com intervalo de 1 segundo
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
    -- Pega trabalho apenas na primeira ativação
    if not trabalhoIniciado then
        pegarTrabalho()
    end

    local indice = 1

    while farmAtivo do
        -- Verifica se personagem ainda está válido
        atualizarPersonagem()
        if not Character or not HRP then
            task.wait(1)
            continue
        end

        local coordAtual = COORDS_CONSTRUCAO[indice]

        -- 1. Teleportar até o ponto de construção
        teleportar(coordAtual)
        task.wait(0.3)

        -- 2. Pressionar E para coletar/interagir
        pressionarE()
        task.wait(0.3)

        -- 3. Teleportar até a entrega
        teleportar(COORD_ENTREGA)
        task.wait(0.3)

        -- 4. Pressionar E para entregar
        pressionarE()
        task.wait(0.3)

        -- 5. Avança para a próxima coordenada (loop circular)
        indice = indice % #COORDS_CONSTRUCAO + 1

        task.wait(0.1) -- pequena pausa de segurança entre ciclos
    end
end

-- ============================================================
--   UI — ABA FARM
-- ============================================================

local secaoFarm = Tabs.Farm:Section({ Title = "Construção" })

secaoFarm:Toggle({
    Title       = "Farm construção",
    Description = "leval +0",
    Default     = false,
    Callback    = function(estado)
        farmAtivo = estado

        if estado then
            -- Inicia o farm em uma thread separada
            farmThread = task.spawn(loopFarm)
        else
            -- Para o loop; a thread verifica `farmAtivo` e encerra sozinha
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

local secaoConfig = Tabs.Configs:Section({ Title = "Sistema" })

secaoConfig:Button({
    Title    = "Resetar Trabalho",
    Description = "Força buscar o trabalho novamente na próxima ativação",
    Callback = function()
        trabalhoIniciado = false
        WindUI:Notify({
            Title   = "Farm EB",
            Content = "Trabalho resetado com sucesso.",
            Icon    = "rotate-ccw",
            Time    = 3,
        })
    end,
})

secaoConfig:Paragraph({
    Title   = "Farm EB do Delta",
    Content = "by CoiledTom\nUse o keybind [RightCtrl] para ocultar/mostrar a UI.",
})

-- ============================================================
--   NOTIFICAÇÃO DE CARREGAMENTO
-- ============================================================

WindUI:Notify({
    Title   = "Farm EB do Delta",
    Content = "Script carregado com sucesso! by CoiledTom",
    Icon    = "check-circle",
    Time    = 5,
})
