private _vehicle = _this select 0;
private _side = _this select 1;

createVehicleCrew _vehicle;
_vehicleGroup = createGroup _side;
(units (group ((crew _vehicle) select 0))) joinSilent _vehicleGroup;
{ deleteVehicle _x; } forEach units _vehicleGroup - [driver _vehicle, leader _vehicleGroup];
{	_x disableAI "MOVE"; _x disableAI "TARGET"; _x disableAI "AUTOTARGET" ; _x disableAI "FSM" ; _x disableAI "AUTOCOMBAT"; _x disableAI "AIMINGERROR"; _x disableAI "SUPPRESSION"; _x disableAI "MINEDETECTION" ; _x disableAI "WEAPONAIM"; _x disableAI "CHECKVISIBLE"; 
	_x setSkill br_ai_skill;
	[_x] call fn_objectInitEvents; 
} forEach units _vehicleGroup;
//br_heliGroups pushBack _vehicleGroup;
_vehicle engineOn false;
_vehicleGroup;