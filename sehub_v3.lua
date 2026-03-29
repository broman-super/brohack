--// SeHub V3 - Stealth Minimalist (Ultimate PC Edition)
--// Focus: Undetected, Humanized, & Live Update
--// Keybind: J | Command: .refresh & .rejoin

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local cam = workspace.CurrentCamera

--// [PENTING] Ganti link di bawah dengan link RAW GitHub milik lu!
local SCRIPT_URL = "https://raw.githubusercontent.com/UsernameLu/RepoLu/main/script.lua"

--// Cleanup System (Agar script tidak menumpuk saat di-refresh)
if _G.SeHubConnection then _G.SeHubConnection:Disconnect() end
if lp.PlayerGui:FindFirstChild("SeHubStealth") then lp.PlayerGui.SeHubStealth:Destroy() end

--========================
-- STEALTH SETTINGS
--========================
local settings = {
    aimbot = false,
    noclip = false,
    infJump = false,
    antiAFK = false,
    autoRejoin = false,
    fov = 100,
    smoothing = 0.15, -- Pergerakan halus agar tidak terdeteksi sistem
}

--========================
-- LIVE UPDATE & COMMANDS (.)
--========================
lp.Chatted:Connect(function(msg)
    if msg:lower() == ".refresh" then
        print("[SeHub] Downloading latest version...")
        if lp.PlayerGui:FindFirstChild("SeHubStealth") then lp.PlayerGui.SeHubStealth:Destroy() end
        pcall(function() loadstring(game:HttpGet(SCRIPT_URL))() end)
    elseif msg:lower() == ".rejoin" then
        TeleportService:Teleport(game.PlaceId, lp)
    end
end)

--========================
-- CORE LOGIC (STEALTH)
--========================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Radius = settings.fov
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.2

-- Auto Rejoin Logic
CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if settings.autoRejoin and child.Name == "ErrorPrompt" then
        TeleportService:Teleport(game.PlaceId, lp)
    end
end)

-- Anti AFK Logic (Simulasi rotasi kamera tipis)
task.spawn(function()
    while task.wait(60) do
        if settings.antiAFK then
            cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
            task.wait(0.1)
            cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(-0.01), 0)
        end
    end
end)

-- Aimbot Target Finder
local function getTarget()
    local target = nil
    local dist = settings.fov
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = cam:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local mDist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mDist < dist then target = v.Character.Head dist = mDist end
            end
        end
    end
    return target
end

-- Render Loop
_G.SeHubConnection = RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)
    
    -- Humanized Aim (Pake Lerp biar gak snap/kaku)
    if settings.aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getTarget()
        if target then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), settings.smoothing)
        end
    end

    -- Stealth Noclip
    if settings.noclip and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Safe Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if settings.infJump and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--========================
-- MINIMALIST UI BUILDER
--========================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "SeHubStealth"
gui.IgnoreGuiInset = true

local window = Instance.new("Frame", gui)
window.Size = UDim2.fromOffset(350, 300)
window.Position = UDim2.fromScale(0.5, 0.5)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- Hitam pekat
window.BackgroundTransparency = 0.15
window.BorderSizePixel = 0

local stroke = Instance.new("UIStroke", window)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1
stroke.Transparency = 0.9

local layout = Instance.new("UIListLayout", window)
layout.Padding = UDim.new(0, 2)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local title = Instance.new("TextLabel", window)
title.Text = "SYSTEM // STEALTH_OS_V3"
title.Size = UDim2.new(1, 0, 0, 40)
title.Font = Enum.Font.Code
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.BackgroundTransparency = 1

local function addToggle(text, key)
    local btn = Instance.new("TextButton", window)
    btn.Text = "> " .. text .. ": OFF"
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Font = Enum.Font.Code
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.BackgroundTransparency = 1
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    btn.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        btn.Text = settings[key] and "> " .. text .. ": ON" or "> " .. text .. ": OFF"
        btn.TextColor3 = settings[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        if key == "aimbot" then FOVCircle.Visible = settings[key] end
    end)
end

-- List Fitur
addToggle("HUMAN_AIMBOT", "aimbot")
addToggle("STEALTH_NOCLIP", "noclip")
addToggle("INFINITE_JUMP", "infJump")
addToggle("ANTI_AFK_MODE", "antiAFK")
addToggle("AUTO_REJOIN", "autoRejoin")

-- Dragging & Toggle J
local dragging, dragStart, startPos
window.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = window.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == Enum.KeyCode.J then window.Visible = not window.Visible end end)

print("SeHub V3 Loaded. Commands: .refresh | .rejoin")
