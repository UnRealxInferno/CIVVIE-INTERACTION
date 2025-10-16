/*
    Remove Interaction from Non-Civilian Unit
    Author: YourName

    Removes civilian interaction actions from units that are no longer civilians.
    This handles cases where unconscious units were marked as civilians but have
    since returned to their original side.

    Parameters:
    0: OBJECT - Unit to check and potentially clean up
*/
params ["_unit"];

// Exit if unit is null, dead, or still a civilian
if (isNull _unit || {!alive _unit} || {side _unit == civilian}) exitWith {};

// Check if this unit has civilian interactions that need to be removed
if (_unit getVariable ["CI_InteractionAdded", false]) then {
    // Get stored action IDs
    private _actionIDs = _unit getVariable ["CI_ActionIDs", []];
    
    // Remove the stored civilian interaction actions
    {
        if (!isNil "_x" && {_x >= 0}) then {
            _unit removeAction _x;
        };
    } forEach _actionIDs;
    
    // Clear the civilian interaction variables
    if (!isNil "_actionIDs" && {count _actionIDs > 0}) then {
        _unit setVariable ["CI_InteractionAdded", false];
    };
    _unit setVariable ["CI_HasSharedEnemyIntel", nil];
    _unit setVariable ["CI_HasSharedMineIntel", nil];
    _unit setVariable ["CI_ActionIDs", nil];
};