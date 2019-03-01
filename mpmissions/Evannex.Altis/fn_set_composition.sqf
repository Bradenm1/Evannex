private _source = _this select 0;
private _composition = _this select 1;

{
	_type = _x select 0;
	_offset = _x select 1;
	_newDir = _x select 2;
	_obj = createVehicle [_type, [0,0,0], [], 0, "CAN_COLLIDE"];
	_obj allowDamage false;
	[_source, _obj, _offset, _newDir, true, true] call BIS_fnc_relPosObject;
} forEach _composition;