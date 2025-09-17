# Civilian Interaction Addon for Arma 3

A comprehensive addon that allows players to interact with civilians to gather intelligence about enemy troops and explosive devices (mines/IEDs). The system features a global reputation system that affects civilian cooperation.

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

## Installation

1. Copy the `ci_interaction.pbo` file to your Arma 3 `@YourMod/addons/` folder
2. Load the mod in Arma 3
3. The addon will automatically initialize when the mission starts

## Usage

### For Players
1. Approach any civilian unit
2. Use the interaction menu (scroll wheel) to select "Talk to Civilian"
3. Choose from available dialog options:
   - Ask about enemy movements
   - Ask about mines/IEDs in the area
   - End conversation
4. Responses depend on your current reputation level

### For Mission Makers

#### Setting Initial Reputation
Add this to your mission's `init.sqf` to set a custom starting reputation:
```sqf
// Set player reputation (0-100, where 50 is neutral)
CI_PlayerReputation = 75; // High reputation - civilians are cooperative
```

#### Reputation Scale
- **0-20**: Very hostile - civilians refuse to help
- **21-40**: Unfriendly - limited cooperation
- **41-60**: Neutral - basic information sharing
- **61-80**: Friendly - helpful responses
- **81-100**: Very friendly - maximum cooperation

#### Adding Interactions to Custom Units
```sqf
// Add interaction to specific civilian
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
- **Enemy Detection**: 1000m radius (configurable in function)
- **Mine/IED Detection**: 1000m radius (configurable in function)
- **Map Marker Duration**: 300 seconds (5 minutes) auto-removal

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

Created for Arma 3 mission makers who want realistic civilian interaction mechanics with intelligence gathering capabilities.

## Version History

- **v1.0**: Initial release with core functionality
- **v1.1**: Enhanced IED detection and reputation system
- **v1.2**: Improved multiplayer compatibility and performance
- **Current**: Comprehensive explosive detection and map marker system
