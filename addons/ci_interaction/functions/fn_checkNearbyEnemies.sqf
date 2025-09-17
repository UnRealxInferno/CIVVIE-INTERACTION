/*
    Check Nearby Enemies (Addon)
    Returns array of enemy units within radius
    Params: 0: OBJECT center, 1: NUMBER radius (default 1000)
*/
params ["_center", ["_radius", 1000]];
private _enemies = [];
// Determine reference side: prefer interacting player's side if available
private _playerSide = side player;
if (!isNil "CI_CurrentPlayer") then {
    private _p = CI_CurrentPlayer;
    if (!isNull _p) then { _playerSide = side _p; };
};
{
    if (alive _x && {[_playerSide, side _x] call BIS_fnc_sideIsEnemy}) then { 
        _enemies pushBack _x; 
    };
} forEach (_center nearEntities ["Man", _radius]);
_enemies
