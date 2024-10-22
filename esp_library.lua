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
    
    local humanoid
    if game.PlaceId == 863266079 then
        local player = Players:GetPlayerFromCharacter(character)
        if player and player:FindFirstChild("Stats") and player.Stats:FindFirstChild("Health") then
            humanoid = {
                Health = player.Stats.Health.Value,
                MaxHealth = 100
            }
        end
    else
        humanoid = character:FindFirstChildOfClass("Humanoid")
    end

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

function Cham:Update(character, bounds, config)
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

    self.box:Update(character, bounds, config)
    self.healthBar:Update(character, bounds, config)
    self.nameTag:Update(character, bounds, config)
    self.distance:Update(character, bounds, config)
    self.cham:Update(character, bounds, config)
end

function ESPObject:CalculateBounds(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local size = character:GetExtentsSize()
    local cf = character:GetPivot()
    
    local corners = {
        cf * Vector3New(size.X/2, size.Y/2, size.X/2),
        cf * Vector3New(-size.X/2, size.Y/2, size.X/2),
        cf * Vector3New(-size.X/2, -size.Y/2, size.X/2),
        cf * Vector3New(size.X/2, -size.Y/2, size.X/2),
        cf * Vector3New(size.X/2, size.Y/2, -size.X/2),
        cf * Vector3New(-size.X/2, size.Y/2, -size.X/2),
        cf * Vector3New(-size.X/2, -size.Y/2, -size.X/2),
        cf * Vector3New(size.X/2, -size.Y/2, -size.X/2),
    }

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local onScreen = false
    
    for _, corner in ipairs(corners) do
        local screenPoint, visible = Camera:WorldToViewportPoint(corner)
        if visible then
            onScreen = true
            minX = math.min(minX, screenPoint.X)
            minY = math.min(minY, screenPoint.Y)
            maxX = math.max(maxX, screenPoint.X)
            maxY = math.max(maxY, screenPoint.Y)
        end
    end
    
    if not onScreen then return nil end

    local minSize = 8
    local width = maxX - minX
    local height = maxY - minY
    
    if width < minSize then
        local center = (minX + maxX) / 2
        minX = center - minSize / 2
        maxX = center + minSize / 2
    end
    
    if height < minSize then
        local center = (minY + maxY) / 2
        minY = center - minSize / 2
        maxY = center + minSize / 2
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

-- PartESP Integration
local PartESP = {}
PartESP.__index = PartESP

local PartESPObject = {}
PartESPObject.__index = PartESPObject

function PartESPObject.new(instance, options)
    local self = setmetatable({}, PartESPObject)
    
    -- Generalize the instance and options setup
    self.instance = instance
    self.options = {
        enabled = options.enabled ~= false,
        text = options.text or "{name}",
        textColor = options.textColor or {Color3.new(1, 1, 1), 1},
        textOutline = options.textOutline ~= false,
        textOutlineColor = options.textOutlineColor or Color3.new(),
        textSize = options.textSize or 13
    }
    
    -- Initialize drawing objects
    self.nameDrawable = Drawing.new("Text")
    self.distanceDrawable = Drawing.new("Text")
    self:UpdateDrawables()
    
    -- Update the drawing based on the part's position each frame
    self.connection = RunService.RenderStepped:Connect(function()
        self:Update()
    end)
    
    return self
end

function PartESPObject:UpdateDrawables()
    -- Update the appearance based on the options
    self.nameDrawable.Visible = false
    self.nameDrawable.Color = self.options.textColor[1]
    self.nameDrawable.Transparency = self.options.textColor[2]
    self.nameDrawable.Size = self.options.textSize
    self.nameDrawable.Center = true
    self.nameDrawable.Outline = self.options.textOutline
    self.nameDrawable.OutlineColor = self.options.textOutlineColor

    self.distanceDrawable.Visible = false
    self.distanceDrawable.Color = self.options.textColor[1]
    self.distanceDrawable.Transparency = self.options.textColor[2]
    self.distanceDrawable.Size = self.options.textSize
    self.distanceDrawable.Center = true
    self.distanceDrawable.Outline = self.options.textOutline
    self.distanceDrawable.OutlineColor = self.options.textOutlineColor
end

function PartESPObject:Update()
    if not self.options.enabled then
        self:SetVisible(false)
        return
    end
    
    -- Check if the part is on the screen and update its position
    local screenPoint, onScreen = Camera:WorldToViewportPoint(self.instance.Position)
    if not onScreen then
        self:SetVisible(false)
        return
    end
    
    -- Update name and distance displays
    self.nameDrawable.Text = self.options.text:gsub("{name}", self.instance.Name)
    self.nameDrawable.Position = Vector2New(screenPoint.X, screenPoint.Y - 20)
    self.nameDrawable.Visible = true
    
    local distance = (Camera.CFrame.Position - self.instance.Position).Magnitude
    self.distanceDrawable.Text = string.format("[%d studs]", MathFloor(distance))
    self.distanceDrawable.Position = Vector2New(screenPoint.X, screenPoint.Y + 5)
    self.distanceDrawable.Visible = true
end

function PartESPObject:SetVisible(visible)
    self.nameDrawable.Visible = visible
    self.distanceDrawable.Visible = visible
end

function PartESPObject:Destroy()
    self.nameDrawable:Remove()
    self.distanceDrawable:Remove()
    if self.connection then
        self.connection:Disconnect()
    end
end

-- PartESP module methods to handle multiple ESP instances
function PartESP:Add(instance, options)
    local espObject = PartESPObject.new(instance, options)
    table.insert(self.objects, espObject)
    return espObject
end

function PartESP:Remove(instance)
    for i, espObject in ipairs(self.objects) do
        if espObject.instance == instance then
            espObject:Destroy()
            table.remove(self.objects, i)
            break
        end
    end
end

function PartESP:Clear()
    for _, espObject in ipairs(self.objects) do
        espObject:Destroy()
    end
    self.objects = {}
end

PartESP.objects = {}

ESP.PartESP = PartESP

return ESP
