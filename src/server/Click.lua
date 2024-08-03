local shared = game.ReplicatedStorage.Shared
local server = game.ServerScriptService.Server
local remotes = game.ReplicatedStorage.Remotes

local dataManager = require(server.DataManager)
local taskTimer = require(shared.TaskTimer)
local types = require(shared.Types)

local items: {BasePart}

function createItem(player: Player, info: types.ClickInvokeInfo)

    local playerData = dataManager.getPlayerData(player)
    if playerData.canSpawnItem then
        local checkAmmo = #playerData.ammo > 0 :: boolean
        if checkAmmo then
            local item = items[playerData.ammo[1]]:Clone()
            item.Parent = playerData.playerItems
            item:PivotTo(info.mouseHit)
            dataManager.removeAmmo(player)

            taskTimer.startTimer(3, function()
                dataManager.resetSpawnItem(player)
            end)

            return 'setupAmmoLabel', #playerData.ammo
        else
            return 'showMsg', "empty ammo"
        end
    else
        return 'showMsg', "Reload"
    end
end

function addAmmo(player: Player, info: types.ClickInvokeInfo)
    dataManager.addAmmo(player, info.mouseTarget:GetAttribute(types.ITEM_INDEX_ATTR))
    return 'setupAmmoLabel', #dataManager.getPlayerData(player).ammo
end

local actions = {
    [types.WALL_ATTR_VALUE] = createItem,
    [types.ITEM_ATTR_VALUE] = addAmmo,
}

function invoke(player: Player, info: types.ClickInvokeInfo)
    if info.mouseTarget then
        if actions[info.mouseTarget:GetAttribute(types.ATTR)] then
            return actions[info.mouseTarget:GetAttribute(types.ATTR)](player, info)
        end
    end
end

function init(serverData: types.ServerData)
    items = serverData.items
    remotes.Click.OnServerInvoke = invoke
end

return {
    init = init,
}
