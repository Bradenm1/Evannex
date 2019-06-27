private _group = _this select 0;
private _vehicle = _this select 1;
private _vehicleGroup = _this select 2;
private _timeBeforeTeleport = 0;

{ _x selectweapon primaryWeapon _x; /*_x setDamage 0*/ } foreach (units _group);
_timeBeforeTeleport = time + br_groupsStuckTeleportDelay;
waitUntil { sleep 2; {_x in _vehicle} count (units _group) == {(alive _x)} count (units _group) || !([_vehicle, _vehicleGroup, TRUE] call fn_checkVehicleAndCrewAlive) || time >= _timeBeforeTeleport || _vehicle emptyPositions "cargo" == 0 || (getPos _vehicle select 2 > 10) };
if (time >= _timeBeforeTeleport || getPos _vehicle select 2 > 10) then { { _x moveInCargo _vehicle; } forEach units _group; };