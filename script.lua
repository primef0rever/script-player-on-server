local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerJoinNotificationGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "NotificationContainer"
container.Size = UDim2.new(0, 220, 0, 300)
container.Position = UDim2.new(1, -20, 1, -180) 
container.AnchorPoint = Vector2.new(1, 1)
container.BackgroundTransparency = 1
container.Parent = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = container

local function showNotification(joinedPlayer)
	-- Не показываем уведомление о самом себе
	if joinedPlayer == player then return end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 1 -- Начальная прозрачность для анимации
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Parent = container

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = frame

	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, 40, 0, 40)
	avatar.Position = UDim2.new(0, 5, 0.5, -20)
	avatar.BackgroundTransparency = 1
	avatar.ImageTransparency = 1 -- Начальная прозрачность
	avatar.Image = "rbxassetid://0"
	avatar.Parent = frame

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(1, 0)
	avatarCorner.Parent = avatar

	task.spawn(function()
		local success, content = pcall(function()
			return Players:GetUserThumbnailAsync(
				joinedPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)
		end)
		if success and content then
			avatar.Image = content
		end
	end)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -55, 1, 0)
	nameLabel.Position = UDim2.new(0, 50, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextTransparency = 1 -- Начальная прозрачность
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = joinedPlayer.DisplayName .. "\n@" .. joinedPlayer.Name
	nameLabel.Parent = frame

	-- АНИМАЦИЯ ПОЯВЛЕНИЯ
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 0.2}):Play()
	TweenService:Create(avatar, tweenInfo, {ImageTransparency = 0}):Play()
	TweenService:Create(nameLabel, tweenInfo, {TextTransparency = 0}):Play()

	-- АНИМАЦИЯ УХОДА (через 5 секунд)
	task.delay(5, function()
		if not frame or not frame.Parent then return end
		
		local fadeOutFrame = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
		TweenService:Create(avatar, tweenInfo, {ImageTransparency = 1}):Play()
		TweenService:Create(nameLabel, tweenInfo, {TextTransparency = 1}):Play()
		
		fadeOutFrame:Play()
		fadeOutFrame.Completed:Connect(function() 
			frame:Destroy() 
		end)
	end)
end

Players.PlayerAdded:Connect(function(newPlayer)
	showNotification(newPlayer)
end)
