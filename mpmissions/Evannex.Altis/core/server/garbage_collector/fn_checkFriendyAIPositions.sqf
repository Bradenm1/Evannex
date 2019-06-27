// Checks units too far from the zone and delete them
br_fnc_deleteDumbAI = {
	private _group = _this select 0;
	private _sidePosition = _this select 1;
	private _postionMatters = _this select 2;

	{
		_y = _x;
		{ 
			if !([getpos _x, br_garbage_collection_player_distance] call fn_checkPlayersAround) then {
				if ((isNull objectParent _x) && {((getpos _x) distance (getMarkerPos "ZONE_ICON") > br_max_ai_distance_before_delete) && ((getpos _x) distance _sidePosition > br_max_ai_distance_before_delete)} && {!br_zone_taken}) then { deleteVehicle _x };
				if (_postionMatters) then { [_x] call fn_checkPosition; };
			};
		} forEach (units _y);
	} foreach _group;
};

br_fnc_checkObjectives = {
	private _group = _this select 0;
	private _postionMatters = _this select 1;
	{
		[_group, _x select 0, _postionMatters] call br_fnc_deleteDumbAI;
	} foreach br_current_sides;
};

While {TRUE} do {
	if (!br_zone_taken) then {
		[br_friendly_objective_groups, TRUE] call br_fnc_checkObjectives;
		[br_friendly_ai_groups, TRUE] call br_fnc_checkObjectives;
		[br_ai_groups - br_special_ai_groups, TRUE] call br_fnc_checkObjectives;
		[br_special_ai_groups, FALSE] call br_fnc_checkObjectives;
		[br_groups_in_buildings, FALSE] call br_fnc_checkObjectives;
	};
	sleep br_garbage_collection_positions_interval;
};