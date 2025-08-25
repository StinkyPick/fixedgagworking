-- Grow A Garden | Nexten Hub (Full Script with Key System)
-- Rayfield GUI | Delta Executor | By Nexten

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Key System
getgenv().NextenKeySystem = getgenv().NextenKeySystem or {}
local keyValidated = getgenv().NextenKeySystem.validated

local correctKey = "food"

local function showKeyGUI()
    local KeyWindow = Rayfield:CreateWindow({
        Name = "Nexten Hub | Grow A Garden",
        LoadingTitle = "Nexten Script Hub",
        LoadingSubtitle = "Made By Your Friend Kai",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false }
    })

    KeyWindow:CreateInput({
        Name = "Enter Key",
        PlaceholderText = "Enter your key here",
        RemoveTextAfterFocusLost = false,
        Callback = function(txt)
            if txt == correctKey then
                getgenv().NextenKeySystem.validated = true
                keyValidated = true
                Rayfield:Notify({Title = "Success", Content = "Correct key! You can now use the script.", Duration = 5, Image = 4483362458})
                KeyWindow:Hide() -- hide key input GUI
                runMainScript()
            else
                Rayfield:Notify({Title = "Error", Content = "Incorrect key!", Duration = 5, Image = 4483362458})
            end
        end
    })
end

-- Main script function (all features)
function runMainScript()
    local Window = Rayfield:CreateWindow({
        Name = "Grow A Garden | Nexten Hub",
        LoadingTitle = "Nexten Hub",
        LoadingSubtitle = "Delta Executor",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false }
    })

    local MainTab = Window:CreateTab("Main", 4483362458)
    local TeleportsTab = Window:CreateTab("Teleports", 4483362458)

    ----------------------------------------------------------------
    -- Speed Boost
    ----------------------------------------------------------------
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

    LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        applySpeed()
    end)

    ----------------------------------------------------------------
    -- Teleports with Save Feature
    ----------------------------------------------------------------
    getgenv().NextenGrow = getgenv().NextenGrow or {}
    local STORE = getgenv().NextenGrow

    local function tpToObjectOrSaved(objName, savedName)
        local char = LP.Character or LP.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        if STORE[savedName] then
            hrp.CFrame = STORE[savedName]
            return
        end

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

    TeleportsTab:CreateButton({ Name = "Go To Gear Shop", Callback = function() tpToObjectOrSaved("GearShop", "GearShop") end })
    TeleportsTab:CreateButton({ Name = "Save Gear Shop Here", Callback = function() saveCurrentPosition("GearShop") end })
    TeleportsTab:CreateButton({ Name = "Go To Pet Egg Shop", Callback = function() tpToObjectOrSaved("PetShop", "PetShop") end })
    TeleportsTab:CreateButton({ Name = "Save Pet Egg Shop Here", Callback = function() saveCurrentPosition("PetShop") end })

    ----------------------------------------------------------------
    -- Touch Fling
    ----------------------------------------------------------------
    local touchFlingEnabled = false
    local flingPower = 1000

    MainTab:CreateToggle({
        Name = "Touch Fling {nw}",
        CurrentValue = false,
        Flag = "TouchFling",
        Callback = function(val)
            touchFlingEnabled = val
        end
    })

    local function setupTouchFling()
        local char = LP.Character or LP.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        hrp.Touched:Connect(function(hit)
            if not touchFlingEnabled then return end
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if player and player ~= LP then
                local targetHRP = hit.Parent:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(9e5, 9e5, 9e5)
                    bv.Velocity = (targetHRP.Position - hrp.Position).Unit * flingPower + Vector3.new(0, flingPower/2, 0)
                    bv.Parent = targetHRP
                    game:GetService("Debris"):AddItem(bv, 0.3)
                end
            end
        end)
    end

    LP.CharacterAdded:Connect(function()
        task.wait(1)
        setupTouchFling()
    end)

    setupTouchFling()
end

-- Run Key GUI or skip if already validated
if keyValidated then
    runMainScript()
else
    showKeyGUI()
end
