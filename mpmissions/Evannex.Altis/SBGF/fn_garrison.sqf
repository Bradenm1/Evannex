/* //////////////////////////////////////////////
Author: J.Shock

Function: fn_garrison.sqf

Description: Fills defined percentage of building positions with a set of 
			 defined units within defined radius.

Parameters: 
		1- Center position: (string/object/position array) (default: objNull)
		2- Side of units: (side) (default: EAST)
		3- Radius for building search: (scalar) (default: 200)
		4- Percentage of used building positions: (scalar (0-1)) (default: 0.2)
		5- Types of units to spawn: (array of classnames) (default: ["O_Soldier_F","O_Soldier_AR_F"])
		6- (Optional)Define the limit of spawned units: (scalar) (default: -1)
			**This overrides parameter 4  (percent of used building positions) unless (-1) is used**
		
	Example: _units = ["mrkName",EAST,300,0.3,["O_Soldier_F","O_Soldier_AR_F"],-1] call SBGF_fnc_garrison;

Return: Array of spawned units.

*///////////////////////////////////////////////
params
[
	["_center",objNull,["",objNull,[]],[3]],
	["_grpParam",EAST,[WEST]],
	["_radius",200,[0]],
	["_pctFill",0.2,[0.0]],
	["_manType",["O_Soldier_F","O_Soldier_AR_F"],[[]]],
	["_positionCount",-1,[0]]
];
private ["_sideGrp","_buildings","_buildCount","_buildPosCount","_cntManType","_spawnedUnits"];

_sideGrp = createGroup _grpParam;

_buildings = [_center,_radius] call SBGF_fnc_buildingPositions;
_buildCount = (_buildings select 0);
_buildPosCount = count (_buildings select 1);
_cntManType = (count _manType);

if (_pctFill > 1 || _pctFill < 0) then
{
	_pctFill = 0.2;
	diag_log "_pctFill must be between 0 and 1, defaulted to 0.2 >> SBGF\fn_garrison.sqf";
};

if (_positionCount isEqualTo -1) then
{
	_positionCount = round(_buildCount * _pctFill);
}
else
{
	if (_positionCount > _buildPosCount) then
	{
		_positionCount = _buildPosCount;
	};
};
_spawnedUnits = [];

for "_i" from 0 to (_positionCount) step 1 do 
{
	_rndPos = ((_buildings select 1) select floor(random(count (_buildings select 1))));
	_rndMan = (_manType select floor(random(_cntManType)));

	_unit = _sideGrp createUnit [_rndMan, (_rndPos), [], 0, "NONE"];

	doStop _unit;

	_unit setDir (random 359);

	_unit setUnitPos "UP";
	
	_spawnedUnits pushBack _unit;
	_buildings set [1,((_buildings select 1) - [_rndPos])];
};

_spawnedUnits;