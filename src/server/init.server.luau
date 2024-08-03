local server = game.ServerScriptService.Server
local tunnel = require(server.TunnelGenerator)
local dataManager = require(server.DataManager)
local click = require(server.Click)

function onPlayerAdded(player: Player)
    dataManager.onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character: Model)
        local humanoid = character:FindFirstChildOfClass('Humanoid') :: Humanoid
        humanoid.WalkSpeed = 30
        humanoid.JumpPower = 100
    end)
end

function init()
    game.Players.PlayerAdded:Connect(onPlayerAdded)
    tunnel.createTunnel()
end

dataManager.init()
click.init()
init()
