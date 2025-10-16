/*
    Update Conversation Lock (Addon)
    Parameters:
    0: OBJECT - Civilian
    1: BOOL - Lock state (true = in conversation, false = end conversation)
    
    This function runs on the server to ensure AI state changes are synchronized.
    It controls civilian movement during conversations in a multiplayer-safe way.
*/
params ["_civilian", "_lockState"];

// Exit if not running on server
if (!isServer) exitWith {};

if (_lockState) then {
    // Lock conversation - disable movement
    _civilian disableAI "MOVE";
    _civilian setVariable ["CI_WasMovingDisabled", true, true];
} else {
    // Unlock conversation - re-enable movement
    // Check prevents re-enabling movement if it was disabled externally (e.g., by mission scripts)
    if (_civilian getVariable ["CI_WasMovingDisabled", false]) then {
        _civilian enableAI "MOVE";
        _civilian setVariable ["CI_WasMovingDisabled", false, true];
    };
};
