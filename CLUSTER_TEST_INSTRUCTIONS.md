# Testing Cluster Detection and Improved Distance Reporting

## Quick Test Setup

1. Load into any mission/scenario
2. Open debug console (Ctrl+D)
3. Paste and execute the content of `test_cluster_detection.sqf`
4. This will create test enemies, mines, and a civilian near your position

## Expected Behavior

### Enemy Cluster Detection
- **Multiple enemies close together (within 150m)** should be reported as a group
  - "Yes, I saw 3 armed men really close by. They seem to be together."
  - Map marker will show "Enemy Group (3)"

### Mine Cluster Detection  
- **Multiple mines close together (within 50m)** should be reported as a minefield
  - "Be very careful! I think there's a minefield with 4 explosives 200 meters away. They seem to be placed together."
  - Map marker will show "Minefield (4)"

### Improved Distance Reporting
- **Threats within 100m** should be reported as "really close by" instead of showing meters
- **Threats beyond 100m** will show rounded distance (200m, 300m, etc.)
- Applied to both enemy and mine intel for consistency

### Test Scenarios Created by Script
1. **Enemy group of 3** at ~200m → Should cluster and report "3 armed men 200 meters away"
2. **Single enemy** at ~70m → Should report "really close by"
3. **Two separate enemies** at ~300m each → Should be reported individually when asked multiple times
4. **Minefield of 4 mines** at ~150m → Should cluster and report "minefield with 4 explosives"
5. **Single mine** at ~80m → Should report "really close by"
6. **Two scattered mines** at ~300m each → Should be reported individually

## Manual Testing

### Distance Reporting Test
```sqf
// Create enemy at specific distance for testing
_testEnemy = createUnit ["O_Soldier_F", (getPos player) vectorAdd [80, 0, 0], [], 0, "NONE"];
_testCiv = createUnit ["C_man_1", (getPos player) vectorAdd [10, 10, 0], [], 0, "NONE"];
[_testCiv] call CI_fnc_addInteractionToUnit;
CI_PlayerReputation = 90;
```

### Enemy Cluster Detection Test
```sqf
// Create tight enemy formation
_group = [];
for "_i" from 0 to 4 do {
    _soldier = createUnit ["O_Soldier_F", (getPos player) vectorAdd [150 + (_i * 20), 100, 0], [], 0, "NONE"];
    _group pushBack _soldier;
};
```

### Mine Cluster Detection Test
```sqf
// Create a minefield pattern
_minefield = [];
for "_i" from 0 to 5 do {
    _mine = createMine ["APERSMine", (getPos player) vectorAdd [200 + (_i * 10), -150, 0], [], 0];
    _minefield pushBack _mine;
};
```

## What to Look For

✅ **Enemy Cluster Detection Working**: 
- Multiple nearby enemies are reported as a single group with count
- Map marker shows "Enemy Group (X)" instead of just "Enemy Spotted"

✅ **Mine Cluster Detection Working**:
- Multiple nearby mines are reported as a minefield with count
- Map marker shows "Minefield (X)" instead of just "Possible Mine"
- Civilians use more urgent language: "Be very careful!" for minefields

✅ **Close Distance Text Working**:
- Threats under 100m show "really close by" in civilian response
- Both enemy and mine intel use consistent distance language

✅ **Group Intelligence**:
- Civilians mention "They seem to be together" for clustered enemies
- Civilians mention "They seem to be placed together" for minefields
- Single threats still get individual reporting

## Cleanup
Run `call TEST_CleanupClusterTest;` in debug console to remove test units.

## Advanced Testing

### Test with ACE Combat
If using ACE mod, test with enemies that have fired shots (should get detection bonus):
```sqf
_enemy = createUnit ["O_Soldier_F", (getPos player) vectorAdd [200, 0, 0], [], 0, "NONE"];
_enemy setVariable ["ace_firedShots", 5];  // Simulate recent combat
```

### Test with Moving Enemies
```sqf
_enemy = createUnit ["O_Soldier_F", (getPos player) vectorAdd [200, 0, 0], [], 0, "NONE"];
_enemy forceSpeed 10;  // Make enemy move for detection bonus
```
