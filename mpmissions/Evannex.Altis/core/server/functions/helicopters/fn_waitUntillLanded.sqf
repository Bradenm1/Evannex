private _vehicle = _this select 0; // The helictoper
private _landingPosition = _this select 1; // Position to land at
private _alreadyFlying = _this select 2; // If the helicopter is already flying
private _vehicleGroup = _this select 3; // The group controlling the vehicle

if (!_alreadyFlying) then {
	// If group already exists delete it
	[_vehicleGroup] call fn_deleteGroup;
	// Create units
	_vehicleGroup = [_helicopterVehicle, WEST, ["MOVE", "TARGET", "AUTOTARGET", "FSM", "AUTOCOMBAT", "AIMINGERROR", "SUPPRESSION", "MINEDETECTION", "WEAPONAIM", "CHECKVISIBLE"]] call fn_createHelicopterCrew;
	// Since we are grounded we want to start the engine
	_vehicle engineOn true;
};

_vehicle setDamage 0;
_vehicle setFuel 1;
_vehicleGroup setBehaviour "CARELESS";
{_x enableAI "MOVE"; } forEach units _vehicleGroup;	

// Do WP stuff
private _wp = _vehicleGroup addWaypoint [_landingPosition, 0];
_wp setWaypointType "GETOUT";

// Wait untill landed
waitUntil { sleep 3; (getPos _vehicle select 2 > 10) || {!([_vehicle, _vehicleGroup, TRUE] call fn_checkVehicleAndCrewAlive)} || {!(isEngineOn _vehicle)} || {br_zone_taken}};
// Has landed
waitUntil { sleep 3; (getPos _vehicle select 2 < 1) || {!([_vehicle, _vehicleGroup, TRUE] call fn_checkVehicleAndCrewAlive)} || {br_zone_taken}};
[_vehicleGroup] call fn_deleteGroup;
_vehicle engineOn false;