While {TRUE} do {
	// Delete groups where all units are dead
	{	// Add waypoint to group (Will do for all groups)
		_y = _x;
		// Check number of waypoints, if less then 3 add more.
		if (count (waypoints _y) < 3) then {
			//_pos = [] call getLocation;
			_pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
			_wp = _y addWaypoint [_pos, 0];
			_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
		};
		// Check group is empty, remove it from groups and delete it
		if (({alive _x} count units _y) < 1) then { br_AIGroups deleteAt (br_AIGroups find _y); { deleteVehicle _x } forEach units _y; deleteGroup _y;  _y = grpNull; _y = nil; };
	} foreach br_AIGroups;
	sleep 1;
}