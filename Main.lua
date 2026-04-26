-- [[ ATOMIC MENU V27.1 - FLY SPEED FIX ]] --
-- Created by: daran
-- Status: แก้ไขตัวบอกความเร็วบินไม่เปลี่ยนตัวเลข / รันติด 100%

local PL = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local L = game:GetService("Lighting")

local player = PL.LocalPlayer
local waypoints = {}
local menuLocked, buttonLocked = false, false
local camRunning = false
local flySpeed = 60 -- ค่าเริ่มต้นความเร็วบิน

-- === [ โครงสร้าง GUI ] ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Atomic_Official"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- FPS Counter
local fpsLabel = Instance.new("TextLabel", screenGui)
fpsLabel.Size = UDim2.new(0, 100, 0, 30); fpsLabel.Position = UDim2.new(0, 10, 1, -40); fpsLabel.BackgroundTransparency = 1; fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150); fpsLabel.TextSize = 14; fpsLabel.Font = Enum.Font.GothamBold; fpsLabel.TextXAlignment = Enum.TextXAlignment.Left; fpsLabel.Visible = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 390, 0, 260); mainFrame.Position = UDim2.new(0.5, -195, 0.4, 0); mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); mainFrame.Active = true; mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(120, 0, 255); mainStroke.Thickness = 2

-- === [ ระบบลาก ] ===
local function setupDrag(obj, isBtn)
	local dragging, dInput, start, startPos
	obj.InputBegan:Connect(function(i)
		local locked = isBtn and buttonLocked or menuLocked
		if not locked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			dragging = true; start = i.Position; startPos = obj.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	obj.InputChanged:Connect(function(i) if dragging then dInput = i end end)
	RS.RenderStepped:Connect(function() if dragging and dInput then local delta = dInput.Position - start obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end

local aBtn = Instance.new("TextButton", screenGui)
aBtn.Size = UDim2.new(0, 42, 0, 42); aBtn.Position = UDim2.new(0, 20, 0.15, 0); aBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 80); aBtn.Text = "A"; aBtn.TextColor3 = Color3.fromRGB(200, 150, 255); aBtn.Font = Enum.Font.GothamBold; aBtn.TextSize = 20; Instance.new("UICorner", aBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", aBtn).Color = Color3.fromRGB(130, 0, 255)
setupDrag(aBtn, true); setupDrag(mainFrame, false)
aBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

-- === [ หัวข้อ & ล็อก ] ===
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 32); titleLabel.BackgroundColor3 = Color3.fromRGB(30, 0, 70); titleLabel.Text = "   ATOMIC MENU | BY DARAN"; titleLabel.TextColor3 = Color3.fromRGB(210, 160, 255); titleLabel.Font = "GothamBold"; titleLabel.TextXAlignment = "Left"; Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 10)

local function createLock(name, x, cb)
	local b = Instance.new("TextButton", mainFrame); b.Size = UDim2.new(0, 68, 0, 20); b.Position = UDim2.new(1, x, 0, 6); b.BackgroundColor3 = Color3.fromRGB(45, 45, 70); b.Text = name.."-UN"; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 8; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	local locked = false; b.MouseButton1Click:Connect(function() locked = not locked; b.Text = locked and name.."-LOCK" or name.."-UN"; b.BackgroundColor3 = locked and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(45, 45, 70); cb(locked) end)
end
createLock("M", -150, function(v) menuLocked = v end)
createLock("B", -75, function(v) buttonLocked = v aBtn.BackgroundTransparency = v and 0.4 or 0 end)

-- === [ ระบบ Tab ] ===
local tList = Instance.new("Frame", mainFrame); tList.Size = UDim2.new(0, 95, 1, -45); tList.Position = UDim2.new(0, 5, 0, 38); tList.BackgroundTransparency = 1; Instance.new("UIListLayout", tList).Padding = UDim.new(0, 5)
local cont = Instance.new("Frame", mainFrame); cont.Size = UDim2.new(1, -110, 1, -45); cont.Position = UDim2.new(0, 105, 0, 38); cont.BackgroundTransparency = 1

local function createTab(name)
	local btn = Instance.new("TextButton", tList); btn.Size = UDim2.new(1, 0, 0, 28); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35); btn.Text = name; btn.TextColor3 = Color3.new(0.8,0.8,0.8); btn.TextSize = 10; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
	local page = Instance.new("ScrollingFrame", cont); page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false; page.CanvasSize = UDim2.new(0, 0, 5, 0); page.ScrollBarThickness = 2
	if name ~= "Credits" then local grid = Instance.new("UIGridLayout", page); grid.CellSize = UDim2.new(0, 120, 0, 30); grid.CellPadding = UDim2.new(0, 8, 0, 8) end
	btn.MouseButton1Click:Connect(function() for _, v in pairs(cont:GetChildren()) do v.Visible = false end for _, v in pairs(tList:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(25, 25, 35) end end page.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(110, 0, 230) end)
	return page
end

local function makeToggle(name, parent, callback)
	local b = Instance.new("TextButton", parent); b.BackgroundColor3 = Color3.fromRGB(65, 25, 25); b.Text = name .. ": OFF"; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 9; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	local s = false; b.MouseButton1Click:Connect(function() s = not s; b.Text = name .. (s and ": ON" or ": OFF"); b.BackgroundColor3 = s and Color3.fromRGB(110, 0, 230) or Color3.fromRGB(65, 25, 25); callback(s) end)
end

-- === [ สร้างแต่ละหน้า ] ===
local pHome = createTab("Credits")
local pP = createTab("Player")
local pT = createTab("Teleport")
local pV = createTab("Visual")
local pC = createTab("FreeCam")

-- Credits (Top Aligned)
local credLabel = Instance.new("TextLabel", pHome); credLabel.Size = UDim2.new(1, -20, 1, -20); credLabel.Position = UDim2.new(0, 10, 0, 15); credLabel.BackgroundTransparency = 1; credLabel.TextColor3 = Color3.new(1, 1, 1); credLabel.TextSize = 14; credLabel.Font = "GothamBold"; credLabel.TextYAlignment = "Top"; credLabel.TextXAlignment = "Center"; credLabel.TextWrapped = true
credLabel.Text = "ATOMIC MENU\n\nDeveloped by: daran\n\nแก้บัคหมดแล้วครับ\nตัวบอกความเร็ว Fix แล้ว!"

-- === [ แผงควบคุมบิน (Fixed Speed Logic) ] ===
local function createPad(pos_y)
	local f = Instance.new("Frame", screenGui); f.Size = UDim2.new(0, 180, 0, 180); f.Position = UDim2.new(0.75, 0, pos_y, 0); f.BackgroundTransparency = 1; f.Visible = false
	local function btn(txt, pos, col)
		local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 48, 0, 48); b.Position = pos; b.Text = txt; b.BackgroundColor3 = col or Color3.fromRGB(60, 0, 120); b.BackgroundTransparency = 0.2; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
		local h = false; b.MouseButton1Down:Connect(function() h = true end); b.MouseButton1Up:Connect(function() h = false end); return function() return h end
	end
	return f, btn
end

local flyPad, flyBtnFunc = createPad(0.45)
local fw, fs, fa, fd = flyBtnFunc("W", UDim2.new(0.35,0,0,0)), flyBtnFunc("S", UDim2.new(0.35,0,0.35,0)), flyBtnFunc("A", UDim2.new(0.1,0,0.35,0)), flyBtnFunc("D", UDim2.new(0.6,0,0.35,0))
local fup, fdn = flyBtnFunc("↑", UDim2.new(0.6,0,-0.15,0), Color3.fromRGB(100, 0, 200)), flyBtnFunc("↓", UDim2.new(0.6,0,0.8,0), Color3.fromRGB(100, 0, 200))

-- ตัวบอกความเร็วที่แท้จริง
local speedDisplay = Instance.new("TextLabel", flyPad)
speedDisplay.Size = UDim2.new(0, 140, 0, 25); speedDisplay.Position = UDim2.new(0.2, 0, -0.35, 0); speedDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 30); speedDisplay.TextColor3 = Color3.new(1, 1, 1); speedDisplay.Text = "FLY SPEED: 60"; speedDisplay.Font = "GothamBold"; speedDisplay.TextSize = 12; Instance.new("UICorner", speedDisplay); Instance.new("UIStroke", speedDisplay).Color = Color3.fromRGB(120, 0, 255)

local pBtn = Instance.new("TextButton", flyPad); pBtn.Size = UDim2.new(0,35,0,35); pBtn.Position = UDim2.new(-0.2,0,0,0); pBtn.Text = "+"; pBtn.BackgroundColor3 = Color3.fromRGB(0,180,0); pBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pBtn)
local mBtn = Instance.new("TextButton", flyPad); mBtn.Size = UDim2.new(0,35,0,35); mBtn.Position = UDim2.new(-0.2,0,0.25,0); mBtn.Text = "-"; mBtn.BackgroundColor3 = Color3.fromRGB(180,0,0); mBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", mBtn)

pBtn.MouseButton1Click:Connect(function() flySpeed = flySpeed + 20; speedDisplay.Text = "FLY SPEED: " .. flySpeed end)
mBtn.MouseButton1Click:Connect(function() flySpeed = math.max(20, flySpeed - 20); speedDisplay.Text = "FLY SPEED: " .. flySpeed end)

local camPad, camBtnFunc = createPad(0.45)
local cw, cs, ca, cd = camBtnFunc("W", UDim2.new(0.3,0,0,0)), camBtnFunc("S", UDim2.new(0.3,0,0.35,0)), camBtnFunc("A", UDim2.new(0,0,0.35,0)), camBtnFunc("D", UDim2.new(0.6,0,0.35,0))
local cup, cdn = camBtnFunc("↑", UDim2.new(0.6,0,-0.15,0), Color3.fromRGB(0, 150, 255)), camBtnFunc("↓", UDim2.new(0.6,0,0.8,0), Color3.fromRGB(0, 150, 255))

-- [ Logics ]
local spdBox = Instance.new("TextBox", pP); spdBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35); spdBox.PlaceholderText = "Walk Speed"; spdBox.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", spdBox); spdBox:GetPropertyChangedSignal("Text"):Connect(function() if tonumber(spdBox.Text) and player.Character then player.Character.Humanoid.WalkSpeed = tonumber(spdBox.Text) end end)
local flying, bv, bg = false, nil, nil
makeToggle("Mobile Fly", pP, function(v) flying = v; flyPad.Visible = v; local char = player.Character if v and char then bv, bg = Instance.new("BodyVelocity", char.HumanoidRootPart), Instance.new("BodyGyro", char.HumanoidRootPart); bv.MaxForce, bg.MaxTorque = Vector3.new(1e6,1e6,1e6), Vector3.new(1e6,1e6,1e6); char.Humanoid.PlatformStand = true else if bv then bv:Destroy() end if bg then bg:Destroy() end if char then char.Humanoid.PlatformStand = false end end end)
makeToggle("AntiFling", pP, function(v) _G.AF = v end)
makeToggle("Inf Jump", pP, function(v) if v then _G.J = UIS.JumpRequest:Connect(function() if player.Character then player.Character.Humanoid:ChangeState(3) end end) else if _G.J then _G.J:Disconnect() end end end)
makeToggle("Noclip", pP, function(v) _G.Nc = v end)
makeToggle("Invis", pP, function(v) if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = v and 1 or 0 end end end end)
local resB = Instance.new("TextButton", pP); resB.BackgroundColor3 = Color3.fromRGB(45,45,60); resB.Text = "Reset Character"; resB.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", resB); resB.MouseButton1Click:Connect(function() if player.Character then player.Character.Humanoid.Health = 0 end end)

local tIn = Instance.new("TextBox", pT); tIn.BackgroundColor3 = Color3.fromRGB(25, 25, 35); tIn.PlaceholderText = "Name / WP"; tIn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", tIn)
local function tAct(n, cb) local b = Instance.new("TextButton", pT); b.BackgroundColor3 = Color3.fromRGB(45,45,60); b.Text = n; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb) end
tAct("Save WP", function() if tIn.Text ~= "" and player.Character then waypoints[tIn.Text] = player.Character.HumanoidRootPart.CFrame end end); tAct("TP WP", function() if waypoints[tIn.Text] and player.Character then player.Character.HumanoidRootPart.CFrame = waypoints[tIn.Text] end end); tAct("TP Player", function() local n = tIn.Text:lower() for _, p in pairs(PL:GetPlayers()) do if p.Name:lower():find(n) or p.DisplayName:lower():find(n) then if p.Character then player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end end)

makeToggle("Check FPS", pV, function(v) fpsLabel.Visible = v end)
makeToggle("ESP Player", pV, function(v) _G.E = v if not v then for _, p in pairs(PL:GetPlayers()) do if p.Character and p.Character:FindFirstChild("AtomicHighlight") then p.Character.AtomicHighlight:Destroy() end end end end)
makeToggle("X-Ray", pV, function(v) for _, x in pairs(workspace:GetDescendants()) do if x:IsA("BasePart") and not x.Parent:FindFirstChild("Humanoid") then x.LocalTransparencyModifier = v and 0.6 or 0 end end end)
local oldAmb = L.Ambient
makeToggle("NightVision", pV, function(v) if v then L.Ambient, L.OutdoorAmbient, L.ExposureCompensation = Color3.new(1,1,1), Color3.new(1,1,1), 1.5 else L.Ambient, L.OutdoorAmbient, L.ExposureCompensation = oldAmb, oldAmb, 0 end end)
makeToggle("Fast E", pV, function(v) _G.FE = v for _, p in pairs(game:GetDescendants()) do if p:IsA("ProximityPrompt") then p.HoldDuration = v and 0 or 1 end end end)
makeToggle("Remove Fog", pV, function(v) if v then L.FogEnd = 1e6 else L.FogEnd = 1000 end end)
makeToggle("FPS Boost", pV, function(v) if v then for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 end end L.GlobalShadows = false else L.GlobalShadows = true for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 0 end end end end)

local rotX, rotY = 0, 0
makeToggle("Free Cam", pC, function(s) camRunning = s; camPad.Visible = s; local cam = workspace.CurrentCamera if s then if player.Character then player.Character.HumanoidRootPart.Anchored = true end rotX, rotY = math.deg(math.atan2(-cam.CFrame.LookVector.X, -cam.CFrame.LookVector.Z)), math.deg(math.asin(cam.CFrame.LookVector.Y)) cam.CameraType = Enum.CameraType.Scriptable else cam.CameraType = Enum.CameraType.Custom; if player.Character then player.Character.HumanoidRootPart.Anchored = false end end end)
UIS.InputChanged:Connect(function(i) if camRunning and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then rotX = rotX - i.Delta.X * 0.4 rotY = math.clamp(rotY - i.Delta.Y * 0.4, -85, 85) end end)

-- === [ Main Loop ] ===
RS.RenderStepped:Connect(function(dt)
    if fpsLabel.Visible then fpsLabel.Text = "FPS: " .. math.floor(1/dt) end
	local cam = workspace.CurrentCamera
	if flying and bv and bg and player.Character then
		local move = Vector3.zero
		if fw() then move += cam.CFrame.LookVector end
		if fs() then move -= cam.CFrame.LookVector end
		if fa() then move -= cam.CFrame.RightVector end
		if fd() then move += cam.CFrame.RightVector end
		if fup() then move += Vector3.new(0, 1, 0) end
		if fdn() then move -= Vector3.new(0, 1, 0) end
		bv.Velocity = move * flySpeed; bg.CFrame = cam.CFrame
	end
	if camRunning then
		cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(0, math.rad(rotX), 0) * CFrame.Angles(math.rad(rotY), 0, 0)
		local move = Vector3.zero
		if cw() then move += cam.CFrame.LookVector end
		if cs() then move -= cam.CFrame.LookVector end
		if ca() then move -= cam.CFrame.RightVector end
		if cd() then move += cam.CFrame.RightVector end
		if cup() then move += Vector3.new(0, 1, 0) end
		if cdn() then move -= Vector3.new(0, 1, 0) end
		cam.CFrame = cam.CFrame + (move * 2)
	end
	if _G.E then for _, p in pairs(PL:GetPlayers()) do if p ~= player and p.Character then local h = p.Character:FindFirstChild("AtomicHighlight") or Instance.new("Highlight", p.Character); h.Name = "AtomicHighlight"; h.FillColor = Color3.fromRGB(150, 0, 255); h.Enabled = true end end end
	if _G.AF and player.Character then player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero end
	if _G.Nc and player.Character then for _, x in pairs(player.Character:GetDescendants()) do if x:IsA("BasePart") then x.CanCollide = false end end end
end)

pHome.Visible = true; tList:FindFirstChildOfClass("TextButton").BackgroundColor3 = Color3.fromRGB(110, 0, 230)
RS.RenderStepped:Connect(function() if player.Character then for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") and v.Transparency == 1 then v.LocalTransparencyModifier = 0.5 end end end end)
