function getNearPointForCalcPath(currentPoint: Vector2, points: { Vector2 }) -- and then this point send to get pat function
    local nearPoint: Vector2
	local shortestDistance = math.huge
	for i, v in points do
		local distance = (currentPoint - v).Magnitude
		if distance < shortestDistance then
            shortestDistance = distance
            nearPoint = v
		end
	end
    return nearPoint
end

function calcPath(path: {}, startPoint: Vector2, finishPoint: Vector2, shortestDistanceToTable_: number?)
	local nearPoint: Vector2
	local shortestDistance = shortestDistanceToTable_ or math.huge
    local nrl: {Vector2} = {}

	for x = 1, 10 do
		for y = 1, 10 do
			local p = Vector2.new(x, y)
			local distance = (p - startPoint).Magnitude
			if distance == 1 then
				table.insert(nrl, p)
			end
		end
	end

	nearPoint = getNearPointForCalcPath(finishPoint, nrl)

    table.insert(path, nearPoint)

    if (finishPoint - nearPoint).Magnitude > 1 then
        calcPath(path, nearPoint, finishPoint, shortestDistance)
    end
end

function createPath(pathPoints: {{number}})
	local path: {Vector2} = {}

	for i = 1, #pathPoints do
		local startPoint = Vector2.new(pathPoints[i][1], pathPoints[i][2])
		if pathPoints[i + 1] then
			table.insert(path, startPoint)
			local finishPoint = Vector2.new(pathPoints[i + 1][1], pathPoints[i + 1][2])
			calcPath(path, startPoint, finishPoint)
		end
	end

	return path
end

function createTunnelPath()
	local coords: {Vector3} = {}
	local floors: {{number}} = {
		{
			{1, 1},
			{1, 5},
			{5, 5},
			{5, 1},
			{10, 1},
			{10, 5},
			{10, 10},
		},
		{
			{10, 9},
			{10, 5},
			{5, 5},
			{1, 5},
		}
	}
	
	local i = 1
	for _, floor in floors do
		local floorPath = createPath(floor)
		for j, coord in floorPath do
			table.insert(coords, Vector3.new(coord.X, i, coord.Y))
		end
		for h = 1, 2 do
			table.insert(coords, Vector3.new(floorPath[#floorPath].X, i + h, floorPath[#floorPath].Y))
		end
		i += 3
	end

	return coords
end

return {
	createTunnelPath = createTunnelPath,
}