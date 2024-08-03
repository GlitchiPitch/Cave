local shared = game.ReplicatedStorage.Shared
local server = game.ServerScriptService.Server
local remotes = game.ReplicatedStorage.Remotes

local dataManager = require(server.DataManager)
local taskTimer = require(server.TaskTimer)
local types = require(shared.Types)

-- all items must be anchored in studio
local items: Folder & {Model | BasePart} = game.ServerStorage.Items:GetChildren()

function createItem(player: Player, info: types.ClickInvokeInfo)

    local playerData = dataManager.getPlayerData(player)
    if playerData.canSpawnItem then
        local checkTarget = info.mouseTarget ~= nil and info.mouseTarget:GetAttribute(types.WALL_ATTR) == types.WALL_ATTR_VALUE :: boolean
        local checkAmmo = #playerData.ammo > 0 :: boolean
        if checkTarget and checkAmmo then
            
            local item = items[playerData.ammo[1]]:Clone()
            item.Parent = playerData.playerItems
            item:PivotTo(info.mouseHit)
            dataManager.removeAmmo(player)

            taskTimer.startTimer(3, function()
                dataManager.resetSpawnItem(player)
            end)

            return true, #playerData.ammo
        else
            return false, (not checkTarget and "wrong target") or (checkAmmo and "empty ammo")
        end
    else
        return false, "Reload"
    end
end

local actions = {
    createItem = createItem,
}

function invoke(player: Player, action: string, ...)
    if actions[action] then
        return actions[action](player, ...)
    end
end

function init(serverData: {})
    remotes.Click.OnServerInvoke = invoke
end

return {
    init = init,
}
