# Civilian Interaction Addon for Arma 3

An Arma 3 addon that lets players talk to civilians to gather intelligence about enemies and explosives. Features a reputation system that affects how helpful civilians are.

## Features

- Talk to civilians using the interaction menu
- Get intel on nearby enemies and their locations
- Detect mines, IEDs, and other explosives
- Reputation system - be nice and civilians help more
- Auto-creates map markers for discovered threats
- Works in multiplayer

## Installation

1. Copy `ci_interaction.pbo` to your Arma 3 `@YourMod/addons/` folder
2. Load the mod in Arma 3
3. That's it! The addon auto-initializes

## How to Use

### For Players
1. Walk up to a civilian
2. Use scroll wheel menu → "Talk to Civilian"
3. Ask about enemies or explosives
4. Check your map for new markers

### For Mission Makers

**Set reputation in your mission's `init.sqf`:**
```sqf
CI_PlayerReputation = 75; // 0-100 scale (50 is neutral)
```

**Reputation levels:**
- 0-20: Civilians won't help
- 21-40: Limited cooperation
- 41-60: Neutral
- 61-80: Friendly
- 81-100: Very helpful

**Add interaction to specific civilians:**
```sqf
[_civilianUnit] call CI_fnc_addInteractionToUnit;
```

## Settings

- **Detection range**: 1000m for enemies and explosives
- **Map markers**: Auto-remove after 5 minutes
- **Works with**: Vanilla Arma 3, ACE, and most mods

## Known Issues

- IEDs placed in 3DEN editor might not be detected (Arma 3 limitation)
- Use scripted placement for reliable IED detection:
  ```sqf
  "IEDLandBig_Remote_Mag" createVehicle [x, y, z];
  ```
