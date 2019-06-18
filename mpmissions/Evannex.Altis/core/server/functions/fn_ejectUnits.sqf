private _units = _this select 0;
{
	_x action ["Eject", _vehicle]; _x leaveVehicle _vehicle;
} foreach (_units);