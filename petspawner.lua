--// Grow A Garden | Nexten Hub (Delta + Rayfield)
--// Teleports auto-detect, Pets auto-list, Smooth Fly, Speed, Save custom shop spots
--// by Nexten

-- UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Grow A Garden | Nexten Hub",
    LoadingTitle = "Nexten Script Hub",
    LoadingSubtitle = "Made By Your Friend Kai",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false }
})

local MainTab      = Window:CreateTab("Main", 4483362458)
local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
local PetsTab      = Window:CreateTab("Pets", 4483362458)

-- Services / Refs
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local Rep     = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

-- Helpers
local function notify(msg)
    pcall(function()
        Rayfield:Notify({ Title = "Nexten Hub", Content = tostring(msg), Duration = 4 })
    end)
    print("[Nexten Hub] "..tostring(msg))
end

local function getCharHRP()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp  = char:WaitForChild("HumanoidRootPart")
    return char, hrp
end

-- Persistent store for saved spots (per-executor session)
getgenv().NextenGrow = getgenv().NextenGrow or {SavedGear=nil, SavedPet=nil}
local STORE = getgenv().NextenGrow

----------------------------------------------------------------
-- Walk Speed
----------------------------------------------------------------
local desiredWalk = 16
local function applyWalkspeed()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = desiredWalk end
    end
end

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 150},
    Increment = 1,
    CurrentValue = 16,
    Flag = "Nexten_WalkSpeed",
    Callback = function(v)
        desiredWalk = v
        applyWalkspeed()
    end
})

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyWalkspeed()
end)

----------------------------------------------------------------
-- Smooth Fly (BodyGyro + BodyVelocity) + speed control
----------------------------------------------------------------
local flyEnabled = false
local flyConn, gyro, velo
local flySpeed = 70

local function stopFly()
    flyEnabled = false
    if flyConn then flyConn:Disconnect() flyConn=nil end
    if gyro then gyro:Destroy() gyro=nil end
    if velo then velo:Destroy() velo=nil end
    notify("Fly disabled")
end

local function startFly()
    local char, hrp = getCharHRP()
    -- Clean any leftovers
    stopFly()

    flyEnabled = true
    gyro = Instance.new("BodyGyro")
    gyro.P = 9e4
    gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    gyro.CFrame = workspace.CurrentCamera.CFrame
    gyro.Parent = hrp

    velo = Instance.new("BodyVelocity")
    velo.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    velo.Velocity = Vector3.zero
    velo.Parent = hrp

    flyConn = RS.RenderStepped:Connect(function()
        if not flyEnabled then return end
        local cam = workspace.CurrentCamera
        local cf = cam.CFrame

        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0,1,0) end

        if dir.Magnitude > 0 then
            velo.Velocity = dir.Unit * flySpeed
        else
            velo.Velocity = Vector3.zero
        end
        gyro.CFrame = cf
    end)
    notify("Fly enabled (WASD + Space / Shift)")
end

MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Nexten_Fly",
    Callback = function(on)
        if on then startFly() else stopFly() end
    end
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 250},
    Increment = 5,
    CurrentValue = 70,
    Flag = "Nexten_FlySpeed",
    Callback = function(v)
        flySpeed = v
    end
})

----------------------------------------------------------------
-- Teleports (smart finder + user-save fallback)
----------------------------------------------------------------
local function basepartFrom(inst)
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        if inst.PrimaryPart then return inst.PrimaryPart end
        local bp = inst:FindFirstChildWhichIsA("BasePart", true)
        if bp then return bp end
    end
    return nil
end

local function findTargets(keywords)
    local list, seen = {}, {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if (d:IsA("Model") or d:IsA("BasePart")) and d.Name then
            local lname = string.lower(d.Name)
            local hit = false
            for _, kw in ipairs(keywords) do
                if string.find(lname, kw) then hit = true break end
            end
            if hit then
                local bp = basepartFrom(d)
                if bp and not seen[bp] then
                    seen[bp] = true
                    table.insert(list, bp)
                end
            end
        end
    end
    -- Biggest parts first (usually the shop building/sign)
    table.sort(list, function(a,b)
        local sa = (a.Size.X + a.Size.Y + a.Size.Z)
        local sb = (b.Size.X + b.Size.Y + b.Size.Z)
        return sa > sb
    end)
    return list
end

local function tpToCFrame(cf)
    local _, hrp = getCharHRP()
    hrp.CFrame = cf + Vector3.new(0, 5, 0)
end

local function gotoGearShop()
    if STORE.SavedGear then tpToCFrame(STORE.SavedGear) return end
    local targets = findTargets({"gear","tool","shop","store"})
    if #targets > 0 then
        tpToCFrame(targets[1].CFrame)
        notify("Teleported to Gear Shop (auto-detected)")
    else
        notify("Gear Shop not found. Stand there and use 'Save Gear Shop Here'.")
    end
end

local function gotoPetShop()
    if STORE.SavedPet then tpToCFrame(STORE.SavedPet) return end
    local targets = findTargets({"pet","egg","hatch","shop","store"})
    if #targets > 0 then
        tpToCFrame(targets[1].CFrame)
        notify("Teleported to Pet Shop (auto-detected)")
    else
        notify("Pet Shop not found. Stand there and use 'Save Pet Shop Here'.")
    end
end

TeleportsTab:CreateButton({
    Name = "Go To Gear Shop",
    Callback = gotoGearShop
})
TeleportsTab:CreateButton({
    Name = "Go To Pet Shop",
    Callback = gotoPetShop
})

TeleportsTab:CreateButton({
    Name = "Save Gear Shop Here",
    Callback = function()
        local _, hrp = getCharHRP()
        STORE.SavedGear = hrp.CFrame
        notify("Saved current position as Gear Shop.")
    end
})
TeleportsTab:CreateButton({
    Name = "Save Pet Shop Here",
    Callback = function()
        local _, hrp = getCharHRP()
        STORE.SavedPet = hrp.CFrame
        notify("Saved current position as Pet Shop.")
    end
})

----------------------------------------------------------------
-- Pets (auto-discover + refresh + spawn-by-name)
----------------------------------------------------------------
local SpawnFolder = workspace:FindFirstChild("Nexten_SpawnedPets") or Instance.new("Folder", workspace)
SpawnFolder.Name = "Nexten_SpawnedPets"

local function ensurePrimary(model)
    if model.PrimaryPart then return end
    local root = model:FindFirstChild("HumanoidRootPart", true)
    if root and root:IsA("BasePart") then
        pcall(function() model.PrimaryPart = root end)
        return
    end
    local bp = model:FindFirstChildWhichIsA("BasePart", true)
    if bp then pcall(function() model.PrimaryPart = bp end) end
end

local function spawnModelTemplate(template)
    local _, hrp = getCharHRP()
    local clone = template:Clone()
    clone.Parent = SpawnFolder
    ensurePrimary(clone)
    if clone.PrimaryPart then
        clone:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5)))
    else
        local bp = clone:FindFirstChildWhichIsA("BasePart", true)
        if bp then
            local pos = hrp.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
            bp.CFrame = CFrame.new(pos)
        end
    end
end

local function collectPetTemplates()
    local containers = {
        Rep,
        Rep:FindFirstChild("Assets"),
        Rep:FindFirstChild("Pets"),
        workspace:FindFirstChild("Pets"),
        workspace:FindFirstChild("PetModels"),
        Rep:FindFirstChild("Models"),
        Rep:FindFirstChild("Shared"),
    }
    local results, added = {}, {}

    local function consider(inst)
        if inst and inst:IsA("Model") then
            -- Accept if model name has "pet" OR any ancestor named pet/egg
            local ok = false
            local cur = inst
            while cur do
                if cur.Name and string.find(string.lower(cur.Name), "pet") then ok = true break end
                if cur.Name and string.find(string.lower(cur.Name), "egg") then ok = true break end
                cur = cur.Parent
            end
            if ok and inst:FindFirstChildWhichIsA("BasePart", true) and not added[inst] then
                added[inst] = true
                table.insert(results, inst)
            end
        end
    end

    -- Search common containers first
    for _, c in ipairs(containers) do
        if c then
            for _, d in ipairs(c:GetDescendants()) do
                consider(d)
            end
        end
    end
    -- As a fallback, scan ReplicatedStorage fully
    for _, d in ipairs(Rep:GetDescendants()) do
        consider(d)
    end
    -- Deduplicate by name (keep first)
    local byName, unique = {}, {}
    for _, m in ipairs(results) do
        if not byName[m.Name] then
            byName[m.Name] = true
            table.insert(unique, m)
        end
    end
    table.sort(unique, function(a,b) return a.Name < b.Name end)
    return unique
end

local PetSection = PetsTab:CreateSection("Pet Spawner (Auto)")
local function buildPetButtons()
    -- Rayfield doesn’t expose a destroy-all, so we simply add on refresh with no duplicates via our table.
    local templates = collectPetTemplates()
    if #templates == 0 then
        notify("No pet models found. Try 'Spawn By Exact Name' or join a different area.")
    end
    for _, model in ipairs(templates) do
        PetsTab:CreateButton({
            Name = "Spawn "..model.Name,
            Callback = function()
                spawnModelTemplate(model)
            end
        })
    end
    notify("Loaded "..tostring(#templates).." pets.")
end

PetsTab:CreateButton({
    Name = "Refresh Pets",
    Callback = buildPetButtons
})

PetsTab:CreateInput({
    Name = "Spawn By Exact Name",
    PlaceholderText = "Type exact model name (e.g. Dragon)",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        text = tostring(text or ""):gsub("^%s+",""):gsub("%s+$","")
        if text == "" then return end
        -- search by exact name in ReplicatedStorage
        local found = {}
        for _, d in ipairs(Rep:GetDescendants()) do
            if d:IsA("Model") and d.Name == text then
                table.insert(found, d)
            end
        end
        if #found > 0 then
            spawnModelTemplate(found[1])
            notify("Spawned "..text)
        else
            notify("No model named '"..text.."' found in ReplicatedStorage.")
        end
    end
})

PetsTab:CreateButton({
    Name = "Clear Spawned Pets",
    Callback = function()
        for _, v in ipairs(SpawnFolder:GetChildren()) do
            v:Destroy()
        end
        notify("Cleared spawned pets.")
    end
})

-- Auto-build once
buildPetButtons()

-- Safety: stop fly if character resets
LP.CharacterAdded:Connect(function()
    if flyEnabled then
        task.wait(0.3)
        startFly()
    end
end)
