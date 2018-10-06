// Number of AI to spawn each side
br_min_ai_groups = "NumberEnemyGroups" call BIS_fnc_getParamValue; // Number of groups
br_min_special_groups = "NumberEnemySpecialGroups" call BIS_fnc_getParamValue;
br_min_friendly_ai_groups = "NumberFriendlyGroups" call BIS_fnc_getParamValue;
br_sides = [EAST, WEST];
br_side_types = ["OPF_F","BLU_F"];
br_min_radius_distance = 180; // Limit to spawm from center
br_max_radius_distance = 360; // Outter limit
br_zone_radius = "ZoneRadius" call BIS_fnc_getParamValue;
br_AIGroups = []; // All spawned groups
br_special_ai_groups = []; // Enemy special groups
br_enemy_vehicle_objects = [];
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
br_objectives = []; // Objectives at the zone
br_hq = nil; // The HQ
br_max_checks = "Checks" call BIS_fnc_getParamValue; // Max checks on finding markers for the gamemode
br_enable_friendly_ai = if ("FriendlyAIEnabled" call BIS_fnc_getParamValue == 1) then { TRUE } else { FALSE };
br_radio_tower_enabled = TRUE;
br_hq_enabled = if ("HQEnabled" call BIS_fnc_getParamValue == 1) then { TRUE } else { FALSE };
br_first_Zone = TRUE; // If it's the first zone
br_min_enemy_groups_for_capture = "MinEnemyGroupsForCapture" call BIS_fnc_getParamValue; // Groups left for zone capture
br_max_ai_distance_before_delete = "MinAIDistanceForDeleteion" call BIS_fnc_getParamValue;
br_blow_up_radio_tower = FALSE; // Use for AI who blow up Radio Tower
br_command_delay = 5; // Command delay for both enemy and friendly zone AI
br_randomly_find_zone = FALSE; // Finds a random position on the map intead of using markers
br_ai_skill = 1;
br_objective_max_angle = 0.25;
br_heli_land_max_angle = 0.25;

// Below units are in-order below given the _sides and _unitTypes positions 
br_units = [[[ // EAST
	"OI_reconPatrol",
	"OI_reconSentry",
	"OI_reconTeam",
	"OI_SniperTeam",
	"OIA_InfAssault",
	"OIA_InfSentry",
	"OIA_InfSquad",
	"OIA_InfSquad_Weapons",
	"OIA_InfTeam",
	"OIA_InfTeam_AA",
	"OIA_InfTeam_AT",
	"OIA_ReconSquad"
],[
	//"OIA_SPGPlatoon_Scorcher",
	//"OIA_SPGSection_Scorcher",
	"OIA_TankPlatoon",
	"OIA_TankPlatoon_AA",
	"OIA_TankSection"
],[
	"OIA_MotInf_AA",
	"OIA_MotInf_AT",
	"OIA_MotInf_GMGTeam",
	"OIA_MotInf_MGTeam",
	"OIA_MotInf_MortTeam",
	"OIA_MotInf_Team"
], [
	"OIA_MechInf_AA",
	"OIA_MechInf_AT",
	"OIA_MechInf_Support",
	"OIA_MechInfSquad"
], [
	"OI_AttackTeam_UAV",
	"OI_AttackTeam_UGV",
	//"OI_diverTeam",
	//"OI_diverTeam_Boat",
	//"OI_diverTeam_SDV",
	"OI_ReconTeam_UAV",
	"OI_ReconTeam_UGV",
	"OI_SmallTeam_UAV"
]], 
[[ // WEST
	"BUS_InfSentry",
	"BUS_InfSquad",
	"BUS_InfAssault",
	"BUS_InfSquad_Weapons",
	"BUS_InfTeam",
	"BUS_InfTeam_AA",
	"BUS_InfTeam_AT",
	"BUS_ReconPatrol",
	"BUS_ReconSentry",
	"BUS_ReconTeam",
	"BUS_ReconSquad",
	"BUS_SniperTeam"
],[
	"BUS_SPGPlatoon_Scorcher",
	"BUS_SPGSection_MLRS",
	"BUS_SPGSection_Scorcher",
	"BUS_TankPlatoon",
	"BUS_TankPlatoon_AA",
	"BUS_TankSection"
],[
	"BUS_MotInf_AA",
	"BUS_MotInf_AT",
	"BUS_MotInf_GMGTeam",
	"BUS_MotInf_MGTeam",
	"BUS_MotInf_MortTeam",
	"BUS_MotInf_Team"
], [
	"BUS_MechInf_AA",
	"BUS_MechInf_AT",
	"BUS_MechInf_Support",
	"BUS_MechInfSquad"
], [
	"BUS_AttackTeam_UAV",
	"BUS_AttackTeam_UGV",
	"BUS_diverTeam",
	"BUS_diverTeam_Boat",
	"BUS_diverTeam_SDV",
	"BUS_ReconTeam_UAV",
	"BUS_ReconTeam_UGV",
	"BUS_SmallTeam_UAV"
]]];

// Zone Locations
//_zones = [position player, getMarkerPos "zone_01"];
br_zones = [];

// Current selected zone
br_current_zone = nil;

// Creates the zone
br_fnc_createZone = {
	if (br_randomly_find_zone) then {
		br_current_zone = selectRandom br_zones;
	} else {
		br_current_zone = [[], 0, -1, 0, 0, 25, 0] call BIS_fnc_findSafePos;
	};
	// Creates the radius
	["ZONE_RADIUS", br_current_zone, br_zone_radius, br_max_radius_distance, "ColorRed", "Enemy Zone", 0.4] call (compile preProcessFile "core\server\functions\fn_createRadiusMarker.sqf");
	// Create text icon
	["ZONE_ICON", br_current_zone, "Enemy Zone", "ColorBlue"] call (compile preProcessFile "core\server\functions\fn_createTextMarker.sqf");
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
	br_enemy_vehicle_objects = [];
};

// Find all markers
// Runs once per mission
br_fnc_doChecks = {
	for "_i" from 0 to br_max_checks do {
		// Get marker prefixs
		_endString = Format ["zone_spawn_%1", _i];
		_endStringVeh = Format ["vehicle_spawn_%1", _i];
		_endStringHeli = Format ["helicopter_transport_%1", _i];
		_endStringHeliEvac = Format ["helicopter_evac_%1", _i];
		_endStringBombSquad = Format ["objective_squad_%1", _i];
		// Check if markers exist
		if (getMarkerColor _endString != "") 
		then { br_zones append [getMarkerPos _endString]; };
		if ((getMarkerColor _endStringVeh != "") && {(br_enable_friendly_ai)}) 
		then { [_endStringVeh] execVM "core\server\base\fn_createVehicle.sqf"; };
		if ((getMarkerColor _endStringHeli != "") && {(br_enable_friendly_ai)})
		then { [_endStringHeli, _i, FALSE] execVM "core\server\base\fn_createHelis.sqf"; };
		if ((getMarkerColor _endStringHeliEvac != "") && {(br_enable_friendly_ai)})
		then { [_endStringHeliEvac, _i, TRUE] execVM "core\server\base\fn_createHelis.sqf"; };
		if ((getMarkerColor _endStringBombSquad != "") && {(br_enable_friendly_ai)})
		then { [_endStringBombSquad, _i] execVM "core\server\base\fn_createObjectiveUnits.sqf"; };
	};
};

// Called when zone is taken
br_fnc_onZoneTaken = {
	br_zone_taken = TRUE;
	[[["Zone Taken!"],"core\client\task\fn_completeObjective.sqf"],"BIS_fnc_execVM",true,true] call BIS_fnc_MP;
	[[[],"core\client\task\fn_completeZoneTask.sqf"],"BIS_fnc_execVM",true,true] call BIS_fnc_MP;
	// Delete all markers
	deleteMarker "ZONE_RADIUS";
	deleteMarker "ZONE_ICON";
	// Delete all AI left at zone
	[] call br_fnc_deleteAllAI;
	br_objectives = [];
	sleep 5;
};

// On first zone creation after AI and everything has been placed do the following...
br_fnc_onFirstZoneCreation = {
	if (br_enable_friendly_ai) then {
		execVM "core\server\base\fn_friendlySpawnAI.sqf";
		execVM "core\server\zone\fn_commandFriendlyGroups.sqf";
		execVM "core\server\garbage_collector\fn_checkFriendyAIPositions.sqf";
	};
	execVM "core\server\zone\fn_commandEnemyGroups.sqf";
	execVM "core\server\garbage_collector\fn_garbageCollector.sqf";
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
	{
		deleteVehicle _x;
	} forEach br_enemy_vehicle_objects;
};

// Main function
br_fnc_main = {
	// Check for markers and do things
	[] call br_fnc_doChecks;
	while {TRUE} do {
		// Everything relies on the zone so we create it first, and not using execVM since it has a queue.
		[] call br_fnc_createZone;
		execVM "core\server\task\fn_playerZoneTasking.sqf";
		// Create HQ
		if (br_hq_enabled) then {["HQ", 15, "Land_Cargo_HQ_V1_F", "Kill", FALSE, "HQ Taken!", ["O_officer_F"], TRUE, TRUE] execVM "core\server\zone_objective\fn_createObjective.sqf";};
		// Create radio tower
		if (br_radio_tower_enabled) then {["Radio_Tower", 10, "Land_TTowerBig_2_F", "Destory", TRUE, "Radio Tower Destroyed!", [], TRUE, TRUE] execVM "core\server\zone_objective\fn_createObjective.sqf";};
		// Create EMP thingy. This was added as a test
		["EMP", 6, "O_Truck_03_device_F", "Destory", TRUE, "EMP Destroyed!", [], TRUE, TRUE] execVM "core\server\zone_objective\fn_createObjective.sqf";
		// Check if it's the first zone
		if (br_first_Zone) then { call br_fnc_onFirstZoneCreation } else { [] call br_fnc_onNewZoneCreation; };
		// Set taken as false
		br_zone_taken = FALSE;
		["ZONE_Radio_Tower_RADIUS"] execVM "core\server\zone\fn_zoneSpawnAI.sqf";
		// Wait for a time for the zone to populate
		sleep 60;
		// Wait untill zone is taken and objectives are completed
		{ if (_x select 6) then { waitUntil { missionNamespace getVariable (_x select 5) }; }; } forEach br_objectives;
		waitUntil { (count br_AIGroups < br_min_enemy_groups_for_capture) };
		[] call br_fnc_onZoneTaken;
	}
};

[] call br_fnc_main;