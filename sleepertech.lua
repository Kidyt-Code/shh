local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "TeleportUI"

-- Sound setup
local function createSound(name, soundId)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = soundId
	sound.Volume = 0.6
	sound.Parent = screenGui
	return sound
end

-- Existing sounds
local clickSound = createSound("ClickSound", "rbxassetid://7817336081")
local teleportSound = createSound("TeleportSound", "rbxassetid://864352897")
local toggleSound = createSound("ToggleSound", "rbxassetid://6512218121") -- Shield break sound

-- New sound for toggling shield OFF
local toggleOffSound = createSound("ToggleOffSound", "rbxassetid://75053701115990")

-- Message label
local messageLabel = Instance.new("TextLabel", screenGui)
messageLabel.Size = UDim2.new(1, 0, 0, 40)
messageLabel.Position = UDim2.new(0, 0, 0, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
messageLabel.TextScaled = true
messageLabel.Font = Enum.Font.FredokaOne
messageLabel.Text = ""
messageLabel.ZIndex = 2

-- Create emoji button
local function createEmojiButton(name, pos, emoji)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 150, 0, 50)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Font = Enum.Font.FredokaOne
	btn.Text = emoji

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 12)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	return btn
end

-- Draggable vertical frame
local buttonFrame = Instance.new("Frame", screenGui)
buttonFrame.Size = UDim2.new(0, 160, 0, 180)
buttonFrame.Position = UDim2.new(0, 30, 1, -220)
buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
buttonFrame.BackgroundTransparency = 0.4
buttonFrame.Active = true
buttonFrame.Draggable = true
buttonFrame.Selectable = true

Instance.new("UICorner", buttonFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", buttonFrame).Thickness = 2

-- Buttons
local posBtn = createEmojiButton("PositionBtn", UDim2.new(0, 5, 0, 10), "📍 Save Position")
posBtn.Parent = buttonFrame

local tweenBtn = createEmojiButton("TweenBtn", UDim2.new(0, 5, 0, 65), "🌀 Tween")
tweenBtn.Parent = buttonFrame

local antiStunBtn = createEmojiButton("AntiStunBtn", UDim2.new(0, 5, 0, 120), "🛡️ Anti Stun: OFF")
antiStunBtn.Parent = buttonFrame

-- Saved position and ghost
local savedPosition = nil
local ghostTorso = nil

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

-- ESP
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

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= player then
		if p.Character then
			setupCharacterESP(p.Character)
		end
		p.CharacterAdded:Connect(setupCharacterESP)
	end
end

Players.PlayerAdded:Connect(function(p)
	if p ~= player then
		p.CharacterAdded:Connect(setupCharacterESP)
	end
end)

if player.Character then
	setupCharacterESP(player.Character)
end

player.CharacterAdded:Connect(function(char)
	character = char
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")
	setupCharacterESP(char)
end)

-- Button functions
posBtn.MouseButton1Click:Connect(function()
	clickSound:Play()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	savedPosition = root.Position
	createGhostTorso(savedPosition)
	messageLabel.Text = "Saved Position"
	task.delay(2, function() messageLabel.Text = "" end)
end)

tweenBtn.MouseButton1Click:Connect(function()
	if not savedPosition then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	teleportSound:Play()

	local originalPosition = root.Position
	root.CFrame = CFrame.new(originalPosition + Vector3.new(0, 500, 0))
	task.wait(0.2)
	root.CFrame = CFrame.new(originalPosition)
	task.wait(0.2)

	local targetPosition = savedPosition + Vector3.new(0, 10, 0)
	local tween = TweenService:Create(root, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(targetPosition)
	})
	tween:Play()
end)

-- Anti-Stun
local antiStun = false
local antiStunConnection

local function removeBodyMoversFromPart(part)
	for _, child in pairs(part:GetChildren()) do
		if child:IsA("BodyVelocity") or child:IsA("BodyPosition") or child:IsA("BodyGyro") or child:IsA("BodyForce") then
			child:Destroy()
		end
	end
end

local function setAntiStun(state)
	antiStun = state
	antiStunBtn.Text = "🛡️ Anti Stun: " .. (state and "ON" or "OFF")
	if state then
		toggleSound:Play()
		antiStunConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			if char then
				for _, part in pairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						if part.Anchored then
							part.Anchored = false
						end
						-- Remove stun-related body movers
						removeBodyMoversFromPart(part)
					end
				end
			end
		end)
	else
		toggleOffSound:Play()
		if antiStunConnection then
			antiStunConnection:Disconnect()
			antiStunConnection = nil
		end
	end
end

antiStunBtn.MouseButton1Click:Connect(function()
	setAntiStun(not antiStun)
end)
