	private _pos = call fn_createLandingNearZone;
	private _nearestRoad = [_pos, 500] call BIS_fnc_nearestRoad;
	if (!isNull _nearestRoad) then {
		_pos = getPos _nearestRoad;
	};
	_pos;