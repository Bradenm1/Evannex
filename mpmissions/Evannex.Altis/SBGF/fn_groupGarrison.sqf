/* //////////////////////////////////////////////
Author: J.Shock

Function: fn_groupGarrison.sqf

Description: Fills buildings within a defined radius with pre-spawned (editor placed) units.

Parameters: 
		1- Unit/Group Leader: (object) (note: for use with unit's name or init field using "this" as the parameter)
		2- Center position: (string/object/position array) (default: objNull)
		3- Radius for building search: (scalar) (default: 200)
		
	Example: [this,"mrkName",200] call SBGF_fnc_groupGarrison;

Return: True when completed.

*///////////////////////////////////////////////
params
[
	"_unit",
	["_center",objNull,["",objNull,[]],[3]],
	["_radius",200,[0]]
];
private ["_unitsGroup","_completed","_buildings"];

_unitsGroup = units group (_unit);
_completed = false;
_buildings = [_center,_radius] call SBGF_fnc_buildingPositions;
_positionsUsed = [];

{
	_rndPos = ((_buildings select 1) select floor(random(count (_buildings select 1))));
	
	if (!(isNil "_rndPos")) then {
		if (!(_rndPos in _positionsUsed)) then {
			_x setPosATL (_rndPos);
		
			doStop _x;

			_x setDir (random 359);

			_x setUnitPos "UP";
			
			_buildings set [1,((_buildings select 1) - [_rndPos])];
			_positionsUsed append [_rndPos];
		};
	};
	
} forEach _unitsGroup;
_completed = true;

_completed;
