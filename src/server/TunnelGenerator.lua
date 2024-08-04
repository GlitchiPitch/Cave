local shared = game.ReplicatedStorage.Shared
local server = game.ServerScriptService.Server
local pg = require(server.PathGenerator)
local obstaclesSpawner = require(server.ObstaclesSpawner)
local types = require(shared.Types)

local blockTemp: Model = game.ServerStorage.Cell
local blocksFolder: Folder = Instance.new("Folder")
blocksFolder.Parent = workspace


function removeWall(i: number, cell: Model, prevPoint: Vector3, nextPoint: Vector3)
	for _, wall: Part in cell:GetChildren() do	
		local dir = wall:GetAttribute(types.DIRECTION_WALL_ATTR)
		if (nextPoint and dir == nextPoint) or (prevPoint and dir == prevPoint) or (i == 1 and dir == -Vector3.zAxis) then
			wall:Destroy()
		end
	end
end

function spawnTunnelBlock(i: number, pathLen: number, currentPoint: Vector3, prevPoint: Vector3, nextPoint: Vector3)
	local block = blockTemp:Clone()
	block.Parent = blocksFolder
	local _, size = block:GetBoundingBox()
	block:PivotTo(CFrame.new(currentPoint * size))

	removeWall(i, block, prevPoint, nextPoint)
	obstaclesSpawner.setupBlock(i, pathLen, block)
end

function createTunnel()
	local path = pg.createTunnelPath()
	for i = 1, #path do

		local nextP = path[i + 1]
		local prevP = path[i - 1]
		nextP = nextP and nextP - path[i]
		prevP = prevP and prevP - path[i]

		spawnTunnelBlock(i, #path, path[i], prevP, nextP)
		-- if i == 3 then
		-- 	break
		-- end
	end
end

return {
	createTunnel = createTunnel,
}
