--[[
    REXY HUB - KAITUN BF v4.0
    Auto 1-2800 | God Human | CDK | Soul Guitar
    Webhook | Fruit Sniper | Auto Stats | UI
    Based on: Kaitun_lua.txt (open source)
]]

-- ================================================================
-- CONFIG
-- ================================================================
if not getgenv().RexyHub then
getgenv().RexyHub = {
    Team = "Pirates",       -- "Pirates" or "Marines"
    FPS = 30,
    FpsBoost = true,
    BlackScreen = false,
    Farming = {
        DoubleQuest = true,
    },
    Get = {
        GodHuman = true,
        CDK = true,
        SoulGuitar = true,
    },
    FruitSniper = {
        Enabled = true,
        List = {
            "Kitsune-Kitsune","T-Rex-T-Rex","Leopard-Leopard","Dragon-Dragon",
            "Dough-Dough","Control-Control","Venom-Venom","Shadow-Shadow",
            "Spirit-Spirit","Tiger-Tiger","Gravity-Gravity","Mammoth-Mammoth",
            "Blizzard-Blizzard","Portal-Portal","Rumble-Rumble","Phoenix-Phoenix",
            "Pain-Pain","Sound-Sound","Spider-Spider","Buddha-Buddha",
            "Quake-Quake","Magma-Magma","Ghost-Ghost","Creation-Creation",
            "Rubber-Rubber","Light-Light","Diamond-Diamond","Dark-Dark",
            "Sand-Sand","Ice-Ice","Falcon-Falcon","Flame-Flame",
            "Spike-Spike","Smoke-Smoke","Bomb-Bomb","Spring-Spring",
            "Blade-Blade","Spin-Spin","Rocket-Rocket",
        },
    },
    Setup = {
        AutoSummonRipIndra   = true,
        AutoSummonDoughKing  = true,
        AutoSummonCakePrince = true,
        UnlockRaidDough      = true,
        AutoCollectBerry     = true,
        AutoWarriorHelmet    = true,
        AutoBartilo          = true,
    },
    Webhook = {
        Enabled = false,
        Url     = "YOUR_WEBHOOK_URL_HERE",
    },
}
end
local CFG = getgenv().RexyHub

-- ================================================================
-- SERVICES
-- ================================================================
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser     = game:GetService("VirtualUser")
local VirtualInput    = game:GetService("VirtualInputManager")
local HS              = game:GetService("HttpService")
local RS              = game:GetService("ReplicatedStorage")
local lp              = Players.LocalPlayer

-- ================================================================
-- GLOBALS
-- ================================================================
local World1, World2, World3 = false, false, false
if     game.PlaceId == 2753915549 then World1 = true
elseif game.PlaceId == 4442272183 then World2 = true
elseif game.PlaceId == 7449423635 then World3 = true end

local Mon, NameQuest, LevelQuest, NameMon, CFrameMon, CFrameQuest, PosMon
_G.SelectWP = "Melee"
local _Running = true

-- ================================================================
-- MELEE SAVE DATA (fixed: was CheckMelee.v1.v2 which is wrong)
-- ================================================================
local CheckMelee = {
    ["Black Leg"]      = {Have=false, Mastery=0},
    ["Electro"]        = {Have=false, Mastery=0},
    ["Fishman Karate"] = {Have=false, Mastery=0},
    ["Dragon Claw"]    = {Have=false, Mastery=0},
    ["Superhuman"]     = {Have=false, Mastery=0},
    ["Death Step"]     = {Have=false, Mastery=0},
    ["Sharkman Karate"]= {Have=false, Mastery=0},
    ["Electric Claw"]  = {Have=false, Mastery=0},
    ["Dragon Talon"]   = {Have=false, Mastery=0},
    ["Godhuman"]       = {Have=false, Mastery=0},
}

local FOLDER = "RexyHub Kaitun"
local MFILE  = FOLDER.."/Blox Fruits/.Melee-"..lp.Name..".json"
if not isfolder(FOLDER) then makefolder(FOLDER) end
if not isfolder(FOLDER.."/Blox Fruits") then makefolder(FOLDER.."/Blox Fruits") end
if not isfile(MFILE) then
    writefile(MFILE, HS:JSONEncode(CheckMelee))
else
    local ok, d = pcall(function() return HS:JSONDecode(readfile(MFILE)) end)
    if ok and d then for k,v in pairs(d) do if CheckMelee[k] then CheckMelee[k]=v end end end
end
function SaveDataMelee(style, field, value)
    -- BUG FIX: original used dot syntax on variables (CheckMelee.v1.v2) which is wrong
    if CheckMelee[style] then CheckMelee[style][field] = value end
    pcall(function() writefile(MFILE, HS:JSONEncode(CheckMelee)) end)
end

-- ================================================================
-- HOOKS
-- ================================================================
pcall(function() hookfunction(require(RS.Effect.Container.Death), function() end) end)
pcall(function() hookfunction(require(RS:WaitForChild("GuideModule")).ChangeDisplayedNPC, function() end) end)
hookfunction(error, function() end)
hookfunction(warn,  function() end)

-- ================================================================
-- AUTO TEAM
-- ================================================================
if lp.PlayerGui:FindFirstChild("Main (minimal)") then
    if lp.PlayerGui["Main (minimal)"]:FindFirstChild("ChooseTeam") then
        repeat task.wait()
            RS.Remotes.CommF_:InvokeServer("SetTeam", CFG.Team or "Pirates")
        until lp.Team ~= nil and game:IsLoaded()
    end
end

-- ================================================================
-- FPS BOOST
-- ================================================================
if CFG.FpsBoost then
    task.spawn(function()
        pcall(function()
            local l = game.Lighting
            local t = workspace.Terrain
            t.WaterWaveSize=0 t.WaterWaveSpeed=0 t.WaterReflectance=0 t.WaterTransparency=0
            l.GlobalShadows=false l.FogEnd=9e9 l.Brightness=0
            settings().Rendering.QualityLevel = "Level01"
            pcall(function() setfpscap(CFG.FPS or 30) end)
            for _,v in pairs(game:GetDescendants()) do
                if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                    v.Material="Plastic" v.Reflectance=0
                elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime=NumberRange.new(0)
                elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled=false
                elseif v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect")
                    or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled=false
                end
            end
        end)
    end)
end

-- ================================================================
-- UI
-- ================================================================
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("RexyHubKaitun") then CoreGui.RexyHubKaitun:Destroy() end
local Gui = Instance.new("ScreenGui")
Gui.Name="RexyHubKaitun" Gui.ResetOnSpawn=false Gui.DisplayOrder=999
pcall(function() Gui.Parent=CoreGui end)
if not Gui.Parent then Gui.Parent=lp.PlayerGui end

-- Toggle button (floating red R)
local TogFrame = Instance.new("Frame")
TogFrame.Size=UDim2.new(0,54,0,54) TogFrame.Position=UDim2.new(0,8,0.5,-27)
TogFrame.BackgroundColor3=Color3.fromRGB(10,5,5) TogFrame.BorderSizePixel=0
TogFrame.Active=true TogFrame.Draggable=true TogFrame.Parent=Gui
Instance.new("UICorner",TogFrame).CornerRadius=UDim.new(1,0)
local TS=Instance.new("UIStroke",TogFrame) TS.Color=Color3.fromRGB(200,20,20) TS.Thickness=2.5
local TogR=Instance.new("TextLabel")
TogR.Size=UDim2.new(1,0,1,0) TogR.BackgroundTransparency=1 TogR.Text="R"
TogR.TextColor3=Color3.fromRGB(210,20,20) TogR.Font=Enum.Font.GothamBold TogR.TextScaled=true TogR.Parent=TogFrame
local TogBtn=Instance.new("TextButton")
TogBtn.Size=UDim2.new(1,0,1,0) TogBtn.BackgroundTransparency=1 TogBtn.Text="" TogBtn.Parent=TogFrame

-- Main panel
local Panel=Instance.new("Frame")
Panel.Name="Panel" Panel.Size=UDim2.new(0,330,0,460)
Panel.Position=UDim2.new(0,72,0.5,-230)
Panel.BackgroundColor3=Color3.fromRGB(8,5,5) Panel.BorderSizePixel=0
Panel.Active=true Panel.Draggable=true Panel.Parent=Gui
Instance.new("UICorner",Panel).CornerRadius=UDim.new(0,10)
local PS=Instance.new("UIStroke",Panel) PS.Color=Color3.fromRGB(180,15,15) PS.Thickness=1.5

TogBtn.MouseButton1Click:Connect(function()
    Panel.Visible=not Panel.Visible
    TogR.TextColor3=Panel.Visible and Color3.fromRGB(210,20,20) or Color3.fromRGB(60,60,60)
end)

-- Title bar
local TBar=Instance.new("Frame")
TBar.Size=UDim2.new(1,0,0,46) TBar.BackgroundColor3=Color3.fromRGB(14,6,6)
TBar.BorderSizePixel=0 TBar.Parent=Panel
Instance.new("UICorner",TBar).CornerRadius=UDim.new(0,10)
local BigR=Instance.new("TextLabel")
BigR.Size=UDim2.new(0,46,0,46) BigR.BackgroundTransparency=1 BigR.Text="R"
BigR.TextColor3=Color3.fromRGB(210,20,20) BigR.Font=Enum.Font.GothamBold BigR.TextScaled=true BigR.Parent=TBar
local TitleLbl=Instance.new("TextLabel")
TitleLbl.Size=UDim2.new(1,-110,1,0) TitleLbl.Position=UDim2.new(0,50,0,0)
TitleLbl.BackgroundTransparency=1 TitleLbl.Text="REXY HUB — KAITUN"
TitleLbl.TextColor3=Color3.fromRGB(230,220,220) TitleLbl.Font=Enum.Font.GothamBold
TitleLbl.TextScaled=true TitleLbl.TextXAlignment=Enum.TextXAlignment.Left TitleLbl.Parent=TBar
local CloseX=Instance.new("TextButton")
CloseX.Size=UDim2.new(0,26,0,26) CloseX.Position=UDim2.new(1,-30,0,10)
CloseX.BackgroundColor3=Color3.fromRGB(160,15,15) CloseX.Text="X"
CloseX.TextColor3=Color3.white CloseX.Font=Enum.Font.GothamBold CloseX.TextSize=12
CloseX.BorderSizePixel=0 CloseX.Parent=TBar
Instance.new("UICorner",CloseX).CornerRadius=UDim.new(0,5)
CloseX.MouseButton1Click:Connect(function() Panel.Visible=false TogR.TextColor3=Color3.fromRGB(60,60,60) end)

-- Stat boxes
local function mkStatBox(x,col)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(0,96,0,26) f.Position=UDim2.new(0,x,0,52)
    f.BackgroundColor3=Color3.fromRGB(20,10,10) f.BorderSizePixel=0 f.Parent=Panel
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
    local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
    l.Text="—" l.TextColor3=col l.Font=Enum.Font.GothamBold l.TextScaled=true l.Parent=f
    return l
end
local LvlLbl  = mkStatBox(6,   Color3.fromRGB(255,80,80))
local BeliLbl = mkStatBox(108, Color3.fromRGB(255,210,50))
local FragLbl = mkStatBox(210, Color3.fromRGB(160,90,255))

-- Status/Goal/Sub bars
local function mkBar(y,h,col,sc)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,-12,0,h) f.Position=UDim2.new(0,6,0,y)
    f.BackgroundColor3=col f.BorderSizePixel=0 f.Parent=Panel
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    if sc then local s=Instance.new("UIStroke",f) s.Color=sc s.Thickness=1 end
    local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-6,1,0) l.Position=UDim2.new(0,3,0,0)
    l.BackgroundTransparency=1 l.Font=Enum.Font.Gotham l.TextScaled=true
    l.TextXAlignment=Enum.TextXAlignment.Left l.TextColor3=Color3.fromRGB(220,200,200) l.Parent=f
    return l
end
local StatusLbl = mkBar(84,  28, Color3.fromRGB(18,8,8),   Color3.fromRGB(140,20,20))
local GoalLbl   = mkBar(118, 22, Color3.fromRGB(10,16,10), Color3.fromRGB(25,100,25))
local SubLbl    = mkBar(146, 18, Color3.fromRGB(10,10,20), Color3.fromRGB(25,50,110))
StatusLbl.Text="Status: Starting..." StatusLbl.TextColor3=Color3.fromRGB(255,150,150)
GoalLbl.Text="Goal: —" GoalLbl.TextColor3=Color3.fromRGB(80,220,80)
SubLbl.Text="SubTask: —" SubLbl.TextColor3=Color3.fromRGB(130,170,255)

-- Mastery scroll
local MScr=Instance.new("ScrollingFrame")
MScr.Size=UDim2.new(1,-12,0,180) MScr.Position=UDim2.new(0,6,0,170)
MScr.BackgroundColor3=Color3.fromRGB(12,7,7) MScr.BorderSizePixel=0
MScr.ScrollBarThickness=3 MScr.ScrollBarImageColor3=Color3.fromRGB(180,20,20)
MScr.CanvasSize=UDim2.new(0,0,0,0) MScr.Parent=Panel
Instance.new("UICorner",MScr).CornerRadius=UDim.new(0,5)
Instance.new("UIListLayout",MScr).Padding=UDim.new(0,2)

local MBars={}
local MELEE_LIST={"Black Leg","Electro","Fishman Karate","Dragon Claw","Superhuman",
    "Death Step","Sharkman Karate","Electric Claw","Dragon Talon","Godhuman"}
local MELEE_REQ={["Black Leg"]=400,["Electro"]=400,["Fishman Karate"]=400,
    ["Dragon Claw"]=400,["Superhuman"]=400,["Death Step"]=400,
    ["Sharkman Karate"]=400,["Electric Claw"]=400,["Dragon Talon"]=400,["Godhuman"]=1}
for _,s in ipairs(MELEE_LIST) do
    local row=Instance.new("Frame") row.Size=UDim2.new(1,-4,0,15) row.BackgroundTransparency=1 row.Parent=MScr
    local nm=Instance.new("TextLabel") nm.Size=UDim2.new(0,108,1,0) nm.BackgroundTransparency=1
    nm.Text=s nm.TextColor3=Color3.fromRGB(175,155,155) nm.Font=Enum.Font.Gotham nm.TextSize=9
    nm.TextXAlignment=Enum.TextXAlignment.Left nm.Parent=row
    local bg=Instance.new("Frame") bg.Size=UDim2.new(1,-114,1,-3) bg.Position=UDim2.new(0,110,0,1)
    bg.BackgroundColor3=Color3.fromRGB(28,12,12) bg.BorderSizePixel=0 bg.Parent=row
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,3)
    local fill=Instance.new("Frame") fill.Size=UDim2.new(0,0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(190,20,20) fill.BorderSizePixel=0 fill.Parent=bg
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,3)
    local pct=Instance.new("TextLabel") pct.Size=UDim2.new(1,0,1,0) pct.BackgroundTransparency=1
    pct.Text="0/400" pct.TextColor3=Color3.white pct.Font=Enum.Font.Gotham pct.TextSize=8
    pct.TextXAlignment=Enum.TextXAlignment.Right pct.Parent=bg
    MBars[s]={fill=fill,pct=pct,nm=nm}
end

-- Time + buttons
local TimeLbl=mkBar(356,20,Color3.fromRGB(12,8,8),nil)
TimeLbl.Text="Time: 0d 0h 0m" TimeLbl.TextColor3=Color3.fromRGB(130,110,110)
local BRow=Instance.new("Frame") BRow.Size=UDim2.new(1,-12,0,28) BRow.Position=UDim2.new(0,6,0,382)
BRow.BackgroundTransparency=1 BRow.Parent=Panel
local function mkBtn(txt,x,c)
    local b=Instance.new("TextButton") b.Size=UDim2.new(0.48,0,1,0) b.Position=UDim2.new(x,0,0,0)
    b.BackgroundColor3=c b.Text=txt b.TextColor3=Color3.white b.Font=Enum.Font.GothamBold
    b.TextSize=11 b.BorderSizePixel=0 b.Parent=BRow Instance.new("UICorner",b).CornerRadius=UDim.new(0,5) return b
end
local HopBtn  = mkBtn("Server Hop",0,   Color3.fromRGB(80,15,15))
local StopBtn = mkBtn("STOP",      0.52,Color3.fromRGB(50,8,8))
local VerLbl=Instance.new("TextLabel") VerLbl.Size=UDim2.new(1,0,0,16) VerLbl.Position=UDim2.new(0,0,1,-16)
VerLbl.BackgroundTransparency=1 VerLbl.Text="Rexy Hub Kaitun v4.0"
VerLbl.TextColor3=Color3.fromRGB(70,35,35) VerLbl.Font=Enum.Font.Gotham VerLbl.TextSize=10
VerLbl.TextXAlignment=Enum.TextXAlignment.Center VerLbl.Parent=Panel

local StartTime = tick()
local function SetStatus(msg)
    print("[RexyHub] "..tostring(msg))
    pcall(function() StatusLbl.Text="Status: "..tostring(msg) end)
end
local function SetGoal(msg)
    pcall(function() GoalLbl.Text="Goal: "..tostring(msg) end)
end
local function SetSub(msg)
    pcall(function() SubLbl.Text="SubTask: "..tostring(msg) end)
end

-- UI update loop
task.spawn(function()
    while _Running do task.wait(0.5)
        pcall(function()
            local lv=lp.Data.Level.Value
            local bl=lp.Data.Beli.Value
            local fr=lp.Data.Fragments.Value
            LvlLbl.Text="Lv."..lv
            if bl>=1e6 then BeliLbl.Text=string.format("$%.1fM",bl/1e6)
            elseif bl>=1000 then BeliLbl.Text=string.format("$%.0fK",bl/1000)
            else BeliLbl.Text="$"..bl end
            FragLbl.Text="F:"..fr
            local e=tick()-StartTime
            TimeLbl.Text=string.format("Time: %dd %dh %dm",
                math.floor(e/86400),math.floor(e%86400/3600),math.floor(e%3600/60))
            for sty,bar in pairs(MBars) do
                local mas=CheckMelee[sty] and CheckMelee[sty]["Mastery"] or 0
                local req=MELEE_REQ[sty] or 400
                local hv=CheckMelee[sty] and CheckMelee[sty]["Have"]
                bar.fill.Size=UDim2.new(math.min(mas/req,1),0,1,0)
                bar.fill.BackgroundColor3=hv and Color3.fromRGB(30,200,30) or Color3.fromRGB(190,20,20)
                bar.pct.Text=mas.."/"..req
                bar.nm.TextColor3=hv and Color3.fromRGB(60,250,60) or Color3.fromRGB(175,155,155)
            end
            MScr.CanvasSize=UDim2.new(0,0,0,#MELEE_LIST*17)
        end)
    end
end)
StopBtn.MouseButton1Click:Connect(function() _Running=false SetStatus("STOPPED") end)

-- ================================================================
-- HELPERS (from original Kaitun_lua.txt - unchanged)
-- ================================================================
function GetBP(v)
    return lp.Backpack:FindFirstChild(v) or lp.Character:FindFirstChild(v)
end
function GetIn(Name)
    for _,v1 in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v1)=="table" then
            if v1.Name==Name or lp.Character:FindFirstChild(Name) or lp.Backpack:FindFirstChild(Name) then
                return true end
        end
    end return false
end
function GetM(Name)
    for _,tab in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(tab)=="table" and tab.Type=="Material" and tab.Name==Name then return tab.Count end
    end return 0
end
function GetWP(nametool)
    for _,v4 in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v4)=="table" and v4.Type=="Sword" then
            if v4.Name==nametool or lp.Character:FindFirstChild(nametool) or lp.Backpack:FindFirstChild(nametool) then
                return true end
        end
    end return false
end
function GetFruits()
    local FruitLow={}
    for _,v in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v)=="table" and v.Type=="Blox Fruit" and v.Value<=900000 then
            table.insert(FruitLow,{Name=v.Name,Value=v.Value}) end
    end return FruitLow
end
function IsAlive(character)
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health>0
end
function SafeWaitForChild(parent, childName)
    local ok,r = pcall(function() return parent:WaitForChild(childName) end)
    return r
end
Net=SafeWaitForChild(SafeWaitForChild(RS,"Modules"),"Net")
RegisterAttack=SafeWaitForChild(Net,"RE/RegisterAttack")
RegisterHit=SafeWaitForChild(Net,"RE/RegisterHit")

-- ================================================================
-- MOVEMENT (original Tween + TP, speed set to 350)
-- ================================================================
function Tween(Target)
    if not Target then return end
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local Distance=(Target.Position-hrp.Position).Magnitude
    local Info=TweenInfo.new(Distance/350, Enum.EasingStyle.Linear)
    if _G.Tween then _G.Tween:Cancel() end
    _G.Tween=TweenService:Create(hrp,Info,{CFrame=Target})
    _G.Tween:Play()
    if Distance<=200 then hrp.CFrame=Target end
end
function TP(p)
    lp.Character.HumanoidRootPart.CFrame=p
end

-- ================================================================
-- ATTACK (original AttackNoCD + BringEnemy + Attack.Kill)
-- BringEnemy fixed: brings mob to player center not offset corners
-- ================================================================
function EquipWeapon(text)
    if not text then return end
    if lp.Backpack:FindFirstChild(text) then
        lp.Character.Humanoid:EquipTool(lp.Backpack:FindFirstChild(text))
    end
end
function weaponSc(weapon)
    for _,v in pairs(lp.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip==weapon then EquipWeapon(v.Name) end
    end
end
function ProcessEnemies(OthersEnemies, Folder)
    local BasePart=nil
    for _,Enemy in pairs(Folder:GetChildren()) do
        local Head=Enemy:FindFirstChild("Head")
        if Head and IsAlive(Enemy) and lp:DistanceFromCharacter(Head.Position)<160 then
            if Enemy~=lp.Character then
                table.insert(OthersEnemies,{Enemy,Head})
                BasePart=Head
            end
        end
    end return BasePart
end
function AttackNoCD()
    local OthersEnemies={}
    Enemies=ProcessEnemies(OthersEnemies,workspace:WaitForChild("Enemies"))
    SeaBeasts=ProcessEnemies(OthersEnemies,workspace:WaitForChild("SeaBeasts"))
    Characters=ProcessEnemies(OthersEnemies,workspace:WaitForChild("Characters"))
    local EW=lp.Character:FindFirstChildOfClass("Tool")
    if EW and EW:FindFirstChild("LeftClickRemote") then
        for _,ed in ipairs(OthersEnemies) do
            pcall(function()
                local dir=(ed[1].HumanoidRootPart.Position-lp.Character:GetPivot().Position).Unit
                EW.LeftClickRemote:FireServer(dir,1)
                EW.LeftClickRemote:FireServer(dir,1)  -- fire twice = faster M1
            end)
        end
    elseif #OthersEnemies>0 then
        local base=Enemies or SeaBeasts or Characters
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(base,OthersEnemies)
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(base,OthersEnemies)
    end
end
-- FIX: BringEnemy now brings mob to player's current position (center)
-- instead of PosMon (a saved offset position that caused corner issues)
function BringEnemy(Name)
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name==Name and IsAlive(v) and v.PrimaryPart then
            if (v.PrimaryPart.Position-hrp.Position).Magnitude<=350 then
                v.PrimaryPart.CFrame=CFrame.new(hrp.Position)  -- center on player
                v.Humanoid.WalkSpeed=0 v.Humanoid.JumpPower=0
                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                lp.SimulationRadius=math.huge
            end
        end
    end
end
Attack={}
function Attack.Alive(model)
    if not model then return end
    local h=model:FindFirstChild("Humanoid")
    return h and h.Health>0
end
function Attack.Kill(model)
    if model then
        if not model:GetAttribute("Locked") then
            model:SetAttribute("Locked",model.HumanoidRootPart.CFrame) end
        PosMon=model:GetAttribute("Locked").Position
        BringEnemy(model.Name)
        weaponSc(_G.SelectWP)
        AttackNoCD()
        -- fly-up method: go above mob and attack (avoids orbit corner miss)
        local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local above=CFrame.new(hrp.Position+Vector3.new(0,40,0))
            TweenService:Create(hrp,TweenInfo.new(0.1,Enum.EasingStyle.Linear),{CFrame=above}):Play()
            task.wait(0.1)
            AttackNoCD()
            task.wait(0.1)
        end
    end
end
function Attack.Kill2(model)
    if model then
        if workspace._WorldOrigin:FindFirstChild("Ring") or workspace._WorldOrigin:FindFirstChild("Fist")
        or workspace._WorldOrigin:FindFirstChild("MochiSwirl") then
            Tween(model.HumanoidRootPart.CFrame*CFrame.new(0,90,0))
        else Attack.Kill(model) end
    end
end
function GetConnectionEnemies(a)
    for _,v in pairs(RS:GetChildren()) do
        if v:IsA("Model") and ((typeof(a)=="table" and table.find(a,v.Name)) or v.Name==a)
        and IsAlive(v) then return v end
    end
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if v:IsA("Model") and ((typeof(a)=="table" and table.find(a,v.Name)) or v.Name==a)
        and IsAlive(v) then return v end
    end
end

-- ================================================================
-- RAID (original RaidFunc - unchanged)
-- ================================================================
function RaidFunc()
    SetStatus("Auto Raid")
    if not lp.PlayerGui.Main.TopHUDList.RaidTimer.Visible then
        if not GetBP("Special Microchip") then
            RS.Remotes.CommF_:InvokeServer("LoadFruit",GetFruits())
            RS.Remotes.CommF_:InvokeServer("RaidsNpc","Select","Flame")
        end
        if GetBP("Special Microchip") then
            pcall(function()
                fireclickdetector(workspace.Map["CircleIsland"].RaidSummon2.Button.Main.ClickDetector)
            end)
        end
    else
        -- Insta-kill island 5 then 4 (fly above + rapid hit)
        local function killIsland(name)
            local locs=workspace._WorldOrigin.Locations
            local isle=locs:FindFirstChild(name)
            if isle then
                Tween(isle.CFrame*CFrame.new(0,120,0))
                task.wait(0.3)
                for _,v in pairs(workspace.Enemies:GetChildren()) do
                    if IsAlive(v) and v.HumanoidRootPart then
                        pcall(function()
                            RegisterAttack:FireServer(0)
                            RegisterHit:FireServer(v.Head,{{v,v.Head}})
                            RegisterAttack:FireServer(0)
                            RegisterHit:FireServer(v.Head,{{v,v.Head}})
                        end)
                    end
                end
                return true
            end
        end
        killIsland("Island 5") task.wait(0.2)
        killIsland("Island 4") task.wait(0.2)
        for _,v in pairs(workspace.Enemies:GetChildren()) do
            if IsAlive(v) then
                repeat task.wait() Attack.Kill(v)
                until not v.Parent or v.Humanoid.Health<=0
                -- reposition after kill
                for _,loc in ipairs({"Island 5","Island 4","Island 3","Island 2","Island 1"}) do
                    if workspace._WorldOrigin.Locations:FindFirstChild(loc) then
                        Tween(workspace._WorldOrigin.Locations[loc].CFrame*CFrame.new(0,50,100))
                        break
                    end
                end
            end
        end
    end
end

-- ================================================================
-- SERVER HOP
-- ================================================================
local function ServerHop()
    SetStatus("Server hopping...")
    local ok,data=pcall(function()
        return HS:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId..
            "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and data and data.data then
        for _,s in ipairs(data.data) do
            if s.id~=game.JobId and s.playing and s.maxPlayers and s.playing<s.maxPlayers-2 then
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,lp) end)
                task.wait(8) return
            end
        end
    end
    TeleportService:Teleport(game.PlaceId)
end
HopBtn.MouseButton1Click:Connect(ServerHop)

-- ================================================================
-- AUTO STATS (Melee first → Defense → Sword)
-- ================================================================
local function AutoStats()
    pcall(function()
        local d=lp.Data
        while d.StatPoints and d.StatPoints.Value>0 do
            local mel=d.Stats and d.Stats.Melee and d.Stats.Melee.Level.Value or 0
            local def=d.Stats and d.Stats.Defense and d.Stats.Defense.Level.Value or 0
            if mel<2650 then RS.Remotes.CommF_:InvokeServer("AddPoint","Melee",d.StatPoints.Value)
            elseif def<2550 then RS.Remotes.CommF_:InvokeServer("AddPoint","Defense",d.StatPoints.Value)
            else RS.Remotes.CommF_:InvokeServer("StatPoint","Sword") end
            task.wait(0.05)
        end
    end)
end

-- ================================================================
-- AUTO CODES
-- ================================================================
task.spawn(function()
    task.wait(3) SetStatus("Redeeming codes...")
    local codes={"Sub2Fer999","Sub2OfficialNoobie","Sub2UncleKizaru","Sub2Daigrock",
        "Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy","fudd10","fudd10_v2",
        "StrawHatMaine","Bignews","Sub2Noobmaster123","TantaiGaming","Sub2CaptainMaui",
        "Sub2Striker","Sub2Ranz","kittgaming","Sub2Aopvien","Axiore","jesuisvenu",
        "Byakugan","ShutUpSam1","CaesarGaming","DRAGONABUSER","notnikolai",
        "GamingWithKev","Sub2HohoHub","Sub2LarryBird","Zero","Rip_indra",
        "Sub2ibrahimzaid","Sub2Gamerrobot_YT","THEGREATACE"}
    for _,c in ipairs(codes) do
        pcall(function() RS.Remotes.CommF_:InvokeServer("CodeRedemption",c) end)
        task.wait(0.2)
    end
    SetStatus("Codes done!")
end)

-- ================================================================
-- AUTO WARRIOR HELMET
-- ================================================================
if CFG.Setup.AutoWarriorHelmet then
    task.spawn(function()
        while _Running do task.wait(2)
            pcall(function()
                if lp.Character and not lp.Character:FindFirstChild("Warrior Helmet") then
                    local h=lp.Backpack:FindFirstChild("Warrior Helmet")
                    if h then lp.Character.Humanoid:EquipTool(h) end
                end
            end)
        end
    end)
end

-- ================================================================
-- AUTO HAKI COLORS (buy from anywhere via Barista Cousin remote)
-- ================================================================
task.spawn(function()
    while _Running do task.wait(20)
        pcall(function() RS.Remotes.CommF_:InvokeServer("Cousin","Buy") end)
    end
end)

-- ================================================================
-- BERRY COLLECT (Pink Pig, Red Cherry, White Cloud ONLY)
-- ================================================================
if CFG.Setup.AutoCollectBerry then
    local BERRIES={"Pink Pig Berry","Red Cherry Berry","White Cloud Berry"}
    task.spawn(function()
        while _Running do task.wait(5)
            pcall(function()
                for _,v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        for _,bn in ipairs(BERRIES) do
                            if v.Name==bn then
                                RS.Remotes.CommF_:InvokeServer("Pickup",v) break
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- ================================================================
-- FRUIT COLLECT + STORE (from original UpdStFruit)
-- ================================================================
task.spawn(function()
    while _Running do task.wait(6)
        pcall(function()
            for _,x in pairs(lp.Backpack:GetChildren()) do
                local sf=x:FindFirstChild("EatRemote",true)
                if sf then RS.Remotes.CommF_:InvokeServer("StoreFruit",
                    sf.Parent:GetAttribute("OriginalName"),lp.Backpack:FindFirstChild(x.Name)) end
            end
            if lp.Character then
                for _,x in pairs(lp.Character:GetChildren()) do
                    if x:GetAttribute("OriginalName") and x.Name:find("Fruit") then
                        RS.Remotes.CommF_:InvokeServer("StoreFruit",x:GetAttribute("OriginalName"),x) end
                end
            end
        end)
    end
end)

-- ================================================================
-- FRUIT SNIPER
-- ================================================================
if CFG.FruitSniper.Enabled then
    task.spawn(function()
        while _Running do task.wait(8)
            pcall(function()
                local stock=RS.Remotes.CommF_:InvokeServer("GetBloxFruitShop")
                if type(stock)=="table" then
                    for _,item in pairs(stock) do
                        if type(item)=="table" and table.find(CFG.FruitSniper.List,item.Name) then
                            SetStatus("Sniper: buying "..item.Name)
                            RS.Remotes.CommF_:InvokeServer("BuyBloxFruit",item.Name)
                        end
                    end
                end
            end)
        end
    end)
end

-- ================================================================
-- QUEST ROUTING (exact CFrames from Kaitun_lua.txt - unchanged)
-- ================================================================
function CheckLevel()
    local L=lp.Data.Level.Value
    if World1 then
        if L<=9 then
            if tostring(lp.Team)=="Marines" then
                Mon="Trainee" LevelQuest=1 NameQuest="MarineQuest" NameMon="Trainee"
                CFrameQuest=CFrame.new(-2709.67944,24.5206585,2104.24585,-0.744724929,-3.97967455e-08,-0.667371571,4.32403588e-08,1,-1.07884304e-07,0.667371571,-1.09201515e-07,-0.744724929)
                CFrameMon=CFrameQuest
            else
                Mon="Bandit" LevelQuest=1 NameQuest="BanditQuest1" NameMon="Bandit"
                CFrameMon=CFrame.new(1045.962646484375,27.00250816345215,1560.8203125)
                CFrameQuest=CFrameMon
            end
        elseif L<=14 then Mon="Monkey" LevelQuest=1 NameQuest="JungleQuest" NameMon="Monkey"
            CFrameQuest=CFrame.new(-1598.08911,35.5501175,153.377838,0,0,1,0,1,-0,-1,0,0)
            CFrameMon=CFrame.new(-1448.51806640625,67.85301208496094,11.46579647064209)
        elseif L<=29 then Mon="Gorilla" LevelQuest=2 NameQuest="JungleQuest" NameMon="Gorilla"
            CFrameQuest=CFrame.new(-1598.08911,35.5501175,153.377838,0,0,1,0,1,-0,-1,0,0)
            CFrameMon=CFrame.new(-1129.8836669921875,40.46354675292969,-525.4237060546875)
        elseif L<=39 then Mon="Pirate" LevelQuest=1 NameQuest="BuggyQuest1" NameMon="Pirate"
            CFrameQuest=CFrame.new(-1141.07483,4.10001802,3831.5498,0.965929627,-0,-0.258804798,0,1,-0,0.258804798,0,0.965929627)
            CFrameMon=CFrame.new(-1103.513427734375,13.752052307128906,3896.091064453125)
        elseif L<=59 then Mon="Brute" LevelQuest=2 NameQuest="BuggyQuest1" NameMon="Brute"
            CFrameQuest=CFrame.new(-1141.07483,4.10001802,3831.5498,0.965929627,-0,-0.258804798,0,1,-0,0.258804798,0,0.965929627)
            CFrameMon=CFrame.new(-1140.083740234375,14.809885025024414,4322.92138671875)
        elseif L<=74 then Mon="Desert Bandit" LevelQuest=1 NameQuest="DesertQuest" NameMon="Desert Bandit"
            CFrameQuest=CFrame.new(894.488647,5.14000702,4392.43359,0.819155693,-0,-0.573571265,0,1,-0,0.573571265,0,0.819155693)
            CFrameMon=CFrame.new(924.7998046875,6.44867467880249,4481.5859375)
        elseif L<=89 then Mon="Desert Officer" LevelQuest=2 NameQuest="DesertQuest" NameMon="Desert Officer"
            CFrameQuest=CFrame.new(894.488647,5.14000702,4392.43359,0.819155693,-0,-0.573571265,0,1,-0,0.573571265,0,0.819155693)
            CFrameMon=CFrame.new(1608.2822265625,8.614224433898926,4371.00732421875)
        elseif L<=99 then Mon="Snow Bandit" LevelQuest=1 NameQuest="SnowQuest" NameMon="Snow Bandit"
            CFrameQuest=CFrame.new(1389.74451,88.1519318,-1298.90796,-0.342042685,0,0.939684391,0,1,0,-0.939684391,0,-0.342042685)
            CFrameMon=CFrame.new(1354.347900390625,87.27277374267578,-1393.946533203125)
        elseif L<=119 then Mon="Snowman" LevelQuest=2 NameQuest="SnowQuest" NameMon="Snowman"
            CFrameQuest=CFrame.new(1389.74451,88.1519318,-1298.90796,-0.342042685,0,0.939684391,0,1,0,-0.939684391,0,-0.342042685)
            CFrameMon=CFrame.new(6241.9951171875,51.522083282471,-1243.9771728516)
        elseif L<=149 then Mon="Chief Petty Officer" LevelQuest=1 NameQuest="MarineQuest2" NameMon="Chief Petty Officer"
            CFrameQuest=CFrame.new(-5039.58643,27.3500385,4324.68018,0,0,-1,0,1,0,1,0,0)
            CFrameMon=CFrame.new(-4881.23095703125,22.65204429626465,4273.75244140625)
        elseif L<=174 then Mon="Sky Bandit" LevelQuest=1 NameQuest="SkyQuest" NameMon="Sky Bandit"
            CFrameQuest=CFrame.new(-4839.53027,716.368591,-2619.44165,0.866007268,0,0.500031412,0,1,0,-0.500031412,0,0.866007268)
            CFrameMon=CFrame.new(-4953.20703125,295.74420166015625,-2899.22900390625)
        elseif L<=189 then Mon="Dark Master" LevelQuest=2 NameQuest="SkyQuest" NameMon="Dark Master"
            CFrameQuest=CFrame.new(-4839.53027,716.368591,-2619.44165,0.866007268,0,0.500031412,0,1,0,-0.500031412,0,0.866007268)
            CFrameMon=CFrame.new(-5259.8447265625,391.3976745605469,-2229.035400390625)
        elseif L<=209 then Mon="Prisoner" LevelQuest=1 NameQuest="PrisonerQuest" NameMon="Prisoner"
            CFrameQuest=CFrame.new(5308.93115,1.65517521,475.120514,-0.0894274712,-5.00292918e-09,-0.995993316,1.60817859e-09,1,-5.16744869e-09,0.995993316,-2.06384709e-09,-0.0894274712)
            CFrameMon=CFrame.new(5098.9736328125,-0.3204058110713959,474.2373352050781)
        elseif L<=249 then Mon="Dangerous Prisoner" LevelQuest=2 NameQuest="PrisonerQuest" NameMon="Dangerous Prisoner"
            CFrameQuest=CFrame.new(5308.93115,1.65517521,475.120514,-0.0894274712,-5.00292918e-09,-0.995993316,1.60817859e-09,1,-5.16744869e-09,0.995993316,-2.06384709e-09,-0.0894274712)
            CFrameMon=CFrame.new(5654.5634765625,15.633401870727539,866.2991943359375)
        elseif L<=274 then Mon="Toga Warrior" LevelQuest=1 NameQuest="ColosseumQuest" NameMon="Toga Warrior"
            CFrameQuest=CFrame.new(-1580.04663,6.35000277,-2986.47534,-0.515037298,0,-0.857167721,0,1,0,0.857167721,0,-0.515037298)
            CFrameMon=CFrame.new(-1820.21484375,51.68385696411133,-2740.6650390625)
        elseif L<=299 then Mon="Gladiator" LevelQuest=2 NameQuest="ColosseumQuest" NameMon="Gladiator"
            CFrameQuest=CFrame.new(-1580.04663,6.35000277,-2986.47534,-0.515037298,0,-0.857167721,0,1,0,0.857167721,0,-0.515037298)
            CFrameMon=CFrame.new(-1292.838134765625,56.380882263183594,-3339.031494140625)
        elseif L<=324 then Mon="Military Soldier" LevelQuest=1 NameQuest="MagmaQuest" NameMon="Military Soldier"
            CFrameQuest=CFrame.new(-5313.37012,10.9500084,8515.29395,-0.499959469,0,0.866048813,0,1,0,-0.866048813,0,-0.499959469)
            CFrameMon=CFrame.new(-5411.16455078125,11.081554412841797,8454.29296875)
        elseif L<=374 then Mon="Military Spy" LevelQuest=2 NameQuest="MagmaQuest" NameMon="Military Spy"
            CFrameQuest=CFrame.new(-5313.37012,10.9500084,8515.29395,-0.499959469,0,0.866048813,0,1,0,-0.866048813,0,-0.499959469)
            CFrameMon=CFrame.new(-5802.8681640625,86.26241302490234,8828.859375)
        elseif L<=399 then Mon="Fishman Warrior" LevelQuest=1 NameQuest="FishmanQuest" NameMon="Fishman Warrior"
            CFrameQuest=CFrame.new(61122.65234375,18.497442245483,1569.3997802734)
            CFrameMon=CFrame.new(60878.30078125,18.482830047607422,1543.7574462890625)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>10000 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625,11.6796875,1819.7841796875)) end
        elseif L<=449 then Mon="Fishman Commando" LevelQuest=2 NameQuest="FishmanQuest" NameMon="Fishman Commando"
            CFrameQuest=CFrame.new(61122.65234375,18.497442245483,1569.3997802734)
            CFrameMon=CFrame.new(61922.6328125,18.482830047607422,1493.934326171875)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>10000 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625,11.6796875,1819.7841796875)) end
        elseif L<=474 then Mon="God's Guard" LevelQuest=1 NameQuest="SkyExp1Quest" NameMon="God's Guard"
            CFrameQuest=CFrame.new(-4721.88867,843.874695,-1949.96643,0.996191859,-0,-0.0871884301,0,1,-0,0.0871884301,0,0.996191859)
            CFrameMon=CFrame.new(-4710.04296875,845.2769775390625,-1927.3079833984375)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>10000 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275,872.54248,-1667.55688)) end
        elseif L<=524 then Mon="Shanda" LevelQuest=2 NameQuest="SkyExp1Quest" NameMon="Shanda"
            CFrameQuest=CFrame.new(-7859.09814,5544.19043,-381.476196,-0.422592998,0,0.906319618,0,1,0,-0.906319618,0,-0.422592998)
            CFrameMon=CFrame.new(-7678.48974609375,5566.40380859375,-497.2156066894531)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>10000 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894.6176757813,5547.1416015625,-380.29119873047)) end
        elseif L<=549 then Mon="Royal Squad" LevelQuest=1 NameQuest="SkyExp2Quest" NameMon="Royal Squad"
            CFrameQuest=CFrame.new(-7906.81592,5634.6626,-1411.99194,0,0,-1,0,1,0,1,0,0)
            CFrameMon=CFrame.new(-7624.25244140625,5658.13330078125,-1467.354248046875)
        elseif L<=624 then Mon="Royal Soldier" LevelQuest=2 NameQuest="SkyExp2Quest" NameMon="Royal Soldier"
            CFrameQuest=CFrame.new(-7906.81592,5634.6626,-1411.99194,0,0,-1,0,1,0,1,0,0)
            CFrameMon=CFrame.new(-7836.75341796875,5645.6640625,-1790.6236572265625)
        elseif L<=649 then Mon="Galley Pirate" LevelQuest=1 NameQuest="FountainQuest" NameMon="Galley Pirate"
            CFrameQuest=CFrame.new(5259.81982,37.3500175,4050.0293,0.087131381,0,0.996196866,0,1,0,-0.996196866,0,0.087131381)
            CFrameMon=CFrame.new(5551.02197265625,78.90135192871094,3930.412841796875)
        else Mon="Galley Captain" LevelQuest=2 NameQuest="FountainQuest" NameMon="Galley Captain"
            CFrameQuest=CFrame.new(5259.81982,37.3500175,4050.0293,0.087131381,0,0.996196866,0,1,0,-0.996196866,0,0.087131381)
            CFrameMon=CFrame.new(5441.95166015625,42.50205993652344,4950.09375)
        end
    elseif World2 then
        if L<=724 then Mon="Raider" LevelQuest=1 NameQuest="Area1Quest" NameMon="Raider"
            CFrameQuest=CFrame.new(-429.543518,71.7699966,1836.18188,-0.22495985,0,-0.974368095,0,1,0,0.974368095,0,-0.22495985)
            CFrameMon=CFrame.new(-728.3267211914062,52.779319763183594,2345.7705078125)
        elseif L<=774 then Mon="Mercenary" LevelQuest=2 NameQuest="Area1Quest" NameMon="Mercenary"
            CFrameQuest=CFrame.new(-429.543518,71.7699966,1836.18188,-0.22495985,0,-0.974368095,0,1,0,0.974368095,0,-0.22495985)
            CFrameMon=CFrame.new(-1004.3244018554688,80.15886688232422,1424.619384765625)
        elseif L<=799 then Mon="Swan Pirate" LevelQuest=1 NameQuest="Area2Quest" NameMon="Swan Pirate"
            CFrameQuest=CFrame.new(638.43811,71.769989,918.282898,0.139203906,0,0.99026376,0,1,0,-0.99026376,0,0.139203906)
            CFrameMon=CFrame.new(1068.664306640625,137.61428833007812,1322.1060791015625)
        elseif L<=874 then Mon="Factory Staff" LevelQuest=2 NameQuest="Area2Quest" NameMon="Factory Staff"
            CFrameQuest=CFrame.new(632.698608,73.1055908,918.666321,-0.0319722369,8.96074881e-10,-0.999488771,1.36326533e-10,1,8.92172336e-10,0.999488771,-1.07732087e-10,-0.0319722369)
            CFrameMon=CFrame.new(73.07867431640625,81.86344146728516,-27.470672607421875)
        elseif L<=899 then Mon="Marine Lieutenant" LevelQuest=1 NameQuest="MarineQuest3" NameMon="Marine Lieutenant"
            CFrameQuest=CFrame.new(-2440.79639,71.7140732,-3216.06812,0.866007268,0,0.500031412,0,1,0,-0.500031412,0,0.866007268)
            CFrameMon=CFrame.new(-2821.372314453125,75.89727783203125,-3070.089111328125)
        elseif L<=949 then Mon="Marine Captain" LevelQuest=2 NameQuest="MarineQuest3" NameMon="Marine Captain"
            CFrameQuest=CFrame.new(-2440.79639,71.7140732,-3216.06812,0.866007268,0,0.500031412,0,1,0,-0.500031412,0,0.866007268)
            CFrameMon=CFrame.new(-1861.2310791015625,80.17658233642578,-3254.697509765625)
        elseif L<=974 then Mon="Zombie" LevelQuest=1 NameQuest="ZombieQuest" NameMon="Zombie"
            CFrameQuest=CFrame.new(-5497.06152,47.5923004,-795.237061,-0.29242146,0,-0.95628953,0,1,0,0.95628953,0,-0.29242146)
            CFrameMon=CFrame.new(-5657.77685546875,78.96973419189453,-928.68701171875)
        elseif L<=999 then Mon="Vampire" LevelQuest=2 NameQuest="ZombieQuest" NameMon="Vampire"
            CFrameQuest=CFrame.new(-5497.06152,47.5923004,-795.237061,-0.29242146,0,-0.95628953,0,1,0,0.95628953,0,-0.29242146)
            CFrameMon=CFrame.new(-6037.66796875,32.18463897705078,-1340.6597900390625)
        elseif L<=1049 then Mon="Snow Trooper" LevelQuest=1 NameQuest="SnowMountainQuest" NameMon="Snow Trooper"
            CFrameQuest=CFrame.new(609.858826,400.119904,-5372.25928,0.50000006,0,0.866025388,0,1,0,-0.866025388,0,0.50000006)
            CFrameMon=CFrame.new(549.147338,427.387054,-5563.698730)
        elseif L<=1099 then Mon="Winter Warrior" LevelQuest=2 NameQuest="SnowMountainQuest" NameMon="Winter Warrior"
            CFrameQuest=CFrame.new(609.858826,400.119904,-5372.25928,0.50000006,0,0.866025388,0,1,0,-0.866025388,0,0.50000006)
            CFrameMon=CFrame.new(1142.745117,475.639801,-5199.416503)
        elseif L<=1124 then Mon="Lab Subordinate" LevelQuest=1 NameQuest="IceSideQuest" NameMon="Lab Subordinate"
            CFrameQuest=CFrame.new(-6064.06885,15.2422857,-4902.97852,-0.50000006,0,-0.866025388,0,1,0,0.866025388,0,-0.50000006)
            CFrameMon=CFrame.new(-5707.471679,15.951709,-4513.392089)
        elseif L<=1174 then Mon="Horned Warrior" LevelQuest=2 NameQuest="IceSideQuest" NameMon="Horned Warrior"
            CFrameQuest=CFrame.new(-6064.06885,15.2422857,-4902.97852,-0.50000006,0,-0.866025388,0,1,0,0.866025388,0,-0.50000006)
            CFrameMon=CFrame.new(-6341.366699,15.951770,-5723.162109)
        elseif L<=1199 then Mon="Magma Ninja" LevelQuest=1 NameQuest="FireSideQuest" NameMon="Magma Ninja"
            CFrameQuest=CFrame.new(-5428.03174,15.0622921,-5299.43457,0.50000006,0,0.866025388,0,1,0,-0.866025388,0,0.50000006)
            CFrameMon=CFrame.new(-5449.672851,76.658744,-5808.200683)
        elseif L<=1249 then Mon="Lava Pirate" LevelQuest=2 NameQuest="FireSideQuest" NameMon="Lava Pirate"
            CFrameQuest=CFrame.new(-5428.03174,15.0622921,-5299.43457,0.50000006,0,0.866025388,0,1,0,-0.866025388,0,0.50000006)
            CFrameMon=CFrame.new(-5213.331542,49.737880,-4701.451171)
        elseif L<=1274 then Mon="Ship Deckhand" LevelQuest=1 NameQuest="ShipQuest1" NameMon="Ship Deckhand"
            CFrameQuest=CFrame.new(1037.80127,125.092171,32911.6016)
            CFrameMon=CFrame.new(1212.011108,150.792053,33059.246093)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>500 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21,126.98,32852.83)) end
        elseif L<=1299 then Mon="Ship Engineer" LevelQuest=2 NameQuest="ShipQuest1" NameMon="Ship Engineer"
            CFrameQuest=CFrame.new(1037.80127,125.092171,32911.6016)
            CFrameMon=CFrame.new(919.480712,43.541839,32779.970703)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>500 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21,126.98,32852.83)) end
        elseif L<=1324 then Mon="Ship Steward" LevelQuest=1 NameQuest="ShipQuest2" NameMon="Ship Steward"
            CFrameQuest=CFrame.new(968.811401,125.092171,33244.125)
            CFrameMon=CFrame.new(919.443603,129.563049,33436.042968)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>500 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21,126.98,32852.83)) end
        elseif L<=1349 then Mon="Ship Officer" LevelQuest=2 NameQuest="ShipQuest2" NameMon="Ship Officer"
            CFrameQuest=CFrame.new(968.811401,125.092171,33244.125)
            CFrameMon=CFrame.new(1036.021118,181.443405,33315.730468)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>500 then
                RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21,126.98,32852.83)) end
        elseif L<=1374 then Mon="Arctic Warrior" LevelQuest=1 NameQuest="FrostQuest" NameMon="Arctic Warrior"
            CFrameQuest=CFrame.new(5667.66357,26.8000011,-6486.08691)
            CFrameMon=CFrame.new(5966.254882,62.972431,-6179.383300)
        elseif L<=1424 then Mon="Snow Lurker" LevelQuest=2 NameQuest="FrostQuest" NameMon="Snow Lurker"
            CFrameQuest=CFrame.new(5667.66357,26.8000011,-6486.08691)
            CFrameMon=CFrame.new(5407.071289,69.193031,-6880.882812)
        elseif L<=1449 then Mon="Sea Soldier" LevelQuest=1 NameQuest="ForgottenQuest" NameMon="Sea Soldier"
            CFrameQuest=CFrame.new(-3054.44458,235.544281,-10142.8193,0.990270376,-0,-0.13915664,0,1,-0,0.13915664,0,0.990270376)
            CFrameMon=CFrame.new(-3028.2236328125,64.67451477050781,-9775.4267578125)
        else Mon="Water Fighter" LevelQuest=2 NameQuest="ForgottenQuest" NameMon="Water Fighter"
            CFrameQuest=CFrame.new(-3054.44458,235.544281,-10142.8193,0.990270376,-0,-0.13915664,0,1,-0,0.13915664,0,0.990270376)
            CFrameMon=CFrame.new(-3352.9013671875,285.01556396484375,-10534.841796875)
        end
    elseif World3 then
        if L<=1524 then Mon="Pirate Millionaire" LevelQuest=1 NameQuest="PiratePortQuest" NameMon="Pirate Millionaire"
            CFrameQuest=CFrame.new(-712.8272705078125,98.5770492553711,5711.9541015625) CFrameMon=CFrameQuest
        elseif L<=1574 then Mon="Pistol Billionaire" LevelQuest=2 NameQuest="PiratePortQuest" NameMon="Pistol Billionaire"
            CFrameQuest=CFrame.new(-723.4331665039062,147.42906188964844,5931.9931640625) CFrameMon=CFrameQuest
        elseif L<=1599 then Mon="Dragon Crew Warrior" LevelQuest=1 NameQuest="AmazonQuest" NameMon="Dragon Crew Warrior"
            CFrameQuest=CFrame.new(6779.03271484375,111.16865539550781,-801.2130737304688) CFrameMon=CFrameQuest
        elseif L<=1624 then Mon="Dragon Crew Archer" LevelQuest=2 NameQuest="AmazonQuest" NameMon="Dragon Crew Archer"
            CFrameQuest=CFrame.new(6955.8974609375,546.6658935546875,309.0401306152344) CFrameMon=CFrameQuest
        elseif L<=1649 then Mon="Hydra Enforcer" LevelQuest=1 NameQuest="VenomCrewQuest" NameMon="Hydra Enforcer"
            CFrameQuest=CFrame.new(4620.61572265625,1002.2954711914062,399.0868835449219) CFrameMon=CFrameQuest
        elseif L<=1699 then Mon="Venomous Assailant" LevelQuest=2 NameQuest="VenomCrewQuest" NameMon="Venomous Assailant"
            CFrameQuest=CFrame.new(4697.5918,1100.65137,946.401978,0.579397917,-4.19689783e-10,0.81504482,-1.49287818e-10,1,6.21053986e-10,-0.81504482,-4.81513662e-10,0.579397917) CFrameMon=CFrameQuest
        elseif L<=1724 then Mon="Marine Commodore" LevelQuest=1 NameQuest="MarineTreeIsland" NameMon="Marine Commodore"
            CFrameQuest=CFrame.new(2180.54126,27.8156815,-6741.5498,-0.965929747,0,0.258804798,0,1,0,-0.258804798,0,-0.965929747)
            CFrameMon=CFrame.new(2286.0078125,73.13391876220703,-7159.80908203125)
        elseif L<=1774 then Mon="Marine Rear Admiral" LevelQuest=2 NameQuest="MarineTreeIsland" NameMon="Marine Rear Admiral"
            CFrameQuest=CFrame.new(2179.98828125,28.731239318848,-6740.0551757813)
            CFrameMon=CFrame.new(3656.773681640625,160.52406311035156,-7001.5986328125)
        elseif L<=1799 then Mon="Fishman Raider" LevelQuest=1 NameQuest="DeepForestIsland3" NameMon="Fishman Raider"
            CFrameQuest=CFrame.new(-10581.6563,330.872955,-8761.18652,-0.882952213,0,0.469463557,0,1,0,-0.469463557,0,-0.882952213)
            CFrameMon=CFrame.new(-10407.5263671875,331.76263427734375,-8368.5166015625)
        elseif L<=1824 then Mon="Fishman Captain" LevelQuest=2 NameQuest="DeepForestIsland3" NameMon="Fishman Captain"
            CFrameQuest=CFrame.new(-10581.6563,330.872955,-8761.18652,-0.882952213,0,0.469463557,0,1,0,-0.469463557,0,-0.882952213)
            CFrameMon=CFrame.new(-10994.701171875,352.38140869140625,-9002.1103515625)
        elseif L<=1849 then Mon="Forest Pirate" LevelQuest=1 NameQuest="DeepForestIsland" NameMon="Forest Pirate"
            CFrameQuest=CFrame.new(-13234.04,331.488495,-7625.40137,0.707134247,-0,-0.707079291,0,1,-0,0.707079291,0,0.707134247)
            CFrameMon=CFrame.new(-13274.478515625,332.3781433105469,-7769.58056640625)
        elseif L<=1899 then Mon="Mythological Pirate" LevelQuest=2 NameQuest="DeepForestIsland" NameMon="Mythological Pirate"
            CFrameQuest=CFrame.new(-13234.04,331.488495,-7625.40137,0.707134247,-0,-0.707079291,0,1,-0,0.707079291,0,0.707134247)
            CFrameMon=CFrame.new(-13680.607421875,501.08154296875,-6991.189453125)
        elseif L<=1924 then Mon="Jungle Pirate" LevelQuest=1 NameQuest="DeepForestIsland2" NameMon="Jungle Pirate"
            CFrameQuest=CFrame.new(-12680.3818,389.971039,-9902.01953,-0.0871315002,0,0.996196866,0,1,0,-0.996196866,0,-0.0871315002)
            CFrameMon=CFrame.new(-12256.16015625,331.73828125,-10485.8369140625)
        elseif L<=1974 then Mon="Musketeer Pirate" LevelQuest=2 NameQuest="DeepForestIsland2" NameMon="Musketeer Pirate"
            CFrameQuest=CFrame.new(-12680.3818,389.971039,-9902.01953,-0.0871315002,0,0.996196866,0,1,0,-0.996196866,0,-0.0871315002)
            CFrameMon=CFrame.new(-13457.904296875,391.545654296875,-9859.177734375)
        elseif L<=1999 then Mon="Reborn Skeleton" LevelQuest=1 NameQuest="HauntedQuest1" NameMon="Reborn Skeleton"
            CFrameQuest=CFrame.new(-9479.2168,141.215088,5566.09277,0,0,1,0,1,-0,-1,0,0)
            CFrameMon=CFrame.new(-8763.7236328125,165.72299194335938,6159.86181640625)
        elseif L<=2024 then Mon="Living Zombie" LevelQuest=2 NameQuest="HauntedQuest1" NameMon="Living Zombie"
            CFrameQuest=CFrame.new(-9479.2168,141.215088,5566.09277,0,0,1,0,1,-0,-1,0,0)
            CFrameMon=CFrame.new(-10144.1318359375,138.62667846679688,5838.0888671875)
        elseif L<=2049 then Mon="Demonic Soul" LevelQuest=1 NameQuest="HauntedQuest2" NameMon="Demonic Soul"
            CFrameQuest=CFrame.new(-9516.99316,172.017181,6078.46533,0,0,-1,0,1,0,1,0,0)
            CFrameMon=CFrame.new(-9505.8720703125,172.10482788085938,6158.9931640625)
        elseif L<=2074 then Mon="Posessed Mummy" LevelQuest=2 NameQuest="HauntedQuest2" NameMon="Posessed Mummy"
            CFrameQuest=CFrame.new(-9516.99316,172.017181,6078.46533,0,0,-1,0,1,0,1,0,0)
            CFrameMon=CFrame.new(-9582.0224609375,6.251527309417725,6205.478515625)
        elseif L<=2099 then Mon="Peanut Scout" LevelQuest=1 NameQuest="NutsIslandQuest" NameMon="Peanut Scout"
            CFrameQuest=CFrame.new(-2104.3908691406,38.104167938232,-10194.21875,0,0,-1,0,1,0,1,0,0)
            CFrameMon=CFrame.new(-2143.241943359375,47.72198486328125,-10029.9951171875)
        elseif L<=2124 then Mon="Peanut President" LevelQuest=2 NameQuest="NutsIslandQuest" NameMon="Peanut President"
            CFrameQuest=CFrame.new(-2104.3908691406,38.104167938232,-10194.21875,0,0,-1,0,1,0,1,0,0)
            CFrameMon=CFrame.new(-1859.35400390625,38.10316848754883,-10422.4296875)
        elseif L<=2149 then Mon="Ice Cream Chef" LevelQuest=1 NameQuest="IceCreamIslandQuest" NameMon="Ice Cream Chef"
            CFrameQuest=CFrame.new(-820.64825439453,65.819526672363,-10965.795898438,0,0,-1,0,1,0,1,0,0)
            CFrameMon=CFrame.new(-872.24658203125,65.81957244873047,-10919.95703125)
        elseif L<=2199 then Mon="Ice Cream Commander" LevelQuest=2 NameQuest="IceCreamIslandQuest" NameMon="Ice Cream Commander"
            CFrameQuest=CFrame.new(-820.64825439453,65.819526672363,-10965.795898438,0,0,-1,0,1,0,1,0,0)
            CFrameMon=CFrame.new(-558.06103515625,112.04895782470703,-11290.7744140625)
        elseif L<=2224 then Mon="Cookie Crafter" LevelQuest=1 NameQuest="CakeQuest1" NameMon="Cookie Crafter"
            CFrameQuest=CFrame.new(-2021.32007,37.7982254,-12028.7295,0.957576931,-8.80302053e-08,0.288177818,6.9301187e-08,1,7.51931211e-08,-0.288177818,-5.2032135e-08,0.957576931)
            CFrameMon=CFrame.new(-2374.13671875,37.79826354980469,-12125.30859375)
        elseif L<=2249 then Mon="Cake Guard" LevelQuest=2 NameQuest="CakeQuest1" NameMon="Cake Guard"
            CFrameQuest=CFrame.new(-2021.32007,37.7982254,-12028.7295,0.957576931,-8.80302053e-08,0.288177818,6.9301187e-08,1,7.51931211e-08,-0.288177818,-5.2032135e-08,0.957576931)
            CFrameMon=CFrame.new(-1598.3070068359375,43.773197174072266,-12244.5810546875)
        elseif L<=2274 then Mon="Baking Staff" LevelQuest=1 NameQuest="CakeQuest2" NameMon="Baking Staff"
            CFrameQuest=CFrame.new(-1927.91602,37.7981339,-12842.5391,-0.96804446,4.22142143e-08,0.250778586,4.74911062e-08,1,1.49904711e-08,-0.250778586,2.64211941e-08,-0.96804446)
            CFrameMon=CFrame.new(-1887.8099365234375,77.6185073852539,-12998.3505859375)
        elseif L<=2299 then Mon="Head Baker" LevelQuest=2 NameQuest="CakeQuest2" NameMon="Head Baker"
            CFrameQuest=CFrame.new(-1927.91602,37.7981339,-12842.5391,-0.96804446,4.22142143e-08,0.250778586,4.74911062e-08,1,1.49904711e-08,-0.250778586,2.64211941e-08,-0.96804446)
            CFrameMon=CFrame.new(-2216.188232421875,82.884521484375,-12869.2939453125)
        elseif L<=2324 then Mon="Cocoa Warrior" LevelQuest=1 NameQuest="ChocQuest1" NameMon="Cocoa Warrior"
            CFrameQuest=CFrame.new(233.22836303710938,29.876001358032227,-12201.2333984375)
            CFrameMon=CFrame.new(-21.55328369140625,80.57499694824219,-12352.3876953125)
        elseif L<=2349 then Mon="Chocolate Bar Battler" LevelQuest=2 NameQuest="ChocQuest1" NameMon="Chocolate Bar Battler"
            CFrameQuest=CFrame.new(233.22836303710938,29.876001358032227,-12201.2333984375)
            CFrameMon=CFrame.new(582.590576171875,77.18809509277344,-12463.162109375)
        elseif L<=2374 then Mon="Sweet Thief" LevelQuest=1 NameQuest="ChocQuest2" NameMon="Sweet Thief"
            CFrameQuest=CFrame.new(150.5066375732422,30.693693161010742,-12774.5029296875)
            CFrameMon=CFrame.new(165.1884765625,76.05885314941406,-12600.8369140625)
        elseif L<=2399 then Mon="Candy Rebel" LevelQuest=2 NameQuest="ChocQuest2" NameMon="Candy Rebel"
            CFrameQuest=CFrame.new(150.5066375732422,30.693693161010742,-12774.5029296875)
            CFrameMon=CFrame.new(134.86563110351562,77.2476806640625,-12876.5478515625)
        elseif L<=2449 then Mon="Candy Pirate" LevelQuest=1 NameQuest="CandyQuest1" NameMon="Candy Pirate"
            CFrameQuest=CFrame.new(-1150.0400390625,20.378934860229492,-14446.3349609375)
            CFrameMon=CFrame.new(-1310.5003662109375,26.016523361206055,-14562.404296875)
        elseif L<=2474 then Mon="Isle Outlaw" LevelQuest=1 NameQuest="TikiQuest1" NameMon="Isle Outlaw"
            CFrameQuest=CFrame.new(-16548.8164,55.6059914,-172.8125,0.213092566,-0,-0.977032006,0,1,-0,0.977032006,0,0.213092566)
            CFrameMon=CFrame.new(-16479.900390625,226.6117401123047,-300.3114318847656)
        elseif L<=2499 then Mon="Island Boy" LevelQuest=2 NameQuest="TikiQuest1" NameMon="Island Boy"
            CFrameQuest=CFrame.new(-16548.8164,55.6059914,-172.8125,0.213092566,-0,-0.977032006,0,1,-0,0.977032006,0,0.213092566)
            CFrameMon=CFrame.new(-16849.396484375,192.86505126953125,-150.7853240966797)
        elseif L<=2524 then Mon="Sun-kissed Warrior" LevelQuest=1 NameQuest="TikiQuest2" NameMon="kissed Warrior"
            CFrameMon=CFrame.new(-16347,64,984) CFrameQuest=CFrame.new(-16538,55,1049)
        elseif L<=2549 then Mon="Isle Champion" LevelQuest=2 NameQuest="TikiQuest2" NameMon="Isle Champion"
            CFrameQuest=CFrame.new(-16541.0215,57.3082275,1051.46118,0.0410757065,-0,-0.999156058,0,1,-0,0.999156058,0,0.0410757065)
            CFrameMon=CFrame.new(-16602.1015625,130.38734436035156,1087.24560546875)
        elseif L<=2574 then Mon="Serpent Hunter" LevelQuest=1 NameQuest="TikiQuest3" NameMon="Serpent Hunter"
            CFrameQuest=CFrame.new(-16679.478515625,176.74737548828125,1474.3995361328125) CFrameMon=CFrameQuest
        elseif L<=2599 then Mon="Skull Slayer" LevelQuest=2 NameQuest="TikiQuest3" NameMon="Skull Slayer"
            CFrameQuest=CFrame.new(-16759.58984375,71.28376770019531,1595.3399658203125) CFrameMon=CFrameQuest
        elseif L<=2624 then Mon="Reef Bandit" LevelQuest=1 NameQuest="SubmergedQuest1" NameMon="Reef Bandit"
            CFrameQuest=CFrame.new(10882.264,-2086.322,10034.226) CFrameMon=CFrame.new(10736.6191,-2087.8439,9338.4882)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.7041,25.2288494,1373.65955)) task.wait(2)
                pcall(function() RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland") end) end
        elseif L<=2649 then Mon="Coral Pirate" LevelQuest=2 NameQuest="SubmergedQuest1" NameMon="Coral Pirate"
            CFrameQuest=CFrame.new(10882.264,-2086.322,10034.226) CFrameMon=CFrame.new(10965.1025,-2158.8842,9177.2597)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.7041,25.2288494,1373.65955)) task.wait(2)
                pcall(function() RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland") end) end
        elseif L<=2699 then Mon="Ocean Prophet" LevelQuest=2 NameQuest="SubmergedQuest2" NameMon="Ocean Prophet"
            CFrameQuest=CFrame.new(10612.3848,-2087.844,10053.8926) CFrameMon=CFrame.new(11056.1445,-2001.6717,10117.4493)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.7041,25.2288494,1373.65955)) task.wait(2)
                pcall(function() RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland") end) end
        elseif L<=2724 then Mon="High Disciple" LevelQuest=1 NameQuest="SubmergedQuest3" NameMon="High Disciple"
            CFrameQuest=CFrame.new(9640.08789,-1992.44507,9613.65234) CFrameMon=CFrame.new(9750.41602,-1966.93884,9753.36035)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.7041,25.2288494,1373.65955)) task.wait(2)
                pcall(function() RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland") end) end
        else Mon="Grand Devotee" LevelQuest=2 NameQuest="SubmergedQuest3" NameMon="Grand Devotee"
            CFrameQuest=CFrame.new(9640.08789,-1992.44507,9613.65234) CFrameMon=CFrame.new(9611.70508,-1993.47119,9882.68848)
            if (CFrameQuest.Position-lp.Character.HumanoidRootPart.Position).Magnitude>1000 then
                Tween(CFrame.new(-16269.7041,25.2288494,1373.65955)) task.wait(2)
                pcall(function() RS.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland") end) end
        end
    end
end

-- ================================================================
-- FARM LEVEL (original FarmLevelFunc fixed - double quest added)
-- ================================================================
function FarmLevelFunc()
    CheckLevel()
    if not Mon then return end
    local QuestTitle=lp.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
    if not string.find(QuestTitle, NameMon) then
        RS.Remotes.CommF_:InvokeServer("AbandonQuest")
    end
    if not lp.PlayerGui.Main.Quest.Visible then
        Tween(CFrameQuest)
        if (lp.Character.HumanoidRootPart.Position-CFrameQuest.Position).Magnitude<=5 then
            task.wait(0.3)  -- small delay to avoid detection
            RS.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
            -- Double quest
            if CFG.Farming.DoubleQuest then
                task.wait(0.3)
                pcall(function()
                    RS.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest==1 and 2 or 1)
                end)
            end
        end
    elseif lp.PlayerGui.Main.Quest.Visible then
        if workspace.Enemies:FindFirstChild(Mon) then
            for _,v in pairs(workspace.Enemies:GetChildren()) do
                if Attack.Alive(v) and v.Name==Mon then
                    if string.find(QuestTitle, NameMon) then
                        -- swap to Tushita/Yama at 25% HP for fast finish
                        if v.Humanoid.Health/v.Humanoid.MaxHealth<=0.25 then
                            if GetWP("Tushita") then weaponSc("Tushita")
                            elseif GetWP("Yama") then weaponSc("Yama") end
                        end
                        repeat
                            task.wait()
                            Attack.Kill(v)
                        until v.Humanoid.Health<=0 or not v.Parent or not lp.PlayerGui.Main.Quest.Visible
                        Tween(CFrameMon)
                    else
                        RS.Remotes.CommF_:InvokeServer("AbandonQuest")
                    end
                end
            end
        else
            Tween(CFrameMon)
            if RS:FindFirstChild(Mon) then
                Tween(RS:FindFirstChild(Mon).HumanoidRootPart.CFrame*CFrame.new(0,30,0))
            end
        end
    end
end

-- ================================================================
-- GOD HUMAN CHAIN (from Kaitun_lua.txt melee loop - fixed & extended)
-- ================================================================
local function UnlockGodHuman()
    if not CFG.Get.GodHuman then return end
    -- Black Leg
    if not CheckMelee["Black Leg"]["Have"] then
        if GetBP("Black Leg") then SaveDataMelee("Black Leg","Have",true) return end
        SetStatus("Buy Black Leg") SetSub("Need $150k beli")
        if lp.Data.Beli.Value>=150000 then
            for _,v in pairs(RS.NPCs:GetChildren()) do
                if v.Name=="Dark Step Teacher" then Tween(v.HumanoidRootPart.CFrame) end
            end
            RS.Remotes.CommF_:InvokeServer("BuyBlackLeg")
        else SetStatus("Farm Level") FarmLevelFunc() end
        return
    end
    -- Electro
    if not CheckMelee["Electro"]["Have"] then
        if GetBP("Electro") then SaveDataMelee("Electro","Have",true) return end
        SetStatus("Buy Electro") SetSub("Need BL 400mas + $500k")
        if CheckMelee["Black Leg"]["Mastery"]>=400 and lp.Data.Beli.Value>=500000 then
            for _,v in pairs(RS.NPCs:GetChildren()) do
                if v.Name=="Mad Scientist" then Tween(v.HumanoidRootPart.CFrame) end
            end
            RS.Remotes.CommF_:InvokeServer("BuyElectro")
        else SetStatus("Farm Level") FarmLevelFunc() end
        return
    end
    -- Fishman Karate
    if not CheckMelee["Fishman Karate"]["Have"] then
        if GetBP("Fishman Karate") then SaveDataMelee("Fishman Karate","Have",true) return end
        SetStatus("Buy Fishman Karate") SetSub("Need Electro 400mas + $750k")
        if CheckMelee["Electro"]["Mastery"]>=400 and lp.Data.Beli.Value>=750000 then
            for _,v in pairs(RS.NPCs:GetChildren()) do
                if v.Name=="Water Kung-fu Teacher" then Tween(v.HumanoidRootPart.CFrame) end
            end
            RS.Remotes.CommF_:InvokeServer("BuyFishmanKarate")
        else SetStatus("Farm Level") FarmLevelFunc() end
        return
    end
    -- Dragon Claw
    if not CheckMelee["Dragon Claw"]["Have"] then
        if GetBP("Dragon Claw") then SaveDataMelee("Dragon Claw","Have",true) return end
        SetStatus("Buy Dragon Claw") SetSub("Need FK 400mas + 1500 frags + Lv1100 + W2/W3")
        if (World2 or World3) and CheckMelee["Fishman Karate"]["Mastery"]>=400
        and lp.Data.Level.Value>=1100 and lp.Data.Fragments.Value>=1500 then
            for _,v in pairs(RS.NPCs:GetChildren()) do
                if v.Name=="Sabi" then Tween(v.HumanoidRootPart.CFrame) end
            end
            RS.Remotes.CommF_:InvokeServer("BlackbeardReward","DragonClaw","2")
        elseif #GetFruits()>0 and lp.Data.Fragments.Value<1500 then
            SetStatus("Auto Raid for frags") RaidFunc()
        else SetStatus("Farm Level") FarmLevelFunc() end
        return
    end
    -- Superhuman
    if not CheckMelee["Superhuman"]["Have"] then
        if GetBP("Superhuman") then SaveDataMelee("Superhuman","Have",true) return end
        SetStatus("Buy Superhuman") SetSub("Need DC 400mas + $3M + W2/W3 + Lv1100")
        if (World2 or World3) and CheckMelee["Dragon Claw"]["Mastery"]>=400
        and lp.Data.Level.Value>=1100 and lp.Data.Beli.Value>=3000000 then
            for _,v in pairs(RS.NPCs:GetChildren()) do
                if v.Name=="Martial Arts Master" then Tween(v.HumanoidRootPart.CFrame) end
            end
            RS.Remotes.CommF_:InvokeServer("BuySuperhuman","2")
        else SetStatus("Farm Level") FarmLevelFunc() end
        return
    end
    -- Death Step
    if not CheckMelee["Death Step"]["Have"] then
        if GetBP("Death Step") then SaveDataMelee("Death Step","Have",true) return end
        SetStatus("Buy Death Step")
        local r=RS.Remotes.CommF_:InvokeServer("BuyDeathStep")
        if r~=1 and r~=2 then SetStatus("Farm Level") FarmLevelFunc() end
        return
    end
    -- Sharkman Karate
    if not CheckMelee["Sharkman Karate"]["Have"] then
        if GetBP("Sharkman Karate") then SaveDataMelee("Sharkman Karate","Have",true) return end
        SetStatus("Buy Sharkman Karate") SetSub("Need 5000 frags")
        if lp.Data.Fragments.Value>=5000 then
            RS.Remotes.CommF_:InvokeServer("BuySharkmanKarate")
        elseif #GetFruits()>0 then RaidFunc()
        else SetStatus("Farm Level") FarmLevelFunc() end
        return
    end
    -- Electric Claw
    if not CheckMelee["Electric Claw"]["Have"] then
        if GetBP("Electric Claw") then SaveDataMelee("Electric Claw","Have",true) return end
        SetStatus("Buy Electric Claw") SetSub("Need 3000 frags")
        if lp.Data.Fragments.Value>=3000 then
            local r=RS.Remotes.CommF_:InvokeServer("BuyElectricClaw")
            if r~=1 and r~=2 then
                if #GetFruits()>0 then RaidFunc() else FarmLevelFunc() end
            end
        elseif #GetFruits()>0 then RaidFunc()
        else FarmLevelFunc() end
        return
    end
    -- Dragon Talon (bones -> fire essence -> Uzoth)
    if not CheckMelee["Dragon Talon"]["Have"] then
        if GetBP("Dragon Talon") then SaveDataMelee("Dragon Talon","Have",true) return end
        SetStatus("Dragon Talon")
        if lp.Backpack:FindFirstChild("Fire Essence") or lp.Character:FindFirstChild("Fire Essence") then
            SetSub("Using Fire Essence at Uzoth")
            EquipWeapon("Fire Essence") task.wait(0.5)
            RS.Remotes.CommF_:InvokeServer("BuyDragonTalon",true)
            RS.Remotes.CommF_:InvokeServer("BuyDragonTalon")
        elseif GetM("Bone")>=500 then
            SetSub("Exchange bones at Death King")
            Tween(CFrame.new(-9534,143,5706)) task.wait(1)
            RS.Remotes.CommF_:InvokeServer("ExchangeBones")
        else
            SetSub("Farm 500 bones ("..GetM("Bone").."/500)")
            Mon="Reborn Skeleton" NameMon="Reborn Skeleton" LevelQuest=1 NameQuest="HauntedQuest1"
            CFrameQuest=CFrame.new(-9479.2168,141.215088,5566.09277,0,0,1,0,1,-0,-1,0,0)
            CFrameMon=CFrame.new(-8763.7236328125,165.72299194335938,6159.86181640625)
            FarmLevelFunc()
        end
        return
    end
    -- God Human
    if not CheckMelee["Godhuman"]["Have"] then
        if GetBP("Godhuman") then SaveDataMelee("Godhuman","Have",true) return end
        SetStatus("Buy GOD HUMAN!") SetSub("Need all 400mas + $5M + 5000 frags")
        if lp.Data.Beli.Value>=5000000 and lp.Data.Fragments.Value>=5000 then
            local r=RS.Remotes.CommF_:InvokeServer("BuyGodhuman")
            if r==1 or r==2 then SaveDataMelee("Godhuman","Have",true) end
        elseif #GetFruits()>0 and lp.Data.Fragments.Value<5000 then RaidFunc()
        else FarmLevelFunc() end
        return
    end
    SetStatus("GOD HUMAN: UNLOCKED!") SetGoal("All 10 styles done!")
end

-- ================================================================
-- YAMA (1000 bones -> Death King)
-- ================================================================
local function GetYama()
    if GetWP("Yama") then return true end
    SetStatus("Getting Yama") SetGoal("Need 1000 bones")
    while GetM("Bone")<1000 do
        SetSub("Bones "..GetM("Bone").."/1000")
        Mon="Reborn Skeleton" NameMon="Reborn Skeleton" LevelQuest=1 NameQuest="HauntedQuest1"
        CFrameQuest=CFrame.new(-9479.2168,141.215088,5566.09277,0,0,1,0,1,-0,-1,0,0)
        CFrameMon=CFrame.new(-8763.7236328125,165.72299194335938,6159.86181640625)
        pcall(FarmLevelFunc) task.wait(0.1)
    end
    Tween(CFrame.new(-9534,143,5706)) task.wait(1.5)
    RS.Remotes.CommF_:InvokeServer("BuyYama")
    task.wait(1)
    if GetWP("Yama") then SetStatus("Yama DONE!") return true end
    return false
end

-- ================================================================
-- TUSHITA (30 Conjured Cocoa + light torches at Floating Turtle)
-- ================================================================
local function GetTushita()
    if GetWP("Tushita") then return true end
    SetStatus("Getting Tushita")
    while GetM("Conjured Cocoa")<30 do
        SetSub("Conjured Cocoa "..GetM("Conjured Cocoa").."/30")
        Mon="Cocoa Warrior" NameMon="Cocoa Warrior" LevelQuest=1 NameQuest="ChocQuest1"
        CFrameQuest=CFrame.new(233.22836303710938,29.876001358032227,-12201.2333984375)
        CFrameMon=CFrame.new(-21.55328369140625,80.57499694824219,-12352.3876953125)
        pcall(FarmLevelFunc) task.wait(0.1)
    end
    SetSub("Lighting torches at Floating Turtle")
    for i=1,5 do
        local torchName="Torch"..i
        local mapHD=workspace.Map:FindFirstChild("HeavenlyDimension",true)
        if mapHD then
            local t=mapHD:FindFirstChild(torchName,true)
            if t then
                repeat task.wait(0.05) Tween(t.CFrame,200)
                until (t.Position-lp.Character.HumanoidRootPart.Position).Magnitude<=7
                pcall(function() fireproximityprompt(t:FindFirstChildOfClass("ProximityPrompt")) end)
                task.wait(0.4)
            end
        end
    end
    pcall(function() RS.Remotes.CommF_:InvokeServer("GetTushita") end)
    task.wait(1)
    if GetWP("Tushita") then SetStatus("Tushita DONE!") return true end
    return false
end

-- ================================================================
-- CDK (Tushita+Yama at 350mas -> combine at Lv2200+)
-- ================================================================
local function GetCDK()
    if not CFG.Get.CDK then return end
    if GetIn("Cursed Dual Katana") then return end
    if lp.Data.Level.Value<2200 then
        SetSub("CDK: need Lv2200+ ("..lp.Data.Level.Value.."/2200)")
        FarmLevelFunc() return
    end
    if not GetWP("Tushita") then GetTushita() return end
    if not GetWP("Yama") then GetYama() return end
    local function getSwordMas(name)
        for _,v in pairs(RS.Remotes.CommF_:InvokeServer("getInventory")) do
            if type(v)=="table" and v.Name==name then return v.Mastery or v.Level or 0 end
        end return 0
    end
    local tm=getSwordMas("Tushita") local ym=getSwordMas("Yama")
    if tm<350 then SetSub("Tushita mastery "..tm.."/350") weaponSc("Tushita") FarmLevelFunc() return end
    if ym<350 then SetSub("Yama mastery "..ym.."/350") weaponSc("Yama") FarmLevelFunc() return end
    -- Both 350 - do CDK quest
    SetStatus("CDK: Starting puzzle!")
    Tween(CFrame.new(-12379.1406,601.433167,-6543.60742)) task.wait(1.5)
    pcall(function() RS.Remotes.CommF_:InvokeServer("CDKQuest","Progress","Good") end) task.wait(1)
    pcall(function() RS.Remotes.CommF_:InvokeServer("CDKQuest","StartTrial","Good") end) task.wait(1)
    -- Light HeavenlyDimension torches
    local hd=workspace.Map:FindFirstChild("HeavenlyDimension",true)
    if hd then
        for i=1,3 do
            local t=hd:FindFirstChild("Torch"..i,true)
            if t then
                repeat task.wait(0.05) Tween(t.CFrame,300)
                until (t.Position-lp.Character.HumanoidRootPart.Position).Magnitude<=7
                pcall(function() fireproximityprompt(t:FindFirstChildOfClass("ProximityPrompt")) end)
                task.wait(0.4)
            end
        end
    end
    pcall(function() RS.Remotes.CommF_:InvokeServer("CDKQuest","Progress","Evil") end) task.wait(1)
    pcall(function() RS.Remotes.CommF_:InvokeServer("CDKQuest","StartTrial","Evil") end) task.wait(1)
    local hell=workspace.Map:FindFirstChild("HellDimension",true)
    if hell then
        for i=1,3 do
            local t=hell:FindFirstChild("Torch"..i,true)
            if t then
                repeat task.wait(0.05) Tween(t.CFrame,300)
                until (t.Position-lp.Character.HumanoidRootPart.Position).Magnitude<=7
                pcall(function() fireproximityprompt(t:FindFirstChildOfClass("ProximityPrompt")) end)
                task.wait(0.4)
            end
        end
    end
    pcall(function() RS.Remotes.CommF_:InvokeServer("CombineSwords","Tushita","Yama") end)
    task.wait(1)
    if GetIn("Cursed Dual Katana") then
        SetStatus("CDK: OBTAINED!") _G.SelectWP="Cursed Dual Katana"
    end
end

-- ================================================================
-- SOUL GUITAR (Soul Reaper boss at Haunted Castle, Lv2300+)
-- ================================================================
local function GetSoulGuitar()
    if not CFG.Get.SoulGuitar then return end
    if GetIn("Soul Guitar") or GetIn("Skull Guitar") then return end
    if lp.Data.Level.Value<2300 then
        SetSub("Soul Guitar: need Lv2300+") FarmLevelFunc() return
    end
    SetStatus("Soul Guitar: hunting Soul Reaper")
    local tries=0
    while not GetIn("Soul Guitar") and not GetIn("Skull Guitar") and _Running do
        tries=tries+1 SetSub("Attempt #"..tries)
        Tween(CFrame.new(-9495.6806640625,453.58624267578125,5977.3486328125))
        local boss=GetConnectionEnemies("Soul Reaper")
        if boss then
            repeat task.wait() Attack.Kill(boss)
            until not boss.Parent or boss.Humanoid.Health<=0
            task.wait(2)
            for _,v in pairs(workspace:GetDescendants()) do
                if v.Name=="Soul Guitar" or v.Name=="Skull Guitar" then
                    pcall(function() RS.Remotes.CommF_:InvokeServer("Pickup",v) end) end
            end
        else
            task.wait(12)
            if tries%6==0 then ServerHop() task.wait(10) end
        end
        if tries>30 then break end
    end
    if GetIn("Soul Guitar") or GetIn("Skull Guitar") then SetStatus("Soul Guitar: OBTAINED!") end
end

-- ================================================================
-- ELITE HUNTER (Sea 3 boss - drops God's Chalice)
-- ================================================================
local function DoEliteHunter()
    if not World3 then return end
    pcall(function()
        local r=RS.Remotes.CommF_:InvokeServer("EliteHunter")
        if type(r)=="string" and r:find("don't have") then return end
        RS.Remotes.CommF_:InvokeServer("EliteHunter")
        for _,name in ipairs({"Diablo","Deandre","Urban"}) do
            local boss=GetConnectionEnemies(name)
            if boss and IsAlive(boss) then
                SetStatus("Elite Hunter: "..name)
                repeat task.wait()
                    RS.Remotes.CommF_:InvokeServer("EliteHunter")
                    Tween(boss.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                    AttackNoCD()
                until not boss.Parent or boss.Humanoid.Health<=0
            end
        end
    end)
end

-- ================================================================
-- DOUGH KING (Sweet Chalice - tween only, no reset/bypass)
-- ================================================================
local function DoDoughKing()
    if not CFG.Setup.AutoSummonDoughKing or not World3 then return end
    local dk=GetConnectionEnemies("Dough King")
    if dk then
        SetStatus("Killing Dough King!")
        repeat task.wait() Tween(dk.HumanoidRootPart.CFrame*CFrame.new(0,-30,0)) AttackNoCD()
        until not dk.Parent or dk.Humanoid.Health<=0
        return
    end
    -- Sweet Chalice flow (tween ONLY - no reset or chalice is lost)
    if lp.Backpack:FindFirstChild("Sweet Chalice") or (lp.Character and lp.Character:FindFirstChild("Sweet Chalice")) then
        EquipWeapon("Sweet Chalice") Tween(CFrame.new(-2286.6843261719,146.56562805176,-12226.881835938))
        task.wait(1) pcall(function() RS.Remotes.CommF_:InvokeServer("SweetChaliceNpc") end)
        return
    end
    -- God's Chalice + 10 Conjured Cocoa -> Sweet Chalice
    if lp.Backpack:FindFirstChild("God's Chalice") or (lp.Character and lp.Character:FindFirstChild("God's Chalice")) then
        if GetM("Conjured Cocoa")>=10 then
            pcall(function() RS.Remotes.CommF_:InvokeServer("SweetChaliceNpc") end)
        else
            SetSub("Sweet Chalice: need Conjured Cocoa ("..GetM("Conjured Cocoa").."/10)")
            Mon="Cocoa Warrior" NameMon="Cocoa Warrior" LevelQuest=1 NameQuest="ChocQuest1"
            CFrameQuest=CFrame.new(233.22836303710938,29.876001358032227,-12201.2333984375)
            CFrameMon=CFrame.new(-21.55328369140625,80.57499694824219,-12352.3876953125)
            FarmLevelFunc()
        end
    end
end

-- ================================================================
-- DISCORD WEBHOOK (every 4 minutes)
-- ================================================================
if CFG.Webhook.Enabled and CFG.Webhook.Url~="YOUR_WEBHOOK_URL_HERE" then
    task.spawn(function()
        while _Running do
            pcall(function()
                local mc=0 for _,v in pairs(CheckMelee) do if v.Have then mc=mc+1 end end
                local fts=GetFruits()
                local fstr=#fts>0 and table.concat((function() local t={} for _,f in ipairs(fts) do table.insert(t,f.Name) end return t end)(),", ") or "No fruits"
                local payload=HS:JSONEncode({
                    username="RexyHub Kaitun",
                    embeds={{
                        title="🔴 RexyHub — Kaitun",
                        color=0xCC1111,
                        fields={
                            {name="👤 Player",    value=lp.Name,                          inline=true},
                            {name="⭐ Level",     value=tostring(lp.Data.Level.Value),     inline=true},
                            {name="💰 Beli",      value="$"..tostring(lp.Data.Beli.Value), inline=true},
                            {name="🔮 Fragments", value=tostring(lp.Data.Fragments.Value), inline=true},
                            {name="👊 Melee",     value=mc.."/10 styles",                 inline=true},
                            {name="🍎 Fruits",    value=fstr,                             inline=false},
                            {name="📋 Status",    value=StatusLbl.Text or "Running",      inline=false},
                        },
                        footer={text="RexyHub Webhook System | Kaitun v4.0"},
                    }}
                })
                game:HttpPost(CFG.Webhook.Url,payload,false,"application/json")
            end)
            task.wait(240)
        end
    end)
end

-- ================================================================
-- UTILITY LOOPS (noclip, buso, anti-afk, auto rejoin)
-- ================================================================
spawn(function()
    while task.wait() do
        pcall(function()
            if not lp.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                local Noclip=Instance.new("BodyVelocity")
                Noclip.Name="BodyClip" Noclip.Parent=lp.Character.HumanoidRootPart
                Noclip.MaxForce=Vector3.new(100000,100000,100000)
                Noclip.Velocity=Vector3.new(0,0,0)
            end
            for _,no in pairs(lp.Character:GetDescendants()) do
                if no:IsA("BasePart") then no.CanCollide=false end
            end
        end)
    end
end)
spawn(function()
    while task.wait() do
        pcall(function()
            if not lp.Character:FindFirstChild("HasBuso") then
                RS.Remotes.CommF_:InvokeServer("Buso") end
        end)
    end
end)
lp.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait()
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)
spawn(function()
    lp.AncestryChanged:Connect(function(_,p)
        if not p then task.wait(3) pcall(function() TeleportService:Teleport(game.PlaceId) end) end
    end)
end)

-- ================================================================
-- MASTERY TRACKER LOOP (from original Kaitun_lua.txt - fixed)
-- ================================================================
spawn(function()
    while task.wait() do
        pcall(function()
            AutoStats()
            for _,style in ipairs(MELEE_LIST) do
                if GetBP(style) and lp.Character:FindFirstChild(style) then
                    local node=lp.Character[style]
                    if node and node:FindFirstChild("Level") then
                        if not CheckMelee[style]["Have"] then SaveDataMelee(style,"Have",true) end
                        SaveDataMelee(style,"Mastery",node.Level.Value)
                    end
                end
            end
        end)
    end
end)

-- ================================================================
-- MAIN LOOP (original structure + all new features)
-- ================================================================
spawn(function()
    while task.wait() do
        pcall(function()
            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1) return end
            local lvl=lp.Data.Level.Value
            local frag=lp.Data.Fragments.Value

            -- Boss priority
            if CFG.Setup.AutoSummonCakePrince then
                local cp=GetConnectionEnemies({"Cake Prince","Dough King"})
                if cp then repeat task.wait() Attack.Kill2(cp) until not cp.Parent or cp.Humanoid.Health<=0 return end
            end
            if World3 then DoEliteHunter() DoDoughKing() end

            -- Sea 1
            if lvl<700 then
                SetStatus("Sea 1 — Lv"..lvl) SetGoal("Reach Lv700")
                FarmLevelFunc()

            -- Sea 2
            elseif lvl<1500 then
                SetStatus("Sea 2 — Lv"..lvl)
                if CFG.Get.GodHuman and not (CheckMelee["Black Leg"]["Have"]
                and CheckMelee["Electro"]["Have"] and CheckMelee["Fishman Karate"]["Have"]) then
                    SetGoal("Unlock early melee styles")
                    UnlockGodHuman()
                else
                    SetGoal("Farm to Lv1500")
                    FarmLevelFunc()
                end

            -- Sea 3
            else
                SetStatus("Sea 3 — Lv"..lvl)
                -- Raids when frags needed
                local needFrag=(not CheckMelee["Dragon Claw"]["Have"] and frag<1500)
                    or (not CheckMelee["Sharkman Karate"]["Have"] and frag<5000)
                    or (not CheckMelee["Electric Claw"]["Have"] and frag<3000)
                    or (not CheckMelee["Godhuman"]["Have"] and frag<5000)
                if CFG.Setup.UnlockRaidDough and needFrag and #GetFruits()>0 then
                    RaidFunc() return end
                -- God Human
                if CFG.Get.GodHuman and not CheckMelee["Godhuman"]["Have"] then
                    UnlockGodHuman() return end
                -- CDK
                if not GetIn("Cursed Dual Katana") then GetCDK() return end
                -- Soul Guitar
                if not GetIn("Soul Guitar") and not GetIn("Skull Guitar") then
                    GetSoulGuitar() return end
                -- Best weapon
                if GetWP("Cursed Dual Katana") then _G.SelectWP="Cursed Dual Katana"
                elseif CheckMelee["Godhuman"]["Have"] then _G.SelectWP="Melee" end
                -- Max level
                if lvl>=2800 then
                    SetStatus("MAX LEVEL! All done!") SetGoal("GH + CDK + SG + Lv2800 COMPLETE!")
                    task.wait(2)
                else
                    SetStatus("Sea 3 grind Lv"..lvl.."/2800")
                    SetGoal("GH "..(CheckMelee["Godhuman"]["Have"] and "done" or "⏳")
                        .." CDK "..(GetIn("Cursed Dual Katana") and "done" or "⏳")
                        .." SG "..(GetIn("Soul Guitar") and "done" or "⏳"))
                    FarmLevelFunc()
                end
            end
        end)
    end
end)

print("[RexyHub Kaitun v4.0] LOADED! Auto-farming 1-2800 active.")
