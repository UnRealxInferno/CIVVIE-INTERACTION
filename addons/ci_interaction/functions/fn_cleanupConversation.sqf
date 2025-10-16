/*
    Cleanup Conversation (Addon)
    
    Releases conversation locks and re-enables civilian movement.
    Called when dialog closes via any method (Leave button, ESC, etc.)
    
    This function reads from the global CI_CurrentCivilian variable set during interaction.
*/

// Only cleanup if we have a valid civilian reference
if (isNil "CI_CurrentCivilian") exitWith {};

private _civilian = CI_CurrentCivilian;

// Re-enable civilian movement on server
[_civilian, false] remoteExecCall ["CI_fnc_updateConversationLock", 2];

// Release conversation lock variables (globally synced)
_civilian setVariable ["CI_InConversation", false, true];
_civilian setVariable ["CI_TalkingTo", nil, true];
