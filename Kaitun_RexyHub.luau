-- ============================================================
-- REXY HUB — KAITUN BF
-- Auto 1-2800 | God Human | CDK | Soul Guitar | Auto Berry
-- ============================================================

-- ── MELEE TRACKER (persists between sessions) ──────────────
local CheckMelee = {
    ["Black Leg"]      = { Have = false, Mastery = 0 },
    ["Electro"]        = { Have = false, Mastery = 0 },
    ["Fishman Karate"] = { Have = false, Mastery = 0 },
    ["Dragon Claw"]    = { Have = false, Mastery = 0 },
    ["Superhuman"]     = { Have = false, Mastery = 0 },
    ["Death Step"]     = { Have = false, Mastery = 0 },
    ["Sharkman Karate"]= { Have = false, Mastery = 0 },
    ["Electric Claw"]  = { Have = false, Mastery = 0 },
    ["Dragon Talon"]   = { Have = false, Mastery = 0 },
    ["Godhuman"]       = { Have = false, Mastery = 0 },
}

local FOLDER = "RexyHub Kaitun"
local FILE   = FOLDER .. "/Blox Fruits/.Melee-" .. game.Players.LocalPlayer.Name .. ".json"
local HS     = game:GetService("HttpService")

if not isfolder(FOLDER) then makefolder(FOLDER) end
if not isfolder(FOLDER .. "/Blox Fruits") then makefolder(FOLDER .. "/Blox Fruits") end
if not isfile(FILE) then
    writefile(FILE, HS:JSONEncode(CheckMelee))
else
    local ok, dec = pcall(function() return HS:JSONDecode(readfile(FILE)) end)
    if ok and dec then
        for k, v in pairs(dec) do
            if CheckMelee[k] then CheckMelee[k] = v end
        end
    end
end

function SaveDataMelee(style, field, value)
    if CheckMelee[style] then
        CheckMelee[style][field] = value
        pcall(function() writefile(FILE, HS:JSONEncode(CheckMelee)) end)
    end
end

-- ── SILENCE ERRORS / GUIDE HOOKS ───────────────────────────
pcall(function()
    hookfunction(require(game.ReplicatedStorage.Effect.Container.Death), function() end)
end)
pcall(function()
    hookfunction(require(game.ReplicatedStorage:WaitForChild("GuideModule")).ChangeDisplayedNPC, function() end)
end)
hookfunction(error, function() end)
hookfunction(warn,  function() end)

-- ── AUTO TEAM SELECT ───────────────────────────────────────
if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)") then
    if game.Players.LocalPlayer.PlayerGui["Main (minimal)"]:FindFirstChild("ChooseTeam") then
        repeat
            task.wait()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
        until game.Players.LocalPlayer.Team ~= nil and game:IsLoaded()
    end
end

-- ── WORLD DETECT ───────────────────────────────────────────
local World1, World2, World3
if     game.PlaceId == 2753915549 then World1 = true
elseif game.PlaceId == 4442272183 then World2 = true
elseif game.PlaceId == 7449423635 then World3 = true
end

-- ── GLOBAL STATE ───────────────────────────────────────────
local Mon, NameQuest, LevelQuest, NameMon, CFrameMon, CFrameQuest, PosMon
_G.SelectWP = "Melee"

-- ── STATUS LOG ─────────────────────────────────────────────
local StatusLabel
local function Status(msg)
    print("[RexyHub Kaitun] " .. tostring(msg))
    pcall(function()
        if StatusLabel then StatusLabel.Text = "Status: " .. tostring(msg) end
    end)
end

-- ── SERVICES ───────────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local Players         = game:GetService("Players")
local VirtualUser     = game:GetService("VirtualUser")
local VirtualInput    = game:GetService("VirtualInputManager")
local RS              = game:GetService("ReplicatedStorage")
local lp              = Players.LocalPlayer

-- ── HELPERS ────────────────────────────────────────────────
function GetBP(v)
    return lp.Backpack:FindFirstChild(v) or lp.Character:FindFirstChild(v)
end

function GetIn(Name)
    for _, v1 in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v1) == "table" then
            if v1.Name == Name
            or lp.Character:FindFirstChild(Name)
            or lp.Backpack:FindFirstChild(Name) then
                return true
            end
        end
    end
    return false
end

function GetWP(name)
    for _, v in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v) == "table" and v.Type == "Sword" then
            if v.Name == name
            or lp.Character:FindFirstChild(name)
            or lp.Backpack:FindFirstChild(name) then
                return true
            end
        end
    end
    return false
end

function GetM(Name)
    for _, tab in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(tab) == "table" and tab.Type == "Material" and tab.Name == Name then
            return tab.Count
        end
    end
    return 0
end

function GetFruits()
    local FruitLow = {}
    for _, v in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v) == "table" and v.Type == "Blox Fruit" and v.Value <= 900000 then
            table.insert(FruitLow, { Name = v.Name, Value = v.Value })
        end
    end
    return FruitLow
end

function IsAlive(model)
    local h = model and model:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

function SafeWaitForChild(parent, name)
    local ok, r = pcall(function() return parent:WaitForChild(name) end)
    return r
end

local Net            = SafeWaitForChild(SafeWaitForChild(RS, "Modules"), "Net")
local RegisterAttack = SafeWaitForChild(Net, "RE/RegisterAttack")
local RegisterHit    = SafeWaitForChild(Net, "RE/RegisterHit")

-- ── MOVEMENT (Bypass TP: TweenService for close, CFrame snap for far) ──
function Tween(Target)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (Target.Position - hrp.Position).Magnitude
    if dist <= 200 then
        hrp.CFrame = Target
    else
        local t = TweenService:Create(hrp, TweenInfo.new(dist / 300, Enum.EasingStyle.Linear), { CFrame = Target })
        t:Play()
        t.Completed:Wait()
    end
end

function StopTween()
    if _G.Tween then _G.Tween:Cancel() _G.Tween = nil end
end

function TP(p)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = p end
end

-- ── ATTACK ─────────────────────────────────────────────────
function EquipWeapon(name)
    if not name then return end
    local tool = lp.Backpack:FindFirstChild(name)
    if tool then lp.Character.Humanoid:EquipTool(tool) end
end

function weaponSc(weapon)
    for _, v in pairs(lp.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == weapon then
            EquipWeapon(v.Name)
            return
        end
    end
end

function ProcessEnemies(out, folder)
    local base
    for _, e in pairs(folder:GetChildren()) do
        local head = e:FindFirstChild("Head")
        if head and IsAlive(e) and e ~= lp.Character
        and lp:DistanceFromCharacter(head.Position) < 120 then
            table.insert(out, { e, head })
            base = head
        end
    end
    return base
end

function BladeHit(base, enemies)
    RegisterAttack:FireServer(0)
    RegisterHit:FireServer(base, enemies)
end

function AttackNoCD()
    local out = {}
    local E = ProcessEnemies(out, workspace:WaitForChild("Enemies"))
    local S = ProcessEnemies(out, workspace:WaitForChild("SeaBeasts"))
    local C = ProcessEnemies(out, workspace:WaitForChild("Characters"))
    local equipped = lp.Character:FindFirstChildOfClass("Tool")
    if equipped and equipped:FindFirstChild("LeftClickRemote") then
        for _, ed in ipairs(out) do
            pcall(function()
                local dir = (ed[1].HumanoidRootPart.Position - lp.Character:GetPivot().Position).Unit
                equipped.LeftClickRemote:FireServer(dir, 1)
            end)
        end
    elseif #out > 0 then
        BladeHit(E or S or C, out)
    end
end

function BringEnemy(Name)
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == Name and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if (v.PrimaryPart.Position - PosMon).Magnitude <= 300 then
                v.PrimaryPart.CFrame = CFrame.new(PosMon)
                v.PrimaryPart.CanCollide = true
                v.Humanoid.WalkSpeed = 0
                v.Humanoid.JumpPower = 0
                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                lp.SimulationRadius = math.huge
            end
        end
    end
end

local Attack = {}
Attack.__index = Attack
function Attack.Alive(model)
    if not model then return end
    local h = model:FindFirstChild("Humanoid")
    return h and h.Health > 0
end
function Attack.Kill(model)
    if model then
        if not model:GetAttribute("Locked") then
            model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
        end
        PosMon = model:GetAttribute("Locked").Position
        BringEnemy(model.Name)
        weaponSc(_G.SelectWP)
        AttackNoCD()
        task.wait(0.2)
        Tween(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
        task.wait(0.2)
        Tween(model.HumanoidRootPart.CFrame * CFrame.new(25, 30, 0))
        task.wait(0.2)
        Tween(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, -25))
        task.wait(0.2)
        Tween(model.HumanoidRootPart.CFrame * CFrame.new(-25, 30, 0))
    end
end
function Attack.Kill2(model)
    if model then
        if workspace._WorldOrigin:FindFirstChild("Ring")
        or workspace._WorldOrigin:FindFirstChild("Fist")
        or workspace._WorldOrigin:FindFirstChild("MochiSwirl") then
            Tween(model.HumanoidRootPart.CFrame * CFrame.new(0, 90, 0))
        else
            if not model:GetAttribute("Locked") then
                model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
            end
            PosMon = model:GetAttribute("Locked").Position
            BringEnemy(model.Name)
            weaponSc(_G.SelectWP)
            AttackNoCD()
            task.wait(0.2)
            Tween(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
            task.wait(0.2)
            Tween(model.HumanoidRootPart.CFrame * CFrame.new(25, 30, 0))
            task.wait(0.2)
            Tween(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, -25))
            task.wait(0.2)
            Tween(model.HumanoidRootPart.CFrame * CFrame.new(-25, 30, 0))
        end
    end
end

function GetConnectionEnemies(a)
    for _, v in ipairs(RS:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if (typeof(a) == "table" and table.find(a, v.Name)) or v.Name == a then
                return v
            end
        end
    end
    for _, v in ipairs(workspace.Enemies:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if (typeof(a) == "table" and table.find(a, v.Name)) or v.Name == a then
                return v
            end
        end
    end
end

-- ── RAID ───────────────────────────────────────────────────
function RaidFunc()
    if not lp.PlayerGui.Main.TopHUDList.RaidTimer.Visible then
        if not GetBP("Special Microchip") then
            RS.Remotes.CommF_:InvokeServer("LoadFruit", GetFruits())
            RS.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", "Flame")
        end
        if GetBP("Special Microchip") then
            fireclickdetector(workspace.Map["CircleIsland"].RaidSummon2.Button.Main.ClickDetector)
        end
    else
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                repeat
                    task.wait()
                    Attack.Kill(v)
                until not v.Parent or v.Humanoid.Health <= 0
                for _, loc in ipairs({"Island 5","Island 4","Island 3","Island 2","Island 1"}) do
                    if workspace["_WorldOrigin"].Locations:FindFirstChild(loc) then
                        Tween(workspace["_WorldOrigin"].Locations[loc].CFrame * CFrame.new(0,50,100))
                        break
                    end
                end
            end
        end
    end
end

-- ── FPS BOOST ──────────────────────────────────────────────
function FPSBooster()
    local l = game.Lighting
    local t = workspace.Terrain
    t.WaterWaveSize = 0
    t.WaterWaveSpeed = 0
    t.WaterReflectance = 0
    t.WaterTransparency = 0
    l.GlobalShadows = false
    l.FogEnd = 9e9
    l.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    for _, e in pairs(l:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect")
        or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect")
        or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end
end
FPSBooster()

-- ── STORE FRUIT ────────────────────────────────────────────
function UpdStFruit()
    for _, x in pairs(lp.Backpack:GetChildren()) do
        local sf = x:FindFirstChild("EatRemote", true)
        if sf then
            RS.Remotes.CommF_:InvokeServer("StoreFruit",
                sf.Parent:GetAttribute("OriginalName"),
                lp.Backpack:FindFirstChild(x.Name))
        end
    end
end

-- ── AUTO COLLECT BERRIES ────────────────────────────────────
spawn(function()
    while task.wait(8) do
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Berry" and v:IsA("BasePart") then
                    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - v.Position).Magnitude < 2000 then
                        RS.Remotes.CommF_:InvokeServer("Pickup", v)
                    end
                end
            end
            -- Also collect from standard pickup remote
            RS.Remotes.CommF_:InvokeServer("CollectBerry")
        end)
    end
end)

-- ── CHECK LEVEL / QUEST ROUTING ────────────────────────────
function CheckLevel()
    local MyLevel = lp.Data.Level.Value
    if World1 then
        if MyLevel >= 1 and MyLevel <= 9 then
            if tostring(lp.Team) == "Marines" then
                Mon="Trainee" LevelQuest=1 NameQuest="MarineQuest" NameMon="Trainee"
                CFrameMon=CFrame.new(-2709.68,24.52,2104.25) CFrameQuest=CFrameMon
            else
                Mon="Bandit" LevelQuest=1 NameQuest="BanditQuest1" NameMon="Bandit"
                CFrameMon=CFrame.new(1045.96,27.0,1560.82) CFrameQuest=CFrameMon
            end
        elseif MyLevel >= 10 and MyLevel <= 14 then
            Mon="Monkey" LevelQuest=1 NameQuest="JungleQuest" NameMon="Monkey"
            CFrameQuest=CFrame.new(-1598.09,35.55,153.38) CFrameMon=CFrame.new(-1448.52,67.85,11.47)
        elseif MyLevel >= 15 and MyLevel <= 29 then
            Mon="Gorilla" LevelQuest=2 NameQuest="JungleQuest" NameMon="Gorilla"
            CFrameQuest=CFrame.new(-1598.09,35.55,153.38) CFrameMon=CFrame.new(-1129.88,40.46,-525.42)
        elseif MyLevel >= 30 and MyLevel <= 39 then
            Mon="Pirate" LevelQuest=1 NameQuest="BuggyQuest1" NameMon="Pirate"
            CFrameQuest=CFrame.new(-1141.07,4.1,3831.55) CFrameMon=CFrame.new(-1103.51,13.75,3896.09)
        elseif MyLevel >= 40 and MyLevel <= 59 then
            Mon="Brute" LevelQuest=2 NameQuest="BuggyQuest1" NameMon="Brute"
            CFrameQuest=CFrame.new(-1141.07,4.1,3831.55) CFrameMon=CFrame.new(-1140.08,14.81,4322.92)
        elseif MyLevel >= 60 and MyLevel <= 74 then
            Mon="Desert Bandit" LevelQuest=1 NameQuest="DesertQuest" NameMon="Desert Bandit"
            CFrameQuest=CFrame.new(894.49,5.14,4392.43) CFrameMon=CFrame.new(924.8,6.45,4481.59)
        elseif MyLevel >= 75 and MyLevel <= 89 then
            Mon="Desert Officer" LevelQuest=2 NameQuest="DesertQuest" NameMon="Desert Officer"
            CFrameQuest=CFrame.new(894.49,5.14,4392.43) CFrameMon=CFrame.new(1608.28,8.61,4371.01)
        elseif MyLevel >= 90 and MyLevel <= 99 then
            Mon="Snow Bandit" LevelQuest=1 NameQuest="SnowQuest" NameMon="Snow Bandit"
            CFrameQuest=CFrame.new(1389.74,88.15,-1298.91) CFrameMon=CFrame.new(1354.35,87.27,-1393.95)
        elseif MyLevel >= 100 and MyLevel <= 119 then
            Mon="Snowman" LevelQuest=2 NameQuest="SnowQuest" NameMon="Snowman"
            CFrameQuest=CFrame.new(1389.74,88.15,-1298.91) CFrameMon=CFrame.new(6241.99,51.52,-1243.98)
        elseif MyLevel >= 120 and MyLevel <= 149 then
            Mon="Chief Petty Officer" LevelQuest=1 NameQuest="MarineQuest2" NameMon="Chief Petty Officer"
            CFrameQuest=CFrame.new(-5039.59,27.35,4324.68) CFrameMon=CFrame.new(-4881.23,22.65,4273.75)
        elseif MyLevel >= 150 and MyLevel <= 174 then
            Mon="Sky Bandit" LevelQuest=1 NameQuest="SkyQuest" NameMon="Sky Bandit"
            CFrameQuest=CFrame.new(-4839.53,716.37,-2619.44) CFrameMon=CFrame.new(-4953.21,295.74,-2899.23)
        elseif MyLevel >= 175 and MyLevel <= 189 then
            Mon="Dark Master" LevelQuest=2 NameQuest="SkyQuest" NameMon="Dark Master"
            CFrameQuest=CFrame.new(-4839.53,716.37,-2619.44) CFrameMon=CFrame.new(-5259.84,391.40,-2229.04)
        elseif MyLevel >= 190 and MyLevel <= 209 then
            Mon="Prisoner" LevelQuest=1 NameQuest="PrisonerQuest" NameMon="Prisoner"
            CFrameQuest=CFrame.new(5308.93,1.66,475.12) CFrameMon=CFrame.new(5098.97,-0.32,474.24)
        elseif MyLevel >= 210 and MyLevel <= 249 then
            Mon="Dangerous Prisoner" LevelQuest=2 NameQuest="PrisonerQuest" NameMon="Dangerous Prisoner"
            CFrameQuest=CFrame.new(5308.93,1.66,475.12) CFrameMon=CFrame.new(5654.56,15.63,866.30)
        elseif MyLevel >= 250 and MyLevel <= 274 then
            Mon="Toga Warrior" LevelQuest=1 NameQuest="ColosseumQuest" NameMon="Toga Warrior"
            CFrameQuest=CFrame.new(-1580.05,6.35,-2986.48) CFrameMon=CFrame.new(-1820.21,51.68,-2740.67)
        elseif MyLevel >= 275 and MyLevel <= 299 then
            Mon="Gladiator" LevelQuest=2 NameQuest="ColosseumQuest" NameMon="Gladiator"
            CFrameQuest=CFrame.new(-1580.05,6.35,-2986.48) CFrameMon=CFrame.new(-1292.84,56.38,-3339.03)
        elseif MyLevel >= 300 and MyLevel <= 324 then
            Mon="Military Soldier" LevelQuest=1 NameQuest="MagmaQuest" NameMon="Military Soldier"
            CFrameQuest=CFrame.new(-5313.37,10.95,8515.29) CFrameMon=CFrame.new(-5411.16,11.08,8454.29)
        elseif MyLevel >= 325 and MyLevel <= 374 then
            Mon="Military Spy" LevelQuest=2 NameQuest="MagmaQuest" NameMon="Military Spy"
            CFrameQuest=CFrame.new(-5313.37,10.95,8515.29) CFrameMon=CFrame.new(-5802.87,86.26,8828.86)
        elseif MyLevel >= 375 and MyLevel <= 399 then
            Mon="Fishman Warrior" LevelQuest=1 NameQuest="FishmanQuest" NameMon="Fishman Warrior"
            CFrameQuest=CFrame.new(61122.65,18.50,1569.40) CFrameMon=CFrame.new(60878.30,18.48,1543.76)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>10000 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.85,11.68,1819.78))
            end
        elseif MyLevel >= 400 and MyLevel <= 449 then
            Mon="Fishman Commando" LevelQuest=2 NameQuest="FishmanQuest" NameMon="Fishman Commando"
            CFrameQuest=CFrame.new(61122.65,18.50,1569.40) CFrameMon=CFrame.new(61922.63,18.48,1493.93)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>10000 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.85,11.68,1819.78))
            end
        elseif MyLevel >= 450 and MyLevel <= 474 then
            Mon="God's Guard" LevelQuest=1 NameQuest="SkyExp1Quest" NameMon="God's Guard"
            CFrameQuest=CFrame.new(-4721.89,843.87,-1949.97) CFrameMon=CFrame.new(-4710.04,845.28,-1927.31)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>10000 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82,872.54,-1667.56))
            end
        elseif MyLevel >= 475 and MyLevel <= 524 then
            Mon="Shanda" LevelQuest=2 NameQuest="SkyExp1Quest" NameMon="Shanda"
            CFrameQuest=CFrame.new(-7859.10,5544.19,-381.48) CFrameMon=CFrame.new(-7678.49,5566.40,-497.22)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>10000 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894.62,5547.14,-380.29))
            end
        elseif MyLevel >= 525 and MyLevel <= 549 then
            Mon="Royal Squad" LevelQuest=1 NameQuest="SkyExp2Quest" NameMon="Royal Squad"
            CFrameQuest=CFrame.new(-7906.82,5634.66,-1411.99) CFrameMon=CFrame.new(-7624.25,5658.13,-1467.35)
        elseif MyLevel >= 550 and MyLevel <= 624 then
            Mon="Royal Soldier" LevelQuest=2 NameQuest="SkyExp2Quest" NameMon="Royal Soldier"
            CFrameQuest=CFrame.new(-7906.82,5634.66,-1411.99) CFrameMon=CFrame.new(-7836.75,5645.66,-1790.62)
        elseif MyLevel >= 625 and MyLevel <= 649 then
            Mon="Galley Pirate" LevelQuest=1 NameQuest="FountainQuest" NameMon="Galley Pirate"
            CFrameQuest=CFrame.new(5259.82,37.35,4050.03) CFrameMon=CFrame.new(5551.02,78.90,3930.41)
        elseif MyLevel >= 650 then
            Mon="Galley Captain" LevelQuest=2 NameQuest="FountainQuest" NameMon="Galley Captain"
            CFrameQuest=CFrame.new(5259.82,37.35,4050.03) CFrameMon=CFrame.new(5441.95,42.50,4950.09)
        end

    elseif World2 then
        if MyLevel >= 700 and MyLevel <= 724 then
            Mon="Raider" LevelQuest=1 NameQuest="Area1Quest" NameMon="Raider"
            CFrameQuest=CFrame.new(-429.54,71.77,1836.18) CFrameMon=CFrame.new(-728.33,52.78,2345.77)
        elseif MyLevel >= 725 and MyLevel <= 774 then
            Mon="Mercenary" LevelQuest=2 NameQuest="Area1Quest" NameMon="Mercenary"
            CFrameQuest=CFrame.new(-429.54,71.77,1836.18) CFrameMon=CFrame.new(-1004.32,80.16,1424.62)
        elseif MyLevel >= 775 and MyLevel <= 799 then
            Mon="Swan Pirate" LevelQuest=1 NameQuest="Area2Quest" NameMon="Swan Pirate"
            CFrameQuest=CFrame.new(638.44,71.77,918.28) CFrameMon=CFrame.new(1068.66,137.61,1322.11)
        elseif MyLevel >= 800 and MyLevel <= 874 then
            Mon="Factory Staff" LevelQuest=2 NameQuest="Area2Quest" NameMon="Factory Staff"
            CFrameQuest=CFrame.new(632.70,73.11,918.67) CFrameMon=CFrame.new(73.08,81.86,-27.47)
        elseif MyLevel >= 875 and MyLevel <= 899 then
            Mon="Marine Lieutenant" LevelQuest=1 NameQuest="MarineQuest3" NameMon="Marine Lieutenant"
            CFrameQuest=CFrame.new(-2440.80,71.71,-3216.07) CFrameMon=CFrame.new(-2821.37,75.90,-3070.09)
        elseif MyLevel >= 900 and MyLevel <= 949 then
            Mon="Marine Captain" LevelQuest=2 NameQuest="MarineQuest3" NameMon="Marine Captain"
            CFrameQuest=CFrame.new(-2440.80,71.71,-3216.07) CFrameMon=CFrame.new(-1861.23,80.18,-3254.70)
        elseif MyLevel >= 950 and MyLevel <= 974 then
            Mon="Zombie" LevelQuest=1 NameQuest="ZombieQuest" NameMon="Zombie"
            CFrameQuest=CFrame.new(-5497.06,47.59,-795.24) CFrameMon=CFrame.new(-5657.78,78.97,-928.69)
        elseif MyLevel >= 975 and MyLevel <= 999 then
            Mon="Vampire" LevelQuest=2 NameQuest="ZombieQuest" NameMon="Vampire"
            CFrameQuest=CFrame.new(-5497.06,47.59,-795.24) CFrameMon=CFrame.new(-6037.67,32.18,-1340.66)
        elseif MyLevel >= 1000 and MyLevel <= 1049 then
            Mon="Snow Trooper" LevelQuest=1 NameQuest="SnowMountainQuest" NameMon="Snow Trooper"
            CFrameQuest=CFrame.new(609.86,400.12,-5372.26) CFrameMon=CFrame.new(549.15,427.39,-5563.70)
        elseif MyLevel >= 1050 and MyLevel <= 1099 then
            Mon="Winter Warrior" LevelQuest=2 NameQuest="SnowMountainQuest" NameMon="Winter Warrior"
            CFrameQuest=CFrame.new(609.86,400.12,-5372.26) CFrameMon=CFrame.new(1142.75,475.64,-5199.42)
        elseif MyLevel >= 1100 and MyLevel <= 1124 then
            Mon="Lab Subordinate" LevelQuest=1 NameQuest="IceSideQuest" NameMon="Lab Subordinate"
            CFrameQuest=CFrame.new(-6064.07,15.24,-4902.98) CFrameMon=CFrame.new(-5707.47,15.95,-4513.39)
        elseif MyLevel >= 1125 and MyLevel <= 1174 then
            Mon="Horned Warrior" LevelQuest=2 NameQuest="IceSideQuest" NameMon="Horned Warrior"
            CFrameQuest=CFrame.new(-6064.07,15.24,-4902.98) CFrameMon=CFrame.new(-6341.37,15.95,-5723.16)
        elseif MyLevel >= 1175 and MyLevel <= 1199 then
            Mon="Magma Ninja" LevelQuest=1 NameQuest="FireSideQuest" NameMon="Magma Ninja"
            CFrameQuest=CFrame.new(-5428.03,15.06,-5299.43) CFrameMon=CFrame.new(-5449.67,76.66,-5808.20)
        elseif MyLevel >= 1200 and MyLevel <= 1249 then
            Mon="Lava Pirate" LevelQuest=2 NameQuest="FireSideQuest" NameMon="Lava Pirate"
            CFrameQuest=CFrame.new(-5428.03,15.06,-5299.43) CFrameMon=CFrame.new(-5213.33,49.74,-4701.45)
        elseif MyLevel >= 1250 and MyLevel <= 1274 then
            Mon="Ship Deckhand" LevelQuest=1 NameQuest="ShipQuest1" NameMon="Ship Deckhand"
            CFrameQuest=CFrame.new(1037.80,125.09,32911.60) CFrameMon=CFrame.new(1212.01,150.79,33059.25)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>500 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21,126.98,32852.83))
            end
        elseif MyLevel >= 1275 and MyLevel <= 1299 then
            Mon="Ship Engineer" LevelQuest=2 NameQuest="ShipQuest1" NameMon="Ship Engineer"
            CFrameQuest=CFrame.new(1037.80,125.09,32911.60) CFrameMon=CFrame.new(919.48,43.54,32779.97)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>500 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21,126.98,32852.83))
            end
        elseif MyLevel >= 1300 and MyLevel <= 1324 then
            Mon="Ship Steward" LevelQuest=1 NameQuest="ShipQuest2" NameMon="Ship Steward"
            CFrameQuest=CFrame.new(968.81,125.09,33244.13) CFrameMon=CFrame.new(919.44,129.56,33436.04)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>500 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21,126.98,32852.83))
            end
        elseif MyLevel >= 1325 and MyLevel <= 1349 then
            Mon="Ship Officer" LevelQuest=2 NameQuest="ShipQuest2" NameMon="Ship Officer"
            CFrameQuest=CFrame.new(968.81,125.09,33244.13) CFrameMon=CFrame.new(1036.02,181.44,33315.73)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>500 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21,126.98,32852.83))
            end
        elseif MyLevel >= 1350 and MyLevel <= 1374 then
            Mon="Arctic Warrior" LevelQuest=1 NameQuest="FrostQuest" NameMon="Arctic Warrior"
            CFrameQuest=CFrame.new(5667.66,26.80,-6486.09) CFrameMon=CFrame.new(5966.25,62.97,-6179.38)
        elseif MyLevel >= 1375 and MyLevel <= 1424 then
            Mon="Snow Lurker" LevelQuest=2 NameQuest="FrostQuest" NameMon="Snow Lurker"
            CFrameQuest=CFrame.new(5667.66,26.80,-6486.09) CFrameMon=CFrame.new(5407.07,69.19,-6880.88)
        elseif MyLevel >= 1425 and MyLevel <= 1449 then
            Mon="Sea Soldier" LevelQuest=1 NameQuest="ForgottenQuest" NameMon="Sea Soldier"
            CFrameQuest=CFrame.new(-3054.44,235.54,-10142.82) CFrameMon=CFrame.new(-3028.22,64.67,-9775.43)
        elseif MyLevel >= 1450 then
            Mon="Water Fighter" LevelQuest=2 NameQuest="ForgottenQuest" NameMon="Water Fighter"
            CFrameQuest=CFrame.new(-3054.44,235.54,-10142.82) CFrameMon=CFrame.new(-3352.90,285.02,-10534.84)
        end

    elseif World3 then
        if MyLevel >= 1500 and MyLevel <= 1524 then
            Mon="Pirate Millionaire" LevelQuest=1 NameQuest="PiratePortQuest" NameMon="Pirate Millionaire"
            CFrameQuest=CFrame.new(-712.83,98.58,5711.95) CFrameMon=CFrameQuest
        elseif MyLevel >= 1525 and MyLevel <= 1574 then
            Mon="Pistol Billionaire" LevelQuest=2 NameQuest="PiratePortQuest" NameMon="Pistol Billionaire"
            CFrameQuest=CFrame.new(-723.43,147.43,5931.99) CFrameMon=CFrameQuest
        elseif MyLevel >= 1575 and MyLevel <= 1599 then
            Mon="Dragon Crew Warrior" LevelQuest=1 NameQuest="AmazonQuest" NameMon="Dragon Crew Warrior"
            CFrameQuest=CFrame.new(6779.03,111.17,-801.21) CFrameMon=CFrameQuest
        elseif MyLevel >= 1600 and MyLevel <= 1649 then
            Mon="Dragon Crew Archer" LevelQuest=2 NameQuest="AmazonQuest" NameMon="Dragon Crew Archer"
            CFrameQuest=CFrame.new(6779.03,111.17,-801.21) CFrameMon=CFrameQuest
        elseif MyLevel >= 1650 and MyLevel <= 1699 then
            Mon="Venomous Assailant" LevelQuest=2 NameQuest="VenomCrewQuest" NameMon="Venomous Assailant"
            CFrameQuest=CFrame.new(4697.59,1100.65,946.40) CFrameMon=CFrameQuest
        elseif MyLevel >= 1700 and MyLevel <= 1724 then
            Mon="Marine Commodore" LevelQuest=1 NameQuest="MarineTreeIsland" NameMon="Marine Commodore"
            CFrameQuest=CFrame.new(2180.54,27.82,-6741.55) CFrameMon=CFrame.new(2286.01,73.13,-7159.81)
        elseif MyLevel >= 1725 and MyLevel <= 1774 then
            Mon="Marine Rear Admiral" LevelQuest=2 NameQuest="MarineTreeIsland" NameMon="Marine Rear Admiral"
            CFrameQuest=CFrame.new(2179.99,28.73,-6740.06) CFrameMon=CFrame.new(3656.77,160.52,-7001.60)
        elseif MyLevel >= 1775 and MyLevel <= 1799 then
            Mon="Fishman Raider" LevelQuest=1 NameQuest="DeepForestIsland3" NameMon="Fishman Raider"
            CFrameQuest=CFrame.new(-10581.66,330.87,-8761.19) CFrameMon=CFrame.new(-10407.53,331.76,-8368.52)
        elseif MyLevel >= 1800 and MyLevel <= 1824 then
            Mon="Fishman Captain" LevelQuest=2 NameQuest="DeepForestIsland3" NameMon="Fishman Captain"
            CFrameQuest=CFrame.new(-10581.66,330.87,-8761.19) CFrameMon=CFrame.new(-10994.70,352.38,-9002.11)
        elseif MyLevel >= 1825 and MyLevel <= 1849 then
            Mon="Forest Pirate" LevelQuest=1 NameQuest="DeepForestIsland" NameMon="Forest Pirate"
            CFrameQuest=CFrame.new(-13234.04,331.49,-7625.40) CFrameMon=CFrame.new(-13274.48,332.38,-7769.58)
        elseif MyLevel >= 1850 and MyLevel <= 1899 then
            Mon="Mythological Pirate" LevelQuest=2 NameQuest="DeepForestIsland" NameMon="Mythological Pirate"
            CFrameQuest=CFrame.new(-13234.04,331.49,-7625.40) CFrameMon=CFrame.new(-13680.61,501.08,-6991.19)
        elseif MyLevel >= 1900 and MyLevel <= 1924 then
            Mon="Jungle Pirate" LevelQuest=1 NameQuest="DeepForestIsland2" NameMon="Jungle Pirate"
            CFrameQuest=CFrame.new(-12680.38,389.97,-9902.02) CFrameMon=CFrame.new(-12256.16,331.74,-10485.84)
        elseif MyLevel >= 1925 and MyLevel <= 1974 then
            Mon="Musketeer Pirate" LevelQuest=2 NameQuest="DeepForestIsland2" NameMon="Musketeer Pirate"
            CFrameQuest=CFrame.new(-12680.38,389.97,-9902.02) CFrameMon=CFrame.new(-13457.90,391.55,-9859.18)
        elseif MyLevel >= 1975 and MyLevel <= 1999 then
            Mon="Reborn Skeleton" LevelQuest=1 NameQuest="HauntedQuest1" NameMon="Reborn Skeleton"
            CFrameQuest=CFrame.new(-9479.22,141.22,5566.09) CFrameMon=CFrame.new(-8763.72,165.72,6159.86)
        elseif MyLevel >= 2000 and MyLevel <= 2024 then
            Mon="Living Zombie" LevelQuest=2 NameQuest="HauntedQuest1" NameMon="Living Zombie"
            CFrameQuest=CFrame.new(-9479.22,141.22,5566.09) CFrameMon=CFrame.new(-10144.13,138.63,5838.09)
        elseif MyLevel >= 2025 and MyLevel <= 2049 then
            Mon="Demonic Soul" LevelQuest=1 NameQuest="HauntedQuest2" NameMon="Demonic Soul"
            CFrameQuest=CFrame.new(-9516.99,172.02,6078.47) CFrameMon=CFrame.new(-9505.87,172.10,6158.99)
        elseif MyLevel >= 2050 and MyLevel <= 2074 then
            Mon="Posessed Mummy" LevelQuest=2 NameQuest="HauntedQuest2" NameMon="Posessed Mummy"
            CFrameQuest=CFrame.new(-9516.99,172.02,6078.47) CFrameMon=CFrame.new(-9582.02,6.25,6205.48)
        elseif MyLevel >= 2075 and MyLevel <= 2099 then
            Mon="Peanut Scout" LevelQuest=1 NameQuest="NutsIslandQuest" NameMon="Peanut Scout"
            CFrameQuest=CFrame.new(-2104.39,38.10,-10194.22) CFrameMon=CFrame.new(-2143.24,47.72,-10029.99)
        elseif MyLevel >= 2100 and MyLevel <= 2124 then
            Mon="Peanut President" LevelQuest=2 NameQuest="NutsIslandQuest" NameMon="Peanut President"
            CFrameQuest=CFrame.new(-2104.39,38.10,-10194.22) CFrameMon=CFrame.new(-1859.35,38.10,-10422.43)
        elseif MyLevel >= 2125 and MyLevel <= 2149 then
            Mon="Ice Cream Chef" LevelQuest=1 NameQuest="IceCreamIslandQuest" NameMon="Ice Cream Chef"
            CFrameQuest=CFrame.new(-820.65,65.82,-10965.80) CFrameMon=CFrame.new(-872.25,65.82,-10919.96)
        elseif MyLevel >= 2150 and MyLevel <= 2199 then
            Mon="Ice Cream Commander" LevelQuest=2 NameQuest="IceCreamIslandQuest" NameMon="Ice Cream Commander"
            CFrameQuest=CFrame.new(-820.65,65.82,-10965.80) CFrameMon=CFrame.new(-558.06,112.05,-11290.77)
        elseif MyLevel >= 2200 and MyLevel <= 2224 then
            Mon="Cookie Crafter" LevelQuest=1 NameQuest="CakeQuest1" NameMon="Cookie Crafter"
            CFrameQuest=CFrame.new(-2021.32,37.80,-12028.73) CFrameMon=CFrame.new(-2374.14,37.80,-12125.31)
        elseif MyLevel >= 2225 and MyLevel <= 2249 then
            Mon="Cake Guard" LevelQuest=2 NameQuest="CakeQuest1" NameMon="Cake Guard"
            CFrameQuest=CFrame.new(-2021.32,37.80,-12028.73) CFrameMon=CFrame.new(-1598.31,43.77,-12244.58)
        elseif MyLevel >= 2250 and MyLevel <= 2274 then
            Mon="Baking Staff" LevelQuest=1 NameQuest="CakeQuest2" NameMon="Baking Staff"
            CFrameQuest=CFrame.new(-1927.92,37.80,-12842.54) CFrameMon=CFrame.new(-1887.81,77.62,-12998.35)
        elseif MyLevel >= 2275 and MyLevel <= 2299 then
            Mon="Head Baker" LevelQuest=2 NameQuest="CakeQuest2" NameMon="Head Baker"
            CFrameQuest=CFrame.new(-1927.92,37.80,-12842.54) CFrameMon=CFrame.new(-2216.19,82.88,-12869.29)
        elseif MyLevel >= 2300 and MyLevel <= 2324 then
            Mon="Cocoa Warrior" LevelQuest=1 NameQuest="ChocQuest1" NameMon="Cocoa Warrior"
            CFrameQuest=CFrame.new(233.23,29.88,-12201.23) CFrameMon=CFrame.new(-21.55,80.57,-12352.39)
        elseif MyLevel >= 2325 and MyLevel <= 2349 then
            Mon="Chocolate Bar Battler" LevelQuest=2 NameQuest="ChocQuest1" NameMon="Chocolate Bar Battler"
            CFrameQuest=CFrame.new(233.23,29.88,-12201.23) CFrameMon=CFrame.new(582.59,77.19,-12463.16)
        elseif MyLevel >= 2350 and MyLevel <= 2374 then
            Mon="Sweet Thief" LevelQuest=1 NameQuest="ChocQuest2" NameMon="Sweet Thief"
            CFrameQuest=CFrame.new(150.51,30.69,-12774.50) CFrameMon=CFrame.new(165.19,76.06,-12600.84)
        elseif MyLevel >= 2375 and MyLevel <= 2399 then
            Mon="Candy Rebel" LevelQuest=2 NameQuest="ChocQuest2" NameMon="Candy Rebel"
            CFrameQuest=CFrame.new(150.51,30.69,-12774.50) CFrameMon=CFrame.new(134.87,77.25,-12876.55)
        elseif MyLevel >= 2400 and MyLevel <= 2449 then
            Mon="Candy Pirate" LevelQuest=1 NameQuest="CandyQuest1" NameMon="Candy Pirate"
            CFrameQuest=CFrame.new(-1150.04,20.38,-14446.33) CFrameMon=CFrame.new(-1310.50,26.02,-14562.40)
        elseif MyLevel >= 2450 and MyLevel <= 2474 then
            Mon="Isle Outlaw" LevelQuest=1 NameQuest="TikiQuest1" NameMon="Isle Outlaw"
            CFrameQuest=CFrame.new(-16548.82,55.61,-172.81) CFrameMon=CFrame.new(-16479.90,226.61,-300.31)
        elseif MyLevel >= 2475 and MyLevel <= 2499 then
            Mon="Island Boy" LevelQuest=2 NameQuest="TikiQuest1" NameMon="Island Boy"
            CFrameQuest=CFrame.new(-16548.82,55.61,-172.81) CFrameMon=CFrame.new(-16849.40,192.87,-150.79)
        elseif MyLevel >= 2500 and MyLevel <= 2524 then
            Mon="Sun-kissed Warrior" LevelQuest=1 NameQuest="TikiQuest2" NameMon="kissed Warrior"
            CFrameMon=CFrame.new(-16347,64,984) CFrameQuest=CFrame.new(-16538,55,1049)
        elseif MyLevel >= 2525 and MyLevel <= 2549 then
            Mon="Isle Champion" LevelQuest=2 NameQuest="TikiQuest2" NameMon="Isle Champion"
            CFrameQuest=CFrame.new(-16541.02,57.31,1051.46) CFrameMon=CFrame.new(-16602.10,130.39,1087.25)
        elseif MyLevel >= 2550 and MyLevel <= 2574 then
            Mon="Serpent Hunter" LevelQuest=1 NameQuest="TikiQuest3" NameMon="Serpent Hunter"
            CFrameQuest=CFrame.new(-16679.48,176.75,1474.40) CFrameMon=CFrameQuest
        elseif MyLevel >= 2575 and MyLevel <= 2599 then
            Mon="Skull Slayer" LevelQuest=2 NameQuest="TikiQuest3" NameMon="Skull Slayer"
            CFrameQuest=CFrame.new(-16759.59,71.28,1595.34) CFrameMon=CFrameQuest
        elseif MyLevel >= 2600 and MyLevel <= 2624 then
            Mon="Reef Bandit" LevelQuest=1 NameQuest="SubmergedQuest1" NameMon="Reef Bandit"
            CFrameQuest=CFrame.new(10882.26,-2086.32,10034.23) CFrameMon=CFrame.new(10736.62,-2087.84,9338.49)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.70,25.23,1373.66)) task.wait(2)
                RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
            end
        elseif MyLevel >= 2625 and MyLevel <= 2649 then
            Mon="Coral Pirate" LevelQuest=2 NameQuest="SubmergedQuest1" NameMon="Coral Pirate"
            CFrameQuest=CFrame.new(10882.26,-2086.32,10034.23) CFrameMon=CFrame.new(10965.10,-2158.88,9177.26)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.70,25.23,1373.66)) task.wait(2)
                RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
            end
        elseif MyLevel >= 2650 and MyLevel <= 2674 then
            Mon="Sea Chanter" LevelQuest=1 NameQuest="SubmergedQuest1" NameMon="Sea Chanter"
            CFrameQuest=CFrame.new(10882.26,-2086.32,10034.23) CFrameMon=CFrame.new(10621.03,-2087.84,10102.03)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.70,25.23,1373.66)) task.wait(2)
                RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
            end
        elseif MyLevel >= 2675 and MyLevel <= 2699 then
            Mon="Ocean Prophet" LevelQuest=2 NameQuest="SubmergedQuest2" NameMon="Ocean Prophet"
            CFrameQuest=CFrame.new(10612.38,-2087.84,10053.89) CFrameMon=CFrame.new(11056.14,-2001.67,10117.45)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.70,25.23,1373.66)) task.wait(2)
                RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
            end
        elseif MyLevel >= 2700 and MyLevel <= 2724 then
            Mon="High Disciple" LevelQuest=1 NameQuest="SubmergedQuest3" NameMon="High Disciple"
            CFrameQuest=CFrame.new(9640.09,-1992.45,9613.65) CFrameMon=CFrame.new(9750.42,-1966.94,9753.36)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.70,25.23,1373.66)) task.wait(2)
                RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
            end
        elseif MyLevel >= 2725 then
            Mon="Grand Devotee" LevelQuest=2 NameQuest="SubmergedQuest3" NameMon="Grand Devotee"
            CFrameQuest=CFrame.new(9640.09,-1992.45,9613.65) CFrameMon=CFrame.new(9611.71,-1993.47,9882.69)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.70,25.23,1373.66)) task.wait(2)
                RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
            end
        end
    end
end

-- ── FARM LEVEL ─────────────────────────────────────────────
function FarmLevelFunc()
    CheckLevel()
    if not Mon then return end
    local QuestTitle = lp.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
    if not string.find(QuestTitle, NameMon) then
        RS.Remotes.CommF_:InvokeServer("AbandonQuest")
    end
    if not lp.PlayerGui.Main.Quest.Visible then
        Tween(CFrameQuest)
        if (lp.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude <= 5 then
            RS.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
        end
    else
        -- NPC at 25% HP → equip Yama or Tushita for fast finish
        if workspace.Enemies:FindFirstChild(Mon) then
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == Mon and Attack.Alive(v) then
                    if string.find(QuestTitle, NameMon) then
                        local hpPct = v.Humanoid.Health / v.Humanoid.MaxHealth
                        if hpPct <= 0.25 then
                            if GetWP("Tushita") then weaponSc("Tushita")
                            elseif GetWP("Yama") then weaponSc("Yama") end
                        end
                        repeat
                            task.wait()
                            Attack.Kill(v)
                        until v.Humanoid.Health <= 0 or not v.Parent or not lp.PlayerGui.Main.Quest.Visible
                        Tween(CFrameMon)
                    else
                        RS.Remotes.CommF_:InvokeServer("AbandonQuest")
                    end
                end
            end
        else
            Tween(CFrameMon)
        end
    end
end

-- ── GET TUSHITA (Colosseum puzzle) ─────────────────────────
function GetTushita()
    Status("Getting Tushita")
    -- Step 1: farm 30 Conjured Cocoa at Haunted Castle area
    local function needCocoa()
        return GetM("Conjured Cocoa") < 30
    end
    if needCocoa() then
        Status("Farm Conjured Cocoa for Tushita")
        while needCocoa() do
            task.wait(0.1)
            pcall(FarmLevelFunc)
        end
    end
    -- Step 2: go to Colosseum stone and interact
    Status("Tushita: going to stone")
    Tween(CFrame.new(-1580.05,6.35,-2986.48))
    task.wait(1)
    pcall(function()
        fireclickdetector(workspace:FindFirstChild("TushitaStone", true))
    end)
    task.wait(2)
    -- Step 3: kill 10 Tohers / Colosseum enemies
    for _ = 1, 10 do
        local found = GetConnectionEnemies({"Toga Warrior","Gladiator"})
        if found then
            repeat task.wait() Attack.Kill(found) until not found.Parent or found.Humanoid.Health <= 0
        end
        task.wait(0.5)
    end
    Status("Tushita attempt done")
end

-- ── GET YAMA ───────────────────────────────────────────────
function GetYama()
    Status("Getting Yama — farming bones")
    -- Need 1000 bones, kill Reborn Skeleton / Living Zombie
    while GetM("Bone") < 1000 do
        task.wait(0.1)
        -- force the haunted quest area
        Mon="Reborn Skeleton" LevelQuest=1 NameQuest="HauntedQuest1" NameMon="Reborn Skeleton"
        CFrameQuest=CFrame.new(-9479.22,141.22,5566.09) CFrameMon=CFrame.new(-8763.72,165.72,6159.86)
        pcall(FarmLevelFunc)
    end
    Status("Yama: 1000 bones ready — buying from Death King")
    Tween(CFrame.new(-9534, 143, 5706))
    task.wait(2)
    pcall(function()
        RS.Remotes.CommF_:InvokeServer("BuyYama")
    end)
    task.wait(1)
end

-- ── CDK (Cursed Dual Katana) ───────────────────────────────
function GetCDK()
    -- Need Tushita + Yama both at 350 mastery, then combine
    Status("CDK: checking Tushita + Yama")
    if not GetWP("Tushita") then
        GetTushita()
    end
    if not GetWP("Yama") then
        GetYama()
    end
    -- Farm mastery on both to 350
    local function getTushitaMastery()
        for _, v in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
            if type(v)=="table" and v.Name=="Tushita" then return v.Level or 0 end
        end return 0
    end
    local function getYamaMastery()
        for _, v in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
            if type(v)=="table" and v.Name=="Yama" then return v.Level or 0 end
        end return 0
    end
    while getTushitaMastery() < 350 or getYamaMastery() < 350 do
        Status("CDK: farming Tushita/Yama mastery ("..getTushitaMastery().."/350, "..getYamaMastery().."/350)")
        weaponSc("Tushita")
        pcall(FarmLevelFunc)
        task.wait(0.5)
        weaponSc("Yama")
        pcall(FarmLevelFunc)
        task.wait(0.5)
    end
    Status("CDK: combining swords")
    Tween(CFrame.new(-9479.22,141.22,5566.09))
    task.wait(2)
    pcall(function()
        RS.Remotes.CommF_:InvokeServer("CombineSwords", "Tushita", "Yama")
    end)
    task.wait(1)
    Status("CDK: done!")
end

-- ── SOUL GUITAR ────────────────────────────────────────────
function GetSoulGuitar()
    Status("Soul Guitar: hunting Soul Reaper")
    while not GetIn("Soul Guitar") do
        task.wait(0.1)
        -- Soul Reaper spawns at Haunted Castle (World 3)
        CFrameMon = CFrame.new(-9495.68,453.59,5977.35)
        Tween(CFrameMon)
        local boss = GetConnectionEnemies("Soul Reaper")
        if boss then
            Status("Soul Guitar: killing Soul Reaper")
            repeat
                task.wait()
                Attack.Kill(boss)
            until not boss.Parent or boss.Humanoid.Health <= 0
            task.wait(2) -- wait for drop
            -- pick up the drop
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Soul Guitar" then
                    RS.Remotes.CommF_:InvokeServer("Pickup", v)
                end
            end
        else
            Status("Soul Guitar: waiting for Soul Reaper spawn...")
            task.wait(10)
        end
    end
    Status("Soul Guitar: obtained!")
end

-- ── GOD HUMAN unlock chain ─────────────────────────────────
-- God Human requires: Black Leg, Electro, Fishman Karate, Dragon Claw,
-- Superhuman, Death Step, Sharkman Karate, Electric Claw, Dragon Talon
-- all at 400 mastery, plus 5,000,000 Beli.

function UnlockGodHuman()
    Status("God Human: checking all melee styles")
    while not CheckMelee["Godhuman"]["Have"] do
        task.wait(0.5)
        pcall(function()
            -- Buy / unlock in order, farm beli/mastery as needed
            -- BLACK LEG
            if not CheckMelee["Black Leg"]["Have"] then
                if GetBP("Black Leg") then
                    SaveDataMelee("Black Leg","Have",true)
                elseif lp.Data.Beli.Value >= 150000 then
                    Status("Buying Black Leg")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Black Leg Teacher" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BuyBlackLeg")
                else Status("Farm beli for Black Leg") FarmLevelFunc() end
                return
            end
            -- ELECTRO
            if not CheckMelee["Electro"]["Have"] then
                if GetBP("Electro") then
                    SaveDataMelee("Electro","Have",true)
                elseif CheckMelee["Black Leg"]["Mastery"]>=400 and lp.Data.Beli.Value>=500000 then
                    Status("Buying Electro")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Mad Scientist" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BuyElectro")
                else Status("Farm for Electro") FarmLevelFunc() end
                return
            end
            -- FISHMAN KARATE
            if not CheckMelee["Fishman Karate"]["Have"] then
                if GetBP("Fishman Karate") then
                    SaveDataMelee("Fishman Karate","Have",true)
                elseif CheckMelee["Electro"]["Mastery"]>=400 and lp.Data.Beli.Value>=750000 then
                    Status("Buying Fishman Karate")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Water Kung-fu Teacher" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BuyFishmanKarate")
                else Status("Farm for Fishman Karate") FarmLevelFunc() end
                return
            end
            -- DRAGON CLAW
            if not CheckMelee["Dragon Claw"]["Have"] then
                if GetBP("Dragon Claw") then
                    SaveDataMelee("Dragon Claw","Have",true)
                elseif (World2 or World3) and CheckMelee["Fishman Karate"]["Mastery"]>=400
                    and lp.Data.Level.Value>=1100 and lp.Data.Fragments.Value>=1500 then
                    Status("Buying Dragon Claw")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Sabi" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BlackbeardReward","DragonClaw","2")
                elseif #GetFruits()>0 and lp.Data.Fragments.Value<1500 then
                    Status("Auto Raid for fragments") RaidFunc()
                else Status("Farm for Dragon Claw") FarmLevelFunc() end
                return
            end
            -- SUPERHUMAN
            if not CheckMelee["Superhuman"]["Have"] then
                if GetBP("Superhuman") then
                    SaveDataMelee("Superhuman","Have",true)
                elseif (World2 or World3) and CheckMelee["Dragon Claw"]["Mastery"]>=400
                    and lp.Data.Level.Value>=1100 and lp.Data.Beli.Value>=3000000 then
                    Status("Buying Superhuman")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Martial Arts Master" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BuySuperhuman","2")
                else Status("Farm for Superhuman") FarmLevelFunc() end
                return
            end
            -- DEATH STEP
            if not CheckMelee["Death Step"]["Have"] then
                if GetBP("Death Step") then
                    SaveDataMelee("Death Step","Have",true)
                elseif CheckMelee["Black Leg"]["Mastery"]>=400 and lp.Data.Beli.Value>=500000 then
                    Status("Buying Death Step")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Killing Dealer" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BuyDeathStep")
                else Status("Farm for Death Step") FarmLevelFunc() end
                return
            end
            -- SHARKMAN KARATE
            if not CheckMelee["Sharkman Karate"]["Have"] then
                if GetBP("Sharkman Karate") then
                    SaveDataMelee("Sharkman Karate","Have",true)
                elseif CheckMelee["Fishman Karate"]["Mastery"]>=400 and lp.Data.Fragments.Value>=5000 then
                    Status("Buying Sharkman Karate")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Longma" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BuySharkmanKarate")
                else Status("Farm for Sharkman Karate") RaidFunc() end
                return
            end
            -- ELECTRIC CLAW
            if not CheckMelee["Electric Claw"]["Have"] then
                if GetBP("Electric Claw") then
                    SaveDataMelee("Electric Claw","Have",true)
                elseif CheckMelee["Electro"]["Mastery"]>=400 and lp.Data.Fragments.Value>=3000 then
                    Status("Buying Electric Claw")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Previous Hero" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BuyElectricClaw")
                else Status("Farm for Electric Claw") RaidFunc() end
                return
            end
            -- DRAGON TALON
            if not CheckMelee["Dragon Talon"]["Have"] then
                if GetBP("Dragon Talon") then
                    SaveDataMelee("Dragon Talon","Have",true)
                elseif CheckMelee["Dragon Claw"]["Mastery"]>=400 and GetM("Bone")>=500 then
                    Status("Buying Dragon Talon")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Uzoth" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BuyDragonTalon")
                elseif GetM("Bone") < 500 then
                    Status("Farm 500 bones for Dragon Talon")
                    Mon="Reborn Skeleton" NameMon="Reborn Skeleton" LevelQuest=1 NameQuest="HauntedQuest1"
                    CFrameQuest=CFrame.new(-9479.22,141.22,5566.09) CFrameMon=CFrame.new(-8763.72,165.72,6159.86)
                    FarmLevelFunc()
                else Status("Farm for Dragon Talon") FarmLevelFunc() end
                return
            end
            -- All styles obtained — buy GOD HUMAN
            if not CheckMelee["Godhuman"]["Have"] then
                if GetBP("Godhuman") then
                    SaveDataMelee("Godhuman","Have",true)
                elseif lp.Data.Beli.Value >= 5000000 and lp.Data.Fragments.Value >= 5000 then
                    Status("BUYING GOD HUMAN!")
                    for _, v in pairs(RS.NPCs:GetChildren()) do
                        if v.Name == "Ancient Monk" then Tween(v.HumanoidRootPart.CFrame) end
                    end
                    RS.Remotes.CommF_:InvokeServer("BuyGodhuman")
                else
                    Status("Farm beli/fragments for God Human")
                    FarmLevelFunc()
                end
            end
        end)
    end
    Status("God Human: UNLOCKED!")
end

-- ── AUTO REJOIN ────────────────────────────────────────────
spawn(function()
    local TeleportService = game:GetService("TeleportService")
    lp.AncestryChanged:Connect(function(_, parent)
        if not parent then
            task.wait(3)
            pcall(function() TeleportService:Teleport(game.PlaceId) end)
        end
    end)
end)

-- ── NOCLIP / BUSO LOOP ─────────────────────────────────────
spawn(function()
    while task.wait() do
        pcall(function()
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp and not hrp:FindFirstChild("BodyClip") then
                local bc = Instance.new("BodyVelocity")
                bc.Name="BodyClip" bc.MaxForce=Vector3.new(1e5,1e5,1e5) bc.Velocity=Vector3.zero
                bc.Parent=hrp
            end
            for _, p in pairs(lp.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end)
    end
end)

spawn(function()
    while task.wait() do
        pcall(function()
            if not lp.Character:FindFirstChild("HasBuso") then
                RS.Remotes.CommF_:InvokeServer("Buso")
            end
        end)
    end
end)

-- ── ANTI-AFK ───────────────────────────────────────────────
lp.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait()
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ── MASTERY TRACKER LOOP ───────────────────────────────────
spawn(function()
    while task.wait(5) do
        pcall(function()
            for style, _ in pairs(CheckMelee) do
                if GetBP(style) and lp.Character:FindFirstChild(style) then
                    local lvl = lp.Character[style].Level and lp.Character[style].Level.Value
                    if lvl then
                        if not CheckMelee[style]["Have"] then SaveDataMelee(style,"Have",true) end
                        SaveDataMelee(style,"Mastery",lvl)
                    end
                end
            end
        end)
    end
end)

-- ── MAIN KAITUN LOOP ───────────────────────────────────────
spawn(function()
    while task.wait() do
        pcall(function()
            local lvl = lp.Data.Level.Value

            -- Kill Cake Prince / Dough King on sight (free fragments + XP)
            if workspace.Enemies:FindFirstChild("Cake Prince")
            or workspace.Enemies:FindFirstChild("Dough King") then
                local boss = GetConnectionEnemies({"Cake Prince","Dough King"})
                if boss then
                    repeat task.wait() Attack.Kill2(boss)
                    until not boss.Parent or boss.Humanoid.Health <= 0
                else
                    Tween(CFrame.new(-1943.68,251.51,-12337.88))
                end
            end

            -- PHASE 1: Level 1–700, Sea 1
            if lvl < 700 then
                Status("Farming Sea 1 — Lvl "..lvl)
                FarmLevelFunc()

            -- PHASE 2: 700–1100, unlock early melees + Sea 2 grind
            elseif lvl >= 700 and lvl < 1100 then
                Status("Sea 2 — Lvl "..lvl)
                FarmLevelFunc()

            -- PHASE 3: 1100–1500, unlock Dragon Claw + Superhuman + Sea 2 finish
            elseif lvl >= 1100 and lvl < 1500 then
                Status("Sea 2 late — unlocking melees — Lvl "..lvl)
                UnlockGodHuman()

            -- PHASE 4: 1500–2800, Sea 3 grind + unlock all melees + CDK + Soul Guitar
            elseif lvl >= 1500 then
                Status("Sea 3 — Lvl "..lvl)

                -- Unlock all melee styles → God Human
                if not CheckMelee["Godhuman"]["Have"] then
                    UnlockGodHuman()
                end

                -- Get CDK
                if not GetIn("Cursed Dual Katana") and CheckMelee["Godhuman"]["Have"] then
                    GetCDK()
                end

                -- Get Soul Guitar
                if not GetIn("Soul Guitar") then
                    GetSoulGuitar()
                end

                -- Swap to CDK when available
                if GetWP("Cursed Dual Katana") then
                    _G.SelectWP = "Cursed Dual Katana"
                elseif CheckMelee["Godhuman"]["Have"] then
                    _G.SelectWP = "Melee"
                end

                FarmLevelFunc()
            end
        end)
    end
end)

print("[RexyHub Kaitun] Script loaded! Auto-farming 1-2800, God Human, CDK, Soul Guitar enabled.")
