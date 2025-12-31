/*
    Process Interaction Response (Addon)
    
    MULTIPLAYER SECURITY: This function now forwards requests to the server
    for success calculation. The server calculates the random success chance
    and returns results to the client via CI_fnc_handleIntelResult.
    
    Parameters:
    0: STRING - Question type ("enemies","mines","general")
*/
params ["_questionType"];

private _civilian = CI_CurrentCivilian;
private _player = CI_CurrentPlayer;
if (isNil "_civilian" || {isNil "_player"}) exitWith { hint "Error: Invalid interaction data"; };

// MULTIPLAYER SECURITY: Forward intel request to server for calculation
// Server will calculate success chance and return results via CI_fnc_handleIntelResult
[_civilian, _player, _questionType] remoteExecCall ["CI_fnc_calculateIntelSuccess", 2];
