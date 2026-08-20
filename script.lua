local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем GUI
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
	if joinedPlayer == player then return end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 1 
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
	avatar.ImageTransparency = 1 
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
		if success and content then avatar.Image = content end
	end)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -55, 1, 0)
	nameLabel.Position = UDim2.new(0, 50, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextTransparency = 1
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = joinedPlayer.DisplayName .. "\n@" .. joinedPlayer.Name
	nameLabel.Parent = frame

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 0.2}):Play()
	TweenService:Create(avatar, tweenInfo, {ImageTransparency = 0}):Play()
	TweenService:Create(nameLabel, tweenInfo, {TextTransparency = 0}):Play()

	task.delay(5, function()
		if not frame or not frame.Parent then return end
		local fadeOut = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
		TweenService:Create(avatar, tweenInfo, {ImageTransparency = 1}):Play()
		TweenService:Create(nameLabel, tweenInfo, {TextTransparency = 1}):Play()
		fadeOut:Play()
		fadeOut.Completed:Connect(function() frame:Destroy() end)
	end)
end

-- 1. ЛОГИКА ДЛЯ ТЕХ, КТО УЖЕ В ИГРЕ
for _, existingPlayer in pairs(Players:GetPlayers()) do
	showNotification(existingPlayer)
end

-- 2. ЛОГИКА ДЛЯ ТЕХ, КТО ЗАЙДЕТ ПОСЛЕ
Players.PlayerAdded:Connect(function(newPlayer)
	showNotification(newPlayer)
end)
