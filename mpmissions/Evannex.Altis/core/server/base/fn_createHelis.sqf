private _heliPad = _this select 0; // The position where the AI will spawn
private _heliIndex = _this select 1; // The index of the helictoper given other helicopters
private _evacChopper = _this select 2; // If te helicopter is a evac helicopter or not
private _vehicleGroup = nil; // The group in the heli
private _helicopterVehicle = nil; // The helicopter
private _landMarker = nil; // Used to tell the AI where to land
private _unitChance = _this select 3;

// Spawn custom units
br_fnc_createChopperUnit = {
	_helicopterVehicle = (selectrandom _unitChance) createVehicle getMarkerPos _heliPad;
	[_helicopterVehicle] call fn_addToZeus;
	_vehicleGroup = [_helicopterVehicle, WEST] call fn_createHelicopterCrew;
	//[] call br_fnc_createHeliUnits;
	waitUntil { sleep 3; {_x in _helicopterVehicle} count (units _vehicleGroup) == {(alive _x)} count (units _vehicleGroup) };
};

// Go and land at zone
br_fuc_landGroupAtZone = {
	private _groups = _this select 0;
	[_helicopterVehicle, "Waiting for all units to enter the helicopter..."] remoteExec ["vehicleChat"]; 
	// Add groups to transit
	{ br_groups_in_transit pushBack _x; } forEach _groups;
	// Command groups into helicopter
	{ [_x, false, _helicopterVehicle] call fn_commandGroupIntoVehicle; } forEach _groups;
	// Wait for the units to enter the helicopter
	{ [_x, _helicopterVehicle, _vehicleGroup] call fn_waitForGroupToEnterVehicle; } forEach _groups;
	[_helicopterVehicle, "Departing in 15 seconds!"] remoteExec ["vehicleChat"]; 
	sleep 15;
	// Generate landing zone and move to it and land
	private _landPosition = call fn_createLandingNearZone;
	[_helicopterVehicle, _vehicleGroup, _groups, _landPosition, TRUE, TRUE, "LZ", "ColorGreen"] call fn_landHelicopter;
	// Move groups into commanding zone group
	{ 
		private _y = _x;
		private _playerCount = ({isPlayer _x} count (units _y));
		if (_playerCount == 0) then {
			br_friendly_ai_groups pushBack _y; 
		};
	} forEach _groups;
	_vehicleGroup = [_helicopterVehicle, WEST] call fn_createHelicopterCrew;
	// Goto helipad and land
	[_helicopterVehicle, _vehicleGroup, [], getMarkerPos _heliPad, TRUE, FALSE, "RTB", "ColorOrange"] call fn_landHelicopter;
	// Create a temp group
	_vehicleGroup = [_helicopterVehicle, WEST] call fn_createHelicopterCrew;
};

// If the chopper is evac
// using an old system... Takes one group at a time...
br_fnc_runEvacChopper = {
	if (count br_friendly_groups_wating_for_evac > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_wating_for_evac, _helicopterVehicle] call fn_findGroupsInQueue;
		if (count _groups > 0) then {
			{ 
				br_friendly_groups_wating_for_evac deleteAt (br_friendly_groups_wating_for_evac find _x);
				_x setBehaviour "SAFE";	 
			} forEach _groups;
			// Moveto LZ
			private _landPosition = [(leader (_groups select 0))] call fn_createLandingNearObject;
			[_helicopterVehicle, _vehicleGroup, [], _landPosition, TRUE, FALSE, "EVAC", "ColorCIV"] call fn_landHelicopter;
			{ [_x, false, _helicopterVehicle] call fn_commandGroupIntoVehicle; } forEach _groups;
			_vehicleGroup = [_helicopterVehicle, WEST] call fn_createHelicopterCrew;
			// Wait for units to enter the helicopter
			[_helicopterVehicle, "Waiting for all units to enter the helicopter..."] remoteExec ["vehicleChat"]; 
			{ [_x, _helicopterVehicle, _vehicleGroup] call fn_waitForGroupToEnterVehicle; } forEach _groups;
			[_helicopterVehicle, "Departing in 15 seconds!"] remoteExec ["vehicleChat"]; 
			sleep 15;
			[_helicopterVehicle, _vehicleGroup, _groups, getMarkerPos _heliPad, TRUE, TRUE, "RTB", "ColorOrange"] call fn_landHelicopter;
			// Wait untill chopper is empty
			private _tempTime = 0;
			{
				private _y = _x; 
				_tempTime = time + br_groupsStuckTeleportDelay;
				waitUntil { sleep 1; [_helicopterVehicle, TRUE] call fn_ejectUnits; {_x in _helicopterVehicle} count (units _y) == 0 || time > _tempTime}; 
				// Move group to waiting groups
				private _playerCount = ({isPlayer _x} count (units _y));
				if (_playerCount == 0) then {
					br_friendly_groups_waiting pushBack _y;
				};
			} forEach _groups;
			_vehicleGroup = [_helicopterVehicle, WEST] call fn_createHelicopterCrew;
		};
	};
};

// If the chopper is transport
br_fnc_runTransportChopper = {
	// Check if any groups are waiting
	if (count br_friendly_groups_waiting > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_waiting, _helicopterVehicle] call fn_findGroupsInQueue;
		if (count _groups > 0) then {
			[_groups] call br_fuc_landGroupAtZone;
		};		
	} else { 
		// Check if any players are waiting in helicopter
		_playersGroups = [_helicopterVehicle] call fn_getPlayersInVehicle;
		if (count _playersGroups > 0) then {
			[_playersGroups] call br_fuc_landGroupAtZone;
		};
	};
};

// Run AI
br_fnc_createHelis = {
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", getMarkerPos _heliPad, [], 0, "CAN_COLLIDE" ];
	while {True} do {
		// Create chopper units
		[] call br_fnc_createChopperUnit;
		// Set angle vector
		[_vehicleGroup, _heliPad] call fn_setDirectionOfMarker;
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
		[_vehicleGroup] call fn_deleteGroup;
		deleteVehicle _helicopterVehicle;
	};
};

[] call br_fnc_createHelis;