private _vehicle = _this select 0; // The vehicle
private _vehicleGroup = _this select 1; // The group controlling the vehicle
private _leaderDistanceMatters = _this select 2; // Matters if the leader is too far away

private _isAlive = TRUE;
if (_leaderDistanceMatters) then {
	if (((leader _vehicleGroup) distance _vehicle) >= 30) then {
		_isAlive = FALSE;
	}; 
};
if (({(alive _x)} count (units _vehicleGroup) == 0) && {!(alive _vehicle)}) then { _isAlive = FALSE; };
_isAlive;