local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local freecamEnabled = false

local moveSpeed = 20
local mouseSensitivity = 0.2
local rollSpeed = 60

local moveVector = Vector3.new()
local rotation = Vector2.new()
local roll = 0
local rollingLeft = false
local rollingRight = false

local character
local humanoidRootPart

local function lockMouse()
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

local function unlockMouse()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

local function setCharacterAnchored(state)
    if character and humanoidRootPart then
        humanoidRootPart.Anchored = state
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.C then
        freecamEnabled = not freecamEnabled

        if freecamEnabled then
            Camera.CameraType = Enum.CameraType.Scriptable
            lockMouse()
            character = player.Character
            if character then
                humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                setCharacterAnchored(true)
            end
        else
            Camera.CameraType = Enum.CameraType.Custom
            unlockMouse()
            setCharacterAnchored(false)
        end
    elseif freecamEnabled then
        if input.KeyCode == Enum.KeyCode.Z then
            rollingLeft = true
        elseif input.KeyCode == Enum.KeyCode.X then
            rollingRight = true
        elseif input.KeyCode == Enum.KeyCode.W then
            moveVector = moveVector + Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveVector = moveVector + Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveVector = moveVector + Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveVector = moveVector + Vector3.new(1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.E then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        elseif input.KeyCode == Enum.KeyCode.Q then
            moveVector = moveVector + Vector3.new(0, -1, 0)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed or not freecamEnabled then return end
    if input.KeyCode == Enum.KeyCode.Z then
        rollingLeft = false
    elseif input.KeyCode == Enum.KeyCode.X then
        rollingRight = false
    elseif input.KeyCode == Enum.KeyCode.W then
        moveVector = moveVector - Vector3.new(0, 0, 1)
    elseif input.KeyCode == Enum.KeyCode.S then
        moveVector = moveVector - Vector3.new(0, 0, -1)
    elseif input.KeyCode == Enum.KeyCode.A then
        moveVector = moveVector - Vector3.new(-1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.D then
        moveVector = moveVector - Vector3.new(1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.E then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    elseif input.KeyCode == Enum.KeyCode.Q then
        moveVector = moveVector - Vector3.new(0, -1, 0)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if freecamEnabled and input.UserInputType == Enum.UserInputType.MouseMovement then
        rotation = rotation + Vector2.new(-input.Delta.y * mouseSensitivity, -input.Delta.x * mouseSensitivity)
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    if freecamEnabled then
            
        if rollingLeft then
            roll = roll + rollSpeed * deltaTime
        elseif rollingRight then
            roll = roll - rollSpeed * deltaTime
        end

        local rotationCFrame = CFrame.Angles(
            math.rad(rotation.X),
            math.rad(rotation.Y),
            math.rad(roll)
        )

        local forward = rotationCFrame.LookVector
        local right = rotationCFrame.RightVector

        forward = Vector3.new(forward.X, 0, forward.Z).Unit
        right = Vector3.new(right.X, 0, right.Z).Unit

        local moveDirection = (right * moveVector.X) + (Vector3.new(0, 1, 0) * moveVector.Y) + (forward * moveVector.Z)
        local cameraCFrame = Camera.CFrame
        local newPosition = cameraCFrame.Position + moveDirection * moveSpeed * deltaTime

        Camera.CFrame = CFrame.new(newPosition) * rotationCFrame
    end
end)
