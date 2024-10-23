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

local function NewDrawing(type, properties)
    local drawing = DrawingNew(type)
    for prop, value in pairs(properties or {}) do
        drawing[prop] = value
    end
    return drawing
end

local function create_instance(class, properties)
    local instance = typeof(class) == 'string' and Instance.new(class) or class
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function load_chams()
    local screen_gui = create_instance("ScreenGui", {
        Parent = CoreGui,
        Name = "chams_holder",
    })

    local function create_chams(player)
        local chams = create_instance("Highlight", {
            Parent = screen_gui,
            FillTransparency = 1,
            OutlineTransparency = 0,
            OutlineColor = Color3.fromRGB(119, 120, 255),
            DepthMode = "AlwaysOnTop"
        })

        local function update_chams()
            local connection
            local function hide_chams()
                chams.Enabled = false
                if not player then
                    screen_gui:Destroy()
                    connection:Disconnect()
                end
            end

            connection = RunService.RenderStepped:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    local pos, on_screen = Workspace.CurrentCamera:WorldToScreenPoint(hrp.Position)
                    local dist = (Workspace.CurrentCamera.CFrame.Position - hrp.Position).Magnitude / 3.5714285714

                    if on_screen and dist <= 9999 then
                        chams.Adornee = player.Character
                        chams.Enabled = true

                        if true then
                            local hue = tick() % 5 / 5
                            local color = Color3.fromHSV(hue, 1, 1)
                            chams.FillColor = color
                            chams.OutlineColor = color
                        else
                            chams.FillColor = Color3.fromRGB(119, 120, 255)
                            chams.OutlineColor = Color3.fromRGB(119, 120, 255)
                        end

                        if true then
                            local fade_in_out = 0.5 + 0.5 * math.sin(tick() * 2)
                            chams.FillTransparency = 100 * fade_in_out * 0.01
                            chams.OutlineTransparency = 100 * fade_in_out * 0.01
                        end

                        if true then
                            chams.OutlineTransparency = 0.5
                        end

                        if true then
                            chams.DepthMode = "Occluded"
                        else
                            chams.DepthMode = "AlwaysOnTop"
                        end
                    else
                        hide_chams()
                    end
                else
                    hide_chams()
                end
            end)
        end

        coroutine.wrap(update_chams)()
    end

    local function setup_player_chams(player)
        if player.Name ~= Players.LocalPlayer.Name then
            coroutine.wrap(create_chams)(player)
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        setup_player_chams(player)
    end

    Players.PlayerAdded:Connect(setup_player_chams)
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
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local health, maxHealth

    if game.PlaceId == 863266079 then
        local player = Players:GetPlayerFromCharacter(character)
        if player and player:FindFirstChild("Stats") and player.Stats:FindFirstChild("Health") then
            health = player.Stats.Health.Value
            maxHealth = player.Stats.Health.MaxValue or 100
        elseif humanoid then
            health = humanoid.Health
            maxHealth = humanoid.MaxHealth
        else
            self:SetVisible(false)
            self.outline.Visible = false
            return
        end
    elseif humanoid then
        health = humanoid.Health
        maxHealth = humanoid.MaxHealth
    else
        self:SetVisible(false)
        self.outline.Visible = false
        return
    end
    
    local healthPercent = health / maxHealth
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

function HealthBar:SetVisible(visible)
    self.drawable.Visible = visible
    self.outline.Visible = visible
end

function HealthBar:Destroy()
    self.drawable:Remove()
    self.outline:Remove()
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

function NameTag:SetVisible(visible)
    self.drawable.Visible = visible
end

function NameTag:Destroy()
    self.drawable:Remove()
end

local Cham = setmetatable({}, ESPComponent)
Cham.__index = Cham

function Cham.new(chamColor, chamThickness, chamTransparency, wallCheck, outlineColor, outlineTransparency, thermalEnabled, rainbowEnabled, glowEnabled)
    local self = setmetatable({}, Cham)
    self.drawable = create_instance("Highlight", {
        Parent = CoreGui,
        FillColor = chamColor or Color3New(0, 0, 1),
        OutlineColor = outlineColor or Color3New(1, 1, 1),
        OutlineTransparency = outlineTransparency or 0.5,
        FillTransparency = chamTransparency or 0.5,
        Enabled = false
    })
    self.wallCheck = wallCheck or false
    self.thermalEnabled = thermalEnabled or false
    self.rainbowEnabled = rainbowEnabled or false
    self.glowEnabled = glowEnabled or false
    return self
end

function Cham:Update(character, bounds, config)
    if not config.chamEnabled then
        self:SetVisible(false)
        return
    end
    
    self.drawable.Adornee = character
    self:SetVisible(true)

    if config.rainbowEnabled then
        local hue = tick() % 5 / 5
        local color = Color3.fromHSV(hue, 1, 1)
        self.drawable.FillColor = color
        self.drawable.OutlineColor = color
    else
        self.drawable.FillColor = config.chamColor
        self.drawable.OutlineColor = config.chamsOutline
    end

    if config.thermalEnabled then
        local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
        self.drawable.FillTransparency = config.chamTransparency * breathe_effect * 0.01
        self.drawable.OutlineTransparency = config.chamsOutlineTransparency * breathe_effect * 0.01
    end

    if config.glowEnabled then
        self.drawable.OutlineTransparency = 0.5
    end

    if config.wallCheck then
        self.drawable.DepthMode = "Occluded"
    else
        self.drawable.DepthMode = "AlwaysOnTop"
    end
end

function Cham:SetVisible(visible)
    self.drawable.Enabled = visible
end

function Cham:Destroy()
    self.drawable:Destroy()
end

local ESPObject = {}
ESPObject.__index = ESPObject

function ESPObject.new(boxColor, boxThickness, boxTransparency, boxFilled, boxFillColor, boxFillTransparency, healthBarColor, healthBarThickness, healthBarTransparency, healthBarFilled, nameTagColor, nameTagSize, nameTagCenter, nameTagOutline, nameTagOutlineColor, chamColor, chamThickness, chamTransparency, wallCheck, outlineColor, outlineTransparency, thermalEnabled, rainbowEnabled, glowEnabled)
    local self = setmetatable({}, ESPObject)
    self.box = Box.new(boxColor, boxThickness, boxTransparency, boxFilled, boxFillColor, boxFillTransparency)
    self.healthBar = HealthBar.new(healthBarColor, healthBarThickness, healthBarTransparency, healthBarFilled)
    self.nameTag = NameTag.new(nameTagColor, nameTagSize, nameTagCenter, nameTagOutline, nameTagOutlineColor)
    self.cham = Cham.new(chamColor, chamThickness, chamTransparency, wallCheck, outlineColor, outlineTransparency, thermalEnabled, rainbowEnabled, glowEnabled)
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
    self.cham:SetVisible(visible)
end

function ESPObject:Destroy()
    self.box:Destroy()
    self.healthBar:Destroy()
    self.healthBar.outline:Remove()
    self.nameTag:Destroy()
    self.cham:Destroy()
end

ESP.Object = ESPObject

load_chams()

return ESP
