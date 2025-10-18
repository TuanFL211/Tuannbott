-- Gemini Chatbot Script for Roblox
-- Supported Executors: KRNL, Delta, Fluxus, Synapse

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local CONFIG = {
    API_KEY = "AIzaSyAFyB_C2KtOXYjRsjK52jeL-qOGkRaBBPA",
    ENABLED_EFFECTS = true,
    CHAT_HISTORY = {}
}

-- Load saved data
local function LoadData()
    local success, data = pcall(function()
        if readfile and isfile then
            if isfile("gemini_chat_config.json") then
                return HttpService:JSONDecode(readfile("gemini_chat_config.json"))
            end
        end
        return nil
    end)
    
    if success and data then
        if data.API_KEY then CONFIG.API_KEY = data.API_KEY end
        if data.ENABLED_EFFECTS ~= nil then CONFIG.ENABLED_EFFECTS = data.ENABLED_EFFECTS end
        if data.CHAT_HISTORY then CONFIG.CHAT_HISTORY = data.CHAT_HISTORY end
    end
end

-- Save data
local function SaveData()
    local success, err = pcall(function()
        if writefile and makefolder then
            if not isfile("gemini_chat_config.json") then
                writefile("gemini_chat_config.json", HttpService:JSONEncode(CONFIG))
            else
                writefile("gemini_chat_config.json", HttpService:JSONEncode(CONFIG))
            end
        end
    end)
    
    if not success then
        warn("Failed to save data: " .. tostring(err))
    end
end

-- Create main GUI
local function CreateChatGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GeminiChat"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    -- Main chat frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Drop shadow
    if CONFIG.ENABLED_EFFECTS then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://1316045217"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.5
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(10, 10, 118, 118)
        shadow.ZIndex = -1
        shadow.Parent = mainFrame
    end

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Tuann chatbot"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Control buttons
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0, 90, 1, 0)
    controls.Position = UDim2.new(1, -95, 0, 0)
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
    minimizeBtn.TextSize = 14
    minimizeBtn.Font = Enum.Font.GothamBold
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn

    -- Maximize button
    local maximizeBtn = Instance.new("TextButton")
    maximizeBtn.Name = "MaximizeBtn"
    maximizeBtn.Size = UDim2.new(0, 25, 0, 25)
    maximizeBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    maximizeBtn.BorderSizePixel = 0
    maximizeBtn.Text = "□"
    maximizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    maximizeBtn.TextSize = 12
    maximizeBtn.Font = Enum.Font.GothamBold
    
    local maximizeCorner = Instance.new("UICorner")
    maximizeCorner.CornerRadius = UDim.new(0, 6)
    maximizeCorner.Parent = maximizeBtn

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
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    minimizeBtn.Parent = controls
    maximizeBtn.Parent = controls
    closeBtn.Parent = controls
    titleBar.Parent = mainFrame
    controls.Parent = titleBar

    -- Settings button
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Name = "SettingsBtn"
    settingsBtn.Size = UDim2.new(0, 30, 0, 30)
    settingsBtn.Position = UDim2.new(1, -130, 0, 5)
    settingsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    settingsBtn.BorderSizePixel = 0
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsBtn.TextSize = 16
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 6)
    settingsCorner.Parent = settingsBtn
    settingsBtn.Parent = titleBar

    -- Chat history frame
    local chatHistory = Instance.new("ScrollingFrame")
    chatHistory.Name = "ChatHistory"
    chatHistory.Size = UDim2.new(1, -20, 1, -120)
    chatHistory.Position = UDim2.new(0, 10, 0, 50)
    chatHistory.BackgroundTransparency = 1
    chatHistory.BorderSizePixel = 0
    chatHistory.ScrollBarThickness = 6
    chatHistory.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatHistory.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.Padding = UDim.new(0, 10)
    chatLayout.Parent = chatHistory

    -- Input area
    local inputArea = Instance.new("Frame")
    inputArea.Name = "InputArea"
    inputArea.Size = UDim2.new(1, -20, 0, 50)
    inputArea.Position = UDim2.new(0, 10, 1, -60)
    inputArea.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    inputArea.BorderSizePixel = 0
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 25)
    inputCorner.Parent = inputArea

    -- Message input
    local messageInput = Instance.new("TextBox")
    messageInput.Name = "MessageInput"
    messageInput.Size = UDim2.new(1, -70, 1, 0)
    messageInput.Position = UDim2.new(0, 15, 0, 0)
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
    sendBtn.Size = UDim2.new(0, 40, 0, 40)
    sendBtn.Position = UDim2.new(1, -50, 0, 5)
    sendBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    sendBtn.BorderSizePixel = 0
    sendBtn.Text = "➤"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.TextSize = 16
    sendBtn.Font = Enum.Font.GothamBold
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(1, 0)
    sendCorner.Parent = sendBtn

    messageInput.Parent = inputArea
    sendBtn.Parent = inputArea
    chatHistory.Parent = mainFrame
    inputArea.Parent = mainFrame
    mainFrame.Parent = screenGui

    -- Settings panel
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.Size = UDim2.new(0, 300, 0, 200)
    settingsPanel.Position = UDim2.new(0, 10, 0, 50)
    settingsPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Visible = false
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 12)
    settingsCorner.Parent = settingsPanel

    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, 0, 0, 40)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "Cài Đặt"
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.TextSize = 18
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Parent = settingsPanel

    -- Effects toggle
    local effectsToggle = Instance.new("TextButton")
    effectsToggle.Name = "EffectsToggle"
    effectsToggle.Size = UDim2.new(1, -20, 0, 40)
    effectsToggle.Position = UDim2.new(0, 10, 0, 50)
    effectsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    effectsToggle.BorderSizePixel = 0
    effectsToggle.Text = "Hiệu ứng: " .. (CONFIG.ENABLED_EFFECTS and "BẬT" : "TẮT")
    effectsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    effectsToggle.TextSize = 14
    effectsToggle.Font = Enum.Font.Gotham
    
    local effectsCorner = Instance.new("UICorner")
    effectsCorner.CornerRadius = UDim.new(0, 8)
    effectsCorner.Parent = effectsToggle

    -- API Key input
    local apiKeyInput = Instance.new("TextBox")
    apiKeyInput.Name = "APIKeyInput"
    apiKeyInput.Size = UDim2.new(1, -20, 0, 40)
    apiKeyInput.Position = UDim2.new(0, 10, 0, 100)
    apiKeyInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    apiKeyInput.BorderSizePixel = 0
    apiKeyInput.Text = CONFIG.API_KEY
    apiKeyInput.PlaceholderText = "Nhập API Key mới..."
    apiKeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    apiKeyInput.TextSize = 12
    apiKeyInput.Font = Enum.Font.Gotham
    apiKeyInput.ClearTextOnFocus = false
    
    local apiKeyCorner = Instance.new("UICorner")
    apiKeyCorner.CornerRadius = UDim.new(0, 8)
    apiKeyCorner.Parent = apiKeyInput

    effectsToggle.Parent = settingsPanel
    apiKeyInput.Parent = settingsPanel
    settingsPanel.Parent = mainFrame

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
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = messageFrame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Size = UDim2.new(1, -20, 0, 0)
    messageLabel.Position = UDim2.new(0, 10, 0, 10)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y

    messageLabel.Parent = messageFrame
    messageFrame.Parent = bubble

    return bubble
end

-- Gemini API call
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
        return game:HttpGetAsync(url, HttpService:JSONEncode(requestBody), Enum.HttpContentType.ApplicationJson)
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.candidates and data.candidates[1] then
            return data.candidates[1].content.parts[1].text
        else
            return "Lỗi: Không thể nhận phản hồi từ Gemini"
        end
    else
        return "Lỗi kết nối: " .. tostring(response)
    end
end

-- Add message to chat
local function AddMessage(message, isUser, saveToHistory)
    local chatGUI = playerGui:FindFirstChild("GeminiChat")
    if not chatGUI then return end
    
    local chatHistory = chatGUI.MainFrame.ChatHistory
    local messageBubble = CreateMessageBubble(message, isUser)
    
    if CONFIG.ENABLED_EFFECTS then
        messageBubble.MessageFrame.Size = UDim2.new(0, 0, 0, 0)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(messageBubble.MessageFrame, tweenInfo, {Size = UDim2.new(0.7, 0, 0, messageBubble.MessageFrame.MessageLabel.TextBounds.Y + 20)})
        tween:Play()
    end
    
    messageBubble.Parent = chatHistory
    
    if saveToHistory then
        table.insert(CONFIG.CHAT_HISTORY, {
            message = message,
            isUser = isUser,
            timestamp = os.time()
        })
        SaveData()
    end
end

-- Load chat history
local function LoadChatHistory()
    for _, chat in ipairs(CONFIG.CHAT_HISTORY) do
        AddMessage(chat.message, chat.isUser, false)
    end
end

-- Initialize chat
local function InitializeChat()
    LoadData()
    
    local chatGUI = CreateChatGUI()
    chatGUI.Parent = playerGui
    
    -- Load existing chat history
    LoadChatHistory()
    
    -- Set up event handlers
    local mainFrame = chatGUI.MainFrame
    local sendBtn = mainFrame.InputArea.SendBtn
    local messageInput = mainFrame.InputArea.MessageInput
    local minimizeBtn = mainFrame.TitleBar.Controls.MinimizeBtn
    local maximizeBtn = mainFrame.TitleBar.Controls.MaximizeBtn
    local closeBtn = mainFrame.TitleBar.Controls.CloseBtn
    local settingsBtn = mainFrame.TitleBar.SettingsBtn
    local settingsPanel = mainFrame.SettingsPanel
    local effectsToggle = settingsPanel.EffectsToggle
    local apiKeyInput = settingsPanel.APIKeyInput
    
    -- Send message function
    local function SendMessage()
        local message = messageInput.Text:gsub("^%s*(.-)%s*$", "%1")
        if message == "" then return end
        
        messageInput.Text = ""
        AddMessage(message, true, true)
        
        -- Simulate typing
        local thinkingMsg = AddMessage("Đang suy nghĩ...", false, false)
        
        -- Call Gemini API
        spawn(function()
            local response = CallGeminiAPI(message)
            
            -- Remove thinking message and add actual response
            if thinkingMsg and thinkingMsg.Parent then
                thinkingMsg:Destroy()
            end
            
            AddMessage(response, false, true)
        end)
    end
    
    -- Button events
    sendBtn.MouseButton1Click:Connect(SendMessage)
    
    messageInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            SendMessage()
        end
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        -- You can implement minimize logic here
    end)
    
    maximizeBtn.MouseButton1Click:Connect(function()
        if mainFrame.Size == UDim2.new(0, 600, 0, 400) then
            mainFrame.Size = UDim2.new(0, 800, 0, 600)
            mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
        else
            mainFrame.Size = UDim2.new(0, 600, 0, 400)
            mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        chatGUI:Destroy()
    end)
    
    settingsBtn.MouseButton1Click:Connect(function()
        settingsPanel.Visible = not settingsPanel.Visible
    end)
    
    effectsToggle.MouseButton1Click:Connect(function()
        CONFIG.ENABLED_EFFECTS = not CONFIG.ENABLED_EFFECTS
        effectsToggle.Text = "Hiệu ứng: " .. (CONFIG.ENABLED_EFFECTS and "BẬT" : "TẮT")
        SaveData()
    end)
    
    apiKeyInput.FocusLost:Connect(function()
        CONFIG.API_KEY = apiKeyInput.Text
        SaveData()
    end)
    
    -- Make window draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    mainFrame.TitleBar.InputBegan:Connect(function(input)
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
    
    mainFrame.TitleBar.InputChanged:Connect(function(input)
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

-- Start the chat
InitializeChat()