# oreMining
A plugin for helix that will add the ability to mine ore to your server.
> [!NOTE]
> To start working, you just need to spawn the ore spawner entity, and also slightly edit the file `entities/entities/ix_rockspawner/shared.lua`
---------------------
### Actions in `entities/entities/ix_rockspawner/shared.lua`
You can configure everything you need in the following part of the code:
```lua
local CONFIG = {
    -- Admin-only spawning (true/false)
    AdminOnly = true,
    -- Rock health (how much damage required to break)
    RockHealth = 100,
    -- Time (in seconds) before the rock model appears after spawning
    RockSpawnTime = 6,
    -- List of possible rock models
    RockModels = {
        "models/props_wasteland/rockgranite03c.mdl",
        "models/props_wasteland/rockgranite03b.mdl",
        "models/props_wasteland/rockgranite03a.mdl",
        "models/props_wasteland/rockgranite02c.mdl",
        "models/props_wasteland/rockgranite02b.mdl",
        "models/props_wasteland/rockgranite02a.mdl"
    },
    -- Items to drop and their probabilities (total should be 100)
    Items = {
        {id = "coal", probability = 50},
        {id = "copper", probability = 15},
        {id = "iron", probability = 15},
        {id = "silver", probability = 10},
        {id = "gold", probability = 5}
    },
    -- Sound to play when the rock is broken
    BreakSound = "physics/concrete/boulder_impact_hard4.wav",
    -- A weapon that can destroy stone
    RockWeapon = "weapon_crowbar"
}
```
---------------------
### Installation
to install, simply drag the plugin folder into your schema `plugins folder`
