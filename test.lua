local ESP = {}
ESP.__index = ESP

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Box = {}
Box.__index = Box

function Box.new()
    local self = setmetatable({}, Box)
    self.box = Drawing.new("Square")
    self.box.Visible = false
    self.box.Color = Color3.new(1, 0, 0)
    self.box.Thickness = 2
    self.box.Transparency = 1
    self.box.Filled = false

    self.healthBar = Drawing.new("Square")
    self.healthBar.Visible = false
    self.healthBar.Color = Color3.new(0, 1, 0)
    self.healthBar.Thickness = 1
    self.healthBar.Transparency = 1
    self.healthBar.Filled = true

    self.nameText = Drawing.new("Text")
    self.nameText.Visible = false
    self.nameText.Color = Color3.new(1, 1, 1)
    self.nameText.Size = 16
    self.nameText.Center = true
    self.nameText.Outline = true
    self.nameText.OutlineColor = Color3.new(0, 0, 0)

    self.distanceText = Drawing.new("Text")
    self.distanceText.Visible = false
    self.distanceText.Color = Color3.new(1, 1, 1)
    self.distanceText.Size = 16
    self.distanceText.Center = true
    self.distanceText.Outline = true
    self.distanceText.OutlineColor = Color3.new(0, 0, 0)

    return self
end

function Box:Update(character)
    if not character then
        self:SetVisible(false)
        return
    end

    local head = character:FindFirstChild("Head")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not (head and rootPart and humanoid) then
        self:SetVisible(false)
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then
        self:SetVisible(false)
        return
    end

    local player = Players:GetPlayerFromCharacter(character)
    if not player then
        self:SetVisible(false)
        return
    end

    local _, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        self:SetVisible(false)
        return
    end

    local cornerPoints = {
        rootPart.Position + Vector3.new(2, 3, 2),
        rootPart.Position + Vector3.new(-2, 3, 2),
        rootPart.Position + Vector3.new(-2, -3, 2),
        rootPart.Position + Vector3.new(2, -3, 2),
        rootPart.Position + Vector3.new(2, 3, -2),
        rootPart.Position + Vector3.new(-2, 3, -2),
        rootPart.Position + Vector3.new(-2, -3, -2),
        rootPart.Position + Vector3.new(2, -3, -2),
    }

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    
    for _, point in ipairs(cornerPoints) do
        local screenPoint = camera:WorldToViewportPoint(point)
        minX = math.min(minX, screenPoint.X)
        minY = math.min(minY, screenPoint.Y)
        maxX = math.max(maxX, screenPoint.X)
        maxY = math.max(maxY, screenPoint.Y)
    end
    
    local boxWidth = maxX - minX
    local boxHeight = maxY - minY

    self.box.Size = Vector2.new(boxWidth, boxHeight)
    self.box.Position = Vector2.new(minX, minY)
    self.box.Visible = true

    local healthPercent = humanoid.Health / humanoid.MaxHealth
    self.healthBar.Size = Vector2.new(5, boxHeight * healthPercent)
    self.healthBar.Position = Vector2.new(minX - 10, minY + boxHeight * (1 - healthPercent))
    self.healthBar.Visible = true

    self.nameText.Text = player.Name
    self.nameText.Position = Vector2.new(minX + (boxWidth / 2), minY - 20)
    self.nameText.Visible = true

    local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
    self.distanceText.Text = string.format("[%d studs]", math.floor(distance))
    self.distanceText.Position = Vector2.new(minX + (boxWidth / 2), maxY + 5)
    self.distanceText.Visible = true
end

function Box:SetVisible(visible)
    self.box.Visible = visible
    self.healthBar.Visible = visible
    self.nameText.Visible = visible
    self.distanceText.Visible = visible
end

function Box:Destroy()
    self.box:Remove()
    self.healthBar:Remove()
    self.nameText:Remove()
    self.distanceText:Remove()
end

ESP.Box = Box

return ESP
