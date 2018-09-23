// Number of AI to spawn each side
br_min_ai_groups = 18; // Number of groups
br_min_friendly_ai_groups = 5;
br_min_radius_distance = 180; // Limit to spawm from center
br_max_radius_distance = 360; // Outter limit
br_zone_radius = 55; // Radius to spawn within
br_total_groups_spawed = 0; // Total groups spawned
br_AIGroups = []; // All spawned groups
br_FriendlyAIGroups = []; // Firendly AI
br_helis_in_transit = [];
br_heliGroups = [];
br_groupsInTransit = [];
br_friendlyGroupsWaiting = [];
br_friendlyvehicles = [];
br_HQ_taken = 0;
br_radio_tower_destoryed = 0;
br_zone_taken = 0;
br_heli_queue_size = 0;
br_min_helis = 1;
br_max_checks = 200;

// Zone Locations
//_zones = [position player, getMarkerPos "zone_01"];
br_zones = [];

// Current zone
br_current_zone = objnull;

// Creates the zone
createZone = {
	br_current_zone = floor random count br_zones;
	_location = br_zones select br_current_zone;
	// Creates the radius
	["ZONE_RADIUS", _location, br_zone_radius, br_max_radius_distance, "ColorRed", "Enemy Zone", 0.4] call (compile preProcessFile "functions\createRadiusMarker.sqf");
	// Create text icon
	["ZONE_ICON", _location, "Enemy Zone", "ColorBlue"] call (compile preProcessFile "functions\createTextMarker.sqf");
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

// Called when the Zone is taken
onTaken = {
	["TaskSucceeded",["", "Zone Taken"]] call bis_fnc_showNotification;
	br_zone_taken = 1;
	sleep 5;
	// Delete spawned AI
	{
		deleteGroup _x; _x = grpNull;
	} foreach br_AIGroups;
	br_AIGroups = [];
	br_zone_taken = 0;
	br_total_groups_spawed = 0;
	br_radio_tower_destoryed = 0;
	br_HQ_taken = 0;
};

// Get all heli and vehicle spawn locations
createFriendlyTransportAndVehicles = {
	for "_i" from 0 to br_max_checks do {
		_endStringVeh = Format ["vehicle_spawn_%1", _i];
		_endStringHeli = Format ["helicopter_transport_%1", _i];
		if (getMarkerColor _endStringVeh == "") 
		then {} else {  
			[_endStringVeh] execVM "createVehicle.sqf";
		};
		if (getMarkerColor _endStringHeli == "") 
		then {} else {  
			[_endStringHeli] execVM "createHelis.sqf";
		};
	};
};

// Get all spawn locations
getZoneSpawnLocations = {
	for "_i" from 0 to br_max_checks do {
		_endString = Format ["marker_%1", _i];
		if (getMarkerColor _endString == "") 
		then {} else {  
			br_zones append [getMarkerPos _endString];
		};
	};
};

// Main function
main = {
	while {True} do {
		// Get spawn locations
		[] call getZoneSpawnLocations;
		// Create a zone
		// Everything relies on the zone so we create it first, and not using execVM since it has a queue.
		[] call createZone;
		execVM "createHQ.sqf";
		execVM "createRadioTower.sqf";
		//[] call createRescueBunker;
		execVM "zoneSpawnAI.sqf";
		[] call createFriendlyTransportAndVehicles;
		execVM "friendlySpawnAI.sqf";
		sleep 30;
		// Waits untills most groups are dead, HQ is taken and radio tower is destoryed
		waitUntil { (count br_AIGroups < 2) and (br_radio_tower_destoryed == 1) and (br_HQ_taken == 1); };
		// Calls when zone is taken
		[] call onTaken;
	}
};

[] call main;