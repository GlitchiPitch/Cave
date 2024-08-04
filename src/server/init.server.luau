local server = game.ServerScriptService.Server
local shared = game.ReplicatedStorage.Shared

local dataManager = require(server.DataManager)
local types = require(shared.Types)

local tunnel = require(server.TunnelGenerator)
local click = require(server.Click)
local itemsSpawner = require(server.ItemsSpawner)

local items: Folder & {Model | BasePart} = game.ServerStorage.Items:GetChildren()
local itemsFolder: Folder = workspace.Items

function onPlayerAdded(player: Player)
    game.ServerStorage.leaderstats:Clone().Parent = player
    player.CharacterAdded:Connect(function(character: Model)
        dataManager.onPlayerAdded(player)
        local humanoid = character:FindFirstChildOfClass('Humanoid') :: Humanoid
        humanoid.WalkSpeed = 30
        humanoid.JumpPower = 100
    end)
end

function init()
    game.Players.PlayerAdded:Connect(onPlayerAdded)
    game.Players.PlayerRemoving:Connect(dataManager.onPlayerRemoved)
    game.
    tunnel.createTunnel()
end

dataManager.init()
tunnel.init()

click.init({
    items = items,
} :: types.ServerData)

itemsSpawner.init({
    items = items,
    itemsFolder = itemsFolder,
} :: types.ServerData)

init()
