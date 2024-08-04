local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local shared = game.ReplicatedStorage.Shared
local serverStorage = game.ServerStorage

local events = serverStorage.Events

local types = require(shared.Types)
local config = require(shared.Config)

local ball: Part = Instance.new("Part")
ball:SetAttribute(types.ATTR, types.WALL_ATTR_VALUE)
ball.Anchored = true
ball.CanCollide = false
ball.Size = Vector3.new(2, 2, 2)
ball.BrickColor = BrickColor.Blue()
ball.Transparency = .5

local rotatePart: Part = Instance.new("Part")
rotatePart.Anchored = true
rotatePart.Size = Vector3.new(20, 90, 20)
rotatePart.CanCollide = false

function killWall(wall: Part)
	wall.BrickColor = config.colors.kill
	wall.Touched:Connect(function(hit: Part)
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid") :: Humanoid
		if humanoid then
			humanoid.Health = 0
		end
	end)
end

function untouchedWall(wall: Part)
	wall.CanCollide = false
	wall.Transparency = 0.5
	wall.BrickColor = config.colors.untouched
    wall:SetAttribute(types.ATTR, nil)
end

function movingBlocks(block: Model) 
    local _, size = block:GetBoundingBox()
    local directions = {
        {start = block.PrimaryPart.Position - Vector3.new(size.X / 2, 0, 0), finish = block.PrimaryPart.Position + Vector3.new(size.X / 2, 0, 0)}, -- horizontal
        {start = block.PrimaryPart.Position - Vector3.new(0, 0, size.Z / 2), finish = block.PrimaryPart.Position + Vector3.new(0, 0, size.Z / 2)}, -- forward
        {start = block.PrimaryPart.Position - Vector3.new(size.X / 2, 0, size.Z / 2), finish = block.PrimaryPart.Position + Vector3.new(size.X / 2, 0, size.Z / 2)}, -- diag
        {start = block.PrimaryPart.Position + Vector3.new(size.X / 2, 0, size.Z / 2), finish = block.PrimaryPart.Position - Vector3.new(size.X / 2, 0, size.Z / 2)}, -- negDiag
        {start = block.PrimaryPart.Position + Vector3.new(0, size.Y / 2, 0), finish = block.PrimaryPart.Position - Vector3.new(0, size.Y / 2, 0)}, -- vertical
    }

    local direction = directions[math.random(#directions)]
    local movingBlock = rotatePart:Clone()
    movingBlock.Position = direction.start
    movingBlock.Parent = block

    killWall(movingBlock)

    TweenService:Create(movingBlock, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {
        Position = direction.finish
    }):Play()

end

function rotateBlock(block: Model)
    local rotates = {
        Vector3.xAxis,
        Vector3.zAxis,
    }
    local rot = rotates[math.random(#rotates)]

    local rotatePart_ = rotatePart:Clone()
    rotatePart_.Position = block.PrimaryPart.Position
    rotatePart_.Parent = block
    
    killWall(rotatePart_)

    coroutine.wrap(function()
        local function rotateDirection(rotationAmount: number)
            return Vector3.new(rotationAmount, rotationAmount, rotationAmount) * rot :: Vector3
        end

        local angle = 0
        RunService.Heartbeat:Connect(function(deltaTime: number)
            angle = angle + deltaTime
            local rotationAmount = rotateDirection(math.rad(math.sin(angle)) * 2) :: Vector3
            rotatePart_.CFrame = rotatePart_.CFrame * CFrame.Angles(rotationAmount.X, rotationAmount.Y, rotationAmount.Z)
        end)
    end)()
end

function flyingPoints(block: Model)

    block.PrimaryPart:Destroy()

    for i, wall: Part in block:GetChildren() do
        untouchedWall(wall)
    end

	local balls = Instance.new("Folder")
	balls.Parent = block
	local cf, size = block:GetBoundingBox()
	local startPoint = cf.Position - size / 2.5
	for x = 0, 3 do
		for z = 0, 3 do
			for y = 0, 3 do
				local ball_ = ball:Clone()
				ball_.Parent = balls
				ball_.Position = Vector3.new(x, y, z) * size / 4 + startPoint
			end
		end
	end
end

function checkpointBlock(block: Model)
	for i, wall: Part in block:GetChildren() do
		local dir = wall:GetAttribute("Dir")
		if dir == -Vector3.yAxis then
			wall.BrickColor = config.colors.checkpoint
			wall.Touched:Connect(function(hit: Part)
				if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
					local player = game.Players:GetPlayerFromCharacter(hit.Parent)
					local checkpointData = game.ServerStorage:FindFirstChild("CheckpointData")
					if not checkpointData then
						checkpointData = Instance.new("Model", game.ServerStorage)
						checkpointData.Name = "CheckpointData"
						events.SpawnItem:Fire(block.PrimaryPart)
					end

					local checkpoint = checkpointData:FindFirstChild(tostring(player.UserId))
					if not checkpoint then
						checkpoint = Instance.new("ObjectValue", checkpointData)
						checkpoint.Name = tostring(player.UserId)

						player.CharacterAdded:Connect(function(character)
							task.wait()
							character:WaitForChild("HumanoidRootPart").CFrame = game.ServerStorage.CheckpointData[tostring(
								player.UserId
							)].Value.CFrame + Vector3.new(0, 4, 0)
						end)
					end

					checkpoint.Value = checkpoint
				end
			end)
		end
	end
end

function finishBlock(block: Model)
    for i, wall in block:GetChildren() do
        wall.BrickColor = BrickColor.Yellow()
    end
end

function commonBlock(block: Model)
	local walls = block:GetChildren()
	local untouchedWall_ = math.random(#walls)
	for i, wall: Part in walls do
        if i == untouchedWall_ then
            untouchedWall(wall)
        else
            wall:SetAttribute(types.ATTR, types.WALL_ATTR_VALUE)
            if math.random(0, 1) == 0 then
                killWall(wall)
            end
        end
	end
end

local blockTypes = {
    movingBlocks,
    rotateBlock,
    flyingPoints,
}

function setupBlock(blockIndex: number, pathLen: number, block: Model) 
    if blockIndex % 3 == 0 then
        checkpointBlock(block)
    elseif blockIndex == pathLen then
        finishBlock(block)
    else
        commonBlock(block)
        blockTypes[math.random(#blockTypes)](block)
    end
end

return {
	setupBlock = setupBlock,
	killWall = killWall,
	untouchedWall = untouchedWall,
}
