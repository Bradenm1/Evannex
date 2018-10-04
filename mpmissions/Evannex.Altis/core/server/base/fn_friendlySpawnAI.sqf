//_numbToSpawn = 3;  AI spawn per spawn rate
_aiSpawnRate = 0; // Delay in seconds
_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died

_spawnFriendlyGroundUnitsLocation = getMarkerPos "marker_ai_spawn_friendly_ground_units";

//_unitTypes = ["Infantry","Armored", "Motorized_MTP", "Mechanized", "SpecOps"];
_unitTypes = ["Infantry"];

// Gets a random location on the plaer
br_fnc_getGroundUnitLocation = {
	// Gets a random location within the zone radius
	getMarkerPos "marker_ai_spawn_friendly_ground_units" getPos [2 * sqrt random 180, random 360];
};

// Spawn custom units
br_fnc_createCustomUnitsFriendly = {
	
};

br_fnc_spawnFriendlyAI = {
	// Spawn custom units
	[] call br_fnc_createCustomUnitsFriendly;
	while {True} do {
		// Spawn AI untill reached limit
		while {(((count br_friendlyGroupsWaiting) + (count br_FriendlyAIGroups) + (count br_groupsInTransit) - (count br_friendlyvehicles))  < br_min_friendly_ai_groups)} do {
			//sleep _aiSpawnRate;
			_group = [br_sides, 1, _unitTypes, br_side_types, br_units, [] call br_fnc_getGroundUnitLocation, br_friendlyGroupsWaiting] call compile preprocessFileLineNumbers "core\server\functions\fn_selectRandomGroupToSpawn.sqf";
			br_FriendlyGroundGroups append [_group];
			//{ _x setSkill br_ai_skill; _x; _x setVectorDir [random 360, random 360, random 360];  } forEach units _group;
			sleep 3;		
		};
		//hint format ["Group Spawned - Total:  %1", count br_AIGroups];
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

[] call br_fnc_spawnFriendlyAI;