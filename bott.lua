-- Gemini Chatbot Script for Roblox - Fixed Version
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

-- Safe wait for CoreGui
local CoreGui = game:GetService("CoreGui")
while not CoreGui do
    wait(0.1)
    CoreGui = game:FindService("CoreGui")
end

-- Configuration
local CONFIG = {
    API_KEY = "AIzaSyAFyB_C2KtOXYjRsjK52jeL-qOGkRaBBPA",
    ENABLED_EFFECTS = true,
    CHAT_HISTORY = {},
    CURRENT_CHAT_ID = nil
}

-- Safe function to generate ID
local function GenerateID()
    return tostring(math.random(1, 1000000)) .. "_" .. tostring(tick())
end

-- Safe function to create gradient
local function CreateGradient(color1, color2)
    local gradient = Instance.new("UIGradient")
    if color1 and color2 then
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2)
        })
    end
    gradient.Rotation = 45
    return gradient
end

-- Safe destroy function
local function SafeDestroy(obj)
    if obj and obj.Parent then
        obj:Destroy()
    end
end

-- Safe clear function
local function SafeClear(parent)
    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            SafeDestroy(child)
        end
    end
end

-- Check if GUI already exists and remove it
local function CleanupExistingGUI()
    local existingGUI = playerGui:FindFirstChild("GeminiChat")
    if existingGUI then
        SafeDestroy(existingGUI)
    end
    
    local coreGUI = CoreGui:FindFirstChild("GeminiChat")
    if coreGUI then
        SafeDestroy(coreGUI)
    end
end

-- Safe Tween function
local function SafeTween(obj, tweenInfo, properties)
    if obj and obj.Parent then
        local success, result = pcall(function()
            return TweenService:Create(obj, tweenInfo, properties)
        end)
        if success and result then
            result:Play()
            return result
        end
    end
    return nil
end

-- Create main GUI với bảo vệ an toàn
local function CreateChatGUI()
    -- Clean up existing GUI first
    CleanupExistingGUI()
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GeminiChat"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    -- Main chat frame với tỷ lệ 16:9
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 640, 0, 360)
    mainFrame.Position = UDim2.new(0.5, -320, 0.5, -180)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    
    -- Corner radius an toàn
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Gemini AI Chat"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Control buttons đơn giản
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0, 80, 1, 0)
    controls.Position = UDim2.new(1, -85, 0, 0)
    controls.BackgroundTransparency = 1
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.FillDirection = Enum.FillDirection.Horizontal
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.Parent = controls

    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "_"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextSize = 12
    minimizeBtn.Font = Enum.Font.GothamBold
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = minimizeBtn

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn

    minimizeBtn.Parent = controls
    closeBtn.Parent = controls
    titleBar.Parent = mainFrame
    controls.Parent = titleBar

    -- Settings button
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Name = "SettingsBtn"
    settingsBtn.Size = UDim2.new(0, 30, 0, 30)
    settingsBtn.Position = UDim2.new(1, -120, 0.5, -15)
    settingsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    settingsBtn.BorderSizePixel = 0
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsBtn.TextSize = 14
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 4)
    settingsCorner.Parent = settingsBtn
    settingsBtn.Parent = titleBar

    -- Chat history frame
    local chatHistory = Instance.new("ScrollingFrame")
    chatHistory.Name = "ChatHistory"
    chatHistory.Size = UDim2.new(1, -20, 1, -100)
    chatHistory.Position = UDim2.new(0, 10, 0, 45)
    chatHistory.BackgroundTransparency = 1
    chatHistory.BorderSizePixel = 0
    chatHistory.ScrollBarThickness = 6
    chatHistory.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatHistory.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.Padding = UDim.new(0, 8)
    chatLayout.Parent = chatHistory

    -- Input area
    local inputArea = Instance.new("Frame")
    inputArea.Name = "InputArea"
    inputArea.Size = UDim2.new(1, -20, 0, 45)
    inputArea.Position = UDim2.new(0, 10, 1, -55)
    inputArea.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    inputArea.BorderSizePixel = 0
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputArea

    -- Message input
    local messageInput = Instance.new("TextBox")
    messageInput.Name = "MessageInput"
    messageInput.Size = UDim2.new(1, -60, 1, -10)
    messageInput.Position = UDim2.new(0, 10, 0, 5)
    messageInput.BackgroundTransparency = 1
    messageInput.Text = ""
    messageInput.PlaceholderText = "Nhập tin nhắn..."
    messageInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageInput.TextSize = 14
    messageInput.Font = Enum.Font.Gotham
    messageInput.TextXAlignment = Enum.TextXAlignment.Left
    messageInput.ClearTextOnFocus = false

    -- Send button
    local sendBtn = Instance.new("TextButton")
    sendBtn.Name = "SendBtn"
    sendBtn.Size = UDim2.new(0, 35, 0, 35)
    sendBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
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

    -- Settings panel đơn giản
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.Size = UDim2.new(0, 250, 0, 150)
    settingsPanel.Position = UDim2.new(0, 10, 0, 45)
    settingsPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Visible = false
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 8)
    settingsCorner.Parent = settingsPanel

    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, 0, 0, 30)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "Cài Đặt"
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.TextSize = 14
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Parent = settingsPanel

    -- Effects toggle
    local effectsToggle = Instance.new("TextButton")
    effectsToggle.Name = "EffectsToggle"
    effectsToggle.Size = UDim2.new(1, -20, 0, 35)
    effectsToggle.Position = UDim2.new(0, 10, 0, 40)
    effectsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    effectsToggle.BorderSizePixel = 0
    effectsToggle.Text = "Hiệu ứng: " .. (CONFIG.ENABLED_EFFECTS and "BẬT" : "TẮT")
    effectsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    effectsToggle.TextSize = 12
    effectsToggle.Font = Enum.Font.Gotham
    
    local effectsCorner = Instance.new("UICorner")
    effectsCorner.CornerRadius = UDim.new(0, 6)
    effectsCorner.Parent = effectsToggle

    -- API Key input
    local apiKeyInput = Instance.new("TextBox")
    apiKeyInput.Name = "APIKeyInput"
    apiKeyInput.Size = UDim2.new(1, -20, 0, 35)
    apiKeyInput.Position = UDim2.new(0, 10, 0, 85)
    apiKeyInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    apiKeyInput.BorderSizePixel = 0
    apiKeyInput.Text = CONFIG.API_KEY
    apiKeyInput.PlaceholderText = "Nhập API Key mới..."
    apiKeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    apiKeyInput.TextSize = 12
    apiKeyInput.Font = Enum.Font.Gotham
    apiKeyInput.ClearTextOnFocus = false
    
    local apiKeyCorner = Instance.new("UICorner")
    apiKeyCorner.CornerRadius = UDim.new(0, 6)
    apiKeyCorner.Parent = apiKeyInput

    effectsToggle.Parent = settingsPanel
    apiKeyInput.Parent = settingsPanel
    settingsPanel.Parent = mainFrame

    mainFrame.Parent = screenGui

    return screenGui
end

-- Create message bubble đơn giản
local function CreateMessageBubble(message, isUser)
    local bubble = Instance.new("Frame")
    bubble.Name = "MessageBubble"
    bubble.Size = UDim2.new(1, 0, 0, 0)
    bubble.BackgroundTransparency = 1
    bubble.AutomaticSize = Enum.AutomaticSize.Y

    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "MessageFrame"
    messageFrame.Size = UDim2.new(0.7, 0, 0, 0)
    messageFrame.BackgroundColor3 = isUser and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 70)
    messageFrame.BorderSizePixel = 0
    messageFrame.AutomaticSize = Enum.AutomaticSize.Y
    
    if isUser then
        messageFrame.Position = UDim2.new(1, -10, 0, 0)
        messageFrame.AnchorPoint = Vector2.new(1, 0)
    else
        messageFrame.Position = UDim2.new(0, 10, 0, 0)
    end

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = messageFrame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Size = UDim2.new(1, -16, 0, 0)
    messageLabel.Position = UDim2.new(0, 8, 0, 8)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y

    messageLabel.Parent = messageFrame
    messageFrame.Parent = bubble

    return bubble
end

-- Safe Gemini API call
local function CallGeminiAPI(message)
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
            return game:HttpGetAsync(url, true, HttpService:JSONEncode(requestBody), Enum.HttpContentType.ApplicationJson)
        end
    end)
    
    if success and response then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if decodeSuccess and data and data.candidates and data.candidates[1] and data.candidates[1].content then
            return data.candidates[1].content.parts[1].text
        else
            return "Lỗi: Không thể nhận phản hồi từ Gemini. Vui lòng kiểm tra API Key."
        end
    else
        return "Lỗi kết nối: " .. tostring(response)
    end
end

-- Safe add message to chat
local function AddMessage(message, isUser, saveToHistory)
    local chatGUI = playerGui:FindFirstChild("GeminiChat") or CoreGui:FindFirstChild("GeminiChat")
    if not chatGUI then return end
    
    local mainFrame = chatGUI:FindFirstChild("MainFrame")
    if not mainFrame then return end
    
    local chatHistory = mainFrame:FindFirstChild("ChatHistory")
    if not chatHistory then return end
    
    local messageBubble = CreateMessageBubble(message, isUser)
    
    if CONFIG.ENABLED_EFFECTS and messageBubble and messageBubble.MessageFrame then
        SafeTween(messageBubble.MessageFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.7, 0, 0, messageBubble.MessageFrame.MessageLabel.TextBounds.Y + 16)})
    end
    
    if messageBubble then
        messageBubble.Parent = chatHistory
    end
    
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
    
    -- Auto scroll to bottom
    wait(0.05)
    if chatHistory then
        chatHistory.CanvasPosition = Vector2.new(0, chatHistory.AbsoluteCanvasSize.Y)
    end
end

-- Safe initialize chat
local function InitializeChat()
    -- Initialize current chat ID
    if not CONFIG.CURRENT_CHAT_ID then
        CONFIG.CURRENT_CHAT_ID = GenerateID()
        CONFIG.CHAT_HISTORY[CONFIG.CURRENT_CHAT_ID] = {}
    end
    
    local chatGUI = CreateChatGUI()
    
    -- Thử parent vào PlayerGui trước, nếu không được thì dùng CoreGui
    local success = pcall(function()
        chatGUI.Parent = playerGui
    end)
    
    if not success then
        chatGUI.Parent = CoreGui
    end
    
    -- Set up event handlers với bảo vệ
    local mainFrame = chatGUI:FindFirstChild("MainFrame")
    if not mainFrame then return end
    
    local inputArea = mainFrame:FindFirstChild("InputArea")
    local titleBar = mainFrame:FindFirstChild("TitleBar")
    
    if not inputArea or not titleBar then return end
    
    local sendBtn = inputArea:FindFirstChild("SendBtn")
    local messageInput = inputArea:FindFirstChild("MessageInput")
    local minimizeBtn = titleBar:FindFirstChild("Controls"):FindFirstChild("MinimizeBtn")
    local closeBtn = titleBar:FindFirstChild("Controls"):FindFirstChild("CloseBtn")
    local settingsBtn = titleBar:FindFirstChild("SettingsBtn")
    local settingsPanel = mainFrame:FindFirstChild("SettingsPanel")
    
    if not sendBtn or not messageInput or not minimizeBtn or not closeBtn or not settingsBtn or not settingsPanel then return end
    
    local effectsToggle = settingsPanel:FindFirstChild("EffectsToggle")
    local apiKeyInput = settingsPanel:FindFirstChild("APIKeyInput")
    
    -- Add welcome message
    AddMessage("Xin chào! Tôi là Gemini AI. Tôi có thể giúp gì cho bạn?", false, true)
    
    -- Safe send message function
    local function SendMessage()
        local message = messageInput.Text:gsub("^%s*(.-)%s*$", "%1")
        if message == "" then return end
        
        messageInput.Text = ""
        AddMessage(message, true, true)
        
        -- Disable send button while processing
        if sendBtn then
            sendBtn.Text = "..."
            sendBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
        
        -- Safe call Gemini API
        spawn(function()
            local response = CallGeminiAPI(message)
            
            -- Re-enable send button
            if sendBtn then
                sendBtn.Text = "➤"
                sendBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            end
            
            AddMessage(response, false, true)
        end)
    end
    
    -- Safe button events
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
    
    if minimizeBtn then
        minimizeBtn.MouseButton1Click:Connect(function()
            if mainFrame then
                mainFrame.Visible = false
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
            if settingsPanel then
                settingsPanel.Visible = not settingsPanel.Visible
            end
        end)
    end
    
    if effectsToggle then
        effectsToggle.MouseButton1Click:Connect(function()
            CONFIG.ENABLED_EFFECTS = not CONFIG.ENABLED_EFFECTS
            effectsToggle.Text = "Hiệu ứng: " .. (CONFIG.ENABLED_EFFECTS and "BẬT" : "TẮT")
        end)
    end
    
    if apiKeyInput then
        apiKeyInput.FocusLost:Connect(function()
            CONFIG.API_KEY = apiKeyInput.Text
            if settingsPanel then
                settingsPanel.Visible = false
            end
            AddMessage("API Key đã được cập nhật!", false, true)
        end)
    end
    
    -- Safe window dragging
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
    
    -- Safe close settings when clicking outside
    if UserInputService then
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and settingsPanel and settingsPanel.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local settingsAbsolutePos = settingsPanel.AbsolutePosition
                local settingsAbsoluteSize = settingsPanel.AbsoluteSize
                
                if not (mousePos.X >= settingsAbsolutePos.X and mousePos.X <= settingsAbsolutePos.X + settingsAbsoluteSize.X and
                       mousePos.Y >= settingsAbsolutePos.Y and mousePos.Y <= settingsAbsolutePos.Y + settingsAbsoluteSize.Y) then
                    settingsPanel.Visible = false
                end
            end
        end)
    end
end

-- Main execution với bảo vệ hoàn toàn
local success, error = pcall(function()
    InitializeChat()
end)

if not success then
    warn("Gemini Chat khởi động thất bại: " .. tostring(error))
    
    -- Fallback GUI đơn giản
    local fallbackGUI = Instance.new("ScreenGui")
    fallbackGUI.Name = "GeminiChatFallback"
    fallbackGUI.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.Parent = fallbackGUI
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Gemini Chat\nĐã khởi động ở chế độ đơn giản\nLỗi: " .. tostring(error)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.TextWrapped = true
    label.Parent = frame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 100, 0, 30)
    closeBtn.Position = UDim2.new(0.5, -50, 1, -40)
    closeBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    closeBtn.Text = "Đóng"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        fallbackGUI:Destroy()
    end)
end