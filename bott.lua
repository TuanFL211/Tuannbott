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
local isUltraHidden = false
local isGUIVisible = true
local isGUIMinimized = false
local originalGUISize = UDim2.new(0, 300, 0, 200)
local minimizedGUISize = UDim2.new(0, 100, 0, 40)

-- Hàm điều chỉnh đồ họa thấp
local function SetLowGraphics()
    -- Chỉnh chất lượng đồ họa xuống thấp
    settings().Rendering.QualityLevel = 1
    
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
            obj.Rate = math.min(obj.Rate, 10)
        elseif obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = false
        elseif obj:IsA("Decal") then
            obj.Transparency = 0.5
        end
    end
    
    -- Tắt âm thanh skill
    for _, sound in ipairs(SoundService:GetDescendants()) do
        if sound:IsA("Sound") and sound.Name:match("Skill") then
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
    
    -- Khôi phục particle
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Rate = obj.Rate * 2
        elseif obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = true
        elseif obj:IsA("Decal") then
            obj.Transparency = 0
        end
    end
end

-- Tạo GUI chính
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "GraphicsControlGUI"
mainGui.ResetOnSpawn = false
mainGui.Parent = PlayerGui

-- Frame chính
local mainFrame = Instance.new("Frame")
mainFrame.Size = originalGUISize
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = mainGui

-- Thanh tiêu đề
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Tiêu đề
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Text = "Graphics Control"
titleLabel.Parent = titleBar

-- Nút đóng (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -75, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16
closeButton.Text = "X"
closeButton.Parent = titleBar

-- Nút thu nhỏ
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -50, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 16
minimizeButton.Text = "_"
minimizeButton.Parent = titleBar

-- Nút ẩn
local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 25, 0, 25)
hideButton.Position = UDim2.new(1, -25, 0, 0)
hideButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
hideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hideButton.Font = Enum.Font.SourceSansBold
hideButton.TextSize = 16
hideButton.Text = "—"
hideButton.Parent = titleBar

-- Nội dung chính
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -35)
contentFrame.Position = UDim2.new(0, 5, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Nút bật/tắt đồ họa thấp
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 0, 40)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 18
toggleButton.Text = "BẬT ĐỒ HỌA THẤP"
toggleButton.Parent = contentFrame

-- Hiển thị FPS
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 30)
fpsLabel.Position = UDim2.new(0, 0, 0, 50)
fpsLabel.BackgroundTransparency = 0.8
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.TextStrokeTransparency = 0.8
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 18
fpsLabel.Text = "FPS: ..."
fpsLabel.Parent = contentFrame

-- Thông tin trạng thái
local statusLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 30)
fpsLabel.Position = UDim2.new(0, 0, 0, 90)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.Font = Enum.Font.SourceSans
fpsLabel.TextSize = 14
fpsLabel.Text = "Đồ họa: Bình thường"
fpsLabel.Parent = contentFrame

-- Nút hiện GUI (khi bị ẩn)
local showGUIButton = Instance.new("TextButton")
showGUIButton.Size = UDim2.new(0, 40, 0, 40)
showGUIButton.Position = UDim2.new(0, 10, 0, 10)
showGUIButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
showGUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
showGUIButton.Font = Enum.Font.SourceSansBold
showGUIButton.TextSize = 16
showGUIButton.Text = "☰"
showGUIButton.Visible = false
showGUIButton.Parent = mainGui

-- Cập nhật FPS
local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 1 then
        fpsLabel.Text = "FPS: " .. tostring(frameCount)
        frameCount = 0
        lastTime = now
    end
end)

-- Xử lý sự kiện nút
toggleButton.MouseButton1Click:Connect(function()
    if not isUltraHidden then
        SetLowGraphics()
        toggleButton.Text = "TẮT ĐỒ HỌA THẤP"
        toggleButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        statusLabel.Text = "Đồ họa: Thấp"
        isUltraHidden = true
        StarterGui:SetCore("SendNotification", {
            Title = "ĐỒ HỌA THẤP",
            Text = "Đã bật chế độ đồ họa thấp",
            Duration = 3
        })
    else
        RestoreGraphics()
        toggleButton.Text = "BẬT ĐỒ HỌA THẤP"
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = "Đồ họa: Bình thường"
        isUltraHidden = false
        StarterGui:SetCore("SendNotification", {
            Title = "ĐỒ HỌA BÌNH THƯỜNG",
            Text = "Đã khôi phục đồ họa",
            Duration = 3
        })
    end
end)

closeButton.MouseButton1Click:Connect(function()
    mainGui:Destroy()
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
        minimizeButton.Text = "_"
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

-- Cho phép kéo frame bằng title bar
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)