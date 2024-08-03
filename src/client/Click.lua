local shared = game.ReplicatedStorage.Shared
local remotes = game.ReplicatedStorage.Remotes
local types = require(shared.Types)

local view: types.ClickView

function createItem()

    local invokeInfo: types.ClickInvokeInfo = {
        mouseHit = view.mouse.Hit,
        mouseTarget = view.mouse.Target,
    }

    local result: boolean, msg: string | number = remotes.Click:InvokeServer('createItem', invokeInfo)
    -- print(result, msg)
    if result == true then
        view.setupAmmoLabel(msg)
    elseif result == false then
        view.showMsg(msg)
    end

end

function init(view_: types.ClickView)
    view = view_ 
    local playerData = remotes.Data:InvokeServer() :: types.PlayerData
    view.setupAmmoLabel(#playerData.ammo)
end

return {
    init = init,
    createItem = createItem,
}