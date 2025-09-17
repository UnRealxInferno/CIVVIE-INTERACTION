/*
    Gather Intelligence (Addon)
    Parameters: 0: OBJECT - Civilian
    
    Called when player asks for information - civilian "looks around" for threats
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

// Simplified explosive detection - focuses on reliable detection
// Note: 3DEN editor-placed IEDs have known detection limitations in Arma 3
{
    private _classname = typeOf _x;
    private _classnameUpper = toUpper _classname;
    private _isExplosive = false;
    
    // Check for reliable explosive types that work with both scripted and 3DEN placement
    if (
        (_x isKindOf "MineBase") or                       // Traditional mines (works with 3DEN)
        (_x isKindOf "TimeBomb") or                       // Timer bombs and some IEDs  
        (_x isKindOf "Explosive")                         // Generic explosives
    ) then {
        _isExplosive = true;
    } else {
        // Check for specific explosive classnames
        if (_classname in [
            "DemoCharge_Remote_Mag",
            "SatchelCharge_Remote_Mag", 
            "ClaymoreDirectionalMine_Remote_Mag",
            "TimeBomb",
            "Explosive"
        ]) then {
            _isExplosive = true;
        } else {
            // Basic string checks for common explosives
            if (
                ("MINE" in _classnameUpper) or                // Mine variants
                ("CHARGE" in _classnameUpper) or              // Demo/satchel charges
                ("EXPLOSIVE" in _classnameUpper)              // Generic explosives
            ) then {
                _isExplosive = true;
            };
        };
    };
    
    // Apply detection chance if it's an explosive and alive
    if (_isExplosive && {!isNull _x} && {alive _x}) then {
        private _distance = _civilian distance _x;
        // Mine detection when actively looking
        private _noticeChance = 0.8 - (_distance / CI_INTEL_RANGE * 0.6); // 80% at 0m, 20% at max range
        _noticeChance = _noticeChance max 0.05; // Minimum 5% chance
        if (random 1 < _noticeChance) then { 
            _knownMines pushBack _x;
        };
    };
} forEach (_civilian nearObjects ["All", CI_INTEL_RANGE]);

_civilian setVariable ["CI_KnownEnemies", _knownEnemies];
_civilian setVariable ["CI_KnownMines", _knownMines];
