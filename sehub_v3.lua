--// SeHub V3 - Stealth Minimalist (.dot Update Edition)
--// Focus: Undetected, Live Refresh, & Dot Commands
--// Keybind: J | Command: .refresh

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local cam = workspace.CurrentCamera

--// URL Script (Ganti dengan link raw GitHub/Pastebin Anda)
local SCRIPT_URL = "https://raw.githubusercontent.com/Username/Repo/main/script.lua"

--// Cleanup Fungsi (Penting agar tidak tumpang tindih)
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
    smoothing = 0.15,
}

--========================
-- DOT COMMANDS SYSTEM
--========================
lp.Chatted:Connect(function(msg)
    -- Menggunakan awalan titik [.]
    if msg:lower() == ".refresh" then
        print("[SeHub] Update Signal Received. Downloading latest version...")
        if lp.PlayerGui:FindFirstChild("SeHubStealth") then 
            lp.PlayerGui.SeHubStealth:Destroy() 
        end
        pcall(function()
            loadstring(game:HttpGet(SCRIPT_URL))()
        end)
    elseif msg:lower() == ".rejoin" then
        print("[SeHub] Rejoining server...")
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

_G.SeHubConnection = RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)
    
    if settings.aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil
        local dist = settings.fov
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                local pos, onScreen = cam:WorldToViewportPoint(v.Character.Head.Position)
                if onScreen then
                    local mDist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mDist < dist then target = v.Character.Head dist = mDist end
                end
            end
        end
        if target then
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), settings.smoothing)
        end
    end

    if settings.noclip and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

--========================
-- MINIMALIST UI (BLACK)
--========================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "SeHubStealth"
gui.IgnoreGuiInset = true

local window = Instance.new("Frame", gui)
window.Size = UDim2.fromOffset(350, 280)
window.Position = UDim2.fromScale(0.5, 0.5)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
window.BackgroundTransparency = 0.15
window.BorderSizePixel = 0

local function addToggle(text, key)
    local btn = Instance.new("TextButton", window)
    btn.Text = "> " .. text .. ": OFF"
    btn.Size = UDim2.new(0.9, 0, 0, 28)
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

local layout = Instance.new("UIListLayout", window)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
addToggle("HUMAN_AIM", "aimbot")
addToggle("GHOST_COLLISION", "noclip")
addToggle("AUTO_REJOIN", "autoRejoin")
addToggle("ANTI_AFK", "antiAFK")

--========================
-- DRAGGING LOGIC
--========================
local dragging, dragStart, startPos
window.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = window.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == Enum.KeyCode.J then window.Visible = not window.Visible end end)

print("SeHub V3 Loaded. Prefix set to [.]")
