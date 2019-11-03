While {TRUE} do {
	if (!br_zone_taken) then {
		// Delete groups where all units are dead
		{	// Add waypoint to group (Will do for all groups)
			private _y = _x;
			// Check number of waypoints, if less then 3 add more.
			if (count (waypoints _y) < 3 && !br_zone_taken) then {
				//_pos = [] call getLocation;
				private _pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
				while {count _pos > 2} do {
					_pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
					sleep 0.1;
				};
				private _wp = _y addWaypoint [_pos, 0];
				_wp setWaypointType (selectrandom ["Sentry", "Move", "Destroy"]);
				_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
			};
			// Check group is empty, remove it from groups and delete it
			if (({alive _x} count units _y) < 1) then { 
				br_friendly_ai_groups deleteAt (br_friendly_ai_groups find _y); /*{ deleteVehicle _x } forEach units _y;*/ deleteGroup _y;  _y = grpNull; _y = nil; 
			};
		} foreach br_friendly_ai_groups;
		{
			private _y = _x;
			if (({alive _x} count units _y) < 1) then { br_friendly_ground_groups deleteAt (br_friendly_ground_groups find _y); { deleteVehicle _x } forEach units _y; deleteGroup _y;  _y = grpNull; _y = nil;};
		} forEach br_friendly_ground_groups;
		{
			private _y = _x;
			// Check number of waypoints, if less then 1 add more.
			if (count (waypoints _y) < 3) then {
				private _pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
				while {count _pos > 2} do {
					_pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
					sleep 0.1;
				};
				_wp = _y addWaypoint [_pos, 0];
				_wp setWaypointFormation "NO CHANGE";
				_wp setWaypointSpeed "FULL";
				_wp setWaypointBehaviour "AWARE";
				_wp setWaypointStatements ["true","while {(count (waypoints this)) > 0} do { deleteWaypoint ((waypoints this) select 0); }; br_friendly_ai_groups pushBack this;"];
			};
		} forEach br_friendly_ground_on_foot_to_zone;
	};
	sleep br_command_delay;
};