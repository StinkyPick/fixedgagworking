-- Grow A Garden | Nexten Hub (Speed + Teleports + Save Shops)
-- Rayfield GUI | Delta Executor | By Nexten

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

-- Services
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Speed Boost
local defaultSpeed = 16
local desiredSpeed = defaultSpeed

local function applySpeed()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = desiredSpeed end
    end
end

MainTab:CreateSlider({
    Name = "Speed Boost",
    Range = {16, 150},
    Increment = 1,
    CurrentValue = 16,
    Flag = "SpeedBoost",
    Callback = function(val)
        desiredSpeed = val
        applySpeed()
    end
})

-- Ensure speed stays after respawn
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed()
end)

----------------------------------------------------------------
-- Teleports with Save Feature
----------------------------------------------------------------
getgenv().NextenGrow = getgenv().NextenGrow or {}
local STORE = getgenv().NextenGrow -- Persistent for current executor session

local function tpToObjectOrSaved(objName, savedName)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    -- If saved location exists, teleport there
    if STORE[savedName] then
        hrp.CFrame = STORE[savedName]
        return
    end

    -- Try to find object in workspace
    local target = Workspace:FindFirstChild(objName, true)
    if target and target:IsA("BasePart") then
        hrp.CFrame = target.CFrame + Vector3.new(0,5,0)
    else
        warn(objName.." not found")
    end
end

local function saveCurrentPosition(saveName)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    STORE[saveName] = hrp.CFrame
    print("Saved "..saveName.." position.")
end

-- Teleport buttons
TeleportsTab:CreateButton({
    Name = "Go To Gear Shop",
    Callback = function() tpToObjectOrSaved("GearShop", "GearShop") end
})

TeleportsTab:CreateButton({
    Name = "Go To Pet Egg Shop",
    Callback = function() tpToObjectOrSaved("PetShop", "PetShop") end
})

-- Save buttons
TeleportsTab:CreateButton({
    Name = "Save Gear Shop Here",
    Callback = function() saveCurrentPosition("GearShop") end
})

TeleportsTab:CreateButton({
    Name = "Save Pet Egg Shop Here",
    Callback = function() saveCurrentPosition("PetShop") end
})
