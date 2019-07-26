private _vehicle = _this select 0;
private _side = _this select 1;
private _fms = _this select 2;

// Check gunner seats
deleteVehicle (driver _vehicle);
private _tempGroup = createVehicleCrew _vehicle;
//hint format["%1", count (units _tempGroup)];
private _vehicleGroup = createGroup _side;
// This hotfix won't work if crew count is saw as group in vehicle
private _vehCfg = configFile >> "CfgVehicles" >> typeOf _vehicle;
private _crewCount = {round getNumber (_x >> "dontCreateAI") < 1 && 
					((_x == _vehCfg && {round getNumber (_x >> "hasDriver") > 0}) ||
					(_x != _vehCfg && {round getNumber (_x >> "hasGunner") > 0}))} count ([_vehicle, configNull] call BIS_fnc_getTurrets);
if (_crewCount == (count (units _tempGroup))) then {
	units _tempGroup joinSilent _vehicleGroup;
	{ deleteVehicle _x; } forEach (units (group (driver _vehicle))) - [driver _vehicle];
};
[driver _vehicle] joinSilent _vehicleGroup;
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