// Number of AI to spawn each side
br_min_ai_groups = "NumberEnemyGroups" call BIS_fnc_getParamValue; // Number of groups
br_min_special_groups = "NumberEnemySpecialGroups" call BIS_fnc_getParamValue;
br_min_friendly_ai_groups = "NumberFriendlyGroups" call BIS_fnc_getParamValue;
br_min_radius_distance = 180; // Limit to spawm from center
br_max_radius_distance = 360; // Outter limit
br_zone_radius = "ZoneRadius" call BIS_fnc_getParamValue;
br_AIGroups = []; // All spawned groups
br_special_ai_groups = []; // Enemy special groups
br_FriendlyGroundGroups = []; // Friendly ground units
br_FriendlyAIGroups = []; // All Firendly AI
br_heliGroups = []; // Helicopters
br_groupsInTransit = []; // Groups in transit to the zone via helicopters
br_friendlyGroupsWaiting = []; // Waiting at base for pickup
br_friendlyGroupsWatingForEvac = []; // Waiting at zone after capture
br_friendlyvehicles = []; // Friendly armor
br_friendlyRadioBombers = []; // The bombers groups which attemped to blow up the radio tower
br_HQ_taken = FALSE; // If the HQ is taken
br_radio_tower_destoryed = FALSE; // If the radio tower is destroyed
br_zone_taken = TRUE; // If the zone is taken.. start off at true
br_radio_tower = nil; // The radio tower
br_hq = nil; // The HQ
br_max_checks = "Checks" call BIS_fnc_getParamValue;
br_enable_friendly_ai = if ("FriendlyAIEnabled" call BIS_fnc_getParamValue == 1) then { TRUE } else { FALSE };
br_radio_tower_enabled = TRUE;
br_hq_enabled = if ("HQEnabled" call BIS_fnc_getParamValue == 1) then { TRUE } else { FALSE };
br_first_Zone = TRUE; // If it's the first zone
br_min_enemy_groups_for_capture = "MinEnemyGroupsForCapture" call BIS_fnc_getParamValue;
br_max_ai_distance_before_delete = "MinAIDistanceForDeleteion" call BIS_fnc_getParamValue;
br_blow_up_radio_tower = FALSE; // Use for AI who blow up Radio Tower
br_ai_skill = 1;

// Zone Locations
//_zones = [position player, getMarkerPos "zone_01"];
br_zones = [];

// Current selected zone
br_current_zone = nil;

// Creates the zone
br_fnc_createZone = {
	br_current_zone = selectRandom br_zones;
	// Creates the radius
	["ZONE_RADIUS", br_current_zone, br_zone_radius, br_max_radius_distance, "ColorRed", "Enemy Zone", 0.4] call (compile preProcessFile "functions\fn_createRadiusMarker.sqf");
	// Create text icon
	["ZONE_ICON", br_current_zone, "Enemy Zone", "ColorBlue"] call (compile preProcessFile "functions\fn_createTextMarker.sqf");
};

// Creates the RescueBunker
/*br_fnc_createRescueBunker = {
	// Creates center for RescueBunker
	_hqCenterPos = [] call br_fnc_getLocation;
	// Gets position near center
	_hqPos = _hqCenterPos getPos [10 * sqrt random 180, random 360];	
	// Place RescueBunker near center
	"Land_Cargo_House_V1_F" createVehicle _hqPos;
	// Creates the radius
	["ZONE_RESCUEBUNKER_RADIUS", _hqCenterPos, 10, 360, "ColorRed", "Rescue Bunker(s) Zone", 0.3] call (compile preProcessFile "functions\fn_createRadiusMarker.sqf");
	// Create text icon
	["ZONE_RESCUEBUNKER_ICON", _hqCenterPos, "Rescue Bunker(s)", "ColorBlue"] call (compile preProcessFile "functions\fn_createTextMarker.sqf");
	//_toResuce = [ _hqPos, CIVILIAN, ["C_man_polo_1_f"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
};*/

// Delete groups in AIGroups
br_fnc_deleteGroups = {
	_group = _this select 0;
	{ deleteVehicle _x } forEach (units _group);
	deleteGroup _group;
};

// Delete all enemy AI
br_fnc_deleteAllAI = {
	// Delete existing units 
	{ [_x] call br_fnc_deleteGroups; } forEach br_AIGroups;
	{ [_x] call br_fnc_deleteGroups; } forEach br_special_ai_groups;
	br_AIGroups = [];
	br_special_ai_groups = [];
};

// Find all markers
// Runs once per mission
br_fnc_doChecks = {
	for "_i" from 0 to br_max_checks do {
		// Get marker prefixs
		_endString = Format ["marker_%1", _i];
		_endStringVeh = Format ["vehicle_spawn_%1", _i];
		_endStringHeli = Format ["helicopter_transport_%1", _i];
		_endStringHeliEvac = Format ["helicopter_evac_%1", _i];
		_endStringBombSquad = Format ["bomb_squad_%1", _i];
		// Check if markers exist
		if (getMarkerColor _endString != "") 
		then { br_zones append [getMarkerPos _endString]; };
		if ((getMarkerColor _endStringVeh != "") && (br_enable_friendly_ai)) 
		then { [_endStringVeh] execVM "fn_createVehicle.sqf"; };
		if ((getMarkerColor _endStringHeli != "") && (br_enable_friendly_ai))
		then { [_endStringHeli, _i, FALSE] execVM "fn_createHelis.sqf"; };
		if ((getMarkerColor _endStringHeliEvac != "") && (br_enable_friendly_ai))
		then { [_endStringHeliEvac, _i, TRUE] execVM "fn_createHelis.sqf"; };
		if ((getMarkerColor _endStringBombSquad != "") && (br_enable_friendly_ai))
		then { [_endStringBombSquad, _i] execVM "fn_createRadioBombUnits.sqf"; };
	};
};

// Called when zone is taken
br_fnc_onZoneTaken = {
	br_zone_taken = TRUE;
	task setTaskState "Succeeded";
	["TaskSucceeded",["", "Zone Taken!"]] call bis_fnc_showNotification;
	{ _x removeSimpleTask task; } forEach allPlayers;
	// Delete all markers
	deleteMarker "ZONE_RADIUS";
	deleteMarker "ZONE_ICON";
	deleteMarker "ZONE_HQ_RADIUS";
	deleteMarker "ZONE_HQ_ICON";
	deleteMarker "ZONE_RADIOTOWER_ICON";
	deleteMarker "ZONE_RADIOTOWER_RADIUS";
	// Delete all AI left at zone
	[] call br_fnc_deleteAllAI;
	sleep 5;
};

// On first zone creation after AI and everything has been placed do the following...
br_fnc_onFirstZoneCreation = {
	if (br_enable_friendly_ai) then {
		execVM "fn_friendlySpawnAI.sqf";
		execVM "fn_commandFriendlyGroups.sqf";
		execVM "fn_checkFriendyAIPositions.sqf";
	};
	execVM "fn_commandEnemyGroups.sqf";
	execVM "fn_garbageCollector.sqf";
	br_first_Zone = FALSE;
};

// On new zone creation after AI and everything has been placed do the following...
br_fnc_onNewZoneCreation = {
	// Delete all waypoints for vehicles
	{  
		while {(count (waypoints _x)) > 0} do {
			deleteWaypoint ((waypoints _x) select 0);
		};
	} forEach br_friendlyvehicles;
	// Place all the friendly ground units at the zone into a waiting evac queue
	{
		if (_x in br_FriendlyAIGroups) then {
			// Delete from zone roaming list
			br_FriendlyAIGroups deleteAt (br_FriendlyAIGroups find _x);
			// Delete waypoints
			while {(count (waypoints _x)) > 0} do {
				deleteWaypoint ((waypoints _x) select 0);
			};
			_x setBehaviour "SAFE";	
			// Add the group to the evac queue
			br_friendlyGroupsWatingForEvac append [_x];
		}
	} forEach br_FriendlyGroundGroups;
};

// Main function
br_fnc_main = {
	// Check for markers and do things
	[] call br_fnc_doChecks;
	while {TRUE} do {
		// Everything relies on the zone so we create it first, and not using execVM since it has a queue.
		[] call br_fnc_createZone;
		execVM "fn_playerTasking.sqf";
		if (br_hq_enabled) then {execVM "fn_createHQ.sqf";};
		if (br_radio_tower_enabled) then {execVM "fn_createRadioTower.sqf"};
		// Check if it's the first zone
		if (br_first_Zone) then { [] call br_fnc_onFirstZoneCreation } else { [] call br_fnc_onNewZoneCreation; };
		// Set taken as false
		br_zone_taken = FALSE;
		execVM "fn_zoneSpawnAI.sqf";
		// Wait for a time for the zone to populate
		sleep 60;
		// Wait untill zone is taken
		waitUntil { (count br_AIGroups < br_min_enemy_groups_for_capture) and (br_radio_tower_destoryed) and (br_HQ_taken); };
		[] call br_fnc_onZoneTaken;
	}
};

[] call br_fnc_main;