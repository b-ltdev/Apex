repeat task.wait() until game:IsLoaded()

local PlaceId = game.PlaceId

if PlaceId == 0 or PlaceId == nil then
	queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/b-ltdev/Apex/refs/heads/master/main.lua"))
    return
end

local Success, Script = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/b-ltdev/Apex/refs/heads/master/modules/" .. tostring(PlaceId) .. ".lua")
end)

if not Success or not Script or Script == "" then
    warn("This game is not supported by Apex!")
    return
end

queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/b-ltdev/Apex/refs/heads/master/main.lua"))
return loadstring(Script)()