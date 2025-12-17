local function Queue(typeName)
	ReplicatedStorage:WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("joinQueue"):FireServer({queueType = typeName})
end

Queue("skywars_to2")