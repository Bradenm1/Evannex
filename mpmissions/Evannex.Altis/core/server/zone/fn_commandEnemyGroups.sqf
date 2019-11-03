While {TRUE} do {
	// Delete groups where all units are dead
	{	// Add waypoint to group (Will do for all groups)
		private _y = _x;
		// Check number of waypoints, if less then 3 add more.
		if (count (waypoints _y) < 3) then {
			private _pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
			while {count _pos > 2} do {
				_pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
				sleep 0.1;
			};
			_wp = _y addWaypoint [_pos, 0];
			_wp setWaypointFormation (selectrandom ["NO CHANGE", "COLUMN", "STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "LINE", "FILE", "DIAMOND"]);
			_wp setWaypointSpeed (selectrandom ["UNCHANGED", "LIMITED", "NORMAL", "FULL"]);
			_wp setWaypointBehaviour (selectrandom ["CARELESS", "AWARE", "STEALTH"]);
			_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
		};
		// Check group is empty, remove it from groups and delete it
		if (({alive _x} count units _y) < 1) then { 
			br_ai_groups deleteAt (br_ai_groups find _y); if (_y in br_special_ai_groups) then { br_special_ai_groups deleteAt (br_special_ai_groups find _y); { deleteVehicle _x } forEach units _y; }; deleteGroup _y;  _y = grpNull; _y = nil;
		};
	} foreach br_ai_groups;
	{
		private _y = _x;
		if (({alive _x} count units _y) < 1) then { br_groups_in_buildings deleteAt (br_groups_in_buildings find _y); /*{ deleteVehicle _x } forEach units _y;*/ deleteGroup _y;  _y = grpNull; _y = nil;};
	} forEach br_groups_in_buildings;
	sleep br_command_delay;
}