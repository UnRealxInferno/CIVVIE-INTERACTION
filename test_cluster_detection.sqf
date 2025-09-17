/*
    Test script for cluster enemy detection, mine clustering, and improved distance reporting
    Run this in debug console to test the new features
*/

// Test 1: Create a group of enemies close together (should be detected as cluster)
private _testGroup1 = [];
for "_i" from 0 to 2 do {
    private _soldier = createUnit ["O_Soldier_F", (getPos player) vectorAdd [200 + (_i * 10), 200, 0], [], 0, "NONE"];
    _testGroup1 pushBack _soldier;
};

// Test 2: Create a single enemy very close (should report "really close by")
private _closeSoldier = createUnit ["O_Soldier_F", (getPos player) vectorAdd [50, 50, 0], [], 0, "NONE"];

// Test 3: Create enemies far apart (should be reported separately)
private _farSoldier1 = createUnit ["O_Soldier_F", (getPos player) vectorAdd [300, 100, 0], [], 0, "NONE"];
private _farSoldier2 = createUnit ["O_Soldier_F", (getPos player) vectorAdd [100, 300, 0], [], 0, "NONE"];

// Test 4: Create a minefield (clustered mines within 50m)
private _mineField = [];
for "_i" from 0 to 3 do {
    private _mine = createMine ["APERSMine", (getPos player) vectorAdd [150 + (_i * 15), -100, 0], [], 0];
    _mineField pushBack _mine;
};

// Test 5: Create a single mine close by (should report "really close by")
private _closeMine = createMine ["ATMine", (getPos player) vectorAdd [60, -50, 0], [], 0];

// Test 6: Create scattered individual mines (should be reported separately)
private _scatteredMine1 = createMine ["APERSMine", (getPos player) vectorAdd [250, -200, 0], [], 0];
private _scatteredMine2 = createMine ["ATMine", (getPos player) vectorAdd [-150, 250, 0], [], 0];

// Create a test civilian
private _testCiv = createUnit ["C_man_1", (getPos player) vectorAdd [10, 10, 0], [], 0, "NONE"];

// Set up civilian interaction
[_testCiv] call CI_fnc_addInteractionToUnit;

// Also set a high reputation for easy testing
CI_PlayerReputation = 90;

systemChat "Test enemies and mines created:";
systemChat format ["ENEMIES:"];
systemChat format ["- Group of 3 at ~200m (should cluster)"];
systemChat format ["- Single enemy at ~70m (should say 'really close by')"];
systemChat format ["- Two separate enemies at ~300m each"];
systemChat format ["MINES:"];
systemChat format ["- Minefield of 4 mines at ~150m (should cluster within 50m)"];
systemChat format ["- Single mine at ~80m (should say 'really close by')"];
systemChat format ["- Two scattered mines at ~300m each"];
systemChat format ["- Test civilian created near you"];
systemChat format ["- Reputation set to 90 for easy testing"];
systemChat "Try interacting with the civilian to test both enemy and mine clustering!";

// Enhanced cleanup function for later use
TEST_CleanupClusterTest = {
    {deleteVehicle _x} forEach _testGroup1;
    deleteVehicle _closeSoldier;
    deleteVehicle _farSoldier1;
    deleteVehicle _farSoldier2;
    {deleteVehicle _x} forEach _mineField;
    deleteVehicle _closeMine;
    deleteVehicle _scatteredMine1;
    deleteVehicle _scatteredMine2;
    deleteVehicle _testCiv;
    systemChat "Test units and mines cleaned up.";
};

systemChat "Run 'call TEST_CleanupClusterTest;' to clean up all test units and mines when done.";
