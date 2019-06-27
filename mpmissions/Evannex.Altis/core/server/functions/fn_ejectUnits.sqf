private _vehicle = _this select 0;
private _includePlayers = _this select 1;
{
	if ((!isPlayer _x) || (isPlayer _x && _includePlayers)) then {
		_x action ["Eject", _vehicle]; _x leaveVehicle _vehicle;
	};
} foreach (units _vehicle);