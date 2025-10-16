/*
    Show Interaction Menu (Addon)
    Parameters:
    0: OBJECT - Civilian
    1: OBJECT - Player
*/
params ["_civilian", "_player"];

// Check if civilian is already in conversation (multiplayer lock)
private _isInConversation = _civilian getVariable ["CI_InConversation", false];
if (_isInConversation) exitWith {};

// Lock the civilian for conversation (globally synced)
_civilian setVariable ["CI_InConversation", true, true];
_civilian setVariable ["CI_TalkingTo", name _player, true];

CI_CurrentCivilian = _civilian;
CI_CurrentPlayer = _player;

// Stop civilian movement during conversation (execute on server for dedicated server support)
[_civilian, true] remoteExecCall ["CI_fnc_updateConversationLock", 2];

// Update civilian's intelligence before interaction
[_civilian] call CI_fnc_gatherIntelligence;

// Open the dialog
createDialog "CivilianInteractionDialog";
