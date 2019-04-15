private _unitChance = _this select 0;
private _aiSpawnRate = 1; // Delay in seconds
private _allSpawnedDelay = 10; // Seconds to wait untill checking if any groups died
private _types = (call compile preprocessFileLineNumbers (format ["core\spawnlists\%1\unit_composition_types.sqf", br_friendly_faction]));

br_fnc_spawnFriendlyAI = {
	while {True} do {
		// Spawn AI untill reached limit
		while {((count br_friendly_ground_groups)  < br_min_friendly_ai_groups)} do {
			private _group = [WEST, _types select 0, _types select 2, _types select 1, _unitChance, call compile preprocessFileLineNumbers "core\server\functions\fn_getGroundUnitsLocation.sqf", br_friendly_groups_waiting] call compile preprocessFileLineNumbers "core\server\functions\fn_selectRandomGroupToSpawn.sqf";
			br_friendly_ground_groups pushBack _group;
			sleep _aiSpawnRate;		
		};
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

[] call br_fnc_spawnFriendlyAI;