// Checks units too far from the zone and delete them
br_fnc_deleteDumbAI = {
	_group = _this select 0;
	_sidePosition = _this select 1;
	{
		_y = _x;
		{ if ((isNull objectParent _x) && {((getpos _x) distance (getMarkerPos "ZONE_ICON") > br_max_ai_distance_before_delete) && ((getpos _x) distance _sidePosition > br_max_ai_distance_before_delete)} && {!br_zone_taken}) then { deleteVehicle _x }; } forEach (units _y);
	} foreach _group;
};

br_fnc_checkObjectives = {
	_group = _this select 0;
	{
		[_group, _x select 0] call br_fnc_deleteDumbAI;
	} foreach br_current_sides;
};

While {TRUE} do {
	if (!br_zone_taken) then {
		[br_friendly_objective_groups] call br_fnc_checkObjectives;
		[br_friendly_ai_groups] call br_fnc_checkObjectives;
		[br_ai_groups] call br_fnc_checkObjectives;
	};
	sleep 30;
};