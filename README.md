# Civilian Interaction Addon for Arma 3

An Arma 3 addon that lets players talk to civilians to gather intelligence about enemies and explosives. Features a reputation system that affects how helpful civilians are.

## Features

### Core Functionality
- **Interactive Dialog System**: Custom dialog interface for civilian interactions
- **Intelligence Gathering**: Get information about nearby enemies and explosive devices
- **Reputation System**: Global player reputation affects civilian cooperation
- **Map Markers**: Automatic creation of temporary map markers for discovered threats
- **Multiplayer Safe**: Designed to work in multiplayer environments
- **Dynamic Civilians**: Works with spawned/despawned civilians

### Intelligence Types
- **Enemy Intelligence**: Detects hostile units within configurable radius
  - **Cluster Detection**: Groups nearby enemies together (within 150m) for realistic reporting
  - **Distance Prioritization**: Always reports closest enemy clusters first for tactical relevance
  - Reports approximate numbers ("I saw 3 armed men") and distances
  - **Smart Distance Reporting**: "Really close by" for threats under 100m, rounded distances for farther enemies
  - Uses proper side hostility checks via `BIS_fnc_sideIsEnemy`
  - Creates temporary map markers showing "Enemy Spotted" or "Enemy Group (X)" for clusters

- **Explosive Device Detection**: Mine and explosive detection with limitations
  - **Cluster Detection**: Groups nearby mines/explosives together (within 50m) for minefield reporting
  - **Distance Prioritization**: Always reports closest mine clusters first for immediate threat awareness
  - **Traditional mines** (MineBase class) - Full 3DEN editor support
  - **Demo charges and satchel charges** - Full support
  - **Claymore mines** - Full support  
  - **IEDs**: Limited support - works reliably with scripted placement
  - **Smart Distance Reporting**: "Really close by" for threats under 100m, rounded distances for farther threats
  - **Minefield Intelligence**: Reports "minefield with X explosives" for clustered mines vs individual mine reports
  - **⚠️ Known Limitation**: 3DEN editor-placed IEDs may not be detected due to Arma 3 engine limitations
  - Works with ACE explosives (respects defused status)

### Reputation System
- **Global Parameter**: Uses `CI_PlayerReputation` (0-100 scale)
- **Dynamic Responses**: Civilian cooperation varies based on reputation
- **Mission Maker Control**: Can be overridden in mission `init.sqf`
- **Realistic Behavior**: Low reputation = less cooperation, high reputation = more helpful
- **Death Detection**: Civilians detect nearby dead civilians (within 200m) and become significantly less cooperative
  - Each dead civilian reduces cooperation chance by 15% (maximum 60% reduction)
  - Civilians provide contextual fear-based responses when refusing to help due to nearby deaths
- Talk to civilians using the interaction menu
- Get intel on nearby enemies and their locations
- Detect mines, IEDs, and other explosives
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

#### Setting Initial Reputation
Add this to your mission's `init.sqf` to set a custom starting reputation:
```sqf
// Set player reputation (0-100, where 50 is neutral)
CI_PlayerReputation = 75; // High reputation - civilians are cooperative
```

#### Configuring Death Detection System
Customize the death detection behavior in your mission's `init.sqf`:
```sqf
// Detection range for dead civilians (default: 200m)
CI_DEATH_DETECTION_RANGE = 150;

// Penalty per dead civilian (default: 0.15 or 15%)
CI_DEATH_PENALTY_PER_CIVILIAN = 0.20;

// Maximum total penalty (default: 0.6 or 60%)
CI_DEATH_PENALTY_MAX = 0.5;

// Minimum success chance floor (default: 0.05 or 5%)
CI_MIN_SUCCESS_CHANCE = 0.10;
```

#### Reputation Scale
- **0-20**: Very hostile - civilians refuse to help
- **21-40**: Unfriendly - limited cooperation
- **41-60**: Neutral - basic information sharing
- **61-80**: Friendly - helpful responses
- **81-100**: Very friendly - maximum cooperation

#### Adding Interactions to Custom Units
**Add interaction to specific civilians:**
```sqf
[_civilianUnit] call CI_fnc_addInteractionToUnit;

// Add to all civilians in area
{
    if (side _x == civilian) then {
        [_x] call CI_fnc_addInteractionToUnit;
    };
} forEach allUnits;
```

## Configuration

### Detection Ranges
- **Enemy Detection**: 1000m radius (configurable via `CI_INTEL_RANGE`)
- **Mine/IED Detection**: 1000m radius (configurable via `CI_INTEL_RANGE`)
- **Dead Civilian Detection**: 200m radius (configurable via `CI_DEATH_DETECTION_RANGE`)
- **Map Marker Duration**: 300 seconds (5 minutes) auto-removal

### Death Detection Parameters
- **CI_DEATH_DETECTION_RANGE**: Detection range for dead civilians (default: 200m)
- **CI_DEATH_PENALTY_PER_CIVILIAN**: Cooperation penalty per death (default: 0.15 or 15%)
- **CI_DEATH_PENALTY_MAX**: Maximum total penalty cap (default: 0.6 or 60%)
- **CI_MIN_SUCCESS_CHANCE**: Minimum success chance floor (default: 0.05 or 5%)

### Supported Explosive Types
The addon detects a wide range of explosive devices:
- All MineBase variants (AP mines, AT mines, etc.)
- TimeBomb class objects (many IEDs use this)
- Demo charges and satchel charges
- Any object with classname containing: IED, Mine, Charge, Explosive, Bomb, Demo, C4, Claymore, Landmine
- Mod-specific explosives through pattern matching

## Technical Details

### File Structure
```
addons/ci_interaction/
├── config.cpp                                 # Addon configuration
├── dialogs/
│   ├── CI_baseControls.hpp                   # Base UI controls
│   └── civilianInteraction.hpp               # Main dialog definition
└── functions/
    ├── fn_addInteractionToUnit.sqf           # Add interaction to unit
    ├── fn_calculateReputation.sqf            # Reputation calculations
    ├── fn_checkNearbyEnemies.sqf             # Enemy detection
    ├── fn_gatherIntelligence.sqf             # Intelligence gathering & mine/IED detection
    ├── fn_initCivilianInteraction.sqf        # Initialization
    ├── fn_processInteractionResponse.sqf     # Dialog response processing
    ├── fn_showInteractionMenu.sqf            # Dialog display
    └── fn_updateReputationSystem.sqf         # Reputation updates
```

### CfgFunctions
All functions are registered under the `CI` tag and can be called using:
```sqf
[] call CI_fnc_functionName;
```

### Civilian Variables
- `CI_DeadCiviliansNearby`: Number of dead civilians detected within 200m (set during intelligence gathering)
- `CI_HasSharedEnemyIntel`: Boolean flag tracking if civilian has shared enemy intelligence
- `CI_HasSharedMineIntel`: Boolean flag tracking if civilian has shared mine intelligence
- `CI_InConversation`: Boolean flag indicating if civilian is currently in conversation
- `CI_KnownEnemies`: Array of detected enemy clusters
- `CI_KnownMines`: Array of detected mine clusters

### Compatibility
- **Base Game**: Full compatibility with vanilla Arma 3
- **ACE**: Respects ACE explosives defused status
- **Mods**: Designed to work with popular civilian and explosive mods
- **Multiplayer**: Safe for dedicated servers and multiplayer sessions

## Troubleshooting

### Common Issues
1. **No interaction option**: Ensure the civilian has the interaction added via script
2. **No intelligence found**: Check if enemies/explosives are actually within range
3. **Wrong reputation responses**: Verify `CI_PlayerReputation` is set correctly
4. **IEDs not detected**: 3DEN editor-placed IEDs have known detection issues - use scripted placement for reliable detection

### IED Detection Workaround
If you need reliable IED detection, use scripted placement instead of 3DEN editor:
```sqf
// In init.sqf or mission script - replace 3DEN IEDs with scripted ones
"IEDLandBig_Remote_Mag" createVehicle [x, y, z];
```

### Debug Information
The addon includes debug output (visible in system chat) for:
- Detected explosives with classnames and distances
- Reputation calculations
- Intelligence gathering results

### Performance
- Optimized search algorithms for large areas
- Efficient object filtering to minimize performance impact
- Temporary marker cleanup to prevent map clutter

## Credits
```

## Settings

- **Detection range**: 1000m for enemies and explosives
- **Map markers**: Auto-remove after 5 minutes
- **Works with**: Vanilla Arma 3, ACE, and most mods

## Known Issues

- **v1.0**: Initial release with core functionality
- **v1.1**: Enhanced IED detection and reputation system
- **v1.2**: Improved multiplayer compatibility and performance
- **v1.3**: Added civilian death detection system - civilians detect nearby deaths and become less cooperative
- **Current**: Comprehensive explosive detection, map marker system, and death-aware civilian behavior
- IEDs placed in 3DEN editor might not be detected (Arma 3 limitation)
- Use scripted placement for reliable IED detection:
  ```sqf
  "IEDLandBig_Remote_Mag" createVehicle [x, y, z];
  ```
