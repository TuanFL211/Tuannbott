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

-- Cài đặt đồ họa cực thấp (RIP#6666)
local UltraLowSettings = {
    Players = {
        ["Ignore Me"] = true,
        ["Ignore Others"] = true,
        ["Ignore Tools"] = true
    },
    Meshes = {
        NoMesh = true,
        NoTexture = true,
        Destroy = false
    },
    Images = {
        Invisible = true,
        Destroy = false
    },
    Explosions = {
        Smaller = true,
        Invisible = true,
        Destroy = false
    },
    Particles = {
        Invisible = true,
        Destroy = false
    },
    TextLabels = {
        LowerQuality = true,
        Invisible = false,
        Destroy = false
    },
    MeshParts = {
        LowerQuality = true,
        Invisible = false,
        NoTexture = true,
        NoMesh = true,
        Destroy = false
    },
    Other = {
        ["FPS Cap"] = true,
        ["No Camera Effects"] = true,
        ["No Clothes"] = true,
        ["Low Water Graphics"] = true,
        ["No Shadows"] = true,
        ["Low Rendering"] = true,
        ["Low Quality Parts"] = true,
        ["Low Quality Models"] = true,
        ["Reset Materials"] = true,
        ["Lower Quality MeshParts"] = true,
        ClearNilInstances = false
    }
}

-- Hàm kiểm tra và áp dụng cài đặt đồ họa thấp
local function CheckIfBad(Inst)
    if not Inst:IsDescendantOf(Players) then
        if Inst:IsA("DataModelMesh") then
            if Inst:IsA("SpecialMesh") then
                if UltraLowSettings.Meshes.NoMesh then
                    Inst.MeshId = ""
                end
                if UltraLowSettings.Meshes.NoTexture then
                    Inst.TextureId = ""
                end
            end
            if UltraLowSettings.Meshes.Destroy then
                Inst:Destroy()
            end
        elseif Inst:IsA("FaceInstance") then
            if UltraLowSettings.Images.Invisible then
                Inst.Transparency = 1
                Inst.Shiny = 1
            end
            if UltraLowSettings.Images.Destroy then
                Inst:Destroy()
            end
        elseif Inst:IsA("ShirtGraphic") then
            if UltraLowSettings.Images.Invisible then
                Inst.Graphic = ""
            end
            if UltraLowSettings.Images.Destroy then
                Inst:Destroy()
            end
        elseif Inst:IsA("ParticleEmitter") or Inst:IsA("Trail") or Inst:IsA("Smoke") or Inst:IsA("Fire") or Inst:IsA("Sparkles") then
            if UltraLowSettings.Particles.Invisible then
                Inst.Enabled = false
            end
            if UltraLowSettings.Particles.Destroy then
                Inst:Destroy()
            end
        elseif Inst:IsA("PostEffect") and UltraLowSettings.Other["No Camera Effects"] then
            Inst.Enabled = false
        elseif Inst:IsA("Explosion") then
            if UltraLowSettings.Explosions.Smaller then
                Inst.BlastPressure = 1
                Inst.BlastRadius = 1
            end
            if UltraLowSettings.Explosions.Invisible then
                Inst.BlastPressure = 1
                Inst.BlastRadius = 1
                Inst.Visible = false
            end
            if UltraLowSettings.Explosions.Destroy then
                Inst:Destroy()
            end
        elseif Inst:IsA("Clothing") or Inst:IsA("SurfaceAppearance") then
            if UltraLowSettings.Other["No Clothes"] then
                Inst:Destroy()
            end
        elseif Inst:IsA("BasePart") and not Inst:IsA("MeshPart") then
            if UltraLowSettings.Other["Low Quality Parts"] then
                Inst.Material = Enum.Material.Plastic
                Inst.Reflectance = 0
            end
        elseif Inst:IsA("TextLabel") and Inst:IsDescendantOf(workspace) then
            if UltraLowSettings.TextLabels.LowerQuality then
                Inst.Font = Enum.Font.SourceSans
                Inst.TextScaled = false
                Inst.RichText = false
                Inst.TextSize = 14
            end
            if UltraLowSettings.TextLabels.Invisible then
                Inst.Visible = false
            end
            if UltraLowSettings.TextLabels.Destroy then
                Inst:Destroy()
            end
        elseif Inst:IsA("Model") then
            if UltraLowSettings.Other["Low Quality Models"] then
                Inst.LevelOfDetail = 1
            end
        elseif Inst:IsA("MeshPart") then
            if UltraLowSettings.MeshParts.LowerQuality then
                Inst.RenderFidelity = 2
                Inst.Reflectance = 0
                Inst.Material = Enum.Material.Plastic
            end
            if UltraLowSettings.MeshParts.NoTexture then
                Inst.TextureID = ""
            end
            if UltraLowSettings.MeshParts.NoMesh then
                Inst.MeshId = ""
            end
            if UltraLowSettings.MeshParts.Destroy then
                Inst:Destroy()
            end
        end
    end
end

-- Hàm áp dụng đồ họa cực thấp
local function ApplyUltraLowGraphics()
    -- Áp dụng cài đặt lighting
    if UltraLowSettings.Other["No Shadows"] then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
    end
    
    -- Áp dụng cài đặt rendering
    if UltraLowSettings.Other["Low Rendering"] then
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    end
    
    -- Áp dụng cài đặt water graphics
    if UltraLowSettings.Other["Low Water Graphics"] then
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
    end
    
    -- Áp dụng cho tất cả descendants hiện có
    local Descendants = game:GetDescendants()
    for i, v in pairs(Descendants) do
        CheckIfBad(v)
    end
    
    -- Áp dụng cho descendants mới
    game.DescendantAdded:Connect(function(value)
        task.wait(0.1)
        CheckIfBad(value)
    end)
end

-- Hàm điều chỉnh đồ họa thấp
local function SetLowGraphics()
    if isUltraLowGraphics then return end
    
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

-- Tạo GUI chính
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "UltraGraphicsControl"
mainGui.ResetOnSpawn = false
mainGui.Parent = PlayerGui

-- Frame chính
local mainFrame = Instance.new("Frame")
mainFrame.Size = originalGUISize
mainFrame.Position = UDim2.new(0, 15, 0, 15)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0

local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(20, 20, 30)
shadow.Thickness = 2
shadow.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

mainFrame.Parent = mainGui

-- Thanh tiêu đề
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
titleBar.BorderSizePixel = 0
titleBar.Name = "TitleBar"

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
titleLabel.Text = "TUANN_FL"
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

-- Nút chế độ cực thấp
local ultraLowButton = Instance.new("TextButton")
ultraLowButton.Size = UDim2.new(1, 0, 0, 45)
ultraLowButton.Position = UDim2.new(0, 0, 0, 55)
ultraLowButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
ultraLowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ultraLowButton.Font = Enum.Font.GothamBold
ultraLowButton.TextSize = 14
ultraLowButton.Text = "CỰC THẤP"

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
statusLabel.Text = "Trạng thái: Đồ họa thường"
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

-- Nút hiện GUI (khi bị ẩn)
local showGUIButton = Instance.new("Frame")
showGUIButton.Size = UDim2.new(0, 50, 0, 50)
showGUIButton.Position = UDim2.new(0, 15, 0, 15)
showGUIButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
showGUIButton.Visible = false

local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 8)
showCorner.Parent = showGUIButton

local showShadow = Instance.new("UIStroke")
showShadow.Color = Color3.fromRGB(20, 20, 30)
showShadow.Thickness = 2
showShadow.Parent = showGUIButton

local showIcon = Instance.new("TextButton")
showIcon.Size = UDim2.new(1, 0, 1, 0)
showIcon.BackgroundTransparency = 1
showIcon.TextColor3 = Color3.fromRGB(220, 220, 255)
showIcon.Font = Enum.Font.GothamBold
showIcon.TextSize = 18
showIcon.Text = "⚙️"
showIcon.Parent = showGUIButton

showGUIButton.Parent = mainGui

-- Tạo FPS display riêng (có thể di chuyển)
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "FPSDisplay"
fpsGui.ResetOnSpawn = false
fpsGui.Parent = PlayerGui

local fpsFrame = Instance.new("TextButton")
fpsFrame.Size = UDim2.new(0, 80, 0, 30)
fpsFrame.Position = UDim2.new(1, -90, 0, 15)
fpsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
fpsFrame.BorderSizePixel = 0
fpsFrame.AutoButtonColor = false
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
fpsLabel.Text = "60"
fpsLabel.Parent = fpsFrame

fpsFrame.Parent = fpsGui

-- Biến để theo dõi chế độ hiển thị FPS
local fpsDisplayMode = "compact"

-- Cập nhật FPS
local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 0.5 then
        local currentFPS = math.floor(frameCount * 2)
        if fpsDisplayMode == "compact" then
            fpsLabel.Text = tostring(currentFPS)
        else
            fpsLabel.Text = "FPS: " .. tostring(currentFPS)
        end
        frameCount = 0
        lastTime = now
    end
end)

-- Xử lý click vào FPS để chuyển đổi chế độ hiển thị
fpsFrame.MouseButton1Click:Connect(function()
    if fpsDisplayMode == "compact" then
        fpsDisplayMode = "full"
        fpsFrame.Size = UDim2.new(0, 120, 0, 30)
        fpsLabel.Text = "FPS: " .. fpsLabel.Text
    else
        fpsDisplayMode = "compact"
        fpsFrame.Size = UDim2.new(0, 80, 0, 30)
        fpsLabel.Text = string.match(fpsLabel.Text, "%d+") or "60"
    end
end)

-- Xử lý sự kiện nút
lowGraphicsButton.MouseButton1Click:Connect(function()
    if isUltraLowGraphics then
        RestoreGraphics()
        isUltraLowGraphics = false
        ultraLowButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
        ultraLowButton.Text = "CỰC THẤP (RIP)"
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
        statusLabel.Text = "Trạng thái: Đồ họa thường"
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
        ApplyUltraLowGraphics()
        ultraLowButton.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
        ultraLowButton.Text = "TẮT CỰC THẤP"
        statusLabel.Text = "Trạng thái: Đồ họa cực thấp"
        isUltraLowGraphics = true
        
        StarterGui:SetCore("SendNotification", {
            Title = "CỰC THẤP KÍCH HOẠT",
            Text = "Đồ họa cực thấp đã được bật",
            Duration = 3
        })
    else
        RestoreGraphics()
        ultraLowButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
        ultraLowButton.Text = "CỰC THẤP"
        statusLabel.Text = "Trạng thái: Đồ họa thường"
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

showIcon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    showGUIButton.Visible = false
    isGUIVisible = true
end)

-- SỬA LỖI DI CHUYỂN GUI
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

-- Hiệu ứng cho nút hiện GUI
showIcon.MouseEnter:Connect(function()
    local tween = TweenService:Create(showGUIButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    })
    tween:Play()
end)

showIcon.MouseLeave:Connect(function()
    local tween = TweenService:Create(showGUIButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    })
    tween:Play()
end)

-- Hiệu ứng cho FPS frame
fpsFrame.MouseEnter:Connect(function()
    local tween = TweenService:Create(fpsFrame, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    })
    tween:Play()
end)

fpsFrame.MouseLeave:Connect(function()
    local tween = TweenService:Create(fpsFrame, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    })
    tween:Play()
end)

-- Thông báo khởi động
StarterGui:SetCore("SendNotification", {
    Title = "GRAPHICS CONTROL",
    Text = "GUI đã được tải thành công!",
    Duration = 3
})