/*
    Cleanup Conversation (Addon)
    
    Releases conversation locks and re-enables civilian movement.
    Called when dialog closes via any method (Leave button, ESC, etc.)
    
    MULTIPLAYER SECURITY: Forwards cleanup to server to ensure
    conversation state is properly released.
    
    This function reads from the global CI_CurrentCivilian variable set during interaction.
*/

// Only cleanup if we have a valid civilian reference
if (isNil "CI_CurrentCivilian") exitWith {};

private _civilian = CI_CurrentCivilian;

// MULTIPLAYER SECURITY: Forward cleanup to server
[_civilian] remoteExecCall ["CI_fnc_unlockCivilianConversation", 2];
