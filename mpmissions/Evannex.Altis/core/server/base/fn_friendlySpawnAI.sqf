private _aiSpawnRate = 1; // Delay in seconds
private _allSpawnedDelay = 10; // Seconds to wait untill checking if any groups died

//_unitTypes = ["Infantry","Armored", "Motorized_MTP", "Mechanized", "SpecOps"];
private _unitTypes = ["Infantry"];

br_fnc_spawnFriendlyAI = {
	while {True} do {
		// Spawn AI untill reached limit
		while {((count br_friendly_ground_groups)  < br_min_friendly_ai_groups)} do {
			private _group = [br_sides, 1, _unitTypes, br_side_types, (call compile preprocessFileLineNumbers "core\spawnlists\units.sqf"), call compile preprocessFileLineNumbers "core\server\functions\fn_getGroundUnitsLocation.sqf", br_friendly_groups_waiting] call compile preprocessFileLineNumbers "core\server\functions\fn_selectRandomGroupToSpawn.sqf";
			br_friendly_ground_groups append [_group];
			sleep _aiSpawnRate;		
		};
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

[] call br_fnc_spawnFriendlyAI;