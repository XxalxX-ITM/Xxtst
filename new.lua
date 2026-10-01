--[[
    ITMEANS RECHAT - ULTIMATE FINAL + AI SYSTEM (SINGLE KEY)
    Firebase: itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app
    Creator: XxalxX (itmeans0011)
    Added: 10 new animated auras (from Zane/Chat style), new sticker pack, model update
    AI: gemini-3.5-flash-lite, max 200 chars reply
]]

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserId = LocalPlayer.UserId
local ScriptStartTime = os.time()

local SOUND_TOGGLE = "rbxasset://sounds/ui_click.wav"
local SOUND_MESSAGE = "rbxasset://sounds/electronicpingshort.wav"

-- ==================== AI CONFIG (SINGLE KEY) ====================
local GEMINI_MODEL   = "gemini-3.5-flash-lite"
local GEMINI_API_KEY = "YAHAN_APNI_KEY_DAAL"

local AI_NAME          = "XxalxX's AI"
local AI_DISPLAY       = "XxalxX AI"
local AI_CREATOR       = "itmeans0011"
local AI_COOLDOWN      = 5
local AI_HISTORY_LIMIT = 3
local AI_PFP           = "🤖"
local AI_SPY_TARGET    = "itmeans0011"
local aiLastUsed = {}
local aiHistory  = {}
-- =============================================================

local IsFullyLoaded = false
local uiToggled = false
local renderedMessageIds = {}
local renderedPvtMsgIds = {}
local CurrentThemeColor = Color3.fromRGB(255, 20, 147)
local DarkBG = Color3.fromRGB(18, 18, 24)
local SecondaryBG = Color3.fromRGB(28, 28, 36)
local LastMessageTime = 0
local MESSAGE_COOLDOWN = 1.5
local AnimatedRankLabels = {}
local AnimatedSystemLabels = {}
local BannedUsers = {}
local activeReplyContext = nil
local activePvtTarget = nil
local currentPopup = nil

local CurrentServerId = (game.JobId ~= "" and game.JobId) or "StudioLocalServer"
local FirebaseURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/SecretChat_" .. CurrentServerId .. ".json"
local FirebaseTypingURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/SecretTyping_" .. CurrentServerId .. ".json"
local FirebaseRanksURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Ranks.json"
local FirebaseAurasURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Auras.json"
local FirebaseFollowsURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Followers.json"
local FirebasePrivateURL = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/PrivateMessages_" .. CurrentServerId .. ".json"

local Creators = {
    ["itmeans0011"] = true,
    ["ArynX_Xhehe"] = true,
    [11017676057] = true,
}
local Admins = {}
local Vips = {
    ["AaravGamer9586"] = true,
    ["Vedantplays122"] = true,
}
local Daddys = {
    ["diva_bobagirl"] = true,
}

local RGBRanks = {}
local SyncedAuras = {}
local activeAuras = {}
local sendSecretMessage
local sendAiReply

local AuraColors = {
    ["pink"] = Color3.fromRGB(255, 20, 147),
    ["golden"] = Color3.fromRGB(255, 215, 0),
    ["gold"] = Color3.fromRGB(255, 215, 0),
    ["black"] = Color3.fromRGB(15, 15, 15),
    ["red"] = Color3.fromRGB(255, 0, 0),
    ["green"] = Color3.fromRGB(0, 255, 0),
    ["blue"] = Color3.fromRGB(0, 0, 255),
    ["white"] = Color3.fromRGB(255, 255, 255),
    ["silver"] = Color3.fromRGB(192, 192, 192)
}

-- ==================== ONLY 3 STRUCTURE AURAS (MECHA, MECHA2, ORBIT) ====================
local partsStructure = {
    {size = Vector3.new(1.8, 1.8, 2), offset = CFrame.new(-1.8, 2.5, 2.2), isDetail = false},
    {size = Vector3.new(2.2, 2.2, 2.2), offset = CFrame.new(-2.8, 2.8, 2.4) * CFrame.Angles(0, math.rad(15), 0), isDetail = false},
    {size = Vector3.new(2.5, 3.5, 2.5), offset = CFrame.new(-4, 3.5, 2.6) * CFrame.Angles(0, 0, math.rad(-10)), isDetail = false},
    {size = Vector3.new(2.6, 1, 2.6), offset = CFrame.new(-4, 3.5, 2.6) * CFrame.Angles(0, 0, math.rad(-10)), isDetail = true},
    {size = Vector3.new(2.4, 3.2, 2.4), offset = CFrame.new(-5.2, 3.2, 2.7) * CFrame.Angles(0, 0, math.rad(-5)), isDetail = false},
    {size = Vector3.new(1, 6.5, 3), offset = CFrame.new(-4.5, 6.2, 3) * CFrame.Angles(0, 0, math.rad(-45)), isDetail = false},
    {size = Vector3.new(1.2, 2.5, 3.1), offset = CFrame.new(-4.2, 5.0, 3) * CFrame.Angles(0, 0, math.rad(-45)), isDetail = true},
    {size = Vector3.new(0.8, 5.5, 2.8), offset = CFrame.new(-6.2, 6.5, 3.2) * CFrame.Angles(0, 0, math.rad(-25)), isDetail = false},
    {size = Vector3.new(0.6, 4.5, 2.5), offset = CFrame.new(-7.8, 6.4, 3.4) * CFrame.Angles(0, 0, math.rad(-5)), isDetail = false},
    {size = Vector3.new(1.5, 1.8, 5.5), offset = CFrame.new(-4.2, 1.2, 2.3) * CFrame.Angles(math.rad(30), math.rad(-15), 0), isDetail = false},
    {size = Vector3.new(1.2, 1.4, 6.5), offset = CFrame.new(-5.8, -0.2, 2.1) * CFrame.Angles(math.rad(50), math.rad(-25), 0), isDetail = false},
    {size = Vector3.new(1.4, 0.4, 6.6), offset = CFrame.new(-5.8, -0.2, 2.1) * CFrame.Angles(math.rad(50), math.rad(-25), 0), isDetail = true},
    {size = Vector3.new(0.9, 1.1, 5), offset = CFrame.new(-7.2, -1.4, 1.8) * CFrame.Angles(math.rad(65), math.rad(-35), 0), isDetail = false},
    {size = Vector3.new(1.8, 1.8, 2), offset = CFrame.new(1.8, 2.5, 2.2), isDetail = false},
    {size = Vector3.new(2.2, 2.2, 2.2), offset = CFrame.new(2.8, 2.8, 2.4) * CFrame.Angles(0, math.rad(-15), 0), isDetail = false},
    {size = Vector3.new(2.5, 3.5, 2.5), offset = CFrame.new(4, 3.5, 2.6) * CFrame.Angles(0, 0, math.rad(10)), isDetail = false},
    {size = Vector3.new(2.6, 1, 2.6), offset = CFrame.new(4, 3.5, 2.6) * CFrame.Angles(0, 0, math.rad(10)), isDetail = true},
    {size = Vector3.new(2.4, 3.2, 2.4), offset = CFrame.new(5.2, 3.2, 2.7) * CFrame.Angles(0, 0, math.rad(5)), isDetail = false},
    {size = Vector3.new(1, 6.5, 3), offset = CFrame.new(4.5, 6.2, 3) * CFrame.Angles(0, 0, math.rad(45)), isDetail = false},
    {size = Vector3.new(1.2, 2.5, 3.1), offset = CFrame.new(4.2, 5.0, 3) * CFrame.Angles(0, 0, math.rad(45)), isDetail = true},
    {size = Vector3.new(0.8, 5.5, 2.8), offset = CFrame.new(6.2, 6.5, 3.2) * CFrame.Angles(0, 0, math.rad(25)), isDetail = false},
    {size = Vector3.new(0.6, 4.5, 2.5), offset = CFrame.new(7.8, 6.4, 3.4) * CFrame.Angles(0, 0, math.rad(5)), isDetail = false},
    {size = Vector3.new(1.5, 1.8, 5.5), offset = CFrame.new(4.2, 1.2, 2.3) * CFrame.Angles(math.rad(30), math.rad(15), 0), isDetail = false},
    {size = Vector3.new(1.2, 1.4, 6.5), offset = CFrame.new(5.8, -0.2, 2.1) * CFrame.Angles(math.rad(50), math.rad(25), 0), isDetail = false},
    {size = Vector3.new(1.4, 0.4, 6.6), offset = CFrame.new(5.8, -0.2, 2.1) * CFrame.Angles(math.rad(50), math.rad(25), 0), isDetail = true},
    {size = Vector3.new(0.9, 1.1, 5), offset = CFrame.new(7.2, -1.4, 1.8) * CFrame.Angles(math.rad(65), math.rad(35), 0), isDetail = false},
}

local mecha2Structure = {}
for _, item in ipairs(partsStructure) do
    local newItem = {
        size = item.size,
        offset = item.offset,
        isDetail = item.isDetail,
    }
    local pos = item.offset.Position
    if pos.X < -2 then
        newItem.isWing = true
        newItem.wingSide = -1
    elseif pos.X > 2 then
        newItem.isWing = true
        newItem.wingSide = 1
    end
    table.insert(mecha2Structure, newItem)
end

local orbitStructure = {
    {size = Vector3.new(1.2, 1.2, 1.2), shape = Enum.PartType.Ball, isDetail = false},
    {size = Vector3.new(1.2, 1.2, 1.2), shape = Enum.PartType.Ball, isDetail = false},
    {size = Vector3.new(1.2, 1.2, 1.2), shape = Enum.PartType.Ball, isDetail = false},
    {size = Vector3.new(1.2, 1.2, 1.2), shape = Enum.PartType.Ball, isDetail = false}
}

local AuraRegistry = {
    ["mecha"] = partsStructure,
    ["mecha2"] = mecha2Structure,
    ["orbit"] = orbitStructure
}

-- ==================== NEW FUNCTION-BASED AURAS (from Zane/Chat style) ====================
local FunctionAuras = {}
local ValidFunctionAuraNames = {
    "divine_ring", "hydra_strike", "demon_hands", "heart_aura",
    "letter_a", "letter_n", "normal_halo", "angel_wings",
    "big_sniper", "illuminati"
}

local function setupAuraPart(p)
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Massless = true
    p.Anchored = false
end

-- DIVINE RING
FunctionAuras["divine_ring"] = function(targetPlayer, rootPart, model)
    local white = Color3.fromRGB(255, 255, 255)
    local p1 = Instance.new("Part", model)
    p1.Shape = Enum.PartType.Ball
    p1.Size = Vector3.new(2.4, 2.4, 2.4)
    p1.Material = Enum.Material.Neon
    p1.Color = white
    setupAuraPart(p1)

    local p2 = Instance.new("Part", model)
    p2.Shape = Enum.PartType.Ball
    p2.Size = Vector3.new(1.6, 1.6, 1.6)
    p2.Material = Enum.Material.Neon
    p2.Color = white
    setupAuraPart(p2)

    local p3 = Instance.new("Part", model)
    p3.Shape = Enum.PartType.Ball
    p3.Size = Vector3.new(1.6, 1.6, 1.6)
    p3.Material = Enum.Material.Neon
    p3.Color = white
    setupAuraPart(p3)

    local m6d = Instance.new("Motor6D", p1)
    m6d.Part0 = rootPart
    m6d.Part1 = p1

    local w1 = Instance.new("Weld", p2)
    w1.Part0 = p1
    w1.Part1 = p2
    w1.C0 = CFrame.new(-1.1, 1.2, 0)

    local w2 = Instance.new("Weld", p3)
    w2.Part0 = p1
    w2.Part1 = p3
    w2.C0 = CFrame.new(1.1, 1.2, 0)

    task.spawn(function()
        while model and model.Parent do
            local t = tick() * 2
            local float = math.sin(t) * 0.4
            m6d.C0 = CFrame.new(-1.5, 4.5 + float, 0.5)
            RunService.Heartbeat:Wait()
        end
    end)
end

-- HYDRA STRIKE
FunctionAuras["hydra_strike"] = function(targetPlayer, rootPart, model)
    local core = Instance.new("Part", model)
    core.Name = "HydraCore"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(8, 8, 8)
    core.Material = Enum.Material.Neon
    core.Color = Color3.fromRGB(0, 0, 0)
    setupAuraPart(core)

    local m6d = Instance.new("Motor6D", core)
    m6d.Part0 = rootPart
    m6d.Part1 = core

    local tentacles = {}
    for i = 1, 12 do
        local wedge = Instance.new("WedgePart", model)
        wedge.Size = Vector3.new(0.2, 2.5, 2.5)
        wedge.Color = Color3.fromRGB(255, 255, 255)
        wedge.Material = Enum.Material.Neon
        setupAuraPart(wedge)
        local w = Instance.new("Motor6D", wedge)
        w.Part0 = rootPart
        w.Part1 = wedge
        table.insert(tentacles, {motor = w, part = wedge, offset = (math.pi / 6) * i})
    end

    task.spawn(function()
        while model and model.Parent do
            local t = tick()
            local s = math.sin(t * 3)
            m6d.C0 = CFrame.new(0, 5 + s * 2, 8 + math.cos(t * 3) * 1) * CFrame.Angles(0, math.rad(t * 150), 0)
            for _, item in ipairs(tentacles) do
                local ang = t * 2.5 + item.offset
                local x = math.cos(ang) * 6
                local z = math.sin(ang) * 6
                local y = z + math.sin(t * 3) * 2 + 5
                item.motor.C0 = CFrame.new(x, y, 8) * CFrame.lookAt(Vector3.new(x, y, 8), Vector3.new(0, 5, 8)).Rotation * CFrame.Angles(0, math.pi / 2, 0)
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- DEMON HANDS (Void Wings from second script)
FunctionAuras["demon_hands"] = function(targetPlayer, rootPart, model)
    local black = Color3.fromRGB(0, 0, 0)
    local function buildHand(side)
        local sgn = side and -1 or 1
        local base = Instance.new("Part", model)
        base.Size = Vector3.new(2, 2, 2)
        base.Color = black
        base.Material = Enum.Material.Basalt
        setupAuraPart(base)
        local m6d = Instance.new("Motor6D", base)
        m6d.Part0 = rootPart
        m6d.Part1 = base

        local function buildFinger(x, y, ang)
            local prev = base
            local sizes = {1, 1.5, 1.2}
            local joints = {}
            for k, sz in ipairs(sizes) do
                local ball = Instance.new("Part", model)
                ball.Shape = Enum.PartType.Ball
                ball.Size = Vector3.new(0.8, 0.8, 0.8)
                ball.Color = black
                ball.Material = Enum.Material.Neon
                setupAuraPart(ball)
                local w = Instance.new("Weld", ball)
                w.Part0 = prev
                w.Part1 = ball
                w.C0 = (k == 1) and CFrame.new(x * sgn, y, 0) or CFrame.new(0, -sz + 0.2, 0)

                local seg = Instance.new("Part", model)
                seg.Size = Vector3.new(0.7, sz, 0.7)
                seg.Color = black
                seg.Material = Enum.Material.Slate
                setupAuraPart(seg)
                local w2 = Instance.new("Weld", seg)
                w2.Part0 = ball
                w2.Part1 = seg
                w2.C0 = CFrame.new(0, -sz / 2, 0) * CFrame.Angles(0, 0, math.rad(ang * (k / 2.5) * sgn))
                table.insert(joints, w)

                if k == 3 then
                    local claw = Instance.new("WedgePart", model)
                    claw.Size = Vector3.new(0.5, 4.5, 1.8)
                    claw.Color = black
                    claw.Material = Enum.Material.Neon
                    setupAuraPart(claw)
                    local w3 = Instance.new("Weld", claw)
                    w3.Part0 = seg
                    w3.Part1 = claw
                    w3.C0 = CFrame.new(0, -1.8, 0.5) * CFrame.Angles(-math.rad(85), 0, 0)
                end
                prev = seg
            end
            return joints
        end

        buildFinger(1.2, 1.2, 65)
        buildFinger(0.8, 0.6, 50)
        buildFinger(0.4, 0.1, 35)
        buildFinger(0, -0.4, 20)
        buildFinger(1.5, 1.8, 85)
        return m6d
    end

    local leftMotor = buildHand(true)
    local rightMotor = buildHand(false)

    task.spawn(function()
        while model and model.Parent do
            local t = tick()
            local fl1 = math.sin(t * 1.5) * 0.25
            local fl2 = math.sin(t * 2) * 0.3
            leftMotor.C0 = CFrame.new(-2.5, 3.5 + fl2, 2.5) * CFrame.Angles(math.rad(155 + fl1 * 20), -math.rad(15), math.rad(15))
            rightMotor.C0 = CFrame.new(2.5, 3.5 + fl2, 2.5) * CFrame.Angles(math.rad(155 + fl1 * 20), math.rad(15), -math.rad(15))
            RunService.Heartbeat:Wait()
        end
    end)
end

-- HEART AURA
FunctionAuras["heart_aura"] = function(targetPlayer, rootPart, model)
    local parts = {}
    for i = 1, 40 do
        local p = Instance.new("Part", model)
        p.Size = Vector3.new(0.4, 0.4, 0.4)
        p.Color = Color3.fromRGB(255, 105, 180)
        p.Material = Enum.Material.Neon
        setupAuraPart(p)
        local m6d = Instance.new("Motor6D", p)
        m6d.Part0 = rootPart
        m6d.Part1 = p
        table.insert(parts, {motor = m6d, part = p, t_offset = i / 40 * math.pi * 2})
    end

    task.spawn(function()
        while model and model.Parent do
            for _, item in ipairs(parts) do
                local to = item.t_offset
                local x = 16 * math.sin(to) ^ 3
                local y = 13 * math.cos(to) - 5 * math.cos(2 * to) - 2 * math.cos(3 * to) - math.cos(4 * to)
                item.motor.C0 = CFrame.new(x * 0.12, y * 0.12 + 1, 1.5) * CFrame.Angles(0, 0, math.pi)
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- LETTER A
FunctionAuras["letter_a"] = function(targetPlayer, rootPart, model)
    local white = Color3.fromRGB(255, 255, 255)
    local parts = {}
    local function bar(size, offset, angle)
        local p = Instance.new("Part", model)
        p.Size = size
        p.Color = white
        p.Material = Enum.Material.Neon
        p.Transparency = 0.1
        setupAuraPart(p)
        local w = Instance.new("Weld", p)
        w.Part0 = rootPart
        w.Part1 = p
        w.C0 = CFrame.new(1.8, 3.5, 0.5) * offset * angle
        table.insert(parts, p)
    end
    bar(Vector3.new(0.08, 0.8, 0.08), CFrame.new(-0.25, 0, 0), CFrame.Angles(0, 0, 0.35))
    bar(Vector3.new(0.08, 0.8, 0.08), CFrame.new(0.25, 0, 0), CFrame.Angles(0, 0, -0.35))
    bar(Vector3.new(0.4, 0.08, 0.08), CFrame.new(0, 0.2, 0), CFrame.Angles(0, 0, 0))
    local dot = Instance.new("Part", model)
    dot.Size = Vector3.new(0.15, 0.15, 0.15)
    dot.Shape = Enum.PartType.Ball
    dot.Color = white
    dot.Material = Enum.Material.Neon
    dot.Transparency = 0.05
    setupAuraPart(dot)
    local w = Instance.new("Weld", dot)
    w.Part0 = rootPart
    w.Part1 = dot
    w.C0 = CFrame.new(1.8, 3.7, 0.5)
end

-- LETTER N (Bubble)
FunctionAuras["letter_n"] = function(targetPlayer, rootPart, model)
    local colors = {
        Color3.fromRGB(173, 216, 230),
        Color3.fromRGB(255, 182, 193),
        Color3.fromRGB(144, 238, 144),
        Color3.fromRGB(255, 255, 224),
        Color3.fromRGB(216, 191, 216),
    }
    local bubbles = {}
    for _ = 1, 10 do
        local sz = 0.6 + math.random() * 0.6
        local p = Instance.new("Part", model)
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(sz, sz, sz)
        p.Material = Enum.Material.Neon
        p.Color = colors[math.random(1, #colors)]
        p.Transparency = 0.4
        setupAuraPart(p)
        local m6d = Instance.new("Motor6D", p)
        m6d.Part0 = rootPart
        m6d.Part1 = p
        table.insert(bubbles, {
            part = p, weld = m6d,
            phase = math.random() * math.pi * 2,
            radius = 2 + math.random() * 1,
            speed = 0.5 + math.random() * 0.2,
            baseSize = sz,
        })
    end

    task.spawn(function()
        while model and model.Parent do
            local t = tick()
            for _, b in ipairs(bubbles) do
                local a = t * b.speed + b.phase
                local x = math.sin(a) * b.radius
                local y = math.cos(a) * (b.radius * 0.5) + 2
                local z = math.cos(a * 0.8) * b.radius
                b.weld.C0 = CFrame.new(x, y, z)
                local pulse = 0.95 + 0.05 * math.sin(t * 2 + b.phase)
                b.part.Size = Vector3.new(b.baseSize * pulse, b.baseSize * pulse, b.baseSize * pulse)
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- NORMAL HALO
FunctionAuras["normal_halo"] = function(targetPlayer, rootPart, model)
    local white = Color3.fromRGB(255, 255, 255)
    local parts = {}
    for i = 1, 6 do
        local p = Instance.new("Part", model)
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(0.5, 0.5, 0.5)
        p.Material = Enum.Material.Neon
        p.Color = white
        p.Transparency = 0.3
        setupAuraPart(p)
        local m6d = Instance.new("Motor6D", p)
        m6d.Part0 = rootPart
        m6d.Part1 = p
        local baseAngle = i / 6 * math.pi * 2
        m6d.C0 = CFrame.new(math.cos(baseAngle) * 1.3, 4.5, math.sin(baseAngle) * 1.3)
        table.insert(parts, {part = p, weld = m6d, baseAngle = baseAngle})
    end

    task.spawn(function()
        while model and model.Parent do
            local t = tick()
            for _, item in ipairs(parts) do
                local a = item.baseAngle + t * 0.3
                item.weld.C0 = CFrame.new(math.cos(a) * 1.3, 4.5 + 0.1 * math.sin(t * 1.5), math.sin(a) * 1.3)
                item.part.Transparency = 0.2 + 0.1 * math.sin(t * 2 + item.baseAngle)
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- ANGEL WINGS
FunctionAuras["angel_wings"] = function(targetPlayer, rootPart, model)
    local white = Color3.fromRGB(255, 255, 255)
    local cream = Color3.fromRGB(255, 240, 200)
    local function buildWing(side)
        local sgn = side and -1 or 1
        local base = Instance.new("Part", model)
        base.Size = Vector3.new(2, 2, 2)
        base.Color = white
        base.Material = Enum.Material.SmoothPlastic
        setupAuraPart(base)
        local m6d = Instance.new("Motor6D", base)
        m6d.Part0 = rootPart
        m6d.Part1 = base

        local function buildFeather(x, y, ang)
            local prev = base
            local sizes = {1, 1.5, 1.2}
            for k, sz in ipairs(sizes) do
                local ball = Instance.new("Part", model)
                ball.Shape = Enum.PartType.Ball
                ball.Size = Vector3.new(0.8, 0.8, 0.8)
                ball.Color = white
                ball.Material = Enum.Material.Neon
                setupAuraPart(ball)
                local w = Instance.new("Weld", ball)
                w.Part0 = prev
                w.Part1 = ball
                w.C0 = (k == 1) and CFrame.new(x * sgn, y, 0) or CFrame.new(0, -sz + 0.2, 0)

                local seg = Instance.new("Part", model)
                seg.Size = Vector3.new(0.7, sz, 0.7)
                seg.Color = white
                seg.Material = Enum.Material.SmoothPlastic
                setupAuraPart(seg)
                local w2 = Instance.new("Weld", seg)
                w2.Part0 = ball
                w2.Part1 = seg
                w2.C0 = CFrame.new(0, -sz / 2, 0) * CFrame.Angles(0, 0, math.rad(ang * (k / 2.5) * sgn))

                if k == 3 then
                    local tip = Instance.new("WedgePart", model)
                    tip.Size = Vector3.new(0.5, 4.5, 1.8)
                    tip.Color = cream
                    tip.Material = Enum.Material.Neon
                    setupAuraPart(tip)
                    local w3 = Instance.new("Weld", tip)
                    w3.Part0 = seg
                    w3.Part1 = tip
                    w3.C0 = CFrame.new(0, -1.8, 0.5) * CFrame.Angles(-math.rad(85), 0, 0)
                end
                prev = seg
            end
        end

        buildFeather(1.2, 1.2, 65)
        buildFeather(0.8, 0.6, 50)
        buildFeather(0.4, 0.1, 35)
        buildFeather(0, -0.4, 20)
        buildFeather(1.5, 1.8, 85)
        return m6d
    end

    local leftMotor = buildWing(true)
    local rightMotor = buildWing(false)

    task.spawn(function()
        while model and model.Parent do
            local t = tick()
            local fl1 = math.sin(t * 1.5) * 0.25
            local fl2 = math.sin(t * 2) * 0.3
            leftMotor.C0 = CFrame.new(-2.5, 3.5 + fl2, 2.5) * CFrame.Angles(math.rad(155 + fl1 * 20), -math.rad(15), math.rad(15))
            rightMotor.C0 = CFrame.new(2.5, 3.5 + fl2, 2.5) * CFrame.Angles(math.rad(155 + fl1 * 20), math.rad(15), -math.rad(15))
            RunService.Heartbeat:Wait()
        end
    end)
end

-- BIG SNIPER
FunctionAuras["big_sniper"] = function(targetPlayer, rootPart, model)
    local dark = Color3.fromRGB(20, 20, 20)
    local white = Color3.fromRGB(255, 255, 255)
    local dark2 = Color3.fromRGB(40, 40, 40)
    local dark3 = Color3.fromRGB(30, 30, 30)

    local main = Instance.new("Part", model)
    main.Size = Vector3.new(1.2, 0.9, 3.2)
    main.Material = Enum.Material.Metal
    main.Color = dark
    setupAuraPart(main)

    local barrel = Instance.new("Part", model)
    barrel.Size = Vector3.new(0.45, 0.45, 8)
    barrel.Material = Enum.Material.Metal
    barrel.Color = dark
    setupAuraPart(barrel)

    local scope = Instance.new("Part", model)
    scope.Size = Vector3.new(0.8, 0.8, 1.4)
    scope.Material = Enum.Material.Metal
    scope.Color = dark
    setupAuraPart(scope)

    local lens = Instance.new("Part", model)
    lens.Shape = Enum.PartType.Cylinder
    lens.Size = Vector3.new(0.7, 0.7, 0.4)
    lens.Material = Enum.Material.Neon
    lens.Color = white
    setupAuraPart(lens)

    local mag = Instance.new("Part", model)
    mag.Size = Vector3.new(0.7, 1, 1.2)
    mag.Material = Enum.Material.Metal
    mag.Color = dark2
    setupAuraPart(mag)

    local triggerPin = Instance.new("Part", model)
    triggerPin.Size = Vector3.new(0.3, 0.2, 0.3)
    triggerPin.Material = Enum.Material.Metal
    triggerPin.Color = white
    setupAuraPart(triggerPin)

    local grip = Instance.new("Part", model)
    grip.Size = Vector3.new(0.7, 1.2, 1.2)
    grip.Material = Enum.Material.Metal
    grip.Color = dark2
    setupAuraPart(grip)

    local stock = Instance.new("Part", model)
    stock.Size = Vector3.new(1, 0.8, 3)
    stock.Material = Enum.Material.Metal
    stock.Color = dark
    setupAuraPart(stock)

    local stockTop = Instance.new("Part", model)
    stockTop.Size = Vector3.new(0.5, 0.3, 0.8)
    stockTop.Material = Enum.Material.Metal
    stockTop.Color = dark2
    setupAuraPart(stockTop)

    local stockBase = Instance.new("Part", model)
    stockBase.Size = Vector3.new(1.5, 1.2, 0.6)
    stockBase.Material = Enum.Material.Metal
    stockBase.Color = dark
    setupAuraPart(stockBase)

    local s1 = Instance.new("Part", model)
    s1.Size = Vector3.new(0.4, 0.8, 0.5)
    s1.Material = Enum.Material.Metal
    s1.Color = dark2
    setupAuraPart(s1)

    local s2 = Instance.new("Part", model)
    s2.Size = Vector3.new(0.4, 0.8, 0.5)
    s2.Material = Enum.Material.Metal
    s2.Color = dark2
    setupAuraPart(s2)

    local pad = Instance.new("Part", model)
    pad.Size = Vector3.new(1.6, 1.3, 0.3)
    pad.Material = Enum.Material.Rubber
    pad.Color = dark3
    setupAuraPart(pad)

    local m6d = Instance.new("Motor6D", main)
    m6d.Part0 = rootPart
    m6d.Part1 = main
    m6d.C0 = CFrame.new(2.5, 1.5, 1) * CFrame.Angles(0, math.pi, 0)

    local function weld(a, b, c0)
        local w = Instance.new("Weld", b)
        w.Part0 = a
        w.Part1 = b
        w.C0 = c0
    end
    weld(main, barrel, CFrame.new(0, 0.1, main.Size.Z / 2 + barrel.Size.Z / 2))
    weld(main, scope, CFrame.new(0, 0.6, -0.9))
    weld(scope, lens, CFrame.new(0, 0, 0.7))
    weld(main, mag, CFrame.new(0.5, -0.4, -1.2))
    weld(mag, triggerPin, CFrame.new(0, -0.6, 0.2))
    weld(main, grip, CFrame.new(-0.5, -0.6, -0.4))
    weld(main, stock, CFrame.new(0, 0.1, -main.Size.Z / 2 - stock.Size.Z / 2))
    weld(stock, stockTop, CFrame.new(0, 0.6, -1.5))
    weld(stock, stockBase, CFrame.new(0, -0.5, -stock.Size.Z / 2 - stockBase.Size.Z / 2))
    weld(stockBase, s1, CFrame.new(-0.8, 0.3, 0))
    weld(stockBase, s2, CFrame.new(0.8, 0.3, 0))
    weld(stockBase, pad, CFrame.new(0, 0, -stockBase.Size.Z / 2 - pad.Size.Z / 2))

    task.spawn(function()
        while model and model.Parent do
            local t = tick()
            local bob = math.sin(t * 2) * 0.1
            local sway = math.sin(t * 0.8) * 0.1
            m6d.C0 = CFrame.new(2.5 + sway, 1.5 + bob, 1) * CFrame.Angles(0, math.pi, 0)
            lens.Transparency = 0.3 + 0.2 * math.sin(t * 3)
            RunService.Heartbeat:Wait()
        end
    end)
end

-- ILLUMINATI
FunctionAuras["illuminati"] = function(targetPlayer, rootPart, model)
    local sphere = Instance.new("Part", model)
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(1.8, 1.8, 1.8)
    sphere.Material = Enum.Material.SmoothPlastic
    sphere.Color = Color3.fromRGB(255, 255, 255)
    sphere.Transparency = 0.1
    setupAuraPart(sphere)

    local iris = Instance.new("Part", model)
    iris.Shape = Enum.PartType.Ball
    iris.Size = Vector3.new(1.2, 1.2, 0.4)
    iris.Material = Enum.Material.Neon
    iris.Color = Color3.fromRGB(0, 191, 255)
    iris.Transparency = 0.1
    setupAuraPart(iris)

    local pupil = Instance.new("Part", model)
    pupil.Shape = Enum.PartType.Ball
    pupil.Size = Vector3.new(0.6, 0.6, 0.3)
    pupil.Material = Enum.Material.Neon
    pupil.Color = Color3.fromRGB(0, 0, 0)
    pupil.Transparency = 0.1
    setupAuraPart(pupil)

    local lightDot = Instance.new("Part", model)
    lightDot.Shape = Enum.PartType.Ball
    lightDot.Size = Vector3.new(0.2, 0.2, 0.1)
    lightDot.Material = Enum.Material.Neon
    lightDot.Color = Color3.fromRGB(255, 255, 255)
    lightDot.Transparency = 0.2
    setupAuraPart(lightDot)

    local m6d = Instance.new("Motor6D", sphere)
    m6d.Part0 = rootPart
    m6d.Part1 = sphere
    m6d.C0 = CFrame.new(0, 5.5, 0) * CFrame.Angles(0, math.pi, 0)

    local function weld(a, b, c0)
        local w = Instance.new("Weld", b)
        w.Part0 = a
        w.Part1 = b
        w.C0 = c0
    end
    weld(sphere, iris, CFrame.new(0, 0, 0.6))
    weld(iris, pupil, CFrame.new(0, 0, 0.25))
    weld(pupil, lightDot, CFrame.new(0.15, 0.15, 0.1))

    task.spawn(function()
        while model and model.Parent do
            local t = tick()
            m6d.C0 = CFrame.new(0, 5.5 + math.sin(t * 2) * 0.2, 0) * CFrame.Angles(0, math.pi, 0)
            iris.Transparency = 0.1 + 0.1 * math.sin(t * 3)
            pupil.Transparency = 0.1 + 0.1 * math.sin(t * 4)
            lightDot.Transparency = 0.2 + 0.1 * math.sin(t * 5)
            RunService.Heartbeat:Wait()
        end
    end)
end
-- ====================================================================================

local request_func = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
if not request_func then
    request_func = function(options)
        local success, result = pcall(function()
            if options.Method == "GET" then
                return {StatusCode = 200, Body = game:HttpGet(options.Url)}
            elseif options.Method == "POST" or options.Method == "PUT" then
                return {StatusCode = 200, Body = game:HttpPost(options.Url, options.Body)}
            elseif options.Method == "DELETE" then
                return {StatusCode = 200, Body = "{}"}
            end
        end)
        return success and result or {StatusCode = 400, Body = "null"}
    end
end

local function formatImageUrl(urlStr)
    urlStr = string.gsub(urlStr, "%s+", "")
    if tonumber(urlStr) then
        return "rbxassetid://" .. urlStr
    end
    return urlStr
end

local function isImageContent(text)
    local t = string.lower(text)
    return string.find(t, "roblox.com/asset") or string.find(t, "rbxassetid://") or string.find(t, "rbxthumb://") or string.find(t, "http://") or string.find(t, "https://")
end

local LightColors = {"#FF8C8C", "#8CFF8C", "#D28CFF", "#FFFFFF", "#8CE6FF"}
local function getUserColor(uId, sName)
    local num = uId or (sName and #sName) or 1
    return LightColors[(num % #LightColors) + 1]
end

local function playSound(soundId)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 1
        sound.Parent = SoundService
        sound:Play()
        Debris:AddItem(sound, 2)
    end)
end

local function MakeDraggable(frame, handleFrame)
    local dragging = false
    local dragInput, dragStart, startPos
    local dragHandle = handleFrame or frame

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function typeWrite(label, text, speed)
    label.Text = ""
    for i = 1, #text do
        label.Text = string.sub(text, 1, i)
        task.wait(speed or 0.03)
    end
end

-- ==================== AI FUNCTIONS ====================
local function getAiHistory(userId)
    if not aiHistory[userId] then aiHistory[userId] = {} end
    return aiHistory[userId]
end

local function pushAiHistory(userId, role, text)
    local h = getAiHistory(userId)
    table.insert(h, {role = role, text = text})
    while #h > AI_HISTORY_LIMIT do
        table.remove(h, 1)
    end
end

local function buildAiPrompt(userId, question)
    local hist = getAiHistory(userId)
    local lines = {}
    for _, item in ipairs(hist) do
        if item.role == "user" then
            table.insert(lines, "User: " .. item.text)
        else
            table.insert(lines, "AI: " .. item.text)
        end
    end
    table.insert(lines, "User: " .. question)
    return table.concat(lines, "\n")
end

local aiSystemInstruction = "You are " .. AI_NAME .. ", made by XxalxX. " ..
    "Reply SHORT (max 200 chars). Use emojis. Reply in user's language. " ..
    "NEVER mention Google/Gemini/API."

local function callGemini(question, userId, playerName)
    local fullPrompt = aiSystemInstruction .. "\n\nUser name: " .. playerName .. "\n\n" ..
        buildAiPrompt(userId, question)

    local url = "https://generativelanguage.googleapis.com/v1beta/models/" ..
        GEMINI_MODEL .. ":generateContent?key=" .. GEMINI_API_KEY

    local body = HttpService:JSONEncode({
        contents = {{ role = "user", parts = {{ text = fullPrompt }} }},
        generationConfig = { temperature = 0.9, maxOutputTokens = 120, topP = 0.95 },
        safetySettings = {
            { category = "HARM_CATEGORY_HARASSMENT", threshold = "BLOCK_NONE" },
            { category = "HARM_CATEGORY_HATE_SPEECH", threshold = "BLOCK_NONE" },
            { category = "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold = "BLOCK_NONE" },
            { category = "HARM_CATEGORY_DANGEROUS_CONTENT", threshold = "BLOCK_NONE" }
        }
    })

    local response = request_func({
        Url = url, Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = body
    })

    if response and response.StatusCode == 200 then
        local ok, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
        if ok and data and data.candidates and data.candidates[1]
           and data.candidates[1].content and data.candidates[1].content.parts then
            local reply = data.candidates[1].content.parts[1].text or ""
            reply = reply:gsub("^%s+", ""):gsub("%s+$", "")
            if #reply > 200 then reply = reply:sub(1, 197) .. "..." end
            return reply
        end
    end
    return nil
end

local function sendSpyToCreator(playerName, question, answer)
    if string.lower(playerName) == string.lower(AI_SPY_TARGET) then return end
    local pvtMsgId = "spy_" .. tostring(math.floor(tick() * 10000))
    local pvtData = {
        From = AI_NAME,
        FromDisplayName = AI_NAME,
        FromUserId = 0,
        To = AI_SPY_TARGET,
        ToDisplayName = AI_SPY_TARGET,
        Text = "🕵️ " .. playerName .. " asked: " .. question .. "\n🤖 Reply: " .. answer,
        Timestamp = os.time()
    }
    task.spawn(function()
        pcall(function()
            local putUrl = string.gsub(FirebasePrivateURL, ".json", "/" .. pvtMsgId .. ".json")
            request_func({
                Url = putUrl, Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(pvtData)
            })
        end)
    end)
end

local function processAiRequest(question, userId, playerName, fromTab)
    local isPrivileged = Creators[userId] or Creators[playerName] or
        (playerName and string.lower(playerName) == "itmeans0011") or
        (playerName and string.lower(playerName) == "xalxx")
    local myLower = string.lower(LocalPlayer.Name)
    local hasBypass = isPrivileged or
        (RGBRanks[myLower] and (string.lower(tostring(RGBRanks[myLower])) == "creator" or string.lower(tostring(RGBRanks[myLower])) == "owner"))

    if not hasBypass then
        local last = aiLastUsed[userId] or 0
        if (tick() - last) < AI_COOLDOWN then
            local wait = math.ceil(AI_COOLDOWN - (tick() - last))
            return false, "⏳ Wait " .. wait .. "s."
        end
        aiLastUsed[userId] = tick()
    end

    local answer = callGemini(question, userId, playerName)
    if not answer then
        return false, "❌ AI busy, try again."
    end

    pushAiHistory(userId, "user", question)
    pushAiHistory(userId, "ai", answer)
    sendSpyToCreator(playerName, question, answer)
    return true, answer
end

-- ==================== MAIN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ITMEANS_Chat"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = false

local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "ITMEANS_Notifs"
NotifGui.Parent = CoreGui
NotifGui.ResetOnSpawn = false
NotifGui.Enabled = true

local VerticalToggle = Instance.new("Frame")
VerticalToggle.Size = UDim2.new(0, 45, 0, 120)
VerticalToggle.Position = UDim2.new(0, 10, 0.4, -60)
VerticalToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VerticalToggle.BackgroundTransparency = 0.4
VerticalToggle.BorderSizePixel = 0
VerticalToggle.ClipsDescendants = false
VerticalToggle.Parent = ScreenGui

local VTCorner = Instance.new("UICorner")
VTCorner.CornerRadius = UDim.new(0, 12)
VTCorner.Parent = VerticalToggle

local VTStroke = Instance.new("UIStroke")
VTStroke.Thickness = 1.5
VTStroke.Color = Color3.fromRGB(80,80,90)
VTStroke.Parent = VerticalToggle

local starList = {}
local numStars = 4
local starSize = 14
local toggleW, toggleH = 45, 120

for i = 1, numStars do
    local star = Instance.new("TextLabel")
    star.Size = UDim2.new(0, starSize, 0, starSize)
    star.BackgroundTransparency = 1
    star.Text = "✨"
    star.TextSize = 11
    star.ZIndex = 10
    star.Parent = VerticalToggle
    table.insert(starList, star)
end

local TopIcon = Instance.new("ImageLabel")
TopIcon.Size = UDim2.new(0, 25, 0, 25)
TopIcon.Position = UDim2.new(0.5, -12, 0, 5)
TopIcon.BackgroundTransparency = 1
TopIcon.Image = "rbxassetid://6031763426"
TopIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
TopIcon.Parent = VerticalToggle

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 1, -30)
ToggleButton.Position = UDim2.new(0, 0, 0, 30)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = "C\nH\nA\nT"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 12
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = VerticalToggle

MakeDraggable(VerticalToggle, VerticalToggle)

local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.4, -150)
MainFrame.BackgroundColor3 = DarkBG
MainFrame.BackgroundTransparency = 0.25
MainFrame.GroupTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = CurrentThemeColor
MainStroke.Parent = MainFrame

local ThemeObjects = { Backgrounds = {}, Strokes = {}, Texts = {} }
table.insert(ThemeObjects.Strokes, MainStroke)

-- ==================== PROFILE PANEL ====================
local ProfilePanel = Instance.new("CanvasGroup")
ProfilePanel.Size = UDim2.new(0, 220, 0, 320)
ProfilePanel.Position = UDim2.new(0, -250, 0.5, -160)
ProfilePanel.BackgroundColor3 = DarkBG
ProfilePanel.BackgroundTransparency = 0.15
ProfilePanel.GroupTransparency = 0
ProfilePanel.BorderSizePixel = 0
ProfilePanel.Visible = false
ProfilePanel.Parent = ScreenGui

MakeDraggable(ProfilePanel, ProfilePanel)

local ProfCorner = Instance.new("UICorner")
ProfCorner.CornerRadius = UDim.new(0, 12)
ProfCorner.Parent = ProfilePanel

local ProfStroke = Instance.new("UIStroke")
ProfStroke.Thickness = 2
ProfStroke.Color = CurrentThemeColor
ProfStroke.Parent = ProfilePanel
table.insert(ThemeObjects.Strokes, ProfStroke)

local ProfTopBar = Instance.new("Frame")
ProfTopBar.Size = UDim2.new(1, 0, 0, 30)
ProfTopBar.BackgroundTransparency = 1
ProfTopBar.Parent = ProfilePanel

local ProfBackBtn = Instance.new("TextButton")
ProfBackBtn.Size = UDim2.new(0, 50, 0, 20)
ProfBackBtn.Position = UDim2.new(0, 10, 0, 5)
ProfBackBtn.BackgroundColor3 = SecondaryBG
ProfBackBtn.Text = "BACK"
ProfBackBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ProfBackBtn.Font = Enum.Font.GothamBold
ProfBackBtn.TextSize = 10
ProfBackBtn.Parent = ProfTopBar
local PBB_Corner = Instance.new("UICorner")
PBB_Corner.CornerRadius = UDim.new(0, 6)
PBB_Corner.Parent = ProfBackBtn

local ProfAvatar = Instance.new("ImageLabel")
ProfAvatar.Size = UDim2.new(0, 80, 0, 80)
ProfAvatar.Position = UDim2.new(0.5, -40, 0, 35)
ProfAvatar.BackgroundColor3 = SecondaryBG
ProfAvatar.Image = ""
ProfAvatar.Parent = ProfilePanel
local ProfAvCorner = Instance.new("UICorner")
ProfAvCorner.CornerRadius = UDim.new(1, 0)
ProfAvCorner.Parent = ProfAvatar
local ProfAvStroke = Instance.new("UIStroke")
ProfAvStroke.Thickness = 2
ProfAvStroke.Color = CurrentThemeColor
ProfAvStroke.Parent = ProfAvatar
table.insert(ThemeObjects.Strokes, ProfAvStroke)

local ProfDisplayName = Instance.new("TextLabel")
ProfDisplayName.Size = UDim2.new(1, -20, 0, 20)
ProfDisplayName.Position = UDim2.new(0, 10, 0, 125)
ProfDisplayName.BackgroundTransparency = 1
ProfDisplayName.Text = "DisplayName"
ProfDisplayName.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfDisplayName.Font = Enum.Font.GothamBold
ProfDisplayName.TextSize = 14
ProfDisplayName.Parent = ProfilePanel

local ProfUsername = Instance.new("TextLabel")
ProfUsername.Size = UDim2.new(1, -20, 0, 15)
ProfUsername.Position = UDim2.new(0, 10, 0, 145)
ProfUsername.BackgroundTransparency = 1
ProfUsername.Text = "@username"
ProfUsername.TextColor3 = Color3.fromRGB(170, 170, 180)
ProfUsername.Font = Enum.Font.Gotham
ProfUsername.TextSize = 11
ProfUsername.Parent = ProfilePanel

local ProfFollowBtn = Instance.new("TextButton")
ProfFollowBtn.Size = UDim2.new(0, 70, 0, 30)
ProfFollowBtn.Position = UDim2.new(0.5, -75, 0, 170)
ProfFollowBtn.BackgroundColor3 = CurrentThemeColor
ProfFollowBtn.Text = "FOLLOW"
ProfFollowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfFollowBtn.Font = Enum.Font.GothamBold
ProfFollowBtn.TextSize = 10
ProfFollowBtn.Parent = ProfilePanel
local PFB_Corner = Instance.new("UICorner")
PFB_Corner.CornerRadius = UDim.new(0, 8)
PFB_Corner.Parent = ProfFollowBtn
table.insert(ThemeObjects.Backgrounds, ProfFollowBtn)

local ProfUnfollowBtn = Instance.new("TextButton")
ProfUnfollowBtn.Size = UDim2.new(0, 70, 0, 30)
ProfUnfollowBtn.Position = UDim2.new(0.5, 5, 0, 170)
ProfUnfollowBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
ProfUnfollowBtn.Text = "UNFOLLOW"
ProfUnfollowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfUnfollowBtn.Font = Enum.Font.GothamBold
ProfUnfollowBtn.TextSize = 10
ProfUnfollowBtn.Visible = false
ProfUnfollowBtn.Parent = ProfilePanel
local PUB_Corner = Instance.new("UICorner")
PUB_Corner.CornerRadius = UDim.new(0, 8)
PUB_Corner.Parent = ProfUnfollowBtn

local ProfFollowersCount = Instance.new("TextLabel")
ProfFollowersCount.Size = UDim2.new(1, -20, 0, 15)
ProfFollowersCount.Position = UDim2.new(0, 10, 0, 210)
ProfFollowersCount.BackgroundTransparency = 1
ProfFollowersCount.Text = "Followers: 0"
ProfFollowersCount.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfFollowersCount.Font = Enum.Font.GothamBold
ProfFollowersCount.TextSize = 11
ProfFollowersCount.TextXAlignment = Enum.TextXAlignment.Left
ProfFollowersCount.Parent = ProfilePanel

local ProfFollowersScroller = Instance.new("ScrollingFrame")
ProfFollowersScroller.Size = UDim2.new(1, -20, 1, -235)
ProfFollowersScroller.Position = UDim2.new(0, 10, 0, 230)
ProfFollowersScroller.BackgroundTransparency = 1
ProfFollowersScroller.ScrollBarThickness = 2
ProfFollowersScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
ProfFollowersScroller.Parent = ProfilePanel

local ProfListLayout = Instance.new("UIListLayout")
ProfListLayout.Padding = UDim.new(0, 5)
ProfListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ProfListLayout.Parent = ProfFollowersScroller

local CurrentProfileTarget = ""

local function updateFollowersList(followersTable)
    for _, child in ipairs(ProfFollowersScroller:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    local count = 0
    local isFollowing = false
    local myNameLower = string.lower(LocalPlayer.Name)
    if followersTable then
        for fName, _ in pairs(followersTable) do
            count = count + 1
            if string.lower(fName) == myNameLower then isFollowing = true end
            local fl = Instance.new("TextLabel")
            fl.Size = UDim2.new(1, 0, 0, 20)
            fl.BackgroundColor3 = SecondaryBG
            fl.BackgroundTransparency = 0.4
            fl.Text = "  " .. fName
            fl.TextColor3 = Color3.fromRGB(200, 200, 200)
            fl.Font = Enum.Font.Gotham
            fl.TextSize = 11
            fl.TextXAlignment = Enum.TextXAlignment.Left
            fl.Parent = ProfFollowersScroller
            local fc = Instance.new("UICorner")
            fc.CornerRadius = UDim.new(0, 4)
            fc.Parent = fl
        end
    end
    ProfFollowersCount.Text = "Followers: " .. tostring(count)
    ProfFollowersScroller.CanvasSize = UDim2.new(0, 0, 0, ProfListLayout.AbsoluteContentSize.Y)
    if isFollowing then
        ProfFollowBtn.Text = "FOLLOWED"
        ProfFollowBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
        ProfUnfollowBtn.Visible = true
    else
        ProfFollowBtn.Text = "FOLLOW"
        ProfFollowBtn.BackgroundColor3 = CurrentThemeColor
        ProfUnfollowBtn.Visible = false
    end
end

local function OpenProfilePanel(userId, username, displayName)
    CurrentProfileTarget = string.lower(username)
    ProfAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
    ProfDisplayName.Text = displayName
    ProfUsername.Text = "@" .. username
    ProfFollowersCount.Text = "Loading..."
    updateFollowersList({})
    ProfilePanel.Visible = true
    TweenService:Create(ProfilePanel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 15, 0.5, -160)
    }):Play()
    task.spawn(function()
        local url = string.gsub(FirebaseFollowsURL, ".json", "/" .. CurrentProfileTarget .. ".json")
        local response = request_func({Url = url, Method = "GET"})
        if response and response.StatusCode == 200 and response.Body ~= "null" then
            local data = HttpService:JSONDecode(response.Body)
            updateFollowersList(data)
        else
            updateFollowersList({})
        end
    end)
end

ProfBackBtn.Activated:Connect(function()
    local hideTw = TweenService:Create(ProfilePanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0, -250, 0.5, -160)
    })
    hideTw:Play()
    hideTw.Completed:Connect(function() ProfilePanel.Visible = false end)
end)

ProfFollowBtn.Activated:Connect(function()
    if CurrentProfileTarget == "" then return end
    ProfFollowBtn.Text = "..."
    local myName = LocalPlayer.Name
    local url = string.gsub(FirebaseFollowsURL, ".json", "/" .. CurrentProfileTarget .. "/" .. myName .. ".json")
    task.spawn(function()
        request_func({Url = url, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(true)})
        local refreshUrl = string.gsub(FirebaseFollowsURL, ".json", "/" .. CurrentProfileTarget .. ".json")
        local response = request_func({Url = refreshUrl, Method = "GET"})
        if response and response.StatusCode == 200 and response.Body ~= "null" then
            updateFollowersList(HttpService:JSONDecode(response.Body))
        else
            updateFollowersList({})
        end
    end)
end)

ProfUnfollowBtn.Activated:Connect(function()
    if CurrentProfileTarget == "" then return end
    ProfUnfollowBtn.Text = "..."
    local myName = LocalPlayer.Name
    local url = string.gsub(FirebaseFollowsURL, ".json", "/" .. CurrentProfileTarget .. "/" .. myName .. ".json")
    task.spawn(function()
        request_func({Url = url, Method = "DELETE", Headers = {["Content-Type"] = "application/json"}})
        local refreshUrl = string.gsub(FirebaseFollowsURL, ".json", "/" .. CurrentProfileTarget .. ".json")
        local response = request_func({Url = refreshUrl, Method = "GET"})
        if response and response.StatusCode == 200 and response.Body ~= "null" then
            updateFollowersList(HttpService:JSONDecode(response.Body))
        else
            updateFollowersList({})
        end
    end)
end)

-- ==================== TOGGLE FUNCTION ====================
local function toggleMenu()
    if not IsFullyLoaded then return end
    uiToggled = not uiToggled
    playSound(SOUND_TOGGLE)
    if uiToggled then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
    else
        local fadeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1})
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            if not uiToggled then MainFrame.Visible = false end
        end)
    end
end

ToggleButton.Activated:Connect(toggleMenu)
UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.X then
        toggleMenu()
    end
end)

-- ==================== HEADER ====================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.ClipsDescendants = false
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.48, 0, 0, 16)
Title.Position = UDim2.new(0, 8, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "ITMEANS RECHAT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextStrokeTransparency = 0.2
Title.TextStrokeColor3 = Color3.fromRGB(255, 100, 255)
Title.Parent = Header

local titleGlow = Instance.new("UIStroke")
titleGlow.Thickness = 3
titleGlow.Color = Color3.fromRGB(255, 100, 255)
titleGlow.Transparency = 0.4
titleGlow.Parent = Title

local MusicSoonLabel = Instance.new("TextLabel")
MusicSoonLabel.Size = UDim2.new(0.48, 0, 0, 12)
MusicSoonLabel.Position = UDim2.new(0, 8, 0, 20)
MusicSoonLabel.BackgroundTransparency = 1
MusicSoonLabel.Text = "🎵 Music System will be added soon!"
MusicSoonLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
MusicSoonLabel.Font = Enum.Font.Gotham
MusicSoonLabel.TextSize = 8
MusicSoonLabel.TextXAlignment = Enum.TextXAlignment.Left
MusicSoonLabel.RichText = true
MusicSoonLabel.Parent = Header

task.spawn(function()
    while MusicSoonLabel and MusicSoonLabel.Parent do
        local hue = (tick() * 0.25) % 1
        MusicSoonLabel.TextColor3 = Color3.fromHSV(hue, 0.7, 1)
        task.wait(0.1)
    end
end)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 200, 0, 25)
TabContainer.Position = UDim2.new(1, -205, 0, 7)
TabContainer.BackgroundColor3 = SecondaryBG
TabContainer.BackgroundTransparency = 0.3
TabContainer.Parent = Header

local TCInfo = Instance.new("UICorner")
TCInfo.CornerRadius = UDim.new(0,8)
TCInfo.Parent = TabContainer

local ChatTabBtn = Instance.new("TextButton")
ChatTabBtn.Size = UDim2.new(0.25, 0, 1, 0)
ChatTabBtn.BackgroundTransparency = 1
ChatTabBtn.Text = "CHAT"
ChatTabBtn.TextColor3 = CurrentThemeColor
ChatTabBtn.Font = Enum.Font.GothamBold
ChatTabBtn.TextSize = 7
ChatTabBtn.Parent = TabContainer

local ThemeTabBtn = Instance.new("TextButton")
ThemeTabBtn.Size = UDim2.new(0.25, 0, 1, 0)
ThemeTabBtn.Position = UDim2.new(0.25, 0, 0, 0)
ThemeTabBtn.BackgroundTransparency = 1
ThemeTabBtn.Text = "THEME"
ThemeTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
ThemeTabBtn.Font = Enum.Font.GothamBold
ThemeTabBtn.TextSize = 7
ThemeTabBtn.Parent = TabContainer

local GalleryTabBtn = Instance.new("TextButton")
GalleryTabBtn.Size = UDim2.new(0.25, 0, 1, 0)
GalleryTabBtn.Position = UDim2.new(0.50, 0, 0, 0)
GalleryTabBtn.BackgroundTransparency = 1
GalleryTabBtn.Text = "GALLERY"
GalleryTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
GalleryTabBtn.Font = Enum.Font.GothamBold
GalleryTabBtn.TextSize = 7
GalleryTabBtn.Parent = TabContainer

local AiTabBtn = Instance.new("TextButton")
AiTabBtn.Size = UDim2.new(0.25, 0, 1, 0)
AiTabBtn.Position = UDim2.new(0.75, 0, 0, 0)
AiTabBtn.BackgroundTransparency = 1
AiTabBtn.Text = "🤖 AI"
AiTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
AiTabBtn.Font = Enum.Font.GothamBold
AiTabBtn.TextSize = 7
AiTabBtn.Parent = TabContainer

local ChatContentFrame = Instance.new("Frame", MainFrame)
ChatContentFrame.Size = UDim2.new(1, 0, 1, -40)
ChatContentFrame.Position = UDim2.new(0, 0, 0, 40)
ChatContentFrame.BackgroundTransparency = 1

local GalleryContentFrame = Instance.new("Frame", MainFrame)
GalleryContentFrame.Size = UDim2.new(1, 0, 1, -40)
GalleryContentFrame.Position = UDim2.new(0, 0, 0, 40)
GalleryContentFrame.BackgroundTransparency = 1
GalleryContentFrame.Visible = false

local ThemeContentFrame = Instance.new("Frame", MainFrame)
ThemeContentFrame.Size = UDim2.new(1, 0, 1, -40)
ThemeContentFrame.Position = UDim2.new(0, 0, 0, 40)
ThemeContentFrame.BackgroundTransparency = 1
ThemeContentFrame.Visible = false

local AiContentFrame = Instance.new("Frame", MainFrame)
AiContentFrame.Size = UDim2.new(1, 0, 1, -40)
AiContentFrame.Position = UDim2.new(0, 0, 0, 40)
AiContentFrame.BackgroundTransparency = 1
AiContentFrame.Visible = false

-- ==================== CHAT UI ====================
local ChatDisplay = Instance.new("ScrollingFrame")
ChatDisplay.Size = UDim2.new(1, -20, 1, -90)
ChatDisplay.Position = UDim2.new(0, 10, 0, 5)
ChatDisplay.BackgroundTransparency = 1
ChatDisplay.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatDisplay.ScrollBarThickness = 2
ChatDisplay.Parent = ChatContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ChatDisplay

local isAtBottom = true
ChatDisplay:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    local maxScroll = math.max(0, UIListLayout.AbsoluteContentSize.Y - ChatDisplay.AbsoluteWindowSize.Y)
    if ChatDisplay.CanvasPosition.Y >= maxScroll - 10 then
        isAtBottom = true
    else
        isAtBottom = false
    end
end)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ChatDisplay.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 35)
    if isAtBottom then
        TweenService:Create(ChatDisplay, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CanvasPosition = Vector2.new(0, math.max(0, UIListLayout.AbsoluteContentSize.Y - ChatDisplay.AbsoluteWindowSize.Y + 35))
        }):Play()
    end
end)

local StickerPanel = Instance.new("Frame")
StickerPanel.Size = UDim2.new(1, -20, 0, 140)
StickerPanel.Position = UDim2.new(0, 10, 1, 5)
StickerPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
StickerPanel.Visible = false
StickerPanel.ClipsDescendants = true
StickerPanel.Parent = ChatContentFrame

local SPCorn = Instance.new("UICorner")
SPCorn.CornerRadius = UDim.new(0, 8)
SPCorn.Parent = StickerPanel

local SPStroke = Instance.new("UIStroke")
SPStroke.Thickness = 1
SPStroke.Color = CurrentThemeColor
SPStroke.Parent = StickerPanel
table.insert(ThemeObjects.Strokes, SPStroke)

local PanelHeaderTitle = Instance.new("TextLabel")
PanelHeaderTitle.Size = UDim2.new(1, 0, 0, 22)
PanelHeaderTitle.BackgroundTransparency = 1
PanelHeaderTitle.Text = "STICKER LIBRARY"
PanelHeaderTitle.Font = Enum.Font.GothamBold
PanelHeaderTitle.TextColor3 = Color3.fromRGB(180, 180, 190)
PanelHeaderTitle.TextSize = 9
PanelHeaderTitle.Parent = StickerPanel

local StickerScroller = Instance.new("ScrollingFrame")
StickerScroller.Size = UDim2.new(1, -6, 1, -24)
StickerScroller.Position = UDim2.new(0, 3, 0, 22)
StickerScroller.BackgroundTransparency = 1
StickerScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
StickerScroller.ScrollBarThickness = 3
StickerScroller.Parent = StickerPanel

local StickerLayout = Instance.new("UIGridLayout")
StickerLayout.CellSize = UDim2.new(0, 70, 0, 70)
StickerLayout.CellPadding = UDim2.new(0, 10, 0, 10)
StickerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StickerLayout.SortOrder = Enum.SortOrder.LayoutOrder
StickerLayout.Parent = StickerScroller

local ReplyPreviewBar = Instance.new("Frame")
ReplyPreviewBar.Size = UDim2.new(1, -20, 0, 25)
ReplyPreviewBar.Position = UDim2.new(0, 10, 1, -65)
ReplyPreviewBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ReplyPreviewBar.Visible = false
ReplyPreviewBar.Parent = ChatContentFrame

local RPCorner = Instance.new("UICorner")
RPCorner.CornerRadius = UDim.new(0, 6)
RPCorner.Parent = ReplyPreviewBar

local RPStroke = Instance.new("UIStroke")
RPStroke.Thickness = 1
RPStroke.Color = CurrentThemeColor
RPStroke.Parent = ReplyPreviewBar
table.insert(ThemeObjects.Strokes, RPStroke)

local RPLabel = Instance.new("TextLabel")
RPLabel.Size = UDim2.new(1, -30, 1, 0)
RPLabel.Position = UDim2.new(0, 10, 0, 0)
RPLabel.BackgroundTransparency = 1
RPLabel.Text = ""
RPLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RPLabel.Font = Enum.Font.Gotham
RPLabel.TextSize = 10
RPLabel.TextXAlignment = Enum.TextXAlignment.Left
RPLabel.Parent = ReplyPreviewBar

local RPCloseBtn = Instance.new("TextButton")
RPCloseBtn.Size = UDim2.new(0, 25, 0, 25)
RPCloseBtn.Position = UDim2.new(1, -25, 0, 0)
RPCloseBtn.BackgroundTransparency = 1
RPCloseBtn.Text = "X"
RPCloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
RPCloseBtn.Font = Enum.Font.GothamBold
RPCloseBtn.TextSize = 12
RPCloseBtn.Parent = ReplyPreviewBar

local function updateReplyBar()
    if activePvtTarget then
        RPLabel.Text = "🔒 PVT with " .. activePvtTarget.DisplayName .. " - type to send privately"
        ReplyPreviewBar.Visible = true
    elseif activeReplyContext then
        local previewText = string.sub(activeReplyContext.Text, 1, 35)
        if #activeReplyContext.Text > 35 then previewText = previewText .. "..." end
        RPLabel.Text = "Replying to " .. activeReplyContext.Sender .. ": " .. previewText
        ReplyPreviewBar.Visible = true
    else
        ReplyPreviewBar.Visible = false
    end
end

local function openReplyMode(sender, text)
    if isImageContent(text) then text = "[Image/Sticker]" end
    activeReplyContext = {Sender = sender, Text = text}
    updateReplyBar()
end

local function startPrivateChat(targetName, targetUserId, targetDisplayName)
    activePvtTarget = {Name = targetName, UserId = targetUserId, DisplayName = targetDisplayName or targetName}
    activeReplyContext = nil
    updateReplyBar()
end

local function stopPrivateChat()
    activePvtTarget = nil
    updateReplyBar()
end

RPCloseBtn.Activated:Connect(function()
    activeReplyContext = nil
    activePvtTarget = nil
    updateReplyBar()
end)

local InputBar = Instance.new("Frame")
InputBar.Size = UDim2.new(1, -20, 0, 35)
InputBar.Position = UDim2.new(0, 10, 1, -38)
InputBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
InputBar.BackgroundTransparency = 0.2
InputBar.Parent = ChatContentFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 15)
InputCorner.Parent = InputBar

local InputStroke = Instance.new("UIStroke")
InputStroke.Thickness = 1
InputStroke.Color = CurrentThemeColor
InputStroke.Parent = InputBar
table.insert(ThemeObjects.Strokes, InputBar)

local ImageMenuBtn = Instance.new("TextButton")
ImageMenuBtn.Size = UDim2.new(0, 25, 0, 25)
ImageMenuBtn.Position = UDim2.new(0, 4, 0, 5)
ImageMenuBtn.BackgroundTransparency = 1
ImageMenuBtn.Text = "📸"
ImageMenuBtn.TextSize = 14
ImageMenuBtn.Parent = InputBar

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -90, 1, 0)
TextBox.Position = UDim2.new(0, 35, 0, 0)
TextBox.BackgroundTransparency = 1
TextBox.PlaceholderText = "ITMEANS Chat..."
TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 12
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.Parent = InputBar

local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 25, 0, 25)
SendBtn.Position = UDim2.new(1, -30, 0, 5)
SendBtn.BackgroundColor3 = CurrentThemeColor
SendBtn.Text = "↑"
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.TextStrokeTransparency = 0
SendBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
SendBtn.Font = Enum.Font.GothamBold
SendBtn.TextSize = 14
SendBtn.Parent = InputBar

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(1, 0)
SendCorner.Parent = SendBtn
table.insert(ThemeObjects.Backgrounds, SendBtn)

-- ==================== AI TAB UI ====================
local AiTopSection = Instance.new("Frame")
AiTopSection.Size = UDim2.new(1, 0, 0, 88)
AiTopSection.BackgroundTransparency = 1
AiTopSection.Parent = AiContentFrame

local AiPfpWrap = Instance.new("Frame")
AiPfpWrap.Size = UDim2.new(0, 55, 0, 55)
AiPfpWrap.Position = UDim2.new(0.5, -27, 0, 4)
AiPfpWrap.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
AiPfpWrap.Parent = AiTopSection
local AiPfpCorner = Instance.new("UICorner")
AiPfpCorner.CornerRadius = UDim.new(1, 0)
AiPfpCorner.Parent = AiPfpWrap
local AiPfpStroke = Instance.new("UIStroke")
AiPfpStroke.Thickness = 2
AiPfpStroke.Color = CurrentThemeColor
AiPfpStroke.Parent = AiPfpWrap
table.insert(ThemeObjects.Strokes, AiPfpStroke)

local AiPfpEmoji = Instance.new("TextLabel")
AiPfpEmoji.Size = UDim2.new(1, 0, 1, 0)
AiPfpEmoji.BackgroundTransparency = 1
AiPfpEmoji.Text = "🤖"
AiPfpEmoji.TextSize = 30
AiPfpEmoji.Font = Enum.Font.GothamBold
AiPfpEmoji.TextColor3 = Color3.fromRGB(255,255,255)
AiPfpEmoji.Parent = AiPfpWrap

local AiNameLabel = Instance.new("TextLabel")
AiNameLabel.Size = UDim2.new(1, 0, 0, 14)
AiNameLabel.Position = UDim2.new(0, 0, 0, 62)
AiNameLabel.BackgroundTransparency = 1
AiNameLabel.Text = AI_NAME
AiNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AiNameLabel.Font = Enum.Font.GothamBold
AiNameLabel.TextSize = 12
AiNameLabel.Parent = AiTopSection

local AiSubLabel = Instance.new("TextLabel")
AiSubLabel.Size = UDim2.new(1, 0, 0, 12)
AiSubLabel.Position = UDim2.new(0, 0, 0, 76)
AiSubLabel.BackgroundTransparency = 1
AiSubLabel.Text = "Pvt With AI"
AiSubLabel.TextColor3 = CurrentThemeColor
AiSubLabel.Font = Enum.Font.Gotham
AiSubLabel.TextSize = 9
AiSubLabel.Parent = AiTopSection
table.insert(ThemeObjects.Texts, AiSubLabel)

local AiChatDisplay = Instance.new("ScrollingFrame")
AiChatDisplay.Size = UDim2.new(1, -20, 1, -132)
AiChatDisplay.Position = UDim2.new(0, 10, 0, 90)
AiChatDisplay.BackgroundTransparency = 1
AiChatDisplay.CanvasSize = UDim2.new(0, 0, 0, 0)
AiChatDisplay.ScrollBarThickness = 2
AiChatDisplay.ScrollBarImageColor3 = CurrentThemeColor
AiChatDisplay.Parent = AiContentFrame

local AiListLayout = Instance.new("UIListLayout")
AiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
AiListLayout.Padding = UDim.new(0, 5)
AiListLayout.Parent = AiChatDisplay

AiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    AiChatDisplay.CanvasSize = UDim2.new(0, 0, 0, AiListLayout.AbsoluteContentSize.Y + 10)
    AiChatDisplay.CanvasPosition = Vector2.new(0, math.max(0, AiListLayout.AbsoluteContentSize.Y - AiChatDisplay.AbsoluteWindowSize.Y + 10))
end)

local AiInputBar = Instance.new("Frame")
AiInputBar.Size = UDim2.new(1, -20, 0, 35)
AiInputBar.Position = UDim2.new(0, 10, 1, -40)
AiInputBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
AiInputBar.BackgroundTransparency = 0.2
AiInputBar.Parent = AiContentFrame

local AiInputCorner = Instance.new("UICorner")
AiInputCorner.CornerRadius = UDim.new(0, 15)
AiInputCorner.Parent = AiInputBar

local AiInputStroke = Instance.new("UIStroke")
AiInputStroke.Thickness = 1
AiInputStroke.Color = CurrentThemeColor
AiInputStroke.Parent = AiInputBar
table.insert(ThemeObjects.Strokes, AiInputStroke)

local AiTextBox = Instance.new("TextBox")
AiTextBox.Size = UDim2.new(1, -45, 1, 0)
AiTextBox.Position = UDim2.new(0, 12, 0, 0)
AiTextBox.BackgroundTransparency = 1
AiTextBox.PlaceholderText = "Ask " .. AI_NAME .. "..."
AiTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
AiTextBox.Text = ""
AiTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AiTextBox.Font = Enum.Font.Gotham
AiTextBox.TextSize = 12
AiTextBox.TextXAlignment = Enum.TextXAlignment.Left
AiTextBox.Parent = AiInputBar

local AiSendBtn = Instance.new("TextButton")
AiSendBtn.Size = UDim2.new(0, 25, 0, 25)
AiSendBtn.Position = UDim2.new(1, -30, 0, 5)
AiSendBtn.BackgroundColor3 = CurrentThemeColor
AiSendBtn.Text = "↑"
AiSendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AiSendBtn.Font = Enum.Font.GothamBold
AiSendBtn.TextSize = 14
AiSendBtn.Parent = AiInputBar
local AiSendCorner = Instance.new("UICorner")
AiSendCorner.CornerRadius = UDim.new(1, 0)
AiSendCorner.Parent = AiSendBtn
table.insert(ThemeObjects.Backgrounds, AiSendBtn)

local function addAiChatBubble(sender, text, isUser)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 0)
    Frame.AutomaticSize = Enum.AutomaticSize.Y
    Frame.BackgroundTransparency = 1
    Frame.Parent = AiChatDisplay

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.Parent = Frame

    local bubble = Instance.new("Frame")
    bubble.Size = UDim2.new(0.82, 0, 0, 0)
    bubble.AutomaticSize = Enum.AutomaticSize.Y
    if isUser then
        bubble.Position = UDim2.new(0.18, 0, 0, 0)
        bubble.BackgroundColor3 = Color3.fromRGB(60, 30, 90)
    else
        bubble.Position = UDim2.new(0, 0, 0, 0)
        bubble.BackgroundColor3 = Color3.fromRGB(28, 40, 60)
    end
    bubble.BackgroundTransparency = 0.15
    bubble.Parent = Frame
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = bubble
    local bs = Instance.new("UIStroke")
    bs.Thickness = 1
    bs.Color = CurrentThemeColor
    bs.Transparency = 0.3
    bs.Parent = bubble
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingBottom = UDim.new(0, 5)
    pad.PaddingLeft = UDim.new(0, 7)
    pad.PaddingRight = UDim.new(0, 7)
    pad.Parent = bubble

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, 0, 0, 11)
    nameL.BackgroundTransparency = 1
    nameL.Text = sender
    nameL.TextColor3 = isUser and Color3.fromRGB(200, 160, 255) or CurrentThemeColor
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 9
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = bubble

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, 0, 0, 0)
    body.Position = UDim2.new(0, 0, 0, 13)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.BackgroundTransparency = 1
    body.Text = text
    body.TextColor3 = Color3.fromRGB(255, 255, 255)
    body.Font = Enum.Font.Gotham
    body.TextSize = 11
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.Parent = bubble

    return Frame
end

local function sendAiMessage(userText)
    if userText == "" or userText:gsub(" ", "") == "" then return end
    AiTextBox.Text = ""

    addAiChatBubble(LocalPlayer.DisplayName, userText, true)
    local typingFrame = addAiChatBubble(AI_NAME, "typing...", false)

    task.spawn(function()
        local ok, answer = processAiRequest(userText, LocalPlayer.UserId, LocalPlayer.Name, true)
        if typingFrame and typingFrame.Parent then
            typingFrame:Destroy()
        end
        if ok then
            addAiChatBubble(AI_NAME .. " (for " .. LocalPlayer.DisplayName .. ")", answer, false)
        else
            addAiChatBubble("System", tostring(answer), false)
        end
    end)
end

AiSendBtn.Activated:Connect(function()
    sendAiMessage(AiTextBox.Text)
end)

AiTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendAiMessage(AiTextBox.Text)
    end
end)

-- ==================== POPUP MENU ====================
local function closeMessagePopup()
    if currentPopup then
        currentPopup:Destroy()
        currentPopup = nil
    end
end

local function copyToClipboard(txt)
    pcall(function()
        if setclipboard then setclipboard(txt)
        elseif toclipboard then toclipboard(txt)
        elseif writeclipboard then writeclipboard(txt)
        elseif set_clipboard then set_clipboard(txt)
        end
    end)
end

local function showMessagePopup(sender, text, userId, shownName)
    closeMessagePopup()
    local isOwnMessage = (userId == LocalPlayer.UserId) or (sender == LocalPlayer.Name)

    local popup = Instance.new("Frame")
    popup.Name = "ITMEANS_MsgPopup"
    popup.Size = UDim2.new(0, 100, 0, isOwnMessage and 80 or 118)
    popup.BackgroundColor3 = DarkBG
    popup.BackgroundTransparency = 0.05
    popup.BorderSizePixel = 0
    popup.ZIndex = 500
    popup.Active = true
    popup.Parent = ScreenGui

    local mouseLoc = UserInputService:GetMouseLocation()
    local px = math.clamp(mouseLoc.X + 15, 10, 800)
    local py = math.clamp(mouseLoc.Y - 30, 10, 500)
    popup.Position = UDim2.new(0, px, 0, py)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = popup

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = CurrentThemeColor
    stroke.Parent = popup

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = popup

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.Parent = popup

    local function makeBtn(txt, color, order)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -12, 0, 30)
        b.BackgroundColor3 = color
        b.Text = txt
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.ZIndex = 501
        b.LayoutOrder = order
        b.Parent = popup
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 5)
        bc.Parent = b
        return b
    end

    if not isOwnMessage then
        local pvtBtn = makeBtn("🔒 PVT", Color3.fromRGB(120, 50, 170), 1)
        pvtBtn.Activated:Connect(function()
            if userId then startPrivateChat(sender, userId, shownName) end
            closeMessagePopup()
        end)
    end

    local copyBtn = makeBtn("📋 COPY", Color3.fromRGB(50, 100, 150), 2)
    copyBtn.Activated:Connect(function()
        copyToClipboard(text)
        copyBtn.Text = "✅ COPIED!"
        task.delay(0.7, function() closeMessagePopup() end)
    end)

    local profBtn = makeBtn("👤 PROFILE", Color3.fromRGB(50, 130, 80), 3)
    profBtn.Activated:Connect(function()
        if userId then OpenProfilePanel(userId, sender, shownName) end
        closeMessagePopup()
    end)

    currentPopup = popup
    task.delay(5, function()
        if currentPopup == popup then closeMessagePopup() end
    end)
end

-- ==================== STICKERS ====================
local StickerRegistry = {
    "rbxthumb://type=Asset&id=126155452969559&w=420&h=420",
    "rbxthumb://type=Asset&id=76528918733148&w=420&h=420",
    "rbxthumb://type=Asset&id=139746534721570&w=420&h=420",
    "rbxthumb://type=Asset&id=107882158860216&w=420&h=420",
    "rbxthumb://type=Asset&id=99467189295335&w=420&h=420",
    "rbxthumb://type=Asset&id=114738142020573&w=420&h=420",
    "rbxthumb://type=Asset&id=100644268219896&w=420&h=420",
    "rbxthumb://type=Asset&id=82732486060449&w=420&h=420",
    "rbxthumb://type=Asset&id=84345768144066&w=420&h=420",
    "rbxthumb://type=Asset&id=85611228914039&w=420&h=420",
    "rbxthumb://type=Asset&id=126857592936719&w=420&h=420",
    "rbxthumb://type=Asset&id=106945724992072&w=420&h=420",
    "rbxthumb://type=Asset&id=102454731178873&w=420&h=420",
    "rbxthumb://type=Asset&id=33230128&w=420&h=420",
    "rbxthumb://type=Asset&id=33199969&w=420&h=420",
    "rbxthumb://type=Asset&id=33200194&w=420&h=420",
    "rbxthumb://type=Asset&id=33200310&w=420&h=420",
    "rbxthumb://type=Asset&id=33200394&w=420&h=420",
    "rbxthumb://type=Asset&id=12221967&w=420&h=420",
    "rbxthumb://type=Asset&id=12221983&w=420&h=420",
    "rbxthumb://type=Asset&id=12221991&w=420&h=420",
}

-- ===== NEW STICKER PACK (Zane/Chat style) =====
local NewStickerIds = {
    "13217424699", "13217424385", "13217423982", "13217423696", "13217423402",
    "13217422998", "13217422471", "13217422119", "13217421825", "13217421379",
    "13217421060", "13217420557", "13217420077", "13217419720", "13217419266",
    "13217418705", "13217418293", "13217417743", "13217417316", "13217416955",
    "13217416447", "13217415842", "13217415494", "13217414963", "13217414546",
    "13217413988", "13217413470", "13217412952", "13217412384", "13217411985",
    "13217411477", "13217410978", "13217410668", "13217410058", "13217409559",
    "13217409212", "13217408711", "13217408018", "13217407511", "13217407137",
    "13217406604", "13217406188", "13217405706", "13217405108", "13217404617",
    "13217404285", "13217403780", "13217403333", "13217402809", "13217402179",
    "13217401799", "13217401318", "13217400732", "13217400037", "13217399580",
    "13217398918", "13217398466", "13217397973", "13217397455"
}
for _, id in ipairs(NewStickerIds) do
    table.insert(StickerRegistry, "rbxthumb://type=Asset&id=" .. id .. "&w=420&h=420")
end

local StickerOpened = false

for i, sticker in ipairs(StickerRegistry) do
    local StkBtn = Instance.new("ImageButton")
    StkBtn.Image = sticker
    StkBtn.BackgroundColor3 = SecondaryBG
    StkBtn.ScaleType = Enum.ScaleType.Fit
    StkBtn.Parent = StickerScroller
    local SBCorn = Instance.new("UICorner")
    SBCorn.CornerRadius = UDim.new(0, 5)
    SBCorn.Parent = StkBtn
    StkBtn.Activated:Connect(function()
        sendSecretMessage(sticker)
        if StickerOpened then
            StickerOpened = false
            local closeTween = TweenService:Create(StickerPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 10, 1, 5)
            })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if not StickerOpened then StickerPanel.Visible = false end
            end)
        end
    end)
end

task.delay(0.1, function()
    StickerScroller.CanvasSize = UDim2.new(0, 0, 0, StickerLayout.AbsoluteContentSize.Y + 10)
end)

ImageMenuBtn.Activated:Connect(function()
    if not StickerOpened then
        StickerOpened = true
        StickerPanel.Visible = true
        StickerPanel.Position = UDim2.new(0, 10, 1, 5)
        TweenService:Create(StickerPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 10, 1, -145)
        }):Play()
    else
        StickerOpened = false
        local closeTween = TweenService:Create(StickerPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 10, 1, 5)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            if not StickerOpened then StickerPanel.Visible = false end
        end)
    end
end)

-- ==================== GALLERY TAB ====================
local GalleryContent = Instance.new("Frame")
GalleryContent.Size = UDim2.new(1, -20, 1, -20)
GalleryContent.Position = UDim2.new(0, 10, 0, 10)
GalleryContent.BackgroundTransparency = 1
GalleryContent.Parent = GalleryContentFrame

local GalLabel = Instance.new("TextLabel")
GalLabel.Size = UDim2.new(1, 0, 0, 18)
GalLabel.Position = UDim2.new(0, 0, 0, 0)
GalLabel.Text = "IMAGE PREVIEW"
GalLabel.Font = Enum.Font.GothamBold
GalLabel.TextColor3 = Color3.fromRGB(200,200,200)
GalLabel.TextSize = 10
GalLabel.BackgroundTransparency = 1
GalLabel.Parent = GalleryContent

local ImagePreview = Instance.new("ImageLabel")
ImagePreview.Size = UDim2.new(0,120,0,120)
ImagePreview.Position = UDim2.new(0.5,-60,0,25)
ImagePreview.BackgroundColor3 = SecondaryBG
ImagePreview.Image = "rbxassetid://0"
ImagePreview.ScaleType = Enum.ScaleType.Fit
ImagePreview.Parent = GalleryContent

local IPCorner = Instance.new("UICorner")
IPCorner.CornerRadius = UDim.new(0,8)
IPCorner.Parent = ImagePreview

local IPStroke = Instance.new("UIStroke")
IPStroke.Thickness = 1.5
IPStroke.Color = CurrentThemeColor
IPStroke.Parent = ImagePreview
table.insert(ThemeObjects.Strokes, IPStroke)

local UrlInput = Instance.new("TextBox")
UrlInput.Size = UDim2.new(1,-30,0,30)
UrlInput.Position = UDim2.new(0,15,0,155)
UrlInput.BackgroundColor3 = Color3.fromRGB(12,12,16)
UrlInput.BackgroundTransparency = 0.2
UrlInput.PlaceholderText = "Paste Image URL / rbxassetid / Asset ID..."
UrlInput.Text = ""
UrlInput.TextColor3 = Color3.fromRGB(255,255,255)
UrlInput.Font = Enum.Font.Gotham
UrlInput.TextSize = 10
UrlInput.Parent = GalleryContent

local UrlCorner = Instance.new("UICorner")
UrlCorner.CornerRadius = UDim.new(0,6)
UrlCorner.Parent = UrlInput

local GalSendBtn = Instance.new("TextButton")
GalSendBtn.Size = UDim2.new(0,120,0,32)
GalSendBtn.Position = UDim2.new(0.5,-60,0,195)
GalSendBtn.BackgroundColor3 = CurrentThemeColor
GalSendBtn.Text = "SEND TO CHAT"
GalSendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GalSendBtn.TextStrokeTransparency = 0
GalSendBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
GalSendBtn.Font = Enum.Font.GothamBold
GalSendBtn.TextSize = 11
GalSendBtn.Parent = GalleryContent

local GSCorner = Instance.new("UICorner")
GSCorner.CornerRadius = UDim.new(0,6)
GSCorner.Parent = GalSendBtn

local GSStroke = Instance.new("UIStroke")
GSStroke.Thickness = 1.5
GSStroke.Color = Color3.fromRGB(255, 255, 255)
GSStroke.Parent = GalSendBtn

UrlInput:GetPropertyChangedSignal("Text"):Connect(function()
    ImagePreview.Image = formatImageUrl(UrlInput.Text)
end)

GalSendBtn.Activated:Connect(function()
    if UrlInput.Text ~= "" then
        local imgTarget = formatImageUrl(UrlInput.Text)
        sendSecretMessage(imgTarget)
        UrlInput.Text = ""
        ImagePreview.Image = "rbxassetid://0"
    end
end)

-- ==================== THEME TAB ====================
local ThemeDisplay = Instance.new("ScrollingFrame")
ThemeDisplay.Size = UDim2.new(1, -20, 1, -20)
ThemeDisplay.Position = UDim2.new(0, 10, 0, 10)
ThemeDisplay.BackgroundTransparency = 1
ThemeDisplay.CanvasSize = UDim2.new(0, 0, 0, 0)
ThemeDisplay.ScrollBarThickness = 2
ThemeDisplay.Parent = ThemeContentFrame

local ThemeGrid = Instance.new("UIGridLayout")
ThemeGrid.CellSize = UDim2.new(0, 60, 0, 50)
ThemeGrid.CellPadding = UDim2.new(0, 8, 0, 8)
ThemeGrid.Parent = ThemeDisplay

local AvailableThemes = {
    {Name = "Riser Pink", Color = Color3.fromRGB(255, 20, 147)},
    {Name = "Ruby Red", Color = Color3.fromRGB(220, 20, 60)},
    {Name = "Crimson", Color = Color3.fromRGB(180, 0, 0)},
    {Name = "Sunset", Color = Color3.fromRGB(255, 80, 0)},
    {Name = "Orange", Color = Color3.fromRGB(255, 140, 0)},
    {Name = "Gold", Color = Color3.fromRGB(255, 215, 0)},
    {Name = "Lime", Color = Color3.fromRGB(50, 205, 50)},
    {Name = "Neon Green", Color = Color3.fromRGB(57, 255, 20)},
    {Name = "Teal", Color = Color3.fromRGB(0, 128, 128)},
    {Name = "Cyan", Color = Color3.fromRGB(0, 255, 255)},
    {Name = "Royal Blue", Color = Color3.fromRGB(65, 105, 225)},
    {Name = "Neon Purple", Color = Color3.fromRGB(176, 38, 255)},
    {Name = "White", Color = Color3.fromRGB(255, 255, 255)}
}

local function ApplyTheme(newColor)
    CurrentThemeColor = newColor
    for _, obj in ipairs(ThemeObjects.Backgrounds) do
        if obj and obj.Parent then obj.BackgroundColor3 = newColor end
    end
    for _, obj in ipairs(ThemeObjects.Strokes) do
        if obj and obj.Parent then obj.Color = newColor end
    end
    for _, obj in ipairs(ThemeObjects.Texts) do
        if obj and obj.Parent then obj.TextColor3 = newColor end
    end
    GalSendBtn.BackgroundColor3 = newColor
    AiSendBtn.BackgroundColor3 = newColor
    AiPfpStroke.Color = newColor

    if ProfFollowBtn.Text == "FOLLOW" then
        ProfFollowBtn.BackgroundColor3 = newColor
    end

    if ChatContentFrame.Visible then
        ChatTabBtn.TextColor3 = newColor
    elseif ThemeContentFrame.Visible then
        ThemeTabBtn.TextColor3 = newColor
    elseif GalleryContentFrame.Visible then
        GalleryTabBtn.TextColor3 = newColor
    elseif AiContentFrame.Visible then
        AiTabBtn.TextColor3 = newColor
    end
end

for i, theme in ipairs(AvailableThemes) do
    local ColorBtn = Instance.new("TextButton")
    ColorBtn.BackgroundColor3 = theme.Color
    ColorBtn.Text = ""
    ColorBtn.Parent = ThemeDisplay
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 10)
    CCorner.Parent = ColorBtn
    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size = UDim2.new(1, 0, 0, 12)
    NameLbl.Position = UDim2.new(0, 0, 1, -12)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = theme.Name
    NameLbl.TextColor3 = Color3.fromRGB(255,255,255)
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 7
    NameLbl.Parent = ColorBtn
    ColorBtn.Activated:Connect(function()
        ApplyTheme(theme.Color)
    end)
end

task.delay(0.1, function()
    ThemeDisplay.CanvasSize = UDim2.new(0, 0, 0, ThemeGrid.AbsoluteContentSize.Y + 10)
end)

-- ==================== TAB SWITCHING ====================
local function SwitchTab(tab)
    ChatTabBtn.TextColor3 = (tab == "Chat") and CurrentThemeColor or Color3.fromRGB(150, 150, 160)
    ThemeTabBtn.TextColor3 = (tab == "Theme") and CurrentThemeColor or Color3.fromRGB(150, 150, 160)
    GalleryTabBtn.TextColor3 = (tab == "Gallery") and CurrentThemeColor or Color3.fromRGB(150, 150, 160)
    AiTabBtn.TextColor3 = (tab == "AI") and CurrentThemeColor or Color3.fromRGB(150, 150, 160)

    ChatContentFrame.Visible = (tab == "Chat")
    ThemeContentFrame.Visible = (tab == "Theme")
    GalleryContentFrame.Visible = (tab == "Gallery")
    AiContentFrame.Visible = (tab == "AI")
end

ChatTabBtn.Activated:Connect(function() SwitchTab("Chat") end)
ThemeTabBtn.Activated:Connect(function() SwitchTab("Theme") end)
GalleryTabBtn.Activated:Connect(function() SwitchTab("Gallery") end)
AiTabBtn.Activated:Connect(function() SwitchTab("AI") end)

-- ==================== RANK & AURA MANAGEMENT ====================
local function fetchRanksFromFirebase()
    pcall(function()
        local response = request_func({Url = FirebaseRanksURL, Method = "GET"})
        if response and response.StatusCode == 200 and response.Body ~= "null" then
            local data = HttpService:JSONDecode(response.Body)
            if data then
                RGBRanks = {}
                for usernameStr, rank in pairs(data) do
                    RGBRanks[string.lower(usernameStr)] = rank
                end
            end
        end
    end)
end

local function updateRankInFirebase(username, rankName)
    local userKey = string.lower(username)
    local rankUrl = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Ranks/" .. userKey .. ".json"
    local ok, result = pcall(function()
        return request_func({Url = rankUrl, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(rankName)})
    end)
    return (ok and result and result.StatusCode == 200)
end

local function removeRankFromFirebase(username)
    local userKey = string.lower(username)
    local rankUrl = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Ranks/" .. userKey .. ".json"
    local ok, result = pcall(function()
        return request_func({Url = rankUrl, Method = "DELETE", Headers = {["Content-Type"] = "application/json"}})
    end)
    return (ok and result and result.StatusCode == 200)
end

local function fetchAurasFromFirebase()
    pcall(function()
        local response = request_func({Url = FirebaseAurasURL, Method = "GET"})
        if response and response.StatusCode == 200 and response.Body ~= "null" then
            local data = HttpService:JSONDecode(response.Body)
            if data then
                SyncedAuras = {}
                for usernameStr, val in pairs(data) do
                    if type(val) == "table" then
                        SyncedAuras[string.lower(usernameStr)] = val
                    else
                        SyncedAuras[string.lower(usernameStr)] = {Active = val, Color = "pink", Type = "mecha"}
                    end
                end
            end
        end
    end)
end

local function updateAuraDataInFirebase(username, dataObj)
    local userKey = string.lower(username)
    local url = "https://itmeans-chat-4df62-default-rtdb.asia-southeast1.firebasedatabase.app/Auras/" .. userKey .. ".json"
    if dataObj then
        local ok, result = pcall(function()
            return request_func({Url = url, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(dataObj)})
        end)
        return (ok and result and result.StatusCode == 200)
    else
        local ok, result = pcall(function()
            return request_func({Url = url, Method = "DELETE", Headers = {["Content-Type"] = "application/json"}})
        end)
        return (ok and result and result.StatusCode == 200)
    end
end

local function createAuraForPlayer(targetPlayer, auraType)
    if activeAuras[targetPlayer] then return end
    local char = targetPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = char.HumanoidRootPart
    local model = Instance.new("Model", char)
    model.Name = "SyncedMechaAura"
    local typeKey = string.lower(auraType or "mecha")

    -- Check function-based auras first
    if FunctionAuras[typeKey] then
        FunctionAuras[typeKey](targetPlayer, rootPart, model)
        activeAuras[targetPlayer] = {
            Model = model,
            Parts = {},
            Type = typeKey,
            IsFunction = true
        }
        return
    end

    -- Structure-based auras (mecha, mecha2, orbit)
    local structureToUse = AuraRegistry[typeKey] or partsStructure
    local createdParts = {}
    for _, data in ipairs(structureToUse) do
        local p = Instance.new("Part")
        p.Material = Enum.Material.Neon
        p.Color = data.isDetail and Color3.fromRGB(5, 5, 5) or CurrentThemeColor
        p.CanCollide = false
        p.Anchored = true
        p.Size = data.size
        if data.shape then p.Shape = data.shape end
        p.Parent = model
        table.insert(createdParts, {
            part = p,
            offset = data.offset or CFrame.new(),
            isDetail = data.isDetail,
            isWing = data.isWing,
            wingSide = data.wingSide
        })
    end
    activeAuras[targetPlayer] = {Model = model, Parts = createdParts, Type = typeKey, IsFunction = false}
end

local function removeAuraForPlayer(targetPlayer)
    if activeAuras[targetPlayer] then
        if activeAuras[targetPlayer].Model then activeAuras[targetPlayer].Model:Destroy() end
        activeAuras[targetPlayer] = nil
    end
end

local function applyAuras()
    for _, plr in ipairs(Players:GetPlayers()) do
        local userKey = string.lower(plr.Name)
        if SyncedAuras[userKey] and SyncedAuras[userKey].Active then
            local currentType = SyncedAuras[userKey].Type or "mecha"
            if activeAuras[plr] and activeAuras[plr].Type ~= string.lower(currentType) then
                removeAuraForPlayer(plr)
            end
            if not activeAuras[plr] then
                createAuraForPlayer(plr, currentType)
            end
        else
            removeAuraForPlayer(plr)
        end
    end
end

RunService.RenderStepped:Connect(function()
    local t = tick()
    local speed = 1.4
    local height = 0.35
    local float = math.sin(t * speed) * height

    for targetPlayer, data in pairs(activeAuras) do
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and data.Model.Parent then
            if data.IsFunction then
                -- Function-based auras animate themselves, skip here
            else
                local rootCF = targetPlayer.Character.HumanoidRootPart.CFrame
                local userKey = string.lower(targetPlayer.Name)
                local auraData = SyncedAuras[userKey]
                local targetColor = CurrentThemeColor
                if auraData and auraData.Color and AuraColors[auraData.Color] then
                    targetColor = AuraColors[auraData.Color]
                end

                local circleBehind = (data.Type ~= "mecha" and data.Type ~= "mecha2" and data.Type ~= "orbit")

                local circleOffset = CFrame.new(0, 0, 0)
                if circleBehind then
                    local angle = t * 1.2
                    local radius = 8
                    local behindZ = -7
                    circleOffset = CFrame.new(math.cos(angle) * radius, 0, behindZ + math.sin(angle) * radius)
                end

                for i, item in ipairs(data.Parts) do
                    if item.part and item.part.Parent then
                        if item.isDetail then
                            item.part.Color = Color3.fromRGB(5, 5, 5)
                        else
                            item.part.Color = targetColor
                        end
                        if data.Type == "orbit" then
                            local orbitSpeed = t * 2.5
                            local radius = 3.5
                            local offsetAngle = (i / #data.Parts) * math.pi * 2
                            local x = math.cos(orbitSpeed + offsetAngle) * radius
                            local z = math.sin(orbitSpeed + offsetAngle) * radius
                            local y = math.sin(t * 2 + offsetAngle) * 1.5
                            item.part.CFrame = rootCF * CFrame.new(x, y, z)
                        elseif data.Type == "mecha2" and item.isWing then
                            local flapSpeed = t * 2.5
                            local flapAngle = math.sin(flapSpeed) * 12 * item.wingSide
                            local wingTilt = CFrame.Angles(0, 0, math.rad(flapAngle))
                            item.part.CFrame = rootCF * item.offset * wingTilt * CFrame.new(0, float, 0)
                        elseif circleBehind then
                            item.part.CFrame = rootCF * circleOffset * item.offset * CFrame.new(0, float, 0)
                        else
                            local rotSpeed = 1.0
                            if data.Type == "mecha" or data.Type == "mecha2" then rotSpeed = 0
                            end
                            local rotationAngle = t * rotSpeed
                            local offset = item.offset
                            if rotationAngle ~= 0 then
                                offset = CFrame.Angles(0, rotationAngle, 0) * offset
                            end
                            item.part.CFrame = rootCF * offset * CFrame.new(0, float, 0)
                        end
                    end
                end
            end
        else
            removeAuraForPlayer(targetPlayer)
        end
    end
end)

-- ==================== NOTIFICATION & OVERHEAD ====================
local function createOverheadBubble(player, text)
    if not player or not player.Character or not player.Character:FindFirstChild("Head") then return end
    local head = player.Character.Head
    if head:FindFirstChild("RechatOverhead") then head.RechatOverhead:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name = "RechatOverhead"
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.Adornee = head
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.Parent = head
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundColor3 = DarkBG
    f.BackgroundTransparency = 0.2
    f.Parent = bb
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = f
    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = CurrentThemeColor
    s.Parent = f
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 1, -8)
    l.Position = UDim2.new(0, 4, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = isImageContent(text) and "[Sticker/Image]" or text
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 10
    l.TextWrapped = true
    l.Parent = f
    task.delay(4, function()
        if bb and bb.Parent then bb:Destroy() end
    end)
end

local function sendNotification(senderName, text, userId)
    if NotifGui:FindFirstChild("CurrentNotif") then NotifGui.CurrentNotif:Destroy() end
    local NotifGroup = Instance.new("CanvasGroup")
    NotifGroup.Name = "CurrentNotif"
    NotifGroup.Size = UDim2.new(0, 250, 0, 60)
    NotifGroup.Position = UDim2.new(0, -280, 1, -90)
    NotifGroup.BackgroundColor3 = DarkBG
    NotifGroup.BackgroundTransparency = 0.2
    NotifGroup.GroupTransparency = 1
    NotifGroup.Parent = NotifGui

    local NCorner = Instance.new("UICorner")
    NCorner.CornerRadius = UDim.new(0, 10)
    NCorner.Parent = NotifGroup

    local NStroke = Instance.new("UIStroke")
    NStroke.Thickness = 2
    NStroke.Color = CurrentThemeColor
    NStroke.Parent = NotifGroup

    local NAvatar = Instance.new("ImageLabel")
    NAvatar.Size = UDim2.new(0, 40, 0, 40)
    NAvatar.Position = UDim2.new(0, 10, 0.5, -20)
    NAvatar.BackgroundColor3 = SecondaryBG
    NAvatar.Image = ""

    if senderName == "SYSTEM" then
        local sysIcon = Instance.new("TextLabel")
        sysIcon.Size = UDim2.new(1, 0, 1, 0)
        sysIcon.BackgroundTransparency = 1
        sysIcon.Text = "🕊"
        sysIcon.TextSize = 22
        sysIcon.Font = Enum.Font.GothamBold
        sysIcon.Parent = NAvatar
    else
        NAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId or 0) .. "&w=48&h=48"
    end
    NAvatar.Parent = NotifGroup

    local NACorner = Instance.new("UICorner")
    NACorner.CornerRadius = UDim.new(1, 0)
    NACorner.Parent = NAvatar

    local NName = Instance.new("TextLabel")
    NName.Size = UDim2.new(1, -60, 0, 16)
    NName.Position = UDim2.new(0, 55, 0, 10)
    NName.BackgroundTransparency = 1
    NName.Text = senderName or "SYSTEM"
    NName.TextColor3 = CurrentThemeColor
    NName.Font = Enum.Font.GothamBold
    NName.TextSize = 12
    NName.TextXAlignment = Enum.TextXAlignment.Left
    NName.Parent = NotifGroup

    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -60, 0, 20)
    NText.Position = UDim2.new(0, 55, 0, 28)
    NText.BackgroundTransparency = 1

    local preview = text or ""
    if isImageContent(preview) then preview = "Sent a sticker/image" end
    if #preview > 28 then preview = string.sub(preview, 1, 25) .. "..." end
    NText.Text = preview
    NText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NText.Font = Enum.Font.Gotham
    NText.TextSize = 10
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.TextWrapped = true
    NText.Parent = NotifGroup

    playSound(SOUND_MESSAGE)
    TweenService:Create(NotifGroup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {GroupTransparency = 0, Position = UDim2.new(0, 15, 1, -90)}):Play()
    task.delay(4, function()
        if NotifGroup and NotifGroup.Parent then
            local fade = TweenService:Create(NotifGroup, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1, Position = UDim2.new(0, -280, 1, -90)})
            fade:Play()
            fade.Completed:Connect(function() NotifGroup:Destroy() end)
        end
    end)
end

-- ==================== RGB ANIMATION + STAR ORBIT ====================
RunService.Heartbeat:Connect(function()
    local hue = (tick() * 0.05) % 1
    local rgbColor = Color3.fromHSV(hue, 0.85, 1)
    local hexColor = rgbColor:ToHex()

    for label, info in pairs(AnimatedRankLabels) do
        if label and label.Parent then
            label.Text = '<font color="#' .. hexColor .. '"><b>[' .. info.RankText .. ']</b></font> <font color="' .. info.NameHex .. '"><b>' .. info.SenderText .. '</b></font>:'
        else
            AnimatedRankLabels[label] = nil
        end
    end

    for label, rawText in pairs(AnimatedSystemLabels) do
        if label and label.Parent then
            if string.sub(rawText, 1, 12) == "⚡ [SYSTEM] :" then
                local content = string.sub(rawText, 13)
                label.Text = '<font color="#' .. hexColor .. '"><b>⚡ [SYSTEM] :</b></font><font color="#FFFFFF">' .. content .. '</font>'
            else
                label.Text = '<font color="#' .. hexColor .. '"><b>' .. rawText .. '</b></font>'
            end
        else
            AnimatedSystemLabels[label] = nil
        end
    end

    local orbitSpeed = tick() * 55
    local cx = toggleW / 2
    local cy = toggleH / 2
    local radiusX = (toggleW / 2) + 3
    local radiusY = (toggleH / 2) + 3
    for i, star in ipairs(starList) do
        local angle = math.rad(orbitSpeed + (i - 1) * (360 / numStars))
        local posX = cx + math.cos(angle) * radiusX
        local posY = cy + math.sin(angle) * radiusY
        star.Position = UDim2.new(0, posX - (starSize / 2), 0, posY - (starSize / 2))
    end
end)

-- ==================== ADD MESSAGE TO UI ====================
function addMessageToUI(sender, text, userId, isSystem, displayName, replyData, isTyping)
    sender = (sender and sender ~= "") and sender or "User"
    text = tostring(text or "")
    local shownName = (displayName and displayName ~= "") and displayName or sender
    local isAIMessage = (userId == 0 and sender == AI_NAME)

    local MsgFrame = Instance.new("Frame")
    MsgFrame.Size = UDim2.new(1, 0, 0, 0)
    MsgFrame.AutomaticSize = Enum.AutomaticSize.Y
    MsgFrame.BackgroundTransparency = 1
    MsgFrame.Parent = ChatDisplay

    local pressStartTime = 0
    local dragStart = nil

    MsgFrame.InputBegan:Connect(function(input)
        if not isSystem and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragStart = input.Position
            pressStartTime = tick()
        end
    end)
    MsgFrame.InputEnded:Connect(function(input)
        if dragStart and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            local delta = input.Position - dragStart
            local heldTime = tick() - pressStartTime
            if math.abs(delta.X) > 40 then
                openReplyMode(shownName, text)
                local origPos = MsgFrame.Position
                TweenService:Create(MsgFrame, TweenInfo.new(0.15), {Position = MsgFrame.Position + UDim2.new(0, delta.X > 0 and 20 or -20, 0, 0)}):Play()
                task.wait(0.15)
                TweenService:Create(MsgFrame, TweenInfo.new(0.15), {Position = origPos}):Play()
            elseif heldTime >= 1.2 then
                if userId and not isTyping then
                    showMessagePopup(sender, text, userId, shownName)
                end
            end
            dragStart = nil
        end
    end)

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 30)
    Padding.Parent = MsgFrame

    if userId and userId ~= 0 and not isSystem then
        local MiniAvatar = Instance.new("ImageButton")
        MiniAvatar.Size = UDim2.new(0, 20, 0, 20)
        MiniAvatar.Position = UDim2.new(0, -25, 0, 2)
        MiniAvatar.BackgroundColor3 = SecondaryBG
        MiniAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=48&h=48"
        MiniAvatar.Parent = MsgFrame
        local MACorner = Instance.new("UICorner")
        MACorner.CornerRadius = UDim.new(1,0)
        MACorner.Parent = MiniAvatar
        MiniAvatar.Activated:Connect(function()
            OpenProfilePanel(userId, sender, shownName)
        end)
    elseif isAIMessage then
        local AiMini = Instance.new("TextLabel")
        AiMini.Size = UDim2.new(0, 20, 0, 20)
        AiMini.Position = UDim2.new(0, -25, 0, 2)
        AiMini.BackgroundColor3 = SecondaryBG
        AiMini.Text = "🤖"
        AiMini.TextSize = 12
        AiMini.Font = Enum.Font.GothamBold
        AiMini.Parent = MsgFrame
        local AiMCorner = Instance.new("UICorner")
        AiMCorner.CornerRadius = UDim.new(1,0)
        AiMCorner.Parent = AiMini
    end

    if isSystem then
        Padding.PaddingLeft = UDim.new(0, 8)
        MsgFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
        MsgFrame.BackgroundTransparency = 0.4
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = MsgFrame

        local SysMini = Instance.new("TextLabel")
        SysMini.Size = UDim2.new(0, 20, 0, 20)
        SysMini.Position = UDim2.new(0, -25, 0, 2)
        SysMini.BackgroundColor3 = SecondaryBG
        SysMini.Text = "🕊"
        SysMini.TextSize = 12
        SysMini.Font = Enum.Font.GothamBold
        SysMini.Parent = MsgFrame
        local SysMCorner = Instance.new("UICorner")
        SysMCorner.CornerRadius = UDim.new(1,0)
        SysMCorner.Parent = SysMini

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -10, 1, 0)
        Label.Position = UDim2.new(0, 5, 0, 0)
        Label.AutomaticSize = Enum.AutomaticSize.Y
        Label.BackgroundTransparency = 1
        Label.TextSize = 11
        Label.Font = Enum.Font.GothamBold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextWrapped = true
        Label.RichText = true
        Label.Parent = MsgFrame

        AnimatedSystemLabels[Label] = text
    else
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 14)
        Label.BackgroundTransparency = 1
        Label.TextSize = 12
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.RichText = true
        Label.Parent = MsgFrame

        local customTag = nil
        local senderLower = string.lower(sender)
        local actualPlayer = userId and Players:GetPlayerByUserId(userId) or nil

        if sender == AI_NAME then
            customTag = "AI"
        elseif RGBRanks[senderLower] then
            customTag = RGBRanks[senderLower]
        elseif Creators[userId] or Creators[sender] or (actualPlayer and Creators[actualPlayer.Name]) then
            customTag = "Creator"
        elseif Admins[userId] or Admins[sender] or (actualPlayer and Admins[actualPlayer.Name]) then
            customTag = "Admin"
        elseif Vips[userId] or Vips[sender] or (actualPlayer and Vips[actualPlayer.Name]) then
            customTag = "Vip"
        elseif Daddys[userId] or Daddys[sender] or (actualPlayer and Daddys[actualPlayer.Name]) then
            customTag = "Daddy"
        end

        local nameHex = getUserColor(userId, sender)
        if customTag then
            AnimatedRankLabels[Label] = {
                RankText = customTag,
                SenderText = shownName,
                NameHex = nameHex
            }
        else
            Label.Text = '<font color="' .. nameHex .. '"><b>' .. shownName .. '</b></font>:'
        end

        local startYOffset = 16
        if replyData and replyData.Sender then
            local RepBlock = Instance.new("Frame")
            RepBlock.Size = UDim2.new(1, -20, 0, 14)
            RepBlock.Position = UDim2.new(0, 0, 0, startYOffset)
            RepBlock.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            RepBlock.BackgroundTransparency = 0.5
            RepBlock.Parent = MsgFrame
            local RC = Instance.new("UICorner")
            RC.CornerRadius = UDim.new(0, 4)
            RC.Parent = RepBlock
            local RL = Instance.new("TextLabel")
            RL.Size = UDim2.new(1, -10, 1, 0)
            RL.Position = UDim2.new(0, 5, 0, 0)
            RL.BackgroundTransparency = 1
            RL.Text = "Replying to " .. replyData.Sender .. ": " .. replyData.Text
            RL.TextColor3 = Color3.fromRGB(180, 180, 180)
            RL.Font = Enum.Font.Gotham
            RL.TextSize = 9
            RL.TextXAlignment = Enum.TextXAlignment.Left
            RL.TextTruncate = Enum.TextTruncate.AtEnd
            RL.Parent = RepBlock
            startYOffset = startYOffset + 18
        end

        local isImage = isImageContent(text)
        if isImage then
            local SharedImg = Instance.new("ImageLabel")
            SharedImg.Size = UDim2.new(0, 90, 0, 90)
            SharedImg.Position = UDim2.new(0, 0, 0, startYOffset + 2)
            SharedImg.BackgroundColor3 = SecondaryBG
            SharedImg.Image = formatImageUrl(text)
            SharedImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
            SharedImg.ScaleType = Enum.ScaleType.Fit
            SharedImg.Parent = MsgFrame
            local SICorn = Instance.new("UICorner")
            SICorn.CornerRadius = UDim.new(0, 6)
            SICorn.Parent = SharedImg
            local Spacer = Instance.new("Frame")
            Spacer.Size = UDim2.new(1,0,0, startYOffset + 94)
            Spacer.BackgroundTransparency = 1
            Spacer.Parent = MsgFrame
        else
            local TextBlock = Instance.new("TextLabel")
            TextBlock.Size = UDim2.new(1, 0, 0, 0)
            TextBlock.Position = UDim2.new(0, 0, 0, startYOffset)
            TextBlock.AutomaticSize = Enum.AutomaticSize.Y
            TextBlock.BackgroundTransparency = 1
            TextBlock.TextSize = 12
            TextBlock.Font = Enum.Font.Gotham
            if isTyping then
                TextBlock.TextColor3 = Color3.fromRGB(180, 180, 180)
                TextBlock.Font = Enum.Font.GothamMedium
                TextBlock.Text = text
                task.spawn(function()
                    local dots = {".", "..", "..."}
                    local i = 1
                    while TextBlock and TextBlock.Parent and isTyping do
                        TextBlock.Text = "typing" .. dots[i]
                        i = i + 1
                        if i > 3 then i = 1 end
                        task.wait(0.3)
                    end
                end)
            else
                TextBlock.TextColor3 = Color3.fromRGB(255,255,255)
                TextBlock.TextWrapped = true
                TextBlock.Text = text
            end
            TextBlock.TextXAlignment = Enum.TextXAlignment.Left
            TextBlock.Parent = MsgFrame
        end
    end

    return MsgFrame
end

local function addPvtMessageToUI(fromName, fromDisplay, toName, toDisplay, text)
    local isOwn = (fromName == LocalPlayer.Name)
    local isIncoming = (toName == LocalPlayer.Name)

    local MsgFrame = Instance.new("Frame")
    MsgFrame.Size = UDim2.new(1, -10, 0, 0)
    MsgFrame.Position = UDim2.new(0, 5, 0, 0)
    MsgFrame.AutomaticSize = Enum.AutomaticSize.Y
    MsgFrame.BackgroundColor3 = isOwn and Color3.fromRGB(60, 30, 90) or Color3.fromRGB(30, 50, 80)
    MsgFrame.BackgroundTransparency = 0.3
    MsgFrame.Parent = ChatDisplay

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = MsgFrame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(150, 100, 200)
    stroke.Parent = MsgFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = MsgFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = MsgFrame

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 14)
    Header.BackgroundTransparency = 1
    Header.TextSize = 10
    Header.Font = Enum.Font.GothamBold
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.TextColor3 = Color3.fromRGB(200, 160, 255)
    Header.RichText = true
    Header.Parent = MsgFrame

    local prefix
    if isOwn then
        prefix = "🔒 <b>You → " .. toDisplay .. "</b>"
    elseif isIncoming then
        prefix = "🔒 <b>" .. fromDisplay .. " → You</b>"
    else
        prefix = "🔒 <b>" .. fromDisplay .. " → " .. toDisplay .. "</b> (creator view)"
    end
    Header.Text = prefix

    if isImageContent(text) then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(0, 100, 0, 100)
        img.BackgroundColor3 = SecondaryBG
        img.Image = formatImageUrl(text)
        img.ScaleType = Enum.ScaleType.Fit
        img.Parent = MsgFrame
        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(0, 6)
        ic.Parent = img
    else
        local Body = Instance.new("TextLabel")
        Body.Size = UDim2.new(1, 0, 0, 0)
        Body.AutomaticSize = Enum.AutomaticSize.Y
        Body.BackgroundTransparency = 1
        Body.TextSize = 12
        Body.Font = Enum.Font.Gotham
        Body.TextXAlignment = Enum.TextXAlignment.Left
        Body.TextColor3 = Color3.fromRGB(255, 255, 255)
        Body.TextWrapped = true
        Body.Text = text
        Body.Parent = MsgFrame
    end
end

-- ==================== SEND AI REPLY ====================
sendAiReply = function(replyText, replyToName, replyToText)
    replyText = tostring(replyText or "")
    if replyText == "" then return end

    local msgId = "ai_" .. tostring(math.floor(tick() * 10000))
    renderedMessageIds[msgId] = true

    local replyData = nil
    if replyToName and replyToText then
        local preview = tostring(replyToText)
        if #preview > 40 then preview = string.sub(preview, 1, 37) .. "..." end
        replyData = {Sender = replyToName, Text = preview}
    end

    local payloadData = {
        Sender = AI_NAME,
        DisplayName = AI_NAME,
        Text = replyText,
        Timestamp = os.time(),
        UserId = 0,
        IsSystem = false,
        IsAI = true,
        CustomId = msgId,
        ReplyData = replyData
    }

    addMessageToUI(AI_NAME, replyText, 0, false, AI_NAME, replyData)
    sendNotification(AI_NAME, replyText, 0)

    local payload = HttpService:JSONEncode(payloadData)
    task.spawn(function()
        pcall(function()
            local putUrl = string.gsub(FirebaseURL, ".json", "/" .. msgId .. ".json")
            request_func({Url = putUrl, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = payload})
        end)
    end)
end

-- ==================== SEND MESSAGE & COMMANDS ====================
function sendSecretMessage(message, isSystemMsg)
    message = tostring(message or "")
    if message == "" or string.gsub(message, " ", "") == "" then return end

    local isCreator = Creators[LocalPlayer.UserId] or Creators[LocalPlayer.Name]
    local args = string.split(message, " ")
    local cmd = string.lower(args[1] or "")

    if cmd == "/ai" or cmd == "!ai" then
        local question = table.concat(args, " ", 2)
        if question == "" or question:gsub(" ", "") == "" then
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: /ai <your question>", nil, true)
            return
        end
        TextBox.Text = ""

        local visibleMsgId = "msg_" .. tostring(LocalPlayer.UserId) .. "_" .. tostring(math.floor(tick() * 10000))
        renderedMessageIds[visibleMsgId] = true

        local payloadData = {
            Sender = LocalPlayer.Name,
            DisplayName = LocalPlayer.DisplayName,
            Text = message,
            Timestamp = os.time(),
            UserId = LocalPlayer.UserId,
            IsSystem = false,
            CustomId = visibleMsgId
        }

        addMessageToUI(LocalPlayer.Name, message, LocalPlayer.UserId, false, LocalPlayer.DisplayName, nil)
        createOverheadBubble(LocalPlayer, message)
        sendNotification(LocalPlayer.DisplayName, message, LocalPlayer.UserId)

        task.spawn(function()
            pcall(function()
                local putUrl = string.gsub(FirebaseURL, ".json", "/" .. visibleMsgId .. ".json")
                request_func({Url = putUrl, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(payloadData)})
            end)
        end)

        local typingMsgId = "ai_typing_" .. tostring(math.floor(tick() * 10000))
        renderedMessageIds[typingMsgId] = true

        local typingPayload = {
            Sender = AI_NAME,
            DisplayName = AI_NAME,
            Text = "typing...",
            Timestamp = os.time(),
            UserId = 0,
            IsSystem = false,
            IsAI = true,
            IsTyping = true,
            CustomId = typingMsgId,
            ReplyData = {Sender = LocalPlayer.DisplayName, Text = message}
        }
        local typingFrame = addMessageToUI(AI_NAME, "typing...", 0, false, AI_NAME, {Sender = LocalPlayer.DisplayName, Text = message}, true)

        task.spawn(function()
            pcall(function()
                local putUrl = string.gsub(FirebaseURL, ".json", "/" .. typingMsgId .. ".json")
                request_func({Url = putUrl, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(typingPayload)})
            end)
        end)

        task.spawn(function()
            local startTime = tick()
            local ok, answer = processAiRequest(question, LocalPlayer.UserId, LocalPlayer.Name, false)
            local finalAnswer = ok and answer or tostring(answer)

            local elapsed = tick() - startTime
            if elapsed < 0.8 then
                task.wait(0.8 - elapsed)
            end

            if typingFrame and typingFrame.Parent then
                typingFrame:Destroy()
            end

            sendAiReply(finalAnswer, LocalPlayer.DisplayName, message)
        end)
        return
    end

    if cmd == "!pvtoff" or cmd == "/pvtoff" then
        stopPrivateChat()
        TextBox.Text = ""
        addMessageToUI(nil, "⚡ [SYSTEM] : Private chat disabled.", nil, true)
        return
    end

    if cmd == "!rank" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can use this command!", nil, true)
            return
        end
        if #args >= 3 then
            local targetUsername = args[#args]
            local rankName = table.concat(args, " ", 2, #args - 1)
            local success = updateRankInFirebase(targetUsername, rankName)
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " has given " .. rankName .. " rank to " .. targetUsername .. ".", true)
                fetchRanksFromFirebase()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to update database.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !rank <rank name> <username>", nil, true)
        end
        return
    end

    if cmd == "!removerank" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can use this command!", nil, true)
            return
        end
        if #args >= 2 then
            local targetUsername = args[2]
            local success = removeRankFromFirebase(targetUsername)
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " has removed rank from " .. targetUsername .. ".", true)
                fetchRanksFromFirebase()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to remove rank.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !removerank <username>", nil, true)
        end
        return
    end

    -- ============ !aura2 ============
    if cmd == "!aura2" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can give Auras!", nil, true)
            return
        end
        if #args >= 2 then
            local targetUsername = args[2]
            local targetLower = string.lower(targetUsername)
            local currColor = (SyncedAuras[targetLower] and SyncedAuras[targetLower].Color) or "pink"
            local success = updateAuraDataInFirebase(targetUsername, {Active = true, Color = currColor, Type = "mecha2"})
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " granted mecha2 Aura to " .. targetUsername .. ".", true)
                SyncedAuras[targetLower] = {Active = true, Color = currColor, Type = "mecha2"}
                applyAuras()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to update database.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !aura2 <username>", nil, true)
        end
        return
    end

    -- ============ !aura (mecha, mecha2, orbit + 10 new function auras) ============
    if cmd == "!aura" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can give Auras!", nil, true)
            return
        end
        local selectedAura = "mecha"
        local targetUsername = ""
        if #args == 2 then
            targetUsername = args[2]
        elseif #args >= 3 then
            selectedAura = string.lower(args[2])
            targetUsername = args[3]
        end
        if targetUsername ~= "" then
            local isValidStructure = AuraRegistry[selectedAura] ~= nil
            local isValidFunction = FunctionAuras[selectedAura] ~= nil
            if not isValidStructure and not isValidFunction then
                addMessageToUI(nil,
                    "⚡ [SYSTEM] : Invalid aura! Valid: mecha, mecha2, orbit, divine_ring, hydra_strike, demon_hands, heart_aura, letter_a, letter_n, normal_halo, angel_wings, big_sniper, illuminati",
                    nil, true)
                return
            end
            local targetLower = string.lower(targetUsername)
            local currColor = (SyncedAuras[targetLower] and SyncedAuras[targetLower].Color) or "pink"
            local success = updateAuraDataInFirebase(targetUsername, {Active = true, Color = currColor, Type = selectedAura})
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " granted " .. selectedAura .. " Aura to " .. targetUsername .. ".", true)
                SyncedAuras[targetLower] = {Active = true, Color = currColor, Type = selectedAura}
                -- Force refresh
                for _, plr in ipairs(Players:GetPlayers()) do
                    if string.lower(plr.Name) == targetLower then
                        removeAuraForPlayer(plr)
                    end
                end
                applyAuras()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to update database.", nil, true)
            end
        else
            addMessageToUI(nil, "⚡ [SYSTEM] : Usage: !aura <auraname> <username>", nil, true)
        end
        return
    end

    if cmd == "!auraround" or cmd == "/auraround" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can give Orbit Auras!", nil, true)
            return
        end
        if #args >= 2 then
            local targetUsername = args[2]
            local targetLower = string.lower(targetUsername)
            local currColor = (SyncedAuras[targetLower] and SyncedAuras[targetLower].Color) or "pink"
            local success = updateAuraDataInFirebase(targetUsername, {Active = true, Color = currColor, Type = "orbit"})
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " granted Orbit Aura to " .. targetUsername .. ".", true)
                SyncedAuras[targetLower] = {Active = true, Color = currColor, Type = "orbit"}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if string.lower(plr.Name) == targetLower then
                        removeAuraForPlayer(plr)
                    end
                end
                applyAuras()
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Failed to update database.", nil, true)
            end
        end
        return
    end

    if cmd == "!colouraura" or cmd == "!auracolour" or cmd == "!coloraura" or cmd == "!auracolor" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can change Aura Colors!", nil, true)
            return
        end
        if #args >= 3 then
            local colorName = string.lower(args[2])
            local targetUsername = args[3]
            local targetLower = string.lower(targetUsername)
            if not AuraColors[colorName] then
                addMessageToUI(nil, "⚡ [SYSTEM] : Invalid color! Use pink, golden, black, red, green, blue, white, silver.", nil, true)
                return
            end
            local currentType = (SyncedAuras[targetLower] and SyncedAuras[targetLower].Type) or "mecha"
            local success = updateAuraDataInFirebase(targetUsername, {Active = true, Color = colorName, Type = currentType})
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Aura color updated to " .. colorName .. " for " .. targetUsername .. ".", true)
                SyncedAuras[targetLower] = {Active = true, Color = colorName, Type = currentType}
                applyAuras()
            end
        end
        return
    end

    if cmd == "!removeaura" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can remove Auras!", nil, true)
            return
        end
        if #args >= 2 then
            local targetUsername = args[2]
            local success = updateAuraDataInFirebase(targetUsername, nil)
            if success then
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " removed Aura from " .. targetUsername .. ".", true)
                SyncedAuras[string.lower(targetUsername)] = nil
                applyAuras()
            end
        end
        return
    end

    if cmd == "!kick" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can kick!", nil, true)
            return
        end
        if #args >= 2 then
            local targetName = args[2]
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer then
                pcall(function() targetPlayer:Kick("Kicked by Creator " .. LocalPlayer.Name .. " via ITMEANS Rechat") end)
                TextBox.Text = ""
                sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " has kicked " .. targetName .. ".", true)
            else
                addMessageToUI(nil, "⚡ [SYSTEM] : Player not found.", nil, true)
            end
        end
        return
    end

    if cmd == "!ban" then
        if not isCreator then
            addMessageToUI(nil, "⚡ [SYSTEM] : Only Creators can ban!", nil, true)
            return
        end
        if #args >= 2 then
            local targetName = args[2]
            BannedUsers[string.lower(targetName)] = true
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer then
                pcall(function() targetPlayer:Kick("Banned by Creator " .. LocalPlayer.Name .. " via ITMEANS Rechat") end)
            end
            TextBox.Text = ""
            sendSecretMessage("⚡ [SYSTEM] : Creator " .. LocalPlayer.Name .. " has banned " .. targetName .. ".", true)
        end
        return
    end

    local senderLower = string.lower(LocalPlayer.Name)
    local hasCreatorBypass = isCreator or (RGBRanks[senderLower] and string.lower(tostring(RGBRanks[senderLower])) == "creator")

    if not isSystemMsg and not hasCreatorBypass then
        if (tick() - LastMessageTime) < MESSAGE_COOLDOWN then
            addMessageToUI(nil, "⚡ [SYSTEM] : Slow down! Anti-spam active.", nil, true)
            return
        end
        LastMessageTime = tick()
    end

    if string.lower(message) == "/help" then
        TextBox.Text = ""
        addMessageToUI(nil, "⚡ [SYSTEM] : Commands: /ai <question>, !rank, !removerank, !aura, !aura2, !auracolour, !removeaura, !kick, !ban, !pvtoff", nil, true)
        return
    end

    if activePvtTarget and not isSystemMsg then
        local pvtMsgId = "pvt_" .. tostring(LocalPlayer.UserId) .. "_" .. tostring(math.floor(tick() * 10000))
        renderedPvtMsgIds[pvtMsgId] = true
        local pvtData = {
            From = LocalPlayer.Name,
            FromDisplayName = LocalPlayer.DisplayName,
            FromUserId = LocalPlayer.UserId,
            To = activePvtTarget.Name,
            ToDisplayName = activePvtTarget.DisplayName,
            Text = message,
            Timestamp = os.time()
        }
        addPvtMessageToUI(LocalPlayer.Name, LocalPlayer.DisplayName, activePvtTarget.Name, activePvtTarget.DisplayName, message)
        TextBox.Text = ""
        task.spawn(function()
            pcall(function()
                local putUrl = string.gsub(FirebasePrivateURL, ".json", "/" .. pvtMsgId .. ".json")
                request_func({Url = putUrl, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(pvtData)})
            end)
        end)
        return
    end

    local msgId = "msg_" .. tostring(LocalPlayer.UserId) .. "_" .. tostring(math.floor(tick() * 10000))
    renderedMessageIds[msgId] = true
    local payloadData = {
        Sender = isSystemMsg and "SYSTEM" or LocalPlayer.Name,
        DisplayName = isSystemMsg and "SYSTEM" or LocalPlayer.DisplayName,
        Text = message,
        Timestamp = os.time(),
        UserId = isSystemMsg and 0 or LocalPlayer.UserId,
        IsSystem = isSystemMsg or false,
        CustomId = msgId
    }
    if isSystemMsg then
        addMessageToUI(nil, message, nil, true)
        sendNotification("SYSTEM", message, LocalPlayer.UserId)
    else
        addMessageToUI(LocalPlayer.Name, message, LocalPlayer.UserId, false, LocalPlayer.DisplayName, activeReplyContext)
        createOverheadBubble(LocalPlayer, message)
        sendNotification(LocalPlayer.DisplayName, message, LocalPlayer.UserId)
    end
    TextBox.Text = ""

    if activeReplyContext and not isSystemMsg then
        payloadData.ReplyData = activeReplyContext
        activeReplyContext = nil
        updateReplyBar()
    end
    local payload = HttpService:JSONEncode(payloadData)
    task.spawn(function()
        pcall(function()
            local putUrl = string.gsub(FirebaseURL, ".json", "/" .. msgId .. ".json")
            request_func({Url = putUrl, Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = payload})
        end)
    end)
end

local function broadcastJoinMessage()
    local playerDisplayName = LocalPlayer.DisplayName
    sendSecretMessage("⚡ [SYSTEM] : " .. playerDisplayName .. " HAS JOINED THE CHAT!", true)
    sendNotification("SYSTEM", playerDisplayName .. " has joined the chat!", LocalPlayer.UserId)
    sendSecretMessage("☆ You can click on the camera option on left of your textbox to send stickers.", true)
    sendSecretMessage("☆ You can click and hold on any player message for 3 second for PVT, COPY TEXT & PROFILE option.", true)
    sendSecretMessage("☆ You can use this command to use AI :- /ai question.", true)
end

local function showCreatorJoinNotification(displayName)
    local notifScreen = Instance.new("ScreenGui")
    notifScreen.Name = "CreatorJoinNotif"
    notifScreen.Parent = CoreGui
    notifScreen.ResetOnSpawn = false
    notifScreen.IgnoreGuiInset = true

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 120)
    frame.Position = UDim2.new(0.5, -250, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = notifScreen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, -40)
    label.Position = UDim2.new(0, 20, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "[System]: Creator " .. displayName .. " has joined the chat!"
    label.TextSize = 24
    label.Font = Enum.Font.GothamBlack
    label.TextWrapped = true
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Parent = frame

    local rgbConnection
    rgbConnection = RunService.RenderStepped:Connect(function()
        local hue = (tick() * 1.5) % 1
        local color = Color3.fromHSV(hue, 0.9, 1)
        stroke.Color = color
        label.TextColor3 = color
    end)

    task.delay(3, function()
        rgbConnection:Disconnect()
        TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1, Position = UDim2.new(0.5, -250, 0.2, -50)}):Play()
        task.delay(0.5, function() notifScreen:Destroy() end)
    end)
end

Players.PlayerAdded:Connect(function(plr)
    if plr.Name == "itmeans0011" then
        showCreatorJoinNotification(plr.DisplayName)
    end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Name == "itmeans0011" then
        showCreatorJoinNotification(plr.DisplayName)
        break
    end
end

Players.PlayerAdded:Connect(function(plr)
    if BannedUsers[string.lower(plr.Name)] then
        pcall(function() plr:Kick("You are banned from this server via ITMEANS Rechat") end)
    end
end)

SendBtn.Activated:Connect(function()
    sendSecretMessage(TextBox.Text)
    TextBox.Text = ""
end)

TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendSecretMessage(TextBox.Text)
        TextBox.Text = ""
    end
end)

local lastTypingSent = 0
TextBox:GetPropertyChangedSignal("Text"):Connect(function()
    if TextBox.Text ~= "" and (tick() - lastTypingSent) > 2 then
        lastTypingSent = tick()
        task.spawn(function()
            pcall(function()
                request_func({
                    Url = string.gsub(FirebaseTypingURL, ".json", "/" .. LocalPlayer.UserId .. ".json"),
                    Method = "PUT",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({Name = LocalPlayer.Name, Time = os.time()})
                })
            end)
        end)
    end
end)

-- ==================== MAIN INIT ====================
task.spawn(function()
    sendNotification("ITMEANS RECHAT", "Script executed & loaded successfully!", LocalPlayer.UserId)

    local WelcomeScreen = Instance.new("ScreenGui")
    WelcomeScreen.Name = "ITMEANS_Welcome"
    WelcomeScreen.Parent = CoreGui
    WelcomeScreen.ResetOnSpawn = false
    WelcomeScreen.IgnoreGuiInset = true

    local WelcomeBg = Instance.new("Frame")
    WelcomeBg.Size = UDim2.new(1, 0, 1, 0)
    WelcomeBg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    WelcomeBg.BorderSizePixel = 0
    WelcomeBg.Parent = WelcomeScreen

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 10, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    }
    Gradient.Rotation = 45
    Gradient.Parent = WelcomeBg

    local WelcomeCard = Instance.new("Frame")
    WelcomeCard.Size = UDim2.new(0, 0, 0, 0)
    WelcomeCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    WelcomeCard.BackgroundColor3 = SecondaryBG
    WelcomeCard.BorderSizePixel = 0
    WelcomeCard.ClipsDescendants = true
    WelcomeCard.Parent = WelcomeScreen

    local WCorner = Instance.new("UICorner")
    WCorner.CornerRadius = UDim.new(0, 18)
    WCorner.Parent = WelcomeCard

    local RGBStroke = Instance.new("UIStroke")
    RGBStroke.Thickness = 3
    RGBStroke.Parent = WelcomeCard

    TweenService:Create(WelcomeCard, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 350, 0, 220),
        Position = UDim2.new(0.5, -175, 0.5, -110)
    }):Play()

    task.spawn(function()
        while WelcomeCard and WelcomeCard.Parent do
            local hue = tick() % 6 / 6
            RGBStroke.Color = Color3.fromHSV(hue, 0.9, 1)
            task.wait()
        end
    end)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -30, 0, 35)
    TitleLabel.Position = UDim2.new(0, 15, 0, 35)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = ""
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 20
    TitleLabel.Parent = WelcomeCard

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(1, -30, 0, 25)
    SubtitleLabel.Position = UDim2.new(0, 15, 0, 75)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = ""
    SubtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextSize = 12
    SubtitleLabel.Parent = WelcomeCard

    local ContinueBtn = Instance.new("TextButton")
    ContinueBtn.Size = UDim2.new(0, 120, 0, 35)
    ContinueBtn.Position = UDim2.new(0.5, -60, 1, -50)
    ContinueBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ContinueBtn.Text = ""
    ContinueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ContinueBtn.Font = Enum.Font.GothamBold
    ContinueBtn.TextSize = 14
    ContinueBtn.AutoButtonColor = false
    ContinueBtn.Parent = WelcomeCard

    local ContCorner = Instance.new("UICorner")
    ContCorner.CornerRadius = UDim.new(0, 8)
    ContCorner.Parent = ContinueBtn

    task.wait(0.2)
    typeWrite(TitleLabel, "WELCOME TO ITMEANS RECHAT", 0.04)
    task.wait(0.2)
    typeWrite(SubtitleLabel, "Hello " .. LocalPlayer.DisplayName .. ", Click below to start chatting secretly.", 0.03)
    task.wait(0.2)
    ContinueBtn.Text = "CONTINUE"

    ContinueBtn.MouseEnter:Connect(function()
        TweenService:Create(ContinueBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 65, 80)}):Play()
    end)
    ContinueBtn.MouseLeave:Connect(function()
        TweenService:Create(ContinueBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
    end)

    ContinueBtn.Activated:Connect(function()
        playSound(SOUND_TOGGLE)
        TweenService:Create(WelcomeCard, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.6)
        WelcomeScreen:Destroy()

        IsFullyLoaded = true
        ScreenGui.Enabled = true
        broadcastJoinMessage()

        local RE = ReplicatedStorage:WaitForChild("RE", 5)
        if RE then
            local NameRemote = RE:WaitForChild("1RPNam1eTex1t", 5)
            local ColorRemote = RE:WaitForChild("1RPNam1eColo1r", 5)
            if NameRemote and ColorRemote then
                task.spawn(function()
                    task.wait(1)
                    pcall(function()
                        NameRemote:FireServer("RolePlayName"," ○☆ITMEANS RECHAT☆○")
                        NameRemote:FireServer("RolePlayBio"," ︵‿WELCOME DEAR, "..string.upper(LocalPlayer.DisplayName or LocalPlayer.Name))
                    end)
                    while true do
                        local c = Color3.fromHSV(tick()%5/5,1,1)
                        pcall(function()
                            ColorRemote:FireServer("PickingRPNameColor",c)
                            ColorRemote:FireServer("PickingRPBioColor",c)
                        end)
                        task.wait(0.1)
                    end
                end)
            end
        end
    end)
end)

-- ==================== PUBLIC MESSAGE POLLING (WITH DEDUP + JOIN NOTIFY) ====================
task.spawn(function()
    while task.wait(1.5) do
        if IsFullyLoaded then
            pcall(function()
                local response = request_func({Url = FirebaseURL, Method = "GET"})
                if response.StatusCode == 200 and response.Body ~= "null" then
                    local data = HttpService:JSONDecode(response.Body)
                    if data then
                        local msgList = {}
                        for key, info in pairs(data) do
                            info.Key = key
                            table.insert(msgList, info)
                        end
                        table.sort(msgList, function(a, b) return (a.Timestamp or 0) < (b.Timestamp or 0) end)
                        for _, msg in ipairs(msgList) do
                            local alreadyRendered = renderedMessageIds[msg.Key] or (msg.CustomId and renderedMessageIds[msg.CustomId])
                            if (msg.Timestamp or 0) > ScriptStartTime and not alreadyRendered then
                                renderedMessageIds[msg.Key] = true
                                if msg.CustomId then
                                    renderedMessageIds[msg.CustomId] = true
                                end

                                if msg.IsTyping then
                                    -- skip typing
                                elseif msg.IsSystem then
                                    addMessageToUI(nil, msg.Text, nil, true)
                                    if string.find(string.upper(msg.Text), "JOINED THE CHAT") then
                                        sendNotification("SYSTEM", msg.Text, 0)
                                    end
                                else
                                    addMessageToUI(msg.Sender, msg.Text, msg.UserId, false, msg.DisplayName, msg.ReplyData)
                                    sendNotification(msg.DisplayName or msg.Sender, msg.Text, msg.UserId)
                                    local actualPlr = Players:GetPlayerByUserId(msg.UserId)
                                    if actualPlr and actualPlr ~= LocalPlayer then
                                        createOverheadBubble(actualPlr, msg.Text)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== PRIVATE MESSAGE POLLING ====================
task.spawn(function()
    while task.wait(1.5) do
        if IsFullyLoaded then
            pcall(function()
                local response = request_func({Url = FirebasePrivateURL, Method = "GET"})
                if response and response.StatusCode == 200 and response.Body ~= "null" then
                    local data = HttpService:JSONDecode(response.Body)
                    if data then
                        local msgList = {}
                        for key, info in pairs(data) do
                            info.Key = key
                            table.insert(msgList, info)
                        end
                        table.sort(msgList, function(a, b) return (a.Timestamp or 0) < (b.Timestamp or 0) end)
                        local isCreator = Creators[LocalPlayer.UserId] or Creators[LocalPlayer.Name]
                        local myName = LocalPlayer.Name
                        for _, msg in ipairs(msgList) do
                            if (msg.Timestamp or 0) > ScriptStartTime and not renderedPvtMsgIds[msg.Key] then
                                renderedPvtMsgIds[msg.Key] = true
                                if msg.To == myName then
                                    addPvtMessageToUI(msg.From, msg.FromDisplayName or msg.From, msg.To, msg.ToDisplayName or msg.To, msg.Text)
                                    sendNotification("🔒 " .. (msg.FromDisplayName or msg.From), msg.Text, msg.FromUserId)
                                elseif msg.From == myName then
                                    -- skip
                                elseif isCreator then
                                    addPvtMessageToUI(msg.From, msg.FromDisplayName or msg.From, msg.To, msg.ToDisplayName or msg.To, msg.Text)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== RANK & AURA SYNC POLLING ====================
task.spawn(function()
    while task.wait(5) do
        if IsFullyLoaded then
            fetchRanksFromFirebase()
            fetchAurasFromFirebase()
            applyAuras()
        end
    end
end)
