/*
    Show Interaction Menu (Addon)
    Parameters:
    0: OBJECT - Civilian
    1: OBJECT - Player
*/
params ["_civilian", "_player"];

// Check if civilian has already shared intel (no cooldown, just track if they've talked)
private _hasSharedIntel = _civilian getVariable ["CI_HasSharedIntel", false];

CI_CurrentCivilian = _civilian;
CI_CurrentPlayer = _player;

// Update civilian's intelligence before interaction
[_civilian] call CI_fnc_gatherIntelligence;

// Open the dialog
createDialog "CivilianInteractionDialog";
