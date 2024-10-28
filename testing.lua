local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui"))
local Lighting = cloneref(game:GetService("Lighting"))
local UserInputService = game:GetService("UserInputService"))
local gameId = game.PlaceId

_Periphean = _Periphean or {}
_Periphean.ESPConfig = _Periphean.ESPConfig or {
    Enabled = true,
    MaxDistance = 2000,
    FontSize = 11,
    MinFontSize = 8,
    Drawing = {
        Names = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Distances = {
            Enabled = true,
            Position = "Text",
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Healthbar = {
            Enabled = true,
            HealthText = true,
            Width = 2.5,
        },
        Boxes = {
            Filled = {
                Enabled = true,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Corner = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
        },
        Tracers = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 255, 255),
            Thickness = 1,
        },
        InventoryViewer = {
            Enabled = true,
            KeyPicker = Enum.KeyCode.E,
        },
    },
    Connections = {
        RunService = RunService;
    },
}

local ESP = _Periphean.ESPConfig
local lplayer = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

local Functions = {}
do
    function Functions:Create(Class, Properties)
        local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
        for Property, Value in pairs(Properties) do
            _Instance[Property] = Value
        end
        return _Instance
    end

    function Functions:Lerp(a, b, t)
        return a + (b - a) * t
    end
end

do
    local ScreenGui = Functions:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "ESPHolder",
    })

    local function CreateESPElement(Class, Properties)
        return Functions:Create(Class, Properties)
    end

    local ESP = function(plr)
        local Name = CreateESPElement("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0.5, 0, 0, -11),
            Size = UDim2.new(0, 100, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Code,
            TextSize = ESP.FontSize,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            RichText = true
        })
        local Distance = CreateESPElement("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0.5, 0, 0, 11),
            Size = UDim2.new(0, 100, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Code,
            TextSize = ESP.FontSize,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            RichText = true
        })
        local Box = CreateESPElement("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0
        })
        local Healthbar = CreateESPElement("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0
        })
        local BehindHealthbar = CreateESPElement("Frame", {
            Parent = ScreenGui,
            ZIndex = -1,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0
        })
        local HealthText = CreateESPElement("TextLabel", {
            Parent = ScreenGui,
            Size = UDim2.new(0, 50, 0, 20),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Code,
            TextSize = ESP.FontSize,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        })
        local Tracer = Drawing.new("Line")
        Tracer.Color = ESP.Drawing.Tracers.RGB
        Tracer.Thickness = ESP.Drawing.Tracers.Thickness
        Tracer.Transparency = 1

        local InventoryViewer = CreateESPElement("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0, 10, 0, 300),
            Size = UDim2.new(0, 300, 0, 200),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Code,
            TextSize = ESP.FontSize,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            RichText = true,
            Visible = false
        })

        local CornerFrames = {}
        for _, pos in ipairs({"LeftTop", "LeftSide", "RightTop", "RightSide", "BottomSide", "BottomDown", "BottomRightSide", "BottomRightDown"}) do
            CornerFrames[pos] = CreateESPElement("Frame", {
                Parent = ScreenGui,
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB,
                Position = UDim2.new(0, 0, 0, 0)
            })
        end

        local Connection
        local function HideESP()
            Box.Visible = false
            Name.Visible = false
            Distance.Visible = false
            Healthbar.Visible = false
            BehindHealthbar.Visible = false
            HealthText.Visible = false
            Tracer.Visible = false
            InventoryViewer.Visible = false
            for _, frame in pairs(CornerFrames) do
                frame.Visible = false
            end
            if not plr then
                ScreenGui:Destroy()
                Connection:Disconnect()
            end
        end

        local previousInventoryText = ""

        local maxDistance = ESP.MaxDistance
        local namesEnabled = ESP.Drawing.Names.Enabled
        local namesRGB = ESP.Drawing.Names.RGB
        local distancesEnabled = ESP.Drawing.Distances.Enabled
        local distancesRGB = ESP.Drawing.Distances.RGB
        local healthbarEnabled = ESP.Drawing.Healthbar.Enabled
        local healthbarWidth = ESP.Drawing.Healthbar.Width
        local boxesFullEnabled = ESP.Drawing.Boxes.Full.Enabled
        local boxesFilledRGB = ESP.Drawing.Boxes.Filled.RGB
        local boxesFilledTransparency = ESP.Drawing.Boxes.Filled.Transparency
        local boxesCornerEnabled = ESP.Drawing.Boxes.Corner.Enabled
        local tracersEnabled = ESP.Drawing.Tracers.Enabled
        local tracersRGB = ESP.Drawing.Tracers.RGB
        local tracersThickness = ESP.Drawing.Tracers.Thickness
        local inventoryViewerEnabled = ESP.Drawing.InventoryViewer.Enabled
        local inventoryViewerKeyPicker = ESP.Drawing.InventoryViewer.KeyPicker

        Connection = ESP.Connections.RunService.RenderStepped:Connect(function()
            local character = plr.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local HRP = character.HumanoidRootPart
                local Humanoid = character:WaitForChild("Humanoid")
                local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
                local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
                
                if not OnScreen or Dist > maxDistance then
                    HideESP()
                    return
                end

                local Size = HRP.Size.Y
                local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                local targetTextSize = math.max(ESP.MinFontSize, ESP.FontSize * (1 - (Dist / maxDistance)))
                local smoothTextSize = Functions:Lerp(Name.TextSize, targetTextSize, 0.1)

                Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                Box.Size = UDim2.new(0, w, 0, h)
                Box.Visible = boxesFullEnabled
                Box.BackgroundColor3 = boxesFilledRGB
                Box.BackgroundTransparency = boxesFilledTransparency

                local CornerPositions = {
                    LeftTop = {Pos.X - w / 2, Pos.Y - h / 2, w / 5, 1},
                    LeftSide = {Pos.X - w / 2, Pos.Y - h / 2, 1, h / 5},
                    BottomSide = {Pos.X - w / 2, Pos.Y + h / 2, 1, h / 5, Vector2.new(0, 5)},
                    BottomDown = {Pos.X - w / 2, Pos.Y + h / 2, w / 5, 1, Vector2.new(0, 1)},
                    RightTop = {Pos.X + w / 2, Pos.Y - h / 2, w / 5, 1, Vector2.new(1, 0)},
                    RightSide = {Pos.X + w / 2 - 1, Pos.Y - h / 2, 1, h / 5, Vector2.new(0, 0)},
                    BottomRightSide = {Pos.X + w / 2, Pos.Y + h / 2, 1, h / 5, Vector2.new(1, 1)},
                    BottomRightDown = {Pos.X + w / 2, Pos.Y + h / 2, w / 5, 1, Vector2.new(1, 1)}
                }

                for pos, data in pairs(CornerPositions) do
                    local frame = CornerFrames[pos]
                    frame.Visible = boxesCornerEnabled
                    frame.Position = UDim2.new(0, data[1], 0, data[2])
                    frame.Size = UDim2.new(0, data[3], 0, data[4])
                    if data[5] then
                        frame.AnchorPoint = data[5]
                    end
                end

                local health, maxHealth
                if gameId == 863266079 then
                    local stats = plr:FindFirstChild("Stats")
                    if stats then
                        local healthValue = stats:FindFirstChild("Health")
                        if healthValue then
                            health = healthValue.Value
                            maxHealth = 100
                        end
                    end
                else
                    health = Humanoid.Health
                    maxHealth = Humanoid.MaxHealth
                end

                health = health or 0
                maxHealth = maxHealth or 100

                Healthbar.Visible = healthbarEnabled
                Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - health / maxHealth))  
                Healthbar.Size = UDim2.new(0, healthbarWidth, 0, h * (health / maxHealth))
                Healthbar.BackgroundColor3 = Color3.fromHSV((health / maxHealth) * 0.33, 1, 1)
                BehindHealthbar.Visible = healthbarEnabled
                BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2)  
                BehindHealthbar.Size = UDim2.new(0, healthbarWidth, 0, h)

                if ESP.Drawing.Healthbar.HealthText then
                    local healthPercentage = math.floor((health / maxHealth) * 100)
                    HealthText.Position = UDim2.new(0, Pos.X - w / 2 - 10, 0, Pos.Y - h / 2 + h / 2)
                    HealthText.Text = tostring(healthPercentage) .. "%"
                    HealthText.Visible = true
                    HealthText.TextColor3 = Color3.fromHSV((health / maxHealth) * 0.33, 1, 1)
                    HealthText.TextSize = smoothTextSize
                end
                
                Name.Visible = namesEnabled
                if Name.Visible then
                    Name.Text = plr.Name
                    Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 9)
                    Name.TextSize = smoothTextSize
                end

                if distancesEnabled then
                    Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)
                    Distance.Text = math.floor(Dist) .. " meters"
                    Distance.Visible = true
                    Distance.TextSize = smoothTextSize
                end

                if tracersEnabled then
                    local head = character:FindFirstChild("Head")
                    if head then
                        local headBottomPos = head.Position - Vector3.new(0, head.Size.Y / 2, 0)
                        local headScreenPos = Cam:WorldToViewportPoint(headBottomPos)
                        local mousePos = UserInputService:GetMouseLocation()
                        Tracer.From = Vector2.new(mousePos.X, mousePos.Y)
                        Tracer.To = Vector2.new(headScreenPos.X, headScreenPos.Y)
                        Tracer.Visible = health > 0
                    end
                end

                if gameId == 863266079 and UserInputService:IsKeyDown(inventoryViewerKeyPicker) then
                    local closestPlayer, closestDist = nil, math.huge
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= lplayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local mousePos = UserInputService:GetMouseLocation()
                            local playerPos = Cam:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                            local dist = (Vector2.new(playerPos.X, playerPos.Y) - mousePos).Magnitude
                            if dist < closestDist then
                                closestPlayer, closestDist = player, dist
                            end
                        end
                    end
                
                    if closestPlayer and closestDist <= maxDistance then
                        local stats = closestPlayer:FindFirstChild("Stats")
                        local primary, secondary = "None", "None"
                        if stats then
                            primary = stats:FindFirstChild("Primary") and stats.Primary.Value or "None"
                            secondary = stats:FindFirstChild("Secondary") and stats.Secondary.Value or "None"
                        end
                
                        local equipment = {}
                        local equipmentFolder = closestPlayer.Character:FindFirstChild("Equipment")
                        if equipmentFolder then
                            for _, item in pairs(equipmentFolder:GetChildren()) do
                                table.insert(equipment, item.Name)
                            end
                        end
                        local equipmentText = table.concat(equipment, "\n")
                
                        local health = stats:FindFirstChild("Health") and stats.Health.Value or 0
                        local hpBoost = health > 100 and "Yes" or "No"
                
                        local characterState = "Idle"
                        if closestPlayer.Character and closestPlayer.Character:FindFirstChild("Humanoid") then
                            local humanoid = closestPlayer.Character.Humanoid
                            if humanoid:GetState() == Enum.HumanoidStateType.Running then
                                characterState = "Running"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Seated then
                                characterState = "Sitting"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                                characterState = "Jumping"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                                characterState = "Falling"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Climbing then
                                characterState = "Climbing"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                                characterState = "Swimming"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Dead then
                                characterState = "Dead"
                            end
                        end
                
                        local newInventoryText = string.format(
                            "%s's information:\n\nWeapons:\nPrimary: %s\nSecondary: %s\n\nEquipment:\n%s\n\nInfo:\nHP: %d%%\nHP Boost: %s\nCharacter State: %s",
                            closestPlayer.Name, primary, secondary, equipmentText, health, hpBoost, characterState
                        )

                        if newInventoryText ~= previousInventoryText then
                            InventoryViewer.Text = newInventoryText
                            previousInventoryText = newInventoryText
                        end
                        InventoryViewer.Visible = true
                    else
                        InventoryViewer.Visible = false
                    end
                else
                    InventoryViewer.Visible = false
                end
            else
                HideESP()
            end
        end)
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v.Name ~= lplayer.Name then
            ESP(v)
        end      
    end

    Players.PlayerAdded:Connect(function(v)
        ESP(v)
    end)
end
