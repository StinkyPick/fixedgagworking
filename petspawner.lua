--// Grow A Garden Temporary Pets + Fly + Teleports
--// Rayfield GUI | Delta Executor | By Nexten

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Grow A Garden | Nexten Hub",
    LoadingTitle = "Nexten Script Hub",
    LoadingSubtitle = "Made By Your Friend Kai",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
local PetsTab = Window:CreateTab("Pets", 4483362458)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Fly
local flyEnabled = false
local flySpeed = 70
local flyConn, bv, bg

local function stopFly()
    flyEnabled = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

local function startFly()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    stopFly()
    flyEnabled = true

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    flyConn = RS.RenderStepped:Connect(function()
        if not flyEnabled then return end
        local dir = Vector3.zero
        local cam = Workspace.CurrentCamera
        local cf = cam.CFrame

        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

        bv.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        bg.CFrame = cf
    end)
end

MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(val)
        if val then startFly() else stopFly() end
    end
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 250},
    Increment = 5,
    CurrentValue = 70,
    Flag = "FlySpeed",
    Callback = function(val)
        flySpeed = val
    end
})

-- Teleports
local function tpToObject(objName)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local target = Workspace:FindFirstChild(objName, true)
    if target and target:IsA("BasePart") then
        hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)
    else
        warn(objName.." not found")
    end
end

TeleportsTab:CreateButton({
    Name = "Go To Gear Shop",
    Callback = function() tpToObject("GearShop") end
})

TeleportsTab:CreateButton({
    Name = "Go To Pet Egg Shop",
    Callback = function() tpToObject("PetShop") end
})

-- Pets (temporary, server-visible)
local SpawnFolder = Workspace:FindFirstChild("Nexten_Pets") or Instance.new("Folder", Workspace)
SpawnFolder.Name = "Nexten_Pets"

local function spawnTempPet(model)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local clone = model:Clone()
    clone.Parent = SpawnFolder
    if clone.PrimaryPart then
        clone:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(math.random(-5,5),0,math.random(-5,5)))
    else
        local bp = clone:FindFirstChildWhichIsA("BasePart", true)
        if bp then bp.CFrame = hrp.CFrame + Vector3.new(math.random(-5,5),0,math.random(-5,5)) end
    end
end

-- Auto-populate pets
local function getPets()
    local pets = {}
    for _, v in ipairs(ReplicatedStorage:GetChildren()) do
        if v:IsA("Model") and string.find(string.lower(v.Name), "pet") then
            table.insert(pets, v)
        end
    end
    return pets
end

for _, pet in ipairs(getPets()) do
    PetsTab:CreateButton({
        Name = "Spawn "..pet.Name,
        Callback = function()
            spawnTempPet(pet)
        end
    })
end

PetsTab:CreateButton({
    Name = "Clear All Spawned Pets",
    Callback = function()
        for _, v in ipairs(SpawnFolder:GetChildren()) do
            v:Destroy()
        end
    end
})
