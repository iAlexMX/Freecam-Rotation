local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local freecamEnabled = false
local mouseLocked = true
local camera = workspace.CurrentCamera

local moveSpeed = 0.2
local rotateSpeed = 1

local yaw = 0
local pitch = 0
local roll = 0

local function toggleFreecam()
    freecamEnabled = not freecamEnabled
    if freecamEnabled then
        camera.CameraType = Enum.CameraType.Scriptable
        yaw, pitch, roll = 0, 0, 0

        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.AutoRotate = false

        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        mouseLocked = true
    else
        camera.CameraType = Enum.CameraType.Custom

        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid.AutoRotate = true

        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

local function toggleMouseLock()
    if not freecamEnabled then return end
    mouseLocked = not mouseLocked
    UserInputService.MouseBehavior = mouseLocked and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
end

UserInputService.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end

    if input.KeyCode == Enum.KeyCode.C then
        toggleFreecam()
    elseif input.KeyCode == Enum.KeyCode.V then
        toggleMouseLock()
    elseif input.KeyCode == Enum.KeyCode.Z and freecamEnabled then
        roll = roll - math.rad(10)
    elseif input.KeyCode == Enum.KeyCode.X and freecamEnabled then
        roll = roll + math.rad(10)
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if freecamEnabled then

        local moveDirection = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Vector3.new(0, 0, -1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection + Vector3.new(0, 0, 1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection + Vector3.new(-1, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Vector3.new(1, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDirection = moveDirection + Vector3.new(0, -1, 0)
        end

        if mouseLocked then
            local delta = UserInputService:GetMouseDelta()
            yaw = yaw - delta.X * rotateSpeed * dt
            pitch = pitch - delta.Y * rotateSpeed * dt
            pitch = math.clamp(pitch, -math.pi/2, math.pi/2)
        end

        local rotationCFrame = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, roll)
        local moveCFrame = rotationCFrame:VectorToWorldSpace(moveDirection * moveSpeed)

        camera.CFrame = camera.CFrame + moveCFrame
        camera.CFrame = CFrame.new(camera.CFrame.Position) * rotationCFrame
    end
end)
