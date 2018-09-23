// Circle Radius
_zoneRadius = 10;

// Creates the RadioTower
createRadioTower = {
	// Creates center for RadioTower
	//_hqCenterPos = call (compile preprocessFileLineNumbers "functions\getRandomLocation.sqf");
	_newPos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 3, 0, 20, 0] call BIS_fnc_findSafePos;
	// Gets position near center
	_hqPos = _newPos getPos [_zoneRadius * sqrt random 180, random 360];	
	// Place RadioTower near center
	_radioTowerObject = "Land_TTowerBig_2_F" createVehicle _hqPos;
	// Creates the radius
	["ZONE_RADIOTOWER_RADIUS", _newPos, 10, 360, "ColorRed", "Radio Tower Zone", 0.3] call (compile preProcessFile "functions\createRadiusMarker.sqf");
	// Create text icon
	["ZONE_RADIOTOWER_ICON", _newPos, "Radio Tower", "ColorBlue"] call (compile preProcessFile "functions\createTextMarker.sqf");

	waitUntil { !alive _radioTowerObject};

	[] call onDestory;
};

// Once object has been Destroyed do the following
onDestory = {
	["TaskSucceeded",["", "Radio Tower Destroyed"]] call bis_fnc_showNotification;

	// Delete the markers
	deleteMarker "ZONE_RADIOTOWER_RADIUS"; 
	deleteMarker "ZONE_RADIOTOWER_ICON";

	br_radio_tower_destoryed = 1;
};

[] call createRadioTower;