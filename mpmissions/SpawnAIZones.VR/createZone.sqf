// Creates the zone
createZone = {
	br_current_zone = floor (random (count br_zones));
	_location = br_zones select br_current_zone;
	// Creates the radius
	["ZONE_RADIUS", _location, br_zone_radius, br_max_radius_distance, "ColorRed", "Enemy Zone", 0.4] call (compile preProcessFile "functions\createRadiusMarker.sqf");
	// Create text icon
	["ZONE_ICON", _location, "Enemy Zone", "ColorBlue"] call (compile preProcessFile "functions\createTextMarker.sqf");

	waitUntil { (count br_AIGroups < 2); };

	[] call onTaken;
};

// Called when the Zone is taken
onTaken = {
	["TaskSucceeded",["", "Zone Taken"]] call bis_fnc_showNotification;

	br_zone_taken = 1;
};

[] call createZone;