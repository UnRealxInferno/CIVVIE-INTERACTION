/*
    IED Detection Debug Script
    Run this to test IED detection specifically
*/

systemChat "=== IED DETECTION DEBUG ===";

// Create a test civilian
private _testPos = getPos player vectorAdd [10, 0, 0];
private _civilian = "C_man_1" createUnit [_testPos, createGroup civilian, "this setVariable ['CI_InteractionAdded', false];"];

// Initialize the civilian interaction system
[_civilian] call CI_fnc_addInteractionToUnit;

// Let civilian gather intelligence 
[_civilian] call CI_fnc_gatherIntelligence;

// Check what the civilian knows
private _knownMines = _civilian getVariable ["CI_KnownMines", []];
systemChat format ["Civilian knows about %1 explosives", count _knownMines];

// Let's manually search for all IED-related objects
private _allObjects = _civilian nearObjects ["All", 2000];
private _foundIEDs = [];

{
    private _classname = typeOf _x;
    private _classnameUpper = toUpper _classname;
    
    // Check if it looks like an IED
    if (
        ("IED" in _classnameUpper) or
        ("MINE" in _classnameUpper) or
        ("EXPLOSIVE" in _classnameUpper) or
        ("BOMB" in _classnameUpper) or
        ("CHARGE" in _classnameUpper)
    ) then {
        _foundIEDs pushBack [_classname, _x, alive _x, _civilian distance _x];
        systemChat format ["Found potential explosive: %1 (alive: %2, distance: %3m)", _classname, alive _x, round (_civilian distance _x)];
    };
} forEach _allObjects;

systemChat format ["Total potential explosives found: %1", count _foundIEDs];

// Test the exact IED classnames we're looking for
private _testClassnames = [
    "IEDLandBig_F",
    "IEDLandSmall_F", 
    "IEDUrbanBig_F",
    "IEDUrbanSmall_F",
    "IEDLandBig_Remote_Mag",
    "IEDLandSmall_Remote_Mag",
    "IEDUrbanBig_Remote_Mag", 
    "IEDUrbanSmall_Remote_Mag"
];

systemChat "=== TESTING EXACT CLASSNAMES ===";
{
    private _testClass = _x;
    private _found = false;
    {
        if (typeOf _x == _testClass) then {
            _found = true;
            systemChat format ["✓ Found %1 at distance %2m", _testClass, round (_civilian distance _x)];
        };
    } forEach _allObjects;
    
    if (!_found) then {
        systemChat format ["✗ No %1 found", _testClass];
    };
} forEach _testClassnames;

systemChat "=== DEBUG COMPLETE ===";
systemChat "Check the output above to see what IED types are being found";
