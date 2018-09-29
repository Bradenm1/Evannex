// Checks units too far from the zone and delete them
deleteDumbAI = {
	_group = _this select 0;
	{
		_y = _x;
		{ if ((isNull objectParent _x) && ((getpos _x) distance (getMarkerPos "ZONE_ICON") > br_max_ai_distance_before_delete)) then { deleteVehicle _x }; } forEach (units _y);
	} foreach _group;
};

While {TRUE} do {
	[br_friendlyRadioBombers] call deleteDumbAI;
	[br_FriendlyAIGroups] call deleteDumbAI;
	sleep 30;
};