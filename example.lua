local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/fuckthiswebsite83/library/refs/heads/main/test.lua"))()
local activeESP = {}

local espConfig = {
    boxEnabled = true,
    boxColor = Color3.new(0.000000, 0.000000, 0.000000),
    boxThickness = 3,
    boxTransparency = 1,
    boxFilled = true,
    boxFillColor = Color3.new(0.764706, 0.478431, 1.000000),
    boxFillTransparency = 0.3,
    healthBarEnabled = true,
    healthBarColor = Color3.new(0, 1, 0),
    healthBarThickness = 1,
    healthBarTransparency = 1,
    healthBarFilled = true,
    nameTagEnabled = true,
    nameTagColor = Color3.new(1.000000, 1.000000, 1.000000),
    nameTagSize = 16,
    nameTagCenter = true,
    nameTagOutline = true,
    nameTagOutlineColor = Color3.new(0, 0, 0),
    distanceEnabled = true,
    distanceColor = Color3.new(1, 1, 1),
    distanceSize = 16,
    distanceCenter = true,
    distanceOutline = true,
    distanceOutlineColor = Color3.new(0, 0, 0),
    chamEnabled = true,
    chamColor = Color3.new(0, 0, 1),
    chamThickness = 2,
    chamTransparency = 0.86,
    wallCheck = true
}

local function createESP(player)
    if activeESP[player] then
        activeESP[player].esp:Destroy()
        if activeESP[player].connection then
            activeESP[player].connection:Disconnect()
        end
        activeESP[player] = nil
    end

    local espObject = ESP.Object.new(
        espConfig.boxEnabled and espConfig.boxColor or nil, 
        espConfig.boxEnabled and espConfig.boxThickness or nil, 
        espConfig.boxEnabled and espConfig.boxTransparency or nil, 
        espConfig.boxEnabled and espConfig.boxFilled or nil,
        espConfig.boxEnabled and espConfig.boxFillColor or nil,
        espConfig.boxEnabled and espConfig.boxFillTransparency or nil,
        espConfig.healthBarEnabled and espConfig.healthBarColor or nil, 
        espConfig.healthBarEnabled and espConfig.healthBarThickness or nil, 
        espConfig.healthBarEnabled and espConfig.healthBarTransparency or nil, 
        espConfig.healthBarEnabled and espConfig.healthBarFilled or nil,
        espConfig.nameTagEnabled and espConfig.nameTagColor or nil, 
        espConfig.nameTagEnabled and espConfig.nameTagSize or nil, 
        espConfig.nameTagEnabled and espConfig.nameTagCenter or nil, 
        espConfig.nameTagEnabled and espConfig.nameTagOutline or nil, 
        espConfig.nameTagEnabled and espConfig.nameTagOutlineColor or nil,
        espConfig.distanceEnabled and espConfig.distanceColor or nil, 
        espConfig.distanceEnabled and espConfig.distanceSize or nil, 
        espConfig.distanceEnabled and espConfig.distanceCenter or nil, 
        espConfig.distanceEnabled and espConfig.distanceOutline or nil, 
        espConfig.distanceEnabled and espConfig.distanceOutlineColor or nil,
        espConfig.chamEnabled and espConfig.chamColor or nil,
        espConfig.chamEnabled and espConfig.chamThickness or nil,
        espConfig.chamEnabled and espConfig.chamTransparency or nil,
        espConfig.wallCheck
    )

    local connection = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            espObject:Update(player.Character, espConfig)
        else
            espObject:SetVisible(false)
        end
    end)

    activeESP[player] = {
        esp = espObject,
        connection = connection
    }

    player.CharacterRemoving:Connect(function()
        if activeESP[player] and activeESP[player].esp then
            activeESP[player].esp:SetVisible(false)
        end
    end)

    player.AncestryChanged:Connect(function()
        if not player:IsDescendantOf(game) then
            if activeESP[player] then
                if activeESP[player].connection then
                    activeESP[player].connection:Disconnect()
                end
                activeESP[player].esp:Destroy()
                activeESP[player] = nil
            end
        end
    end)
end

local function toggleESPComponent(componentName, enabled)
    espConfig[componentName .. "Enabled"] = enabled
    for _, espData in pairs(activeESP) do
        if espData.esp[componentName] then
            espData.esp[componentName]:SetVisible(enabled)
        end
    end
end

local function toggleBoxes(enabled)
    toggleESPComponent("box", enabled)
end

local function toggleHealthBars(enabled)
    toggleESPComponent("healthBar", enabled)
end

local function toggleNames(enabled)
    toggleESPComponent("nameTag", enabled)
end

local function toggleDistance(enabled)
    espConfig.distanceEnabled = enabled
    toggleESPComponent("distance", enabled)
end

local function toggleChams(enabled)
    toggleESPComponent("cham", enabled)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if activeESP[player] then
        if activeESP[player].connection then
            activeESP[player].connection:Disconnect()
        end
        activeESP[player].esp:Destroy()
        activeESP[player] = nil
    end
end)

local function cleanup()
    for _, espData in pairs(activeESP) do
        if espData.connection then
            espData.connection:Disconnect()
        end
        espData.esp:Destroy()
    end
    activeESP = {}
end

return {
    toggleBoxes = toggleBoxes,
    toggleHealthBars = toggleHealthBars,
    toggleNames = toggleNames,
    toggleDistance = toggleDistance,
    toggleChams = toggleChams,
    cleanup = cleanup
}
