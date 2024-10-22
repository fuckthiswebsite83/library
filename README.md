
# ESP Library Documentation

## ESPComponent
Base class for all ESP components.

### Methods

#### SetVisible
Sets the visibility of the ESP component.
```lua
<void> ESPComponent:SetVisible(<boolean> visible)
```

#### Destroy
Destroys the ESP component.
```lua
<void> ESPComponent:Destroy(<void>)
```

## Box
Represents a box ESP component.

### Methods

#### new
Creates a new `Box` instance.
```lua
<Box> Box.new(<Color3> boxColor, <number> boxThickness, <number> boxTransparency, <boolean> boxFilled, <Color3> fillColor, <number> fillTransparency)
```

#### Update
Updates the Box component based on character and configuration.
```lua
<void> Box:Update(<Instance> character, <table> bounds, <table> config)
```

#### SetVisible
Sets the visibility of the Box component.
```lua
<void> Box:SetVisible(<boolean> visible)
```

#### Destroy
Destroys the Box component.
```lua
<void> Box:Destroy(<void>)
```

## HealthBar
Represents a health bar ESP component.

### Methods

#### new
Creates a new `HealthBar` instance.
```lua
<HealthBar> HealthBar.new(<Color3> healthBarColor, <number> healthBarThickness, <number> healthBarTransparency, <boolean> healthBarFilled)
```

#### Update
Updates the HealthBar component based on character and configuration.
```lua
<void> HealthBar:Update(<Instance> character, <table> bounds, <table> config)
```

## NameTag
Represents a name tag ESP component.

### Methods

#### new
Creates a new `NameTag` instance.
```lua
<NameTag> NameTag.new(<Color3> nameTagColor, <number> nameTagSize, <boolean> nameTagCenter, <boolean> nameTagOutline, <Color3> nameTagOutlineColor)
```

#### Update
Updates the NameTag component based on character and configuration.
```lua
<void> NameTag:Update(<Instance> character, <table> bounds, <table> config)
```

## Distance
Represents a distance ESP component.

### Methods

#### new
Creates a new `Distance` instance.
```lua
<Distance> Distance.new(<Color3> distanceColor, <number> distanceSize, <boolean> distanceCenter, <boolean> distanceOutline, <Color3> distanceOutlineColor)
```

#### Update
Updates the Distance component based on character and configuration.
```lua
<void> Distance:Update(<Instance> character, <table> bounds, <table> config)
```

## Cham
Represents a cham ESP component.

### Methods

#### new
Creates a new `Cham` instance.
```lua
<Cham> Cham.new(<Color3> chamColor, <number> chamThickness, <number> chamTransparency, <boolean> wallCheck)
```

#### Update
Updates the Cham component based on character and configuration.
```lua
<void> Cham:Update(<Instance> character, <table> bounds, <table> config)
```

## ESPObject
Represents an ESP object containing multiple ESP components.

### Methods

#### new
Creates a new `ESPObject` instance.
```lua
<ESPObject> ESPObject.new(<Color3> boxColor, <number> boxThickness, <number> boxTransparency, <boolean> boxFilled, <Color3> boxFillColor, <number> boxFillTransparency, <Color3> healthBarColor, <number> healthBarThickness, <number> healthBarTransparency, <boolean> healthBarFilled, <Color3> nameTagColor, <number> nameTagSize, <boolean> nameTagCenter, <boolean> nameTagOutline, <Color3> nameTagOutlineColor, <Color3> distanceColor, <number> distanceSize, <boolean> distanceCenter, <boolean> distanceOutline, <Color3> distanceOutlineColor, <Color3> chamColor, <number> chamThickness, <number> chamTransparency, <boolean> wallCheck)
```

#### Update
Updates the ESPObject based on character and configuration.
```lua
<void> ESPObject:Update(<Instance> character, <table> config)
```

#### CalculateBounds
Calculates the bounds of the character for ESP rendering.
```lua
<table> ESPObject:CalculateBounds(<Instance> character)
```

#### SetVisible
Sets the visibility of the ESPObject.
```lua
<void> ESPObject:SetVisible(<boolean> visible)
```

#### Destroy
Destroys the ESPObject and all its components.
```lua
<void> ESPObject:Destroy(<void>)
```

## ESP
Main ESP library.

### Properties

#### Object
Reference to the ESPObject class.
```lua
ESP.Object
```
