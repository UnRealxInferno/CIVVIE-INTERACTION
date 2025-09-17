/*
    Check Nearby Enemies (Addon)
    Returns array of enemy units within radius
    Params: 0: OBJECT center, 1: NUMBER radius (default 1000)
*/
params ["_center", ["_radius", 1000]];
private _enemies = [];
{
    if (alive _x && {side _x != civilian} && {[side _center, side _x] call BIS_fnc_sideIsEnemy}) then { 
        _enemies pushBack _x; 
    };
} forEach (_center nearEntities ["Man", _radius]);
_enemies
