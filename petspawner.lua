-- Grow a Garden Utility GUI
-- Made for Delta Executor | Using Rayfield UI
-- by Nexten

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Grow A Garden | Nexten Hub",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "Delta Executor",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   }
})

-- Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
local PetsTab = Window:CreateTab("Pets", 4483362458)

------------------------------------------------------
-- Speed Boost + Fly
------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local speedEnabled = false
local flyEnabled = false

MainTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedBoost",
    Callback = function(Value)
        speedEnabled = Value
        if speedEnabled then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 50
        else
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end,
})

MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        flyEnabled = Value

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if flyEnabled then
            hum.PlatformStand = true
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp

            -- Movement handler
            local conn
            conn = game:GetService("RunService").Heartbeat:Connect(function()
                if not flyEnabled then conn:Disconnect() return end
                local moveDir = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += workspace.CurrentCamera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= workspace.CurrentCamera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= workspace.CurrentCamera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += workspace.CurrentCamera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
                bv.Velocity = moveDir * 50
            end)
        else
            hum.PlatformStand = false
            local bv = hrp:FindFirstChild("FlyVelocity")
            if bv then bv:Destroy() end
        end
    end,
})

------------------------------------------------------
-- Teleports
------------------------------------------------------
local function tpTo(pos)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(pos)
end

TeleportsTab:CreateButton({
    Name = "Go To Gear Shop",
    Callback = function()
        tpTo(Vector3.new(100, 5, -50)) -- replace coords with real Gear Shop location
    end,
})

TeleportsTab:CreateButton({
    Name = "Go To Pet Egg Shop",
    Callback = function()
        tpTo(Vector3.new(-25, 5, 120)) -- replace coords with real Pet Egg Shop location
    end,
})

------------------------------------------------------
-- Pet Spawner
------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local petFolder = ReplicatedStorage:FindFirstChild("Pets") or ReplicatedStorage

for _, v in ipairs(petFolder:GetChildren()) do
    if v:IsA("Model") or v:IsA("Folder") then
        PetsTab:CreateButton({
            Name = "Spawn " .. v.Name,
            Callback = function()
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")

                local clone = v:Clone()
                clone.Parent = workspace
                if clone.PrimaryPart then
                    clone:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(math.random(-5,5),0,math.random(-5,5)))
                elseif clone:FindFirstChildWhichIsA("BasePart") then
                    clone:MoveTo(hrp.Position + Vector3.new(math.random(-5,5),0,math.random(-5,5)))
                end
            end,
        })
    end
end
