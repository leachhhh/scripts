-- Universal Chams with Name Tags
-- StarterPlayerScripts -> LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- CONFIG
local ENABLE_CHAMS = true
local UPDATE_INTERVAL = 0.12
local MAX_DISTANCE = 1000
local OUTLINE_ENABLED = true
local OUTLINE_THICKNESS = 1
local TEAM_CHECK = true

local highlights = {}
local nameTags = {}

local function getOrCreateHighlight(character)
    if not character then return nil end
    if highlights[character] and highlights[character].Parent then
        return highlights[character]
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "UniversalChams_Highlight"
    highlight.Adornee = character
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0.3
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = LocalPlayer:WaitForChild("PlayerGui")

    highlights[character] = highlight
    return highlight
end

local function getOrCreateNameTag(player, character)
    if not character then return nil end
    if nameTags[character] and nameTags[character].Parent then
        return nameTags[character]
    end

    local head = character:FindFirstChild("Head")
    if not head then return nil end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "UniversalChams_NameTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextSize = 11 -- Small text
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0.2 -- Outline to keep it readable
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = billboard

    billboard.Parent = LocalPlayer:WaitForChild("PlayerGui")
    nameTags[character] = billboard
    return billboard
end

local function destroyHighlight(character)
    local h = highlights[character]
    if h then
        if h.Parent then pcall(function() h:Destroy() end) end
        highlights[character] = nil
    end

    local tag = nameTags[character]
    if tag then
        if tag.Parent then pcall(function() tag:Destroy() end) end
        nameTags[character] = nil
    end
end

local function computeColors(targetPlayer, targetHumanoid)
    local fill = Color3.new(1, 0, 0)
    local outline = Color3.new(0.2, 0, 0)
    local fillTransparency = 0.65
    local outlineTransparency = 0.3

    local isTeammate = false
    if TEAM_CHECK and LocalPlayer and targetPlayer then
        if LocalPlayer.Team and targetPlayer.Team then
            isTeammate = (LocalPlayer.Team == targetPlayer.Team)
        else
            isTeammate = (LocalPlayer.TeamColor == targetPlayer.TeamColor)
        end
    end

    if isTeammate then
        local healthRatio = 1
        if targetHumanoid and targetHumanoid.MaxHealth > 0 then
            healthRatio = math.clamp(targetHumanoid.Health / targetHumanoid.MaxHealth, 0, 1)
        end
        local minG = 0.08
        local gValue = minG + (0.92 * healthRatio)
        fill = Color3.new(0, gValue, 0)
        outline = Color3.new(0, math.max(0.2, gValue * 0.6), 0)
        fillTransparency = 0.6 + (1 - healthRatio) * 0.25
        outlineTransparency = 0.3
    else
        fill = Color3.new(1, 0.12, 0.12)
        outline = Color3.new(0.45, 0, 0)
        fillTransparency = 0.6
        outlineTransparency = 0.25
    end

    return fill, outline, fillTransparency, outlineTransparency
end

local function updateCharacterHighlight(player, character)
    if not ENABLE_CHAMS then return end
    if not character or not player then return end
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChildWhichIsA("BasePart")
    if not hrp then
        destroyHighlight(character)
        return
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
        if dist > MAX_DISTANCE then
            destroyHighlight(character)
            return
        end
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local fill, outline, fillT, outlineT = computeColors(player, humanoid)
    local h = getOrCreateHighlight(character)
    local tag = getOrCreateNameTag(player, character)

    if h then
        h.FillColor = fill
        h.OutlineColor = outline
        h.FillTransparency = fillT
        h.OutlineTransparency = outlineT
    end

    if tag and tag:FindFirstChildOfClass("TextLabel") then
        tag.TextLabel.TextColor3 = fill
    end
end

local function onCharacterAdded(player, character)
    destroyHighlight(character)
    character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            destroyHighlight(character)
        end
    end)
    task.spawn(function()
        while character.Parent do
            pcall(function()
                updateCharacterHighlight(player, character)
            end)
            task.wait(UPDATE_INTERVAL)
        end
        destroyHighlight(character)
    end)
end

local function onPlayerAdded(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char) onCharacterAdded(player, char) end)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        onPlayerAdded(p)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(p)
    if p and p.Character then destroyHighlight(p.Character) end
end)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Equals then
        ENABLE_CHAMS = not ENABLE_CHAMS
        if not ENABLE_CHAMS then
            for c,_ in pairs(highlights) do destroyHighlight(c) end
        end
        print("Chams toggled:", ENABLE_CHAMS)
    end
end)

print("✅ Universal Chams v2 loaded — transparent version with Name Tags.")