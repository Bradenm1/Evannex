private _object = _this select 0; // An object/unit/vehicle to use.

private _spaceMult = 1;
private _pos = [getpos _object, 0, 300 * _spaceMult, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
// We also find another position if it returns a null position
while {count _pos > 2} do {
	_pos = [getpos _object, 0, 300 * _spaceMult, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
	_spaceMult = _spaceMult + 0.1;
	sleep 0.1;
};
_pos;