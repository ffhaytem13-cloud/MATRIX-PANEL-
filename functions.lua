-- functions.lua - MATRIX PANEL v1.0
-- ملف الدوال والميزات الإضافية

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Functions = {}
local Connections = {}

local function safe(f) pcall(f) end

-- ==================== بانني هوب ====================
Functions.BHop = false
Functions.BHopPower = 50

function Functions.StartBHop()
    if Connections.BHop then Connections.BHop:Disconnect() end
    
    Connections.BHop = RunService.Heartbeat:Connect(function()
        if not Functions.BHop then return end
        
        safe(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end
            
            local isMoving = UserInputService:IsKeyDown(Enum.KeyCode.W) or 
                            (hum.MoveDirection.Magnitude > 0)
            
            if isMoving then
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {char}
                local ray = Workspace:Raycast(root.Position, Vector3.new(0, -3, 0), rayParams)
                
                if ray then
                    hum.Jump = true
                    hum.JumpPower = Functions.BHopPower
                end
            end
        end)
    end)
end

function Functions.StopBHop()
    Functions.BHop = false
    if Connections.BHop then Connections.BHop:Disconnect() end
    safe(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = 50 end
        end
    end)
end

-- ==================== تيلي بورت ====================
function Functions.TeleportTo(target)
    safe(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        if typeof(target) == "Vector3" then
            root.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
        elseif typeof(target) == "Instance" and target:IsA("BasePart") then
            root.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        end
        return true
    end)
end

-- ==================== تغيير سيرفر ====================
function Functions.ServerHop()
    safe(function()
        local placeId = game.PlaceId
        local cursor = ""
        local bestServer = nil
        local lowestPlayers = math.huge
        
        repeat
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
            
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            
            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if server.playing < server.maxPlayers and server.playing < lowestPlayers then
                        lowestPlayers = server.playing
                        bestServer = server.id
                    end
                end
                cursor = result.nextPageCursor or ""
            else
                break
            end
        until cursor == "" or bestServer
        
        if bestServer then
            TeleportService:TeleportToPlaceInstance(placeId, bestServer, LocalPlayer)
        else
            TeleportService:Teleport(placeId, LocalPlayer)
        end
    end)
end

-- ==================== زر الانضمام لسيرفر ====================
function Functions.RejoinServer()
    safe(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- ==================== إنفنت جمب ====================
Functions.InfiniteJump = false

function Functions.StartInfiniteJump()
    if Connections.InfJump then Connections.InfJump:Disconnect() end
    
    Connections.InfJump = UserInputService.JumpRequest:Connect(function()
        if not Functions.InfiniteJump then return end
        
        safe(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Jump = true
                end
            end
        end)
    end)
end

function Functions.StopInfiniteJump()
    Functions.InfiniteJump = false
    if Connections.InfJump then Connections.InfJump:Disconnect() end
end

-- ==================== جود مود ====================
Functions.GodMode = false

function Functions.StartGodMode()
    if Connections.God then Connections.God:Disconnect() end
    
    Connections.God = RunService.RenderStepped:Connect(function()
        if not Functions.GodMode then return end
        
        safe(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = hum.MaxHealth
                    hum.MaxHealth = math.huge
                end
            end
        end)
    end)
end

function Functions.StopGodMode()
    Functions.GodMode = false
    if Connections.God then Connections.God:Disconnect() end
end

-- ==================== معلومات السيرفر ====================
function Functions.GetServerInfo()
    local info = {
        Players = #Players:GetPlayers(),
        MaxPlayers = Players.MaxPlayers,
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        FPS = 60,
    }
    return info
end

-- ==================== تنظيف ====================
function Functions.Cleanup()
    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
    Connections = {}
end

-- ==================== إرجاع الدوال ====================
return Functions
