-- gui.lua - MATRIX PANEL v1.0
-- ملف الواجهة والبانل

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- الإعدادات
local Settings = {
    Aimbot = false,
    ESP = false,
    SpeedHack = false,
    NoClip = false,
    WalkSpeed = 50,
}

-- المتغيرات
local GUI = {}
local ESPObjects = {}
local Connections = {}
local targetInfo = nil
local lastMousePos = Vector2.new(0, 0)
local mouseMoved = false

local function safe(f) pcall(f) end

-- كشف حركة الماوس
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local newPos = Vector2.new(input.Position.X, input.Position.Y)
        if (newPos - lastMousePos).Magnitude > 2 then mouseMoved = true end
        lastMousePos = newPos
    end
end)

-- ==================== إيم بوت ====================
local function startAimbot()
    if Connections.Aim then Connections.Aim:Disconnect() end
    Connections.Aim = RunService.RenderStepped:Connect(function()
        if not Settings.Aimbot then return end
        if mouseMoved then targetInfo = nil mouseMoved = false return end
        
        safe(function()
            if targetInfo and targetInfo.Player.Character then
                local hum = targetInfo.Player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local head = targetInfo.Player.Character:FindFirstChild("Head")
                    if head then
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        if onScreen and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 300 then
                            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, head.Position), 0.2)
                            return
                        end
                    end
                end
            end
            
            local best, bestDist = nil, 999
            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local char = LocalPlayer.Character
            if not char then return end
            
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local head = plr.Character:FindFirstChild("Head")
                        if head then
                            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                                if dist < 200 and dist < bestDist then
                                    bestDist = dist
                                    best = {Part = head, Player = plr}
                                end
                            end
                        end
                    end
                end
            end
            targetInfo = best
        end)
    end)
end

-- ==================== ESP ====================
local function createESP(player)
    safe(function()
        local char = player.Character
        if not char then return end
        
        for i, obj in ipairs(ESPObjects) do
            if obj.Player == player then
                if obj.Line then obj.Line:Remove() end
                if obj.Highlight then obj.Highlight:Destroy() end
                table.remove(ESPObjects, i)
                break
            end
        end
        
        local line = Drawing.new("Line")
        line.Visible = true
        line.Color = Color3.fromRGB(0, 255, 0)
        line.Thickness = 2
        line.Transparency = 0.6
        
        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0.2
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
        highlight.Parent = char
        
        table.insert(ESPObjects, {Player = player, Line = line, Highlight = highlight})
    end)
end

local function updateESP()
    for _, obj in ipairs(ESPObjects) do
        safe(function()
            local char = obj.Player.Character
            if not char then obj.Line.Visible = false return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then obj.Line.Visible = false return end
            
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if onScreen and hum and hum.Health > 0 then
                obj.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                obj.Line.To = Vector2.new(pos.X, pos.Y)
                obj.Line.Visible = true
            else
                obj.Line.Visible = false
            end
        end)
    end
end

local function startESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then createESP(plr) end
    end
    Players.PlayerAdded:Connect(function(plr) if Settings.ESP then createESP(plr) end end)
    Players.PlayerRemoving:Connect(function(plr)
        for i, obj in ipairs(ESPObjects) do
            if obj.Player == plr then
                if obj.Line then obj.Line:Remove() end
                if obj.Highlight then obj.Highlight:Destroy() end
                table.remove(ESPObjects, i) break
            end
        end
    end)
    if Connections.ESP then Connections.ESP:Disconnect() end
    Connections.ESP = RunService.RenderStepped:Connect(function() if Settings.ESP then updateESP() end end)
end

local function clearAllESP()
    for _, obj in ipairs(ESPObjects) do
        if obj.Line then obj.Line:Remove() end
        if obj.Highlight then obj.Highlight:Destroy() end
    end
    ESPObjects = {}
end

-- ==================== سبيد هاك ====================
local function setSpeed(speed)
    safe(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speed end
        end
    end)
end

-- ==================== NoClip ====================
local function startNoClip()
    if Connections.NoClip then Connections.NoClip:Disconnect() end
    Connections.NoClip = RunService.Stepped:Connect(function()
        if not Settings.NoClip then return end
        safe(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end)
end

-- ==================== واجهة المستخدم ====================
local function createGUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "MATRIX"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    -- زر الفتح
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 70, 0, 28)
    openBtn.Position = UDim2.new(0.5, -35, 0, 10)
    openBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    openBtn.BackgroundTransparency = 0.3
    openBtn.Text = "MATRIX"
    openBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    openBtn.Font = Enum.Font.SourceSansBold
    openBtn.TextSize = 12
    openBtn.BorderSizePixel = 3
    openBtn.BorderColor3 = Color3.fromRGB(0, 255, 0)
    openBtn.ZIndex = 10
    openBtn.Parent = gui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 6)

    -- البانل الرئيسي
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 240)
    frame.Position = UDim2.new(0.5, -110, 0.5, -120)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    frame.Visible = true
    frame.ZIndex = 5
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    -- عنوان
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    title.BackgroundTransparency = 0.3
    title.BorderSizePixel = 0
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

    local titleText = Instance.new("TextLabel")
    titleText.Text = "MATRIX PANEL"
    titleText.Size = UDim2.new(1, -30, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 13
    titleText.TextXAlignment = Enum.TextXAlignment.Center
    titleText.Parent = title

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = title
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 12)

    -- دالة زر
    local function makeButton(text, y, parent)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(0, 195, 0, 34)
        btn.Position = UDim2.new(0.5, -97, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = 0.4
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 12
        btn.BorderSizePixel = 4
        btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        btn.AutoButtonColor = false
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end

    local function updateBtn(btn, state)
        if state then
            btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
            btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    -- أزرار
    local aimBtn = makeButton("AIMBOT: OFF", 38, frame)
    local espBtn = makeButton("ESP: OFF", 78, frame)
    local speedBtn = makeButton("SPEED: OFF", 118, frame)
    local noclipBtn = makeButton("NO CLIP: OFF", 158, frame)
    local exitBtn = makeButton("EXIT", 198, frame)

    -- وظائف
    aimBtn.MouseButton1Click:Connect(function()
        Settings.Aimbot = not Settings.Aimbot
        aimBtn.Text = "AIMBOT: " .. (Settings.Aimbot and "ON" or "OFF")
        updateBtn(aimBtn, Settings.Aimbot)
        if Settings.Aimbot then startAimbot() else if Connections.Aim then Connections.Aim:Disconnect() end end
    end)

    espBtn.MouseButton1Click:Connect(function()
        Settings.ESP = not Settings.ESP
        espBtn.Text = "ESP: " .. (Settings.ESP and "ON" or "OFF")
        updateBtn(espBtn, Settings.ESP)
        if Settings.ESP then startESP() else clearAllESP() if Connections.ESP then Connections.ESP:Disconnect() end end
    end)

    speedBtn.MouseButton1Click:Connect(function()
        Settings.SpeedHack = not Settings.SpeedHack
        speedBtn.Text = "SPEED: " .. (Settings.SpeedHack and "ON" or "OFF")
        updateBtn(speedBtn, Settings.SpeedHack)
        setSpeed(Settings.SpeedHack and Settings.WalkSpeed or 16)
    end)

    noclipBtn.MouseButton1Click:Connect(function()
        Settings.NoClip = not Settings.NoClip
        noclipBtn.Text = "NO CLIP: " .. (Settings.NoClip and "ON" or "OFF")
        updateBtn(noclipBtn, Settings.NoClip)
        if Settings.NoClip then startNoClip() else if Connections.NoClip then Connections.NoClip:Disconnect() end end
    end)

    exitBtn.MouseButton1Click:Connect(function()
        Settings.Aimbot = false
        Settings.ESP = false
        Settings.SpeedHack = false
        Settings.NoClip = false
        setSpeed(16)
        clearAllESP()
        for _, conn in pairs(Connections) do conn:Disconnect() end
        gui:Destroy()
    end)

    closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)
    openBtn.MouseButton1Click:Connect(function() frame.Visible = true end)

    -- مفتاح M
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.M then
            frame.Visible = not frame.Visible
        end
    end)

    -- سحب
    local function makeDraggable(dragObj, moveObj)
        local dragging, startInput, startPos = false, nil, nil
        dragObj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, startInput, startPos = true, input.Position, moveObj.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - startInput
                moveObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    makeDraggable(title, frame)
    makeDraggable(openBtn, openBtn)

    -- حفظ المتغيرات
    GUI.Settings = Settings
    GUI.ESPObjects = ESPObjects
    GUI.Connections = Connections
end

-- بدء الواجهة
createGUI()

return GUI
