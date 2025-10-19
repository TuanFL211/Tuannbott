-- Script Fix Lag by TUANN_FL
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Hiển thị thông báo khi bắt đầu
print("TUANN_FL DÒNG TIN NHẮN DƯỚI: ĐANG LOAD SCRIPT FIXLAG TUANN")

-- Đợi 5 giây
wait(5)

-- Tạo ScreenGui chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TUANN_FL_FixLag"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Tạo GUI chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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
UIStroke.Color = Color3.fromRGB(80, 80, 200)
UIStroke.Thickness = 3
UIStroke.Parent = MainFrame

-- Gradient background
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.15, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
Title.BackgroundTransparency = 0.3
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
FPSLabel.Position = UDim2.new(0.05, 0, 0.18, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: Đang tải..."
FPSLabel.TextColor3 = Color3.new(1, 1, 1)
FPSLabel.TextScaled = true
FPSLabel.Font = Enum.Font.Gotham
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Parent = MainFrame

-- Nút Fix Lag
local FixLagButton = Instance.new("TextButton")
FixLagButton.Size = UDim2.new(0.9, 0, 0.2, 0)
FixLagButton.Position = UDim2.new(0.05, 0, 0.35, 0)
FixLagButton.BackgroundColor3 = Color3.fromRGB(60, 60, 150)
FixLagButton.AutoButtonColor = false
FixLagButton.Text = "🚀 FIX LAG"
FixLagButton.TextColor3 = Color3.new(1, 1, 1)
FixLagButton.TextScaled = true
FixLagButton.Font = Enum.Font.GothamBold
FixLagButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0.1, 0)
ButtonCorner.Parent = FixLagButton

-- Hiệu ứng cho nút
local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 70, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 120))
})
ButtonGradient.Parent = FixLagButton

-- Thông tin trạng thái
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.35, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: Sẵn sàng"
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.TextScaled = false
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Parent = MainFrame

-- Hiệu ứng mở GUI với animation
local TweenService = game:GetService("TweenService")

local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0.85, 0, 0.7, 0)
})
openTween:Play()

-- Hiệu ứng hover cho nút
FixLagButton.MouseEnter:Connect(function()
    TweenService:Create(FixLagButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(80, 80, 200),
        Size = UDim2.new(0.92, 0, 0.21, 0)
    }):Play()
end)

FixLagButton.MouseLeave:Connect(function()
    TweenService:Create(FixLagButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(60, 60, 150),
        Size = UDim2.new(0.9, 0, 0.2, 0)
    }):Play()
end)

-- Hàm tính FPS
local RunService = game:GetService("RunService")
local lastTime = tick()
local frameCount = 0

local function updateFPS()
    frameCount = frameCount + 1
    local currentTime = tick()
    
    if currentTime - lastTime >= 0.5 then
        local fps = math.floor(frameCount / (currentTime - lastTime))
        FPSLabel.Text = "FPS: " .. fps
        frameCount = 0
        lastTime = currentTime
    end
end

-- Hàm fix lag an toàn
local function applyFixLag()
    StatusLabel.Text = "🔄 Đang áp dụng fix lag..."
    
    -- Sử dụng pcall để bắt lỗi
    local success, errorMsg = pcall(function()
        -- Chuyển đồ họa thành potato
        if settings().Rendering then
            settings().Rendering.QualityLevel = 1
        end
        
        -- Tối ưu Lighting
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 2
        Lighting.FogStart = 9e9
        Lighting.ClockTime = 14
        
        -- Xóa sương mù
        Lighting.Atmosphere.Density = 0
        Lighting.Atmosphere.Offset = 0
        Lighting.Atmosphere.Color = Color3.new(1, 1, 1)
        Lighting.Atmosphere.Decay = Color3.new(1, 1, 1)
        Lighting.Atmosphere.Glare = 0
        Lighting.Atmosphere.Haze = 0
        
        -- Tối ưu Terrain
        local Terrain = workspace.Terrain
        if Terrain then
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
        end
        
        -- Tắt các hiệu ứng không cần thiết
        for _, obj in pairs(Lighting:GetDescendants()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") then
                obj.Enabled = false
            end
        end
        
        -- Giảm âm thanh (tránh lỗi authorization)
        game:GetService("SoundService").RespectFilteringEnabled = false
        
        -- Tối ưu workspace
        game:GetService("Workspace").StreamingEnabled = false
        
        -- Tắt particle effects
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("ParticleEmitter") or part:IsA("Fire") or part:IsA("Smoke") then
                part.Enabled = false
            end
            
            -- Đổi material thành Plastic để tối ưu
            if part:IsA("Part") and part.Material ~= Enum.Material.Plastic then
                part.Material = Enum.Material.Plastic
            end
        end
        
        -- Force garbage collection
        wait(0.1)
        game:GetService("GC"):CollectGarbage()
        wait(0.1)
    end)
    
    if success then
        StatusLabel.Text = "✅ Đã áp dụng fix lag thành công!\n\n• Đồ họa: Potato\n• Hiệu ứng ánh sáng: Đã tắt\n• Sương mù: Đã xóa\n• Bóng: Đã xóa\n• Particle: Đã tắt\n• Âm thanh: Tối ưu"
        
        -- Hiệu ứng thành công
        TweenService:Create(FixLagButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        }):Play()
        
        wait(1)
        
        TweenService:Create(FixLagButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 150)
        }):Play()
    else
        StatusLabel.Text = "❌ Có lỗi xảy ra: " .. tostring(errorMsg)
        
        -- Hiệu ứng lỗi
        TweenService:Create(FixLagButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        }):Play()
    end
end

-- Kết nối sự kiện click nút
FixLagButton.MouseButton1Click:Connect(function()
    applyFixLag()
end)

-- Cập nhật FPS liên tục
RunService.Heartbeat:Connect(updateFPS)

-- Nút đóng GUI (tùy chọn)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.1, 0, 0.1, 0)
CloseButton.Position = UDim2.new(0.9, 0, -0.05, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.5, 0)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    wait(0.5)
    ScreenGui:Destroy()
end)

-- Thông báo hoàn thành
print("Script Fix Lag TUANN_FL đã được tải thành công!")
wait(1)
print("GUI đã sẵn sàng - Nhấn FIX LAG để tối ưu hóa!")
