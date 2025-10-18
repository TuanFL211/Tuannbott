-- Gemini Chatbot Script for Roblox - Fixed API Version
-- Supported Executors: KRNL, Delta, Fluxus, Synapse

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Safe get CoreGui
local CoreGui
pcall(function()
    CoreGui = game:GetService("CoreGui")
end)

if not CoreGui then
    CoreGui = game:FindFirstChild("CoreGui") or playerGui
end

-- Configuration - KHÔNG có API key mặc định
local CONFIG = {
    API_KEY = "", -- Để trống, người dùng phải tự nhập
    ENABLED_EFFECTS = true,
    CHAT_HISTORY = {},
    CURRENT_CHAT_ID = nil
}

-- Safe functions
local function GenerateID()
    return tostring(math.random(1, 1000000)) .. "_" .. tostring(tick())
end

local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function()
            obj:Destroy()
        end)
    end
end

local function CleanupExistingGUI()
    local guis = {playerGui, CoreGui}
    for _, guiParent in ipairs(guis) do
        local existingGUI = guiParent:FindFirstChild("GeminiChat")
        if existingGUI then
            SafeDestroy(existingGUI)
        end
    end
end

-- Create compact GUI
local function CreateChatGUI()
    CleanupExistingGUI()
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GeminiChat"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    -- Main Frame - NHỎ HƠN
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 350) -- Nhỏ hơn trước
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30) -- Nhỏ hơn
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 150, 1, 0)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Gemini AI Chat"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 12
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Control Buttons
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0, 50, 1, 0)
    controls.Position = UDim2.new(1, -55, 0, 0)
    controls.BackgroundTransparency = 1
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.FillDirection = Enum.FillDirection.Horizontal
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    uiListLayout.Padding = UDim.new(0, 4)
    uiListLayout.Parent = controls

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 10
    closeBtn.Font = Enum.Font.GothamBold
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn

    closeBtn.Parent = controls
    titleBar.Parent = mainFrame
    controls.Parent = titleBar

    -- Settings Button
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Name = "SettingsBtn"
    settingsBtn.Size = UDim2.new(0, 70, 0, 22)
    settingsBtn.Position = UDim2.new(1, -130, 0.5, -11)
    settingsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    settingsBtn.BorderSizePixel = 0
    settingsBtn.Text = "⚙ Cài Đặt"
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsBtn.TextSize = 10
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 4)
    settingsCorner.Parent = settingsBtn
    settingsBtn.Parent = titleBar

    -- Chat History
    local chatHistory = Instance.new("ScrollingFrame")
    chatHistory.Name = "ChatHistory"
    chatHistory.Size = UDim2.new(1, -16, 1, -100) -- Điều chỉnh cho nhỏ hơn
    chatHistory.Position = UDim2.new(0, 8, 0, 38)
    chatHistory.BackgroundTransparency = 1
    chatHistory.BorderSizePixel = 0
    chatHistory.ScrollBarThickness = 4
    chatHistory.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatHistory.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.Padding = UDim.new(0, 6)
    chatLayout.Parent = chatHistory

    -- Input Area
    local inputArea = Instance.new("Frame")
    inputArea.Name = "InputArea"
    inputArea.Size = UDim2.new(1, -16, 0, 45)
    inputArea.Position = UDim2.new(0, 8, 1, -53)
    inputArea.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    inputArea.BorderSizePixel = 0
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputArea

    -- Message Input
    local messageInput = Instance.new("TextBox")
    messageInput.Name = "MessageInput"
    messageInput.Size = UDim2.new(1, -50, 1, -8)
    messageInput.Position = UDim2.new(0, 8, 0, 4)
    messageInput.BackgroundTransparency = 1
    messageInput.Text = ""
    messageInput.PlaceholderText = "Nhập tin nhắn..."
    messageInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageInput.TextSize = 12
    messageInput.Font = Enum.Font.Gotham
    messageInput.TextXAlignment = Enum.TextXAlignment.Left
    messageInput.ClearTextOnFocus = false

    -- Send Button
    local sendBtn = Instance.new("TextButton")
    sendBtn.Name = "SendBtn"
    sendBtn.Size = UDim2.new(0, 35, 0, 35)
    sendBtn.Position = UDim2.new(1, -42, 0.5, -17.5)
    sendBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    sendBtn.BorderSizePixel = 0
    sendBtn.Text = "➤"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.TextSize = 14
    sendBtn.Font = Enum.Font.GothamBold
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(1, 0)
    sendCorner.Parent = sendBtn

    messageInput.Parent = inputArea
    sendBtn.Parent = inputArea
    chatHistory.Parent = mainFrame
    inputArea.Parent = mainFrame

    -- Settings Panel - CŨNG NHỎ HƠN
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.Size = UDim2.new(0, 280, 0, 180)
    settingsPanel.Position = UDim2.new(0.5, -140, 0.5, -90)
    settingsPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Visible = false
    settingsPanel.ZIndex = 10
    
    local settingsPanelCorner = Instance.new("UICorner")
    settingsPanelCorner.CornerRadius = UDim.new(0, 8)
    settingsPanelCorner.Parent = settingsPanel

    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, 0, 0, 35)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "⚙ CÀI ĐẶT API"
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.TextSize = 14
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Parent = settingsPanel

    -- API Key Input
    local apiKeyContainer = Instance.new("Frame")
    apiKeyContainer.Name = "ApiKeyContainer"
    apiKeyContainer.Size = UDim2.new(1, -16, 0, 70)
    apiKeyContainer.Position = UDim2.new(0, 8, 0, 40)
    apiKeyContainer.BackgroundTransparency = 1

    local apiKeyLabel = Instance.new("TextLabel")
    apiKeyLabel.Name = "ApiKeyLabel"
    apiKeyLabel.Size = UDim2.new(1, 0, 0, 18)
    apiKeyLabel.BackgroundTransparency = 1
    apiKeyLabel.Text = "🔑 API KEY GEMINI:"
    apiKeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    apiKeyLabel.TextSize = 11
    apiKeyLabel.Font = Enum.Font.GothamBold
    apiKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    apiKeyLabel.Parent = apiKeyContainer

    local apiKeyInput = Instance.new("TextBox")
    apiKeyInput.Name = "APIKeyInput"
    apiKeyInput.Size = UDim2.new(1, 0, 0, 30)
    apiKeyInput.Position = UDim2.new(0, 0, 0, 20)
    apiKeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    apiKeyInput.BorderSizePixel = 0
    apiKeyInput.Text = CONFIG.API_KEY
    apiKeyInput.PlaceholderText = "Dán API Key vào đây..."
    apiKeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    apiKeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    apiKeyInput.TextSize = 11
    apiKeyInput.Font = Enum.Font.Gotham
    apiKeyInput.ClearTextOnFocus = false
    
    local apiKeyCorner = Instance.new("UICorner")
    apiKeyCorner.CornerRadius = UDim.new(0, 4)
    apiKeyCorner.Parent = apiKeyInput

    -- Instructions
    local instructions = Instance.new("TextLabel")
    instructions.Name = "Instructions"
    instructions.Size = UDim2.new(1, 0, 0, 25)
    instructions.Position = UDim2.new(0, 0, 0, 55)
    instructions.BackgroundTransparency = 1
    instructions.Text = "Lấy API Key: makersuite.google.com"
    instructions.TextColor3 = Color3.fromRGB(150, 150, 200)
    instructions.TextSize = 9
    instructions.Font = Enum.Font.Gotham
    instructions.TextXAlignment = Enum.TextXAlignment.Left
    instructions.Parent = apiKeyContainer

    apiKeyInput.Parent = apiKeyContainer
    apiKeyContainer.Parent = settingsPanel

    -- Save Button
    local saveBtn = Instance.new("TextButton")
    saveBtn.Name = "SaveBtn"
    saveBtn.Size = UDim2.new(1, -16, 0, 35)
    saveBtn.Position = UDim2.new(0, 8, 1, -45)
    saveBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    saveBtn.BorderSizePixel = 0
    saveBtn.Text = "💾 LƯU API KEY"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.TextSize = 12
    saveBtn.Font = Enum.Font.GothamBold
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 6)
    saveCorner.Parent = saveBtn
    saveBtn.Parent = settingsPanel

    -- Close Settings Button
    local closeSettingsBtn = Instance.new("TextButton")
    closeSettingsBtn.Name = "CloseSettingsBtn"
    closeSettingsBtn.Size = UDim2.new(0, 25, 0, 25)
    closeSettingsBtn.Position = UDim2.new(1, -30, 0, 5)
    closeSettingsBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    closeSettingsBtn.BorderSizePixel = 0
    closeSettingsBtn.Text = "X"
    closeSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeSettingsBtn.TextSize = 10
    closeSettingsBtn.Font = Enum.Font.GothamBold
    
    local closeSettingsCorner = Instance.new("UICorner")
    closeSettingsCorner.CornerRadius = UDim.new(0, 4)
    closeSettingsCorner.Parent = closeSettingsBtn
    closeSettingsBtn.Parent = settingsPanel

    settingsPanel.Parent = mainFrame
    mainFrame.Parent = screenGui

    return screenGui
end

-- Create message bubble
local function CreateMessageBubble(message, isUser)
    local bubble = Instance.new("Frame")
    bubble.Name = "MessageBubble"
    bubble.Size = UDim2.new(1, 0, 0, 0)
    bubble.BackgroundTransparency = 1
    bubble.AutomaticSize = Enum.AutomaticSize.Y

    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "MessageFrame"
    messageFrame.Size = UDim2.new(0.75, 0, 0, 0)
    messageFrame.BackgroundColor3 = isUser and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 75)
    messageFrame.BorderSizePixel = 0
    messageFrame.AutomaticSize = Enum.AutomaticSize.Y
    
    if isUser then
        messageFrame.Position = UDim2.new(1, -8, 0, 0)
        messageFrame.AnchorPoint = Vector2.new(1, 0)
    else
        messageFrame.Position = UDim2.new(0, 8, 0, 0)
    end

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = messageFrame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Size = UDim2.new(1, -12, 0, 0)
    messageLabel.Position = UDim2.new(0, 6, 0, 6)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 11
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y

    messageLabel.Parent = messageFrame
    messageFrame.Parent = bubble

    return bubble
end

-- FIXED Gemini API call
local function CallGeminiAPI(message)
    if CONFIG.API_KEY == "" or not CONFIG.API_KEY then
        return "❌ Vui lòng thiết lập API Key trong mục Cài Đặt!"
    end
    
    -- Kiểm tra API key format
    if not CONFIG.API_KEY:match("^AIza[%w-_]+$") then
        return "❌ API Key không đúng định dạng! Vui lòng kiểm tra lại."
    end
    
    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=" .. CONFIG.API_KEY
    
    local requestBody = {
        contents = {
            {
                parts = {
                    {
                        text = message
                    }
                }
            }
        }
    }
    
    local success, response = pcall(function()
        -- Sử dụng syn.request nếu có (cho executor)
        if syn and syn.request then
            local req = syn.request({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(requestBody)
            })
            return req.Body
        else
            -- Fallback cho các executor khác
            local httpSuccess, httpResponse = pcall(function()
                return game:HttpGetAsync(url, true, HttpService:JSONEncode(requestBody), Enum.HttpContentType.ApplicationJson)
            end)
            if httpSuccess then
                return httpResponse
            else
                return nil
            end
        end
    end)
    
    if success and response then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if decodeSuccess and data then
            if data.error then
                return "❌ Lỗi API: " .. (data.error.message or "Unknown error")
            elseif data.candidates and data.candidates[1] and data.candidates[1].content then
                return data.candidates[1].content.parts[1].text
            else
                return "❌ Không nhận được phản hồi từ Gemini"
            end
        else
            return "❌ Lỗi xử lý phản hồi từ server"
        end
    else
        return "❌ Lỗi kết nối: " .. tostring(response)
    end
end

-- Add message to chat
local function AddMessage(message, isUser, saveToHistory)
    local chatGUI = playerGui:FindFirstChild("GeminiChat") or CoreGui:FindFirstChild("GeminiChat")
    if not chatGUI then return end
    
    local mainFrame = chatGUI:FindFirstChild("MainFrame")
    if not mainFrame then return end
    
    local chatHistory = mainFrame:FindFirstChild("ChatHistory")
    if not chatHistory then return end
    
    local messageBubble = CreateMessageBubble(message, isUser)
    messageBubble.Parent = chatHistory
    
    if saveToHistory then
        if not CONFIG.CHAT_HISTORY[CONFIG.CURRENT_CHAT_ID] then
            CONFIG.CHAT_HISTORY[CONFIG.CURRENT_CHAT_ID] = {}
        end
        
        table.insert(CONFIG.CHAT_HISTORY[CONFIG.CURRENT_CHAT_ID], {
            message = message,
            isUser = isUser,
            timestamp = os.time()
        })
    end
    
    wait(0.05)
    chatHistory.CanvasPosition = Vector2.new(0, chatHistory.AbsoluteCanvasSize.Y)
end

-- Initialize chat
local function InitializeChat()
    if not CONFIG.CURRENT_CHAT_ID then
        CONFIG.CURRENT_CHAT_ID = GenerateID()
        CONFIG.CHAT_HISTORY[CONFIG.CURRENT_CHAT_ID] = {}
    end
    
    local chatGUI = CreateChatGUI()
    
    -- Safe parent assignment
    local success = pcall(function()
        chatGUI.Parent = playerGui
    end)
    
    if not success then
        pcall(function()
            chatGUI.Parent = CoreGui
        end)
    end
    
    -- Get references với safe check
    local mainFrame = chatGUI:FindFirstChild("MainFrame")
    if not mainFrame then return end
    
    local inputArea = mainFrame:FindFirstChild("InputArea")
    local titleBar = mainFrame:FindFirstChild("TitleBar")
    local settingsPanel = mainFrame:FindFirstChild("SettingsPanel")
    
    if not inputArea or not titleBar or not settingsPanel then return end
    
    local sendBtn = inputArea:FindFirstChild("SendBtn")
    local messageInput = inputArea:FindFirstChild("MessageInput")
    local closeBtn = titleBar:FindFirstChild("Controls"):FindFirstChild("CloseBtn")
    local settingsBtn = titleBar:FindFirstChild("SettingsBtn")
    local apiKeyInput = settingsPanel:FindFirstChild("ApiKeyContainer"):FindFirstChild("APIKeyInput")
    local saveBtn = settingsPanel:FindFirstChild("SaveBtn")
    local closeSettingsBtn = settingsPanel:FindFirstChild("CloseSettingsBtn")
    
    -- Auto show settings panel first time (vì chưa có API key)
    settingsPanel.Visible = true
    
    -- Add welcome message
    AddMessage("🤖 Chào bạn! Để sử dụng Gemini AI:", false, true)
    AddMessage("1. Dán API Key Gemini", false, true)
    AddMessage("2. Nhấn 💾 LƯU API KEY", false, true)
    AddMessage("3. Đóng cửa sổ cài đặt", false, true)
    AddMessage("4. Bắt đầu chat!", false, true)

    -- Send message function
    local function SendMessage()
        local message = messageInput and messageInput.Text or ""
        message = message:gsub("^%s*(.-)%s*$", "%1")
        if message == "" then return end
        
        if messageInput then
            messageInput.Text = ""
        end
        
        AddMessage(message, true, true)
        
        if sendBtn then
            sendBtn.Text = "..."
            sendBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
        
        spawn(function()
            local response = CallGeminiAPI(message)
            
            if sendBtn then
                sendBtn.Text = "➤"
                sendBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            end
            
            AddMessage(response, false, true)
        end)
    end

    -- Button events với safe pcall
    if sendBtn then
        sendBtn.MouseButton1Click:Connect(function()
            pcall(SendMessage)
        end)
    end
    
    if messageInput then
        messageInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                pcall(SendMessage)
            end
        end)
    end
    
    if closeBtn then
        closeBtn.MouseButton1Click:Connect(function()
            pcall(function()
                chatGUI:Destroy()
            end)
        end)
    end
    
    if settingsBtn then
        settingsBtn.MouseButton1Click:Connect(function()
            pcall(function()
                settingsPanel.Visible = not settingsPanel.Visible
            end)
        end)
    end
    
    if saveBtn then
        saveBtn.MouseButton1Click:Connect(function()
            pcall(function()
                if apiKeyInput then
                    local newApiKey = apiKeyInput.Text:gsub("^%s*(.-)%s*$", "%1")
                    if newApiKey ~= "" then
                        CONFIG.API_KEY = newApiKey
                        settingsPanel.Visible = false
                        AddMessage("✅ API Key đã được lưu!", false, true)
                        AddMessage("Bạn có thể bắt đầu chat ngay!", false, true)
                    else
                        AddMessage("❌ Vui lòng nhập API Key!", false, true)
                    end
                end
            end)
        end)
    end
    
    if closeSettingsBtn then
        closeSettingsBtn.MouseButton1Click:Connect(function()
            pcall(function()
                settingsPanel.Visible = false
            end)
        end)
    end
    
    -- Window dragging
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        if mainFrame and dragStart and startPos then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    
    if titleBar then
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        
        titleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
    end
    
    if UserInputService then
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                pcall(function()
                    update(input)
                end)
            end
        end)
    end
end

-- Main execution với error handling
local success, err = pcall(InitializeChat)

if not success then
    warn("Gemini Chat Error: " .. tostring(err))
end