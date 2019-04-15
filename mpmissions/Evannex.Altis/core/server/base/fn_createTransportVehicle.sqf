private _spawnPad = _this select 0; // The spawnpad for it
private _vehIndex = _this select 1;
private _unitChance = _this select 2;
private _evacVehicle = _this select 3;
private _vehicleGroup = nil; // The group in the vehicle
private _vehicle = nil; // The vehicle
private _landMarker = nil; // Used to tell the AI where to land

// Deletes the current Vehicle units
br_fnc_deleteOldVehicleUnits = {
	br_heliGroups deleteAt (br_heliGroups find _vehicleGroup);
	{ deleteVehicle _x } forEach units _vehicleGroup;
	deleteGroup _vehicleGroup;
};

// Creates the helicopter units
br_fnc_createVehicleUnits = {
	createVehicleCrew _vehicle;
	// Get the vehicle commander
	private _commander = driver _vehicle;
	// Get the group from the commander
	private _temp = group _commander;
	_vehicleGroup = createGroup WEST;
	// If vehicle is another faction it can spawn people on the wrong side, we need them to be on our side.
	(units _temp) joinSilent _vehicleGroup;
	{_x disableAI "MOVE"; } forEach units _vehicleGroup;
	{ _x setSkill br_ai_skill } forEach units _vehicleGroup;
	br_heliGroups append [_vehicleGroup];
	_vehicle engineOn false;
};

// Gets the LZ for the zone
br_fnc_createSpotNearZone = {
	private _spaceMult = 2;
	private _pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * _spaceMult) * sqrt br_max_radius_distance, 600, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
	// We also find another position if it's too far from the zone
	while {count _pos > 2 || _pos distance br_current_zone > (br_max_ai_distance_before_delete - 50)} do {
		_pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * _spaceMult) * sqrt br_max_radius_distance, 600, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
		_spaceMult = _spaceMult + 0.1;
		sleep 0.1;
	};
	private _nearestRoad = [_pos, 500] call BIS_fnc_nearestRoad;
	if (!isNull _nearestRoad) then {
		_pos = getPos _nearestRoad;
	};
	[format ["Drop - %1", _vehIndex], _pos, format ["Drop - %1", groupId _vehicleGroup], "ColorGreen", 1] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
	_pos;
};

// Spawn custom units
br_fnc_createVehicleUnit = {
	// Select a random unit from the above list to spawn
	_vehicle = (selectrandom _unitChance) createVehicle (getMarkerPos _spawnPad);
	_vehicle setUnloadInCombat [FALSE, FALSE];
	// Create its crew
	call br_fnc_createVehicleUnits;
	[_vehicleGroup, _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";
	{ _x setBehaviour "AWARE"; _x setSkill br_ai_skill; } forEach (units _vehicleGroup);
};

// Wait for a group to enter the Vehicle
br_fnc_waitForUntsToEnterVehicle = {
	private _tempGroup = _this select 0;
	{_x selectweapon primaryWeapon _x; _x setDamage 0} foreach (units _tempGroup);
	_timeBeforeTeleport = time + br_groupsStuckTeleportDelay;
	waitUntil { sleep 1; {_x in _vehicle} count (units _tempGroup) == {(alive _x)} count (units _tempGroup) || [] call br_fnc_checkVehicleDead || _vehicle emptyPositions "cargo" == 0 || time >= _timeBeforeTeleport || (getPos _vehicle select 2 > 10) };
	if (time >= _timeBeforeTeleport ) then { { _x moveInCargo _vehicle; } forEach units _tempGroup; };
};

// Checks if units in chooper are dead but false is if they are alive
br_fnc_checkVehicleDead = {
	if (({(alive _x)} count (units _vehicleGroup) > 0) && {(alive _vehicle)} && {(((leader _vehicleGroup) distance _vehicle) < 30)}) then { false;} else { true; };
};

// Gets the LZ for the zone
br_fnc_createEvacPoint = {
	private _pos = _this select 0;
	[format ["EVACv - %1", _vehIndex], _pos, format ["EVAC - %1", groupId _vehicleGroup], "colorCivilian", 1] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
};

br_fnc_move = {
	private _pos = _this select 0; // Position to land
	// Create units
	//[] call br_fnc_createVehicleUnits;
	_vehicle setDamage 0;
	_vehicle setFuel 1;
	_vehicleGroup setBehaviour "AWARE";
	{_x enableAI "MOVE"; } forEach units _vehicleGroup;
	private _wp = _vehicleGroup addWaypoint [_pos, 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
	_vehicle engineOn true;
	waitUntil { sleep 2; _vehicle distance _pos < 10 || {[] call br_fnc_checkVehicleDead} || {br_zone_taken}};
	while {(count (waypoints _vehicleGroup)) > 0} do
	{
		deleteWaypoint ((waypoints _vehicleGroup) select 0);
	};
	_vehicle engineOn false;
};

fn_disable_group_fms = {
	params ["_group", "_enabled"];
	{ if (_enabled) then { _x enableAI "ALL"; } else { _x disableAI "ALL"; }; } forEach units _group;
};

// Go and land at zone
br_fuc_MoveGroupTotZone = {
	private _groups = _this select 0;
	[_vehicle, "Waiting for all units to enter the helicopter..."] remoteExec ["vehicleChat"];
	// Add groups to transit
	{ br_groups_in_transit pushBack _x; } forEach _groups;
	// Command groups into helicopter
	{ [_x, FALSE, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_commandGroupIntoVehicle.sqf"; } forEach _groups;
	// Wait for the units to enter the helicopter
	{ [_x] call br_fnc_waitForUntsToEnterVehicle; } forEach _groups;
	[_vehicle, "Departing in 15 seconds!"] remoteExec ["vehicleChat"];
	sleep 15;
	{ [_x, FALSE] call fn_disable_group_fms; } forEach _groups;
	{_x enableAI "MOVE"; } forEach units _vehicleGroup;
	// Generate landing zone and move to it and land
	[[] call br_fnc_createSpotNearZone] call br_fnc_move;
	[_vehicle, "Ejecting units!"] remoteExec ["vehicleChat"];
	// Tell the groups to getout
	[_vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_ejectCrew.sqf";
	{ [_x, TRUE] call fn_disable_group_fms; } forEach _groups;
	{ deleteVehicle _x } forEach units _vehicleGroup;
	call br_fnc_createVehicleUnits;
	// Delete un-needed things
	deleteVehicle _landMarker;
	deleteMarker format ["Drop - %1", _vehIndex];
	// Wait untill all units are out
	tempTime = time + br_groupsStuckTeleportDelay;
	{ waitUntil { sleep 1; [_x, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_getUnitsInVehicle.sqf" == 0 || time > tempTime}; } forEach _groups;
	// Set group as aware
	{ _x setBehaviour "AWARE"; } forEach _groups;	
	// Remove groups from transit
	{ br_groups_in_transit deleteAt (br_groups_in_transit find _x); } forEach _groups;
	// Move groups into commanding zone group
	{ 
		private _y = _x;
		private _playerCount = ({isPlayer _x} count (units _y));
		if (_playerCount == 0) then {
			br_friendly_ai_groups pushBack _y; 
		};
	} forEach _groups;
	// Goto helipad and land
	[getMarkerPos _spawnPad] call br_fnc_move;
	{_x disableAI "MOVE"; } forEach units _vehicleGroup;
};


br_fnc_runEvacVehicle = {
	if (count br_friendly_groups_wating_for_evac > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_wating_for_evac, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_findGroupsInQueue.sqf";
		if (count _groups > 0) then {
			{ 
				br_friendly_groups_wating_for_evac deleteAt (br_friendly_groups_wating_for_evac find _x);
				br_groups_in_transit pushBack _x; 
				_x setBehaviour "SAFE";	 
			} forEach _groups;
			// Get landing position
			private _pos = [getpos (leader (_groups select 0)), 0, 300, 24, 0, 0.25, 0] call BIS_fnc_findSafePos;
			while {count _pos > 2} do {
				_pos = [getpos (leader (_groups select 0)), 0, 300, 24, 0, 0.25, 0] call BIS_fnc_findSafePos;
				sleep 0.01;
			};
			// Create LZ
			[_pos] call br_fnc_createEvacPoint;
			{_x enableAI "MOVE"; } forEach units _vehicleGroup;
			// Moveto LZ
			[_pos] call br_fnc_move;
			// Wait for group to get in
			{ [_x, false, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_commandGroupIntoVehicle.sqf"; } forEach _groups;
			// Wait for units to enter the helicopter
			{ [_x] call br_fnc_waitForUntsToEnterVehicle; } forEach _groups;
			// Delete LZ
			deleteVehicle _landMarker;
			deleteMarker format ["EVACv - %1", _vehIndex];
			// Move back to base
			[getMarkerPos _spawnPad] call br_fnc_move;
			// Eject the crew at base
			[_vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_ejectCrew.sqf";
			{ deleteVehicle _x } forEach units _vehicleGroup;
			call br_fnc_createVehicleUnits;
			// Wait untill all units are out
			tempTime = time + br_groupsStuckTeleportDelay;
			{ waitUntil { sleep 1; [_x, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_getUnitsInVehicle.sqf" == 0 || time > tempTime}; } forEach _groups;
			// Wait untill chopper is empty
			{
				private _y = _x; 
				waitUntil { sleep 1; {_x in _vehicle} count (units _y) == 0}; 
				// Move group to waiting groups
				private _playerCount = ({isPlayer _x} count (units _y));
				if (_playerCount == 0) then {
					br_friendly_groups_waiting pushBack _y;
				};
				// Delete from transit group
				br_groups_in_transit deleteAt (br_groups_in_transit find _y);
			} forEach _groups;
			{_x disableAI "MOVE"; } forEach units _vehicleGroup;
		};
	};
};

// If the Vehicle is transport
br_fnc_runTransportVehicle = {
	// Check if any groups are waiting
	if (count br_friendly_groups_waiting > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_waiting, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_findGroupsInQueue.sqf"; 
		if (count _groups > 0) then {
			[_groups] call br_fuc_MoveGroupTotZone;
		};	
	} else { 
		// Check if any players are waiting in helicopter
		_playersGroups = [_vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_getPlayersInVehicle.sqf";
		if (count _playersGroups > 0) then {
			[_playersGroups] call br_fuc_MoveGroupTotZone;
		};
	};
};

// run the vehicle
br_fnc_runVehicleUnit = {
	while {True} do {
		// Spawn vehicle
		[] call br_fnc_createVehicleUnit;
		while {({(alive _x)} count (units _vehicleGroup) > 0) && {(alive _vehicle)} && {(((leader _vehicleGroup) distance _vehicle) < 30)};} do {
			sleep 15;
			if (_evacVehicle) then { call br_fnc_runEvacVehicle; } else { call br_fnc_runTransportVehicle; };
			_vehicle setFuel 1;
			_vehicle setDamage 0;
			// Veh should be on the pad, destory if not
			if ((getMarkerPos _spawnPad) distance _vehicle > 10) then { _vehicle setdamage 1; };
		};
		sleep 15;
		// Do some cleanup cause they died
		call br_fnc_deleteOldVehicleUnits;
		deleteVehicle _vehicle;
	};
};

[] call br_fnc_runVehicleUnit;