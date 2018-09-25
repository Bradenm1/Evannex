_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died
_bombGroup = nil;

// Gets a random location on the plaer
getGroundUnitLocation = {
	// Gets a random location within the zone radius
	(getMarkerPos "marker_ai_spawn_friendly_ground_units") getPos [5 * sqrt random 0, random 360];
};

createBombUnits = {
	_bombGroup = [WEST, "BLU_F", "Infantry", "BUS_InfAssault", [] call getLocation] call compile preprocessFileLineNumbers "functions\spawnGroup.sqf";
	// Give each unit a sactelCharge
	{ _x addMagazines ["SatchelCharge_Remote_Mag", 1] } forEach _bombGroup;
};

createHelis = {
	while {True} do {
		[] call createBombUnits;
		// Check if units inside chopper are dead
		while {{(alive _x)} count (units _bombGroup) > 0} do {
			// Check if any groups are waiting
			_pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
			_wp = _y addWaypoint [_pos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
		};
		sleep 15;
	};
};

[] call createHelis;