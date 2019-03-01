/* //////////////////////////////////////////////
Author: J.Shock

Function: fn_posConversion.sqf

Description: Takes an object/string and gets the position.

Parameters: 
		1- (string/object/position array)

Return: Position.

*///////////////////////////////////////////////
params
[
	["_data",[0,0,0]]
];

switch (typeName _data) do
{
	case "OBJECT": { _data = getPos _data; };
	case "STRING": { _data = getMarkerPos _data; };
	case "ARRAY": { _data; };
	default { diag_log "Center position undefined >> SBGF\fn_buildingPositions.sqf"; };
};

_data;