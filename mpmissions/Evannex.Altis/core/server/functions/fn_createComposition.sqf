private _source = _this select 0;
private _composition = _this select 1;
private _objectGroup = [];

{
	_x params ["_type", "_offset", "_newDir"];
	private _obj = _type createVehicle [0,0,0];
	[_source, _obj, _offset, _newDir] call BIS_fnc_relPosObject;
	private _newPos = getPosASL _obj;
	_newPos set [2, 0];
	_obj setPosATL _newPos;
	_obj setVectorUp (surfaceNormal _newPos);
	_objectGroup pushBack _obj;
	sleep 0.1;
	_obj enableDynamicSimulation true;
} forEach _composition;
_objectGroup;