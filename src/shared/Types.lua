
export type Items = {Model}
export type Item = number

export type PlayerData = {
    ammo: {Item},
    playerItems: Folder,
    canSpawnItem: boolean,
}

export type ServerData = {
    items: Folder & {BasePart},
    itemsFolder: Folder?,
}

export type ClickView = {
    mouse: Mouse,
    showMsg: (ammo: number, msg: string) -> (),
    setupAmmoLabel: (ammo: number) -> (),
}

export type ClickInvokeInfo = {
    mouseHit: CFrame,
    mouseTarget: BasePart | nil,
}

local ATTR = "Type"
local WALL_ATTR_VALUE = 'Wall'
local ITEM_ATTR_VALUE = 'Item'
local DIRECTION_WALL_ATTR = 'Dir'
local ITEM_INDEX_ATTR = 'Index'

return {
    ATTR = ATTR,
    WALL_ATTR_VALUE = WALL_ATTR_VALUE,
    ITEM_ATTR_VALUE = ITEM_ATTR_VALUE,
    DIRECTION_WALL_ATTR = DIRECTION_WALL_ATTR,
    ITEM_INDEX_ATTR = ITEM_INDEX_ATTR,
}