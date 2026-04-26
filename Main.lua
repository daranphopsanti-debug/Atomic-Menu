-- [[ ATOMIC MENU V43.0 - FIX RUN ]] --
local PL, UIS, RS, L = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("Lighting")
local TS, Http = game:GetService("TeleportService"), game:GetService("HttpService")
local player = PL.LocalPlayer

-- === [ 1. AUTO CLEANUP ] ===
for _, v in pairs(player.PlayerGui:GetChildren()) do if v.Name:find("Atomic") then v:Destroy() end end

-- === [ 2. SETTINGS ] ===
local menuLocked, buttonLocked, camRun = false, false, false
local waypoints = {}
_G.Nc, _G.AF, _G.E, _G.Xray, _G.Invis, _G.FE = false, false, false, false, false, false

local flying = false
local flySpeed = 60
local bv, bg

-- Store Default Lighting Settings
local defAmbient = L.Ambient
local defOutdoor = L.OutdoorAmbient
local defShadows = L.GlobalShadows
local defBrightness = L.Brightness

player.Idled:Connect(function() game:GetService("VirtualUser"):CaptureController() game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)

-- === [ 3. UI CORE ] ===
local screenGui = Instance.new("ScreenGui", player.PlayerGui); screenGui.Name = "Atomic_V43"; screenGui.ResetOnSpawn = false

local aBtn = Instance.new("TextButton", screenGui); aBtn.Size = UDim2.new(0, 40, 0, 40); aBtn.Position = UDim2.new(0, 15, 0.15, 0); aBtn.BackgroundColor3 = Color3.fromRGB(45, 0, 90); aBtn.Text = "A"; aBtn.TextColor3 = Color3.fromRGB(200, 150, 255); aBtn.Font = "GothamBold"; aBtn.TextSize = 20; aBtn.ZIndex = 10
Instance.new("UICorner", aBtn).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", aBtn).Color = Color3.fromRGB(130, 0, 255)

local main = Instance.new("Frame", screenGui); main.Size = UDim2.new(0, 380, 0, 240); main.Position = UDim2.new(0.5, -190, 0.4, 0); main.BackgroundColor3 = Color3.fromRGB(12, 12, 18); main.Visible = false; main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6); local mStroke = Instance.new("UIStroke", main); mStroke.Color = Color3.fromRGB(70, 0, 150); mStroke.Thickness = 1.5

local fpsShow = Instance.new("TextLabel", screenGui); fpsShow.Size = UDim2.new(0, 80, 0, 25); fpsShow.Position = UDim2.new(0, 10, 1, -30); fpsShow.BackgroundTransparency = 1; fpsShow.TextColor3 = Color3.fromRGB(0, 255, 150); fpsShow.Font = "GothamBold"; fpsShow.TextSize = 14; fpsShow.Visible = false

local function MakeDraggable(obj, mode)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        local isLock = (mode == "M" and menuLocked) or (mode == "B" and buttonLocked)
        if not isLock and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
            dragInput = input 
        end 
    end)
    RS.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end
MakeDraggable(aBtn, "B"); MakeDraggable(main, "M"); aBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

local head = Instance.new("Frame", main); head.Size = UDim2.new(1, 0, 0, 30); head.BackgroundTransparency = 1
local title = Instance.new("TextLabel", head); title.Size = UDim2.new(0.5, 0, 1, 0); title.Position = UDim2.new(0, 10, 0, 0); title.BackgroundTransparency = 1; title.Text = "ATOMIC MENU"; title.TextColor3 = Color3.new(0.8, 0.6, 1); title.Font = "GothamBold"; title.TextSize = 11; title.TextXAlignment = "Left"

local function createLock(n, x, cb)
    local b = Instance.new("TextButton", head); b.Size = UDim2.new(0, 55, 0, 18); b.Position = UDim2.new(1, x, 0, 6); b.BackgroundColor3 = Color3.fromRGB(35, 35, 50); b.Text = n.."-UN"; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 9; Instance.new("UICorner", b)
    local act = false; b.MouseButton1Click:Connect(function() act = not act; b.Text = act and n.."-LOCK" or n.."-UN"; b.BackgroundColor3 = act and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(35, 35, 50); cb(act) end)
end
createLock("M", -120, function(v) menuLocked = v end); createLock("B", -60, function(v) buttonLocked = v; aBtn.BackgroundTransparency = v and 0.5 or 0 end)

-- === [ 4. FLY PAD ] ===
local flyPad = Instance.new("Frame", screenGui); flyPad.Size = UDim2.new(0, 160, 0, 120); flyPad.Position = UDim2.new(0.75, 0, 0.6, 0); flyPad.BackgroundTransparency = 1; flyPad.Visible = false
local function mkFlyBtn(txt, x, y, color)
    local b = Instance.new("TextButton", flyPad); b.Size = UDim2.new(0, 35, 0, 35); b.Position = UDim2.new(0, x, 0, y); b.Text = txt; b.BackgroundColor3 = color or Color3.fromRGB(80, 0, 150); b.BackgroundTransparency = 0.3; b.TextColor3 = Color3.new(1, 1, 1); b.Font = "GothamBold"; b.TextSize = 12; Instance.new("UICorner", b)
    local hold = false; b.MouseButton1Down:Connect(function() hold = true end); b.MouseButton1Up:Connect(function() hold = false end); return function() return hold end
end
local fw, fs, fa, fd = mkFlyBtn("W", 42, 0), mkFlyBtn("S", 42, 76), mkFlyBtn("A", 0, 38), mkFlyBtn("D", 84, 38)
local fu, fdn = mkFlyBtn("↑", 125, 15, Color3.fromRGB(0, 100, 200)), mkFlyBtn("↓", 125, 60, Color3.fromRGB(0, 100, 200))

local function ToggleFly(v)
    flying = v; local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if v then
        bv = Instance.new("BodyVelocity", char.HumanoidRootPart); bg = Instance.new("BodyGyro", char.HumanoidRootPart)
        bv.MaxForce = Vector3.new(1e6,1e6,1e6); bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
        char.Humanoid.PlatformStand = true; flyPad.Visible = true
    else
        if bv then bv:Destroy() end; if bg then bg:Destroy() end
        char.Humanoid.PlatformStand = false; flyPad.Visible = false
    end
end

-- === [ 5. TAB SYSTEM ] ===
local side = Instance.new("Frame", main); side.Size = UDim2.new(0, 90, 1, -40); side.Position = UDim2.new(0, 6, 0, 35); side.BackgroundTransparency = 1; Instance.new("UIListLayout", side).Padding = UDim.new(0, 4)
local container = Instance.new("Frame", main); container.Size = UDim2.new(1, -110, 1, -40); container.Position = UDim2.new(0, 102, 0, 35); container.BackgroundTransparency = 1

local function createTab(name)
    local b = Instance.new("TextButton", side); b.Size = UDim2.new(1, 0, 0, 28); b.BackgroundColor3 = Color3.fromRGB(22, 22, 28); b.Text = name; b.TextColor3 = Color3.new(0.7, 0.7, 0.7); b.Font = "GothamBold"; b.TextSize = 11; Instance.new("UICorner", b)
    local p = Instance.new("ScrollingFrame", container); p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.AutomaticCanvasSize = "Y"; p.ScrollBarThickness = 1
    local grid = Instance.new("UIGridLayout", p); grid.CellSize = UDim2.new(0, 125, 0, 32); grid.CellPadding = UDim2.new(0, 8, 0, 8)
    b.MouseButton1Click:Connect(function()
        for _, x in pairs(container:GetChildren()) do if x:IsA("ScrollingFrame") then x.Visible = false end end
        for _, x in pairs(side:GetChildren()) do if x:IsA("TextButton") then x.BackgroundColor3 = Color3.fromRGB(22, 22, 28) end end
        p.Visible = true; b.BackgroundColor3 = Color3.fromRGB(90, 0, 220); b.TextColor3 = Color3.new(1,1,1)
    end)
    return p
end

local function addToggle(n, p, cb)
    local b = Instance.new("TextButton", p); b.BackgroundColor3 = Color3.fromRGB(35, 20, 20); b.Text = n .. ": OFF"; b.TextColor3 = Color3.new(0.9, 0.9, 0.9); b.Font = "GothamBold"; b.TextSize = 9; Instance.new("UICorner", b)
    local s = false; b.MouseButton1Click:Connect(function() s = not s; b.Text = n .. (s and ": ON" or ": OFF"); b.BackgroundColor3 = s and Color3.fromRGB(90, 0, 220) or Color3.fromRGB(35, 20, 20); cb(s) end)
end

local function addBtn(n, p, cb)
    local b = Instance.new("TextButton", p); b.BackgroundColor3 = Color3.fromRGB(30, 30, 40); b.Text = n; b.TextColor3 = Color3.new(1, 1, 1); b.Font = "GothamBold"; b.TextSize = 9; Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb)
    return b
end

local tCred = createTab("Credits"); local tPlay = createTab("Player"); local tTele = createTab("Teleport"); local tVis = createTab("Visual"); local tMisc = createTab("Misc"); local tCam = createTab("FreeCam")

-- Credits
local cBtn = addBtn("credits by daran - Atomic Menu full version", tCred, function() end)
cBtn.Parent.UIGridLayout:Destroy(); cBtn.Size = UDim2.new(1, -5, 0, 32); cBtn.TextSize = 10

-- Player Tab
addToggle("FLY", tPlay, function(v) ToggleFly(v) end)
addBtn("Speed +", tPlay, function() flySpeed += 20 end)
addBtn("Speed -", tPlay, function() flySpeed = math.max(20, flySpeed - 20) end)
local wsIn = Instance.new("TextBox", tPlay); wsIn.BackgroundColor3 = Color3.fromRGB(30,30,40); wsIn.PlaceholderText = "WalkSpeed"; wsIn.TextColor3 = Color3.new(1,1,1); wsIn.TextSize = 9; Instance.new("UICorner", wsIn)
wsIn:GetPropertyChangedSignal("Text"):Connect(function() if tonumber(wsIn.Text) and player.Character then player.Character.Humanoid.WalkSpeed = tonumber(wsIn.Text) end end)
addToggle("AntiFling", tPlay, function(v) _G.AF = v end)
addToggle("Inf Jump", tPlay, function(v) if v then _G.J = UIS.JumpRequest:Connect(function() if player.Character then player.Character.Humanoid:ChangeState(3) end end) else if _G.J then _G.J:Disconnect() end end end)
addToggle("Noclip", tPlay, function(v) _G.Nc = v end)
addToggle("Invis", tPlay, function(v) if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = v and 1 or 0 end end end end)

-- Hitbox (Fixed)
addToggle("Hitbox", tPlay, function(v)
    for _, p in pairs(PL:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            hrp.Size = v and Vector3.new(5,5,5) or Vector3.new(2,2,1)
            hrp.Transparency = v and 0.5 or 1
            hrp.Material = v and Enum.Material.Neon or Enum.Material.Plastic
        end
    end
end)

addBtn("Reset", tPlay, function() if player.Character then player.Character.Humanoid.Health = 0 end end)

-- Teleport Tab
local tpIn = Instance.new("TextBox", tTele); tpIn.BackgroundColor3 = Color3.fromRGB(30,30,40); tpIn.PlaceholderText = "Name / WP"; tpIn.TextColor3 = Color3.new(1,1,1); tpIn.TextSize = 9; Instance.new("UICorner", tpIn)
addBtn("TP Player", tTele, function() local t = tpIn.Text:lower() for _, p in pairs(PL:GetPlayers()) do if p.Name:lower():find(t) and p.Character then player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end)
addBtn("Save WP", tTele, function() if tpIn.Text ~= "" then waypoints[tpIn.Text] = player.Character.HumanoidRootPart.CFrame end end)
addBtn("TP WP", tTele, function() if waypoints[tpIn.Text] then player.Character.HumanoidRootPart.CFrame = waypoints[tpIn.Text] end end)

-- Visual Tab
addToggle("FPS Show", tVis, function(v) fpsShow.Visible = v end)
addToggle("RTX Mode", tVis, function(v)
    if v then
        L.GlobalShadows = true; L.Ambient = Color3.fromRGB(150, 150, 150); L.OutdoorAmbient = Color3.fromRGB(100, 100, 100); L.Brightness = 2.2
        local b = L:FindFirstChild("AtomicBloom") or Instance.new("BloomEffect", L); b.Name = "AtomicBloom"; b.Intensity = 1.2; b.Size = 24; b.Threshold = 0.8
        local c = L:FindFirstChild("AtomicColor") or Instance.new("ColorCorrectionEffect", L); c.Name = "AtomicColor"; c.Contrast = 0.2; c.Saturation = 0.25; c.Brightness = 0.05
        local s = L:FindFirstChild("AtomicRays") or Instance.new("SunRaysEffect", L); s.Name = "AtomicRays"; s.Intensity = 0.1; s.Spread = 1
    else
        L.GlobalShadows = defShadows; L.Ambient = defAmbient; L.OutdoorAmbient = defOutdoor; L.Brightness = defBrightness
        if L:FindFirstChild("AtomicBloom") then L.AtomicBloom:Destroy() end
        if L:FindFirstChild("AtomicColor") then L.AtomicColor:Destroy() end
        if L:FindFirstChild("AtomicRays") then L.AtomicRays:Destroy() end
    end
end)
addToggle("ESP", tVis, function(v) 
    _G.E = v 
    if not v then for _, p in pairs(PL:GetPlayers()) do if p.Character and p.Character:FindFirstChild("AtomicHighlight") then p.Character.AtomicHighlight:Destroy() end end end
end)

-- Tracer (Beam System)
_G.TracerActive = false
addToggle("Tracer", tVis, function(v)
    _G.TracerActive = v
    if not v then
        for _, p in pairs(PL:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("AtomicTracer") then p.Character.AtomicTracer:Destroy() end
                if p.Character.HumanoidRootPart:FindFirstChild("AtomicAtch") then p.Character.HumanoidRootPart.AtomicAtch:Destroy() end
            end
        end
    end
end)

addToggle("Xray", tVis, function(v) _G.Xray = v for _, o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") and not o.Parent:FindFirstChild("Humanoid") then o.LocalTransparencyModifier = v and 0.6 or 0 end end end)
addToggle("Night Vision", tVis, function(v) L.Ambient = v and Color3.new(1,1,1) or defAmbient end)
addToggle("FPS Boost", tVis, function(v)
    L.GlobalShadows = not v
    for _, o in pairs(workspace:GetDescendants()) do 
        if o:IsA("BasePart") then o.Material = v and Enum.Material.SmoothPlastic or Enum.Material.Plastic 
        elseif o:IsA("Decal") then o.Transparency = v and 1 or 0 end 
    end 
end)
addToggle("No Fog", tVis, function(v) L.FogEnd = v and 1e6 or 1000 end)
addToggle("Fast E", tVis, function(v) _G.FE = v for _, p in pairs(game:GetDescendants()) do if p:IsA("ProximityPrompt") then p.HoldDuration = v and 0 or 1 end end end)

-- Misc Tab
addBtn("Rejoin", tMisc, function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
addBtn("Server Hop", tMisc, function() 
    local s = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, v in pairs(s.data) do if v.playing < v.maxPlayers and v.id ~= game.JobId then TS:TeleportToPlaceInstance(game.PlaceId, v.id, player) return end end 
end)

-- FreeCam Tab
local function createCamPad(y, c)
    local f = Instance.new("Frame", screenGui); f.Size = UDim2.new(0, 120, 0, 120); f.Position = UDim2.new(0.75, 0, y, 0); f.BackgroundTransparency = 1; f.Visible = false
    local function b(t, px, py)
        local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(0, 35, 0, 35); btn.Position = UDim2.new(0, px, 0, py); btn.Text = t; btn.BackgroundColor3 = c; btn.BackgroundTransparency = 0.3; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 12; Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local h = false; btn.MouseButton1Down:Connect(function() h = true end); btn.MouseButton1Up:Connect(function() h = false end); return function() return h end
    end
    return f, b
end
local camPad, cF = createCamPad(0.4, Color3.fromRGB(0, 100, 200))
local cw, cs, ca, cd = cF("W", 42, 0), cF("S", 42, 84), cF("A", 0, 42), cF("D", 84, 42)
local cup, cdn = cF("↑", 84, 0), cF("↓", 84, 84)
local rotX, rotY = 0, 0
addToggle("Free Cam", tCam, function(s) camRun = s; camPad.Visible = s; if s then if player.Character then player.Character.HumanoidRootPart.Anchored = true end workspace.CurrentCamera.CameraType = "Scriptable" else workspace.CurrentCamera.CameraType = "Custom"; if player.Character then player.Character.HumanoidRootPart.Anchored = false end end end)
UIS.InputChanged:Connect(function(i) if camRun and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then rotX = rotX - i.Delta.X * 0.4 rotY = math.clamp(rotY - i.Delta.Y * 0.4, -85, 85) end end)

-- === [ MASTER LOOP ] ===
RS.RenderStepped:Connect(function(dt)
    if fpsShow.Visible then fpsShow.Text = "FPS: " .. math.floor(1/dt) end
    
    -- Beam Tracer Rendering
    if _G.TracerActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local myAtch = player.Character.HumanoidRootPart:FindFirstChild("AtomicMyAtch") or Instance.new("Attachment", player.Character.HumanoidRootPart)
        myAtch.Name = "AtomicMyAtch"
        myAtch.Position = Vector3.new(0, -2, 0)

        for _, p in pairs(PL:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = p.Character.HumanoidRootPart
                local tAtch = targetHRP:FindFirstChild("AtomicAtch") or Instance.new("Attachment", targetHRP)
                tAtch.Name = "AtomicAtch"
                
                local beam = p.Character:FindFirstChild("AtomicTracer") or Instance.new("Beam", p.Character)
                beam.Name = "AtomicTracer"
                beam.Attachment0 = myAtch
                beam.Attachment1 = tAtch
                beam.Color = ColorSequence.new(Color3.fromRGB(150, 0, 255))
                beam.Width0, beam.Width1 = 0.1, 0.1
                beam.FaceCamera, beam.Enabled = true, true
            end
        end
    end

    if camRun then
        local c = workspace.CurrentCamera; c.CFrame = CFrame.new(c.CFrame.Position) * CFrame.Angles(0, math.rad(rotX), 0) * CFrame.Angles(math.rad(rotY), 0, 0)
        local m = Vector3.zero; if cw() then m += c.CFrame.LookVector end if cs() then m -= c.CFrame.LookVector end if ca() then m -= c.CFrame.RightVector end if cd() then m += c.CFrame.RightVector end if cup() then m += Vector3.new(0, 1, 0) end if cdn() then m -= Vector3.new(0, 1, 0) end
        c.CFrame = c.CFrame + (m * 1.5)
    end
    if flying and bv and bg and player.Character then
        local cam = workspace.CurrentCamera; local move = Vector3.zero
        if fw() or UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if fs() or UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if fa() or UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if fd() or UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if fu() or UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if fdn() or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        if move.Magnitude > 0 then move = move.Unit * flySpeed end
        bv.Velocity = bv.Velocity:Lerp(move, 0.2); bg.CFrame = cam.CFrame
    end
    if _G.Nc and player.Character then for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if _G.AF and player.Character then player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero end
    if _G.E then 
        for _, p in pairs(PL:GetPlayers()) do 
            if p ~= player and p.Character then 
                local h = p.Character:FindFirstChild("AtomicHighlight") or Instance.new("Highlight", p.Character)
                h.Name = "AtomicHighlight"; h.FillColor = Color3.fromRGB(150, 0, 255); h.Enabled = true 
            end 
        end 
    end
end)

tPlay.Visible = true; side:FindFirstChildOfClass("TextButton").BackgroundColor3 = Color3.fromRGB(90, 0, 220)
