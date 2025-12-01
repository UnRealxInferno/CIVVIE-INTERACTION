/*
    Civilian Interaction System - Initialization (Addon Version)
    Author: YourName

    Initializes the civilian interaction system after all mission objects are created.
    This runs postInit (scheduled environment allowed) defined in CfgFunctions.

    Notes:
    - Civilians have a random 25-75% chance of being helpful when asked for intel
    - Monitors dynamically spawned civilians and attaches the interaction action.
*/

// Guard: run only on clients with interface (skip dedicated server headless logic if needed)
if (!hasInterface) exitWith {};

// Initialize core data structures only once
if (isNil "CI_IntelligenceData") then { CI_IntelligenceData = createHashMap; };

// Configurable constants (can be overridden preInit by mission maker)
if (isNil "CI_INTEL_RANGE") then { CI_INTEL_RANGE = 1000; };
if (isNil "CI_DEATH_DETECTION_RANGE") then { CI_DEATH_DETECTION_RANGE = 200; };
if (isNil "CI_DEATH_PENALTY_PER_CIVILIAN") then { CI_DEATH_PENALTY_PER_CIVILIAN = 0.15; };
if (isNil "CI_DEATH_PENALTY_MAX") then { CI_DEATH_PENALTY_MAX = 0.6; };
if (isNil "CI_MIN_SUCCESS_CHANCE") then { CI_MIN_SUCCESS_CHANCE = 0.05; };

// Background process to:
// 1) Permanently mark any unit that is (or becomes) non-civilian as ineligible (CI_EverNonCivilian)
// 2) Attach interaction to eligible civilians only
// 3) Remove interaction from ineligible or non-civilian units
[] spawn {
    // Wait for mission init to complete before starting monitoring
    sleep 3;
    
    while {true} do {
        {
            private _unit = _x;

            // Permanently flag units that are any side except civilian
            if (side _unit != civilian) then {
                if (!(_unit getVariable ["CI_EverNonCivilian", false])) then {
                    _unit setVariable ["CI_EverNonCivilian", true, true]; // publicVar true to propagate in MP
                };
            };

            // If unit is civilian and never flagged, ensure it has interaction
            // Also check that unit is not unconscious or incapacitated
            if (side _unit == civilian && !(_unit getVariable ["CI_EverNonCivilian", false])) then {
                private _lifeState = lifeState _unit;
                if ((_lifeState == "HEALTHY" || _lifeState == "INJURED") && !(_unit getVariable ["CI_InteractionAdded", false])) then {
                    [_unit] call CI_fnc_addInteractionToUnit;
                };
            } else {
                // Otherwise, ensure interaction is removed
                [_unit] call CI_fnc_removeInteractionFromUnit;
            };
        } forEach allUnits;
        sleep 5;
    };
};

// Initialize existing units at startup with eligibility gating
// Wait briefly to ensure all mission objects are created
[] spawn {
    sleep 3;
    
    {
        private _unit = _x;
        if (side _unit != civilian) then {
            _unit setVariable ["CI_EverNonCivilian", true, true];
            [_unit] call CI_fnc_removeInteractionFromUnit;
        } else {
            if !(_unit getVariable ["CI_EverNonCivilian", false]) then {
                private _lifeState = lifeState _unit;
                if (_lifeState == "HEALTHY" || _lifeState == "INJURED") then {
                    [_unit] call CI_fnc_addInteractionToUnit;
                };
            };
        };
    } forEach allUnits;
};
// ...existing code...
