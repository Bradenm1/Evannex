private _group = _this select 0;
private _vehicle = _this select 1;

{
	_x action ["Eject", _vehicle]; _x leaveVehicle _vehicle;
} foreach (units _group); 