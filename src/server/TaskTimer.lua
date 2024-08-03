local RunService = game:GetService("RunService")
function startTimer(time: number, callback: () -> ())
    local time_ = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(deltaTime)
        time_ += deltaTime
        if time_ >= time then
            callback()
            conn:Disconnect()
        end
    end)
end

return {
    startTimer = startTimer
}