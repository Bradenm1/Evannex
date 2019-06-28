private _spawnPad = _this select 0; // The spawnpad for it
private _vehIndex = _this select 1;
private _unitChance = _this select 2;
private _evacVehicle = _this select 3;
private _vehicleGroup = nil; // The group in the vehicle
private _vehicle = nil; // The vehicle
private _landMarker = nil; // Used to tell the AI where to land
private _fmsDisable = ["MOVE", "TARGET", "AUTOTARGET", "FSM", "AUTOCOMBAT", "AIMINGERROR", "SUPPRESSION", "MINEDETECTION", "WEAPONAIM", "CHECKVISIBLE"];

// Deletes the current Vehicle units
br_fnc_deleteOldVehicleUnits = {
	br_heliGroups deleteAt (br_heliGroups find _vehicleGroup);
	[_vehicleGroup] call fn_deleteGroup;
};

// Spawn custom units
br_fnc_createVehicleUnit = {
	// Select a random unit from the above list to spawn
	_vehicle = (selectrandom _unitChance) createVehicle (getMarkerPos _spawnPad);
	[_vehicle] call fn_addToZeus;
	_vehicle setUnloadInCombat [FALSE, FALSE];
	_vehicleGroup = [_vehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
	[_vehicleGroup, _spawnPad] call fn_setDirectionOfMarker;
	{ _x setBehaviour "AWARE"; _x setSkill br_ai_skill; } forEach (units _vehicleGroup);
};

fn_disable_group_fms = {
	params ["_group", "_enabled"];
	{ if (_enabled) then { _x enableAI "ALL"; } else { _x disableAI "ALL"; }; } forEach units _group;
};

fn_disable_group_guns = {
 	params ["_group", "_enabled"];
	{ if (_enabled) then { _x enableAI "TARGET"; _x enableAI "AUTOTARGET"; _x enableAI "WEAPONAIM"; _x enableAI "AIMINGERROR"; _x enableAI "CHECKVISIBLE"; _x enableAI "AUTOCOMBAT"; _x enableAI "MINEDETECTION"; } else { _x disableAI "TARGET"; _x disableAI "AUTOTARGET"; _x disableAI "WEAPONAIM"; _x disableAI "AIMINGERROR"; _x disableAI "CHECKVISIBLE"; _x disableAI "AUTOCOMBAT"; _x disableAI "MINEDETECTION"; }; } forEach units _group;
};

// Go and land at zone
br_fuc_MoveGroupTotZone = {
	private _groups = _this select 0;
	[_vehicle, "Waiting for all units to enter the vehicle..."] remoteExec ["vehicleChat"];
	// Command groups into helicopter
	{ [_x, FALSE, _vehicle] call fn_commandGroupIntoVehicle; } forEach _groups;
	// Wait for the units to enter the helicopter
	{ [_x, _vehicle, _vehicleGroup] call fn_waitForGroupToEnterVehicle; } forEach _groups;
	_vehicle setUnloadInCombat [FALSE, FALSE];
	[_vehicle, "Departing in 15 seconds!"] remoteExec ["vehicleChat"];
	sleep 15;
	//{ [_x, FALSE] call fn_disable_group_fms; } forEach _groups;
	//{ [_x, TRUE] call fn_disable_group_guns; } forEach _groups;
	private _dropPosition = call fn_createLandingNearZoneOnRoad;
	[_vehicle, _vehicleGroup, _groups, _dropPosition, TRUE, TRUE, "LZ", "ColorGreen", FALSE] call fn_landHelicopter;
	//{ [_x, TRUE] call fn_disable_group_fms; } forEach _groups;
	[_vehicleGroup] call fn_deleteGroup;
	_vehicleGroup = [_vehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
	// Move groups into commanding zone group
	{ 
		private _y = _x;
		private _playerCount = ({isPlayer _x} count (units _y));
		if (_playerCount == 0) then {
			br_friendly_ai_groups pushBack _y; 
		};
	} forEach _groups;
	// Goto helipad and land
	//[getMarkerPos _spawnPad] call br_fnc_move;
	[_vehicle, _vehicleGroup, _groups, getMarkerPos _spawnPad, TRUE, FALSE, "RTB", "ColorOrange", FALSE] call fn_landHelicopter;
	_vehicleGroup = [_vehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
	{_x disableAI "MOVE"; } forEach units _vehicleGroup;
};


br_fnc_runEvacVehicle = {
	if (count br_friendly_groups_wating_for_evac > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_wating_for_evac, _vehicle] call fn_findGroupsInQueue;
		if (count _groups > 0) then {
			{ 
				br_friendly_groups_wating_for_evac deleteAt (br_friendly_groups_wating_for_evac find _x);
				_x setBehaviour "SAFE";	 
			} forEach _groups;
			// Get drop position
			private _pickUpPosition = [leader (_groups select 0)] call fn_createLandingNearObject;
			[_vehicle, _vehicleGroup, _groups, _pickUpPosition, TRUE, FALSE, "EVAC", "ColorCIV", FALSE] call fn_landHelicopter;
			_vehicleGroup = [_vehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
			// Wait for group to get in
			{ [_x, false, _vehicle] call fn_commandGroupIntoVehicle; } forEach _groups;
			[_vehicle, "Waiting for all units to enter the helicopter..."] remoteExec ["vehicleChat"]; 
			// Wait for units to enter the helicopter
			{ [_x, _vehicle, _vehicleGroup] call fn_waitForGroupToEnterVehicle; } forEach _groups;
			[_vehicle, "Departing in 15 seconds!"] remoteExec ["vehicleChat"]; 
			sleep 15;
			_vehicle setUnloadInCombat [FALSE, FALSE];
			[_vehicle, _vehicleGroup, _groups, getMarkerPos _spawnPad, TRUE, TRUE, "RTB", "ColorOrange", FALSE] call fn_landHelicopter;
			// Wait for units to eject and return to base
			[_vehicle, _groups] call fn_dropEvacedUnitsAtBase;
			_vehicleGroup = [_vehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
			//{_x disableAI "MOVE"; } forEach units _vehicleGroup;
		};
	};
};

// If the Vehicle is transport
br_fnc_runTransportVehicle = {
	// Check if any groups are waiting
	if (count br_friendly_groups_waiting > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_waiting, _vehicle] call fn_findGroupsInQueue; 
		if (count _groups > 0) then {
			[_groups] call br_fuc_MoveGroupTotZone;
		};	
	} else { 
		// Check if any players are waiting in helicopter
		_playersGroups = [_vehicle] call fn_getPlayersInVehicle;
		if (count _playersGroups > 0) then {
			[_playersGroups] call br_fuc_MoveGroupTotZone;
		};
	};
};

// run the vehicle
br_fnc_runVehicleUnit = {
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", getMarkerPos _spawnPad, [], 0, "CAN_COLLIDE" ];
	while {True} do {
		// Spawn vehicle
		[] call br_fnc_createVehicleUnit;
		while {({(alive _x)} count (units _vehicleGroup) > 0) && {(alive _vehicle)} && {(((leader _vehicleGroup) distance _vehicle) < 30)};} do {
			sleep 25;
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