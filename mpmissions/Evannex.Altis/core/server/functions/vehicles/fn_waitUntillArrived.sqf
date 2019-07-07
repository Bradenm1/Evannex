private _vehicle = _this select 0; // The helictoper
private _drivingPosition = _this select 1; // Position to drive to
private _vehicleGroup = _this select 2; // The group controlling the vehicle

_vehicle setDamage 0;
_vehicle setFuel 1;
_vehicleGroup setBehaviour "AWARE";
{_x enableAI "MOVE"; } forEach units _vehicleGroup;

// Do WP stuff
private _wp = _vehicleGroup addWaypoint [_drivingPosition, 0];
_wp setWaypointType "MOVE";
_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];

_vehicle engineOn true;
waitUntil { sleep 2; _vehicle distance _drivingPosition < 10 || {!([_vehicle, _vehicleGroup, TRUE] call fn_checkVehicleAndCrewAlive)} || (count (waypoints _vehicleGroup)) == 0 || {br_zone_taken}};
/*while {(count (waypoints _vehicleGroup)) > 0} do
{
	deleteWaypoint ((waypoints _vehicleGroup) select 0);
};*/
_vehicle engineOn false;
[_vehicleGroup] call fn_deleteGroup;