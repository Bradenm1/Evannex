_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died
_chopperUnits = nil;
_helicopterVech = nil;
_heliPad = _this select 0;

// Gets a random location on the plaer
getGroundUnitLocation = {
	// Gets a random location within the zone radius
	(getMarkerPos "marker_ai_spawn_friendly_ground_units") getPos [5 * sqrt random 0, random 360];
};

commandGroupIntoChopper = {
	_group = _this select 0;
	_getOut = _this select 1;
	if (_getOut) then {
		_group leaveVehicle _helicopterVech;
	} else {
		_group addVehicle _helicopterVech;
	};
	{
		//_x assignAsCargo _helicopterVech;
		if (_getOut) then { _x action ["Eject",_helicopterVech]; } else { [_x] orderGetIn true; };
	} foreach (units _group);
};

// Create a landing pad
createHeliPad = {
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", getMarkerPos _heliPad, [], 0, "CAN_COLLIDE" ];
};

// Spawn custom units
createChopperUnit = {
	_helicopterVech = "B_Heli_Transport_03_F" createVehicle getMarkerPos _heliPad;
	//createVehicleCrew _helicopterVech;
	_chopperUnits = [[] call getGroundUnitLocation, WEST, ["B_Pilot_F"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
	//_chopperUnits addVehicle _helicopterVech;
	{_x moveInDriver _helicopterVech} forEach units _chopperUnits;
	br_heliGroups append [_chopperUnits];
	waitUntil { {_x in _helicopterVech} count (units _chopperUnits) == {(alive _x)} count (units _chopperUnits) };
	//br_helisWaiting append [_chopper];
};

// Checks if units in chooper are dead but false is if they are alive
checkHeliDead = {
	if ({(alive _x)} count (units _chopperUnits) > 0) then { false; } else { true; };
};

createHelis = {
	[] call createHeliPad;
	while {True} do {
		[] call createChopperUnit;
		// Check if units inside chopper are dead
		while {{(alive _x)} count (units _chopperUnits) > 0} do {
			// Check if any groups are waiting
			if ((count br_friendlyGroupsWaiting > 0)) then {
				// Remove group from queue
				_group = br_friendlyGroupsWaiting select 0;
				br_friendlyGroupsWaiting deleteAt (br_friendlyGroupsWaiting find _group);
				// Check if group is alive
				if ({(alive _x)} count (units _group) > 0) then {
					[_group, false] call commandGroupIntoChopper;
					waitUntil { {_x in _helicopterVech} count (units _group) == {(alive _x)} count (units _group) || [] call checkHeliDead };
					//br_FriendlyAIGroups append [_chopperUnits];
					br_helis_in_transit append [_chopperUnits];
					_chopperUnits setBehaviour "CARELESS";
					_pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius + br_zone_radius) * sqrt br_max_radius_distance, 600, 24, 0, 20, 0] call BIS_fnc_findSafePos;
					_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
					_wp = _chopperUnits addWaypoint [_pos, 0];
					_wp setWaypointType "GETOUT";
					_wp setWaypointStatements ["true", "heli land ""LAND"";"];
					waitUntil {(getPos _helicopterVech select 2 > 10) || [] call checkHeliDead};
					waitUntil {(getPos _helicopterVech select 2 < 1) || [] call checkHeliDead};
					_wp = _chopperUnits addWaypoint [getpos _helicopterVech, 0];
					_wp setWaypointType "GETIN";
					br_FriendlyAIGroups append [_group];
					
					waitUntil { {_x in _helicopterVech} count (units _chopperUnits) == {(alive _x)} count (units _chopperUnits) || [] call checkHeliDead};
					_chopperUnits setBehaviour "SAFE";
					_wp = _chopperUnits addWaypoint [getMarkerPos _heliPad, 0];
					_wp setWaypointType "GETOUT";
					_wp setWaypointStatements ["true", "heli land ""LAND"";"];
					[_group, true] call commandGroupIntoChopper;
					waitUntil {(getPos _helicopterVech select 2 > 10) || [] call checkHeliDead};
					waitUntil {(getPos _helicopterVech select 2 < 1) || [] call checkHeliDead};
					_wp = _chopperUnits addWaypoint [getpos _helicopterVech, 0];
					_wp setWaypointType "GETIN";
				}
			};
			sleep _allSpawnedDelay;
		};
		// Do the below because the heli died
		br_heliGroups deleteAt (br_heliGroups find _chopperUnits);
		deleteGroup _chopperUnits;
		_chopperUnits = grpNull;
		_chopperUnits = nil;
	};
};

[] call createHelis;