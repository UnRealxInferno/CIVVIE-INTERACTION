/*
    Civilian Interaction System - Initialization (Addon Version)
    Author: YourName

    Initializes the civilian interaction system after all mission objects are created.
    This runs postInit (scheduled environment allowed) defined in CfgFunctions.

    Notes:
    - Relies on global CI_PlayerReputation (mission makers can override in init.sqf before postInit executes by defining it earlier)
    - Monitors dynamically spawned civilians and attaches the interaction action.
*/

// Guard: run only on clients with interface (skip dedicated server headless logic if needed)
if (!hasInterface) exitWith {};

// Initialize core data structures only once
if (isNil "CI_IntelligenceData") then { CI_IntelligenceData = createHashMap; };

// Default global reputation if not set by mission maker (range clamp 1-100)
if (isNil "CI_PlayerReputation") then { CI_PlayerReputation = 50; }; // 50 is a half chance of getting intel, can be adjusted
CI_PlayerReputation = (CI_PlayerReputation max 1) min 100;

// Configurable constants (can be overridden preInit by mission maker)
if (isNil "CI_INTEL_RANGE") then { CI_INTEL_RANGE = 1000; };

// Background process to attach interaction to new civilians
[] spawn {
    while {true} do {
        {
            if (side _x == civilian && !(_x getVariable ["CI_InteractionAdded", false])) then {
                [_x] call CI_fnc_addInteractionToUnit;
            };
        } forEach allUnits;
        sleep 5;
    };
};

// Initialize existing civilians at startup
{
    if (side _x == civilian) then {
        [_x] call CI_fnc_addInteractionToUnit;
    };
} forEach allUnits;

systemChat "Civilian Interaction System (Addon) initialized";
// ...existing code...
