/*
    Lock Civilian for Conversation (Server-side)
    Author: Inferno
    
    MULTIPLAYER SECURITY: This function MUST run on server to prevent client-side abuse.
    Handles locking a civilian for conversation to prevent multiple players
    from talking to the same civilian simultaneously.
    
    Parameters:
    0: OBJECT - Civilian
    1: OBJECT - Player initiating conversation
*/
params ["_civilian", "_player"];

// SECURITY: Must run on server only
if (!isServer) exitWith {};

// Validate inputs
if (isNull _civilian || isNull _player) exitWith {};

// Check if civilian is already in conversation (server-authoritative check)
private _isInConversation = _civilian getVariable ["CI_InConversation", false];
if (_isInConversation) exitWith {};

// Lock the civilian for conversation (globally synced from server)
_civilian setVariable ["CI_InConversation", true, true];
_civilian setVariable ["CI_TalkingTo", name _player, true];

// Stop civilian movement during conversation
[_civilian, true] call CI_fnc_updateConversationLock;
