local shared = game.ReplicatedStorage.Shared
local remotes = game.ReplicatedStorage.Remotes
local types = require(shared.Types)
local taskTimer = require(shared.TaskTimer)

local view: types.ClickView
local canInvoke = true

function onClick()
    if canInvoke then 
        canInvoke = false
        taskTimer.startTimer(1, function()
            canInvoke = true
        end)
    else
        return 
    end

    local invokeInfo: types.ClickInvokeInfo = {
        mouseHit = view.mouse.Hit,
        mouseTarget = view.mouse.Target,
    }

    local action: boolean, answer: string | number = remotes.Click:InvokeServer(invokeInfo)

    if view[action] then
        view[action](answer)
    end
end

function init(view_: types.ClickView)
    view = view_ 
    local playerData = remotes.Data:InvokeServer() :: types.PlayerData
    view.setupAmmoLabel(#playerData.ammo)
end

return {
    init = init,
    onClick = onClick,
}