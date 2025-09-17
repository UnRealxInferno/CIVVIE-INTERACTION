/*
    Temporary 100% detection version for testing
    Copy this over fn_gatherIntelligence.sqf to test
*/
params ["_civilian"];

// Civilian actively scans the area when asked
private _knownEnemies = [];
{
    // Check if unit is hostile to civilians (not same side and not civilian)
    if (alive _x && {side _x != civilian} && {[side _civilian, side _x] call BIS_fnc_sideIsEnemy}) then {
        private _distance = _civilian distance _x;
        // High detection chance when actively looking
        private _noticeChance = 1.0 - (_distance / CI_INTEL_RANGE * 0.8); // 100% at 0m, 20% at max range
        if (speed _x > 1) then { _noticeChance = _noticeChance + 0.3; }; // Moving bonus
        if (_x getVariable ["ace_firedShots", 0] > 0) then { _noticeChance = _noticeChance + 0.4; }; // Firing bonus
        _noticeChance = _noticeChance max 0.1; // Minimum 10% chance
        if (random 1 < _noticeChance) then { 
            _knownEnemies pushBack _x;
        };
    };
} forEach (_civilian nearEntities ["Man", CI_INTEL_RANGE]);

private _knownMines = [];

// Enhanced explosive detection with 100% detection for testing
systemChat "=== MINE DETECTION DEBUG (100% chance) ===";
{
    private _classname = typeOf _x;
    private _classnameUpper = toUpper _classname;
    private _isExplosive = false;
    private _detectionMethod = "";
    
    // Debug: Show ALL objects that might be explosives
    if (
        ("IED" in _classnameUpper) or
        ("MINE" in _classnameUpper) or
        ("EXPLOSIVE" in _classnameUpper) or
        ("BOMB" in _classnameUpper) or
        ("CHARGE" in _classnameUpper) or
        (_x isKindOf "MineBase") or
        (_x isKindOf "TimeBomb") or
        (_x isKindOf "Explosive")
    ) then {
        systemChat format ["DEBUG: Checking %1 (class: %2, alive: %3, null: %4, distance: %5m)", 
            _x, _classname, alive _x, isNull _x, round (_civilian distance _x)];
    };
    
    // Comprehensive check using same logic as before
    if (
        (_x isKindOf "MineBase") or                       // Traditional mines
        (_x isKindOf "TimeBomb") or                       // Timer bombs and many IEDs  
        (_x isKindOf "Explosive") or                      // Generic explosives
        (_x isKindOf "Thing")                             // Many placed explosives inherit from Thing
    ) then {
        _isExplosive = true;
        _detectionMethod = "Class inheritance";
    } else {
        // Check for specific explosive classnames (exact matches)
        if (_classname in [
            "DemoCharge_Remote_Mag",
            "SatchelCharge_Remote_Mag", 
            "ClaymoreDirectionalMine_Remote_Mag",
            "APERSMine",
            "ATMine",
            "APERSBoundingMine",
            "APERSTripMine",
            "SLAMDirectionalMine",
            "TimeBomb",
            "Explosive",
            // Editor-placed IED variants
            "IEDLandBig_F",
            "IEDLandSmall_F", 
            "IEDUrbanBig_F",
            "IEDUrbanSmall_F",
            // Runtime IED variants
            "IEDLandBig_Remote_Mag",
            "IEDLandSmall_Remote_Mag",
            "IEDUrbanBig_Remote_Mag", 
            "IEDUrbanSmall_Remote_Mag"
        ]) then {
            _isExplosive = true;
            _detectionMethod = "Exact classname match";
        } else {
            // String-based checks for modded explosives
            if (
                ("IED" in _classnameUpper) or                 // IED variants
                ("MINE" in _classnameUpper) or                // Mine variants
                ("CHARGE" in _classnameUpper) or              // Demo/satchel charges
                ("EXPLOSIVE" in _classnameUpper) or           // Generic explosives
                ("BOMB" in _classnameUpper) or                // Bomb variants
                ("DEMO" in _classnameUpper) or                // Demo charges
                ("C4" in _classnameUpper) or                  // C4 explosives
                ("CLAYMORE" in _classnameUpper) or            // Claymore mines
                ("LANDMINE" in _classnameUpper) or            // Landmines
                ("SUICIDE" in _classnameUpper) or             // Suicide bomber items
                ("ROADSIDE" in _classnameUpper)               // Roadside bombs
            ) then {
                _isExplosive = true;
                _detectionMethod = "String pattern match";
            };
        };
    };
    
    // Apply 100% detection if it's an explosive and alive
    if (_isExplosive && {!isNull _x} && {alive _x}) then {
        _knownMines pushBack _x;
        systemChat format ["✓ DETECTED: %1 via %2 at %3m", _classname, _detectionMethod, round (_civilian distance _x)];
    } else {
        if (_isExplosive) then {
            systemChat format ["✗ REJECTED: %1 (null: %2, alive: %3)", _classname, isNull _x, alive _x];
        };
    };
} forEach (_civilian nearObjects ["All", CI_INTEL_RANGE]);

systemChat format ["=== FINAL RESULT: %1 explosives detected ===", count _knownMines];

_civilian setVariable ["CI_KnownEnemies", _knownEnemies];
_civilian setVariable ["CI_KnownMines", _knownMines];
