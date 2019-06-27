
private _vehicle = _this select 0; // The vehicle itself
private _vehicleGroup = _this select 1; // The vehicle group
private _groups = _this select 2; // Groups inside the helicopter
private _landingPosition = _this select 3; // The landing position
private _displayOnMap = _this select 4; // If should display on the map
private _ejectUnits = _this select 5; // If the units get ejected apon arrival
private _markerName = _this select 6; // The marker text on the map
private _markerColour = _this select 7; // The colour of the icon on the map
private _unquieNumber = _vehicle call BIS_fnc_netId;

// Generate landing zone and move to it and land
//private _landingPosition = call fn_createLandingNearZone;
// Place a marker on the map
if (_displayOnMap) then { [format ["%1 - %2", _markerName, _unquieNumber], _landingPosition, format ["%1 - %2", _markerName, groupId (group (driver _vehicle))], _markerColour, 1] call fn_createTextMarker; };
_landMarker = createVehicle [ "Land_HelipadEmpty_F", _landingPosition, [], 0, "CAN_COLLIDE" ];

// Wait until landed
[_vehicle, _landingPosition, FALSE, _vehicleGroup] call fn_waitUntillLanded;
// Wait a second after landing
sleep 1;

// Do this if units should be ejected once landed
if (_ejectUnits) then {
	private _tempTime = 0;
	[_vehicle, "Ejecting units!"] remoteExec ["vehicleChat"];
	// Tell the groups to getout
	[_vehicle, TRUE] call fn_ejectUnits;
	// Wait until all units are out
	_tempTime = time + br_groupsStuckTeleportDelay;
	{ waitUntil { sleep 1; [_x, _vehicle] call fn_getUnitsInVehicle == 0 || time > _tempTime}; } forEach _groups;
	// Set group as aware
	{ _x setBehaviour "AWARE"; } forEach _groups;	
};

deleteVehicle _landMarker;
// Delete the marker on the map
if (_displayOnMap) then { deleteMarker format ["%1 - %2", _markerName, _unquieNumber]; };