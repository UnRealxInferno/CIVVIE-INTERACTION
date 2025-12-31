/*
    Handle Intel Result (Client-side)
    Author: Inferno
    
    Receives intelligence results from server and handles client-side display.
    This runs on the client that requested intel.
    
    Parameters:
    0: ARRAY - Result data from server
        0: STRING - Question type
        1: BOOL - Success
        2: BOOL - Already shared enemy intel
        3: BOOL - Already shared mine intel  
        4: ARRAY - Enemy cluster data
        5: ARRAY - Mine cluster data
        6: NUMBER - Dead civilians count
        7: STRING - Civilian name
*/
params ["_resultData"];

_resultData params [
    "_questionType",
    "_success", 
    "_hasSharedEnemyIntel",
    "_hasSharedMineIntel",
    "_enemies",
    "_mines",
    "_deadCiviliansNearby",
    "_civilianName"
];

private _response = "";

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
                if ((count _enemies) > 0) then {
                    // Prioritize closest enemy cluster instead of random selection
                    private _closestCluster = _enemies select 0;
                    private _closestDistance = (_closestCluster select 2); // Distance is index 2
                    
                    {
                        private _currentDistance = _x select 2;
                        if (_currentDistance < _closestDistance) then {
                            _closestCluster = _x;
                            _closestDistance = _currentDistance;
                        };
                    } forEach _enemies;
                    
                    private _enemyCluster = _closestCluster;
                    _enemyCluster params ["_position", "_enemyCount", "_distance", "_unitArray"];
                    
                    // Create map marker for the cluster (LOCAL to this player only)
                    // Use getPlayerUID for unique marker names across clients
                    private _markerName = format ["CI_EnemyIntel_%1_%2", getPlayerUID player, diag_tickTime];
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
                    
                    // Vague group size descriptions to avoid counting bugs
                    if (_enemyCount == 1) then {
                        _marker setMarkerTextLocal "Enemy Spotted";
                        _response = format ["Yes, I saw an armed man %1. I've marked it on your map.", _distanceText];
                    } else {
                        if (_enemyCount <= 4) then {
                            _marker setMarkerTextLocal "Small Enemy Group";
                            _response = format ["Yes, I saw a small group of armed men %1. They seem to be together. I've marked their location on your map.", _distanceText];
                        } else {
                            if (_enemyCount <= 10) then {
                                _marker setMarkerTextLocal "Large Enemy Group";
                                _response = format ["Yes, I saw a larger group of armed men %1. There were quite a few of them together. I've marked their location on your map.", _distanceText];
                            } else {
                                _marker setMarkerTextLocal "Major Enemy Force";
                                _response = format ["Yes, I saw a big group of armed men %1. There were many of them - it looked like a serious force. I've marked their location on your map.", _distanceText];
                            };
                        };
                    };
                    
                    _marker setMarkerSizeLocal [1.0, 1.0];
                    
                    // Remove marker after 30 seconds
                    [_markerName] spawn {
                        params ["_marker"];
                        sleep 30;
                        deleteMarkerLocal _marker;
                    };
                } else {
                    _response = "I haven't seen any armed men around here recently.";
                };
            } else {
                private _responses = [];
                
                // Add death-aware responses if there are dead civilians nearby
                if (_deadCiviliansNearby > 0) then {
                    _responses = [
                        "I... I can't talk about this. Not after what I've seen.",
                        "Please, just leave me alone. People are dying here.",
                        "I don't want any trouble. Look what happened to my neighbors...",
                        "I'm too scared to help. Too many have died already.",
                        "You see what happens to people around here? I can't risk it."
                    ];
                } else {
                    _responses = [
                        "I don't know anything about that.",
                        "I prefer not to talk about such things.", 
                        "Sorry, I haven't seen anything.",
                        "I don't pay attention to those matters.",
                        "I'm just trying to mind my own business."
                    ];
                };
                _response = selectRandom _responses;
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
                if ((count _mines) > 0) then {
                    // Prioritize closest mine cluster instead of random selection
                    private _closestCluster = _mines select 0;
                    private _closestDistance = (_closestCluster select 2); // Distance is index 2
                    
                    {
                        private _currentDistance = _x select 2;
                        if (_currentDistance < _closestDistance) then {
                            _closestCluster = _x;
                            _closestDistance = _currentDistance;
                        };
                    } forEach _mines;
                    
                    private _mineCluster = _closestCluster;
                    _mineCluster params ["_position", "_mineCount", "_distance", "_mineArray"];
                    
                    // Create map marker for mine location (LOCAL to this player only)
                    // Use getPlayerUID for unique marker names across clients
                    private _markerName = format ["CI_MineIntel_%1_%2", getPlayerUID player, diag_tickTime];
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
                        if (_mineCount <= 4) then {
                            _marker setMarkerTextLocal "Small Minefield";
                            _response = format ["Be very careful! I think there's a small minefield %1. There seem to be several explosives placed together. I've marked the dangerous area on your map.", _distanceText];
                        } else {
                            _marker setMarkerTextLocal "Large Minefield";
                            _response = format ["Be extremely careful! I think there's a large minefield %1. There are many explosives in that area - it looks very dangerous. I've marked it on your map.", _distanceText];
                        };
                    };
                    
                    // Remove marker after 30 seconds
                    [_markerName] spawn {
                        params ["_marker"];
                        sleep 30;
                        deleteMarkerLocal _marker;
                    };
                } else {
                    _response = "I don't know of any dangerous areas around here.";
                };
            } else {
                private _responses = [];
                
                // Add death-aware responses if there are dead civilians nearby
                if (_deadCiviliansNearby > 0) then {
                    _responses = [
                        "I don't know about such things. Not after... not after what happened.",
                        "Please, I just want to survive. I've seen too much death.",
                        "I'm sorry, I can't help. It's too dangerous here.",
                        "Look around you. Do you think I want to end up like them?",
                        "I won't talk about dangerous things. Not when people are dying."
                    ];
                } else {
                    _responses = [
                        "I don't know about such things.",
                        "I try not to wander far from here.",
                        "Sorry, I can't help with that.",
                        "I don't know the area that well.",
                        "I haven't noticed anything dangerous."
                    ];
                };
                _response = selectRandom _responses;
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

// Display response to the player
hint format ["%1: %2", _civilianName, _response];

// Cleanup conversation and close dialog
[] call CI_fnc_cleanupConversation;
closeDialog 0;
