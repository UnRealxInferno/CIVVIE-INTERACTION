/*
    Add Interaction to Civilian Unit (Addon)
    Author: YourName

    Adds an interaction action to a civilian allowing player dialogue.

    Parameters:
    0: OBJECT - Civilian unit
*/
params ["_unit"];
if (isNull _unit || {!alive _unit} || {side _unit != civilian}) exitWith {};

// Hard gate: if unit was ever non-civilian, never allow interaction
if (_unit getVariable ["CI_EverNonCivilian", false]) exitWith {};

// Prevent duplicate actions
if (_unit getVariable ["CI_InteractionAdded", false]) exitWith {};

private _actionID = _unit addAction [
    "<t color='#00FF00'>Talk to Civilian</t>",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        [_target, _caller] call CI_fnc_showInteractionMenu;
    },
    [],
    1.5,
    true,
    true,
    "",
    "alive _target && (side _target == civilian) && !(_target getVariable ['CI_EverNonCivilian', false]) && (_this distance _target) < 3"
];

// Store the action ID for later removal if needed
_unit setVariable ["CI_ActionIDs", [_actionID]];
_unit setVariable ["CI_InteractionAdded", true];
_unit setVariable ["CI_HasSharedEnemyIntel", false]; // Track enemy intel separately
_unit setVariable ["CI_HasSharedMineIntel", false]; // Track mine intel separately