private _aiSpawnRate = 3; // Delay in seconds
private _allSpawnedDelay = 10; // Seconds to wait untill checking if any groups died

private _spawnFriendlyGroundUnitsLocation = getMarkerPos "marker_ai_spawn_friendly_ground_units"; // Where to spawn friendly units

//_unitTypes = ["Infantry","Armored", "Motorized_MTP", "Mechanized", "SpecOps"];
private _unitTypes = ["Infantry"];

// Gets a random location on the plaer
br_fnc_getGroundUnitLocation = {
	// Gets a random location within the zone radius
	getMarkerPos "marker_ai_spawn_friendly_ground_units" getPos [2 * sqrt random 180, random 360];
};

br_fnc_spawnFriendlyAI = {
	while {True} do {
		// Spawn AI untill reached limit
		while {((count br_friendly_ground_groups)  < br_min_friendly_ai_groups)} do {
			private _group = [br_sides, 1, _unitTypes, br_side_types, (call compile preprocessFileLineNumbers "core\spawnlists\units.sqf"), [] call br_fnc_getGroundUnitLocation, br_friendly_groups_waiting] call compile preprocessFileLineNumbers "core\server\functions\fn_selectRandomGroupToSpawn.sqf";
			br_friendly_ground_groups append [_group];
			//{ _x setSkill br_ai_skill; _x; _x setVectorDir [random 360, random 360, random 360];  } forEach units _group;
			sleep _aiSpawnRate;		
		};
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

[] call br_fnc_spawnFriendlyAI;