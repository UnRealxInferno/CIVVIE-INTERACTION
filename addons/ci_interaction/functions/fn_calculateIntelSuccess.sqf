/*
    Calculate Intel Success (Server-side)
    Author: Inferno
    
    MULTIPLAYER SECURITY: This function MUST run on server to prevent client-side abuse.
    Calculates whether a civilian will share intelligence with a player.
    The random chance calculation happens server-side so clients cannot manipulate it.
    
    Parameters:
    0: OBJECT - Civilian
    1: OBJECT - Player requesting intel
    2: STRING - Question type ("enemies", "mines", "general")
    
    Returns result to client via remoteExec callback
*/
params ["_civilian", "_player", "_questionType"];

// SECURITY: Must run on server only
if (!isServer) exitWith {
    // Forward to server
    [_civilian, _player, _questionType] remoteExecCall ["CI_fnc_calculateIntelSuccess", 2];
};

// Validate inputs
if (isNull _civilian || isNull _player) exitWith {};

// Check if civilian has already shared specific intel types (server-authoritative)
private _hasSharedEnemyIntel = _civilian getVariable ["CI_HasSharedEnemyIntel", false];
private _hasSharedMineIntel = _civilian getVariable ["CI_HasSharedMineIntel", false];

// SERVER-SIDE: Random success chance between 25-75%
// This runs on server so clients cannot manipulate the random result
private _successChance = 0.25 + (random 0.5);

// Apply penalty for nearby dead civilians (data gathered by server in gatherIntelligence)
private _deadCiviliansNearby = _civilian getVariable ["CI_DeadCiviliansNearby", 0];

// Get configurable values using same approach as original code
private _deathPenaltyPerCivilian = if (isNil "CI_DEATH_PENALTY_PER_CIVILIAN") then { 0.15 } else { CI_DEATH_PENALTY_PER_CIVILIAN };
private _deathPenaltyMax = if (isNil "CI_DEATH_PENALTY_MAX") then { 0.6 } else { CI_DEATH_PENALTY_MAX };
private _minSuccessChance = if (isNil "CI_MIN_SUCCESS_CHANCE") then { 0.05 } else { CI_MIN_SUCCESS_CHANCE };

if (_deadCiviliansNearby > 0) then {
    // Reduce success chance based on configurable penalty values
    private _deathPenalty = (_deadCiviliansNearby * _deathPenaltyPerCivilian) min _deathPenaltyMax;
    _successChance = (_successChance - _deathPenalty) max _minSuccessChance;
};

// SERVER-SIDE: Calculate success
private _success = random 1 < _successChance;

// Get intel data (already gathered on server)
private _enemies = _civilian getVariable ["CI_KnownEnemies", []];
private _mines = _civilian getVariable ["CI_KnownMines", []];

// Prepare result data to send to client
private _resultData = [
    _questionType,         // 0: question type
    _success,              // 1: success (true/false)
    _hasSharedEnemyIntel,  // 2: already shared enemy intel
    _hasSharedMineIntel,   // 3: already shared mine intel
    _enemies,              // 4: enemy cluster data
    _mines,                // 5: mine cluster data
    _deadCiviliansNearby,  // 6: dead civilians count
    name _civilian         // 7: civilian name for display
];

// Mark intel as shared on server (before sending to client)
switch (_questionType) do {
    case "enemies": {
        if (!_hasSharedEnemyIntel) then {
            _civilian setVariable ["CI_HasSharedEnemyIntel", true, true];
        };
    };
    case "mines": {
        if (!_hasSharedMineIntel) then {
            _civilian setVariable ["CI_HasSharedMineIntel", true, true];
        };
    };
};

// Send result to requesting player's client
[_resultData] remoteExecCall ["CI_fnc_handleIntelResult", _player];
