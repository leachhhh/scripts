--Coordinate GUI + TP
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CoordinateGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 230)
frame.Position = UDim2.new(0, 20, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Make GUI draggable
local dragging = false
local dragStart
local startPosition

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Coordinate Teleporter"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Create text box
local function createBox(name, y, defaultText)
	local box = Instance.new("TextBox")
	box.Name = name
	box.Size = UDim2.new(1, -30, 0, 35)
	box.Position = UDim2.new(0, 15, 0, y)
	box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	box.TextSize = 16
	box.Font = Enum.Font.Gotham
	box.Text = defaultText
	box.ClearTextOnFocus = false
	box.Parent = frame

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 6)
	boxCorner.Parent = box

	return box
end

local xBox = createBox("X", 50, "X")
local yBox = createBox("Y", 90, "Y")
local zBox = createBox("Z", 130, "Z")

-- Get Coordinates button
local getButton = Instance.new("TextButton")
getButton.Size = UDim2.new(0.47, -5, 0, 40)
getButton.Position = UDim2.new(0, 15, 0, 175)
getButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
getButton.Text = "Get Coordinates"
getButton.TextColor3 = Color3.fromRGB(255, 255, 255)
getButton.TextSize = 14
getButton.Font = Enum.Font.GothamBold
getButton.Parent = frame

local getCorner = Instance.new("UICorner")
getCorner.CornerRadius = UDim.new(0, 6)
getCorner.Parent = getButton

-- Teleport button
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0.47, -5, 0, 40)
teleportButton.Position = UDim2.new(0.53, 0, 0, 175)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
teleportButton.Text = "Teleport"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.TextSize = 14
teleportButton.Font = Enum.Font.GothamBold
teleportButton.Parent = frame

local teleportCorner = Instance.new("UICorner")
teleportCorner.CornerRadius = UDim.new(0, 6)
teleportCorner.Parent = teleportButton

-- Get current coordinates
getButton.MouseButton1Click:Connect(function()
	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local position = root.Position

	xBox.Text = string.format("%.3f", position.X)
	yBox.Text = string.format("%.3f", position.Y)
	zBox.Text = string.format("%.3f", position.Z)
end)

-- Teleport to coordinates
teleportButton.MouseButton1Click:Connect(function()
	local x = tonumber(xBox.Text)
	local y = tonumber(yBox.Text)
	local z = tonumber(zBox.Text)

	if not x or not y or not z then
		warn("Invalid coordinates")
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	root.CFrame = CFrame.new(x, y, z)
end)
