--Anti Fling #1
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local connections = {}
local isEnabled = true

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiFlingIndicator"
screenGui.ResetOnSpawn = false

local uiParent = pcall(function() return CoreGui.RobloxGui end) and CoreGui or localPlayer:WaitForChild("PlayerGui")
screenGui.Parent = uiParent

local statusLabel = Instance.new("TextButton")
statusLabel.Name = "StatusButton"
statusLabel.Size = UDim2.new(0, 200, 0, 30)
statusLabel.Position = UDim2.new(0, 15, 1, -45)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Anti-Fling: Enabled"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
statusLabel.TextSize = 16
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = screenGui

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1.5
uiStroke.Color = Color3.fromRGB(0, 0, 0)
uiStroke.Transparency = 0.3
uiStroke.Parent = statusLabel

local function updateUI()
	if isEnabled then
		statusLabel.Text = "Anti-Fling: Enabled"
		statusLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
	else
		statusLabel.Text = "Anti-Fling: Disabled"
		statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end

local function setupCharacterCollision(character)
	local function disableCollide(part)
		if isEnabled and part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	for _, part in ipairs(character:GetChildren()) do
		disableCollide(part)
	end

	local childAddedConn = character.ChildAdded:Connect(disableCollide)

	local steppedConn = RunService.Stepped:Connect(function()
		if isEnabled and character:IsDescendantOf(workspace) then
			for _, part in ipairs(character:GetChildren()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end)

	character.Destroying:Connect(function()
		childAddedConn:Disconnect()
		steppedConn:Disconnect()
	end)
end

local function trackPlayer(player)
	if player == localPlayer then return end
	local charAddedConn = player.CharacterAdded:Connect(setupCharacterCollision)
	if player.Character then
		setupCharacterCollision(player.Character)
	end
	connections[player] = charAddedConn
end

local function untrackPlayer(player)
	if connections[player] then
		connections[player]:Disconnect()
		connections[player] = nil
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	trackPlayer(player)
end

Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(untrackPlayer)

statusLabel.MouseButton1Click:Connect(function()
	isEnabled = not isEnabled
	updateUI()
end)

localPlayer.Chatted:Connect(function(msg)
	msg = msg:lower()
	if msg == ";af on" or msg == ";antifling on" then
		isEnabled = true
	elseif msg == ";af off" or msg == ";antifling off" then
		isEnabled = false
	end
	updateUI()
end)
