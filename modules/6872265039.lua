local function Queue(typeName)
	game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("joinQueue"):FireServer({queueType = typeName})
end

Queue("skywars_to2")