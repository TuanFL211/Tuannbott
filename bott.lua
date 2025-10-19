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
    if IsCharacter(instance) then
        return false
    end
    
    local environmentNames = {
        "Ground", "Terrain", "Water", "Tree", "Wood", "Rock", "Stone", 
        "Grass", "Leaf", "Bush", "Plant", "Flower", "Building", "House",
        "Wall", "Floor", "Road", "Path", "Bridge", "Mountain", "Hill",
        "Part", "Block", "Brick", "Baseplate", "Platform", "Platforms"
    }
    
    for _, name in pairs(environmentNames) do
        if instance.Name:lower():find(name:lower()) then
            return true
        end
    end
    
    -- Nếu là part không thuộc character và không phải tool
    if instance:IsA("BasePart") and not instance:IsA("Tool") then
        return true
    end
    
    return false
end

-- Hàm áp dụng đồ họa potato cho môi trường
local function ApplyPotatoGraphics()
    -- Áp dụng cài đặt lighting cực thấp
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1000000
    Lighting.FogStart = 1000000
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    
    -- Chất lượng rendering cực thấp
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    
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
                        Size = obj.Size,
                        Material = obj.Material,
                        Color = obj.Color,
                        Transparency = obj.Transparency,
                        Reflectance = obj.Reflectance,
                        BrickColor = obj.BrickColor,
                        Shape = obj.Shape
                    }
                end
                
                -- Biến thành khối potato đơn giản
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.Transparency = 0
                
                -- Đơn giản hóa kích thước (làm tròn thành khối vuông)
                local originalSize = originalEnvironment[obj].Size
                local avgSize = (originalSize.X + originalSize.Y + originalSize.Z) / 3
                obj.Size = Vector3.new(
                    math.max(1, math.floor(avgSize / 2) * 2),
                    math.max(1, math.floor(avgSize / 2) * 2), 
                    math.max(1, math.floor(avgSize / 2) * 2)
                )
                
                -- Màu potato (nâu đất cơ bản)
                local potatoColors = {
                    Color3.fromRGB(139, 69, 19),   -- nâu sẫm
                    Color3.fromRGB(160, 82, 45),   -- nâu
                    Color3.fromRGB(205, 133, 63),  -- nâu tanin
                    Color3.fromRGB(210, 180, 140), -- nâu nhạt
                    Color3.fromRGB(101, 67, 33)    -- nâu đất
                }
                obj.Color = potatoColors[math.random(1, #potatoColors)]
                
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("MeshPart") then
                -- Đơn giản hóa MeshPart thành BasePart thường
                if not originalEnvironment[obj] then
                    originalEnvironment[obj] = {
                        Size = obj.Size,
                        Material = obj.Material,
                        Color = obj.Color,
                        Transparency = obj.Transparency,
                        Reflectance = obj.Reflectance,
                        MeshId = obj.MeshId,
                        TextureId = obj.TextureId
                    }
                end
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.Transparency = 0
                local potatoColors = {
                    Color3.fromRGB(139, 69, 19),
                    Color3.fromRGB(160, 82, 45),
                    Color3.fromRGB(205, 133, 63)
                }
                obj.Color = potatoColors[math.random(1, #potatoColors)]
            elseif obj:IsA("Model") and IsEnvironment(obj) then
                -- Đơn giản hóa model
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not originalEnvironment[part] then
                            originalEnvironment[part] = {
                                Size = part.Size,
                                Material = part.Material,
                                Color = part.Color,
                                Transparency = part.Transparency,
                                Reflectance = part.Reflectance
                            }
                        end
                        part.Material = Enum.Material.Plastic
                        part.Reflectance = 0
                        part.Transparency = 0
                        local potatoColors = {
                            Color3.fromRGB(139, 69, 19),
                            Color3.fromRGB(160, 82, 45), 
                            Color3.fromRGB(205, 133, 63)
                        }
                        part.Color = potatoColors[math.random(1, #potatoColors)]
                    end
                end
            end
        end
    end
    
    -- Xóa tất cả hiệu ứng ánh sáng
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
    
    -- Tắt âm thanh môi trường
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") and IsEnvironment(sound) then
            sound:Stop()
        end
    end
end

-- Hàm khôi phục môi trường
local function RestoreEnvironment()
    -- Khôi phục lighting
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 1000
    Lighting.FogStart = 0
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.new(0, 0, 0)
    
    -- Khôi phục chất lượng rendering
    settings().Rendering.QualityLevel = 10
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level20
    
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
                if originalData.Size then
                    obj.Size = originalData.Size
                end
                obj.Material = originalData.Material
                obj.Color = originalData.Color
                obj.Transparency = originalData.Transparency
                obj.Reflectance = originalData.Reflectance
                if originalData.Shape then
                    obj.Shape = originalData.Shape
                end
            elseif obj:IsA("MeshPart") then
                obj.Material = originalData.Material
                obj.Color = originalData.Color
                obj.Transparency = originalData.Transparency
                obj.Reflectance = originalData.Reflectance
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = true
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
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
    
    -- Bật lại âm thanh môi trường
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound:Play()
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
mainFrame.ClipsDescendants = true

local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(20, 20, 30)
shadow.Thickness = 2
shadow.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

mainFrame.Parent = mainGui

-- Thanh tiêu đề (chỉ để hiển thị, không kéo được riêng)
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

-- Nút chế độ potato
local potatoButton = Instance.new("TextButton")
potatoButton.Size = UDim2.new(1, 0, 0, 45)
potatoButton.Position = UDim2.new(0, 0, 0, 55)
potatoButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
potatoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
potatoButton.Font = Enum.Font.GothamBold
potatoButton.TextSize = 14
potatoButton.Text = "POTATO MODE"

local potatoCorner = Instance.new("UICorner")
potatoCorner.CornerRadius = UDim.new(0, 6)
potatoCorner.Parent = potatoButton

local potatoStroke = Instance.new("UIStroke")
potatoStroke.Color = Color3.fromRGB(160, 80, 80)
potatoStroke.Thickness = 2
potatoStroke.Parent = potatoButton

potatoButton.Parent = contentFrame

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

local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 8)
showCorner.Parent = showGUIButton

local showShadow = Instance.new("UIStroke")
showShadow.Color = Color3.fromRGB(20, 20, 30)
showShadow.Thickness = 2
showShadow.Parent = showGUIButton

showGUIButton.Parent = mainGui

-- Tạo FPS display riêng
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
        potatoButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
        potatoButton.Text = "POTATO MODE"
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

potatoButton.MouseButton1Click:Connect(function()
    if isLowGraphics then
        RestoreGraphics()
        isLowGraphics = false
        lowGraphicsButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
        lowGraphicsButton.Text = "ĐỒ HỌA THẤP"
    end
    
    if not isUltraLowGraphics then
        ApplyPotatoGraphics()
        potatoButton.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
        potatoButton.Text = "TẮT POTATO"
        statusLabel.Text = "Trạng thái: Potato Mode (Siêu nhẹ)"
        isUltraLowGraphics = true
        
        StarterGui:SetCore("SendNotification", {
            Title = "POTATO MODE KÍCH HOẠT",
            Text = "Môi trường đã biến thành khối potato siêu nhẹ!",
            Duration = 3
        })
    else
        RestoreGraphics()
        potatoButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
        potatoButton.Text = "POTATO MODE"
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

-- Hàm kéo thả cho GUI (SỬA LỖI TÁCH PHẦN)
local function MakeDraggable(gui)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
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

-- Áp dụng kéo thả cho các UI elements
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
setupButtonEffects(potatoButton)
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
    Title = "TUANN_FL",
    Text = " ĐANH LOAD SCRIPT FIXLAG ",
    Duration = 3
})