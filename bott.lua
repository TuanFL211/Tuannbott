-- Gemini Chatbot Script for Roblox
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

-- Configuration
local CONFIG = {
    API_KEY = "AIzaSyAFyB_C2KtOXYjRsjK52jeL-qOGkRaBBPA",
    ENABLED_EFFECTS = true,
    CHAT_HISTORY = {},
    CURRENT_CHAT_ID = nil
}

-- Generate unique ID
local function GenerateID()
    return tostring(math.random(1, 1000000)) .. "_" .. tostring(tick())
end

-- Create modern gradient
local function CreateGradient(color1, color2)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Rotation = 45
    return gradient
end

-- Create main GUI
local function CreateChatGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GeminiChat"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    -- Main chat frame với tỷ lệ 16:9
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 640, 0, 360) -- 16:9 ratio
    mainFrame.Position = UDim2.new(0.5, -320, 0.5, -180)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    
    -- Gradient background
    local backgroundGradient = CreateGradient(Color3.fromRGB(30, 30, 45), Color3.fromRGB(20, 20, 30))
    backgroundGradient.Parent = mainFrame
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    -- Modern shadow effect
    if CONFIG.ENABLED_EFFECTS then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 24, 1, 24)
        shadow.Position = UDim2.new(0, -12, 0, -12)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://1316045217"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.6
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(10, 10, 118, 118)
        shadow.ZIndex = -1
        shadow.Parent = mainFrame
    end

    -- Title bar với gradient
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    titleBar.BorderSizePixel = 0
    
    local titleGradient = CreateGradient(Color3.fromRGB(45, 45, 65), Color3.fromRGB(35, 35, 50))
    titleGradient.Parent = titleBar
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar
    
    -- Title với icon
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.Size = UDim2.new(0, 200, 1, 0)
    titleContainer.Position = UDim2.new(0, 15, 0, 0)
    titleContainer.BackgroundTransparency = 1
    
    local titleIcon = Instance.new("TextLabel")
    titleIcon.Name = "TitleIcon"
    titleIcon.Size = UDim2.new(0, 30, 0, 30)
    titleIcon.Position = UDim2.new(0, 0, 0.5, -15)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = "🤖"
    titleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleIcon.TextSize = 18
    titleIcon.Font = Enum.Font.GothamBold
    titleIcon.Parent = titleContainer
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 35, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Gemini AI Chat"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleContainer

    -- Control buttons với modern style
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0, 100, 1, 0)
    controls.Position = UDim2.new(1, -105, 0, 0)
    controls.BackgroundTransparency = 1
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.FillDirection = Enum.FillDirection.Horizontal
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    uiListLayout.Padding = UDim.new(0, 8)
    uiListLayout.Parent = controls

    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "_"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextSize = 16
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.AutoButtonColor = false
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(1, 0)
    minimizeCorner.Parent = minimizeBtn

    -- Maximize button
    local maximizeBtn = Instance.new("TextButton")
    maximizeBtn.Name = "MaximizeBtn"
    maximizeBtn.Size = UDim2.new(0, 28, 0, 28)
    maximizeBtn.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    maximizeBtn.BorderSizePixel = 0
    maximizeBtn.Text = "□"
    maximizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    maximizeBtn.TextSize = 12
    maximizeBtn.Font = Enum.Font.GothamBold
    maximizeBtn.AutoButtonColor = false
    
    local maximizeCorner = Instance.new("UICorner")
    maximizeCorner.CornerRadius = UDim.new(1, 0)
    maximizeCorner.Parent = maximizeBtn

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn

    minimizeBtn.Parent = controls
    maximizeBtn.Parent = controls
    closeBtn.Parent = controls
    titleContainer.Parent = titleBar
    titleBar.Parent = mainFrame
    controls.Parent = titleBar

    -- Settings button
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Name = "SettingsBtn"
    settingsBtn.Size = UDim2.new(0, 32, 0, 32)
    settingsBtn.Position = UDim2.new(1, -140, 0.5, -16)
    settingsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    settingsBtn.BorderSizePixel = 0
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsBtn.TextSize = 16
    settingsBtn.AutoButtonColor = false
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(1, 0)
    settingsCorner.Parent = settingsBtn
    settingsBtn.Parent = titleBar

    -- Chat history frame với gradient
    local chatHistory = Instance.new("ScrollingFrame")
    chatHistory.Name = "ChatHistory"
    chatHistory.Size = UDim2.new(1, -20, 1, -130)
    chatHistory.Position = UDim2.new(0, 10, 0, 55)
    chatHistory.BackgroundTransparency = 1
    chatHistory.BorderSizePixel = 0
    chatHistory.ScrollBarThickness = 6
    chatHistory.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    chatHistory.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatHistory.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.Padding = UDim.new(0, 12)
    chatLayout.Parent = chatHistory
    
    local chatPadding = Instance.new("UIPadding")
    chatPadding.PaddingTop = UDim.new(0, 5)
    chatPadding.PaddingBottom = UDim.new(0, 5)
    chatPadding.Parent = chatHistory

    -- Input area với modern design
    local inputArea = Instance.new("Frame")
    inputArea.Name = "InputArea"
    inputArea.Size = UDim2.new(1, -20, 0, 55)
    inputArea.Position = UDim2.new(0, 10, 1, -65)
    inputArea.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    inputArea.BorderSizePixel = 0
    
    local inputGradient = CreateGradient(Color3.fromRGB(50, 50, 70), Color3.fromRGB(40, 40, 55))
    inputGradient.Parent = inputArea
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 25)
    inputCorner.Parent = inputArea

    -- Message input
    local messageInput = Instance.new("TextBox")
    messageInput.Name = "MessageInput"
    messageInput.Size = UDim2.new(1, -75, 1, -10)
    messageInput.Position = UDim2.new(0, 15, 0, 5)
    messageInput.BackgroundTransparency = 1
    messageInput.Text = ""
    messageInput.PlaceholderText = "Nhập tin nhắn của bạn..."
    messageInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    messageInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageInput.TextSize = 14
    messageInput.Font = Enum.Font.Gotham
    messageInput.TextXAlignment = Enum.TextXAlignment.Left
    messageInput.ClearTextOnFocus = false
    messageInput.TextWrapped = true

    -- Send button với gradient
    local sendBtn = Instance.new("TextButton")
    sendBtn.Name = "SendBtn"
    sendBtn.Size = UDim2.new(0, 45, 0, 45)
    sendBtn.Position = UDim2.new(1, -55, 0.5, -22.5)
    sendBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    sendBtn.BorderSizePixel = 0
    sendBtn.Text = "➤"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.TextSize = 18
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.AutoButtonColor = false
    
    local sendGradient = CreateGradient(Color3.fromRGB(86, 185, 90), Color3.fromRGB(76, 175, 80))
    sendGradient.Parent = sendBtn
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(1, 0)
    sendCorner.Parent = sendBtn

    messageInput.Parent = inputArea
    sendBtn.Parent = inputArea
    chatHistory.Parent = mainFrame
    inputArea.Parent = mainFrame

    -- Settings panel với modern design
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.Size = UDim2.new(0, 320, 0, 220)
    settingsPanel.Position = UDim2.new(0, 10, 0, 55)
    settingsPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Visible = false
    settingsPanel.ZIndex = 10
    
    local settingsPanelGradient = CreateGradient(Color3.fromRGB(45, 45, 65), Color3.fromRGB(35, 35, 50))
    settingsPanelGradient.Parent = settingsPanel
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 16)
    settingsCorner.Parent = settingsPanel

    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, 0, 0, 45)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "⚙ Cài Đặt"
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.TextSize = 18
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Parent = settingsPanel

    -- Effects toggle
    local effectsToggle = Instance.new("TextButton")
    effectsToggle.Name = "EffectsToggle"
    effectsToggle.Size = UDim2.new(1, -20, 0, 45)
    effectsToggle.Position = UDim2.new(0, 10, 0, 55)
    effectsToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    effectsToggle.BorderSizePixel = 0
    effectsToggle.Text = "✨ Hiệu ứng: " .. (CONFIG.ENABLED_EFFECTS and "BẬT" : "TẮT")
    effectsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    effectsToggle.TextSize = 14
    effectsToggle.Font = Enum.Font.Gotham
    effectsToggle.AutoButtonColor = false
    
    local effectsCorner = Instance.new("UICorner")
    effectsCorner.CornerRadius = UDim.new(0, 10)
    effectsCorner.Parent = effectsToggle

    -- API Key input
    local apiKeyInput = Instance.new("TextBox")
    apiKeyInput.Name = "APIKeyInput"
    apiKeyInput.Size = UDim2.new(1, -20, 0, 45)
    apiKeyInput.Position = UDim2.new(0, 10, 0, 110)
    apiKeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    apiKeyInput.BorderSizePixel = 0
    apiKeyInput.Text = CONFIG.API_KEY
    apiKeyInput.PlaceholderText = "🔑 Nhập API Key mới..."
    apiKeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    apiKeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    apiKeyInput.TextSize = 12
    apiKeyInput.Font = Enum.Font.Gotham
    apiKeyInput.ClearTextOnFocus = false
    
    local apiKeyCorner = Instance.new("UICorner")
    apiKeyCorner.CornerRadius = UDim.new(0, 10)
    apiKeyCorner.Parent = apiKeyInput

    -- Save settings button
    local saveSettingsBtn = Instance.new("TextButton")
    saveSettingsBtn.Name = "SaveSettingsBtn"
    saveSettingsBtn.Size = UDim2.new(1, -20, 0, 40)
    saveSettingsBtn.Position = UDim2.new(0, 10, 1, -50)
    saveSettingsBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    saveSettingsBtn.BorderSizePixel = 0
    saveSettingsBtn.Text = "💾 Lưu Cài Đặt"
    saveSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveSettingsBtn.TextSize = 14
    saveSettingsBtn.Font = Enum.Font.GothamBold
    saveSettingsBtn.AutoButtonColor = false
    
    local saveSettingsCorner = Instance.new("UICorner")
    saveSettingsCorner.CornerRadius = UDim.new(0, 10)
    saveSettingsCorner.Parent = saveSettingsBtn

    effectsToggle.Parent = settingsPanel
    apiKeyInput.Parent = settingsPanel
    saveSettingsBtn.Parent = settingsPanel
    settingsPanel.Parent = mainFrame

    -- Chat history panel
    local historyPanel = Instance.new("Frame")
    historyPanel.Name = "HistoryPanel"
    historyPanel.Size = UDim2.new(0, 280, 0, 300)
    historyPanel.Position = UDim2.new(0, 10, 0, 55)
    historyPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    historyPanel.BorderSizePixel = 0
    historyPanel.Visible = false
    historyPanel.ZIndex = 10
    
    local historyGradient = CreateGradient(Color3.fromRGB(45, 45, 65), Color3.fromRGB(35, 35, 50))
    historyGradient.Parent = historyPanel
    
    local historyCorner = Instance.new("UICorner")
    historyCorner.CornerRadius = UDim.new(0, 16)
    historyCorner.Parent = historyPanel

    local historyTitle = Instance.new("TextLabel")
    historyTitle.Name = "HistoryTitle"
    historyTitle.Size = UDim2.new(1, 0, 0, 45)
    historyTitle.BackgroundTransparency = 1
    historyTitle.Text = "📝 Lịch Sử Chat"
    historyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    historyTitle.TextSize = 18
    historyTitle.Font = Enum.Font.GothamBold
    historyTitle.Parent = historyPanel

    local historyList = Instance.new("ScrollingFrame")
    historyList.Name = "HistoryList"
    historyList.Size = UDim2.new(1, -20, 1, -100)
    historyList.Position = UDim2.new(0, 10, 0, 55)
    historyList.BackgroundTransparency = 1
    historyList.BorderSizePixel = 0
    historyList.ScrollBarThickness = 6
    historyList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    historyList.CanvasSize = UDim2.new(0, 0, 0, 0)
    historyList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local historyLayout = Instance.new("UIListLayout")
    historyLayout.Padding = UDim.new(0, 8)
    historyLayout.Parent = historyList
    
    local historyPadding = Instance.new("UIPadding")
    historyPadding.PaddingTop = UDim.new(0, 5)
    historyPadding.PaddingBottom = UDim.new(0, 5)
    historyPadding.Parent = historyList

    local clearHistoryBtn = Instance.new("TextButton")
    clearHistoryBtn.Name = "ClearHistoryBtn"
    clearHistoryBtn.Size = UDim2.new(1, -20, 0, 40)
    clearHistoryBtn.Position = UDim2.new(0, 10, 1, -50)
    clearHistoryBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    clearHistoryBtn.BorderSizePixel = 0
    clearHistoryBtn.Text = "🗑️ Xoá Lịch Sử"
    clearHistoryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearHistoryBtn.TextSize = 14
    clearHistoryBtn.Font = Enum.Font.GothamBold
    clearHistoryBtn.AutoButtonColor = false
    
    local clearHistoryCorner = Instance.new("UICorner")
    clearHistoryCorner.CornerRadius = UDim.new(0, 10)
    clearHistoryCorner.Parent = clearHistoryBtn

    historyList.Parent = historyPanel
    clearHistoryBtn.Parent = historyPanel
    historyPanel.Parent = mainFrame

    -- History button
    local historyBtn = Instance.new("TextButton")
    historyBtn.Name = "HistoryBtn"
    historyBtn.Size = UDim2.new(0, 32, 0, 32)
    historyBtn.Position = UDim2.new(1, -180, 0.5, -16)
    historyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    historyBtn.BorderSizePixel = 0
    historyBtn.Text = "📋"
    historyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    historyBtn.TextSize = 14
    historyBtn.AutoButtonColor = false
    
    local historyBtnCorner = Instance.new("UICorner")
    historyBtnCorner.CornerRadius = UDim.new(1, 0)
    historyBtnCorner.Parent = historyBtn
    historyBtn.Parent = titleBar

    mainFrame.Parent = screenGui

    return screenGui
end

-- Create message bubble với modern design
local function CreateMessageBubble(message, isUser, timestamp)
    local bubble = Instance.new("Frame")
    bubble.Name = "MessageBubble"
    bubble.Size = UDim2.new(1, 0, 0, 0)
    bubble.BackgroundTransparency = 1
    bubble.AutomaticSize = Enum.AutomaticSize.Y

    local messageContainer = Instance.new("Frame")
    messageContainer.Name = "MessageContainer"
    messageContainer.Size = UDim2.new(0.75, 0, 0, 0)
    messageContainer.BackgroundTransparency = 1
    messageContainer.AutomaticSize = Enum.AutomaticSize.Y
    
    if isUser then
        messageContainer.Position = UDim2.new(1, -10, 0, 0)
        messageContainer.AnchorPoint = Vector2.new(1, 0)
    else
        messageContainer.Position = UDim2.new(0, 10, 0, 0)
    end

    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "MessageFrame"
    messageFrame.Size = UDim2.new(1, 0, 0, 0)
    messageFrame.BackgroundColor3 = isUser and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 80)
    messageFrame.BorderSizePixel = 0
    messageFrame.AutomaticSize = Enum.AutomaticSize.Y
    
    local messageGradient = CreateGradient(
        isUser and Color3.fromRGB(0, 140, 235) or Color3.fromRGB(70, 70, 90),
        isUser and Color3.fromRGB(0, 100, 195) or Color3.fromRGB(50, 50, 70)
    )
    messageGradient.Parent = messageFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = messageFrame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Size = UDim2.new(1, -20, 0, 0)
    messageLabel.Position = UDim2.new(0, 10, 0, 12)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y

    -- Time stamp
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(1, -20, 0, 15)
    timeLabel.Position = UDim2.new(0, 10, 1, -18)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = timestamp or os.date("%H:%M")
    timeLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    timeLabel.TextSize = 10
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left

    messageLabel.Parent = messageFrame
    timeLabel.Parent = messageFrame
    messageFrame.Parent = messageContainer
    messageContainer.Parent = bubble

    return bubble
end

-- Create history item
local function CreateHistoryItem(chatId, preview, messageCount)
    local item = Instance.new("TextButton")
    item.Name = "HistoryItem_" .. chatId
    item.Size = UDim2.new(1, 0, 0, 60)
    item.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    item.BorderSizePixel = 0
    item.Text = ""
    item.AutoButtonColor = false
    
    local itemGradient = CreateGradient(Color3.fromRGB(60, 60, 85), Color3.fromRGB(50, 50, 70))
    itemGradient.Parent = item
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = item

    local previewLabel = Instance.new("TextLabel")
    previewLabel.Name = "PreviewLabel"
    previewLabel.Size = UDim2.new(1, -20, 0.6, 0)
    previewLabel.Position = UDim2.new(0, 10, 0, 5)
    previewLabel.BackgroundTransparency = 1
    previewLabel.Text = string.sub(preview, 1, 30) .. (string.len(preview) > 30 and "..." : "")
    previewLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    previewLabel.TextSize = 12
    previewLabel.Font = Enum.Font.Gotham
    previewLabel.TextXAlignment = Enum.TextXAlignment.Left
    previewLabel.TextWrapped = true

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -20, 0.4, 0)
    infoLabel.Position = UDim2.new(0, 10, 0.6, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = messageCount .. " tin nhắn • " .. os.date("%H:%M")
    infoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    infoLabel.TextSize = 10
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left

    previewLabel.Parent = item
    infoLabel.Parent = item

    return item
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
        if data and data.candidates and data.candidates[1] and data.candidates[1].content then
            return data.candidates[1].content.parts[1].text
        else
            return "Lỗi: Không thể nhận phản hồi từ Gemini. Vui lòng kiểm tra API Key."
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
        messageBubble.MessageContainer.MessageFrame.Size = UDim2.new(0, 0, 0, 0)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(messageBubble.MessageContainer.MessageFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, messageBubble.MessageContainer.MessageFrame.MessageLabel.TextBounds.Y + 35)})
        tween:Play()
    end
    
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
    
    -- Auto scroll to bottom
    wait(0.1)
    chatHistory.CanvasPosition = Vector2.new(0, chatHistory.AbsoluteCanvasSize.Y)
end

-- Load chat history to UI
local function LoadChatHistoryToUI(chatId)
    local chatGUI = playerGui:FindFirstChild("GeminiChat")
    if not chatGUI then return end
    
    local chatHistory = chatGUI.MainFrame.ChatHistory
    chatHistory:ClearAllChildren()
    
    if CONFIG.CHAT_HISTORY[chatId] then
        for _, messageData in ipairs(CONFIG.CHAT_HISTORY[chatId]) do
            AddMessage(messageData.message, messageData.isUser, false)
        end
    end
end

-- Update history panel
local function UpdateHistoryPanel()
    local chatGUI = playerGui:FindFirstChild("GeminiChat")
    if not chatGUI then return end
    
    local historyList = chatGUI.MainFrame.HistoryPanel.HistoryList
    historyList:ClearAllChildren()
    
    for chatId, messages in pairs(CONFIG.CHAT_HISTORY) do
        if #messages > 0 then
            local preview = messages[1].message
            local item = CreateHistoryItem(chatId, preview, #messages)
            item.Parent = historyList
            
            item.MouseButton1Click:Connect(function()
                CONFIG.CURRENT_CHAT_ID = chatId
                LoadChatHistoryToUI(chatId)
                chatGUI.MainFrame.HistoryPanel.Visible = false
            end)
        end
    end
end

-- Initialize chat
local function InitializeChat()
    -- Initialize current chat ID
    if not CONFIG.CURRENT_CHAT_ID then
        CONFIG.CURRENT_CHAT_ID = GenerateID()
        CONFIG.CHAT_HISTORY[CONFIG.CURRENT_CHAT_ID] = {}
    end
    
    local chatGUI = CreateChatGUI()
    chatGUI.Parent = playerGui
    
    -- Set up event handlers
    local mainFrame = chatGUI.MainFrame
    local sendBtn = mainFrame.InputArea.SendBtn
    local messageInput = mainFrame.InputArea.MessageInput
    local minimizeBtn = mainFrame.TitleBar.Controls.MinimizeBtn
    local maximizeBtn = mainFrame.TitleBar.Controls.MaximizeBtn
    local closeBtn = mainFrame.TitleBar.Controls.CloseBtn
    local settingsBtn = mainFrame.TitleBar.SettingsBtn
    local historyBtn = mainFrame.TitleBar.HistoryBtn
    local settingsPanel = mainFrame.SettingsPanel
    local historyPanel = mainFrame.HistoryPanel
    local effectsToggle = settingsPanel.EffectsToggle
    local apiKeyInput = settingsPanel.APIKeyInput
    local saveSettingsBtn = settingsPanel.SaveSettingsBtn
    local clearHistoryBtn = historyPanel.ClearHistoryBtn
    
    -- Add welcome message
    AddMessage("Xin chào! Tôi là Gemini AI. Tôi có thể giúp gì cho bạn?", false, true)
    
    -- Button hover effects
    local function SetupButtonHover(button, normalColor, hoverColor)
        local gradient = button:FindFirstChildOfClass("UIGradient")
        if gradient then
            local originalColors = gradient.Color
            button.MouseEnter:Connect(function()
                if CONFIG.ENABLED_EFFECTS then
                    local tween = TweenService:Create(gradient, TweenInfo.new(0.2), {
                        Color = ColorSequence.new({hoverColor, hoverColor})
                    })
                    tween:Play()
                end
            end)
            
            button.MouseLeave:Connect(function()
                if CONFIG.ENABLED_EFFECTS then
                    local tween = TweenService:Create(gradient, TweenInfo.new(0.2), {
                        Color = originalColors
                    })
                    tween:Play()
                end
            end)
        end
    end
    
    -- Setup button hovers
    SetupButtonHover(sendBtn, Color3.fromRGB(76, 175, 80), Color3.fromRGB(86, 185, 90))
    SetupButtonHover(minimizeBtn, Color3.fromRGB(255, 193, 7), Color3.fromRGB(265, 203, 17))
    SetupButtonHover(maximizeBtn, Color3.fromRGB(33, 150, 243), Color3.fromRGB(43, 160, 253))
    SetupButtonHover(closeBtn, Color3.fromRGB(244, 67, 54), Color3.fromRGB(254, 77, 64))
    SetupButtonHover(settingsBtn, Color3.fromRGB(60, 60, 80), Color3.fromRGB(70, 70, 90))
    SetupButtonHover(historyBtn, Color3.fromRGB(60, 60, 80), Color3.fromRGB(70, 70, 90))
    SetupButtonHover(effectsToggle, Color3.fromRGB(50, 50, 70), Color3.fromRGB(60, 60, 80))
    SetupButtonHover(saveSettingsBtn, Color3.fromRGB(76, 175, 80), Color3.fromRGB(86, 185, 90))
    SetupButtonHover(clearHistoryBtn, Color3.fromRGB(244, 67, 54), Color3.fromRGB(254, 77, 64))
    
    -- Send message function
    local function SendMessage()
        local message = messageInput.Text:gsub("^%s*(.-)%s*$", "%1")
        if message == "" then return end
        
        messageInput.Text = ""
        AddMessage(message, true, true)
        
        -- Disable send button while processing
        sendBtn.Text = "..."
        sendBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        -- Call Gemini API
        spawn(function()
            local response = CallGeminiAPI(message)
            
            -- Re-enable send button
            sendBtn.Text = "➤"
            sendBtn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            
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
    end)
    
    maximizeBtn.MouseButton1Click:Connect(function()
        if mainFrame.Size == UDim2.new(0, 640, 0, 360) then
            mainFrame.Size = UDim2.new(0, 800, 0, 450)
            mainFrame.Position = UDim2.new(0.5, -400, 0.5, -225)
        else
            mainFrame.Size = UDim2.new(0, 640, 0, 360)
            mainFrame.Position = UDim2.new(0.5, -320, 0.5, -180)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        chatGUI:Destroy()
    end)
    
    settingsBtn.MouseButton1Click:Connect(function()
        settingsPanel.Visible = not settingsPanel.Visible
        historyPanel.Visible = false
    end)
    
    historyBtn.MouseButton1Click:Connect(function()
        historyPanel.Visible = not historyPanel.Visible
        settingsPanel.Visible = false
        if historyPanel.Visible then
            UpdateHistoryPanel()
        end
    end)
    
    effectsToggle.MouseButton1Click:Connect(function()
        CONFIG.ENABLED_EFFECTS = not CONFIG.ENABLED_EFFECTS
        effectsToggle.Text = "✨ Hiệu ứng: " .. (CONFIG.ENABLED_EFFECTS and "BẬT" : "TẮT")
    end)
    
    saveSettingsBtn.MouseButton1Click:Connect(function()
        CONFIG.API_KEY = apiKeyInput.Text
        settingsPanel.Visible = false
        AddMessage("Cài đặt đã được lưu!", false, true)
    end)
    
    clearHistoryBtn.MouseButton1Click:Connect(function()
        CONFIG.CHAT_HISTORY = {}
        CONFIG.CURRENT_CHAT_ID = GenerateID()
        CONFIG.CHAT_HISTORY[CONFIG.CURRENT_CHAT_ID] = {}
        
        local chatHistory = mainFrame.ChatHistory
        chatHistory:ClearAllChildren()
        
        historyPanel.Visible = false
        AddMessage("Lịch sử chat đã được xoá!", false, true)
    end)
    
    -- New chat function
    local function StartNewChat()
        CONFIG.CURRENT_CHAT_ID = GenerateID()
        CONFIG.CHAT_HISTORY[CONFIG.CURRENT_CHAT_ID] = {}
        
        local chatHistory = mainFrame.ChatHistory
        chatHistory:ClearAllChildren()
        
        AddMessage("Cuộc trò chuyện mới đã bắt đầu! Tôi có thể giúp gì cho bạn?", false, true)
    end
    
    -- New chat button (added to title bar)
    local newChatBtn = Instance.new("TextButton")
    newChatBtn.Name = "NewChatBtn"
    newChatBtn.Size = UDim2.new(0, 32, 0, 32)
    newChatBtn.Position = UDim2.new(1, -220, 0.5, -16)
    newChatBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    newChatBtn.BorderSizePixel = 0
    newChatBtn.Text = "🆕"
    newChatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    newChatBtn.TextSize = 14
    newChatBtn.AutoButtonColor = false
    
    local newChatCorner = Instance.new("UICorner")
    newChatCorner.CornerRadius = UDim.new(1, 0)
    newChatCorner.Parent = newChatBtn
    
    SetupButtonHover(newChatBtn, Color3.fromRGB(60, 60, 80), Color3.fromRGB(70, 70, 90))
    newChatBtn.MouseButton1Click:Connect(StartNewChat)
    newChatBtn.Parent = mainFrame.TitleBar
    
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
    
    -- Close settings when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if settingsPanel.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local settingsAbsolutePos = settingsPanel.AbsolutePosition
                local settingsAbsoluteSize = settingsPanel.AbsoluteSize
                
                if not (mousePos.X >= settingsAbsolutePos.X and mousePos.X <= settingsAbsolutePos.X + settingsAbsoluteSize.X and
                       mousePos.Y >= settingsAbsolutePos.Y and mousePos.Y <= settingsAbsolutePos.Y + settingsAbsoluteSize.Y) then
                    settingsPanel.Visible = false
                end
            end
            
            if historyPanel.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local historyAbsolutePos = historyPanel.AbsolutePosition
                local historyAbsoluteSize = historyPanel.AbsoluteSize
                
                if not (mousePos.X >= historyAbsolutePos.X and mousePos.X <= historyAbsolutePos.X + historyAbsoluteSize.X and
                       mousePos.Y >= historyAbsolutePos.Y and mousePos.Y <= historyAbsolutePos.Y + historyAbsoluteSize.Y) then
                    historyPanel.Visible = false
                end
            end
        end
    end)
end

-- Start the chat
InitializeChat()