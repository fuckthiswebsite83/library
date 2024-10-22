local ESP = {}
ESP.__index = ESP

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Base class for all ESP elements
local ESPComponent = {}
ESPComponent.__index = ESPComponent

function ESPComponent:SetVisible(visible)
    self.drawable.Visible = visible
end

function ESPComponent:Destroy()
    self.drawable:Remove()
end

-- Box Component
local Box = setmetatable({}, ESPComponent)
Box.__index = Box

function Box.new()
    local self = setmetatable({}, Box)
    self.drawable = Drawing.new("Square")
    self.drawable.Visible = false
    self.drawable.Color = Color3.new(1, 0, 0)
    self.drawable.Thickness = 2
    self.drawable.Transparency = 1
    self.drawable.Filled = false
    return self
end

function Box:Update(character, bounds)
    if not bounds then
        self:SetVisible(false)
        return
    end
    
    self.drawable.Size = Vector2.new(bounds.maxX - bounds.minX, bounds.maxY - bounds.minY)
    self.drawable.Position = Vector2.new(bounds.minX, bounds.minY)
    self.drawable.Visible = true
end

-- HealthBar Component
local HealthBar = setmetatable({}, ESPComponent)
HealthBar.__index = HealthBar

function HealthBar.new()
    local self = setmetatable({}, HealthBar)
    self.drawable = Drawing.new("Square")
    self.drawable.Visible = false
    self.drawable.Color = Color3.new(0, 1, 0)
    self.drawable.Thickness = 1
    self.drawable.Transparency = 1
    self.drawable.Filled = true
    return self
end

function HealthBar:Update(character, bounds)
    if not (bounds and character) then
        self:SetVisible(false)
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        self:SetVisible(false)
        return
    end
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    local boxHeight = bounds.maxY - bounds.minY
    self.drawable.Size = Vector2.new(5, boxHeight * healthPercent)
    self.drawable.Position = Vector2.new(bounds.minX - 10, bounds.minY + boxHeight * (1 - healthPercent))
    self.drawable.Visible = true
end

-- NameTag Component
local NameTag = setmetatable({}, ESPComponent)
NameTag.__index = NameTag

function NameTag.new()
    local self = setmetatable({}, NameTag)
    self.drawable = Drawing.new("Text")
    self.drawable.Visible = false
    self.drawable.Color = Color3.new(1, 1, 1)
    self.drawable.Size = 16
    self.drawable.Center = true
    self.drawable.Outline = true
    self.drawable.OutlineColor = Color3.new(0, 0, 0)
    return self
end

function NameTag:Update(character, bounds)
    if not (bounds and character) then
        self:SetVisible(false)
        return
    end
    
    local player = Players:GetPlayerFromCharacter(character)
    if not player then
        self:SetVisible(false)
        return
    end
    
    self.drawable.Text = player.Name
    self.drawable.Position = Vector2.new(bounds.minX + ((bounds.maxX - bounds.minX) / 2), bounds.minY - 20)
    self.drawable.Visible = true
end

-- Distance Component
local Distance = setmetatable({}, ESPComponent)
Distance.__index = Distance

function Distance.new()
    local self = setmetatable({}, Distance)
    self.drawable = Drawing.new("Text")
    self.drawable.Visible = false
    self.drawable.Color = Color3.new(1, 1, 1)
    self.drawable.Size = 16
    self.drawable.Center = true
    self.drawable.Outline = true
    self.drawable.OutlineColor = Color3.new(0, 0, 0)
    return self
end

function Distance:Update(character, bounds)
    if not (bounds and character) then
        self:SetVisible(false)
        return
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        self:SetVisible(false)
        return
    end
    
    local camera = workspace.CurrentCamera
    if not camera then
        self:SetVisible(false)
        return
    end
    
    local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
    self.drawable.Text = string.format("[%d studs]", math.floor(distance))
    self.drawable.Position = Vector2.new(bounds.minX + ((bounds.maxX - bounds.minX) / 2), bounds.maxY + 5)
    self.drawable.Visible = true
end

-- Main ESP Handler
local ESPObject = {}
ESPObject.__index = ESPObject

function ESPObject.new()
    local self = setmetatable({}, ESPObject)
    self.box = Box.new()
    self.healthBar = HealthBar.new()
    self.nameTag = NameTag.new()
    self.distance = Distance.new()
    return self
end

function ESPObject:Update(character)
    if not character then
        self:SetVisible(false)
        return
    end

    local bounds = self:CalculateBounds(character)
    if not bounds then
        self:SetVisible(false)
        return
    end

    self.box:Update(character, bounds)
    self.healthBar:Update(character, bounds)
    self.nameTag:Update(character, bounds)
    self.distance:Update(character, bounds)
end

function ESPObject:CalculateBounds(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    
    local _, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then return nil end
    
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
    
    return {
        minX = minX,
        minY = minY,
        maxX = maxX,
        maxY = maxY
    }
end

function ESPObject:SetVisible(visible)
    self.box:SetVisible(visible)
    self.healthBar:SetVisible(visible)
    self.nameTag:SetVisible(visible)
    self.distance:SetVisible(visible)
end

function ESPObject:Destroy()
    self.box:Destroy()
    self.healthBar:Destroy()
    self.nameTag:Destroy()
    self.distance:Destroy()
end

ESP.Object = ESPObject

return ESP
