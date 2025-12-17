local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LootRange = 18
local LootDelay = 0.2
local QueueDelay = 2
local Player = Players.LocalPlayer
local Delays = {}

local function Queue(typeName)
	ReplicatedStorage:WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("joinQueue"):FireServer({queueType = typeName})
end

local function GetNetRemote(name)
	local net = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged")
	return net and net:FindFirstChild(name)
end

local setObservedChest = GetNetRemote("Inventory/SetObservedChest")
local chestGetItem = GetNetRemote("Inventory/ChestGetItem")

local function GetTopBarTimer()
	local gui = Player:WaitForChild("PlayerGui"):WaitForChild("TopBarAppGui"):WaitForChild("TopBarApp")
	local minutesTab = gui:WaitForChild("2")
	local timerLabel = minutesTab:WaitForChild("5")
	return timerLabel
end

local timerLabel = GetTopBarTimer()

local function HasMatchStarted()
	local text = timerLabel.Text
	return text and text ~= "00:00"
end

local function CanResetMatch()
	local text = timerLabel.Text
	if not text or text == "00:00" then
		return false
	end

	local mm, ss = text:match("(%d+):(%d+)")
	if not mm or not ss then
		return false
	end

	mm = tonumber(mm)
	ss = tonumber(ss)
	if not mm or not ss then
		return false
	end

	if mm == 0 then
		return ss >= 31
	end

	return false
end

local function GetChestPosition(model)
	if not model then
		return nil
	end

	if model:IsA("BasePart") then
		return model.Position
	end

	local part = model:FindFirstChildWhichIsA("BasePart")
	if part then
		return part.Position
	end

	local ok, pivot = pcall(function()
		return model:GetPivot()
	end)
	return ok and pivot.Position
end

local function GetNearestChest(root)
	local bestChest
	local bestPos
	local bestDistance = math.huge
	for _, chestModel in ipairs(CollectionService:GetTagged("chest")) do
		local pos = GetChestPosition(chestModel)
		if pos then
			local dist = (root.Position - pos).Magnitude
			if dist < bestDistance then
				bestDistance = dist
				bestChest = chestModel
				bestPos = pos
			end
		end
	end
	return bestChest, bestPos
end

local function WalkToChest(pos)
	local character = Player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or not pos then
		return
	end

	local reached
	local conn
	conn = humanoid.MoveToFinished:Connect(function(result)
		reached = result
		if conn then
			conn:Disconnect()
		end
	end)

	humanoid:MoveTo(pos)
	local start = tick()
	repeat
		task.wait()
	until reached or tick() - start > 3
end

local function LootChest(chestModel)
	local chestValue = chestModel and chestModel:FindFirstChild("ChestFolderValue")
	local chest = chestValue and chestValue.Value
	if not chest then
		return false
	end

	if (Delays[chest] or 0) > tick() then
		return false
	end

	local chestItems = chest:GetChildren()
	if #chestItems <= 1 then
		return false
	end

	Delays[chest] = tick() + LootDelay
	setObservedChest:FireServer(chest)
	for _, item in ipairs(chestItems) do
		if item:IsA("Accessory") then
			task.spawn(function()
				pcall(function()
					chestGetItem:InvokeServer(chest, item)
				end)
			end)
		end
	end
	setObservedChest:FireServer(nil)
	return true
end

local function ResetAndQueue()
	local charHumanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
	if charHumanoid and charHumanoid.Health > 0 then
		charHumanoid.Health = 0
	end
	Queue("skywars_to2")
end

task.spawn(function()
	local busy = false

	while true do
		if busy or Player.PlayerGui:FindFirstChild("QueueApp") then
			task.wait(1)
			continue
		end

		if not HasMatchStarted() then
			task.wait(0.5)
			continue
		end

		busy = true

		local char = Player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")

		if root then
			local chestModel, chestPos = GetNearestChest(root)
			if chestModel and chestPos then
				WalkToChest(chestPos)
				LootChest(chestModel)
			end
		end

		task.spawn(function()
			if Player.PlayerGui:FindFirstChild("QueueApp") then return end

			local vim = game:GetService("VirtualInputManager")
			vim:SendKeyEvent(true, Enum.KeyCode.W, false, game)
			vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			task.wait(0.1)
			vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
			task.wait(9)
			vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)

			if Player.PlayerGui:FindFirstChild("QueueApp") then return end
			if mouse1click then
				mouse1click()
			end
		end)

		repeat task.wait(0.2) until CanResetMatch()

		if not Player.PlayerGui:FindFirstChild("QueueApp") then
			task.wait(QueueDelay)
			ResetAndQueue()
		end

		local start = tick()
		repeat
			task.wait(0.5)
		until Player.PlayerGui:FindFirstChild("QueueApp") or tick() - start > 12

		if not Player.PlayerGui:FindFirstChild("QueueApp") then
			game:GetService("TeleportService"):Teleport(6872265039, Player)
		end

		busy = false
	end
end)
