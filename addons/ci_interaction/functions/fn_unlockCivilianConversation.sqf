/*
    Unlock Civilian Conversation (Server-side)
    Author: Inferno
    
    MULTIPLAYER SECURITY: This function MUST run on server to prevent client-side abuse.
    Releases conversation locks and re-enables civilian movement.
    
    Parameters:
    0: OBJECT - Civilian
*/
params ["_civilian"];

// SECURITY: Must run on server only
if (!isServer) exitWith {};

// Validate input
if (isNull _civilian) exitWith {};

// Re-enable civilian movement
[_civilian, false] call CI_fnc_updateConversationLock;

// Release conversation lock variables (server-authoritative with global broadcast)
_civilian setVariable ["CI_InConversation", false, true];
_civilian setVariable ["CI_TalkingTo", nil, true];
