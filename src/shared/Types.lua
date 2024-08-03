
export type Items = {Model}
export type Item = number

export type PlayerData = {
    ammo: {Item},
    playerItems: Folder,
    canSpawnItem: boolean,
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

local WALL_ATTR = "Type"
local WALL_ATTR_VALUE = 'Wall'

return {
    WALL_ATTR = WALL_ATTR,
    WALL_ATTR_VALUE = WALL_ATTR_VALUE,
}