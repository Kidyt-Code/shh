local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local savedPosition = nil
local ghostTorso = nil

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

-- Ghost torso
local function createGhostTorso(position)
	if ghostTorso then ghostTorso:Destroy() end

	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local torsoClone = root:Clone()
	torsoClone.Anchored = true
	torsoClone.CanCollide = false
	torsoClone.Transparency = 0.5
	torsoClone.Material = Enum.Material.Neon
	torsoClone.Color = Color3.new(1, 1, 1)
	torsoClone.CFrame = CFrame.new(position)
	torsoClone.Parent = workspace
	ghostTorso = torsoClone
end

-- Position button
posBtn.MouseButton1Click:Connect(function()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	savedPosition = root.Position
	createGhostTorso(savedPosition)

	messageLabel.Text = "Saved Position"
	task.delay(2, function()
		messageLabel.Text = ""
	end)
end)

-- Tween button with upward fly after
tweenBtn.MouseButton1Click:Connect(function()
	if not savedPosition then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local originalPosition = root.Position
	root.CFrame = CFrame.new(originalPosition + Vector3.new(0, 500, 0))
	task.wait(0.2)
	root.CFrame = CFrame.new(originalPosition)
	task.wait(0.2)

	local tweenInfo = TweenInfo.new(3.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local toPositionTween = TweenService:Create(root, tweenInfo, {
		CFrame = CFrame.new(savedPosition)
	})

	toPositionTween:Play()

	-- After tween finishes, fly up 40 studs
	toPositionTween.Completed:Connect(function()
		local upTween = TweenService:Create(root, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = root.CFrame + Vector3.new(0, 40, 0)
		})
		upTween:Play()
	end)
end)

-- ESP silhouette setup
local espAdornments = {}

local function removeESP(character)
	if espAdornments[character] then
		for _, adorn in ipairs(espAdornments[character]) do
			if adorn and adorn.Parent then
				adorn:Destroy()
			end
		end
		espAdornments[character] = nil
	end
end

local function addESP(character)
	removeESP(character)
	espAdornments[character] = {}

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			local adorn = Instance.new("BoxHandleAdornment")
			adorn.Adornee = part
			adorn.Size = part.Size
			adorn.Transparency = 0.5
			adorn.ZIndex = 10
			adorn.AlwaysOnTop = true
			adorn.Color3 = Color3.fromRGB(0, 170, 255)
			adorn.Parent = part
			table.insert(espAdornments[character], adorn)
		end
	end
end

local function setupCharacterESP(character)
	addESP(character)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			removeESP(character)
		end)
	end
end

local function onPlayerAdded(otherPlayer)
	if otherPlayer == player then return end

	if otherPlayer.Character then
		setupCharacterESP(otherPlayer.Character)
	end

	otherPlayer.CharacterAdded:Connect(setupCharacterESP)
end

for _, otherPlayer in ipairs(Players:GetPlayers()) do
	onPlayerAdded(otherPlayer)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Optional: ESP for yourself
if player.Character then
	setupCharacterESP(player.Character)
end
player.CharacterAdded:Connect(function(char)
	character = char
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")
	setupCharacterESP(char)
end)
