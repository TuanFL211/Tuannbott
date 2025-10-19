loadstring([[
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Biến toàn cục
local isPotatoMode = false
local isUIVisible = true
local isFPSMinimized = false
local connections = {}

-- Hàm chuyển đổi đồ họa potato xi măng
local function enablePotatoMode()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    -- Thiết lập Lighting cho potato mode
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.GeographicLatitude = 0
    
    -- Xóa các hiệu ứng
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        elseif effect:IsA("Sky") then
            effect:Destroy()
        end
    end
    
    -- Xóa particle và beam
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
                obj.Enabled = false
            elseif obj:IsA("Decal") and not obj:FindFirstAncestorOfClass("Model") then
                obj.Transparency = 1
            elseif obj:IsA("Part") and obj.Material ~= Enum.Material.Plastic then
                obj.Material = Enum.Material.Concrete
                if obj.BrickColor ~= BrickColor.new("Medium stone grey") then
                    obj.BrickColor = BrickColor.new("Medium stone grey")
                end
            end
        end)
    end
    
    -- Xóa remote event không cần thiết
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (remote.Name:find("Skill") or remote.Name:find("Effect")) then
            remote:Destroy()
        end
    end
    
    -- Dừng sound
    for _, sound in ipairs(SoundService:GetDescendants()) do
        if sound:IsA("Sound") and sound.Name:match("Skill") then
            sound:Stop()
        end
    end
end

-- Tạo GUI chính
local mainGUI = Instance.new("ScreenGui")
mainGUI.Name = "PotatoModeGUI"
mainGUI.ResetOnSpawn = false
mainGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame chính có thể di chuyển
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 120)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = mainGUI

-- Thanh tiêu đề
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "POTATO MODE"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 14
titleText.Parent = titleBar

-- Nút thu nhỏ
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(0.7, 0, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 16
minimizeBtn.Parent = titleBar

-- Nút đóng
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(0.85, 0, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.Parent = titleBar

-- Nội dung chính
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -25)
contentFrame.Position = UDim2.new(0, 0, 0, 25)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Nút bật/tắt potato mode
local potatoBtn = Instance.new("TextButton")
potatoBtn.Size = UDim2.new(0.9, 0, 0, 35)
potatoBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
potatoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
potatoBtn.BorderSizePixel = 0
potatoBtn.Text = "BẬT POTATO MODE"
potatoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
potatoBtn.Font = Enum.Font.SourceSansBold
potatoBtn.TextSize = 16
potatoBtn.Parent = contentFrame

-- Nút rejoin
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0.9, 0, 0, 35)
rejoinBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
rejoinBtn.BorderSizePixel = 0
rejoinBtn.Text = "REJOIN"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.Font = Enum.Font.SourceSansBold
rejoinBtn.TextSize = 16
rejoinBtn.Parent = contentFrame

-- Tạo FPS counter
local fpsGUI = Instance.new("ScreenGui")
fpsGUI.Name = "RealFPS"
fpsGUI.ResetOnSpawn = false
fpsGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local fpsFrame = Instance.new("Frame")
fpsFrame.Size = UDim2.new(0, 120, 0, 30)
fpsFrame.Position = UDim2.new(1, -130, 0, 50)
fpsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsFrame.BackgroundTransparency = 0.4
fpsFrame.BorderSizePixel = 0
fpsFrame.Active = true
fpsFrame.Draggable = true
fpsFrame.Parent = fpsGUI

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 1, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.TextStrokeTransparency = 0.1
fpsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 18
fpsLabel.Text = "FPS: ..."
fpsLabel.Parent = fpsFrame

-- Logic FPS counter
local lastTime = tick()
local frameCount = 0

local fpsConnection = RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    
    if currentTime - lastTime >= 1 then
        local fps = math.floor(frameCount / (currentTime - lastTime))
        if isFPSMinimized then
            fpsLabel.Text = tostring(fps)
        else
            fpsLabel.Text = "FPS: " .. tostring(fps)
        end
        frameCount = 0
        lastTime = currentTime
    end
end)
table.insert(connections, fpsConnection)

-- Xử lý sự kiện nút FPS
fpsLabel.MouseButton1Click:Connect(function()
    isFPSMinimized = not isFPSMinimized
    if isFPSMinimized then
        local currentText = fpsLabel.Text
        local fpsNumber = currentText:gsub("FPS: ", "")
        fpsLabel.Text = fpsNumber
        fpsFrame.Size = UDim2.new(0, 50, 0, 30)
    else
        local currentText = fpsLabel.Text
        fpsLabel.Text = "FPS: " .. currentText
        fpsFrame.Size = UDim2.new(0, 120, 0, 30)
    end
end)

-- Xử lý sự kiện nút thu nhỏ GUI
minimizeBtn.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    contentFrame.Visible = isUIVisible
    
    if isUIVisible then
        mainFrame.Size = UDim2.new(0, 200, 0, 120)
        minimizeBtn.Text = "_"
    else
        mainFrame.Size = UDim2.new(0, 200, 0, 25)
        minimizeBtn.Text = "□"
    end
end)

-- Xử lý sự kiện nút đóng
closeBtn.MouseButton1Click:Connect(function()
    -- Ngắt tất cả connections
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    
    -- Xóa GUI
    mainGUI:Destroy()
    fpsGUI:Destroy()
end)

-- Xử lý sự kiện nút potato mode
potatoBtn.MouseButton1Click:Connect(function()
    if not isPotatoMode then
        enablePotatoMode()
        potatoBtn.Text = "POTATO MODE ON"
        potatoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        isPotatoMode = true
        
        StarterGui:SetCore("SendNotification", {
            Title = "POTATO MODE",
            Text = "Đồ họa đã được tối ưu!",
            Duration = 3
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title = "THÔNG BÁO",
            Text = "Potato mode đã được bật!",
            Duration = 3
        })
    end
end)

-- Xử lý sự kiện nút rejoin
rejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- Thêm GUI vào PlayerGui
mainGUI.Parent = PlayerGui
fpsGUI.Parent = PlayerGui

-- Xử lý khi nhấp vào UI để hiện GUI (nếu đang ẩn)
mainFrame.MouseButton1Click:Connect(function()
    if not isUIVisible then
        isUIVisible = true
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 200, 0, 120)
        minimizeBtn.Text = "_"
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "POTATO MODE SCRIPT",
    Text = "Đã tải thành công! CRE: TUAN_FIX_LAG AND TK",
    Duration = 5
})
]])()