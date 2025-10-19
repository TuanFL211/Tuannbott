-- Script Fix Lag by TUANN_FL
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Hiển thị thông báo khi bắt đầu
print("TUANN_FL DÒNG TIN NHẮN DƯỚI: ĐANG LOAD SCRIPT FIXLAG TUANN")

-- Tạo ScreenGui chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TUANN_FL_FixLag"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Tạo hiệu ứng loading
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
LoadingFrame.BackgroundTransparency = 0.3
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ScreenGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 50)
LoadingText.Position = UDim2.new(0, 0, 0.5, -25)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "TUANN_FL DÒNG TIN NHẮN DƯỚI: ĐANG LOAD SCRIPT FIXLAG TUANN"
LoadingText.TextColor3 = Color3.new(1, 1, 1)
LoadingText.TextScaled = true
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Parent = LoadingFrame

-- Đợi 5 giây
wait(5)

-- Ẩn loading và hiện GUI chính
LoadingFrame.Visible = false

-- Tạo GUI chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Hiệu ứng bo góc
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.05, 0)
UICorner.Parent = MainFrame

-- Hiệu ứng đổ bóng
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(100, 100, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.15, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
Title.BackgroundTransparency = 0.2
Title.Text = "TUANN_FL FIX LAG"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 0)
TitleCorner.Parent = Title

-- Hiển thị FPS
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
FPSLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: 0"
FPSLabel.TextColor3 = Color3.new(1, 1, 1)
FPSLabel.TextScaled = true
FPSLabel.Font = Enum.Font.Gotham
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Parent = MainFrame

-- Nút Fix Lag
local FixLagButton = Instance.new("TextButton")
FixLagButton.Size = UDim2.new(0.9, 0, 0.2, 0)
FixLagButton.Position = UDim2.new(0.05, 0, 0.35, 0)
FixLagButton.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
FixLagButton.Text = "FIX LAG"
FixLagButton.TextColor3 = Color3.new(1, 1, 1)
FixLagButton.TextScaled = true
FixLagButton.Font = Enum.Font.GothamBold
FixLagButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0.1, 0)
ButtonCorner.Parent = FixLagButton

-- Hiệu ứng hover cho nút
FixLagButton.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(FixLagButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 90, 160)}):Play()
end)

FixLagButton.MouseLeave:Connect(function()
    game:GetService("TweenService"):Create(FixLagButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 120)}):Play()
end)

-- Hiệu ứng click cho nút
FixLagButton.MouseButton1Down:Connect(function()
    game:GetService("TweenService"):Create(FixLagButton, TweenInfo.new(0.1), {Size = UDim2.new(0.85, 0, 0.19, 0)}):Play()
end)

FixLagButton.MouseButton1Up:Connect(function()
    game:GetService("TweenService"):Create(FixLagButton, TweenInfo.new(0.1), {Size = UDim2.new(0.9, 0, 0.2, 0)}):Play()
end)

-- Thông tin trạng thái
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.3, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: Chưa fix lag"
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Parent = MainFrame

-- Hiệu ứng mở GUI
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
game:GetService("TweenService"):Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0.8, 0, 0.6, 0),
    Position = UDim2.new(0.1, 0, 0.2, 0)
}):Play()

-- Hàm tính FPS
local RunService = game:GetService("RunService")
local lastTime = tick()
local frameCount = 0

local function updateFPS()
    frameCount = frameCount + 1
    local currentTime = tick()
    
    if currentTime - lastTime >= 1 then
        local fps = math.floor(frameCount / (currentTime - lastTime))
        FPSLabel.Text = "FPS: " .. fps
        frameCount = 0
        lastTime = currentTime
    end
end

RunService.Heartbeat:Connect(updateFPS)

-- Hàm fix lag
local function applyFixLag()
    StatusLabel.Text = "Đang áp dụng fix lag..."
    
    -- Chuyển đồ họa thành potato
    settings().Rendering.QualityLevel = 1
    
    -- Tắt hiệu ứng ánh sáng
    game.Lighting.GlobalShadows = false
    game.Lighting.FogEnd = 9e9
    game.Lighting.Brightness = 2
    
    -- Xóa sương mù
    game.Lighting.FogStart = 9e9
    game.Lighting.FogEnd = 9e9
    
    -- Xóa bóng
    for _, obj in pairs(game.Lighting:GetDescendants()) do
        if obj:IsA("ShadowMap") then
            obj:Destroy()
        end
    end
    
    -- Tắt skill âm thanh (giảm volume)
    game:GetService("SoundService").RespectFilteringEnabled = false
    for _, sound in pairs(game:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0.1
        end
    end
    
    -- Xóa lá cây và các hiệu ứng khác
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("Part") then
            part.Material = Enum.Material.Plastic
            part.Reflectance = 0
        end
        
        -- Xóa particle effects
        if part:IsA("ParticleEmitter") or part:IsA("Fire") or part:IsA("Smoke") then
            part.Enabled = false
        end
    end
    
    -- Tối ưu hóa các setting khác
    game:GetService("Workspace").StreamingEnabled = false
    game:GetService("Workspace").Terrain.WaterReflectance = 0
    game:GetService("Workspace").Terrain.WaterTransparency = 1
    game:GetService("Workspace").Terrain.WaterWaveSize = 0
    game:GetService("Workspace").Terrain.WaterWaveSpeed = 0
    
    StatusLabel.Text = "Đã áp dụng fix lag thành công!\n- Đồ họa: Potato\n- Hiệu ứng ánh sáng: Đã tắt\n- Sương mù: Đã xóa\n- Bóng: Đã xóa\n- Âm thanh: Giảm\n- Lá cây: Đã xóa"
end

-- Kết nối sự kiện click nút
FixLagButton.MouseButton1Click:Connect(function()
    applyFixLag()
    
    -- Hiệu ứng khi click
    game:GetService("TweenService"):Create(FixLagButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 150, 50)}):Play()
    wait(0.5)
    game:GetService("TweenService"):Create(FixLagButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 120)}):Play()
end)

-- Thông báo hoàn thành
print("Script Fix Lag TUANN_FL đã được tải thành công!")
