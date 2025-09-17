# Test Instructions

## CRITICAL: Manual File Access Test

**Copy this code into debug console (LOCAL EXEC) and run it:**

```sqf
_result = "";
_paths = [
    "functions\fn_initCivilianInteraction.sqf",
    "\ci_interaction\functions\fn_initCivilianInteraction.sqf", 
    "ci_interaction\functions\fn_initCivilianInteraction.sqf",
    "\functions\fn_initCivilianInteraction.sqf"
];
{
    _exists = fileExists _x;
    _result = _result + format["%1: %2\n", _x, _exists];
} forEach _paths;
try {
    _code = compile preprocessFileLineNumbers "functions\fn_initCivilianInteraction.sqf";
    _result = _result + format["Compile success: %1\n", !isNil "_code"];
    if (!isNil "_code") then {
        [] call _code;
        _result = _result + "Execution attempted\n";
    };
} catch {
    _result = _result + format["Compile error: %1\n", _exception];
};
hint _result;
copyToClipboard _result;
```

This will test all possible file paths and show which ones work.

## Then test CfgFunctions:

```sqf
// Test 1: Is the addon loaded?
hint str isClass (configFile >> "CfgPatches" >> "ci_interaction");

// Test 2: Are functions registered?  
hint str isNil "CI_fnc_initCivilianInteraction";
```

## Expected Results
- **File access test**: At least one path should show "true"
- **Test 1**: Should show "true" (addon loaded)
- **Test 2**: Should show "false" (function exists)

## Report Back:
1. Copy/paste the full result from the file access test
2. Results of Test 1 and Test 2
3. Any error messages from RPT file

This will tell us if it's a file access issue or CfgFunctions issue.
