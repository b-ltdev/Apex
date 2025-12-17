local function Queue(typeName)
	game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("joinQueue"):FireServer({queueType = typeName})
end

while true do
    if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("QueueApp") then
        Queue("skywars_to2")
    end
    wait(2.5)
end

