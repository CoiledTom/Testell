local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local speaker = Players.LocalPlayer
local PlayerGui = speaker:WaitForChild("PlayerGui")

-- Remove uma versão anterior se o script for executado novamente.
local oldGui = PlayerGui:FindFirstChild("main")
if oldGui then
    oldGui:Destroy()
end

local main = Instance.new("ScreenGui")
main.Name = "main"
main.Parent = PlayerGui
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "Frame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Frame.BackgroundTransparency = 0.06
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.5, -130, 0.5, -58)
Frame.Size = UDim2.new(0, 260, 0, 116)
Frame.Active = true
Frame.Draggable = true
Frame.ZIndex = 10

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(130, 72, 220)
FrameStroke.Thickness = 1.2
FrameStroke.Transparency = 0.12
FrameStroke.Parent = Frame

local function makeButton(name, text, position, size)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Parent = Frame
    b.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
    b.BorderSizePixel = 0
    b.Position = position
    b.Size = size
    b.Font = Enum.Font.GothamMedium
    b.Text = text
    b.TextColor3 = Color3.fromRGB(218, 210, 232)
    b.TextSize = 12
    b.AutoButtonColor = false
    b.ZIndex = 12

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b

    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(72, 62, 92)
    st.Thickness = 1
    st.Transparency = 0.15
    st.Parent = b

    return b, st
end

local Title = Instance.new("TextLabel")
Title.Name = "TextLabel"
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 5)
Title.Size = UDim2.new(0, 150, 0, 24)
Title.Font = Enum.Font.GothamBold
Title.Text = "FLY"
Title.TextColor3 = Color3.fromRGB(232, 224, 246)
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Parent = Frame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 12, 0, 27)
Status.Size = UDim2.new(0, 150, 0, 16)
Status.Font = Enum.Font.Gotham
Status.Text = "V3  •  COILEDTOM"
Status.TextColor3 = Color3.fromRGB(120, 112, 132)
Status.TextSize = 9
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.ZIndex = 12

local closebutton, closeStroke = makeButton("Close", "×", UDim2.new(1, -38, 0, 7), UDim2.new(0, 30, 0, 24))
closebutton.TextSize = 20
closebutton.TextColor3 = Color3.fromRGB(245, 175, 190)
closeStroke.Color = Color3.fromRGB(100, 52, 70)

local mini, miniStroke = makeButton("minimize", "−", UDim2.new(1, -72, 0, 7), UDim2.new(0, 30, 0, 24))
mini.TextSize = 18

local mini2, mini2Stroke = makeButton("minimize2", "+", UDim2.new(0, 10, 0, 8), UDim2.new(0, 34, 0, 26))
mini2.TextSize = 17
mini2.Visible = false

local up = makeButton("up", "UP", UDim2.new(0, 10, 0, 48), UDim2.new(0, 52, 0, 28))
local down = makeButton("down", "DOWN", UDim2.new(0, 10, 0, 80), UDim2.new(0, 52, 0, 28))

local mine = makeButton("mine", "−", UDim2.new(0, 68, 0, 48), UDim2.new(0, 38, 0, 28))
local speed = Instance.new("TextLabel")
speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(20, 18, 28)
speed.BorderSizePixel = 0
speed.Position = UDim2.new(0, 108, 0, 48)
speed.Size = UDim2.new(0, 42, 0, 28)
speed.Font = Enum.Font.GothamBold
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(228, 220, 240)
speed.TextSize = 12
speed.ZIndex = 12
local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 7)
speedCorner.Parent = speed
local speedStroke = Instance.new("UIStroke")
speedStroke.Color = Color3.fromRGB(72, 62, 92)
speedStroke.Thickness = 1
speedStroke.Parent = speed

local plus = makeButton("plus", "+", UDim2.new(0, 156, 0, 48), UDim2.new(0, 38, 0, 28))

local onof, flyStroke = makeButton("onof", "FLY  OFF", UDim2.new(0, 200, 0, 48), UDim2.new(0, 50, 0, 28))

local ReturnButton, ReturnStroke
ReturnButton, ReturnStroke = makeButton("Return", "RETURN  OFF", UDim2.new(0, 156, 0, 80), UDim2.new(0, 94, 0, 28))
ReturnButton.TextSize = 9

local speeds = 1
local nowe = false
local tpwalking = false

local function setButtonVisual(button, stroke, active)
    if active then
        button.BackgroundColor3 = Color3.fromRGB(48, 28, 68)
        button.TextColor3 = Color3.fromRGB(226, 202, 250)
        if stroke then stroke.Color = Color3.fromRGB(140, 76, 225) end
    else
        button.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
        button.TextColor3 = Color3.fromRGB(218, 210, 232)
        if stroke then stroke.Color = Color3.fromRGB(72, 62, 92) end
    end
end

local function updateFlyVisual()
    if nowe then
        onof.Text = "FLY  ON"
        setButtonVisual(onof, flyStroke, true)
    else
        onof.Text = "FLY  OFF"
        setButtonVisual(onof, flyStroke, false)
    end
end

local returnEnabled = false
local savedDeathCFrame = nil
local savedDeathFlying = false
local restoring = false

local function updateReturnVisual()
    if returnEnabled then
        ReturnButton.Text = "RETURN  ON"
        setButtonVisual(ReturnButton, ReturnStroke, true)
    else
        ReturnButton.Text = "RETURN  OFF"
        setButtonVisual(ReturnButton, ReturnStroke, false)
    end
end

local function toggleFly()

	if nowe == true then

		nowe = false

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)

		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

	else 

		nowe = true

		for i = 1, speeds do

			spawn(function()

				local hb = game:GetService("RunService").Heartbeat	

				tpwalking = true

				local chr = game.Players.LocalPlayer.Character

				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

				while tpwalking and hb:Wait() and chr and hum and hum.Parent do

					if hum.MoveDirection.Magnitude > 0 then

						chr:TranslateBy(hum.MoveDirection)

					end

				end

			end)

		end

		game.Players.LocalPlayer.Character.Animate.Disabled = true

		local Char = game.Players.LocalPlayer.Character

		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

		for i,v in next, Hum:GetPlayingAnimationTracks() do

			v:AdjustSpeed(0)

		end

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)

		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

	end

	if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then

		local plr = game.Players.LocalPlayer

		local torso = plr.Character.Torso

		local flying = true

		local deb = true

		local ctrl = {f = 0, b = 0, l = 0, r = 0}

		local lastctrl = {f = 0, b = 0, l = 0, r = 0}

		local maxspeed = 50

		local speed = 0

		local bg = Instance.new("BodyGyro", torso)

		bg.P = 9e4

		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)

		bg.cframe = torso.CFrame

		local bv = Instance.new("BodyVelocity", torso)

		bv.velocity = Vector3.new(0,0.1,0)

		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

		if nowe == true then

			plr.Character.Humanoid.PlatformStand = true

		end

		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do

			game:GetService("RunService").RenderStepped:Wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then

				speed = speed+.5+(speed/maxspeed)

				if speed > maxspeed then

					speed = maxspeed

				end

			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then

				speed = speed-1

				if speed < 0 then

					speed = 0

				end

			end

			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then

				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed

				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}

			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then

				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed

			else

				bv.velocity = Vector3.new(0,0,0)

			end

			--	game.Players.LocalPlayer.Character.Animate.Disabled = true

			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)

		end

		ctrl = {f = 0, b = 0, l = 0, r = 0}

		lastctrl = {f = 0, b = 0, l = 0, r = 0}

		speed = 0

		bg:Destroy()

		bv:Destroy()

		plr.Character.Humanoid.PlatformStand = false

		game.Players.LocalPlayer.Character.Animate.Disabled = false

		tpwalking = false

	else

		local plr = game.Players.LocalPlayer

		local UpperTorso = plr.Character.UpperTorso

		local flying = true

		local deb = true

		local ctrl = {f = 0, b = 0, l = 0, r = 0}

		local lastctrl = {f = 0, b = 0, l = 0, r = 0}

		local maxspeed = 50

		local speed = 0

		local bg = Instance.new("BodyGyro", UpperTorso)

		bg.P = 9e4

		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)

		bg.cframe = UpperTorso.CFrame

		local bv = Instance.new("BodyVelocity", UpperTorso)

		bv.velocity = Vector3.new(0,0.1,0)

		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

		if nowe == true then

			plr.Character.Humanoid.PlatformStand = true

		end

		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do

			wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then

				speed = speed+.5+(speed/maxspeed)

				if speed > maxspeed then

					speed = maxspeed

				end

			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then

				speed = speed-1

				if speed < 0 then

					speed = 0

				end

			end

			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then

				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed

				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}

			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then

				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed

			else

				bv.velocity = Vector3.new(0,0,0)

			end

			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)

		end

		ctrl = {f = 0, b = 0, l = 0, r = 0}

		lastctrl = {f = 0, b = 0, l = 0, r = 0}

		speed = 0

		bg:Destroy()

		bv:Destroy()

		plr.Character.Humanoid.PlatformStand = false

		game.Players.LocalPlayer.Character.Animate.Disabled = false

		tpwalking = false

	end

end


-- Botão do Fly usa o mesmo motor original.
onof.Activated:Connect(function()
    task.spawn(function()
        toggleFly()
        updateFlyVisual()
    end)
end)

-- Movimento vertical, compatível com toque e mouse.
local upHolding = false
local downHolding = false

local function moveVertical(amount, flagName)
    task.spawn(function()
        while (flagName == "up" and upHolding) or (flagName == "down" and downHolding) do
            local character = speaker.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = root.CFrame * CFrame.new(0, amount, 0)
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

up.MouseButton1Down:Connect(function()
    upHolding = true
    moveVertical(1, "up")
end)

up.MouseButton1Up:Connect(function()
    upHolding = false
end)

up.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        upHolding = false
    end
end)

down.MouseButton1Down:Connect(function()
    downHolding = true
    moveVertical(-1, "down")
end)

down.MouseButton1Up:Connect(function()
    downHolding = false
end)

down.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        downHolding = false
    end
end)

plus.Activated:Connect(function()
    speeds += 1
    speed.Text = tostring(speeds)

    if nowe then
        tpwalking = false
        for i = 1, speeds do
            task.spawn(function()
                local hb = RunService.Heartbeat
                tpwalking = true
                local character = speaker.Character
                local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
                while tpwalking and hb:Wait() and character and humanoid and humanoid.Parent do
                    if humanoid.MoveDirection.Magnitude > 0 then
                        character:TranslateBy(humanoid.MoveDirection)
                    end
                end
            end)
        end
    end
end)

mine.Activated:Connect(function()
    if speeds <= 1 then
        speed.Text = "MIN 1"
        task.delay(0.7, function()
            if speed and speed.Parent then
                speed.Text = tostring(speeds)
            end
        end)
        return
    end

    speeds -= 1
    speed.Text = tostring(speeds)

    if nowe then
        tpwalking = false
        for i = 1, speeds do
            task.spawn(function()
                local hb = RunService.Heartbeat
                tpwalking = true
                local character = speaker.Character
                local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
                while tpwalking and hb:Wait() and character and humanoid and humanoid.Parent do
                    if humanoid.MoveDirection.Magnitude > 0 then
                        character:TranslateBy(humanoid.MoveDirection)
                    end
                end
            end)
        end
    end
end)

ReturnButton.Activated:Connect(function()
    returnEnabled = not returnEnabled
    updateReturnVisual()
end)

-- Salva o local exato da morte.
local function watchCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)

    if not humanoid or not root then
        return
    end

    humanoid.Died:Connect(function()
        local wasFlying = nowe == true

        if returnEnabled and root.Parent then
            savedDeathCFrame = root.CFrame
            savedDeathFlying = wasFlying
        end

        -- Para o loop do Fly antigo quando o personagem morre.
        nowe = false
        tpwalking = false
    end)
end

if speaker.Character then
    task.spawn(watchCharacter, speaker.Character)
end

-- Respawn: teleporta imediatamente e restaura o Fly quando necessário.
speaker.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)

    if not humanoid or not root then
        return
    end

    local target = savedDeathCFrame
    local shouldFly = savedDeathFlying

    savedDeathCFrame = nil
    savedDeathFlying = false

    if returnEnabled and target then
        restoring = true

        -- O primeiro CFrame acontece assim que o RootPart existe.
        character:PivotTo(target)
        root.CFrame = target

        if shouldFly then
            -- Deixa o loop antigo terminar antes de iniciar o novo.
            RunService.Heartbeat:Wait()

            if character.Parent and humanoid.Health > 0 then
                character:PivotTo(target)
                root.CFrame = target

                nowe = false
                task.spawn(function()
                    if character.Parent and humanoid.Health > 0 then
                        toggleFly()
                        updateFlyVisual()
                    end
                end)
            end
        else
            nowe = false
            humanoid.PlatformStand = false
            local animate = character:FindFirstChild("Animate")
            if animate then
                animate.Disabled = false
            end
        end

        restoring = false
    else
        nowe = false
        humanoid.PlatformStand = false
        local animate = character:FindFirstChild("Animate")
        if animate then
            animate.Disabled = false
        end
    end

    watchCharacter(character)
end)

-- Fechar.
closebutton.Activated:Connect(function()
    nowe = false
    tpwalking = false
    main:Destroy()
end)

local expanded = true

local function setExpanded(value)
    expanded = value

    local controls = {
        up, down, mine, speed, plus, onof, ReturnButton
    }

    for _, object in ipairs(controls) do
        object.Visible = value
    end

    Title.Visible = value
    Status.Visible = value
    closebutton.Visible = value
    mini.Visible = value
    mini2.Visible = not value

    if value then
        Frame.Size = UDim2.new(0, 260, 0, 116)
    else
        Frame.Size = UDim2.new(0, 56, 0, 42)
        Frame.BackgroundTransparency = 0.06
    end
end

mini.Activated:Connect(function()
    setExpanded(false)
end)

mini2.Activated:Connect(function()
    setExpanded(true)
end)

-- Hover discreto, sem alterar o layout.
local hoverButtons = {up, down, mine, plus}
for _, button in ipairs(hoverButtons) do
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(35, 30, 46)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
    end)
end

updateFlyVisual()
updateReturnVisual()

-- Mantém o texto do Fly sincronizado sem mexer no motor.
task.spawn(function()
    while main.Parent do
        updateFlyVisual()
        task.wait(0.2)
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "FLY",
        Text = "CoiledTom V3",
        Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
    })
end)
