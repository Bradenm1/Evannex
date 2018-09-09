// Number of AI to spawn each side
br_min_ai_groups = 25; // Number of groups
br_min_radius_distance = 180; // Limit to spawm from center
br_max_radius_distance = 360; // Outter limit
br_zone_radius = 55; // Radius to spawn within
br_total_groups_spawed = 0; // Total groups spawned
br_AIGroups = []; // All spawned groups
br_HQ_taken = 0;
br_radio_tower_destoryed = 0;
br_zone_taken = 0;

// Zone Locations
//_zones = [position player, getMarkerPos "zone_01"];
br_zones = [position player];
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
/*createRescueBunker = {
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
};*/	

// Called when the Zone is taken
onTaken = {
	["TaskSucceeded",["", "Zone Taken"]] call bis_fnc_showNotification;
	br_zone_taken = 1;
	sleep 5;
	br_zone_taken = 0;
	br_total_groups_spawed = 0;
	br_radio_tower_destoryed = 0;
	br_HQ_taken = 0;
};

// Main function
main = {
	while {True} do {
		// Create a zone
		[] call createZone;
		null = execVM "createHQ.sqf";
		null = execVM "createRadioTower.sqf";
		//[] call createRescueBunker;
		null = execVM "spawnAI.sqf";
		sleep 30;
		// Waits untills most groups are dead, HQ is taken and radio tower is destoryed
		waitUntil { (count br_AIGroups < 2) and (br_radio_tower_destoryed == 1) and (br_HQ_taken == 1); };
		// Calls when zone is taken
		[] call onTaken;
	}
};

[] call main;