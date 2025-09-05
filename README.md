# oreMining
A plugin for helix that will add the ability to mine ore to your server.
> [!NOTE]
> To start working, you just need to spawn the ore spawner entity, and also slightly edit the file `entities/entities/ix_rockspawner/shared.lua`
---------------------
### Actions in `entities/entities/ix_rockspawner/shared.lua`
You can specify a new item that can fall from the rock, for this you need to register it in the `items folder`, and then add its id and chance in percent in the `items table`. In the `rockModels table` you can add, change or delete rock models.

In order to change the sound, you will need to change the line in the following code:
```lua
sound.Add( {
	name = "rock_hasb_broken",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "physics/concrete/boulder_impact_hard4.wav" -- <==
} )
```

To change the model of the stone while it is broken you need to change the line here:
```lua
  self.RockHealth = 1250

	self:SetModel("models/props_junk/rock001a.mdl") -- <==
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
```

You can change the weapon that will be used for mining here:
```lua
    if dmginfo:GetDamageType() == DMG_SLASH and dmginfo:GetAttacker():GetActiveWeapon():GetClass() == "tfa_nmrih_pickaxe" and self.RockIsSpawn then
                                                                                                        ^^^^^^^^^^^^^^^
```
---------------------
### Installation
to install, simply drag the plugin folder into your schema `plugins folder`
