-- LocalScript (StarterPlayerScripts)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local freecamEnabled = false

local moveSpeed = 20 -- Velocidad de movimiento
local mouseSensitivity = 0.2 -- Sensibilidad del ratón

local moveVector = Vector3.new()
local rotation = Vector2.new()

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

-- Activar/desactivar Freecam con la tecla "C"
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.C then
        freecamEnabled = not freecamEnabled

        if freecamEnabled then
            Camera.CameraType = Enum.CameraType.Scriptable
            lockMouse()

            -- Encontrar personaje y anclarlo
            character = player.Character
            if character then
                humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                setCharacterAnchored(true)
            end
        else
            Camera.CameraType = Enum.CameraType.Custom
            unlockMouse()

            -- Desanclar personaje
            setCharacterAnchored(false)
        end
    end
end)

-- Movimiento de Freecam
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not freecamEnabled then return end
    if input.KeyCode == Enum.KeyCode.W then
        moveVector = moveVector + Vector3.new(0, 0, -1)
    elseif input.KeyCode == Enum.KeyCode.S then
        moveVector = moveVector + Vector3.new(0, 0, 1)
    elseif input.KeyCode == Enum.KeyCode.A then
        moveVector = moveVector + Vector3.new(-1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.D then
        moveVector = moveVector + Vector3.new(1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.E then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    elseif input.KeyCode == Enum.KeyCode.Q then
        moveVector = moveVector + Vector3.new(0, -1, 0)
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed or not freecamEnabled then return end
    if input.KeyCode == Enum.KeyCode.W then
        moveVector = moveVector - Vector3.new(0, 0, -1)
    elseif input.KeyCode == Enum.KeyCode.S then
        moveVector = moveVector - Vector3.new(0, 0, 1)
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

-- Movimiento del mouse
UserInputService.InputChanged:Connect(function(input)
    if freecamEnabled and input.UserInputType == Enum.UserInputType.MouseMovement then
        rotation = rotation + Vector2.new(-input.Delta.y * mouseSensitivity, -input.Delta.x * mouseSensitivity)
    end
end)

-- Actualizar cámara
RunService.RenderStepped:Connect(function(deltaTime)
    if freecamEnabled then
        local cameraCFrame = Camera.CFrame
        local moveDirection = (cameraCFrame.RightVector * moveVector.X) + (cameraCFrame.UpVector * moveVector.Y) + (cameraCFrame.LookVector * moveVector.Z)
        local newPosition = cameraCFrame.Position + moveDirection * moveSpeed * deltaTime
        local rotationCFrame = CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), 0)
        Camera.CFrame = CFrame.new(newPosition) * rotationCFrame
    end
end)
