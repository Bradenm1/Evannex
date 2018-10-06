_delayForAssignment = 5;
_checkForNewPlayer = 10;

// Creates a task for the player
br_fnc_createPlayerTask = {
	[[[],"core\server\task\fn_giveTaskZone.sqf"],"BIS_fnc_execVM",true,true] call BIS_fnc_MP;
};

// Allows zone to be created before an assignment can happen if host.
sleep _delayForAssignment;

[] call br_fnc_createPlayerTask;