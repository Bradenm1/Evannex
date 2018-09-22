_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died
_chopperUnits = nil;
_helicopterVech = nil;
_carryingUnits = false;

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

// Spawn custom units
createChopperUnit = {
	_helicopterVech = "B_Heli_Transport_03_F" createVehicle getMarkerPos "helicopter_transport_01";
	//createVehicleCrew _helicopterVech;
	_chopperUnits = [[] call getGroundUnitLocation, WEST, ["B_Pilot_F"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
	//_chopperUnits addVehicle _helicopterVech;
	{_x moveInDriver _helicopterVech} forEach units _chopperUnits;
	br_heliGroups append [_chopperUnits];
	waitUntil { {_x in _helicopterVech} count (units _chopperUnits) == {(alive _x)} count (units _chopperUnits) };
	//br_helisWaiting append [_chopper];
};


createHelis = {
	[] call createChopperUnit;
	while {True} do {
		// Spawn AI untill reached limit
		//while {((count br_heliGroups) <= br_min_helis)} do {
		//	sleep _aiSpawnRate;
		//	[] call createCustomUnitsFriendly;
		//};
		if ((count br_friendlyGroupsWaiting > 0) && (!_carryingUnits)) then {
			_group = br_friendlyGroupsWaiting select 0;
			br_friendlyGroupsWaiting deleteAt (br_friendlyGroupsWaiting find _group);
			if ({(alive _x)} count (units _group) > 0) then {
				[_group, false] call commandGroupIntoChopper;
				waitUntil { {_x in _helicopterVech} count (units _group) == {(alive _x)} count (units _group) };
				//br_FriendlyAIGroups append [_chopperUnits];
				br_helis_in_transit append [_chopperUnits];
				_carryingUnits = true;
				_chopperUnits setBehaviour "CARELESS";
				_pos = [] call getLocation;
				_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
				_wp = _chopperUnits addWaypoint [_pos, 0];
				_wp setWaypointType "GETOUT";
				_wp setWaypointStatements ["true", "heli land ""LAND"";"];
				waitUntil {(getPos _helicopterVech select 2 > 10)};
				waitUntil {(getPos _helicopterVech select 2 < 1)};
				[_group, true] call commandGroupIntoChopper;
				br_FriendlyAIGroups append [_group];
				{_x moveInDriver _helicopterVech} forEach units _chopperUnits;	
				[_chopperUnits, false] call commandGroupIntoChopper;
				_wp = _chopperUnits addWaypoint [getMarkerPos "helicopter_transport_01", 0];
				_wp setWaypointType "GETOUT";
				_wp setWaypointStatements ["true", "heli land ""LAND"";"];
				waitUntil {(getPos _helicopterVech select 2 > 10)};
				waitUntil {(getPos _helicopterVech select 2 < 1)};
			}
		};
		sleep _allSpawnedDelay;
	};
};

[] call createHelis;