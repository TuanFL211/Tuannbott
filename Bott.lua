-- TUANN_FL FixLag LocalScript - Potato Style
-- LocalScript chạy client, giảm lag, giao diện vuông, nhẹ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== GUI Setup ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TUANN_FL_FixLag_Potato"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Loading label
local loadingFrame = Instance.new("Frame")
loadingFrame.AnchorPoint = Vector2.new(0.5,0.5)
loadingFrame.Size = UDim2.new(0.6,0,0.12,0)
loadingFrame.Position = UDim2.new(0.5,0,0.08,0)
loadingFrame.BackgroundTransparency = 0
loadingFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
loadingFrame.Parent = screenGui

local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(1,0,1,0)
loadingLabel.BackgroundTransparency = 1
loadingLabel.TextColor3 = Color3.fromRGB(255,255,255)
loadingLabel.Font = Enum.Font.SourceSansBold
loadingLabel.TextScaled = true
loadingLabel.Text = "TUANN_FL\nDÒNG TIN NHẮN DƯỚI: ĐANG LOAD SCRIPT FIXLAG TUANN"
loadingLabel.Parent = loadingFrame

-- Main GUI (potato style, vuông, minimal)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
mainFrame.Size = UDim2.new(0,0,0,0)
mainFrame.Position = UDim2.new(0.5,0,0.5,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundColor3 = Color3.fromRGB(70,70,70)
title.BorderSizePixel = 0
title.Text = "TUANN_FL - FixLag"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = mainFrame

-- FixLag Button
local fixBtn = Instance.new("TextButton")
fixBtn.Name = "FixBtn"
fixBtn.Size = UDim2.new(0.6,0,0,40)
fixBtn.Position = UDim2.new(0.2,0,0,50)
fixBtn.BackgroundColor3 = Color3.fromRGB(150,150,150)
fixBtn.Font = Enum.Font.SourceSansBold
fixBtn.TextSize = 16
fixBtn.Text = "FixLag"
fixBtn.TextColor3 = Color3.fromRGB(0,0,0)
fixBtn.Parent = mainFrame

-- FPS Label
local fpsLabel = Instance.new("TextButton")
fpsLabel.Name = "FPSLabel"
fpsLabel.AnchorPoint = Vector2.new(0.5,0)
fpsLabel.Position = UDim2.new(0.5,0,0.5,120)
fpsLabel.Size = UDim2.new(0,100,0,24)
fpsLabel.BackgroundColor3 = Color3.fromRGB(40,40,40)
fpsLabel.BorderSizePixel = 0
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 14
fpsLabel.TextColor3 = Color3.fromRGB(255,255,255)
fpsLabel.Text = "FPS: ..."
fpsLabel.Parent = screenGui

-- ====== Loading + open main GUI ======
spawn(function()
    wait(5)
    loadingFrame.Visible = false
    mainFrame.Visible = true
    TweenService:Create(mainFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,240,0,110)}):Play()
end)

-- ====== FPS Realtime ======
local fps = 0
local smoothing = 0.1
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    local now = tick()
    local dt = now - lastTime
    lastTime = now
    local instant = 1/math.max(dt,1/120)
    fps = fps + (instant - fps)*smoothing
    fpsLabel.Text = "FPS: "..math.floor(fps+0.5)
end)

-- FPS toggle
local minimized = false
fpsLabel.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        fpsLabel.Size = UDim2.new(0,50,0,20)
        fpsLabel.Text = math.floor(fps+0.5)
    else
        fpsLabel.Size = UDim2.new(0,100,0,24)
        fpsLabel.Text = "FPS: "..math.floor(fps+0.5)
    end
end)

-- ====== FixLag Function ======
local fixed = false
local function fixLag()
    if fixed then return end
    fixed = true
    fixBtn.Text = "Đang tối ưu..."
    -- Disable Lighting effects
    for _,v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
            pcall(function() v.Enabled = false end)
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e9
    Lighting.FogStart = 0
    -- Disable particles and trails
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            pcall(function() v.Enabled=false end)
        end
        if v:IsA("BasePart") then
            v.CastShadow = false
            local nameLower = (v.Name or ""):lower()
            if string.find(nameLower,"leaf") or string.find(nameLower,"foliage") then
                v.LocalTransparencyModifier = 1
            end
        end
    end
    -- Mute sounds
    SoundService.Volume = 0
    fixBtn.Text = "Đã tối ưu ✔"
    wait(1.2)
    fixBtn.Text = "FixLag"
end

fixBtn.MouseButton1Click:Connect(fixLag)
