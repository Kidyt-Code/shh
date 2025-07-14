local a,b,c=game:GetService("Players"),game:GetService("TweenService"),game:GetService("RunService")
local d=a.LocalPlayer
local e=d.Character or d.CharacterAdded:Wait()
local f=e:WaitForChild("HumanoidRootPart")
local g,h= "KIDYTBETTER",nil
local i=7200
local function j(k)
	local l=k:upper():gsub("%s+","")
	if l~=g then return false,"Invalid key." end
	if h and os.time()-h>=i then return false,"Key expired." end
	if not h then h=os.time() end
	return true,"Key valid. Access granted!"
end
local m=Instance.new("ScreenGui",d:WaitForChild("PlayerGui"))m.Name="KeyInputGui"
local n=Instance.new("Frame",m)
n.Size=UDim2.new(0,400,0,200)
n.Position=UDim2.new(0.5,-200,0.5,-100)
n.BackgroundColor3=Color3.fromRGB(30,30,30)
n.BorderSizePixel=0;n.Active=true;n.Draggable=true
Instance.new("UICorner",n).CornerRadius=UDim.new(0,15)
local o=Instance.new("TextLabel",n)
o.Size=UDim2.new(1,0,0,50)
o.Position=UDim2.new(0,0,0,0)
o.BackgroundTransparency=1
o.Font=Enum.Font.FredokaOne
o.TextSize=28
o.TextColor3=Color3.fromRGB(0,255,0)
o.Text="Enter your key"
o.TextScaled=true
local p=Instance.new("TextBox",n)
p.Size=UDim2.new(0.8,0,0,40)
p.Position=UDim2.new(0.1,0,0,90)
p.ClearTextOnFocus=false
p.Font=Enum.Font.FredokaOne
p.TextSize=24
p.PlaceholderText="Paste key here..."
p.TextColor3=Color3.fromRGB(255,255,255)
p.BackgroundColor3=Color3.fromRGB(50,50,50)
Instance.new("UICorner",p).CornerRadius=UDim.new(0,8)
local q=Instance.new("TextButton",n)
q.Size=UDim2.new(0.4,0,0,40)
q.Position=UDim2.new(0.3,0,0,140)
q.Text="Submit"
q.Font=Enum.Font.FredokaOne
q.TextSize=24
q.TextColor3=Color3.fromRGB(255,255,255)
q.BackgroundColor3=Color3.fromRGB(0,150,0)
Instance.new("UICorner",q).CornerRadius=UDim.new(0,8)
local r=Instance.new("TextLabel",n)
r.Size=UDim2.new(1,-20,0,30)
r.Position=UDim2.new(0,10,0,185)
r.BackgroundTransparency=1
r.Font=Enum.Font.FredokaOne
r.TextSize=18
r.TextColor3=Color3.fromRGB(255,0,0)
r.Text=""
local s=Instance.new("ScreenGui",d:WaitForChild("PlayerGui"))
s.Name="TeleportUI"
s.Enabled=false
local function t(u,v)
	local w=Instance.new("Sound")
	w.Name=u
	w.SoundId=v
	w.Volume=0.6
	w.Parent=s
	return w
end
local x,y,z,aa=t("ClickSound","rbxassetid://7817336081"),t("TeleportSound","rbxassetid://864352897"),t("ToggleSound","rbxassetid://6512218121"),t("ToggleOffSound","rbxassetid://75053701115990")
local ab=Instance.new("TextLabel",s)
ab.Size=UDim2.new(1,0,0,40)
ab.Position=UDim2.new(0,0,0,0)
ab.BackgroundTransparency=1
ab.TextColor3=Color3.fromRGB(0,255,0)
ab.TextScaled=true
ab.Font=Enum.Font.FredokaOne
ab.Text=""
ab.ZIndex=2
local function ac(ad,ae,af)
	local ag=Instance.new("TextButton")
	ag.Name=ad
	ag.Size=UDim2.new(0,150,0,50)
	ag.Position=ae
	ag.BackgroundColor3=Color3.fromRGB(60,60,60)
	ag.TextColor3=Color3.fromRGB(255,255,255)
	ag.TextScaled=true
	ag.Font=Enum.Font.FredokaOne
	ag.Text=af
	Instance.new("UICorner",ag).CornerRadius=UDim.new(0,12)
	local ah=Instance.new("UIStroke",ag)
	ah.Thickness=3
	ah.Color=Color3.fromRGB(255,255,255)
	ah.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
	return ag
end
local ai=Instance.new("Frame",s)
ai.Size=UDim2.new(0,160,0,180)
ai.Position=UDim2.new(0,30,1,-220)
ai.BackgroundColor3=Color3.fromRGB(40,40,40)
ai.BackgroundTransparency=0.4
ai.Active=true
ai.Draggable=true
ai.Selectable=true
Instance.new("UICorner",ai).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",ai).Thickness=2
local aj=ac("PositionBtn",UDim2.new(0,5,0,10),"📍 Save Position")
aj.Parent=ai
local ak=ac("TweenBtn",UDim2.new(0,5,0,65),"🌀 Tween")
ak.Parent=ai
local al=ac("AntiStunBtn",UDim2.new(0,5,0,120),"🛡️ Anti Stun: OFF")
al.Parent=ai
local am=nil
local an=nil
local function ao(ap)
	if am then am:Destroy() end
	local aq=d.Character and d.Character:FindFirstChild("HumanoidRootPart")
	if not aq then return end
	local ar=aq:Clone()
	ar.Anchored=true
	ar.CanCollide=false
	ar.Transparency=0.5
	ar.Material=Enum.Material.Neon
	ar.Color=Color3.new(1,1,1)
	ar.CFrame=CFrame.new(ap)
	ar.Parent=workspace
	am=ar
end
local function as(at)
	local au=d.Character and d.Character:FindFirstChild("HumanoidRootPart")
	if not au then return end
	local av=12
	local aw=40
	local ax=1
	local ay=ax/aw
	for az=0,aw do
		local aA=math.rad((360/aw)*az)
		local aB=Vector3.new(math.cos(aA)*av,0,math.sin(aA)*av)
		local aC=at+aB
		au.CFrame=CFrame.new(aC,at)
		task.wait(ay)
	end
end
local espAdornments={}
local function aD(aE)
	if espAdornments[aE] then
		for _,aF in ipairs(espAdornments[aE]) do
			aF:Destroy()
		end
		espAdornments[aE]=nil
	end
end
local function aG(aH)
	aD(aH)
	espAdornments[aH]={}
	for _,aI in ipairs(aH:GetDescendants()) do
		if aI:IsA("BasePart") then
			local aJ=Instance.new("BoxHandleAdornment")
			aJ.Adornee=aI
			aJ.Size=aI.Size
			aJ.Transparency=0.5
			aJ.ZIndex=10
			aJ.AlwaysOnTop=true
			aJ.Color3=Color3.fromRGB(0,170,255)
			aJ.Parent=aI
			table.insert(espAdornments[aH],aJ)
		end
	end
end
local function aK(aL)
	aG(aL)
	local aM=aL:FindFirstChildOfClass("Humanoid")
	if aM then
		aM.Died:Connect(function()
			aD(aL)
		end)
	end
end
for _,aN in ipairs(a:GetPlayers()) do
	if aN~=d then
		if aN.Character then
			aK(aN.Character)
		end
		aN.CharacterAdded:Connect(aK)
	end
end
a.PlayerAdded:Connect(function(aO)
	if aO~=d then
		aO.CharacterAdded:Connect(aK)
	end
end)
if d.Character then aK(d.Character) end
d.CharacterAdded:Connect(function(aP)
	character=aP
	humanoidRootPart=aP:WaitForChild("HumanoidRootPart")
	aK(aP)
end)
aj.MouseButton1Click:Connect(function()
	x:Play()
	local aQ=d.Character or d.CharacterAdded:Wait()
	local aR=aQ:FindFirstChild("HumanoidRootPart")
	if not aR then return end
	an=aR.Position
	ao(an)
	ab.Text="Saved Position"
	task.delay(2,function() ab.Text="" end)
end)
ak.MouseButton1Click:Connect(function()
	if not an then return end
	local aS=d.Character and d.Character:FindFirstChild("HumanoidRootPart")
	if not aS then return end
	y:Play()
	local aT=aS.Position
	aS.CFrame=CFrame.new(aT+Vector3.new(0,500,0))
	task.wait(0.2)
	aS.CFrame=CFrame.new(aT)
	task.wait(0.2)
	local aU=an+Vector3.new(0,10,0)
	local aV=b:Create(aS,TweenInfo.new(3.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=CFrame.new(aU)})
	aV:Play()
	aV.Completed:Connect(function()
		as(an)
	end)
end)
local amn=false
local amO
local function amP(aQ)
	for _,aR in pairs(aQ:GetChildren()) do
		if aR:IsA("BodyVelocity") or aR:IsA("BodyPosition") or aR:IsA("BodyGyro") or aR:IsA("BodyForce") then
			aR:Destroy()
		end
	end
end
local function amQ(aR)
	amn=aR
	al.Text="🛡️ Anti Stun: "..(aR and "ON" or "OFF")
	if aR then
		z:Play()
		amO=c.Heartbeat:Connect(function()
			local aS=d.Character
			if aS then
				for _,aT in pairs(aS:GetDescendants()) do
					if aT:IsA("BasePart") and aT.Anchored then
						aT.Anchored=false
						amP(aT)
					end
				end
			end
		end)
	else
		aa:Play()
		if amO then amO:Disconnect() amO=nil end
	end
end
al.MouseButton1Click:Connect(function()
	amQ(not amn)
end)
local function amR()
	if m then
		m:Destroy()
		m=nil
	end
	s.Enabled=true
end
q.MouseButton1Click:Connect(function()
	local aS=p.Text
	local aT,aU=j(aS)
	r.TextColor3=aT and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
	r.Text=aU
	if aT then
		amR()
	end
end)
