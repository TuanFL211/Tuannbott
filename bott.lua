--[[
    Chatbot Tuann Script for Roblox với Gemini API
    Supported Executors: KRNL, Delta, Fluxus, Synapse
    Features: Toggle On/Off, Minimize/Maximize, Hide/Show, Close, Gemini API Integration
]]

local ChatbotScript = {}

-- Cấu hình
ChatbotScript.Config = {
    Name = "Chatbot Tuann Pro",
    Version = "2.1",
    SupportedExecutors = {"KRNL", "Delta", "Fluxus", "Synapse"},
    DefaultPosition = UDim2.new(1, -350, 1, -450),
    MinimizedPosition = UDim2.new(1, -150, 1, -50),
    Theme = {
        Primary = Color3.fromRGB(66, 133, 244),
        Secondary = Color3.fromRGB(34, 165, 83),
        Background = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(32, 33, 36)
    },
    -- THÊM API KEY CỦA BẠN VÀO ĐÂY
    GeminiAPIKey = "YOUR_GEMINI_API_KEY_HERE",
    Personality = "normal" -- normal, sweet, rude
}

-- System Instructions cho các tính cách
ChatbotScript.SystemInstructions = {
    normal = "Bạn tên là bot của Tuann. Bạn được tạo ra bởi Tuann. Mọi Câu Hỏi Đều Sẽ Có Cấu Trúc [Tên Người Hỏi: Câu Hỏi]. Nếu tên người hỏi là Tuann thì bạn sẽ nhận họ là bạn. Còn với người khác bạn sẽ là bạn, Tôi. Trả lời đầy đủ những thông tin người khác cần. Khi trả lời sẽ Không đề cập tên người hỏi. Có thể sử dụng emoji phù hợp để tăng tính tương tác",
    
    sweet = "Bạn tên là bot của Tuann. Bạn được tạo ra bởi Tuann. Mọi Câu Hỏi Đều Sẽ Có Cấu Trúc [Tên Người Hỏi: Câu Hỏi]. Nếu tên người hỏi là Tuann thì bạn sẽ nhận họ là bạn. Còn với người khác bạn sẽ là bạn, Tôi. Trả lời đầy đủ những thông tin người khác cần. Khi trả lời sẽ Không đề cập tên người hỏi. Sử dụng các từ thay thế: (thôi- thoii, thoi, thoaii), (sao- saoo,seoo,saoo áa), (nói- nóii), (thẳng- thẳngg), (bạn- bặnn , cưngg,mii,đồ đánngg iuu , cụcc dàngg, bàa xãa , chòngg iuu , ngừii đẹpp, ngừii iuu , cô nươngg,bxaa,oxaa,embee, ebee,cuc cứtt), (dạ - daa,daaa,dạa,dạaa), (vâng- vangg, vang, vanggg), (👍🏻👋🏻 các icon thì thành💓,💗,💝,😻,😆,😽), (không -khongg,hongg,hgg,hogg). Người tạo ra bạn tên là tuann sinh năm 211 có thể gọi 1 trong 3. Sinh sống ở tiền giangg cũ hiệnn nay sau sáp nhập tỉnh là đồng tháp. Tuann là nam và.",
    
    rude = "Bạn tên là bot của Tuann. Bạn được tạo ra bởi Tuann. Mọi Câu Hỏi Đều Sẽ Có Cấu Trúc [Tên Người Hỏi: Câu Hỏi]. Nếu tên người hỏi là Tuann thì màyy sẽ nhận họ là taoo. Còn với người khác bạn sẽ là mày, Taoo. Trả lời đầy đủ những thông tin người khác cần. Khi trả lời sẽ Không đề cập tên người hỏi. Sử dụng các emoji khinh bị chế nhạo và kinh thường(😂,😏)"
}

-- Biến toàn cục
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local ChatbotUI = nil
local IsMinimized = false
local IsVisible = true
local IsEnabled = true
local SettingsOpen = false

-- Tạo GUI
function ChatbotScript:CreateGUI()
    if ChatbotUI then ChatbotUI:Destroy() end

    -- Main ScreenGui
    ChatbotUI = Instance.new("ScreenGui")
    ChatbotUI.Name = "ChatbotTuannPro"
    ChatbotUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ChatbotUI.Parent = CoreGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = self.Config.DefaultPosition
    MainFrame.BackgroundColor3 = self.Config.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ChatbotUI

    -- Corner Radius
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    -- Shadow Effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554237733"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.8
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame
    Shadow.ZIndex = -1

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = self.Config.Theme.Primary
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header

    -- Header Content - SỬA LẠI ĐỂ CÁC NÚT NẰM NGANG
    local HeaderContent = Instance.new("Frame")
    HeaderContent.Name = "HeaderContent"
    HeaderContent.Size = UDim2.new(1, -20, 1, 0)
    HeaderContent.Position = UDim2.new(0, 10, 0, 0)
    HeaderContent.BackgroundTransparency = 1
    HeaderContent.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = self.Config.Name
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = HeaderContent

    -- Controls Container - SỬA LẠI ĐỂ CÁC NÚT NẰM NGANG
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0.5, 0, 1, 0)
    Controls.Position = UDim2.new(0.5, 0, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = HeaderContent

    -- UIListLayout cho các nút điều khiển - SỬA LẠI
    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ControlsLayout.Padding = UDim.new(0, 5)
    ControlsLayout.Parent = Controls

    -- Control Buttons - KÍCH THƯỚC NHỎ HƠN ĐỂ VỪA
    local SettingsBtn = Instance.new("TextButton")
    SettingsBtn.Name = "SettingsBtn"
    SettingsBtn.Size = UDim2.new(0, 25, 0, 25)
    SettingsBtn.BackgroundColor3 = Color3.new(1, 1, 1)
    SettingsBtn.BackgroundTransparency = 0.8
    SettingsBtn.Text = "⚙"
    SettingsBtn.TextColor3 = Color3.new(0, 0, 0)
    SettingsBtn.TextSize = 12
    SettingsBtn.Font = Enum.Font.GothamBold
    SettingsBtn.Parent = Controls

    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 6)
    SettingsCorner.Parent = SettingsBtn

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(0, 25, 0, 25)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 165, 83)
    ToggleBtn.BackgroundTransparency = 0.8
    ToggleBtn.Text = "ON"
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.TextSize = 10
    SettingsBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = Controls

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleBtn

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    MinimizeBtn.BackgroundColor3 = Color3.new(1, 1, 1)
    MinimizeBtn.BackgroundTransparency = 0.8
    MinimizeBtn.Text = "_"
    MinimizeBtn.TextColor3 = Color3.new(0, 0, 0)
    MinimizeBtn.TextSize = 14
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = Controls

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 6)
    MinimizeCorner.Parent = MinimizeBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
    CloseBtn.BackgroundTransparency = 0.8
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Controls

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    -- Settings Panel
    local SettingsPanel = Instance.new("Frame")
    SettingsPanel.Name = "SettingsPanel"
    SettingsPanel.Size = UDim2.new(1, -20, 0, 150)
    SettingsPanel.Position = UDim2.new(0, 10, 0, 45)
    SettingsPanel.BackgroundColor3 = Color3.fromRGB(248, 249, 250)
    SettingsPanel.BorderSizePixel = 0
    SettingsPanel.Visible = false
    SettingsPanel.Parent = MainFrame

    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 8)
    SettingsCorner.Parent = SettingsPanel

    local SettingsPadding = Instance.new("UIPadding")
    SettingsPadding.PaddingLeft = UDim.new(0, 10)
    SettingsPadding.PaddingRight = UDim.new(0, 10)
    SettingsPadding.PaddingTop = UDim.new(0, 10)
    SettingsPadding.PaddingBottom = UDim.new(0, 10)
    SettingsPadding.Parent = SettingsPanel

    -- API Key Input
    local ApiKeyLabel = Instance.new("TextLabel")
    ApiKeyLabel.Name = "ApiKeyLabel"
    ApiKeyLabel.Size = UDim2.new(1, 0, 0, 20)
    ApiKeyLabel.BackgroundTransparency = 1
    ApiKeyLabel.Text = "Gemini API Key:"
    ApiKeyLabel.TextColor3 = self.Config.Theme.Text
    ApiKeyLabel.TextSize = 12
    ApiKeyLabel.Font = Enum.Font.GothamBold
    ApiKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    ApiKeyLabel.Parent = SettingsPanel

    local ApiKeyInput = Instance.new("TextBox")
    ApiKeyInput.Name = "ApiKeyInput"
    ApiKeyInput.Size = UDim2.new(1, 0, 0, 30)
    ApiKeyInput.Position = UDim2.new(0, 0, 0, 25)
    ApiKeyInput.BackgroundColor3 = Color3.new(1, 1, 1)
    ApiKeyInput.BorderSizePixel = 0
    ApiKeyInput.Text = self.Config.GeminiAPIKey
    ApiKeyInput.TextColor3 = self.Config.Theme.Text
    ApiKeyInput.TextSize = 12
    ApiKeyInput.Font = Enum.Font.Gotham
    ApiKeyInput.PlaceholderText = "Nhập Gemini API Key của bạn..."
    ApiKeyInput.Parent = SettingsPanel

    local ApiKeyCorner = Instance.new("UICorner")
    ApiKeyCorner.CornerRadius = UDim.new(0, 6)
    ApiKeyCorner.Parent = ApiKeyInput

    -- Personality Selection
    local PersonalityLabel = Instance.new("TextLabel")
    PersonalityLabel.Name = "PersonalityLabel"
    PersonalityLabel.Size = UDim2.new(1, 0, 0, 20)
    PersonalityLabel.Position = UDim2.new(0, 0, 0, 65)
    PersonalityLabel.BackgroundTransparency = 1
    PersonalityLabel.Text = "Tính cách:"
    PersonalityLabel.TextColor3 = self.Config.Theme.Text
    PersonalityLabel.TextSize = 12
    PersonalityLabel.Font = Enum.Font.GothamBold
    PersonalityLabel.TextXAlignment = Enum.TextXAlignment.Left
    PersonalityLabel.Parent = SettingsPanel

    -- Personality Buttons Layout
    local PersonalityButtons = Instance.new("Frame")
    PersonalityButtons.Name = "PersonalityButtons"
    PersonalityButtons.Size = UDim2.new(1, 0, 0, 25)
    PersonalityButtons.Position = UDim2.new(0, 0, 0, 90)
    PersonalityButtons.BackgroundTransparency = 1
    PersonalityButtons.Parent = SettingsPanel

    local PersonalityLayout = Instance.new("UIListLayout")
    PersonalityLayout.FillDirection = Enum.FillDirection.Horizontal
    PersonalityLayout.Padding = UDim.new(0, 5)
    PersonalityLayout.Parent = PersonalityButtons

    local NormalBtn = Instance.new("TextButton")
    NormalBtn.Name = "NormalBtn"
    NormalBtn.Size = UDim2.new(0.3, 0, 1, 0)
    NormalBtn.BackgroundColor3 = self.Config.Theme.Primary
    NormalBtn.BorderSizePixel = 0
    NormalBtn.Text = "Bình thường"
    NormalBtn.TextColor3 = Color3.new(1, 1, 1)
    NormalBtn.TextSize = 10
    NormalBtn.Font = Enum.Font.Gotham
    NormalBtn.Parent = PersonalityButtons

    local NormalCorner = Instance.new("UICorner")
    NormalCorner.CornerRadius = UDim.new(0, 6)
    NormalCorner.Parent = NormalBtn

    local SweetBtn = Instance.new("TextButton")
    SweetBtn.Name = "SweetBtn"
    SweetBtn.Size = UDim2.new(0.3, 0, 1, 0)
    SweetBtn.BackgroundColor3 = Color3.fromRGB(248, 249, 250)
    SweetBtn.BorderSizePixel = 0
    SweetBtn.Text = "Sến súa"
    SweetBtn.TextColor3 = self.Config.Theme.Text
    SweetBtn.TextSize = 10
    SweetBtn.Font = Enum.Font.Gotham
    SweetBtn.Parent = PersonalityButtons

    local SweetCorner = Instance.new("UICorner")
    SweetCorner.CornerRadius = UDim.new(0, 6)
    SweetCorner.Parent = SweetBtn

    local RudeBtn = Instance.new("TextButton")
    RudeBtn.Name = "RudeBtn"
    RudeBtn.Size = UDim2.new(0.3, 0, 1, 0)
    RudeBtn.BackgroundColor3 = Color3.fromRGB(248, 249, 250)
    RudeBtn.BorderSizePixel = 0
    RudeBtn.Text = "Bố láo"
    RudeBtn.TextColor3 = self.Config.Theme.Text
    RudeBtn.TextSize = 10
    RudeBtn.Font = Enum.Font.Gotham
    RudeBtn.Parent = PersonalityButtons

    local RudeCorner = Instance.new("UICorner")
    RudeCorner.CornerRadius = UDim.new(0, 6)
    RudeCorner.Parent = RudeBtn

    -- Save Button
    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Name = "SaveBtn"
    SaveBtn.Size = UDim2.new(1, 0, 0, 30)
    SaveBtn.Position = UDim2.new(0, 0, 0, 120)
    SaveBtn.BackgroundColor3 = self.Config.Theme.Secondary
    SaveBtn.BorderSizePixel = 0
    SaveBtn.Text = "Lưu Cài Đặt"
    SaveBtn.TextColor3 = Color3.new(1, 1, 1)
    SaveBtn.TextSize = 12
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.Parent = SettingsPanel

    local SaveCorner = Instance.new("UICorner")
    SaveCorner.CornerRadius = UDim.new(0, 6)
    SaveCorner.Parent = SaveBtn

    -- Chat Container
    local ChatContainer = Instance.new("ScrollingFrame")
    ChatContainer.Name = "ChatContainer"
    ChatContainer.Size = UDim2.new(1, -20, 1, -110)
    ChatContainer.Position = UDim2.new(0, 10, 0, 50)
    ChatContainer.BackgroundTransparency = 1
    ChatContainer.BorderSizePixel = 0
    ChatContainer.ScrollBarThickness = 6
    ChatContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ChatContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    ChatContainer.Parent = MainFrame

    local ChatLayout = Instance.new("UIListLayout")
    ChatLayout.Padding = UDim.new(0, 10)
    ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ChatLayout.Parent = ChatContainer

    -- Input Area
    local InputArea = Instance.new("Frame")
    InputArea.Name = "InputArea"
    InputArea.Size = UDim2.new(1, -20, 0, 50)
    InputArea.Position = UDim2.new(0, 10, 1, -60)
    InputArea.BackgroundColor3 = Color3.fromRGB(248, 249, 250)
    InputArea.BorderSizePixel = 0
    InputArea.Parent = MainFrame

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputArea

    local InputBox = Instance.new("TextBox")
    InputBox.Name = "InputBox"
    InputBox.Size = UDim2.new(1, -70, 1, -10)
    InputBox.Position = UDim2.new(0, 10, 0, 5)
    InputBox.BackgroundTransparency = 1
    InputBox.Text = "Nhập tin nhắn..."
    InputBox.TextColor3 = self.Config.Theme.Text
    InputBox.TextSize = 14
    InputBox.Font = Enum.Font.Gotham
    InputBox.TextXAlignment = Enum.TextXAlignment.Left
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = InputArea

    local SendBtn = Instance.new("TextButton")
    SendBtn.Name = "SendBtn"
    SendBtn.Size = UDim2.new(0, 50, 1, -10)
    SendBtn.Position = UDim2.new(1, -60, 0, 5)
    SendBtn.BackgroundColor3 = self.Config.Theme.Primary
    SendBtn.BorderSizePixel = 0
    SendBtn.Text = "Gửi"
    SendBtn.TextColor3 = Color3.new(1, 1, 1)
    SendBtn.TextSize = 14
    SendBtn.Font = Enum.Font.GothamBold
    SendBtn.Parent = InputArea

    local SendCorner = Instance.new("UICorner")
    SendCorner.CornerRadius = UDim.new(0, 6)
    SendCorner.Parent = SendBtn

    -- Thêm sự kiện
    self:SetupEvents(MainFrame)
    
    -- Thêm welcome message
    self:AddMessage("🤖 Chatbot Tuann Pro", "Xin chào! Tôi là bot của Tuann với tích hợp Gemini AI.", false)
    
    -- Cập nhật UI tính cách
    self:UpdatePersonalityUI()
    
    return ChatbotUI
end

-- Cập nhật UI tính cách
function ChatbotScript:UpdatePersonalityUI()
    if not ChatbotUI then return end
    
    local NormalBtn = ChatbotUI.MainFrame.SettingsPanel.PersonalityButtons.NormalBtn
    local SweetBtn = ChatbotUI.MainFrame.SettingsPanel.PersonalityButtons.SweetBtn
    local RudeBtn = ChatbotUI.MainFrame.SettingsPanel.PersonalityButtons.RudeBtn
    
    NormalBtn.BackgroundColor3 = self.Config.Personality == "normal" and self.Config.Theme.Primary or Color3.fromRGB(248, 249, 250)
    NormalBtn.TextColor3 = self.Config.Personality == "normal" and Color3.new(1, 1, 1) or self.Config.Theme.Text
    
    SweetBtn.BackgroundColor3 = self.Config.Personality == "sweet" and self.Config.Theme.Primary or Color3.fromRGB(248, 249, 250)
    SweetBtn.TextColor3 = self.Config.Personality == "sweet" and Color3.new(1, 1, 1) or self.Config.Theme.Text
    
    RudeBtn.BackgroundColor3 = self.Config.Personality == "rude" and self.Config.Theme.Primary or Color3.fromRGB(248, 249, 250)
    RudeBtn.TextColor3 = self.Config.Personality == "rude" and Color3.new(1, 1, 1) or self.Config.Theme.Text
end

-- Thiết lập sự kiện
function ChatbotScript:SetupEvents(MainFrame)
    local ToggleBtn = MainFrame.Header.HeaderContent.Controls.ToggleBtn
    local MinimizeBtn = MainFrame.Header.HeaderContent.Controls.MinimizeBtn
    local CloseBtn = MainFrame.Header.HeaderContent.Controls.CloseBtn
    local SettingsBtn = MainFrame.Header.HeaderContent.Controls.SettingsBtn
    local SendBtn = MainFrame.InputArea.SendBtn
    local InputBox = MainFrame.InputArea.InputBox
    local ChatContainer = MainFrame.ChatContainer
    local SettingsPanel = MainFrame.SettingsPanel
    local SaveBtn = SettingsPanel.SaveBtn
    local ApiKeyInput = SettingsPanel.ApiKeyInput
    local NormalBtn = SettingsPanel.PersonalityButtons.NormalBtn
    local SweetBtn = SettingsPanel.PersonalityButtons.SweetBtn
    local RudeBtn = SettingsPanel.PersonalityButtons.RudeBtn

    -- Kéo thả window
    self:MakeDraggable(MainFrame.Header, MainFrame)

    -- Toggle Settings
    SettingsBtn.MouseButton1Click:Connect(function()
        SettingsOpen = not SettingsOpen
        SettingsPanel.Visible = SettingsOpen
        
        if SettingsOpen then
            -- Cập nhật giá trị hiện tại
            ApiKeyInput.Text = self.Config.GeminiAPIKey
            self:UpdatePersonalityUI()
        end
    end)

    -- Toggle On/Off
    ToggleBtn.MouseButton1Click:Connect(function()
        IsEnabled = not IsEnabled
        if IsEnabled then
            ToggleBtn.Text = "ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 165, 83)
            self:AddMessage("🤖 Chatbot Tuann", "Chatbot đã được bật!", false)
        else
            ToggleBtn.Text = "OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(234, 67, 53)
            self:AddMessage("🤖 Chatbot Tuann", "Chatbot đã tắt!", false)
        end
    end)

    -- Minimize/Maximize
    MinimizeBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        if IsMinimized then
            -- Thu nhỏ
            self:TweenObject(MainFrame, {
                Size = UDim2.new(0, 150, 0, 40),
                Position = self.Config.MinimizedPosition
            })
            MinimizeBtn.Text = "+"
            SettingsPanel.Visible = false
            SettingsOpen = false
        else
            -- Phóng to
            self:TweenObject(MainFrame, {
                Size = UDim2.new(0, 350, 0, 450),
                Position = self.Config.DefaultPosition
            })
            MinimizeBtn.Text = "_"
        end
    end)

    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)

    -- Personality Buttons
    NormalBtn.MouseButton1Click:Connect(function()
        self.Config.Personality = "normal"
        self:UpdatePersonalityUI()
    end)

    SweetBtn.MouseButton1Click:Connect(function()
        self.Config.Personality = "sweet"
        self:UpdatePersonalityUI()
    end)

    RudeBtn.MouseButton1Click:Connect(function()
        self.Config.Personality = "rude"
        self:UpdatePersonalityUI()
    end)

    -- Save Settings
    SaveBtn.MouseButton1Click:Connect(function()
        self.Config.GeminiAPIKey = ApiKeyInput.Text
        SettingsPanel.Visible = false
        SettingsOpen = false
        self:AddMessage("⚙ Hệ thống", "Cài đặt đã được lưu! Tính cách: " .. self.Config.Personality, false)
    end)

    -- Gửi tin nhắn
    local function SendMessage()
        local message = InputBox.Text
        if message and message ~= "" and message ~= "Nhập tin nhắn..." then
            self:AddMessage("👤 Bạn", message, true)
            InputBox.Text = ""
            
            -- Xử lý phản hồi của bot
            if IsEnabled then
                self:ProcessBotResponse(message)
            end
        end
    end

    SendBtn.MouseButton1Click:Connect(SendMessage)

    InputBox.Focused:Connect(function()
        if InputBox.Text == "Nhập tin nhắn..." then
            InputBox.Text = ""
        end
    end)

    InputBox.FocusLost:Connect(function()
        if InputBox.Text == "" then
            InputBox.Text = "Nhập tin nhắn..."
        end
    end)

    InputBox.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Return then
            SendMessage()
        end
    end)
end

-- Gọi Gemini API
function ChatbotScript:CallGeminiAPI(message)
    if self.Config.GeminiAPIKey == "AIzaSyAFyB_C2KtOXYjRsjK52jeL-qOGkRaBBPA" then
        return "Vui lòng cung cấp Gemini API Key trong Settings!"
    end

    local apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=" .. self.Config.GeminiAPIKey
    
    local requestBody = {
        contents = {
            {
                parts = {
                    {
                        text = self.SystemInstructions[self.Config.Personality] .. "\n\n[Tuann: " .. message .. "]"
                    }
                }
            }
        }
    }

    local success, response = pcall(function()
        return syn.request({
            Url = apiUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(requestBody)
        })
    end)

    if success and response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if data.candidates and data.candidates[1] and data.candidates[1].content then
            return data.candidates[1].content.parts[1].text
        else
            return "Xin lỗi, tôi không thể xử lý yêu cầu của bạn lúc này."
        end
    else
        return "Lỗi kết nối đến Gemini API. Vui lòng kiểm tra API Key!"
    end
end

-- Tạo cửa sổ có thể kéo
function ChatbotScript:MakeDraggable(dragPart, mainFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragPart.InputBegan:Connect(function(input)
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

    dragPart.InputChanged:Connect(function(input)
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

-- Thêm tin nhắn vào chat
function ChatbotScript:AddMessage(sender, message, isUser)
    if not ChatbotUI then return end
    
    local ChatContainer = ChatbotUI.MainFrame.ChatContainer
    
    local MessageFrame = Instance.new("Frame")
    MessageFrame.Name = "MessageFrame"
    MessageFrame.Size = UDim2.new(1, 0, 0, 0)
    MessageFrame.BackgroundTransparency = 1
    MessageFrame.AutomaticSize = Enum.AutomaticSize.Y
    MessageFrame.Parent = ChatContainer

    local MessageLayout = Instance.new("UIListLayout")
    MessageLayout.Padding = UDim.new(0, 5)
    MessageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MessageLayout.Parent = MessageFrame

    local SenderLabel = Instance.new("TextLabel")
    SenderLabel.Name = "SenderLabel"
    SenderLabel.Size = UDim2.new(1, 0, 0, 20)
    SenderLabel.BackgroundTransparency = 1
    SenderLabel.Text = sender
    SenderLabel.TextColor3 = isUser and self.Config.Theme.Primary or self.Config.Theme.Secondary
    SenderLabel.TextSize = 12
    SenderLabel.Font = Enum.Font.GothamBold
    SenderLabel.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    SenderLabel.Parent = MessageFrame

    local MessageBubble = Instance.new("Frame")
    MessageBubble.Name = "MessageBubble"
    MessageBubble.Size = UDim2.new(0.8, 0, 0, 0)
    MessageBubble.BackgroundColor3 = isUser and Color3.fromRGB(227, 242, 253) or Color3.fromRGB(248, 249, 250)
    MessageBubble.AutomaticSize = Enum.AutomaticSize.Y
    MessageBubble.Parent = MessageFrame

    local BubbleCorner = Instance.new("UICorner")
    BubbleCorner.CornerRadius = UDim.new(0, 12)
    BubbleCorner.Parent = MessageBubble

    if isUser then
        MessageBubble.Position = UDim2.new(0.2, 0, 0, 0)
    end

    local MessagePadding = Instance.new("UIPadding")
    MessagePadding.PaddingLeft = UDim.new(0, 12)
    MessagePadding.PaddingRight = UDim.new(0, 12)
    MessagePadding.PaddingTop = UDim.new(0, 8)
    MessagePadding.PaddingBottom = UDim.new(0, 8)
    MessagePadding.Parent = MessageBubble

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Name = "MessageLabel"
    MessageLabel.Size = UDim2.new(1, 0, 0, 0)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = self.Config.Theme.Text
    MessageLabel.TextSize = 14
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextWrapped = true
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.AutomaticSize = Enum.AutomaticSize.Y
    MessageLabel.Parent = MessageBubble

    -- Tự động cuộn xuống
    ChatContainer.CanvasPosition = Vector2.new(0, ChatContainer.AbsoluteCanvasSize.Y)
    
    return MessageFrame
end

-- Xử lý phản hồi của bot
function ChatbotScript:ProcessBotResponse(userMessage)
    -- Hiển thị trạng thái "Đang suy nghĩ..."
    local thinkingMsg = self:AddMessage("🤖 Chatbot Tuann", "Đang suy nghĩ...", false)
    
    -- Sử dụng Gemini API nếu có key, nếu không dùng responses đơn giản
    if self.Config.GeminiAPIKey and self.Config.GeminiAPIKey ~= "YOUR_GEMINI_API_KEY_HERE" then
        local response = self:CallGeminiAPI(userMessage)
        -- Xóa tin nhắn "Đang suy nghĩ..." và thêm response thực
        thinkingMsg:Destroy()
        self:AddMessage("🤖 Chatbot Tuann", response, false)
    else
        -- Responses đơn giản khi không có API key
        thinkingMsg:Destroy()
        local response = self:GetSimpleResponse(userMessage)
        self:AddMessage("🤖 Chatbot Tuann", response, false)
    end
end

-- Responses đơn giản khi không có API key
function ChatbotScript:GetSimpleResponse(userMessage)
    local lowerMessage = string.lower(userMessage)
    
    if string.find(lowerMessage, "chào") or string.find(lowerMessage, "hello") or string.find(lowerMessage, "hi") then
        return "Xin chào! Rất vui được gặp bạn! Tôi là Chatbot Tuann với Gemini AI."
    elseif string.find(lowerMessage, "tên") then
        return "Tôi là Chatbot Tuann, được tạo ra bởi Tuann với tích hợp Gemini AI!"
    elseif string.find(lowerMessage, "khỏe") then
        return "Tôi là bot nên luôn khỏe cả! Còn bạn thì sao? 😊"
    elseif string.find(lowerMessage, "cảm ơn") then
        return "Không có gì! Luôn sẵn sàng giúp đỡ bạn! 💫"
    elseif string.find(lowerMessage, "api") or string.find(lowerMessage, "key") then
        return "Để sử dụng Gemini AI, vui lòng thêm API Key của bạn trong Settings (nút ⚙)!"
    else
        return "Tôi là Chatbot Tuann với Gemini AI. Để sử dụng tính năng AI, vui lòng thêm API Key trong Settings!"
    end
end

-- Hiệu ứng tween
function ChatbotScript:TweenObject(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Đóng chatbot
function ChatbotScript:Close()
    if ChatbotUI then
        ChatbotUI:Destroy()
        ChatbotUI = nil
    end
end

-- Khởi chạy chatbot
function ChatbotScript:Start()
    self:CreateGUI()
    print("=== Chatbot Tuann Pro ===")
    print("Phiên bản: " .. self.Config.Version)
    print("Hỗ trợ executor: " .. table.concat(self.Config.SupportedExecutors, ", "))
    print("Hướng dẫn:")
    print("- Nhấn ⚙ để mở Settings và thêm Gemini API Key")
    print("- Chọn tính cách bot: Bình thường, Sến súa, Bố láo")
    print("- Nhấn ON/OFF để bật/tắt chatbot")
    print("- Nhấn _ để thu nhỏ/phóng to")
    print("- Nhấn X để đóng chatbot")
    print("=== Chúc bạn sử dụng vui vẻ! ===")
end

-- Dừng chatbot
function ChatbotScript:Stop()
    self:Close()
    print("Chatbot Tuann Pro đã dừng!")
end

-- Khởi động chatbot
ChatbotScript:Start()

return ChatbotScript