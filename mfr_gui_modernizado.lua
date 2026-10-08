local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KilasikFlingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- RocketUI Icons
local Icons = {}
pcall(function()
    local iconSource = game:HttpGet("https://raw.githubusercontent.com/CoiledTom/RocketUI/refs/heads/main/Icons.lua")
    Icons = loadstring(iconSource)() or {}
end)

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
    return c
end

local function addStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function iconButton(parent, iconNames, fallback, size)
    local button = Instance.new("TextButton")
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Size = UDim2.fromOffset(size or 28, size or 28)
    button.Parent = parent

    local image
    for _, name in ipairs(iconNames) do
        if Icons[name] then
            image = Icons[name]
            break
        end
    end

    if image then
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Size = UDim2.new(1, -6, 1, -6)
        img.Position = UDim2.fromOffset(3, 3)
        img.Image = image
        img.ImageColor3 = Color3.fromRGB(235, 235, 240)
        img.Parent = button
    else
        button.Text = fallback or "•"
        button.TextColor3 = Color3.fromRGB(235, 235, 240)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 15
    end

    return button
end

local function makeDraggable(handle, target)
    local UIS = game:GetService("UserInputService")
    local dragging = false
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 455)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -227)
MainFrame.BackgroundColor3 = Color3.fromRGB(17, 18, 22)
MainFrame.BackgroundTransparency = 0.04
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 16)
addStroke(MainFrame, Color3.fromRGB(82, 76, 105), 1, 0.25)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 23, 29)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
addCorner(TitleBar, 16)

local Title = Instance.new("TextLabel")
Title.Position = UDim2.fromOffset(48, 0)
Title.Size = UDim2.new(1, -150, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "MULTI-FLING"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Position = UDim2.fromOffset(48, 25)
Subtitle.Size = UDim2.new(1, -150, 0, 18)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "PLAYER CONTROL"
Subtitle.TextColor3 = Color3.fromRGB(125, 127, 138)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 9
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TitleBar

local HeaderIcon = iconButton(TitleBar, {"zap", "rocket", "activity"}, "✦", 30)
HeaderIcon.Position = UDim2.fromOffset(10, 9)
HeaderIcon.AutoButtonColor = false

local MinimizeButton = iconButton(TitleBar, {"minus", "minimize-2"}, "−", 30)
MinimizeButton.Position = UDim2.new(1, -92, 0, 9)

local BubbleButton = iconButton(TitleBar, {"circle", "maximize-2", "scan"}, "○", 30)
BubbleButton.Position = UDim2.new(1, -58, 0, 9)

local CloseButton = iconButton(TitleBar, {"x", "close"}, "×", 30)
CloseButton.Position = UDim2.new(1, -34, 0, 9)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.fromOffset(14, 58)
StatusLabel.Size = UDim2.new(1, -28, 0, 27)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 26, 32)
StatusLabel.BackgroundTransparency = 0.15
StatusLabel.Text = "Select targets to fling"
StatusLabel.TextColor3 = Color3.fromRGB(210, 211, 220)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame
addCorner(StatusLabel, 8)
addStroke(StatusLabel, Color3.fromRGB(70, 71, 82), 1, 0.55)

local SelectionFrame = Instance.new("Frame")
SelectionFrame.Position = UDim2.fromOffset(14, 92)
SelectionFrame.Size = UDim2.new(1, -28, 0, 235)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(21, 22, 27)
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Parent = MainFrame
addCorner(SelectionFrame, 12)
addStroke(SelectionFrame, Color3.fromRGB(65, 66, 77), 1, 0.55)

local ListHeader = Instance.new("TextLabel")
ListHeader.Position = UDim2.fromOffset(12, 7)
ListHeader.Size = UDim2.new(1, -24, 0, 20)
ListHeader.BackgroundTransparency = 1
ListHeader.Text = "PLAYERS"
ListHeader.TextColor3 = Color3.fromRGB(125, 127, 138)
ListHeader.Font = Enum.Font.GothamBold
ListHeader.TextSize = 10
ListHeader.TextXAlignment = Enum.TextXAlignment.Left
ListHeader.Parent = SelectionFrame

local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Position = UDim2.fromOffset(7, 31)
PlayerScrollFrame.Size = UDim2.new(1, -14, 1, -38)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 3
PlayerScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 96, 120)
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = SelectionFrame

local MethodButton = Instance.new("TextButton")
MethodButton.Position = UDim2.fromOffset(14, 337)
MethodButton.Size = UDim2.new(1, -28, 0, 34)
MethodButton.BackgroundColor3 = Color3.fromRGB(27, 28, 35)
MethodButton.BorderSizePixel = 0
MethodButton.Text = "  METHOD: BodyVelocity"
MethodButton.TextColor3 = Color3.fromRGB(225, 226, 233)
MethodButton.Font = Enum.Font.GothamMedium
MethodButton.TextSize = 11
MethodButton.TextXAlignment = Enum.TextXAlignment.Left
MethodButton.AutoButtonColor = false
MethodButton.Parent = MainFrame
addCorner(MethodButton, 9)
addStroke(MethodButton, Color3.fromRGB(74, 72, 91), 1, 0.4)

local StartButton = Instance.new("TextButton")
StartButton.Position = UDim2.fromOffset(14, 378)
StartButton.Size = UDim2.new(0.5, -19, 0, 35)
StartButton.BackgroundColor3 = Color3.fromRGB(38, 105, 75)
StartButton.BorderSizePixel = 0
StartButton.Text = "START"
StartButton.TextColor3 = Color3.fromRGB(240, 255, 247)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 12
StartButton.AutoButtonColor = false
StartButton.Parent = MainFrame
addCorner(StartButton, 9)

local StopButton = Instance.new("TextButton")
StopButton.Position = UDim2.new(0.5, 5, 0, 378)
StopButton.Size = UDim2.new(0.5, -19, 0, 35)
StopButton.BackgroundColor3 = Color3.fromRGB(112, 45, 53)
StopButton.BorderSizePixel = 0
StopButton.Text = "STOP"
StopButton.TextColor3 = Color3.fromRGB(255, 242, 243)
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 12
StopButton.AutoButtonColor = false
StopButton.Parent = MainFrame
addCorner(StopButton, 9)

local SelectAllButton = Instance.new("TextButton")
SelectAllButton.Position = UDim2.fromOffset(14, 421)
SelectAllButton.Size = UDim2.new(0.5, -19, 0, 24)
SelectAllButton.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
SelectAllButton.BorderSizePixel = 0
SelectAllButton.Text = "SELECT ALL"
SelectAllButton.TextColor3 = Color3.fromRGB(185, 186, 196)
SelectAllButton.Font = Enum.Font.GothamMedium
SelectAllButton.TextSize = 9
SelectAllButton.AutoButtonColor = false
SelectAllButton.Parent = MainFrame
addCorner(SelectAllButton, 7)

local DeselectAllButton = Instance.new("TextButton")
DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 421)
DeselectAllButton.Size = UDim2.new(0.5, -19, 0, 24)
DeselectAllButton.BackgroundColor3 = Color3.fromRGB(29, 30, 37)
DeselectAllButton.BorderSizePixel = 0
DeselectAllButton.Text = "CLEAR ALL"
DeselectAllButton.TextColor3 = Color3.fromRGB(185, 186, 196)
DeselectAllButton.Font = Enum.Font.GothamMedium
DeselectAllButton.TextSize = 9
DeselectAllButton.AutoButtonColor = false
DeselectAllButton.Parent = MainFrame
addCorner(DeselectAllButton, 7)

-- Compact bubble mode: tap the bubble to open/close the full GUI.
local Bubble = Instance.new("TextButton")
Bubble.Size = UDim2.fromOffset(56, 56)
Bubble.Position = UDim2.new(0, 20, 0.5, -28)
Bubble.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Bubble.BorderSizePixel = 0
Bubble.Text = ""
Bubble.Visible = false
Bubble.Active = true
Bubble.Parent = ScreenGui
addCorner(Bubble, 28)
addStroke(Bubble, Color3.fromRGB(112, 96, 145), 1, 0.15)

local BubbleIcon = iconButton(Bubble, {"zap", "rocket", "circle"}, "✦", 42)
BubbleIcon.Position = UDim2.fromOffset(7, 7)

makeDraggable(TitleBar, MainFrame)
makeDraggable(Bubble, Bubble)

local minimized = false
local bubbleMode = false
local normalSize = MainFrame.Size

local function setMinimized(state)
    minimized = state
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child ~= TitleBar and not child:IsA("UIStroke") then
            child.Visible = not state
        end
    end
    MainFrame.Size = state and UDim2.new(0, 340, 0, 48) or normalSize
end

local function setBubbleMode(state)
    bubbleMode = state
    MainFrame.Visible = not state
    Bubble.Visible = state
end

MinimizeButton.MouseButton1Click:Connect(function()
    setMinimized(not minimized)
end)

BubbleButton.MouseButton1Click:Connect(function()
    setBubbleMode(true)
end)

Bubble.MouseButton1Click:Connect(function()
    setBubbleMode(false)
end)

local SelectedTargets = {}
local PlayerCheckboxes = {}
local FlingActive = false
local FlingConnection = nil
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight
local function CountSelectedTargets()
    local count = 0
    for _ in pairs(SelectedTargets) do
        count = count + 1
    end
    return count
end
local function UpdateStatus()
    local count = CountSelectedTargets()
    if FlingActive then
        StatusLabel.Text = "Flinging " .. count .. " target(s)"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        StatusLabel.Text = count .. " target(s) selected" 
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function hasNoCollision(character)
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then
        if hrp.CanCollide == false then return true end
        if hrp.Massless == true then return true end
        if hrp.Anchored == true then return true end
    end
    return false
end

spawn(function()
    while true do
        task.wait(1)
        for playerName, checkboxData in pairs(PlayerCheckboxes) do
            local player = Players:FindFirstChild(playerName)
            if player and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local noCollision = hrp and (hrp.CanCollide == false or hrp.Massless == true or hrp.Anchored == true)
                local label = checkboxData.Entry:FindFirstChildOfClass("TextLabel")
                if label then
                    label.Text = string.format(
                        '<font color="#%s">%s</font> <font color="#999999">(%s)</font>',
                        noCollision and "FF0000" or "FFFFFF",
                        player.Name,
                        player.DisplayName
                    )
                end
            end
        end
    end
end)

local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do
        child:Destroy()
    end
    PlayerCheckboxes = {}
    
    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    
    local yPosition = 5
    for _, player in ipairs(PlayerList) do
        if player ~= Player then
            local PlayerEntry = Instance.new("Frame")
            PlayerEntry.Size = UDim2.new(1, -10, 0, 35)
            PlayerEntry.Position = UDim2.new(0, 5, 0, yPosition)
            PlayerEntry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            PlayerEntry.BorderSizePixel = 0
            PlayerEntry.Parent = PlayerScrollFrame
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = PlayerEntry
            
            local Checkbox = Instance.new("TextButton")
            Checkbox.Size = UDim2.new(0, 24, 0, 24)
            Checkbox.Position = UDim2.new(0, 3, 0.5, -12)
            Checkbox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            Checkbox.BorderSizePixel = 0
            Checkbox.Text = ""
            Checkbox.Parent = PlayerEntry
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = Checkbox
            
            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
            Checkmark.TextSize = 18
            Checkmark.Font = Enum.Font.SourceSansBold
            Checkmark.Visible = SelectedTargets[player.Name] ~= nil
            Checkmark.Parent = Checkbox
            
            local noCollision = hasNoCollision(player.Character)
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -35, 1, 0)
            NameLabel.Position = UDim2.new(0, 30, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.RichText = true
            NameLabel.Text = string.format(
                '<font color="#%s">%s</font> <font color="#999999">(%s)</font>',
                noCollision and "FF0000" or "FFFFFF",
                player.Name,
                player.DisplayName
            )
            NameLabel.TextSize = 16
            NameLabel.Font = Enum.Font.SourceSans
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = PlayerEntry
            
            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.ZIndex = 2
            ClickArea.Parent = PlayerEntry

            ClickArea.MouseButton1Click:Connect(function()
                if SelectedTargets[player.Name] then
                    SelectedTargets[player.Name] = nil
                    Checkmark.Visible = false
                else
                    SelectedTargets[player.Name] = player
                    Checkmark.Visible = true
                end
                UpdateStatus()
            end)
            
            PlayerCheckboxes[player.Name] = {
                Entry = PlayerEntry,
                Checkmark = Checkmark
            }
            
            yPosition = yPosition + 40
        end
    end
    
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 5)
end

local function ToggleAllPlayers(select)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            local checkboxData = PlayerCheckboxes[player.Name]
            if checkboxData then
                if select then
                    SelectedTargets[player.Name] = player
                    checkboxData.Checkmark.Visible = true
                else
                    SelectedTargets[player.Name] = nil
                    checkboxData.Checkmark.Visible = false
                end
            end
        end
    end
    
    UpdateStatus()
end

local function Message(Title, Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = Title,
        Text = Text,
        Duration = Time or 5
    })
end

local FlingMethods = {
    ["BodyVelocity"] = function(rootPart, power, dir)
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = dir * power * 100
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = rootPart
        return bv
    end,
    ["BodyThrust"] = function(rootPart, power, dir)
        local bt = Instance.new("BodyThrust")
        bt.Force = dir * power * 500
        bt.Location = rootPart.Position + Vector3.new(0, 1, 0)
        bt.Parent = rootPart
        return bt
    end,
    ["BodyForce"] = function(rootPart, power, dir)
        local bf = Instance.new("BodyForce")
        bf.Force = dir * power * 500
        bf.Parent = rootPart
        return bf
    end,
    ["VectorForce"] = function(rootPart, power, dir)
        local vf = Instance.new("VectorForce")
        vf.Force = dir * power * 500
        vf.Parent = rootPart
        return vf
    end,
    ["LinearVelocity"] = function(rootPart, power, dir)
        local lv = Instance.new("LinearVelocity")
        lv.Velocity = dir * power * 100
        lv.MaxForce = 9e9
        lv.Parent = rootPart
        return lv
    end,
	["ExplodeFling"] = function(rootPart, power, dir)
    	local bf = Instance.new("BodyForce")
    	bf.Force = dir * power * 999999
    	bf.Parent = rootPart
    
    	local bv = Instance.new("BodyVelocity")
    	bv.Velocity = Vector3.new(
        	math.random(-1000, 1000),
        	math.random(500, 1500),
    		math.random(-1000, 1000)
    	)
    	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    	bv.Parent = rootPart
	
    	game:GetService("Debris"):AddItem(bf, 0.3)
    	game:GetService("Debris"):AddItem(bv, 0.3)
   		return {bf, bv}
	end,
    ["NaNFling"] = function(rootPart, power, dir)
    local targetRoot = nil
    for _, player in pairs(SelectedTargets) do
        if player and player.Character then
            local tr = player.Character:FindFirstChild("HumanoidRootPart")
            if tr then targetRoot = tr break end
        end
    end
    if not targetRoot then return nil end
    
    local nan_value = (0) / (0)
    local nan_vector = Vector3.new(nan_value, nan_value, nan_value)
    
    local humanoid = rootPart.Parent:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    
    rootPart.CFrame = targetRoot.CFrame
    rootPart.AssemblyLinearVelocity = nan_vector
    rootPart.AssemblyAngularVelocity = nan_vector
    pcall(function()
        sethiddenproperty(rootPart, "PhysicsRepRootPart", targetRoot)
    end)
    return nil
end,
        ["PhysicsRepFling"] = function(rootPart, power, dir)
        if not sethiddenproperty then
            warn("sethiddenproperty not available!")
            return nil
        end
        
        local targetRoot = nil
        for _, player in pairs(SelectedTargets) do
            if player and player.Character then
                local tr = player.Character:FindFirstChild("HumanoidRootPart")
                if tr then targetRoot = tr break end
            end
        end
        
        if not targetRoot then
            return nil
        end
        
        pcall(function()
            sethiddenproperty(rootPart, "PhysicsRepRootPart", targetRoot)
        end)
        
        rootPart.CFrame = targetRoot.CFrame
        rootPart.Velocity = Vector3.new(9e9, 9e9, 9e9)
        rootPart.RotVelocity = Vector3.new(9e9, 9e9, 9e9)
        
        return nil
    end,
["FlingNEW"] = function(rootPart, power, dir)
    local bodies = {}
    
    local targetRoot = nil
    for _, player in pairs(SelectedTargets) do
        if player and player.Character then
            local tr = player.Character:FindFirstChild("HumanoidRootPart")
            if tr then targetRoot = tr break end
        end
    end
    if not targetRoot then return nil end
    
    pcall(function()
        sethiddenproperty(rootPart, "PhysicsRepRootPart", targetRoot)
        sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
    end)
    
    for i = 1, 100 do
        local bv = Instance.new("BodyVelocity")
        bv.Parent = rootPart
        local nan = 0/0
        bv.Velocity = Vector3.new(nan, nan, nan)
        bv.MaxForce = Vector3.new(9e30, 9e30, 9e30)
        table.insert(bodies, bv)
        game:GetService("Debris"):AddItem(bv, 0.05 + (i * 0.001))
    end
    
    return bodies
end,
	["RocketFling"] = function(rootPart, power, dir)
    local rp = Instance.new("RocketPropulsion")
    rp.Parent = rootPart
    
    local targetPart = Instance.new("Part")
    targetPart.Position = rootPart.Position + dir * 100
    targetPart.Anchored = true
    targetPart.CanCollide = false
    targetPart.Parent = workspace
    rp.Target = targetPart
    
    rp.MaxThrust = power * 1000
    rp.ThrustP = 1e5
    rp.ThrustD = math.huge
    
    rp:Fire()
    
    game:GetService("Debris"):AddItem(rp, 0.5)
    game:GetService("Debris"):AddItem(targetPart, 0.5)
    
    return rp
end,
["TorqueFling"] = function(rootPart, power, dir)
    local torque = Instance.new("Torque")
    torque.Parent = rootPart
    torque.Torque = Vector3.new(power * 10000, power * 10000, power * 10000)
    
    game:GetService("Debris"):AddItem(torque, 0.5)
    return torque
end,
["ImpulseFling1"] = function(rootPart, power, dir)
    local bodies = {}
    for i = 1, 100 do
        local bv = Instance.new("BodyVelocity")
        bv.Parent = rootPart
        bv.Velocity = Vector3.new(9e9, 9e9, 9e9)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        table.insert(bodies, bv)
        game:GetService("Debris"):AddItem(bv, 0.05)
    end
    return bodies
end,
["ImpulseFling2"] = function(rootPart, power, dir)
    local bodies = {}
    
    for i = 1, 100 do
        local bv = Instance.new("BodyVelocity")
        bv.Parent = rootPart
        bv.Velocity = dir * power * 9e9
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        table.insert(bodies, bv)
        game:GetService("Debris"):AddItem(bv, 0.05 + (i * 0.001))
    end
    
    for i = 1, 100 do
        local bf = Instance.new("BodyForce")
        bf.Parent = rootPart
        bf.Force = dir * power * 9e9
        table.insert(bodies, bf)
        game:GetService("Debris"):AddItem(bf, 0.1 + (i * 0.01))
    end
    
    for i = 1, 100 do
        local bt = Instance.new("BodyThrust")
        bt.Parent = rootPart
        bt.Force = dir * power * 9e9
        bt.Location = rootPart.Position + Vector3.new(0, 1, 0) * i
        table.insert(bodies, bt)
        game:GetService("Debris"):AddItem(bt, 0.1 + (i * 0.01))
    end
    
    for i = 1, 100 do
        local gyro = Instance.new("BodyGyro")
        gyro.Parent = rootPart
        gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        gyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(1, 1, 1) * i)
        table.insert(bodies, gyro)
        game:GetService("Debris"):AddItem(gyro, 0.1 + (i * 0.01))
    end
    
    for i = 1, 100 do
        local bp = Instance.new("BodyPosition")
        bp.Parent = rootPart
        bp.Position = rootPart.Position + dir * 9e9 * i
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        table.insert(bodies, bp)
        game:GetService("Debris"):AddItem(bp, 0.1 + (i * 0.01))
    end
    
    return bodies
end,
["AlignPositionFling"] = function(rootPart, power, dir)
    local align = Instance.new("AlignPosition")
    align.Parent = rootPart
    
    local att = Instance.new("Attachment")
    att.Parent = rootPart
    align.Attachment0 = att
    
    local targetPart = Instance.new("Part")
    targetPart.Position = rootPart.Position + dir * 100
    targetPart.Anchored = true
    targetPart.CanCollide = false
    targetPart.Parent = workspace
    
    local att2 = Instance.new("Attachment")
    att2.Parent = targetPart
    align.Attachment1 = att2
    
    align.RigidityEnabled = false
    align.MaxForce = power * 10000
    
    game:GetService("Debris"):AddItem(align, 0.5)
    game:GetService("Debris"):AddItem(targetPart, 0.5)
    return align
end,
}

local currentMethod = "BodyVelocity"
local methodList = {"BodyVelocity", "FlingNEW", "BodyThrust", "BodyForce", "VectorForce", "LinearVelocity","ExplodeFling","RocketFling","TorqueFling","ImpulseFling1","ImpulseFling2","AlignPositionFling","PhysicsRepFling","NaNFling"}
local methodIndex = 1
MethodButton.MouseButton1Click:Connect(function()
    methodIndex = methodIndex % #methodList + 1
    currentMethod = methodList[methodIndex]
    MethodButton.Text = "Method: " .. currentMethod
end)

local function SkidFling(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    
    if not Character or not Humanoid or not RootPart then return end
    
    if RootPart.Velocity.Magnitude < 50 then
        getgenv().OldPos = RootPart.CFrame
    end
    
    if THumanoid and THumanoid.Sit then
        return Message("Error", TargetPlayer.Name .. " is sitting", 2)
    end
    
    if THead then
        --workspace.CurrentCamera.CameraSubject = THead
    elseif Handle then
        --workspace.CurrentCamera.CameraSubject = Handle
    elseif THumanoid and TRootPart then
        --workspace.CurrentCamera.CameraSubject = THumanoid
    end
    
    if not TCharacter:FindFirstChildWhichIsA("BasePart") then
        return
    end
    
    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        RootPart.Velocity = Vector3.new(9e9, 9e9, 9e9)
        RootPart.RotVelocity = Vector3.new(9e9, 9e9, 9e9)
    end
    
    local SFBasePart = function(BasePart)
    local startTime = tick()
    local angle = 0
    local moveDir = THumanoid.MoveDirection
    local speed = THumanoid.WalkSpeed

    repeat
        if not RootPart or not THumanoid or not BasePart or not BasePart.Parent then break end

        local velMag = BasePart.Velocity.Magnitude
        local posOffset = CFrame.new(0, 1.5, 0) + moveDir * (velMag / 1.25)
        local negOffset = CFrame.new(0, -1.5, 0) + moveDir * (velMag / 1.25)

        if velMag < 50 then
            angle = angle + 100
            local ang = CFrame.Angles(math.rad(angle), 0, 0)
            
            FPos(BasePart, posOffset, ang)
            task.wait()
            FPos(BasePart, negOffset, ang)
            task.wait()
            FPos(BasePart, posOffset, ang)
            task.wait()
            FPos(BasePart, negOffset, ang)
            task.wait()
            FPos(BasePart, CFrame.new(0, 1.5, 0) + moveDir, ang)
            task.wait()
            FPos(BasePart, CFrame.new(0, -1.5, 0) + moveDir, ang)
            task.wait()
        else
            local high = CFrame.Angles(math.rad(90), 0, 0)
            local zero = CFrame.new()
            
            FPos(BasePart, CFrame.new(0, 1.5, speed), high)
            task.wait()
            FPos(BasePart, CFrame.new(0, -1.5, -speed), zero)
            task.wait()
            FPos(BasePart, CFrame.new(0, 1.5, speed), high)
            task.wait()
            FPos(BasePart, CFrame.new(0, -1.5, 0), high)
            task.wait()
            FPos(BasePart, CFrame.new(0, -1.5, 0), zero)
            task.wait()
            FPos(BasePart, CFrame.new(0, -1.5, 0), high)
            task.wait()
            FPos(BasePart, CFrame.new(0, -1.5, 0), zero)
            task.wait()
        end
    until tick() - startTime >= 2 or not FlingActive
end
    
    workspace.FallenPartsDestroyHeight = 0/0
    
    local dir = Vector3.new(0, 1, 0)
    local power = 10
    local body = FlingMethods[currentMethod](RootPart, power, dir)
    
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    
    if TRootPart then
        SFBasePart(TRootPart)
    elseif THead then
        SFBasePart(THead)
    elseif Handle then
        SFBasePart(Handle)
    else
        return Message("Error", TargetPlayer.Name .. " has no valid parts", 2)
    end
    
	local body = FlingMethods[currentMethod](RootPart, power, dir)
	if type(body) == "table" then
    	for _, obj in ipairs(body) do
    	    if obj and obj.Destroy then
    	        obj:Destroy()
    	    end
    	end
	elseif body and body.Destroy then
    	body:Destroy()
	end
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    --workspace.CurrentCamera.CameraSubject = Humanoid
    
    if getgenv().OldPos then
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                end
            end
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end
end

local function StartFling()
    if FlingActive then return end
    
    local count = CountSelectedTargets()
    if count == 0 then
        StatusLabel.Text = "No targets selected!"
        wait(1)
        StatusLabel.Text = "Select targets to fling"
        return
    end
    
    FlingActive = true
    UpdateStatus()
    Message("Started", "Flinging " .. count .. " targets", 2)
    
    spawn(function()
        while FlingActive do
            local validTargets = {}
            
            for name, player in pairs(SelectedTargets) do
                if player and player.Parent then
                    validTargets[name] = player
                else
                    SelectedTargets[name] = nil
                    local checkbox = PlayerCheckboxes[name]
                    if checkbox then
                        checkbox.Checkmark.Visible = false
                    end
                end
            end
            
            for _, player in pairs(validTargets) do
                if FlingActive then
                    SkidFling(player)
                    wait(0.1)
                else
                    break
                end
            end
            
            UpdateStatus()
            
            wait(0.5)
        end
    end)
end

local function StopFling()
    if not FlingActive then return end
    
    FlingActive = false
    
    local character = Player.Character
    if character then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyThrust") or 
               v:IsA("LinearVelocity") or v:IsA("VectorForce") or v:IsA("RocketPropulsion") or
               v:IsA("AlignPosition") or v:IsA("Torque") then
                v:Destroy()
            end
        end
        
        pcall(function()
            sethiddenproperty(character.HumanoidRootPart, "PhysicsRepRootPart", character.HumanoidRootPart)
        end)
    end
    
    UpdateStatus()
    Message("Stopped", "Fling has been stopped", 2)
end

StartButton.MouseButton1Click:Connect(StartFling)
StopButton.MouseButton1Click:Connect(StopFling)
SelectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(true) end)
DeselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end)
CloseButton.MouseButton1Click:Connect(function()
    StopFling()
    ScreenGui:Destroy()
end)

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
    if SelectedTargets[player.Name] then
        SelectedTargets[player.Name] = nil
    end
    RefreshPlayerList()
    UpdateStatus()
end)

RefreshPlayerList()
UpdateStatus()
