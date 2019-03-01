/* //////////////////////////////////////////////
Author: J.Shock

Function: fn_buildingPositions.sqf

Description: Gets all building positions within a defined radius of 
			 given marker/object/position center.

Parameters: 
		1- Center position: (string/object/position array) (default: objNull)
		2- Radius from center: (scalar) (default: 200)
		
	Example: ["mrkName",200] call SBGF_fnc_buildingPositions;

Return: A multi-dimension array of the number of buildings and building positions: 
							[#,[[x,y,z],[x,y,z],[x,y,z]]]

**DISCLAIMER**
Do not remove this header from this function. Any reproduced and/or otherwise used 
portions of this code must include credits to the author (J.Shock).

*///////////////////////////////////////////////
params
[
	["_ctr",objNull,["",objNull,[]],[3]],
	["_radius",200,[0]]
];
private ["_houses","_insideHousePos","_singlePosArray"];

_center = _ctr call SBGF_fnc_posConversion;

_houses = nearestObjects [_center, ["Building"], _radius];

_insideHousePos = [];

{ 
	if ([_x] call BIS_fnc_isBuildingEnterable) then 
	{ 
		_buildPos = [_x] call BIS_fnc_buildingPositions; 
		_insideHousePos pushBack _buildPos; 
	};
} forEach _houses;

_singlePosArray = [];

for "_i" from 0 to ((count _insideHousePos) - 1) step 1 do
{
	_singleHouse = _insideHousePos select _i;

	for "_a" from 0 to ((count _singleHouse) - 1) step 1 do
	{
		_singlePos = _singleHouse select _a;
		_singlePosArray pushBack _singlePos;
	};
};

[count _insideHousePos,_singlePosArray];