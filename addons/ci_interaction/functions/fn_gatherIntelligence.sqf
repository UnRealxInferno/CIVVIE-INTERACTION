/*
    Gather Intelligence (Addon)
    Parameters: 0: OBJECT - Civilian
    
    Called when player asks for information - civilian "looks around" for threats
    
    Enemy data structure: Each enemy entry is an array containing:
    [position, enemyCount, distance, unitArray]
    - position: Center position of the enemy cluster
    - enemyCount: Number of enemies in the cluster (150m clustering radius)
    - distance: Distance from civilian to cluster center
    - unitArray: Array of actual enemy units in the cluster
    
    Mine data structure: Each mine entry is an array containing:
    [position, mineCount, distance, mineArray]
    - position: Center position of the minefield
    - mineCount: Number of mines/explosives in the cluster (50m clustering radius)
    - distance: Distance from civilian to cluster center
    - mineArray: Array of actual mine/explosive objects in the cluster
    
    Death detection:
    - Detects dead civilians within 200m radius
    - Stores count in CI_DeadCiviliansNearby variable
    - Used by processInteractionResponse to reduce cooperation chance
*/
params ["_civilian"];

// Civilian actively scans the area when asked
private _knownEnemies = [];
private _detectedEnemies = [];

// Determine the reference side for hostility checks: prefer interacting player's side
private _playerSide = side player;
if (!isNil "CI_CurrentPlayer") then {
    private _p = CI_CurrentPlayer;
    if (!isNull _p) then { _playerSide = side _p; };
};

// First pass: detect individual enemies
{
    // Check if unit is hostile to the interacting player's side (exclude the civilian itself)
    if (
        alive _x &&
        {_x != _civilian} &&
        {[_playerSide, side _x] call BIS_fnc_sideIsEnemy}
    ) then {
        private _distance = _civilian distance _x;
        // High detection chance when actively looking
        private _noticeChance = 1.0 - (_distance / CI_INTEL_RANGE * 0.8); // 100% at 0m, 20% at max range
        if (speed _x > 1) then { _noticeChance = _noticeChance + 0.3; }; // Moving bonus for easier detection
        _noticeChance = _noticeChance max 0.1; // Minimum 10% chance
        if (random 1 < _noticeChance) then { 
            _detectedEnemies pushBack _x;
        };
    };
} forEach (_civilian nearEntities ["Man", CI_INTEL_RANGE]);

// Second pass: for each detected enemy, find nearby enemies to create group/cluster intel
private _processedEnemies = [];
{
    private _primaryEnemy = _x;
    if !(_primaryEnemy in _processedEnemies) then {
        // Find all other detected enemies within 150m of this enemy (cluster detection)
        private _nearbyEnemies = [];
        _nearbyEnemies pushBack _primaryEnemy;
        _processedEnemies pushBack _primaryEnemy;
        
        {
            private _otherEnemy = _x;
            if (_otherEnemy != _primaryEnemy && !(_otherEnemy in _processedEnemies)) then {
                if (_primaryEnemy distance _otherEnemy <= 150) then {
                    _nearbyEnemies pushBack _otherEnemy;
                    _processedEnemies pushBack _otherEnemy;
                };
            };
        } forEach _detectedEnemies;
        
        // Create cluster entry with position, count, and closest distance to civilian
        private _clusterData = [
            getPos _primaryEnemy,  // 0: Position (center of cluster)
            count _nearbyEnemies,  // 1: Enemy count in cluster
            _civilian distance _primaryEnemy,  // 2: Distance to cluster
            _nearbyEnemies         // 3: Array of enemy units in cluster
        ];
        
        _knownEnemies pushBack _clusterData;
    };
} forEach _detectedEnemies;

private _knownMines = [];
private _detectedMines = [];

// First pass: detect individual explosives
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
			"IED",
            "TimeBomb",
            "Explosive"
        ]) then {
            _isExplosive = true;
        } else {
            // Basic string checks for common explosives
            if (
                ("MINE" in _classnameUpper) or                // Mine variants
                ("CHARGE" in _classnameUpper) or              // Demo/satchel charges
                ("EXPLOSIVE" in _classnameUpper) or           // Generic explosives
                ("IED" in _classnameUpper)                     // IED variants
            ) then {
                _isExplosive = true;
            };
        };
    };
    
    // Apply detection chance if it's an explosive and alive
    if (_isExplosive && {!isNull _x} && {alive _x}) then {
        private _distance = _civilian distance _x;
        // Simplified mine detection - uniform 300m range with logical detection rates
        if (_distance <= 300) then {
            private _noticeChance = 0.8 - (_distance / 300 * 0.7); // 80% at 0m, 10% at 300m (linear decrease)
            if (random 1 < _noticeChance) then { 
                _detectedMines pushBack _x;
            };
        };
    };
} forEach (_civilian nearObjects ["All", 300]);

// Second pass: for each detected mine, find nearby mines to create cluster/field intel
private _processedMines = [];

{
    private _primaryMine = _x;
    if !(_primaryMine in _processedMines) then {
        // Find all other detected mines within 50m of this mine (minefield detection)
        private _nearbyMines = [];
        _nearbyMines pushBack _primaryMine;
        _processedMines pushBack _primaryMine;
        
        {
            private _otherMine = _x;
            if (_otherMine != _primaryMine && !(_otherMine in _processedMines)) then {
                if (_primaryMine distance _otherMine <= 50) then {
                    _nearbyMines pushBack _otherMine;
                    _processedMines pushBack _otherMine;
                };
            };
        } forEach _detectedMines;
        
        // Create cluster entry with position, count, and closest distance to civilian
        private _clusterData = [
            getPos _primaryMine,   // 0: Position (center of minefield)
            count _nearbyMines,    // 1: Mine count in cluster
            _civilian distance _primaryMine,  // 2: Distance to cluster
            _nearbyMines           // 3: Array of mine objects in cluster
        ];
        
        _knownMines pushBack _clusterData;
    };
} forEach _detectedMines;

// Third pass: detect nearby dead civilians to affect cooperation
private _deadCivilians = [];

{
    // Check if unit is a dead civilian
    // Note: nearEntities with CI_DEATH_DETECTION_RANGE already filters by distance
    if (
        !alive _x &&
        {side _x == civilian} &&
        {_x != _civilian}
    ) then {
        _deadCivilians pushBack _x;
    };
} forEach (_civilian nearEntities ["Man", CI_DEATH_DETECTION_RANGE]);

_civilian setVariable ["CI_KnownEnemies", _knownEnemies];
_civilian setVariable ["CI_KnownMines", _knownMines];
_civilian setVariable ["CI_DeadCiviliansNearby", count _deadCivilians];
