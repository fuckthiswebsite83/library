local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

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

local function create_instance(class, properties)
    local instance = typeof(class) == 'string' and Instance.new(class) or class
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

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

function Box:Update(character, bounds, config)
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

function Box:SetVisible(visible)
    self.drawable.Visible = visible
    self.fillDrawable.Visible = visible and self.fillDrawable.Visible
end

function Box:Destroy()
    self.drawable:Remove()
    self.fillDrawable:Remove()
end

function Box:CalculateBounds(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local size = Vector3New(3, 5.5, 3)
    local cf = hrp.CFrame

    local corners = {
        cf * Vector3New(size.X/2, size.Y/2, size.Z/2),
        cf * Vector3New(-size.X/2, size.Y/2, size.Z/2),
        cf * Vector3New(-size.X/2, -size.Y/2, size.Z/2),
        cf * Vector3New(size.X/2, -size.Y/2, size.Z/2),
        cf * Vector3New(size.X/2, size.Y/2, -size.Z/2),
        cf * Vector3New(-size.X/2, size.Y/2, -size.Z/2),
        cf * Vector3New(-size.X/2, -size.Y/2, -size.Z/2),
        cf * Vector3New(size.X/2, -size.Y/2, -size.Z/2),
    }

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local onScreen = false
    
    for _, corner in ipairs(corners) do
        local screenPoint, visible = Camera:WorldToViewportPoint(corner)
        if visible then
            onScreen = true
            minX = math.min(minX, math.floor(screenPoint.X))
            minY = math.min(minY, math.floor(screenPoint.Y))
            maxX = math.max(maxX, math.ceil(screenPoint.X))
            maxY = math.max(maxY, math.ceil(screenPoint.Y))
        end
    end
    
    if not onScreen then return nil end

    local minSize = 12
    local width = maxX - minX
    local height = maxY - minY
    
    if width < minSize then
        local center = (minX + maxX) / 2
        minX = math.floor(center - minSize / 2)
        maxX = math.ceil(center + minSize / 2)
    end
    
    if height < minSize then
        local center = (minY + maxY) / 2
        minY = math.floor(center - minSize / 2)
        maxY = math.ceil(center + minSize / 2)
    end
    
    return {
        minX = minX,
        minY = minY,
        maxX = maxX,
        maxY = maxY
    }
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
    
    local healthPercent
    if game.PlaceId == 863266079 then
        local player = Players:GetPlayerFromCharacter(character)
        if player and player:FindFirstChild("Stats") and player.Stats:FindFirstChild("Health") then
            local health = player.Stats.Health.Value
            local maxHealth = 100
            healthPercent = health / maxHealth
        else
            self:SetVisible(false)
            self.outline.Visible = false
            return
        end
    else
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            self:SetVisible(false)
            self.outline.Visible = false
            return
        end
        healthPercent = humanoid.Health / humanoid.MaxHealth
    end
    
    local boxHeight = bounds.maxY - bounds.minY
    local healthColor = Color3.new(
        math.min(2 * (1 - healthPercent), 1), 
        math.min(2 * healthPercent, 1),
        0
    )
    
    local barWidth = 5
    local barX = math.floor(bounds.minX - 10)
    local barY = math.floor(bounds.minY)
    
    self.outline.Size = Vector2New(barWidth, boxHeight)
    self.outline.Position = Vector2New(barX, barY)
    self.outline.Visible = true
    
    self.drawable.Size = Vector2New(barWidth, math.max(1, boxHeight * healthPercent))
    self.drawable.Position = Vector2New(barX, barY + boxHeight * (1 - healthPercent))
    self.drawable.Color = healthColor
    self:SetVisible(true)
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

function Cham.new(chamColor, chamTransparency, outlineColor, outlineTransparency, rainbow, pulse)
    local self = setmetatable({}, Cham)
    self.drawable = create_instance("Highlight", {
        Parent = CoreGui,
        FillColor = chamColor or Color3New(0, 0, 1),
        FillTransparency = chamTransparency or 0.5,
        OutlineColor = outlineColor or Color3New(1, 1, 1),
        OutlineTransparency = outlineTransparency or 0.5,
        Enabled = false
    })
    self.rainbow = rainbow or false
    self.pulse = pulse or false
    self.baseFillTransparency = chamTransparency or 0.5
    self.baseOutlineTransparency = outlineTransparency or 0.5
    return self
end

function Cham:Update(character, bounds, config)
    if not config.chamEnabled then
        self:SetVisible(false)
        return
    end
    
    if character then
        self.drawable.Adornee = character
        
        if self.rainbow then
            local hue = tick() % 5 / 5
            local color = Color3.fromHSV(hue, 1, 1)
            self.drawable.FillColor = color
            self.drawable.OutlineColor = color
        end
        
        if self.pulse then
            local fade_in_out = 0.5 + 0.5 * math.sin(tick() * 2)
            self.drawable.FillTransparency = self.baseFillTransparency * fade_in_out
            self.drawable.OutlineTransparency = self.baseOutlineTransparency * fade_in_out
        end

        self:SetVisible(true)
    else
        self:SetVisible(false)
    end
end

local ESPObject = {}
ESPObject.__index = ESPObject

function ESPObject.new(boxColor, boxThickness, boxTransparency, boxFilled, boxFillColor, boxFillTransparency, 
    healthBarColor, healthBarThickness, healthBarTransparency, healthBarFilled, 
    nameTagColor, nameTagSize, nameTagCenter, nameTagOutline, nameTagOutlineColor, 
    distanceColor, distanceSize, distanceCenter, distanceOutline, distanceOutlineColor, 
    chamColor, chamTransparency, outlineColor, outlineTransparency, rainbow, pulse)
    
    local self = setmetatable({}, ESPObject)
    self.box = Box.new(boxColor, boxThickness, boxTransparency, boxFilled, boxFillColor, boxFillTransparency)
    self.healthBar = HealthBar.new(healthBarColor, healthBarThickness, healthBarTransparency, healthBarFilled)
    self.nameTag = NameTag.new(nameTagColor, nameTagSize, nameTagCenter, nameTagOutline, nameTagOutlineColor)
    self.distance = Distance.new(distanceColor, distanceSize, distanceCenter, distanceOutline, distanceOutlineColor)
    self.cham = Cham.new(chamColor, chamTransparency, outlineColor, outlineTransparency, rainbow, pulse)
    return self
end

function ESPObject:Update(character, config)
    if not character then
        self:SetVisible(false)
        return
    end

    local bounds = self.box:CalculateBounds(character)
    if not bounds then
        self:SetVisible(false)
        return
    end

    self.box:Update(character, bounds, config)
    self.healthBar:Update(character, bounds, config)
    self.nameTag:Update(character, bounds, config)
    self.distance:Update(character, bounds, config)
    self.cham:Update(character, bounds, config)
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
