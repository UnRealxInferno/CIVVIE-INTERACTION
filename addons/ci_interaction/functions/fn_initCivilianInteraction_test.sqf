/*
    Minimal test function to verify CfgFunctions is working
*/

if (!hasInterface) exitWith {};

systemChat "CI_fnc_initCivilianInteraction executed successfully!";

// Set a global flag so we can test it exists
CI_SystemInitialized = true;
CI_PlayerReputation = 50;
