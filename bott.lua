local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Biến trạng thái
local isLowGraphics = false
local isUltraLowGraphics = false
local isGUIVisible = true
local isGUIMinimized = false
local originalGUISize = UDim2.new(0, 320, 0, 250)
local minimizedGUISize = UDim2.new(0, 120, 0, 40)

-- Lưu trữ các giá trị gốc
local originalParts = {}

-- Hàm điều chỉnh đồ họa thấp
local function SetLowGraphics()
    -- Chỉnh chất lượng đồ họa xuống thấp
    settings().Rendering.QualityLevel = 3
    
    -- Xóa sương mù
    Lighting.FogEnd = 1000000
    Lighting.FogStart = 1000000
    
    -- Xóa hiệu ứng ánh sáng
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or 
           effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or 
           effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
    
    -- Giảm chất lượng particle
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Rate = math.min(obj.Rate, 5)
        elseif obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = false
        elseif obj:IsA("Decal") then
            obj.Transparency = 0.7
        end
    end
    
    -- Tắt âm thanh skill
    for _, sound in ipairs(SoundService:GetDescendants()) do
        if sound:IsA("Sound") and sound.Name:match("Skill") then
            sound:Stop()
        end
    end
end

-- Hàm chế độ siêu thấp (đồ họa bùn)
local function SetUltraLowGraphics()
    -- Chất lượng cực thấp
    settings().Rendering.QualityLevel = 1
    
    -- Xóa hoàn toàn sương mù và hiệu ứng
    Lighting.FogEnd = 1000000
    Lighting.FogStart = 1000000
    
    -- Tắt tất cả hiệu ứng
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
    
    -- Biến các khối thành "bùn" (chất liệu đơn giản)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or Player.CharacterAdded:Wait()) then
            -- Lưu giá trị gốc
            if not originalParts[obj] then
                originalParts[obj] = {
                    Material = obj.Material,
                    Color = obj.Color,
                    Transparency = obj.Transparency,
                    Reflectance = obj.Reflectance
                }
            end
            
            -- Biến thành "bùn" - chất liệu đơn giản
            obj.Material = Enum.Material.Plastic
            obj.Color = Color3.fromRGB(101, 67, 33) -- Màu nâu bùn
            obj.Reflectance = 0
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
    end
    
    -- Tắt tất cả âm thanh không cần thiết
    for _, sound in ipairs(SoundService:GetDescendants()) do
        if sound:IsA("Sound") then
            sound:Stop()
        end
    end
end

-- Hàm khôi phục đồ họa
local function RestoreGraphics()
    -- Khôi phục chất lượng đồ họa
    settings().Rendering.QualityLevel = 10
    
    -- Khôi phục sương mù
    Lighting.FogEnd = 1000
    Lighting.FogStart = 0
    
    -- Bật lại hiệu ứng ánh sáng
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = true
        end
    end
    
    -- Khôi phục các khối về trạng thái gốc
    for obj, originalData in pairs(originalParts) do
        if obj and obj.Parent then
            obj.Material = originalData.Material
            obj.Color = originalData.Color
            obj.Transparency = originalData.Transparency
            obj.Reflectance = originalData.Reflectance
        end
    end
    originalParts = {}
    
    -- Bật lại particle và effects
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Enabled = true
        elseif obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = true
        elseif obj:IsA("Decal") then
            obj.Transparency = 0
        end
    end
end

-- Tạo GUI chính với thiết kế đẹp hơn
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "UltraGraphicsControl"
mainGui.ResetOnSpawn = false
mainGui.Parent = PlayerGui

-- Frame chính với gradient và shadow
local mainFrame = Instance.new("Frame")
mainFrame.Size = originalGUISize
mainFrame.Position = UDim2.new(0, 15, 0, 15)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Hiệu ứng bóng đổ
local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(20, 20, 30)
shadow.Thickness = 2
shadow.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

mainFrame.Parent = mainGui

-- Thanh tiêu đề với gradient
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 80))
})
titleGradient.Parent = titleBar

titleBar.Parent = mainFrame

-- Tiêu đề
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0.02, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Text = "GRAPHICS CONTROL"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Container cho các nút điều khiển
local controlButtons = Instance.new("Frame")
controlButtons.Size = UDim2.new(0.35, 0, 1, 0)
controlButtons.Position = UDim2.new(0.65, 0, 0, 0)
controlButtons.BackgroundTransparency = 1
controlButtons.Parent = titleBar

-- Nút đóng (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(0, 0, 0.5, -14)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Text = "×"

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

closeButton.Parent = controlButtons

-- Nút thu nhỏ
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 28, 0, 28)
minimizeButton.Position = UDim2.new(0, 32, 0.5, -14)
minimizeButton.BackgroundColor3 = Color3.fromRGB(90, 90, 120)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 14
minimizeButton.Text = "–"

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeButton

minimizeButton.Parent = controlButtons

-- Nút ẩn
local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 28, 0, 28)
hideButton.Position = UDim2.new(0, 64, 0.5, -14)
hideButton.BackgroundColor3 = Color3.fromRGB(90, 90, 120)
hideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hideButton.Font = Enum.Font.GothamBold
hideButton.TextSize = 12
hideButton.Text = "▁"

local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(0, 6)
hideCorner.Parent = hideButton

hideButton.Parent = controlButtons

-- Nội dung chính
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -42)
contentFrame.Position = UDim2.new(0, 5, 0, 37)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Nút đồ họa thấp
local lowGraphicsButton = Instance.new("TextButton")
lowGraphicsButton.Size = UDim2.new(1, 0, 0, 45)
lowGraphicsButton.Position = UDim2.new(0, 0, 0, 0)
lowGraphicsButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
lowGraphicsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lowGraphicsButton.Font = Enum.Font.GothamBold
lowGraphicsButton.TextSize = 14
lowGraphicsButton.Text = "ĐỒ HỌA THẤP"

local lowCorner = Instance.new("UICorner")
lowCorner.CornerRadius = UDim.new(0, 6)
lowCorner.Parent = lowGraphicsButton

local lowStroke = Instance.new("UIStroke")
lowStroke.Color = Color3.fromRGB(100, 120, 160)
lowStroke.Thickness = 2
lowStroke.Parent = lowGraphicsButton

lowGraphicsButton.Parent = contentFrame

-- Nút chế độ siêu thấp
local ultraLowButton = Instance.new("TextButton")
ultraLowButton.Size = UDim2.new(1, 0, 0, 45)
ultraLowButton.Position = UDim2.new(0, 0, 0, 55)
ultraLowButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
ultraLowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ultraLowButton.Font = Enum.Font.GothamBold
ultraLowButton.TextSize = 14
ultraLowButton.Text = "SIÊU THẤP (BÙN)"

local ultraCorner = Instance.new("UICorner")
ultraCorner.CornerRadius = UDim.new(0, 6)
ultraCorner.Parent = ultraLowButton

local ultraStroke = Instance.new("UIStroke")
ultraStroke.Color = Color3.fromRGB(160, 80, 80)
ultraStroke.Thickness = 2
ultraStroke.Parent = ultraLowButton

ultraLowButton.Parent = contentFrame

-- Thông tin trạng thái
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 110)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Text = "Trạng thái: Đồ họa bình thường"
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

-- Nút hiện GUI (khi bị ẩn)
local showGUIButton = Instance.new("TextButton")
showGUIButton.Size = UDim2.new(0, 45, 0, 45)
showGUIButton.Position = UDim2.new(0, 15, 0, 15)
showGUIButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
showGUIButton.TextColor3 = Color3.fromRGB(220, 220, 255)
showGUIButton.Font = Enum.Font.GothamBold
showGUIButton.TextSize = 18
showGUIButton.Text = "⚙️"
showGUIButton.Visible = false

local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 8)
showCorner.Parent = showGUIButton

local showShadow = Instance.new("UIStroke")
showShadow.Color = Color3.fromRGB(20, 20, 30)
showShadow.Thickness = 2
showShadow.Parent = showGUIButton

showGUIButton.Parent = mainGui

-- Tạo FPS display riêng (có thể di chuyển)
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "FPSDisplay"
fpsGui.ResetOnSpawn = false
fpsGui.Parent = PlayerGui

local fpsFrame = Instance.new("Frame")
fpsFrame.Size = UDim2.new(0, 120, 0, 35)
fpsFrame.Position = UDim2.new(1, -130, 0, 15)
fpsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
fpsFrame.BorderSizePixel = 0
fpsFrame.Active = true
fpsFrame.Draggable = true

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 6)
fpsCorner.Parent = fpsFrame

local fpsShadow = Instance.new("UIStroke")
fpsShadow.Color = Color3.fromRGB(20, 20, 30)
fpsShadow.Thickness = 2
fpsShadow.Parent = fpsFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 1, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 16
fpsLabel.Text = "FPS: ..."
fpsLabel.Parent = fpsFrame

fpsFrame.Parent = fpsGui

-- Cập nhật FPS
local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 0.5 then
        fpsLabel.Text = "FPS: " .. tostring(math.floor(frameCount * 2))
        frameCount = 0
        lastTime = now
    end
end)

-- Xử lý sự kiện nút
lowGraphicsButton.MouseButton1Click:Connect(function()
    if isUltraLowGraphics then
        RestoreGraphics()
        isUltraLowGraphics = false
    end
    
    if not isLowGraphics then
        SetLowGraphics()
        lowGraphicsButton.BackgroundColor3 = Color3.fromRGB(80, 120, 160)
        lowGraphicsButton.Text = "TẮT ĐỒ HỌA THẤP"
        statusLabel.Text = "Trạng thái: Đồ họa thấp"
        isLowGraphics = true
    else
        RestoreGraphics()
        lowGraphicsButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
        lowGraphicsButton.Text = "ĐỒ HỌA THẤP"
        statusLabel.Text = "Trạng thái: Đồ họa bình thường"
        isLowGraphics = false
    end
end)

ultraLowButton.MouseButton1Click:Connect(function()
    if isLowGraphics then
        RestoreGraphics()
        isLowGraphics = false
        lowGraphicsButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
        lowGraphicsButton.Text = "ĐỒ HỌA THẤP"
    end
    
    if not isUltraLowGraphics then
        SetUltraLowGraphics()
        ultraLowButton.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
        ultraLowButton.Text = "TẮT CHẾ ĐỘ BÙN"
        statusLabel.Text = "Trạng thái: Đồ họa siêu thấp (Bùn)"
        isUltraLowGraphics = true
    else
        RestoreGraphics()
        ultraLowButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
        ultraLowButton.Text = "SIÊU THẤP (BÙN)"
        statusLabel.Text = "Trạng thái: Đồ họa bình thường"
        isUltraLowGraphics = false
    end
end)

closeButton.MouseButton1Click:Connect(function()
    mainGui:Destroy()
    fpsGui:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(function()
    if not isGUIMinimized then
        -- Thu nhỏ
        contentFrame.Visible = false
        mainFrame.Size = minimizedGUISize
        minimizeButton.Text = "□"
        isGUIMinimized = true
    else
        -- Phóng to
        contentFrame.Visible = true
        mainFrame.Size = originalGUISize
        minimizeButton.Text = "–"
        isGUIMinimized = false
    end
end)

hideButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    showGUIButton.Visible = true
    isGUIVisible = false
end)

showGUIButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    showGUIButton.Visible = false
    isGUIVisible = true
end)

-- Hiệu ứng hover cho các nút
local function setupButtonEffects(button)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(originalColor.R * 255 + 20, 255),
                math.min(originalColor.G * 255 + 20, 255),
                math.min(originalColor.B * 255 + 20, 255)
            )
        })
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor
        })
        tween:Play()
    end)
end

-- Áp dụng hiệu ứng cho tất cả nút
setupButtonEffects(lowGraphicsButton)
setupButtonEffects(ultraLowButton)
setupButtonEffects(closeButton)
setupButtonEffects(minimizeButton)
setupButtonEffects(hideButton)
setupButtonEffects(showGUIButton)

-- Thông báo khởi động
StarterGui:SetCore("SendNotification", {
    Title = "GRAPHICS CONTROL",
    Text = "GUI đã được tải thành công!",
    Duration = 3
})