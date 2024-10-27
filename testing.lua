local Workspace, RunService, Players, CoreGui, Lighting = cloneref(game:GetService("Workspace")), cloneref(game:GetService("RunService")), cloneref(game:GetService("Players")), game:GetService("CoreGui"), cloneref(game:GetService("Lighting"))

_Periphean = _Periphean or {}
_Periphean.ESPConfig = _Periphean.ESPConfig or {
    Enabled = true,
    MaxDistance = 99999,
    FontSize = 11,
    MinFontSize = 8, -- scaling
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
            HealthTextRGB = Color3.fromRGB(119, 120, 255),
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
    },
    Connections = {
        RunService = RunService;
    },
}

local ESP = _Periphean.ESPConfig

-- Rest of your ESP script...

-- variables
local lplayer = Players.LocalPlayer;
local camera = game.Workspace.CurrentCamera;
local Cam = Workspace.CurrentCamera;

-- funct
local Functions = {}
do
    function Functions:Create(Class, Properties)
        local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
        for Property, Value in pairs(Properties) do
            _Instance[Property] = Value
        end
        return _Instance;
    end

    function Functions:Lerp(a, b, t)
        return a + (b - a) * t
    end
end;

do -- initialize
    local ScreenGui = Functions:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "ESPHolder",
    });

    local ESP = function(plr)
        local Name = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, -11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
        local Distance = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
        local Box = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.75, BorderSizePixel = 0})
        local Healthbar = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0})
        local BehindHealthbar = Functions:Create("Frame", {Parent = ScreenGui, ZIndex = -1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0})
        local HealthText = Functions:Create("TextLabel", {Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 20), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})

        local LeftTop = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local LeftSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local RightTop = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local RightSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomDown = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomRightSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomRightDown = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})

        local Connection;
        local function HideESP()
            Box.Visible = false;
            Name.Visible = false;
            Distance.Visible = false;
            Healthbar.Visible = false;
            BehindHealthbar.Visible = false;
            HealthText.Visible = false;
            LeftTop.Visible = false;
            LeftSide.Visible = false;
            BottomSide.Visible = false;
            BottomDown.Visible = false;
            RightTop.Visible = false;
            RightSide.Visible = false;
            BottomRightSide.Visible = false;
            BottomRightDown.Visible = false;
            if not plr then
                ScreenGui:Destroy();
                Connection:Disconnect();
            end
        end

        Connection = ESP.Connections.RunService.RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local HRP = plr.Character.HumanoidRootPart
                local Humanoid = plr.Character:WaitForChild("Humanoid");
                local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
                local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
                
                if OnScreen and Dist <= ESP.MaxDistance then
                    local Size = HRP.Size.Y
                    local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                    local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                    local targetTextSize = math.max(ESP.MinFontSize, ESP.FontSize * (1 - (Dist / ESP.MaxDistance)))
                    local currentTextSize = Name.TextSize
                    local smoothTextSize = Functions:Lerp(currentTextSize, targetTextSize, 0.1)

                    -- boxes
                    Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                    Box.Size = UDim2.new(0, w, 0, h)
                    Box.Visible = ESP.Drawing.Boxes.Full.Enabled;
                    Box.BackgroundColor3 = ESP.Drawing.Boxes.Filled.RGB
                    Box.BackgroundTransparency = ESP.Drawing.Boxes.Filled.Transparency

                    LeftTop.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    LeftTop.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                    LeftTop.Size = UDim2.new(0, w / 5, 0, 1)
                    
                    LeftSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    LeftSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                    LeftSide.Size = UDim2.new(0, 1, 0, h / 5)
                    
                    BottomSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    BottomSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                    BottomSide.Size = UDim2.new(0, 1, 0, h / 5)
                    BottomSide.AnchorPoint = Vector2.new(0, 5)
                    
                    BottomDown.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    BottomDown.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                    BottomDown.Size = UDim2.new(0, w / 5, 0, 1)
                    BottomDown.AnchorPoint = Vector2.new(0, 1)
                    
                    RightTop.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    RightTop.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y - h / 2)
                    RightTop.Size = UDim2.new(0, w / 5, 0, 1)
                    RightTop.AnchorPoint = Vector2.new(1, 0)
                    
                    RightSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    RightSide.Position = UDim2.new(0, Pos.X + w / 2 - 1, 0, Pos.Y - h / 2)
                    RightSide.Size = UDim2.new(0, 1, 0, h / 5)
                    RightSide.AnchorPoint = Vector2.new(0, 0)
                    
                    BottomRightSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    BottomRightSide.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                    BottomRightSide.Size = UDim2.new(0, 1, 0, h / 5)
                    BottomRightSide.AnchorPoint = Vector2.new(1, 1)
                    
                    BottomRightDown.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    BottomRightDown.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                    BottomRightDown.Size = UDim2.new(0, w / 5, 0, 1)
                    BottomRightDown.AnchorPoint = Vector2.new(1, 1)

                    -- healthbar
                    local health = Humanoid.Health / Humanoid.MaxHealth;
                    Healthbar.Visible = ESP.Drawing.Healthbar.Enabled;
                    Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - health))  
                    Healthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h * health)
                    Healthbar.BackgroundColor3 = Color3.fromHSV(health * 0.33, 1, 1)
                    BehindHealthbar.Visible = ESP.Drawing.Healthbar.Enabled;
                    BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2)  
                    BehindHealthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h)

                    -- health text
                    if ESP.Drawing.Healthbar.HealthText then
                        local healthPercentage = math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)
                        HealthText.Position = UDim2.new(0, Pos.X - w / 2 - 10, 0, Pos.Y - h / 2 + h / 2)
                        HealthText.Text = tostring(healthPercentage) .. "%"
                        HealthText.Visible = true
                        HealthText.TextColor3 = Color3.fromHSV(health * 0.33, 1, 1)
                        HealthText.TextSize = smoothTextSize
                    end
                    
                    -- names
                    Name.Visible = ESP.Drawing.Names.Enabled
                    if Name.Visible then
                        local nameText = ("%s"):format(plr.Name)
                        Name.Text = nameText
                        Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 9)
                        Name.TextSize = smoothTextSize
                    end

                    -- distance
                    if ESP.Drawing.Distances.Enabled then
                        Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)
                        Distance.Text = math.floor(Dist) .. " meters"
                        Distance.Visible = true
                        Distance.TextSize = smoothTextSize
                    end
                else
                    HideESP()
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
