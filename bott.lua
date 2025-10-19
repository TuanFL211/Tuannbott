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

-- Lưu trữ các giá trị gốc của môi trường
local originalEnvironment = {}

-- Hàm kiểm tra xem có phải là nhân vật không
local function IsCharacter(instance)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and instance:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

-- Hàm kiểm tra xem có phải là môi trường không
local function IsEnvironment(instance)
    local environmentNames = {
        "Ground", "Terrain", "Water", "Tree", "Wood", "Rock", "Stone", 
        "Grass", "Leaf", "Bush", "Plant", "Flower", "Building", "House",
        "Wall", "Floor", "Road", "Path", "Bridge", "Mountain", "Hill"
    }
    
    for _, name in pairs(environmentNames) do
        if instance.Name:lower():find(name:lower()) then
            return true
        end
    end
    return false
end

-- Hàm áp dụng đồ họa cực thấp cho môi trường
local function ApplyUltraLowToEnvironment()
    -- Áp dụng cài đặt lighting
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1000000
    Lighting.FogStart = 1000000
    
    -- Chất lượng rendering cực thấp
    settings().Rendering.QualityLevel = 1
    
    -- Xử lý Terrain (đất)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        if not originalEnvironment[terrain] then
            originalEnvironment[terrain] = {
                WaterWaveSize = terrain.WaterWaveSize,
                WaterWaveSpeed = terrain.WaterWaveSpeed,
                WaterReflectance = terrain.WaterReflectance,
                WaterTransparency = terrain.WaterTransparency
            }
        end
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 1
    end
    
    -- Xử lý tất cả các phần tử trong workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if not IsCharacter(obj) and IsEnvironment(obj) then
            if obj:IsA("BasePart") then
                -- Lưu giá trị gốc
                if not originalEnvironment[obj] then
                    originalEnvironment[obj] = {
                        Material = obj.Material,
                        Color = obj.Color,
                        Transparency = obj.Transparency,
                        Reflectance = obj.Reflectance,
                        BrickColor = obj.BrickColor
                    }
                end
                
                -- Áp dụng đồ họa mờ
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.Transparency = 0.3 -- Làm mờ nhẹ
                
                -- Làm mờ màu sắc
                local originalColor = originalEnvironment[obj].Color or originalEnvironment[obj].BrickColor.Color
                obj.Color = Color3.new(
                    originalColor.R * 0.7,
                    originalColor.G * 0.7,
                    originalColor.B * 0.7
                )
                
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
                obj.Enabled = false
            elseif obj:IsA("Decal") then
                obj.Transparency = 0.8
            end
        end
    end
    
    -- Xóa hiệu ứng ánh sáng
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or 
           effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or 
           effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
end

-- Hàm khôi phục môi trường
local function RestoreEnvironment()
    -- Khôi phục lighting
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 1000
    Lighting.FogStart = 0
    
    -- Khôi phục chất lượng rendering
    settings().Rendering.QualityLevel = 10
    
    -- Khôi phục Terrain
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain and originalEnvironment[terrain] then
        terrain.WaterWaveSize = originalEnvironment[terrain].WaterWaveSize
        terrain.WaterWaveSpeed = originalEnvironment[terrain].WaterWaveSpeed
        terrain.WaterReflectance = originalEnvironment[terrain].WaterReflectance
        terrain.WaterTransparency = originalEnvironment[terrain].WaterTransparency
    end
    
    -- Khôi phục tất cả các phần tử môi trường
    for obj, originalData in pairs(originalEnvironment) do
        if obj and obj.Parent and obj ~= terrain then
            if obj:IsA("BasePart") then
                obj.Material = originalData.Material
                obj.Color = originalData.Color
                obj.Transparency = originalData.Transparency
                obj.Reflectance = originalData.Reflectance
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
                obj.Enabled = true
            elseif obj:IsA("Decal") then
                obj.Transparency = 0
            end
        end
    end
    
    -- Bật lại hiệu ứng ánh sáng
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = true
        end
    end
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
    
    -- Giảm chất lượng particle (chỉ cho môi trường)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not IsCharacter(obj) and IsEnvironment(obj) then
            if obj:IsA("ParticleEmitter") then
                obj.Rate = math.min(obj.Rate, 5)
            elseif obj:IsA("Fire") or obj:IsA("Smoke") then
                obj.Enabled = false
            elseif obj:IsA("Decal") then
                obj.Transparency = 0.7
            end
        end
    end
end

-- Hàm khôi phục đồ họa
local function RestoreGraphics()
    RestoreEnvironment()
    
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
    
    -- Bật lại particle và effects (chỉ cho môi trường)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not IsCharacter(obj) and IsEnvironment(obj) then
            if obj:IsA("ParticleEmitter") then
                obj.Enabled = true
            elseif obj:IsA("Fire") or obj:IsA("Smoke") then
                obj.Enabled = true
            elseif obj:IsA("Decal") then
                obj.Transparency = 0
            end
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
mainFrame.Active = true
mainFrame.Draggable = true

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
titleBar.Active = true
titleBar.Draggable = true

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

-- Nút chế độ cực thấp
local ultraLowButton = Instance.new("TextButton")
ultraLowButton.Size = UDim2.new(1, 0, 0, 45)
ultraLowButton.Position = UDim2.new(0, 0, 0, 55)
ultraLowButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
ultraLowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ultraLowButton.Font = Enum.Font.GothamBold
ultraLowButton.TextSize = 14
ultraLowButton.Text = "CỰC THẤP (MỜ)"

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
showGUIButton.Size = UDim2.new(0, 50, 0, 50)
showGUIButton.Position = UDim2.new(0, 15, 0, 15)
showGUIButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
showGUIButton.TextColor3 = Color3.fromRGB(220, 220, 255)
showGUIButton.Font = Enum.Font.GothamBold
showGUIButton.TextSize = 18
showGUIButton.Text = "⚙️"
showGUIButton.Visible = false
showGUIButton.Active = true
showGUIButton.Draggable = true

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
        ultraLowButton.Text = "CỰC THẤP (MỜ)"
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
        ApplyUltraLowToEnvironment()
        ultraLowButton.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
        ultraLowButton.Text = "TẮT CỰC THẤP"
        statusLabel.Text = "Trạng thái: Đồ họa cực thấp (Môi trường mờ)"
        isUltraLowGraphics = true
        
        StarterGui:SetCore("SendNotification", {
            Title = "CỰC THẤP KÍCH HOẠT",
            Text = "Môi trường đã được làm mờ, nhân vật giữ nguyên",
            Duration = 3
        })
    else
        RestoreGraphics()
        ultraLowButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
        ultraLowButton.Text = "CỰC THẤP (MỜ)"
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

-- Hàm tạo hiệu ứng di chuyển cho UI
local function MakeDraggable(uiElement)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        uiElement.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    uiElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = uiElement.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    uiElement.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Áp dụng khả năng di chuyển cho tất cả UI
MakeDraggable(mainFrame)
MakeDraggable(showGUIButton)
MakeDraggable(fpsFrame)

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
    Title = "TUANN",
    Text = "BẢN FIXLAG TỐI ƯU MÁY YẾU😋",
    Duration = 3
})