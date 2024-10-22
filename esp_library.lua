local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Cache frequently used values and functions
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Vector2New, Vector3New = Vector2.new, Vector3.new
local Color3New = Color3.new
local DrawingNew = Drawing.new
local MathFloor = math.floor
local MathMin, MathMax = math.min, math.max
local TableRemove = table.remove

-- Pooling system for drawing objects
local DrawingPool = {
    Square = {},
    Text = {},
    count = {Square = 0, Text = 0}
}

local function GetDrawing(type, properties)
    local pool = DrawingPool[type]
    local drawing = TableRemove(pool) or DrawingNew(type)
    DrawingPool.count[type] = DrawingPool.count[type] + 1
    
    -- Apply properties in bulk
    for k, v in pairs(properties) do
        drawing[k] = v
    end
    
    return drawing
end

local function ReturnDrawing(drawing, type)
    if drawing then
        drawing.Visible = false
        table.insert(DrawingPool[type], drawing)
        DrawingPool.count[type] = DrawingPool.count[type] - 1
    end
end

-- Optimized ESP component base class
local ESPComponent = {}
ESPComponent.__index = ESPComponent

function ESPComponent:SetVisible(visible)
    self.drawable.Visible = visible
end

function ESPComponent:Destroy()
    if self.drawable then
        ReturnDrawing(self.drawable, self.type)
        self.drawable = nil
    end
end

-- Optimized Box component
local Box = setmetatable({}, ESPComponent)
Box.__index = Box

function Box.new()
    local self = setmetatable({}, Box)
    self.type = "Square"
    self.drawable = GetDrawing("Square", {
        Visible = false,
        Thickness = 1,
        Filled = false
    })
    return self
end

function Box:Update(bounds, config)
    if not (bounds and config.boxEnabled) then
        self:SetVisible(false)
        return
    end
    
    local drawable = self.drawable
    drawable.Size = Vector2New(bounds.maxX - bounds.minX, bounds.maxY - bounds.minY)
    drawable.Position = Vector2New(bounds.minX, bounds.minY)
    drawable.Color = config.boxColor
    drawable.Visible = true
end

-- Optimized HealthBar component
local HealthBar = setmetatable({}, ESPComponent)
HealthBar.__index = HealthBar

function HealthBar.new()
    local self = setmetatable({}, HealthBar)
    self.type = "Square"
    self.drawable = GetDrawing("Square", {
        Visible = false,
        Thickness = 1,
        Filled = true
    })
    return self
end

function HealthBar:Update(character, bounds, config)
    if not (bounds and config.healthBarEnabled) then
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
    
    self.drawable.Size = Vector2New(4, boxHeight * healthPercent)
    self.drawable.Position = Vector2New(bounds.minX - 6, bounds.minY + boxHeight * (1 - healthPercent))
    self.drawable.Color = Color3New(1 - healthPercent, healthPercent, 0)
    self.drawable.Visible = true
end

-- Optimized NameTag component
local NameTag = setmetatable({}, ESPComponent)
NameTag.__index = NameTag

function NameTag.new()
    local self = setmetatable({}, NameTag)
    self.type = "Text"
    self.drawable = GetDrawing("Text", {
        Visible = false,
        Center = true,
        Outline = true,
        Color = Color3New(1, 1, 1),
        OutlineColor = Color3New(0, 0, 0)
    })
    return self
end

function NameTag:Update(character, bounds, config)
    if not (bounds and config.nameEnabled) then
        self:SetVisible(false)
        return
    end
    
    local player = Players:GetPlayerFromCharacter(character)
    if not player then
        self:SetVisible(false)
        return
    end
    
    self.drawable.Text = player.Name
    self.drawable.Position = Vector2New(
        bounds.minX + (bounds.maxX - bounds.minX) * 0.5,
        bounds.minY - 15
    )
    self.drawable.Visible = true
end

-- Main ESP object with optimized bounds calculation
local ESP = {}
ESP.__index = ESP

function ESP.new()
    local self = setmetatable({}, ESP)
    self.objects = {}
    self.enabled = false
    return self
end

function ESP:CreateObject(character)
    local object = {
        character = character,
        box = Box.new(),
        healthBar = HealthBar.new(),
        nameTag = NameTag.new(),
        lastUpdate = 0
    }
    self.objects[character] = object
    return object
end

function ESP:RemoveObject(character)
    local object = self.objects[character]
    if object then
        object.box:Destroy()
        object.healthBar:Destroy()
        object.nameTag:Destroy()
        self.objects[character] = nil
    end
end

-- Cached vectors for bounds calculation
local cornerOffsets = {
    Vector3New(0.5, 0.5, 0.5),
    Vector3New(-0.5, 0.5, 0.5),
    Vector3New(-0.5, -0.5, 0.5),
    Vector3New(0.5, -0.5, 0.5)
}

function ESP:CalculateBounds(cf, size)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local onScreen = false
    
    for _, offset in ipairs(cornerOffsets) do
        local worldPoint = cf * (offset * size)
        local screenPoint, visible = Camera:WorldToViewportPoint(worldPoint)
        
        if visible then
            onScreen = true
            minX = MathMin(minX, screenPoint.X)
            minY = MathMin(minY, screenPoint.Y)
            maxX = MathMax(maxX, screenPoint.X)
            maxY = MathMax(maxY, screenPoint.Y)
        end
    end
    
    return onScreen and {
        minX = minX,
        minY = minY,
        maxX = maxX,
        maxY = maxY
    }
end

local config = {
    boxEnabled = true,
    boxColor = Color3New(1, 0, 0),
    healthBarEnabled = true,
    nameEnabled = true
}

-- Optimized update function
function ESP:Update()
    if not self.enabled then return end
    
    local currentTime = tick()
    for character, object in pairs(self.objects) do
        -- Update at most 60 times per second per object
        if currentTime - object.lastUpdate >= 0.016 then
            if character.Parent then
                local cf = character:GetPivot()
                local bounds = self:CalculateBounds(cf, character:GetExtentsSize())
                
                if bounds then
                    object.box:Update(bounds, config)
                    object.healthBar:Update(character, bounds, config)
                    object.nameTag:Update(character, bounds, config)
                else
                    object.box:SetVisible(false)
                    object.healthBar:SetVisible(false)
                    object.nameTag:SetVisible(false)
                end
            else
                self:RemoveObject(character)
            end
            object.lastUpdate = currentTime
        end
    end
end

-- Connection management
function ESP:Toggle(enabled)
    self.enabled = enabled
    if not enabled then
        for _, object in pairs(self.objects) do
            object.box:SetVisible(false)
            object.healthBar:SetVisible(false)
            object.nameTag:SetVisible(false)
        end
    end
end

-- Initialize the ESP system
local esp = ESP.new()

-- Connect to RenderStepped with throttling
local lastUpdate = 0
RunService.RenderStepped:Connect(function()
    local now = tick()
    if now - lastUpdate >= 0.016 then  -- Cap at ~60 FPS
        esp:Update()
        lastUpdate = now
    end
end)

return esp
