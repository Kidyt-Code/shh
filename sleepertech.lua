local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- UI Setup
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "TeleportUI"

-- Message Label
local messageLabel = Instance.new("TextLabel", screenGui)
messageLabel.Size = UDim2.new(1, 0, 0, 40)
messageLabel.Position = UDim2.new(0, 0, 0, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
messageLabel.TextScaled = true
messageLabel.Font = Enum.Font.FredokaOne
messageLabel.Text = ""
messageLabel.ZIndex = 2

-- UI Template Function
local function createButton(name, pos, text)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 150, 0, 50)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Font = Enum.Font.FredokaOne
	btn.Text = text

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 12)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	btn.Parent = screenGui
	return btn
end

-- Buttons
local posBtn = createButton("PositionBtn", UDim2.new(0, 30, 1, -120), "Position")
local tweenBtn = createButton("TweenBtn", UDim2.new(0, 200, 1, -120), "Tween")

-- Position Saving
local savedPosition = nil

posBtn.MouseButton1Click:Connect(function()
	if character.Parent == nil then return end
	savedPosition = humanoidRootPart.Position
	messageLabel.Text = "Saved Position"
	task.delay(2, function()
		messageLabel.Text = ""
	end)
end)

tweenBtn.MouseButton1Click:Connect(function()
	if not savedPosition then return end

	local originalPosition = humanoidRootPart.Position

	-- Teleport Up Higher (+500)
	humanoidRootPart.CFrame = CFrame.new(originalPosition + Vector3.new(0, 500, 0))
	task.wait(0.2)

	-- Back to original
	humanoidRootPart.CFrame = CFrame.new(originalPosition)
	task.wait(0.2)

	-- Tween to saved position (slow = 3s)
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
		CFrame = CFrame.new(savedPosition)
	})
	tween:Play()
end)
