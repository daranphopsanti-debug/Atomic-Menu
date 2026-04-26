-- [[ ATOMIC MENU V42.0 - FLY ENGINE FIX ]] --
local PL, UIS, RS, L = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("Lighting")
local TS, Http = game:GetService("TeleportService"), game:GetService("HttpService")
local player = PL.LocalPlayer

-- === [ 1. AUTO CLEANUP ] ===
for _, v in pairs(player.PlayerGui:GetChildren()) do if v.Name:find("Atomic") then v:Destroy() end end

-- === [ 2. SETTINGS ] ===
local menuLocked, buttonLocked, flySpeed, camRun = false, false, 60, false
local waypoints = {}
_G.Nc, _G.AF, _G.E, _G.Xray, _G.Invis, _G.FE, _G.Flying = false, false, false, false, false, false, false
local bv, bg = nil, nil -- ตัวแปรแรงบิน

-- Anti-AFK
player.Idled:Connect(function() game:GetService("VirtualUser"):CaptureController() game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)

-- === [ 3. UI CORE ] ===
local screenGui = Instance.new("ScreenGui", player.PlayerGui); screenGui.Name = "Atomic_V42"; screenGui.ResetOnSpawn = false

-- ปุ่มวงกลมเปิดเมนู
local aBtn = Instance.new("TextButton", screenGui); aBtn.Size = UDim2.new(0, 50, 0, 50); aBtn.Position = UDim2.new(0, 20, 0.15, 0); aBtn.BackgroundColor3 = Color3.fromRGB(45, 0, 90); aBtn.Text = "A"; aBtn.TextColor3 = Color3.fromRGB(200, 150, 255); aBtn.Font = "GothamBold"; aBtn.TextSize = 24; aBtn.ZIndex = 10
Instance.new("UICorner", aBtn).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", aBtn).Color = Color3.fromRGB(130, 0, 255)

-- หน้าต่างหลัก แนวนอน
local main = Instance.new("Frame", screenGui); main.Size = UDim2.new(0, 520, 0, 310); main.Position = UDim2.new(0.5, -260, 0.4, 0); main.BackgroundColor3 = Color3.fromRGB(12, 12, 18); main.Visible = false; main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", main).Color = Color3.fromRGB(70, 0, 150)

-- Drag System
local function MakeDraggable(obj, mode)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        local isLock = (mode == "M" and menuLocked) or (mode == "B" and buttonLocked)
        if not isLock and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    RS.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end
MakeDraggable(aBtn, "B"); MakeDraggable(main, "M"); aBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- Header
local head = Instance.new("Frame", main); head.Size = UDim2.new(1, 0, 0, 35); head.BackgroundTransparency = 1
local title = Instance.new("TextLabel", head); title.Size = UDim2.new(0.5, 0, 1, 0); title.Position = UDim2.new(0, 10, 0, 0); title.BackgroundTransparency = 1; title.Text = "ATOMIC MENU | BY DARAN"; title.TextColor3 = Color3.new(0.8, 0.6, 1); title.Font = "GothamBold"; title.TextSize = 12; title.TextXAlignment = "Left"

local function createLock(n, x, cb)
    local b = Instance.new("TextButton", head); b.Size = UDim2.new(0, 70, 0, 22); b.Position = UDim2.new(1, x, 0, 6); b.BackgroundColor3 = Color3.fromRGB(35, 35, 50); b.Text = n.."-UN"; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 11; Instance.new("UICorner", b)
    local act = false; b.MouseButton1Click:Connect(function() act = not act; b.Text = act and n.."-LOCK" or n.."-UN"; b.BackgroundColor3 = act and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(35, 35, 50); cb(act) end)
end
createLock("M", -155, function(v) menuLocked = v end); createLock("B", -80, function(v) buttonLocked = v; aBtn.BackgroundTransparency = v and 0.5 or 0 end)

-- === [ 4. TAB SYSTEM ] ===
local side = Instance.new("Frame", main); side.Size = UDim2.new(0, 110, 1, -45); side.Position = UDim2.new(0, 8, 0, 40); side.BackgroundTransparency = 1; Instance.new("UIListLayout", side).Padding = UDim.new(0, 5)
local container = Instance.new("Frame", main); container.Size = UDim2.new(1, -135, 1, -45); container.Position = UDim2.new(0, 125, 0, 40); container.BackgroundTransparency = 1

local function createTab(name)
    local b = Instance.new("TextButton", side); b.Size = UDim2.new(1, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(22, 22, 28); b.Text = name; b.TextColor3 = Color3.new(0.7, 0.7, 0.7); b.Font = "GothamBold"; b.TextSize = 13; Instance.new("UICorner", b)
    local p = Instance.new("ScrollingFrame", container); p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.AutomaticCanvasSize = "Y"; p.ScrollBarThickness = 2
    local grid = Instance.new("UIGridLayout", p); grid.CellSize = UDim2.new(0, 180, 0, 38); grid.CellPadding = UDim2.new(0, 10, 0, 10)
    b.MouseButton1Click:Connect(function()
        for _, x in pairs(container:GetChildren()) do if x:IsA("ScrollingFrame") then x.Visible = false end end
        for _, x in pairs(side:GetChildren()) do if x:IsA("TextButton") then x.BackgroundColor3 = Color3.fromRGB(22, 22, 28) end end
        p.Visible = true; b.BackgroundColor3 = Color3.fromRGB(90, 0, 220); b.TextColor3 = Color3.new(1,1,1)
    end)
    return p, grid
end

local function addToggle(n, p, cb)
    local b = Instance.new("TextButton", p); b.BackgroundColor3 = Color3.fromRGB(35, 20, 20); b.Text = n .. ": OFF"; b.TextColor3 = Color3.new(0.9, 0.9, 0.9); b.Font = "GothamBold"; b.TextSize = 11; Instance.new("UICorner", b)
    local s = false; b.MouseButton1Click:Connect(function() s = not s; b.Text = n .. (s and ": ON" or ": OFF"); b.BackgroundColor3 = s and Color3.fromRGB(90, 0, 220) or Color3.fromRGB(35, 20, 20); cb(s) end)
end
local function addBtn(n, p, cb)
    local b = Instance.new("TextButton", p); b.BackgroundColor3 = Color3.fromRGB(30, 30, 40); b.Text = n; b.TextColor3 = Color3.new(1, 1, 1); b.Font = "GothamBold"; b.TextSize = 11; Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb)
end

-- สร้าง Tab ครบ 6 หน้า (ห้ามขาด)
local tCred, g1 = createTab("Credits"); g1:Destroy()
local tPlay, _ = createTab("Player")
local tTele, _ = createTab("Teleport")
local tVis, _ = createTab("Visual")
local tMisc, _ = createTab("Misc")
local tCam, _ = createTab("FreeCam")

-- Credits
local cl = Instance.new("TextLabel", tCred); cl.Size = UDim2.new(1, 0, 0, 150); cl.BackgroundTransparency = 1; cl.TextColor3 = Color3.new(1,1,1); cl.TextSize = 16; cl.Font = "GothamBold"; cl.Text = "ATOMIC MENU\nBy daran\n\nระบบ บิน ยังใช้ไม่ได้นะครับ"

-- Player
local spIn = Instance.new("TextBox", tPlay); spIn.BackgroundColor3 = Color3.fromRGB(30, 30, 40); spIn.PlaceholderText = "Walk Speed"; spIn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", spIn); spIn:GetPropertyChangedSignal("Text"):Connect(function() if tonumber(spIn.Text) and player.Character then player.Character.Humanoid.WalkSpeed = tonumber(spIn.Text) end end)
addToggle("Mobile Fly", tPlay, function(v) _G.Flying = v; flyPad.Visible = v; if not v then if bv then bv:Destroy() bv = nil end if bg then bg:Destroy() bg = nil end if player.Character then player.Character.Humanoid.PlatformStand = false end end end)
addToggle("Invis (ล่องหน)", tPlay, function(v) _G.Invis = v if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = v and 1 or 0 end end end end)
addToggle("Noclip", tPlay, function(v) _G.Nc = v if not v and player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end)
addToggle("Inf Jump", tPlay, function(v) if v then _G.J = UIS.JumpRequest:Connect(function() if player.Character then player.Character.Humanoid:ChangeState(3) end end) else if _G.J then _G.J:Disconnect() end end end)
addToggle("AntiFling", tPlay, function(v) _G.AF = v end)
addBtn("Reset Character", tPlay, function() if player.Character then player.Character.Humanoid.Health = 0 end end)

-- Teleport
local tIn = Instance.new("TextBox", tTele); tIn.BackgroundColor3 = Color3.fromRGB(30, 30, 40); tIn.PlaceholderText = "Player Name"; tIn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", tIn)
addBtn("TP Player", tTele, function() local target = tIn.Text:lower() for _, p in pairs(PL:GetPlayers()) do if p.Name:lower():find(target) and p.Character then player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end)
addBtn("Save WP", tTele, function() if tIn.Text ~= "" then waypoints[tIn.Text] = player.Character.HumanoidRootPart.CFrame end end)
addBtn("TP WP", tTele, function() if waypoints[tIn.Text] then player.Character.HumanoidRootPart.CFrame = waypoints[tIn.Text] end end)

-- Visual
local fpsShow = Instance.new("TextLabel", screenGui); fpsShow.Size = UDim2.new(0, 100, 0, 30); fpsShow.Position = UDim2.new(0, 10, 1, -40); fpsShow.BackgroundTransparency = 1; fpsShow.TextColor3 = Color3.fromRGB(0, 255, 150); fpsShow.Font = "GothamBold"; fpsShow.TextSize = 16; fpsShow.Visible = false
addToggle("Check FPS", tVis, function(v) fpsShow.Visible = v end)
addToggle("ESP Player", tVis, function(v) _G.E = v if not v then for _, p in pairs(PL:GetPlayers()) do if p.Character and p.Character:FindFirstChild("AtomicHighlight") then p.Character.AtomicHighlight:Destroy() end end end end)
addToggle("X-Ray", tVis, function(v) _G.Xray = v for _, o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") and not o.Parent:FindFirstChild("Humanoid") then o.LocalTransparencyModifier = v and 0.6 or 0 end end end)
addToggle("Night Vision", tVis, function(v) L.Ambient = v and Color3.new(1,1,1) or Color3.new(0.5,0.5,0.5) end)
addToggle("FPS Boost", tVis, function(v) if v then for _, o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") then o.Material = "SmoothPlastic" elseif o:IsA("Decal") then o.Transparency = 1 end end L.GlobalShadows = false else L.GlobalShadows = true end end)
addToggle("Remove Fog", tVis, function(v) L.FogEnd = v and 1e6 or 1000 end)
addToggle("Fast E", tVis, function(v) _G.FE = v for _, p in pairs(game:GetDescendants()) do if p:IsA("ProximityPrompt") then p.HoldDuration = v and 0 or 1 end end end)

-- Misc
addBtn("Rejoin", tMisc, function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
addBtn("Server Hop", tMisc, function() local s = Http:JSONDecode(game:HttpGet("https://roblox.com"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) for _, v in pairs(s.data) do if v.playing < v.maxPlayers and v.id ~= game.JobId then TS:TeleportToPlaceInstance(game.PlaceId, v.id, player) return end end end)
addBtn("Copy Job ID", tMisc, function() setclipboard(game.JobId) end)

-- === [ 5. PADS SETUP (FIXED OFFSET) ] ===
local function createPad(y, c, name)
    local f = Instance.new("Frame", screenGui); f.Name = name; f.Size = UDim2.new(0, 160, 0, 160); f.Position = UDim2.new(0.75, 0, y, 0); f.BackgroundTransparency = 1; f.Visible = false
    local function b(t, px, py)
        local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(0, 50, 0, 50); btn.Position = UDim2.new(0, px, 0, py); btn.Text = t; btn.BackgroundColor3 = c; btn.BackgroundTransparency = 0.3; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local hold = false; btn.MouseButton1Down:Connect(function() hold = true end); btn.MouseButton1Up:Connect(function() hold = false end); UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then hold = false end end); return function() return hold end
    end
    return f, b
end

local flyPad, fF = createPad(0.4, Color3.fromRGB(80, 0, 150), "FlyPad")
local fw, fs, fa, fd = fF("W", 55, 0), fF("S", 55, 110), fF("A", 0, 55), fF("D", 110, 55)
local fup, fdn = fF("↑", 110, 0), fF("↓", 110, 110)
local sLab = Instance.new("TextLabel", flyPad); sLab.Size = UDim2.new(0, 120, 0, 25); sLab.Position = UDim2.new(0, 20, 0, -40); sLab.BackgroundColor3 = Color3.fromRGB(30,30,30); sLab.TextColor3 = Color3.new(1,1,1); sLab.Text = "FLY SPEED: 60"; Instance.new("UICorner", sLab)
addBtn("+", flyPad, function() flySpeed += 20 sLab.Text = "FLY SPEED: "..flySpeed end)
addBtn("-", flyPad, function() flySpeed = math.max(20, flySpeed-20) sLab.Text = "FLY SPEED: "..flySpeed end)

local camPad, cF = createPad(0.4, Color3.fromRGB(0, 100, 200), "CamPad")
local cw, cs, ca, cd = cF("W", 55, 0), cF("S", 55, 110), cF("A", 0, 55), cF("D", 110, 55)
local cup, cdn = cF("↑", 110, 0), cF("↓", 110, 110)
addToggle("Free Cam", tCam, function(s) camRun = s; camPad.Visible = s; if s then if player.Character then player.Character.HumanoidRootPart.Anchored = true end workspace.CurrentCamera.CameraType = "Scriptable" else workspace.CurrentCamera.CameraType = "Custom"; if player.Character then player.Character.HumanoidRootPart.Anchored = false end end end)
local rotX, rotY = 0, 0; UIS.InputChanged:Connect(function(i) if camRun and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then rotX = rotX - i.Delta.X * 0.4 rotY = math.clamp(rotY - i.Delta.Y * 0.4, -85, 85) end end)

-- === [ 6. MASTER LOOP (FLY ENGINE) ] ===
RS.RenderStepped:Connect(function(dt)
    if fpsShow.Visible then fpsShow.Text = "FPS: " .. math.floor(1/dt) end
    local cam = workspace.CurrentCamera
    
    -- Fly Engine (บังคับบินชัวร์ 100%)
    if _G.Flying and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- สร้างแรงบินถ้ายังไม่มี
            if not bv or bv.Parent ~= hrp then
                if bv then bv:Destroy() end
                bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1e6, 1e6, 1e6); bv.Velocity = Vector3.new(0,0,0)
            end
            if not bg or bg.Parent ~= hrp then
                if bg then bg:Destroy() end
                bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6); bg.P = 9000; bg.D = 500
            end
            
            -- คำนวณการเคลื่อนที่
            local move = Vector3.zero
            if fw() then move += cam.CFrame.LookVector end
            if fs() then move -= cam.CFrame.LookVector end
            if fa() then move -= cam.CFrame.RightVector end
            if fd() then move += cam.CFrame.RightVector end
            if fup() then move += Vector3.new(0, 1, 0) end
            if fdn() then move -= Vector3.new(0, 1, 0) end
            
            local targetVel = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
            bv.Velocity = bv.Velocity:Lerp(targetVel, 0.15) -- บินแบบลื่นๆ
            bg.CFrame = cam.CFrame
            player.Character.Humanoid.PlatformStand = true
        end
    end
    
    -- Free Cam
    if camRun then
        cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(0, math.rad(rotX), 0) * CFrame.Angles(math.rad(rotY), 0, 0)
        local m = Vector3.zero
        if cw() then m += cam.CFrame.LookVector end if cs() then m -= cam.CFrame.LookVector end
        if ca() then m -= cam.CFrame.RightVector end if cd() then m += cam.CFrame.RightVector end
        if cup() then m += Vector3.new(0, 1, 0) end if cdn() then m -= Vector3.new(0, 1, 0) end
        cam.CFrame = cam.CFrame + (m * 2)
    end
    
    -- Other Features
    if _G.E then for _, p in pairs(PL:GetPlayers()) do if p ~= player and p.Character then local h = p.Character:FindFirstChild("AtomicHighlight") or Instance.new("Highlight", p.Character); h.Name = "AtomicHighlight"; h.FillColor = Color3.fromRGB(150, 0, 255); h.Enabled = true end end end
    if _G.Nc and player.Character then for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
end)

tPlay.Visible = true; side:FindFirstChildOfClass("TextButton").BackgroundColor3 = Color3.fromRGB(90, 0, 220); side:FindFirstChildOfClass("TextButton").TextColor3 = Color3.new(1,1,1)
