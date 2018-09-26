// Number of AI to spawn each side
br_min_ai_groups = "NumberEnemyGroups" call BIS_fnc_getParamValue; // Number of groups
br_min_friendly_ai_groups = "NumberFriendlyGroups" call BIS_fnc_getParamValue;
br_min_radius_distance = 180; // Limit to spawm from center
br_max_radius_distance = 360; // Outter limit
br_zone_radius = "ZoneRadius" call BIS_fnc_getParamValue;
br_total_groups_spawed = 0; // Total groups spawned
br_AIGroups = []; // All spawned groups
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
br_max_checks = "NChecks" call BIS_fnc_getParamValue;;
br_radio_tower_enabled = TRUE;
br_first_Zone = TRUE;

// Type of transport helicopters that can spawn
br_heli_units = [
	"B_Heli_Transport_03_F",
	"B_Heli_Transport_03_unarmed_F",
	"B_Heli_Transport_03_black_F",
	"B_Heli_Transport_03_unarmed_green_F",
	"B_CTRG_Heli_Transport_01_sand_F",
	"B_CTRG_Heli_Transport_01_tropic_F",
	"B_Heli_Light_01_F",
	"B_Heli_Transport_01_F",
	"B_Heli_Transport_01_camo_F",
	"I_Heli_Transport_02_F",
	"I_Heli_light_03_unarmed_F",
	"O_Heli_Light_02_v2_F",
	"O_Heli_Transport_04_bench_F",
	"O_Heli_Transport_04_covered_F"
];

// Zone Locations
//_zones = [position player, getMarkerPos "zone_01"];
br_zones = [];

// Current zone
br_current_zone = objnull;

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

// Get all spawn locations
getZoneSpawnLocations = {
	for "_i" from 0 to br_max_checks do {
		// Get marker prefix
		_endString = Format ["marker_%1", _i];
		// check if marker exists
		if (getMarkerColor _endString == "") 
		then {} else {  
			br_zones append [getMarkerPos _endString];
		};
	};
};

// Get all heli and vehicle spawn locations
createFriendlyTransportAndVehicles = {
	for "_i" from 0 to br_max_checks do {
		// Get marker prefixs
		_endStringVeh = Format ["vehicle_spawn_%1", _i];
		_endStringHeli = Format ["helicopter_transport_%1", _i];
		_endStringHeliEvac = Format ["helicopter_evac_%1", _i];
		_endStringBombSquad = Format ["bomb_squad_%1", _i];
		// Check if markers exist
		if (getMarkerColor _endStringVeh == "") 
		then {} else {  
			// If so create vehicle
			[_endStringVeh] execVM "createVehicle.sqf";
		};
		if (getMarkerColor _endStringHeli == "") 
		then {} else {
			// If so create vehicle     
			[_endStringHeli, _i, FALSE, selectRandom br_heli_units] execVM "createHelis.sqf";
		};
		if (getMarkerColor _endStringHeliEvac == "") 
		then {} else {
			// If so create vehicle     
			[_endStringHeliEvac, _i, TRUE, selectRandom br_heli_units] execVM "createHelis.sqf";
		};
		if (getMarkerColor _endStringBombSquad == "")
		then {} else  {
			// If so create vehicle  
			[_endStringBombSquad, _i] execVM "createRadioBombUnits.sqf";
		};
	};
};

// Called when zone is taken
onZoneTaken = {
	task setTaskState "Succeeded";
	["TaskSucceeded",["", "Zone Taken!"]] call bis_fnc_showNotification;
	{ _x removeSimpleTask task; } forEach allPlayers;
	br_zone_taken = 1;
	deleteMarker "ZONE_RADIUS";
	deleteMarker "ZONE_ICON";
	deleteMarker "ZONE_HQ_RADIUS";
	deleteMarker "ZONE_HQ_ICON";
	deleteMarker "ZONE_RADIOTOWER_ICON";
	deleteMarker "ZONE_RADIOTOWER_RADIUS";
	{ _y = _x; br_AIGroups deleteAt (br_AIGroups find _y); { deleteVehicle _x } forEach units _y; deleteGroup _y;  _y = grpNull; _y = nil; } foreach br_AIGroups;
};

// On first zone creation after AI and everything has been placed do the following...
onFirstZoneCreation = {
	[] call createFriendlyTransportAndVehicles;
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
		// Get spawn locations
		[] call getZoneSpawnLocations;
		// Create a zone
		// Everything relies on the zone so we create it first, and not using execVM since it has a queue.
		[] call createZone;
		execVM "playerTasking.sqf";
		execVM "createHQ.sqf";
		if (br_radio_tower_enabled) then {execVM "createRadioTower.sqf"};
		execVM "zoneSpawnAI.sqf";
		execVM "commandEnemyGroups.sqf";
		// Check if it's the first zone
		if (br_first_Zone) then { [] call onFirstZoneCreation } else { [] call onNewZoneCreation; };
		// Wait for a time for the zone to populate
		sleep 30;
		// Wait untill zone is taken
		waitUntil { (count br_AIGroups < 2) and (br_radio_tower_destoryed == 1) and (br_HQ_taken == 1); };
		[] call onZoneTaken;
		sleep 5;
	}
};

[] call main;