private _heliPad = _this select 0; // The position where the AI will spawn
private _heliIndex = _this select 1; // The index of the helictoper given other helicopters
private _evacChopper = _this select 2; // If te helicopter is a evac helicopter or not
private _vehicleGroup = nil; // The group in the heli
private _helicopterVehicle = nil; // The helicopter
private _landMarker = nil; // Used to tell the AI where to land
private _unitChance = _this select 3;

// Create a landing pad
br_fnc_createHeliPad = {
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", getMarkerPos _heliPad, [], 0, "CAN_COLLIDE" ];
};

// Spawn custom units
br_fnc_createChopperUnit = {
	_helicopterVehicle = (selectrandom _unitChance) createVehicle getMarkerPos _heliPad;
	[] call br_fnc_createHeliUnits;
	waitUntil { sleep 3; {_x in _helicopterVehicle} count (units _vehicleGroup) == {(alive _x)} count (units _vehicleGroup) };
};

// Deletes the current chopper units
br_fnc_deleteOldChopperUnit = {
	br_heliGroups deleteAt (br_heliGroups find _vehicleGroup);
	{ deleteVehicle _x } forEach units _vehicleGroup;
	deleteGroup _vehicleGroup;
};

// Checks if units in chooper are dead but false is if they are alive
br_fnc_checkHeliDead = {
	if (({(alive _x)} count (units _vehicleGroup) > 0) && {(alive _helicopterVehicle)} && {(((leader _vehicleGroup) distance _helicopterVehicle) < 30)}) then { false;} else { true; };
};

// Creates the helicopter units
br_fnc_createHeliUnits = {
	createVehicleCrew _helicopterVehicle;
	_vehicleGroup = createGroup WEST;
	(units (group ((crew _helicopterVehicle) select 0))) joinSilent _vehicleGroup;
	{ deleteVehicle _x; } forEach units _vehicleGroup - [driver _helicopterVehicle, leader _vehicleGroup];
	//_vehicleGroup = [call compile preprocessFileLineNumbers "core\server\functions\fn_getGroundUnitsLocation.sqf", WEST, ["B_Pilot_F"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
	{_x disableAI "MOVE"; _x disableAI "TARGET"; _x disableAI "AUTOTARGET" ; _x disableAI "FSM" ; _x disableAI "AUTOCOMBAT"; _x disableAI "AIMINGERROR"; _x disableAI "SUPPRESSION"; _x disableAI "MINEDETECTION" ; _x disableAI "WEAPONAIM"; _x disableAI "CHECKVISIBLE"; } forEach units _vehicleGroup;
	//(leader _vehicleGroup) moveInDriver _helicopterVehicle;
	{ _x setSkill br_ai_skill } forEach units _vehicleGroup;
	br_heliGroups pushBack _vehicleGroup;
	_helicopterVehicle engineOn false;
};

// Gets the LZ for the zone
br_fnc_createLandingSpotNearZone = {
	private _spaceMult = 1;
	private _pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * 2) * sqrt br_max_radius_distance, 600 * _spaceMult, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
	// We also find another position if it's too far from the zone
	while {count _pos > 2 || _pos distance br_current_zone > (br_max_ai_distance_before_delete - 50)} do {
		_pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * 2) * sqrt br_max_radius_distance, 600 * _spaceMult, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
		_spaceMult = _spaceMult + 0.1;
		sleep 0.1;
	};
	[format ["LZ - %1", _heliIndex], _pos, format ["LZ - %1", groupId _vehicleGroup], "ColorGreen", 1] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
	_pos;
};

// Gets the LZ for the zone
br_fnc_createLandingSpotLZ = {
	private _spaceMult = 1;
	// Get landing position
	private _pos = [getpos (leader (_groups select 0)), 0, 300 * _spaceMult, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
	while {count _pos > 2} do {
		_pos = [getpos (leader (_groups select 0)), 0, 300 * _spaceMult, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
		_spaceMult = _spaceMult + 0.1;
		sleep 0.01;
	};
	[format ["EVACc - %1", _heliIndex], _pos, format ["EVAC - %1", groupId _vehicleGroup], "colorCivilian", 1] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
	_pos;
};

// Get units alive in a group
br_fnc_getUnitsAlive = {
	private _tempGroup = _this select 0;
	private _count = 0;
	{ if (alive _x) then {_count = _count + 1}; } forEach (units _tempGroup);
	_count;
};

// Wait for a group to enter the chopper
br_fnc_waitForUntsToEnterChopper = {
	private _tempGroup = _this select 0;
	{_x selectweapon primaryWeapon _x; _x setDamage 0} foreach (units _tempGroup);
	_timeBeforeTeleport = time + br_groupsStuckTeleportDelay;
	waitUntil { sleep 3; ({_x in _helicopterVehicle} count (units _tempGroup) == {(alive _x)} count (units _tempGroup) || {[] call br_fnc_checkHeliDead} || {_helicopterVehicle emptyPositions "cargo" == 0} || {time >= _timeBeforeTeleport} || {(getPos _helicopterVehicle select 2 > 10)}) };
	if (time >= _timeBeforeTeleport || (getPos _helicopterVehicle select 2 > 10) ) then { { _x moveInCargo _helicopterVehicle; } forEach units _tempGroup; };
};

// Tell helicopter to goto and land, wait until this has happened
br_fnc_movetoAndLand = {
	private _pos = _this select 0; // Position to land
	// If group already exists delete it
	[] call br_fnc_deleteOldChopperUnit;
	// Create units
	[] call br_fnc_createHeliUnits;
	_helicopterVehicle setDamage 0;
	_helicopterVehicle setFuel 1;
	_vehicleGroup setBehaviour "CARELESS";
	{_x enableAI "MOVE"; } forEach units _vehicleGroup;
	private _wp = _vehicleGroup addWaypoint [_pos, 0];
	_wp setWaypointType "GETOUT";
	_helicopterVehicle engineOn true;
	// Wait untill landed
	waitUntil { sleep 3; (getPos _helicopterVehicle select 2 > 10) || {[] call br_fnc_checkHeliDead} || {!(isEngineOn _helicopterVehicle)} || {br_zone_taken}};
	// Has landed
	waitUntil { sleep 3; (getPos _helicopterVehicle select 2 < 1) || {[] call br_fnc_checkHeliDead} || {br_zone_taken}};
	[] call br_fnc_deleteOldChopperUnit;
	_helicopterVehicle engineOn false;
};

// Go and land at zone
br_fuc_landGroupAtZone = {
	private _groups = _this select 0;
	[_helicopterVehicle, "Waiting for all units to enter the helicopter..."] remoteExec ["vehicleChat"]; 
	// Add groups to transit
	{ br_groups_in_transit pushBack _x; } forEach _groups;
	// Command groups into helicopter
	{ [_x, false, _helicopterVehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_commandGroupIntoVehicle.sqf"; } forEach _groups;
	// Wait for the units to enter the helicopter
	{ [_x] call br_fnc_waitForUntsToEnterChopper; } forEach _groups;
	[_helicopterVehicle, "Departing in 15 seconds!"] remoteExec ["vehicleChat"]; 
	sleep 15;
	// Generate landing zone and move to it and land
	[[] call br_fnc_createLandingSpotNearZone] call br_fnc_movetoAndLand;
	[_helicopterVehicle, "Ejecting units!"] remoteExec ["vehicleChat"];
	// Tell the groups to getout
	[_helicopterVehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_ejectCrew.sqf";
	// Wait untill all units are out
	tempTime = time + br_groupsStuckTeleportDelay;
	{ waitUntil { sleep 2; [_x, _helicopterVehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_getUnitsInVehicle.sqf" == 0 || time > tempTime}; } forEach _groups;
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
	// Delete un-needed things
	deleteVehicle _landMarker;
	deleteMarker format ["LZ - %1", _heliIndex];
	// Goto helipad and land
	[getMarkerPos _heliPad] call br_fnc_movetoAndLand;
	// Create a temp group
	[] call br_fnc_createHeliUnits;
};

// If the chopper is transport
br_fnc_runTransportChopper = {
	// Check if any groups are waiting
	if (count br_friendly_groups_waiting > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_waiting, _helicopterVehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_findGroupsInQueue.sqf";
		if (count _groups > 0) then {
			[_groups] call br_fuc_landGroupAtZone;
		};		
	} else { 
		// Check if any players are waiting in helicopter
		_playersGroups = [_helicopterVehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_getPlayersInVehicle.sqf";
		if (count _playersGroups > 0) then {
			[_playersGroups] call br_fuc_landGroupAtZone;
		};
	};
};

// If the chopper is evac
// using an old system... Takes one group at a time...
br_fnc_runEvacChopper = {
	if (count br_friendly_groups_wating_for_evac > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_wating_for_evac, _helicopterVehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_findGroupsInQueue.sqf";
		if (count _groups > 0) then {
			{ 
				br_friendly_groups_wating_for_evac deleteAt (br_friendly_groups_wating_for_evac find _x);
				br_groups_in_transit pushBack _x; 
				_x setBehaviour "SAFE";	 
			} forEach _groups;
			// Moveto LZ
			[call br_fnc_createLandingSpotLZ] call br_fnc_movetoAndLand;
			// Wait for group to get in
			{ [_x, false, _helicopterVehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_commandGroupIntoVehicle.sqf"; } forEach _groups;
			call br_fnc_createHeliUnits;
			// Wait for units to enter the helicopter
			{ [_x] call br_fnc_waitForUntsToEnterChopper; } forEach _groups;
			// Delete LZ
			deleteVehicle _landMarker;
			deleteMarker format ["EVACc - %1", _heliIndex];
			// Move back to base
			[getMarkerPos _heliPad] call br_fnc_movetoAndLand;
			// Eject the crew at base
			[_helicopterVehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_ejectCrew.sqf";
			// Wait untill all units are out
			tempTime = time + br_groupsStuckTeleportDelay;
			{ waitUntil { sleep 2; [_x, _helicopterVehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_getUnitsInVehicle.sqf" == 0 || time > tempTime}; } forEach _groups;
			// Wait untill chopper is empty
			{
				private _y = _x; 
				waitUntil { sleep 1; {_x in _helicopterVehicle} count (units _y) == 0}; 
				// Move group to waiting groups
				private _playerCount = ({isPlayer _x} count (units _y));
				if (_playerCount == 0) then {
					br_friendly_groups_waiting pushBack _y;
				};
				// Delete from transit group
				br_groups_in_transit deleteAt (br_groups_in_transit find _y);
			} forEach _groups;
			[] call br_fnc_createHeliUnits;	
		};
	};
};

// Run AI
br_fnc_createHelis = {
	// Create the base helipad
	[] call br_fnc_createHeliPad;
	while {True} do {
		// Create chopper units
		[] call br_fnc_createChopperUnit;
		// Set angle vector
		[_vehicleGroup, _heliPad] call compile preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";
		// Check if units inside chopper are dead, or helicopter is dead or pilot ran away
		while {({(alive _x)} count (units _vehicleGroup) > 0) && (alive _helicopterVehicle) && (((leader _vehicleGroup) distance _helicopterVehicle) < 30) && (fuel _helicopterVehicle > 0.2)} do {
			sleep 25;
			if (_evacChopper) then { [] call br_fnc_runEvacChopper; } else { [] call br_fnc_runTransportChopper; };
			_helicopterVehicle setFuel 1;
			_helicopterVehicle setDamage 0;
			// Heli should be on the pad, destory if not
			if ((getMarkerPos _heliPad) distance _helicopterVehicle > 10) then { _helicopterVehicle setdamage 1; };
		};
		sleep 15;
		// Do the below because the heli died or some bullcrap happened
		[] call br_fnc_deleteOldChopperUnit;
		deleteVehicle _helicopterVehicle;
	};
};

[] call br_fnc_createHelis;