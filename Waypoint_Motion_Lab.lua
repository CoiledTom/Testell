--========================================================--
--                  WAYPOINT MOTION LAB                  --
--========================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Character
local Humanoid
local Root

local function setupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
end

setupCharacter(Player.Character or Player.CharacterAdded:Wait())
Player.CharacterAdded:Connect(setupCharacter)

local Speed = 60
local Running = false
local Loop = false
local ShowRoute = true

local Waypoints = {nil, nil, nil, nil}

local Methods = {
    "Tween CFrame",
    "Tween Position",
    "CFrame Lerp",
    "CFrame Frame",
    "MoveTo",
    "AlignPosition",
    "LinearVelocity",
    "AssemblyLinearVelocity",
    "Plataforma Invisível",
    "Seguir Objeto"
}

local MethodIndex = 1
local CurrentMethod = Methods[MethodIndex]
local CurrentTween
local PhysicsObjects = {}

local VisualFolder = Instance.new("Folder")
VisualFolder.Name = "MotionLab_Visuals"
VisualFolder.Parent = workspace

local PointParts = {}
local RouteParts = {}

local function clearRoute()
    for _, obj in pairs(PointParts) do obj:Destroy() end
    for _, obj in pairs(RouteParts) do obj:Destroy() end
    PointParts = {}
    RouteParts = {}
end

local function createPoint(index, position)
    local p = Instance.new("Part")
    p.Name = "WP" .. index
    p.Shape = Enum.PartType.Ball
    p.Size = Vector3.new(2.5, 2.5, 2.5)
    p.Position = position
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.Material = Enum.Material.Neon
    p.Transparency = ShowRoute and 0.15 or 1
    p.Parent = VisualFolder
    PointParts[index] = p
end

local function createLine(a, b)
    local distance = (b - a).Magnitude
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.Material = Enum.Material.Neon
    p.Transparency = ShowRoute and 0.45 or 1
    p.Size = Vector3.new(0.25, 0.25, distance)
    p.CFrame = CFrame.lookAt((a + b) / 2, b)
    p.Parent = VisualFolder
    table.insert(RouteParts, p)
end

local function updateRoute()
    clearRoute()
    for i = 1, 4 do
        if Waypoints[i] then createPoint(i, Waypoints[i]) end
    end
    for i = 1, 3 do
        if Waypoints[i] and Waypoints[i + 1] then
            createLine(Waypoints[i], Waypoints[i + 1])
        end
    end
end

local function cleanupPhysics()
    for _, obj in ipairs(PhysicsObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    PhysicsObjects = {}
end

local function stopMovement()
    Running = false
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
    cleanupPhysics()
end

local function tweenCFrame(target)
    local distance = (Root.Position - target).Magnitude
    local duration = math.max(distance / Speed, 0.05)
    local tween = TweenService:Create(
        Root,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(target)}
    )
    CurrentTween = tween
    tween:Play()
    tween.Completed:Wait()
    CurrentTween = nil
end

local function tweenPosition(target)
    local distance = (Root.Position - target).Magnitude
    local duration = math.max(distance / Speed, 0.05)
    local tween = TweenService:Create(
        Root,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Position = target}
    )
    CurrentTween = tween
    tween:Play()
    tween.Completed:Wait()
    CurrentTween = nil
end

local function cframeLerp(target)
    local start = Root.CFrame
    local finish = CFrame.new(target)
    local distance = (Root.Position - target).Magnitude
    local duration = math.max(distance / Speed, 0.05)
    local startTime = os.clock()

    while Running do
        local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
        Root.CFrame = start:Lerp(finish, alpha)
        if alpha >= 1 then break end
        RunService.RenderStepped:Wait()
    end
end

local function cframeFrame(target)
    local distance = (Root.Position - target).Magnitude
    local duration = math.max(distance / Speed, 0.05)
    local start = Root.Position
    local startTime = os.clock()

    while Running do
        local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
        Root.CFrame = CFrame.new(start:Lerp(target, alpha))
        if alpha >= 1 then break end
        RunService.RenderStepped:Wait()
    end
end

local function moveTo(target)
    Humanoid:MoveTo(target)
    local finished = false
    local connection = Humanoid.MoveToFinished:Connect(function() finished = true end)

    while Running and not finished do task.wait() end
    connection:Disconnect()
end

local function alignPosition(target)
    local attachment = Instance.new("Attachment")
    attachment.Parent = Root

    local align = Instance.new("AlignPosition")
    align.Attachment0 = attachment
    align.Mode = Enum.PositionAlignmentMode.OneAttachment
    align.Position = target
    align.MaxForce = math.huge
    align.MaxVelocity = Speed
    align.Responsiveness = 100
    align.Parent = Root

    table.insert(PhysicsObjects, attachment)
    table.insert(PhysicsObjects, align)

    while Running do
        if (Root.Position - target).Magnitude < 2 then break end
        RunService.Heartbeat:Wait()
    end
    cleanupPhysics()
end

local function linearVelocity(target)
    local attachment = Instance.new("Attachment")
    attachment.Parent = Root

    local velocity = Instance.new("LinearVelocity")
    velocity.Attachment0 = attachment
    velocity.MaxForce = math.huge
    velocity.VectorVelocity = (target - Root.Position).Unit * Speed
    velocity.Parent = Root

    table.insert(PhysicsObjects, attachment)
    table.insert(PhysicsObjects, velocity)

    while Running do
        local direction = target - Root.Position
        if direction.Magnitude < 3 then break end
        if direction.Magnitude > 0 then
            velocity.VectorVelocity = direction.Unit * Speed
        end
        RunService.Heartbeat:Wait()
    end
    cleanupPhysics()
end

local function assemblyVelocity(target)
    while Running do
        local direction = target - Root.Position
        if direction.Magnitude < 3 then break end
        Root.AssemblyLinearVelocity = direction.Unit * Speed
        RunService.Heartbeat:Wait()
    end
    Root.AssemblyLinearVelocity = Vector3.zero
end

local function invisiblePlatform(target)
    local platform = Instance.new("Part")
    platform.Name = "InvisibleMotionPlatform"
    platform.Size = Vector3.new(8, 1, 8)
    platform.Transparency = 1
    platform.CanCollide = true
    platform.Anchored = true
    platform.Position = Root.Position - Vector3.new(0, 3.5, 0)
    platform.Parent = workspace
    table.insert(PhysicsObjects, platform)

    local destination = target - Vector3.new(0, 3.5, 0)
    local distance = (platform.Position - destination).Magnitude
    local duration = math.max(distance / Speed, 0.05)

    local tween = TweenService:Create(
        platform,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Position = destination}
    )

    CurrentTween = tween
    tween:Play()
    tween.Completed:Wait()
    CurrentTween = nil
    cleanupPhysics()
end

local function followObject(target)
    local marker = Instance.new("Part")
    marker.Name = "InvisibleTarget"
    marker.Size = Vector3.new(1, 1, 1)
    marker.Transparency = 1
    marker.Anchored = true
    marker.CanCollide = false
    marker.Position = target
    marker.Parent = workspace
    table.insert(PhysicsObjects, marker)

    while Running do
        local direction = marker.Position - Root.Position
        if direction.Magnitude < 2 then break end
        local dt = RunService.RenderStepped:Wait()
        Root.CFrame = Root.CFrame:Lerp(
            CFrame.new(marker.Position),
            math.clamp(Speed * dt / math.max(direction.Magnitude, 0.001), 0, 1)
        )
    end
    cleanupPhysics()
end

local function move(target)
    if CurrentMethod == "Tween CFrame" then tweenCFrame(target)
    elseif CurrentMethod == "Tween Position" then tweenPosition(target)
    elseif CurrentMethod == "CFrame Lerp" then cframeLerp(target)
    elseif CurrentMethod == "CFrame Frame" then cframeFrame(target)
    elseif CurrentMethod == "MoveTo" then moveTo(target)
    elseif CurrentMethod == "AlignPosition" then alignPosition(target)
    elseif CurrentMethod == "LinearVelocity" then linearVelocity(target)
    elseif CurrentMethod == "AssemblyLinearVelocity" then assemblyVelocity(target)
    elseif CurrentMethod == "Plataforma Invisível" then invisiblePlatform(target)
    elseif CurrentMethod == "Seguir Objeto" then followObject(target)
    end
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "WaypointMotionLab"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(340, 500)
Main.Position = UDim2.new(0.5, -170, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 65, 65)
Stroke.Thickness = 1.5
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.fromOffset(10, 8)
Title.BackgroundTransparency = 1
Title.Text = "MOTION LAB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 19
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 22)
Status.Position = UDim2.fromOffset(10, 43)
Status.BackgroundTransparency = 1
Status.Text = "Pronto"
Status.TextColor3 = Color3.fromRGB(145, 145, 150)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local function waypointButton(index, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 38)
    button.Position = UDim2.fromOffset(10, y)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    button.Text = "WP " .. index .. "  •  Definir"
    button.TextColor3 = Color3.fromRGB(235, 235, 235)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.Parent = Main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    button.MouseButton1Click:Connect(function()
        if Root then
            Waypoints[index] = Root.Position
            button.Text = "WP " .. index .. "  ✓ Definido"
            updateRoute()
        end
    end)
end

waypointButton(1, 75)
waypointButton(2, 118)
waypointButton(3, 161)
waypointButton(4, 204)

local MethodButton = Instance.new("TextButton")
MethodButton.Size = UDim2.new(1, -20, 0, 38)
MethodButton.Position = UDim2.fromOffset(10, 250)
MethodButton.BackgroundColor3 = Color3.fromRGB(27, 27, 33)
MethodButton.Text = "Método: " .. CurrentMethod
MethodButton.TextColor3 = Color3.new(1, 1, 1)
MethodButton.Font = Enum.Font.GothamMedium
MethodButton.TextSize = 12
MethodButton.Parent = Main

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 8)
MC.Parent = MethodButton

MethodButton.MouseButton1Click:Connect(function()
    MethodIndex += 1
    if MethodIndex > #Methods then MethodIndex = 1 end
    CurrentMethod = Methods[MethodIndex]
    MethodButton.Text = "Método: " .. CurrentMethod
end)

local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(0.48, -5, 0, 38)
SpeedButton.Position = UDim2.fromOffset(10, 294)
SpeedButton.BackgroundColor3 = Color3.fromRGB(27, 27, 33)
SpeedButton.Text = "Velocidade: 60"
SpeedButton.TextColor3 = Color3.new(1, 1, 1)
SpeedButton.Font = Enum.Font.GothamMedium
SpeedButton.TextSize = 12
SpeedButton.Parent = Main

local SC = Instance.new("UICorner")
SC.CornerRadius = UDim.new(0, 8)
SC.Parent = SpeedButton

SpeedButton.MouseButton1Click:Connect(function()
    Speed += 20
    if Speed > 200 then Speed = 20 end
    SpeedButton.Text = "Velocidade: " .. Speed
end)

local LoopButton = Instance.new("TextButton")
LoopButton.Size = UDim2.new(0.48, -5, 0, 38)
LoopButton.Position = UDim2.new(0.52, 0, 0, 294)
LoopButton.BackgroundColor3 = Color3.fromRGB(27, 27, 33)
LoopButton.Text = "Loop: OFF"
LoopButton.TextColor3 = Color3.new(1, 1, 1)
LoopButton.Font = Enum.Font.GothamMedium
LoopButton.TextSize = 12
LoopButton.Parent = Main

local LC = Instance.new("UICorner")
LC.CornerRadius = UDim.new(0, 8)
LC.Parent = LoopButton

LoopButton.MouseButton1Click:Connect(function()
    Loop = not Loop
    LoopButton.Text = Loop and "Loop: ON" or "Loop: OFF"
end)

local VisualButton = Instance.new("TextButton")
VisualButton.Size = UDim2.new(1, -20, 0, 34)
VisualButton.Position = UDim2.fromOffset(10, 339)
VisualButton.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
VisualButton.Text = "Visualização da rota: ON"
VisualButton.TextColor3 = Color3.new(1, 1, 1)
VisualButton.Font = Enum.Font.GothamMedium
VisualButton.TextSize = 11
VisualButton.Parent = Main

local VC = Instance.new("UICorner")
VC.CornerRadius = UDim.new(0, 8)
VC.Parent = VisualButton

VisualButton.MouseButton1Click:Connect(function()
    ShowRoute = not ShowRoute
    VisualButton.Text = ShowRoute and "Visualização da rota: ON" or "Visualização da rota: OFF"
    updateRoute()
end)

local Start = Instance.new("TextButton")
Start.Size = UDim2.new(0.48, -5, 0, 44)
Start.Position = UDim2.fromOffset(10, 382)
Start.BackgroundColor3 = Color3.fromRGB(35, 125, 70)
Start.Text = "▶  TESTAR"
Start.TextColor3 = Color3.new(1, 1, 1)
Start.Font = Enum.Font.GothamBold
Start.TextSize = 13
Start.Parent = Main

local STC = Instance.new("UICorner")
STC.CornerRadius = UDim.new(0, 9)
STC.Parent = Start

local Stop = Instance.new("TextButton")
Stop.Size = UDim2.new(0.48, -5, 0, 44)
Stop.Position = UDim2.new(0.52, 0, 0, 382)
Stop.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
Stop.Text = "■  PARAR"
Stop.TextColor3 = Color3.new(1, 1, 1)
Stop.Font = Enum.Font.GothamBold
Stop.TextSize = 13
Stop.Parent = Main

local SPC = Instance.new("UICorner")
SPC.CornerRadius = UDim.new(0, 9)
SPC.Parent = Stop

local Reset = Instance.new("TextButton")
Reset.Size = UDim2.new(1, -20, 0, 34)
Reset.Position = UDim2.fromOffset(10, 435)
Reset.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Reset.Text = "↻  LIMPAR WAYPOINTS"
Reset.TextColor3 = Color3.fromRGB(220, 220, 220)
Reset.Font = Enum.Font.GothamMedium
Reset.TextSize = 11
Reset.Parent = Main

local RC = Instance.new("UICorner")
RC.CornerRadius = UDim.new(0, 8)
RC.Parent = Reset

local function runRoute()
    if Running then return end

    local valid = false
    for i = 1, 4 do
        if Waypoints[i] then valid = true break end
    end

    if not valid then
        Status.Text = "Nenhum waypoint definido"
        return
    end

    Running = true

    task.spawn(function()
        repeat
            for i = 1, 4 do
                if not Running then break end
                if Waypoints[i] then
                    Status.Text = "Executando • WP " .. i .. " • " .. CurrentMethod
                    move(Waypoints[i])
                end
            end
        until not Running or not Loop

        Running = false
        cleanupPhysics()
        Status.Text = "Pronto"
    end)
end

Start.MouseButton1Click:Connect(runRoute)

Stop.MouseButton1Click:Connect(function()
    stopMovement()
    Status.Text = "Parado"
end)

Reset.MouseButton1Click:Connect(function()
    stopMovement()

    for i = 1, 4 do
        Waypoints[i] = nil
    end

    updateRoute()
    Status.Text = "Waypoints limpos"
end)

local dragging = false
local dragStart
local startPosition

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Main.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

print("Motion Lab carregado.")
