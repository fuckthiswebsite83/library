local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local DrawingNew = Drawing.new
local Color3New = Color3.new
local Vector2New = Vector2.new
local Vector3New = Vector3.new
local MathFloor = math.floor

local ESP = {}
ESP.__index = ESP

local ESPComponent = {}
ESPComponent.__index = ESPComponent

function ESPComponent:SetVisible(visible)
    if typeof(self.drawable) == "Instance" and self.drawable:IsA("Highlight") then
        self.drawable.Enabled = visible
    else
        self.drawable.Visible = visible
    end
end

function ESPComponent:Destroy()
    if typeof(self.drawable) == "Instance" then
        self.drawable:Destroy()
    else
        self.drawable:Remove()
    end
end

local function NewDrawing(type, properties)
    local drawing = DrawingNew(type)
    for prop, value in pairs(properties or {}) do
        drawing[prop] = value
    end
    return drawing
end

local function NewCham(properties)
    local cham = Instance.new("Highlight", game.CoreGui)
    for prop, value in pairs(properties or {}) do
        cham[prop] = value
    end
    return cham
end

local Box = setmetatable({}, ESPComponent)
Box.__index = Box

function Box.new(boxColor, boxThickness, boxTransparency, boxFilled, fillColor, fillTransparency)
    local self = setmetatable({}, Box)
    self.drawable = NewDrawing("Square", {
        Visible = false,
        Color = boxColor or Color3New(1, 0, 0),
        Thickness = boxThickness or 2,
        Transparency = boxTransparency or 1,
        Filled = false
    })
    self.fillDrawable = NewDrawing("Square", {
        Visible = false,
        Color = fillColor or Color3New(1, 1, 1),
        Transparency = fillTransparency or 1,
        Filled = true
    })
    return self
end

function Box:Update(bounds, config)
    if not (bounds and config.boxEnabled) then
        self:SetVisible(false)
        self.fillDrawable.Visible = false
        return
    end
    
    self.drawable.Size = Vector2New(bounds.maxX - bounds.minX, bounds.maxY - bounds.minY)
    self.drawable.Position = Vector2New(bounds.minX, bounds.minY)
    self.drawable.Color = config.boxColor
    self.drawable.Transparency = config.boxTransparency
    self.drawable.Visible = true
    
    if config.boxFilled then
        self.fillDrawable.Size = self.drawable.Size
        self.fillDrawable.Position = self.drawable.Position
        self.fillDrawable.Color = config.boxFillColor
        self.fillDrawable.Transparency = config.boxFillTransparency
        self.fillDrawable.Visible = true
    else
        self.fillDrawable.Visible = false
    end
end

local HealthBar = setmetatable({}, ESPComponent)
HealthBar.__index = HealthBar

function HealthBar.new(healthBarColor, healthBarThickness, healthBarTransparency, healthBarFilled)
    local self = setmetatable({}, HealthBar)
    self.drawable = NewDrawing("Square", {
        Visible = false,
        Color = healthBarColor or Color3New(0, 1, 0),
        Thickness = healthBarThickness or 1,
        Transparency = healthBarTransparency or 1,
        Filled = healthBarFilled or true
    })
    self.outline = NewDrawing("Square", {
        Visible = false,
        Color = Color3New(0, 0, 0),
        Thickness = healthBarThickness or 1,
        Transparency = healthBarTransparency or 1,
        Filled = false
    })
    return self
end

function HealthBar:Update(character, bounds, config)
    if not (bounds and config.healthBarEnabled) then
        self:SetVisible(false)
        self.outline.Visible = false
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        self:SetVisible(false)
        self.outline.Visible = false
        return
    end
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    local boxHeight = bounds.maxY - bounds.minY
    
    local healthColor = Color3New(1 - healthPercent, healthPercent, 0)
    self.drawable.Color = healthColor
    
    self.drawable.Size = Vector2New(5, boxHeight * healthPercent)
    self.drawable.Position = Vector2New(bounds.minX - 10, bounds.minY + boxHeight * (1 - healthPercent))
    self:SetVisible(true)
    
    self.outline.Size = Vector2New(5, boxHeight)
    self.outline.Position = Vector2New(bounds.minX - 10, bounds.minY)
    self.outline.Visible = true
end

local NameTag = setmetatable({}, ESPComponent)
NameTag.__index = NameTag

function NameTag.new(nameTagColor, nameTagSize, nameTagCenter, nameTagOutline, nameTagOutlineColor)
    local self = setmetatable({}, NameTag)
    self.drawable = NewDrawing("Text", {
        Visible = false,
        Color = nameTagColor or Color3New(1, 1, 1),
        Size = nameTagSize or 16,
        Center = nameTagCenter or true,
        Outline = nameTagOutline or true,
        OutlineColor = nameTagOutlineColor or Color3New(0, 0, 0)
    })
    return self
end

function NameTag:Update(character, bounds, config)
    if not (bounds and config.nameTagEnabled) then
        self:SetVisible(false)
        return
    end
    
    local player = Players:GetPlayerFromCharacter(character)
    if not player then
        self:SetVisible(false)
        return
    end
    
    self.drawable.Text = player.Name
    self.drawable.Position = Vector2New(bounds.minX + ((bounds.maxX - bounds.minX) / 2), bounds.minY - 20)
    self:SetVisible(true)
end

local Distance = setmetatable({}, ESPComponent)
Distance.__index = Distance

function Distance.new(distanceColor, distanceSize, distanceCenter, distanceOutline, distanceOutlineColor)
    local self = setmetatable({}, Distance)
    self.drawable = NewDrawing("Text", {
        Visible = false,
        Color = distanceColor or Color3New(1, 1, 1),
        Size = distanceSize or 16,
        Center = distanceCenter or true,
        Outline = distanceOutline or true,
        OutlineColor = distanceOutlineColor or Color3New(0, 0, 0)
    })
    return self
end

function Distance:Update(character, bounds, config)
    if not (bounds and config.distanceEnabled) then
        self:SetVisible(false)
        return
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        self:SetVisible(false)
        return
    end
    
    local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
    self.drawable.Text = string.format("[%d studs]", MathFloor(distance))
    self.drawable.Position = Vector2New(bounds.minX + ((bounds.maxX - bounds.minX) / 2), bounds.maxY + 5)
    self:SetVisible(true)
end

local Cham = setmetatable({}, ESPComponent)
Cham.__index = Cham

function Cham.new(chamColor, chamThickness, chamTransparency, wallCheck, outlineColor, outlineTransparency)
    local self = setmetatable({}, Cham)
    self.drawable = NewCham({
        FillColor = chamColor or Color3New(0, 0, 1),
        OutlineColor = outlineColor or Color3New(1, 1, 1),
        OutlineTransparency = outlineTransparency or 0.5,
        FillTransparency = chamTransparency or 0.5,
        Enabled = false
    })
    self.wallCheck = wallCheck or false
    return self
end

function Cham:Update(character, config)
    if not config.chamEnabled then
        self:SetVisible(false)
        return
    end
    
    self.drawable.Adornee = character
    self:SetVisible(true)
end

local ESPObject = {}
ESPObject.__index = ESPObject

function ESPObject.new(boxColor, boxThickness, boxTransparency, boxFilled, boxFillColor, boxFillTransparency, healthBarColor, healthBarThickness, healthBarTransparency, healthBarFilled, nameTagColor, nameTagSize, nameTagCenter, nameTagOutline, nameTagOutlineColor, distanceColor, distanceSize, distanceCenter, distanceOutline, distanceOutlineColor, chamColor, chamThickness, chamTransparency, wallCheck, outlineColor, outlineTransparency)
    local self = setmetatable({}, ESPObject)
    self.box = Box.new(boxColor, boxThickness, boxTransparency, boxFilled, boxFillColor, boxFillTransparency)
    self.healthBar = HealthBar.new(healthBarColor, healthBarThickness, healthBarTransparency, healthBarFilled)
    self.nameTag = NameTag.new(nameTagColor, nameTagSize, nameTagCenter, nameTagOutline, nameTagOutlineColor)
    self.distance = Distance.new(distanceColor, distanceSize, distanceCenter, distanceOutline, distanceOutlineColor)
    self.cham = Cham.new(chamColor, chamThickness, chamTransparency, wallCheck, outlineColor, outlineTransparency)
    return self
end

function ESPObject:Update(character, config)
    if not character then
        self:SetVisible(false)
        return
    end

    local bounds = self:CalculateBounds(character)
    if not bounds then
        self:SetVisible(false)
        return
    end

    self.box:Update(bounds, config)
    self.healthBar:Update(character, bounds, config)
    self.nameTag:Update(character, bounds, config)
    self.distance:Update(character, bounds, config)
    self.cham:Update(character, config)
end

function ESPObject:CalculateBounds(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local _, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then return nil end
    
    local cornerPoints = {
        rootPart.Position + Vector3New(2, 3, 2),
        rootPart.Position + Vector3New(-2, 3, 2),
        rootPart.Position + Vector3New(-2, -3, 2),
        rootPart.Position + Vector3New(2, -3, 2),
        rootPart.Position + Vector3New(2, 3, -2),
        rootPart.Position + Vector3New(-2, 3, -2),
        rootPart.Position + Vector3New(-2, -3, -2),
        rootPart.Position + Vector3New(2, -3, -2),
    }
    
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    
    for _, point in ipairs(cornerPoints) do
        local screenPoint = Camera:WorldToViewportPoint(point)
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
    self.healthBar.outline.Visible = visible
    self.nameTag:SetVisible(visible)
    self.distance:SetVisible(visible)
    self.cham:SetVisible(visible)
end

function ESPObject:Destroy()
    self.box:Destroy()
    self.healthBar:Destroy()
    self.healthBar.outline:Remove()
    self.nameTag:Destroy()
    self.distance:Destroy()
    self.cham:Destroy()
end

ESP.Object = ESPObject

return ESP
