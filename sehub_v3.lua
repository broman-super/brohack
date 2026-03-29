--// SeHub V3 - Minimalist Original Edition
--// Focus: Original Structure, Auto-Save Waypoints, Stealth Logic
--// Keybind: J | Command: .refresh

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local cam = workspace.CurrentCamera

--// CONFIG & FILE SYSTEM
local WP_FILE = "SeHub_Waypoints.json"
local SCRIPT_URL = "https://raw.githubusercontent.com/Username/Repo/main/script.lua"
local savedWaypoints = {}

local function SaveWaypoints()
    if writefile then
        local data = {}
        for _, wp in pairs(savedWaypoints) do
            table.insert(data, {Name = wp.Name, CFArray = {wp.CFrame:GetComponents()}})
        end
        pcall(function() writefile(WP_FILE, HttpService:JSONEncode(data)) end)
    end
end

local function LoadWaypoints()
    if isfile and isfile(WP_FILE) then
        local s, r = pcall(function() return HttpService:JSONDecode(readfile(WP_FILE)) end)
        if s then 
            for _, v in pairs(r) do
                table.insert(savedWaypoints, {Name = v.Name, CFrame = CFrame.new(unpack(v.CFArray))})
            end
        end
    end
end
LoadWaypoints()

--// CLEANUP
if _G.SeHubConnection then _G.SeHubConnection:Disconnect() end
if lp.PlayerGui:FindFirstChild("SeHubV3") then lp.PlayerGui.SeHubV3:Destroy() end

--// SETTINGS
local settings = {
    aimbot = false, noclip = false, infJump = false, 
    antiAFK = false, smoothing = 0.15, fov = 100
}

--========================
-- CORE LOGIC (STEALTH)
--========================
_G.SeHubConnection = RunService.RenderStepped:Connect(function()
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
        if target then cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), settings.smoothing) end
    end
    if settings.noclip and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if settings.infJump and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--========================
-- UI BUILDER (ORIGINAL LAYOUT)
--========================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "SeHubV3"
gui.IgnoreGuiInset = true

local window = Instance.new("Frame", gui)
window.Size = UDim2.fromOffset(500, 320)
window.Position = UDim2.fromScale(0.5, 0.5)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
window.BackgroundTransparency = 0.15
Instance.new("UIStroke", window).Color = Color3.fromRGB(255, 255, 255)

-- Sidebar
local sidebar = Instance.new("Frame", window)
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.BackgroundTransparency = 1
local sLayout = Instance.new("UIListLayout", sidebar)
sLayout.Padding = UDim.new(0, 2)

-- Content Area
local mainContent = Instance.new("Frame", window)
mainContent.Position = UDim2.fromOffset(125, 10)
mainContent.Size = UDim2.new(1, -135, 1, -20)
mainContent.BackgroundTransparency = 1

-- UI Helpers
local function createTabBtn(name, page)
    local btn = Instance.new("TextButton", sidebar)
    btn.Text = "[ " .. name .. " ]"
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Font = Enum.Font.Code
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundTransparency = 1
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(mainContent:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        page.Visible = true
    end)
end

local function createPage()
    local p = Instance.new("ScrollingFrame", mainContent)
    p.Size = UDim2.fromScale(1, 1)
    p.BackgroundTransparency = 1
    p.CanvasSize = UDim2.new(0,0,0,0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.ScrollBarThickness = 2
    p.Visible = false
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 5)
    return p
end

--========================
-- TABS & FEATURES
--========================
local pCombat = createPage()
local pWaypoints = createPage()

createTabBtn("COMBAT", pCombat)
createTabBtn("WAYPOINTS", pWaypoints)

-- Combat Features
local function addToggle(parent, text, key)
    local b = Instance.new("TextButton", parent)
    b.Text = "> " .. text .. ": OFF"
    b.Size = UDim2.new(1, 0, 0, 25)
    b.Font = Enum.Font.Code
    b.TextColor3 = Color3.fromRGB(150, 150, 150)
    b.BackgroundTransparency = 1
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        b.Text = settings[key] and "> " .. text .. ": ON" or "> " .. text .. ": OFF"
        b.TextColor3 = settings[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    end)
end

addToggle(pCombat, "SMOOTH_AIM", "aimbot")
addToggle(pCombat, "NOCLIP", "noclip")
addToggle(pCombat, "INF_JUMP", "infJump")

-- Waypoint Logic (Original Style)
local wpInput = Instance.new("TextBox", pWaypoints)
wpInput.Size = UDim2.new(1, 0, 0, 30)
wpInput.PlaceholderText = "Waypoint Name..."
wpInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
wpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
wpInput.Font = Enum.Font.Code

local addWp = Instance.new("TextButton", pWaypoints)
addWp.Text = "[ + SAVE LOCATION ]"
addWp.Size = UDim2.new(1, 0, 0, 30)
addWp.TextColor3 = Color3.fromRGB(0, 255, 100)
addWp.BackgroundTransparency = 1
addWp.Font = Enum.Font.Code

addWp.MouseButton1Click:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local name = wpInput.Text ~= "" and wpInput.Text or "Point " .. (#savedWaypoints + 1)
        table.insert(savedWaypoints, {Name = name, CFrame = lp.Character.HumanoidRootPart.CFrame})
        SaveWaypoints()
        wpInput.Text = ""
        -- Anda bisa menambahkan logika refresh list di sini
    end
end)

--========================
-- COMMANDS & DRAG
--========================
lp.Chatted:Connect(function(msg)
    if msg == ".refresh" then pcall(function() loadstring(game:HttpGet(SCRIPT_URL))() end) end
end)

local dragging, dragStart, startPos
window.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = window.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == Enum.KeyCode.J then window.Visible = not window.Visible end end)

pCombat.Visible = true
print("SeHub V3 Loaded. Prefix: [.]")
