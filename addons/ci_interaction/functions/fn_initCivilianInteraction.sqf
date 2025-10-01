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
    
    systemChat "Civilian Interaction System (Addon) initialized";
};
// ...existing code...
