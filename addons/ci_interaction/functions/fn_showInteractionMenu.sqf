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

// MULTIPLAYER SECURITY: Lock the civilian for conversation on server
// This prevents race conditions where multiple players try to talk to same civilian
[_civilian, _player] remoteExecCall ["CI_fnc_lockCivilianForConversation", 2];

CI_CurrentCivilian = _civilian;
CI_CurrentPlayer = _player;

// MULTIPLAYER SECURITY: Request intelligence gathering from server
// Pass the player reference so server knows which side to check hostility against
[_civilian, _player] remoteExecCall ["CI_fnc_gatherIntelligence", 2];

// Open the dialog
createDialog "CivilianInteractionDialog";
