local shared = game.ReplicatedStorage.Shared
local client = game.StarterPlayer.StarterPlayerScripts.Client
local types = require(shared.Types)

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local mouse = player:GetMouse()

local mainGui = playerGui:WaitForChild('Main') :: ScreenGui & {Ammo: TextLabel}

local click = require(client.Click)

function showMsg(msg: string)
    local ammoValue = mainGui.Ammo.Text
    mainGui.Ammo.Text = msg
    task.wait(2)
    mainGui.Ammo.Text = ammoValue
end

function setupAmmoLabel(ammo: number)
    mainGui.Ammo.Text = ammo
end

function init()
    mouse.Button1Down:Connect(click.onClick)
end

local view: types.ClickView = {
    mouse = mouse,
    showMsg = showMsg,
    setupAmmoLabel = setupAmmoLabel,
}

click.init(view)
init()