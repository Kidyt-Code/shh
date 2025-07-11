local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local character = nil
local humanoidRootPart = nil

local savedPosition = nil
local highlightTorso = nil

local espOriginalTransparency = {}

local function setupCharacter(char)
	character = char
	humanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
	
	if savedPosition then
		createHighlightTorso(savedPosition)
	end
end

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

local function createHighlightTorso(position)
	if highlightTorso then
		highlightTorso:Destroy()
		highlightTorso = nil
	end

	if not character then return end
	local originalTorso = humanoidRootPart
	if not originalTorso then return end

	local cloneTorso = originalTorso:Clone()
	cloneTorso.Anchored = true
	cloneTorso.CanCollide = false
	cloneTorso.Transparency = 0.5
	cloneTorso.Material = Enum.Material.Neon
	cloneTorso.Color = Color3.new(1,1,1)
	cloneTorso.CFrame = CFrame.new(position)
	cloneTorso.Parent = workspace

	highlightTorso = cloneTorso
end

posBtn.MouseButton1Click:Connect(function()
	if not humanoidRootPart then return end

	savedPosition = humanoidRootPart.Position
	createHighlightTorso(savedPosition)

	messageLabel.Text = "Saved Position"
	task.delay(2, function()
		messageLabel.Text = ""
	end)
end)

tweenBtn.MouseButton1Click:Connect(function()
	if not savedPosition or not humanoidRootPart then return end

	local originalPosition = humanoidRootPart.Position

	humanoidRootPart.CFrame = CFrame.new(originalPosition + Vector3.new(0, 500, 0))
	task.wait(0.2)

	humanoidRootPart.CFrame = CFrame.new(originalPosition)
	task.wait(0.2)

	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
		CFrame = CFrame.new(savedPosition)
	})
	tween:Play()
end)

-- ======= Player ESP using Highlight + Billboard + forced local transparency =======

local function addBillboardMarker(character)
	-- Remove existing marker to avoid duplicates
	local existing = character:FindFirstChild("ESPBillboard")
	if existing then existing:Destroy() end

	local head = character:FindFirstChild("Head")
	if not head then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPBillboard"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 50, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = character

	local frame = Instance.new("Frame", billboard)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.ClipsDescendants = true
end

local function setPartsTransparency(character, transparency)
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			if transparency == nil then
				-- Restore original transparency
				if espOriginalTransparency[part] ~= nil then
					part.LocalTransparencyModifier = espOriginalTransparency[part]
					espOriginalTransparency[part] = nil
				end
			else
				-- Save original and set transparency locally
				if espOriginalTransparency[part] == nil then
					espOriginalTransparency[part] = part.LocalTransparencyModifier
				end
				part.LocalTransparencyModifier = transparency
			end
		end
	end
end

local function applyHighlight(character)
	-- Remove old highlights and markers
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Highlight") or child.Name == "ESPBillboard" then
			child:Destroy()
		end
	end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(0, 85, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.fromRGB(0, 85, 255)
	highlight.OutlineTransparency = 0
	highlight.Adornee = character
	highlight.Parent = character

	addBillboardMarker(character)

	-- Force parts semi-visible locally so highlight shows through invisibility
	setPartsTransparency(character, 0.5)
end

local function clearHighlight(character)
	-- Remove highlight and marker
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Highlight") or child.Name == "ESPBillboard" then
			child:Destroy()
		end
	end
	-- Restore original transparencies
	setPartsTransparency(character, nil)
end

local function onCharacterAdded(character)
	character:WaitForChild("HumanoidRootPart", 5)
	applyHighlight(character)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			clearHighlight(character)
		end)
	end
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

-- Apply to local player too
if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Setup local player character tracking
if player.Character then
	setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)
