local shared = game.ReplicatedStorage.Shared
local serverStorage = game.ServerStorage
local events = serverStorage.Events
local types = require(shared.Types)

local items: {BasePart}
local itemsFolder: Folder
function setupItem(item: BasePart, spawnPoint: BasePart, itemIndex: number)
    local selectionBox = Instance.new("SelectionBox")
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.Parent = item
    selectionBox.Parent = item

    selectionBox.Adornee = item

    clickDetector.MouseHoverEnter:Connect(function(playerWhoHovered)
        selectionBox.Visible = true
    end)
    clickDetector.MouseHoverLeave:Connect(function(playerWhoHovered)
        selectionBox.Visible = false
    end)

    item:SetAttribute(types.ATTR, types.ITEM_ATTR_VALUE)
    item:SetAttribute(types.ITEM_INDEX_ATTR, itemIndex)
    item.Anchored = false
    item.Parent = itemsFolder
    item.Position = spawnPoint.Position
end

function spawnItems(spawnPoint: BasePart)
    for i = 1, 10 do
        local itemIndex = math.random(#items)
        local item = items[itemIndex]:Clone() :: BasePart
        setupItem(item, spawnPoint, itemIndex)
    end
end

function init(serverData: types.ServerData)
    items = serverData.items
    itemsFolder = serverData.itemsFolder
    events.SpawnItem.Event:Connect(spawnItems)
end

return {
    init = init,
}