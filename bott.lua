loadstring([[
local v1 = game:GetService("Players")
local v2 = game:GetService("StarterGui")
local v3 = game:GetService("Workspace")
local v4 = game:GetService("Lighting")
local v5 = game:GetService("ReplicatedStorage")
local v6 = game:GetService("SoundService")
local v7 = game:GetService("RunService")
local v8 = game:GetService("TeleportService")
local v9 = v1.LocalPlayer
local v10 = v9:WaitForChild("PlayerGui")

-- Lưu trữ giá trị gốc để khôi phục
local originalValues = {}
local isPotatoMode = false

local function a1()
    isPotatoMode = true
    local c1 = v9.Character or v9.CharacterAdded:Wait()
    
    -- Xử lý Workspace
    for _, c2 in ipairs(v3:GetDescendants()) do
        if not c2:IsDescendantOf(c1) then
            pcall(function()
                if c2:IsA("BasePart") then
                    -- Lưu giá trị gốc
                    if not originalValues[c2] then
                        originalValues[c2] = {
                            Transparency = c2.Transparency,
                            Material = c2.Material,
                            Color = c2.Color,
                            CastShadow = c2.CastShadow
                        }
                    end
                    
                    -- Áp dụng đồ họa xi măng chất lượng thấp
                    c2.Transparency = 0
                    c2.Material = Enum.Material.Plastic
                    -- Màu nâu xi măng thay vì xám
                    c2.Color = Color3.fromRGB(120, 100, 80)
                    c2.CastShadow = false
                    c2.Reflectance = 0
                end
                if c2:IsA("ParticleEmitter") or c2:IsA("Beam") then 
                    if not originalValues[c2] then
                        originalValues[c2] = {Enabled = c2.Enabled}
                    end
                    c2.Enabled = false 
                end
                if c2:IsA("Decal") or c2:IsA("Texture") then 
                    if not originalValues[c2] then
                        originalValues[c2] = {Transparency = c2.Transparency}
                    end
                    c2.Transparency = 1 
                end
            end)
        end
    end
    
    -- Xử lý nhân vật (chỉ xóa particle, giữ nguyên phần còn lại)
    for _, c3 in ipairs(c1:GetDescendants()) do
        if c3:IsA("ParticleEmitter") then 
            if not originalValues[c3] then
                originalValues[c3] = {Parent = c3.Parent}
            end
            c3:Destroy() 
        end
    end
    
    -- Xử lý RemoteEvents
    for _, c4 in ipairs(v5:GetDescendants()) do
        if c4:IsA("RemoteEvent") and (c4.Name:find("Skill") or c4.Name:find("Effect")) then 
            if not originalValues[c4] then
                originalValues[c4] = {Parent = c4.Parent}
            end
            c4:Destroy() 
        end
    end
    
    -- Xử lý âm thanh
    for _, c5 in ipairs(v6:GetDescendants()) do
        if c5:IsA("Sound") and c5.Name:match("Skill") then 
            if not originalValues[c5] then
                originalValues[c5] = {Playing = c5.Playing, TimePosition = c5.TimePosition}
            end
            c5:Stop() 
        end
    end
    
    -- Xử lý Lighting
    for _, c6 in ipairs(v4:GetChildren()) do 
        if c6:IsA("Sky") then 
            if not originalValues[c6] then
                originalValues[c6] = {Parent = c6.Parent}
            end
            c6:Destroy() 
        end 
    end
    
    v4.ChildAdded:Connect(function(n) 
        if n:IsA("Sky") then 
            task.wait(0.1) 
            if n:IsDescendantOf(v4) then 
                if not originalValues[n] then
                    originalValues[n] = {Parent = n.Parent}
                end
                n:Destroy() 
            end 
        end 
    end)
    
    for _, c7 in ipairs(v4:GetChildren()) do
        if c7:IsA("BlurEffect") or c7:IsA("BloomEffect") or c7:IsA("SunRaysEffect") or c7:IsA("ColorCorrectionEffect") or c7:IsA("DepthOfFieldEffect") then 
            if not originalValues[c7] then
                originalValues[c7] = {Parent = c7.Parent}
            end
            c7:Destroy() 
        end
    end
    
    -- Xử lý các hiệu ứng đặc biệt
    for _, c8 in ipairs(v3:GetDescendants()) do 
        if c8:IsA("Part") and c8.Name:match("Water") then 
            if not originalValues[c8] then
                originalValues[c8] = {Parent = c8.Parent}
            end
            c8:Destroy() 
        end 
    end
    
    for _, c9 in ipairs(v3:GetDescendants()) do 
        if c9:IsA("ParticleEmitter") and c9.Name:match("Wave") then 
            if not originalValues[c9] then
                originalValues[c9] = {Parent = c9.Parent}
            end
            c9:Destroy() 
        end 
    end
    
    for _, d1 in ipairs(v3:GetDescendants()) do
        if d1:IsA("ParticleEmitter") and (d1.Name:match("Melee") or d1.Name:match("Sword") or d1.Name:match("Fruit") or d1.Name:match("Gun")) then 
            if not originalValues[d1] then
                originalValues[d1] = {Parent = d1.Parent}
            end
            d1:Destroy() 
        end
    end
    
    for _, d2 in ipairs(v3:GetDescendants()) do
        if d2:IsA("Beam") and (d2.Name:match("Melee") or d2.Name:match("Sword") or d2.Name:match("Fruit") or d2.Name:match("Gun")) then 
            if not originalValues[d2] then
                originalValues[d2] = {Enabled = d2.Enabled}
            end
            d2.Enabled = false 
        end
    end
end

local function restoreGraphics()
    isPotatoMode = false
    
    -- Khôi phục tất cả giá trị đã lưu
    for obj, values in pairs(originalValues) do
        pcall(function()
            if obj.Parent then -- Nếu object vẫn tồn tại
                if values.Transparency ~= nil then
                    obj.Transparency = values.Transparency
                end
                if values.Material ~= nil then
                    obj.Material = values.Material
                end
                if values.Color ~= nil then
                    obj.Color = values.Color
                end
                if values.CastShadow ~= nil then
                    obj.CastShadow = values.CastShadow
                end
                if values.Enabled ~= nil then
                    obj.Enabled = values.Enabled
                end
                if values.Playing ~= nil then
                    if values.Playing then
                        obj:Play()
                    end
                end
            elseif values.Parent then -- Nếu object đã bị destroy, tạo lại
                if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Decal") or obj:IsA("Texture") then
                    local newObj = obj:Clone()
                    newObj.Parent = values.Parent
                end
            end
        end)
    end
    
    -- Xóa bảng lưu trữ
    originalValues = {}
end

-- Main GUI Setup
if v10:FindFirstChild("T") then v10.T:Destroy() end
local g1 = Instance.new("ScreenGui", v10)
g1.Name = "T"
g1.ResetOnSpawn = false
g1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame", g1)
mainFrame.Size = UDim2.new(0, 200, 0, 200)
mainFrame.Position = UDim2.new(1, -210, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true

-- Bo tròn góc
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0.1, 0)

-- Thêm hình nền
local background = Instance.new("ImageLabel", mainFrame)
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundTransparency = 1
background.Image = "rbxassetid://122014810832779"
background.ScaleType = Enum.ScaleType.Crop
background.ImageColor3 = Color3.fromRGB(60, 60, 60)

-- Hiệu ứng bóng đổ
local shadow = Instance.new("ImageLabel", mainFrame)
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = -1

local toggleButton = Instance.new("TextButton", mainFrame)
toggleButton.Size = UDim2.new(0.8, 0, 0.3, 0)
toggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.BackgroundTransparency = 0.3
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.Text = "BẬT POTATO"
toggleButton.AutoButtonColor = false

local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0.2, 0)

local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Size = UDim2.new(0.35, 0, 0.2, 0)
closeButton.Position = UDim2.new(0.1, 0, 0.5, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.BackgroundTransparency = 0.2
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Text = "ĐÓNG"

local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0.2, 0)

local minimizeButton = Instance.new("TextButton", mainFrame)
minimizeButton.Size = UDim2.new(0.35, 0, 0.2, 0)
minimizeButton.Position = UDim2.new(0.55, 0, 0.5, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
minimizeButton.BackgroundTransparency = 0.2
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.Text = "THU NHỎ"

local minimizeCorner = Instance.new("UICorner", minimizeButton)
minimizeCorner.CornerRadius = UDim.new(0.2, 0)

-- Hiệu ứng hover cho các nút
local function setupButtonHover(button)
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
end

setupButtonHover(toggleButton)
setupButtonHover(closeButton)
setupButtonHover(minimizeButton)

-- FPS Setup
if v10:FindFirstChild("RealFPS") then v10.RealFPS:Destroy() end
local f1 = Instance.new("ScreenGui", v10)
f1.Name = "RealFPS"
f1.ResetOnSpawn = false
f1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local fpsFrame = Instance.new("Frame", f1)
fpsFrame.Size = UDim2.new(0, 120, 0, 40)
fpsFrame.Position = UDim2.new(1, -130, 0, 10)
fpsFrame.BackgroundTransparency = 0.4
fpsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsFrame.Active = true
fpsFrame.Draggable = true

local fpsCorner = Instance.new("UICorner", fpsFrame)
fpsCorner.CornerRadius = UDim.new(0.2, 0)

local f2 = Instance.new("TextLabel", fpsFrame)
f2.Size = UDim2.new(1, 0, 1, 0)
f2.BackgroundTransparency = 1
f2.TextColor3 = Color3.fromRGB(0, 255, 0)
f2.TextStrokeTransparency = 0.1
f2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
f2.Font = Enum.Font.Code
f2.TextSize = 18
f2.Text = "FPS: ..."

local isCompact = false
f2.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isCompact = not isCompact
        if isCompact then
            fpsFrame.Size = UDim2.new(0, 70, 0, 40)
            f2.Text = string.gsub(f2.Text, "FPS: ", "")
            f2.Text = "(" .. f2.Text .. ")"
        else
            fpsFrame.Size = UDim2.new(0, 120, 0, 40)
            f2.Text = "FPS: " .. string.gsub(f2.Text, "[%(%)]", "")
        end
    end
end)

local l1 = tick()
local l2 = 0
v7.RenderStepped:Connect(function()
    l2 += 1
    if tick() - l1 >= 1 then
        local fpsText = tostring(l2)
        if isCompact then
            f2.Text = "(" .. fpsText .. ")"
        else
            f2.Text = "FPS: " .. fpsText
        end
        l2 = 0
        l1 = tick()
    end
end)

-- Logic
local isMinimized = false

toggleButton.MouseButton1Click:Connect(function()
    if not isPotatoMode then
        a1()
        toggleButton.Text = "TẮT POTATO"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        v2:SetCore("SendNotification", {
            Title = "CHẾ ĐỘ POTATO XI MĂNG", 
            Text = "Đã bật! CRE: TUAN_FIX_LAG AND TK", 
            Duration = 3,
            Icon = "rbxassetid://122014810832779"
        })
    else
        restoreGraphics()
        toggleButton.Text = "BẬT POTATO"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        v2:SetCore("SendNotification", {
            Title = "ĐÃ KHÔI PHỤC", 
            Text = "Đồ họa đã được khôi phục!", 
            Duration = 3,
            Icon = "rbxassetid://122014810832779"
        })
    end
end)

closeButton.MouseButton1Click:Connect(function()
    if isPotatoMode then
        restoreGraphics()
    end
    g1:Destroy()
    f1:Destroy()
    v2:SetCore("SendNotification", {
        Title = "SCRIPT ĐÃ TẮT", 
        Text = "Bye!", 
        Duration = 3,
        Icon = "rbxassetid://122014810832779"
    })
end)

minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 200, 0, 60)
        toggleButton.Size = UDim2.new(0.8, 0, 0.6, 0)
        toggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
        closeButton.Visible = false
        minimizeButton.Visible = false
        minimizeButton.Text = "_"
    else
        mainFrame.Size = UDim2.new(0, 200, 0, 200)
        toggleButton.Size = UDim2.new(0.8, 0, 0.3, 0)
        toggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
        closeButton.Visible = true
        minimizeButton.Visible = true
        minimizeButton.Text = "THU NHỎ"
    end
end)

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and isMinimized then
        isMinimized = false
        mainFrame.Size = UDim2.new(0, 200, 0, 200)
        toggleButton.Size = UDim2.new(0.8, 0, 0.3, 0)
        toggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
        closeButton.Visible = true
        minimizeButton.Visible = true
        minimizeButton.Text = "THU NHỎ"
    end
end)

-- Tương thích với các executor
]])()