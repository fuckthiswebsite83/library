
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

#### Update
Updates the ESPObject based on character and configuration.
```lua
<void> ESPObject:Update(<Instance> character, <table> config)
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
