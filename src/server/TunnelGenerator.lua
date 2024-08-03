local shared = game.ReplicatedStorage.Shared
local server = game.ServerScriptService.Server
local serverStorage = game.ServerStorage

local events = serverStorage.Events

local pg = require(server.PathGenerator)
local types = require(shared.Types)

local blockTemp: Model = game.ServerStorage.Cell
local blocksFolder: Folder = Instance.new("Folder")
blocksFolder.Parent = workspace

local colors = {
	kill = BrickColor.new(21),
	untouched = BrickColor.new(23),
	checkpoint = BrickColor.new(193),
}

function removeWall(i: number, cell: Model, prevPoint: Vector3, nextPoint: Vector3)
	for _, wall: Part in cell:GetChildren() do	
		local dir = wall:GetAttribute(types.DIRECTION_WALL_ATTR)
		if (nextPoint and dir == nextPoint) or (prevPoint and dir == prevPoint) or (i == 1 and dir == -Vector3.zAxis) then
			wall:Destroy()
		end
	end
end

function killWall(wall: Part)
	wall.BrickColor = colors.kill
	wall.Touched:Connect(function(hit: Part)
		local humanoid = hit.Parent:FindFirstChildOfClass('Humanoid') :: Humanoid
		if humanoid then
			-- humanoid.Health = 0
		end
	end)
end

function untouchedWall(wall: Part)
	wall.CanCollide = false
	wall.Transparency = .5
	wall.BrickColor = colors.untouched
end

function setupCheckpoint(checkpoint: Part, itemSpawnPoint: BasePart)
	checkpoint.BrickColor = colors.checkpoint
	checkpoint.Touched:Connect(function(hit: Part)
		if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
			local player = game.Players:GetPlayerFromCharacter(hit.Parent)
			local checkpointData = game.ServerStorage:FindFirstChild("CheckpointData")
			if not checkpointData then
				checkpointData = Instance.new("Model", game.ServerStorage)
				checkpointData.Name = "CheckpointData"
				events.SpawnItem:Fire(itemSpawnPoint)
			end
			
			local checkpoint = checkpointData:FindFirstChild(tostring(player.UserId))
			if not checkpoint then
				checkpoint = Instance.new("ObjectValue", checkpointData)
				checkpoint.Name = tostring(player.UserId)
				
				player.CharacterAdded:Connect(function(character)
					task.wait()
					character:WaitForChild("HumanoidRootPart").CFrame = game.ServerStorage.CheckpointData[tostring(player.UserId)].Value.CFrame + Vector3.new(0, 4, 0)
				end)
			end
			
			checkpoint.Value = checkpoint
		end
	end)
end

function setupWalls(blockIndex: number, block: Model)
	local walls = block:GetChildren()
	local untouchedWall_ = math.random(#walls)
	for i, wall: Part in walls do
		if wall == block.PrimaryPart then continue end
		if blockIndex % 3 == 0 then
			local dir = wall:GetAttribute('Dir')
			if dir == -Vector3.yAxis then
				setupCheckpoint(wall, block.PrimaryPart)
			end
		else
			if i == untouchedWall_ then
				untouchedWall(wall)
			else
				wall:SetAttribute(types.ATTR, types.WALL_ATTR_VALUE)
				if math.random(0,1) == 0 then
					killWall(wall)
				end
			end
		end
	end
end

function spawnTunnelBlock(i: number, currentPoint: Vector3, prevPoint: Vector3, nextPoint: Vector3)
	local block = blockTemp:Clone()
	block.Parent = blocksFolder
	local _, size = block:GetBoundingBox()
	block:PivotTo(CFrame.new(currentPoint * size))

	removeWall(i, block, prevPoint, nextPoint)
	setupWalls(i, block)
end

function createTunnel()
	local path = pg.createTunnelPath()
	for i = 1, #path do

		local nextP = path[i + 1]
		local prevP = path[i - 1]
		nextP = nextP and nextP - path[i]
		prevP = prevP and prevP - path[i]

		spawnTunnelBlock(i, path[i], prevP, nextP)

	end
end

return {
	createTunnel = createTunnel,
}
