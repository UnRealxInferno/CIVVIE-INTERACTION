/*
    Process Interaction Response (Addon)
    Parameters:
    0: STRING - Question type ("enemies","mines","general")
*/
params ["_questionType"];

private _civilian = CI_CurrentCivilian;
private _player = CI_CurrentPlayer;
if (isNil "_civilian" || {isNil "_player"}) exitWith { hint "Error: Invalid interaction data"; };

// Check if civilian has already shared specific intel types
private _hasSharedEnemyIntel = _civilian getVariable ["CI_HasSharedEnemyIntel", false];
private _hasSharedMineIntel = _civilian getVariable ["CI_HasSharedMineIntel", false];

private _reputation = CI_PlayerReputation;
private _successChance = switch (true) do {
    case (_reputation >= 80): {0.9};
    case (_reputation >= 60): {0.7};
    case (_reputation >= 40): {0.5};
    case (_reputation >= 20): {0.3};
    default {0.1};
};

private _success = random 1 < _successChance;
private _response = "";
private _gaveEnemyIntel = false;
private _gaveMineIntel = false;

switch (_questionType) do {
    case "enemies": {
        if (_hasSharedEnemyIntel) then {
            _response = selectRandom [
                "I've already told you everything I know about armed men in the area.",
                "Like I said before, that's all I know about enemies around here.",
                "I already shared what I've seen regarding hostile forces.",
                "I've told you all I can about that already."
            ];
        } else {
            if (_success) then {
                private _enemies = _civilian getVariable ["CI_KnownEnemies", []];
                if ((count _enemies) > 0) then {
                    private _enemyCluster = selectRandom _enemies;
                    _enemyCluster params ["_position", "_enemyCount", "_distance", "_unitArray"];
                    
                    // Create map marker for the cluster
                    private _markerName = format ["CI_EnemyIntel_%1", time];
                    private _marker = createMarkerLocal [_markerName, _position];
                    _marker setMarkerTypeLocal "hd_warning";
                    _marker setMarkerColorLocal "ColorRed";
                    
                    // Format response based on enemy count and distance
                    private _distanceText = "";
                    if (_distance < 100) then {
                        _distanceText = "really close by";
                    } else {
                        _distanceText = format ["%1 meters away", (round (_distance / 100)) * 100];
                    };
                    
                    if (_enemyCount == 1) then {
                        _marker setMarkerTextLocal "Enemy Spotted";
                        _response = format ["Yes, I saw an armed man %1. I've marked it on your map.", _distanceText];
                    } else {
                        _marker setMarkerTextLocal format ["Enemy Group (%1)", _enemyCount];
                        _response = format ["Yes, I saw %1 armed men %2. They seem to be together. I've marked their location on your map.", _enemyCount, _distanceText];
                    };
                    
                    _marker setMarkerSizeLocal [1.0, 1.0];
                    _gaveEnemyIntel = true;
                    
                    // Remove marker after 5 minutes
                    [{deleteMarkerLocal _this}, _markerName, 300] spawn {
                        params ["_code", "_marker", "_delay"];
                        sleep _delay;
                        _marker call _code;
                    };
                } else {
                    _response = "I haven't seen any armed men around here recently.";
                    _gaveEnemyIntel = true; // Mark as shared even if no intel to prevent repeated questions
                };
            } else {
                private _responses = [
                    "I don't know anything about that.",
                    "I prefer not to talk about such things.", 
                    "Sorry, I haven't seen anything.",
                    "I don't pay attention to those matters.",
                    "I'm just trying to mind my own business."
                ];
                _response = selectRandom _responses;
                _gaveEnemyIntel = true; // Mark as shared even if refused to prevent spam
            };
        };
    };
    case "mines": {
        if (_hasSharedMineIntel) then {
            _response = selectRandom [
                "I already told you what I know about dangerous areas.",
                "Like I mentioned before, that's all I know about explosives around here.",
                "I've shared everything I can about mines in the area.",
                "I already gave you all the information I have about that."
            ];
        } else {
            if (_success) then {
                private _mines = _civilian getVariable ["CI_KnownMines", []];
                if ((count _mines) > 0) then {
                    private _mineCluster = selectRandom _mines;
                    _mineCluster params ["_position", "_mineCount", "_distance", "_mineArray"];
                    
                    // Create map marker for mine location
                    private _markerName = format ["CI_MineIntel_%1", time];
                    private _marker = createMarkerLocal [_markerName, _position];
                    _marker setMarkerTypeLocal "hd_warning";
                    _marker setMarkerColorLocal "ColorYellow";
                    _marker setMarkerSizeLocal [0.7, 0.7];
                    
                    // Format response based on distance
                    private _distanceText = "";
                    if (_distance < 100) then {
                        _distanceText = "really close by";
                    } else {
                        _distanceText = format ["%1 meters away", (round (_distance / 100)) * 100];
                    };
                    
                    // Format response based on mine count and distance
                    if (_mineCount == 1) then {
                        _marker setMarkerTextLocal "Possible Mine";
                        _response = format ["Be careful! I think there might be explosives buried %1. I've marked the area on your map.", _distanceText];
                    } else {
                        _marker setMarkerTextLocal format ["Minefield (%1)", _mineCount];
                        _response = format ["Be very careful! I think there's a minefield with %1 explosives %2. They seem to be placed together. I've marked the dangerous area on your map.", _mineCount, _distanceText];
                    };
                    
                    _gaveMineIntel = true;
                    
                    // Remove marker after 10 minutes
                    [{deleteMarkerLocal _this}, _markerName, 600] spawn {
                        params ["_code", "_marker", "_delay"];
                        sleep _delay;
                        _marker call _code;
                    };
                } else {
                    _response = "I don't know of any dangerous areas around here.";
                    _gaveMineIntel = true;
                };
            } else {
                private _responses = [
                    "I don't know about such things.",
                    "I try not to wander far from here.",
                    "Sorry, I can't help with that.",
                    "I don't know the area that well.",
                    "I haven't noticed anything dangerous."
                ];
                _response = selectRandom _responses;
                _gaveMineIntel = true;
            };
        };
    };
    case "general": {
        private _responses = [
            "Things have been quiet around here lately.",
            "I just try to keep to myself these days.",
            "It's hard times, but we manage.",
            "I hope this conflict ends soon.",
            "We just want to live in peace.",
            "The situation makes everyone nervous.",
            "I miss the old days when it was safer.",
            "We try to help each other when we can."
        ];
        _response = selectRandom _responses;
    };
};

// Mark civilian as having shared specific intel types
if (_gaveEnemyIntel) then {
    _civilian setVariable ["CI_HasSharedEnemyIntel", true];
};
if (_gaveMineIntel) then {
    _civilian setVariable ["CI_HasSharedMineIntel", true];
};

// Display response
hint format ["%1: %2", name _civilian, _response];

// Close dialog
closeDialog 0;
