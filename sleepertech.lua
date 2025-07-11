local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Helper functions to get character and root
local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getRoot(char)
	return char:WaitForChild("HumanoidRootPart", 10)
end

-- UI Setup
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "TeleportUI"

local messageLabel = Instance.new("TextLabel", screenGui)
messageLabel.Size = UDim2.new(1, 0, 0, 40)
messageLabel.Position = UDim2.new(0, 0, 0, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
messageLabel.TextScaled = true
messageLabel.Font = Enum.Font.FredokaOne
messageLabel.Text = ""
messageLabel.ZIndex = 2

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

local posBtn = createButton("PositionBtn", UDim2.new(0, 30, 1, -120), "Position")
local tweenBtn = createButton("TweenBtn", UDim2.new(0, 200, 1, -120), "Tween")

local savedPosition = nil
local highlightModel = nil

local function createHighlightModel(positionCFrame)
	if highlightModel then
		highlightModel:Destroy()
		highlightModel = nil
	end

	local currentCharacter = getCharacter()
	if not currentCharacter then return end

	local success, clone = pcall(function()
		return currentCharacter:Clone()
	end)

	if not success or not clone then
		warn("Failed to clone character")
		return
	end

	highlightModel = clone
	highlightModel.Name = "HighlightGhost"

	-- Remove scripts and animators
	for _, obj in pairs(highlightModel:GetDescendants()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Animator") then
			obj:Destroy()
		end
	end

	-- Style parts
	for _, part in ipairs(highlightModel:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0.5
			part.Material = Enum.Material.Neon
			part.Color = Color3.new(1, 1, 1)
		elseif part:IsA("Accessory") then
			local handle = part:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				handle.Anchored = true
				handle.CanCollide = false
				handle.Transparency = 0.5
				handle.Material = Enum.Material.Neon
				handle.Color = Color3.new(1, 1, 1)
			end
		elseif part:IsA("Shirt") or part:IsA("Pants") then
			part:Destroy()
		elseif part:IsA("Humanoid") then
			part.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
	end

	-- Position the highlight
	local rootPart = highlightModel:FindFirstChild("HumanoidRootPart")
	if rootPart then
		highlightModel.PrimaryPart = rootPart
		highlightModel:SetPrimaryPartCFrame(positionCFrame)
	end

	highlightModel.Parent = workspace
end

posBtn.MouseButton1Click:Connect(function()
	local currentCharacter = getCharacter()
	local root = getRoot(currentCharacter)
	if not root then return end

	savedPosition = root.Position
	createHighlightModel(CFrame.new(savedPosition))

	messageLabel.Text = "Saved Position"
	task.delay(2, function()
		messageLabel.Text = ""
	end)
end)

tweenBtn.MouseButton1Click:Connect(function()
	if not savedPosition then return end

	local character = getCharacter()
	local root = getRoot(character)
	if not root then return end

	local originalPosition = root.Position

	-- Teleport up 500 studs
	root.CFrame = CFrame.new(originalPosition + Vector3.new(0, 500, 0))
	task.wait(0.2)

	-- Back to original position
	root.CFrame = CFrame.new(originalPosition)
	task.wait(0.2)

	-- Tween to saved position over 3 seconds
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(root, tweenInfo, {
		CFrame = CFrame.new(savedPosition)
	})
	tween:Play()
end)

-- ======= Player ESP =======

local ESP_COLOR = Color3.fromRGB(0, 85, 255)
local ESP_TRANSPARENCY = 0.5

local bodyParts = {
	"Head",
	"UpperTorso", "LowerTorso", -- R15 torso parts
	"Torso", -- R6 torso
	"LeftUpperArm", "LeftLowerArm", "LeftHand",
	"RightUpperArm", "RightLowerArm", "RightHand",
	"LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
	"RightUpperLeg", "RightLowerLeg", "RightFoot",
}

local function applyESP(character)
	for _, partName in ipairs(bodyParts) do
		local part = character:FindFirstChild(partName)
		if part and part:IsA("BasePart") then
			part.Color = ESP_COLOR
			part.Transparency = ESP_TRANSPARENCY
		end
	end
end

local function onCharacterAdded(character)
	character:WaitForChild("HumanoidRootPart", 5)
	applyESP(character)
end

local function onPlayerAdded(otherPlayer)
	if otherPlayer == player then return end

	if otherPlayer.Character then
		onCharacterAdded(otherPlayer.Character)
	end

	otherPlayer.CharacterAdded:Connect(onCharacterAdded)
end

for _, otherPlayer in ipairs(Players:GetPlayers()) do
	onPlayerAdded(otherPlayer)
end

Players.PlayerAdded:Connect(onPlayerAdded)
