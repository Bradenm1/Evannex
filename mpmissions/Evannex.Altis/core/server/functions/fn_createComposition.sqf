private _source = _this select 0;
private _composition = _this select 1;
private _objectGroup = [];

{
	_x params ["_type", "_offset", "_newDir"];
	private _obj = createVehicle [_type, [0,0,0], [], 0, "CAN_COLLIDE" ];
	[_source, _obj, _offset, _newDir] call BIS_fnc_relPosObject;
	private _newPos = getPosASL _obj;
	_newPos set [2, 0];
	_obj setPosATL _newPos;
	_obj setVectorUp (surfaceNormal _newPos);
	_objectGroup pushBack _obj;
	sleep 0.1;
} forEach _composition;
_objectGroup;