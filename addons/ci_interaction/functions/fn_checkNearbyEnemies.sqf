/*
    Check Nearby Enemies (Addon)
    
    MULTIPLAYER SECURITY: This function should ideally run on server.
    Returns array of enemy units within radius.
    
    Params: 
    0: OBJECT - center position object
    1: NUMBER - radius (default 1000)
    2: OBJECT - reference player for side checks (optional)
*/
params ["_center", ["_radius", 1000], ["_referencePlayer", objNull]];

private _enemies = [];

// Determine reference side: prefer passed player, then global var, then local player
private _playerSide = civilian;
if (!isNull _referencePlayer) then {
    _playerSide = side _referencePlayer;
} else {
    if (!isNil "CI_CurrentPlayer") then {
        private _p = CI_CurrentPlayer;
        if (!isNull _p) then { _playerSide = side _p; };
    } else {
        if (hasInterface) then { _playerSide = side player; };
    };
};

{
    if (alive _x && {[_playerSide, side _x] call BIS_fnc_sideIsEnemy}) then { 
        _enemies pushBack _x; 
    };
} forEach (_center nearEntities ["Man", _radius]);

_enemies
