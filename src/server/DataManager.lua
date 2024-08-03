local shared = game.ReplicatedStorage.Shared
local remotes = game.ReplicatedStorage.Remotes
local types = require(shared.Types)

local sessionData: {
    [Player]: types.PlayerData
} = {}


function onPlayerAdded(player: Player)
    sessionData[player] = {
        ammo = {1, 1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6, 6},
        playerItems = Instance.new("Folder"),
        canSpawnItem = true,
    }

    sessionData[player].playerItems.Parent = workspace
    sessionData[player].playerItems.Name = player.UserId
end

function onPlayerRemoved(player: Player)
    sessionData[player] = nil
end

function getPlayerData(player: Player)
    return sessionData[player]
end

function addAmmo(player: Player, value: number)
    table.insert(sessionData[player].ammo, value)
end

function removeAmmo(player: Player)
    table.remove(sessionData[player].ammo, 1)
    sessionData[player].canSpawnItem = false
end

function resetSpawnItem(player: Player)
    sessionData[player].canSpawnItem = true
end

function init()
    remotes.Data.OnServerInvoke = getPlayerData
end

return {

    init = init,

    onPlayerAdded = onPlayerAdded,
    onPlayerRemoved = onPlayerRemoved,
    getPlayerData = getPlayerData,
    addAmmo = addAmmo,
    removeAmmo = removeAmmo,
    resetSpawnItem = resetSpawnItem,
}