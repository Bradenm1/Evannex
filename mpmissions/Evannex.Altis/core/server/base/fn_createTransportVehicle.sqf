private _spawnPad = _this select 0; // The spawnpad for it
private _vehIndex = _this select 1;
private _unitChance = _this select 2;
private _vehicleGroup = nil; // The group in the vehicle
private _vehicle = nil; // The vehicle
private _landMarker = nil; // Used to tell the AI where to land

// Gets a random location on the player
br_fnc_getGroundUnitLocation = {
	// Gets a random location within the zone radius
	(getMarkerPos "marker_ai_spawn_friendly_ground_units") getPos [5 * sqrt random 180, random 360];
};

// Deletes the current Vehicle units
br_fnc_deleteOldVehicleUnits = {
	br_heliGroups deleteAt (br_heliGroups find _vehicleGroup);
	{ deleteVehicle _x } forEach units _vehicleGroup;
	deleteGroup _vehicleGroup;
};

// Creates the helicopter units
br_fnc_createVehicleUnits = {
	_vehicleGroup = [[] call br_fnc_getGroundUnitLocation, WEST, ["B_crew_F"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
	{_x disableAI "MOVE"; _x disableAI "TARGET"; _x disableAI "AUTOTARGET" ; _x disableAI "FSM" ; _x disableAI "AUTOCOMBAT"; _x disableAI "AIMINGERROR"; _x disableAI "SUPPRESSION"; _x disableAI "MINEDETECTION" ; _x disableAI "WEAPONAIM"; _x disableAI "CHECKVISIBLE"; } forEach units _vehicleGroup;
	(leader _vehicleGroup) moveInDriver _vehicle;
	{ _x setSkill br_ai_skill } forEach units _vehicleGroup;
	br_heliGroups append [_vehicleGroup];
	_vehicle engineOn false;
};

// Gets the LZ for the zone
br_fnc_createSpotNearZone = {
	_pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * 2) * sqrt br_max_radius_distance, 600, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
	// We also find another position if it's too far from the zone
	while {count _pos > 2 && _pos distance br_current_zone > (br_max_ai_distance_before_delete - 50)} do {
		_pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * 2) * sqrt br_max_radius_distance, 600, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
		sleep 0.1;
	};
	[format ["Drop - %1", _vehIndex], _pos, format ["Drop - %1", groupId _vehicleGroup], "ColorGreen", 1] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
	_pos;
};

// Spawn custom units
br_fnc_createVehicleUnit = {
	// Select a random unit from the above list to spawn
	_vehicle = (selectrandom _unitChance) createVehicle (getMarkerPos _spawnPad);
	// Create its crew
	call br_fnc_createVehicleUnits;
	// Get the vehicle commander
	private _commander = driver _vehicle;
	// Get the group from the commander
	private _temp = group _commander;
	// If vehicle is another faction it can spawn people on the wrong side, we need them to be on our side.
	(units _temp) joinSilent _vehicleGroup;
	[_vehicleGroup, _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";
	{ _x setBehaviour "SAFE"; _x setSkill br_ai_skill; } forEach (units _vehicleGroup);
	// Apply the zone AI to the vehicle
	br_heliGroups append [_vehicleGroup];
};

// Wait for a group to enter the Vehicle
br_fnc_waitForUntsToEnterVehicle = {
	private _tempGroup = _this select 0;
	{_x selectweapon primaryWeapon _x; _x setDamage 0} foreach (units _tempGroup);
	_timeBeforeTeleport = time + br_groupsStuckTeleportDelay;
	waitUntil { {_x in _vehicle} count (units _tempGroup) == {(alive _x)} count (units _tempGroup) || [] call br_fnc_checkVehicleDead || _vehicle emptyPositions "cargo" == 0 || time >= _timeBeforeTeleport || (getPos _vehicle select 2 > 10) };
	if (time >= _timeBeforeTeleport ) then { { _x moveInCargo _vehicle; } forEach units _tempGroup; };
};

// Checks if units in chooper are dead but false is if they are alive
br_fnc_checkVehicleDead = {
	if (({(alive _x)} count (units _vehicleGroup) > 0) && {(alive _vehicle)} && {(((leader _vehicleGroup) distance _vehicle) < 30)}) then { false;} else { true; };
};

// Tell helicopter to goto and land, wait until this has happened
br_fnc_move = {
	private _pos = _this select 0; // Position to land
	// Create units
	//[] call br_fnc_createVehicleUnits;
	_vehicle setDamage 0;
	_vehicle setFuel 1;
	_vehicleGroup setBehaviour "CARELESS";
	{_x enableAI "MOVE"; } forEach units _vehicleGroup;
	private _wp = _vehicleGroup addWaypoint [_pos, count (waypoints _vehicleGroup)];
	_wp setWaypointType "MOVE";
	_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
	_vehicle engineOn true;
	waitUntil {(count (waypoints _vehicleGroup) < 2) || {[] call br_fnc_checkVehicleDead} || {br_zone_taken}};
	_vehicle engineOn false;
};

// Go and land at zone
br_fuc_MoveGroupTotZone = {
	private _groups = _this select 0;
	// Add groups to transit
	{ br_groups_in_transit append [_x]; } forEach _groups;
	// Command groups into helicopter
	{ [_x, false, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_commandGroupIntoVehicle.sqf"; } forEach _groups;
	// Wait for the units to enter the helicopter
	{ [_x] call br_fnc_waitForUntsToEnterVehicle; } forEach _groups;
	// Generate landing zone and move to it and land
	[[] call br_fnc_createSpotNearZone] call br_fnc_move;
	// Tell the groups to getout
	[_vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_ejectCrew.sqf";
	// Wait untill all units are out
	tempTime = time + br_groupsStuckTeleportDelay;
	{ waitUntil { [_x, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_getUnitsInVehicle.sqf" == 0 || time > tempTime}; } forEach _groups;
	// Set group as aware
	{ _x setBehaviour "AWARE"; } forEach _groups;	
	// Remove groups from transit
	{ br_groups_in_transit deleteAt (br_groups_in_transit find _x); } forEach _groups;
	// Move groups into commanding zone group
	{ 
		private _y = _x;
		private _playerCount = ({isPlayer _x} count (units _y));
		if (_playerCount == 0) then {
			br_friendly_ai_groups append [_y]; 
		};
	} forEach _groups;
	// Delete un-needed things
	deleteVehicle _landMarker;
	deleteMarker format ["LZ - %1", _vehIndex];
	// Goto helipad and land
	[getMarkerPos _spawnPad] call br_fnc_move;
};

// If the Vehicle is transport
br_fnc_runTransportVehicle = {
	{_x disableAI "MOVE"; } forEach units _vehicleGroup;
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
			[] call br_fnc_runTransportVehicle;
			_vehicle setFuel 1;
			_vehicle setDamage 0;
			// Heli should be on the pad, destory if not
			if ((getMarkerPos _spawnPad) distance _vehicle > 10) then { _vehicle setdamage 1; };
		};
		sleep 15;
		// Do some cleanup cause they died
		call br_fnc_deleteOldVehicleUnits;
		deleteVehicle _vehicle;
	};
};

[] call br_fnc_runVehicleUnit;