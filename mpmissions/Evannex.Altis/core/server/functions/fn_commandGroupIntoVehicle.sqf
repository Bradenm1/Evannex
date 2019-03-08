private _group = _this select 0;
private _getOut = _this select 1;
private _vehicle = _this select 2;
if (_getOut) then {
	_group leaveVehicle _vehicle;
} else {
	_group addVehicle _vehicle;
};
{
	//_x assignAsCargo _vehicle;
	if (_getOut) then { _x action ["Eject", _vehicle]; } else { [_x] orderGetIn true; };
} foreach (units _group);