_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died
_chopperUnits = nil;
_helicopterVech = nil;
_heliPad = _this select 0;
_heliIndex = _this select 1;
_landMarker = nil;

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
		if (_getOut) then { _x action ["Eject", _helicopterVech]; } else { [_x] orderGetIn true; };
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
	[] call createHeliUnits;
	waitUntil { {_x in _helicopterVech} count (units _chopperUnits) == {(alive _x)} count (units _chopperUnits) };
	//br_helisWaiting append [_chopper];
};

deleteOldChopperUnit = {
	br_heliGroups deleteAt (br_heliGroups find _chopperUnits);
	{ deleteVehicle _x } forEach units _chopperUnits;
	deleteGroup _chopperUnits;
};

// Checks if units in chooper are dead but false is if they are alive
checkHeliDead = {
	if (({(alive _x)} count (units _chopperUnits) > 0) && (alive _helicopterVech)) then {
		false;
	} else { 
		true; 
	};
};

createHeliUnits = {
	_chopperUnits = [[] call getGroundUnitLocation, WEST, ["B_Pilot_F"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
	{_x disableAI "TARGET"; _x disableAI "AUTOTARGET" ; _x disableAI "FSM" ; _x disableAI "AUTOCOMBAT"; } forEach units _chopperUnits;
	//_chopperUnits addVehicle _helicopterVech;
	{_x moveInDriver _helicopterVech} forEach units _chopperUnits;
	br_heliGroups append [_chopperUnits];
};

createLandingSpotNearZone = {
	_pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * 2) * sqrt br_max_radius_distance, 600, 24, 0, 0.25, 0] call BIS_fnc_findSafePos;
	[format ["LZ - %1", _heliIndex], _pos, format ["LZ - %1", _heliIndex], "ColorGreen"] call (compile preProcessFile "functions\createTextMarker.sqf");
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
	_pos;
};

createHelis = {
	[] call createHeliPad;
	while {True} do {
		[] call createChopperUnit;
		// Check if units inside chopper are dead
		while {({(alive _x)} count (units _chopperUnits) > 0) && (alive _helicopterVech)} do {
			// Check if any groups are waiting
			if ((count br_friendlyGroupsWaiting > 0)) then {
				// Remove group from queue
				_group = br_friendlyGroupsWaiting select 0;
				br_friendlyGroupsWaiting deleteAt (br_friendlyGroupsWaiting find _group);
				// Check if group is alive
				if ({(alive _x)} count (units _group) > 0) then {
					br_groupsInTransit append [_group];
					[_group, false] call commandGroupIntoChopper;
					waitUntil { {_x in _helicopterVech} count (units _group) == {(alive _x)} count (units _group) || [] call checkHeliDead };
					//br_FriendlyAIGroups append [_chopperUnits];
					br_helis_in_transit append [_chopperUnits];
					_chopperUnits setBehaviour "CARELESS";
					_pos = [] call createLandingSpotNearZone;
					_wp = _chopperUnits addWaypoint [_pos, 0];
					_wp setWaypointType "GETOUT";
					_helicopterVech engineOn true;
					// Wait untill landed
					waitUntil {(getPos _helicopterVech select 2 > 10) || [] call checkHeliDead};
					// Has landed
					waitUntil {(getPos _helicopterVech select 2 < 1) || [] call checkHeliDead};
					[_group, true] call commandGroupIntoChopper;
					[] call deleteOldChopperUnit;
					waitUntil { {_x in _helicopterVech} count (units _group) == 0};
					[] call createHeliUnits;
					// Tell group to get out of chooper, it has landed...
					_group setBehaviour "AWARE";					
					_group setCombatMode "RED";
					br_groupsInTransit deleteAt (br_groupsInTransit find _group);
					br_FriendlyAIGroups append [_group];
					_wp = _chopperUnits addWaypoint [getMarkerPos _heliPad, 0];
					_wp setWaypointType "GETOUT";
					_wp setWaypointStatements ["true", "heli land ""LAND"";"];
					deleteVehicle _landMarker;
					deleteMarker format ["LZ - %1", _heliIndex];
					waitUntil {(getPos _helicopterVech select 2 > 10) || [] call checkHeliDead};
					waitUntil {(getPos _helicopterVech select 2 < 1) || [] call checkHeliDead};
					[] call deleteOldChopperUnit;
					[] call createHeliUnits;
					_helicopterVech engineOn false;
					_helicopterVech setFuel 1;
					_helicopterVech setDamage 0;
				}
			};
			sleep _allSpawnedDelay;
		};
		sleep 15;
		// Do the below because the heli died
		[] call deleteOldChopperUnit;
		deleteVehicle _helicopterVech;
	};
};

[] call createHelis;