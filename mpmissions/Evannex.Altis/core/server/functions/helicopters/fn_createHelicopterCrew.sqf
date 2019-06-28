private _vehicle = _this select 0;
private _side = _this select 1;
private _fms = _this select 2;

createVehicleCrew _vehicle;
_vehicleGroup = createGroup _side;
(units (group ((crew _vehicle) select 0))) joinSilent _vehicleGroup;
{ deleteVehicle _x; } forEach units _vehicleGroup - [driver _vehicle, leader _vehicleGroup];
{	
	private _y = _x;
	{
		_y disableAI _x;
	} forEach _fms;
	
	_y setSkill br_ai_skill;
	[_y] call fn_objectInitEvents; 
} forEach units _vehicleGroup;
_vehicle engineOn false;
_vehicleGroup;