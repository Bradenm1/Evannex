// Number of AI to spawn each side
br_min_ai_groups = "NumberEnemyGroups" call BIS_fnc_getParamValue; // Number of groups
br_min_special_groups = "NumberEnemySpecialGroups" call BIS_fnc_getParamValue;
br_min_friendly_ai_groups = "NumberFriendlyGroups" call BIS_fnc_getParamValue;
br_min_radius_distance = 180; // Limit to spawm from center
br_max_radius_distance = 360; // Outter limit
br_zone_radius = "ZoneRadius" call BIS_fnc_getParamValue;
br_total_groups_spawed = 0; // Total groups spawned
br_AIGroups = []; // All spawned groups
br_special_ai_groups = [];
br_FriendlyGroundGroups = [];
br_FriendlyAIGroups = []; // Firendly AI
br_helis_in_transit = [];
br_FriendlyAICommandChannelBase = [];
br_EnemyAICommandChannelBase = [];
br_heliGroups = [];
br_groupsInTransit = [];
br_friendlyGroupsWaiting = []; // Waiting at base for pickup
br_friendlyGroupsWatingForEvac = []; // Waiting at zone after capture
br_friendlyvehicles = [];
br_friendlyRadioBombers = [];
br_HQ_taken = 0;
br_radio_tower_destoryed = 0;
br_zone_taken = 0;
br_heli_queue_size = 0;
br_min_helis = 1;
br_radio_tower = nil;
br_max_checks = "NChecks" call BIS_fnc_getParamValue;
br_enable_friendly_ai = 1;
br_radio_tower_enabled = TRUE;
br_hq_enabled = TRUE;
br_first_Zone = TRUE;
br_min_enemy_groups_for_capture = 2;
// Use for AI who blow up Radio Tower
br_blow_up_radio_tower = FALSE;

// Zone Locations
//_zones = [position player, getMarkerPos "zone_01"];
br_zones = [];

// Current zone
br_current_zone = nil;

// Gets a random location on the plaer
getLocation = {
	[] call compile preprocessFileLineNumbers "functions\getRandomLocation.sqf";
};

// Creates the zone
createZone = {
	br_current_zone = selectRandom br_zones;
	// Creates the radius
	["ZONE_RADIUS", br_current_zone, br_zone_radius, br_max_radius_distance, "ColorRed", "Enemy Zone", 0.4] call (compile preProcessFile "functions\createRadiusMarker.sqf");
	// Create text icon
	["ZONE_ICON", br_current_zone, "Enemy Zone", "ColorBlue"] call (compile preProcessFile "functions\createTextMarker.sqf");
};

// Creates the RescueBunker
createRescueBunker = {
	// Creates center for RescueBunker
	_hqCenterPos = [] call getLocation;
	// Gets position near center
	_hqPos = _hqCenterPos getPos [10 * sqrt random 180, random 360];	
	// Place RescueBunker near center
	"Land_Cargo_House_V1_F" createVehicle _hqPos;
	// Creates the radius
	["ZONE_RESCUEBUNKER_RADIUS", _hqCenterPos, 10, 360, "ColorRed", "Rescue Bunker(s) Zone", 0.3] call (compile preProcessFile "functions\createRadiusMarker.sqf");
	// Create text icon
	["ZONE_RESCUEBUNKER_ICON", _hqCenterPos, "Rescue Bunker(s)", "ColorBlue"] call (compile preProcessFile "functions\createTextMarker.sqf");
	//_toResuce = [ _hqPos, CIVILIAN, ["C_man_polo_1_f"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
};

// Delete all enemy AI
deleteAllAI = {
	// Delete existing units 
	{ [_x] call deleteGroups; } forEach br_AIGroups;
	{ [_x] call deleteGroups; } forEach br_special_ai_groups;
	br_AIGroups = [];
	br_special_ai_groups = [];
};

// Find all markers
// Runs once per mission
doChecks = {
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
		if (getMarkerColor _endStringVeh != "") 
		then { [_endStringVeh] execVM "createVehicle.sqf"; };
		if (getMarkerColor _endStringHeli != "") 
		then { [_endStringHeli, _i, FALSE] execVM "createHelis.sqf"; };
		if (getMarkerColor _endStringHeliEvac != "") 
		then { [_endStringHeliEvac, _i, TRUE] execVM "createHelis.sqf"; };
		if (getMarkerColor _endStringBombSquad != "")
		then { [_endStringBombSquad, _i] execVM "createRadioBombUnits.sqf"; };
	};
};

// Called when zone is taken
onZoneTaken = {
	task setTaskState "Succeeded";
	["TaskSucceeded",["", "Zone Taken!"]] call bis_fnc_showNotification;
	{ _x removeSimpleTask task; } forEach allPlayers;
	br_zone_taken = 1;
	// Delete all markers
	deleteMarker "ZONE_RADIUS";
	deleteMarker "ZONE_ICON";
	deleteMarker "ZONE_HQ_RADIUS";
	deleteMarker "ZONE_HQ_ICON";
	deleteMarker "ZONE_RADIOTOWER_ICON";
	deleteMarker "ZONE_RADIOTOWER_RADIUS";
	[] call deleteAllAI;
};

// On first zone creation after AI and everything has been placed do the following...
onFirstZoneCreation = {
	execVM "friendlySpawnAI.sqf";
	execVM "commandFriendlyGroups.sqf";
	execVM "garbageCollector.sqf";
	br_first_Zone = FALSE;
};

// On new zone creation after AI and everything has been placed do the following...
onNewZoneCreation = {
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
main = {
	while {TRUE} do {
		// Check for markers and do things
		[] call doChecks;
		// Everything relies on the zone so we create it first, and not using execVM since it has a queue.
		[] call createZone;
		execVM "playerTasking.sqf";
		if (br_hq_enabled) then {execVM "createHQ.sqf";};
		if (br_radio_tower_enabled) then {execVM "createRadioTower.sqf"};
		execVM "zoneSpawnAI.sqf";
		execVM "commandEnemyGroups.sqf";
		// Check if it's the first zone
		if (br_first_Zone) then { [] call onFirstZoneCreation } else { [] call onNewZoneCreation; };
		// Wait for a time for the zone to populate
		sleep 30;
		// Wait untill zone is taken
		waitUntil { (count br_AIGroups < br_min_enemy_groups_for_capture) and (br_radio_tower_destoryed == 1) and (br_HQ_taken == 1); };
		[] call onZoneTaken;
		sleep 5;
	}
};

[] call main;