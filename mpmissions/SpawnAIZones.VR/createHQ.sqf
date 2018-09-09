// Circle Radius
_zoneRadius = 15;

// Single unit spawning at a certain location
spawnRandomAIAt = {
	// Getting the params
	_group = _this select 0;
	_spawnAmount = _this select 1;
	_position = _this select 2;
	_applyToMainGroup = _this select 3;
	// Number AI to spawn
	for "_i" from 1 to _spawnAmount do  {
		// Create and return the AI(s) group
		_tempGroup = [_position findEmptyPosition [0,100], side _group, 1] call BIS_fnc_spawnGroup;
		// Place the AI(s) in that group into another group
		units _tempGroup join _group;
	};
	if (_applyToMainGroup == 1) then {br_AIGroups append [_group]};
	_group;
};

// Creates the HQ
createHQ = {
	// Creates center for HQ
	_hqCenterPos = call (compile preprocessFileLineNumbers "functions\getRandomLocation.sqf");
	// Gets position near center
	_hqPos = _hqCenterPos getPos [_zoneRadius * sqrt random 180, random 360];	
	// Place HQ near center
	"Land_Cargo_HQ_V1_F" createVehicle _hqPos;
	// Creates the radius
	["ZONE_HQ_RADIUS", _hqCenterPos, _zoneRadius, 360, "ColorRed", "HQ Zone", 0.3] call (compile preProcessFile "functions\createRadiusMarker.sqf");
	// Create text icon
	["ZONE_HQ_ICON", _hqCenterPos, "HQ", "ColorBlue"] call (compile preProcessFile "functions\createTextMarker.sqf");
	_hqGroup = [ _hqPos, EAST, ["O_officer_F"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
	[_hqGroup, 6, _hqPos, 0] call spawnRandomAIAt;

	waitUntil { ({alive _x} count units _hqGroup < 1); };

	[] call onTaken;
};

// Called when the HQ is taken
onTaken = {
	["TaskSucceeded",["", "HQ Taken"]] call bis_fnc_showNotification;

	"ZONE_HQ_RADIUS" setMarkerColor "ColorBlue"; 

	br_HQ_taken = 1;
};

[] call createHQ;