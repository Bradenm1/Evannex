private _heliPad = _this select 0; // The position where the AI will spawn
private _heliIndex = _this select 1; // The index of the helictoper given other helicopters
private _evacChopper = _this select 2; // If te helicopter is a evac helicopter or not
private _vehicleGroup = nil; // The group in the heli
private _helicopterVehicle = nil; // The helicopter
private _landMarker = nil; // Used to tell the AI where to land
private _unitChance = _this select 3;
private _fmsDisable = ["MOVE", "TARGET", "AUTOTARGET", "FSM", "AUTOCOMBAT", "AIMINGERROR", "SUPPRESSION", "MINEDETECTION", "WEAPONAIM", "CHECKVISIBLE"];

// Spawn custom units
br_fnc_createChopperUnit = {
	_helicopterVehicle = (selectrandom _unitChance) createVehicle getMarkerPos _heliPad;
	[_helicopterVehicle] call fn_addToZeus;
	_vehicleGroup = [_helicopterVehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
	waitUntil { sleep 3; {_x in _helicopterVehicle} count (units _vehicleGroup) == {(alive _x)} count (units _vehicleGroup) };
};

// Go and land at zone
br_fuc_landGroupAtZone = {
	private _groups = _this select 0;
	[_helicopterVehicle, "Waiting for all units to enter the helicopter..."] remoteExec ["vehicleChat"]; 
	// Command groups into helicopter
	{ [_x, false, _helicopterVehicle] call fn_commandGroupIntoVehicle; } forEach _groups;
	// Wait for the units to enter the helicopter
	{ [_x, _helicopterVehicle, _vehicleGroup] call fn_waitForGroupToEnterVehicle; } forEach _groups;
	[_helicopterVehicle, "Departing in 15 seconds!"] remoteExec ["vehicleChat"]; 
	sleep 15;
	// Generate landing zone and move to it and land
	private _landPosition = call fn_createLandingNearZone;
	[_helicopterVehicle, _vehicleGroup, _groups, _landPosition, TRUE, TRUE, "LZ", "ColorGreen", TRUE] call fn_landHelicopter;
	// Move groups into commanding zone group
	{ 
		private _y = _x;
		private _playerCount = ({isPlayer _x} count (units _y));
		if (_playerCount == 0) then {
			br_friendly_ai_groups pushBack _y; 
		};
	} forEach _groups;
	//_vehicleGroup = [_helicopterVehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
	// Goto helipad and land
	[_helicopterVehicle, _vehicleGroup, [], getMarkerPos _heliPad, TRUE, FALSE, "RTB", "ColorOrange", TRUE] call fn_landHelicopter;
	// Create a temp group
	_vehicleGroup = [_helicopterVehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
};

// If the chopper is evac
br_fnc_runEvacChopper = {
	private _groups = _this select 0;
	// Moveto LZ
	private _landPosition = [(leader (_groups select 0))] call fn_createLandingNearObject;
	[_helicopterVehicle, _vehicleGroup, [], _landPosition, TRUE, FALSE, "EVAC", "ColorCIV", TRUE] call fn_landHelicopter;
	{ [_x, false, _helicopterVehicle] call fn_commandGroupIntoVehicle; } forEach _groups;
	//_vehicleGroup = [_helicopterVehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
	// Wait for units to enter the helicopter
	[_helicopterVehicle, "Waiting for all units to enter the helicopter..."] remoteExec ["vehicleChat"]; 
	{ [_x, _helicopterVehicle, _vehicleGroup] call fn_waitForGroupToEnterVehicle; } forEach _groups;
	[_helicopterVehicle, "Departing in 15 seconds!"] remoteExec ["vehicleChat"]; 
	sleep 15;
	[_helicopterVehicle, _vehicleGroup, _groups, getMarkerPos _heliPad, TRUE, TRUE, "RTB", "ColorOrange", TRUE] call fn_landHelicopter;
	// Wait for units to eject and return to base
	[_helicopterVehicle, _groups] call fn_dropEvacedUnitsAtBase;
	_vehicleGroup = [_helicopterVehicle, WEST, _fmsDisable] call fn_createHelicopterCrew;
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
			if (_evacChopper) then { 
				private _groups = [_helicopterVehicle] call fn_getWatingEvacGroups;
				if (count _groups > 0) then { [_groups] call br_fnc_runEvacChopper; };
			} else { 
				private _groups = [_helicopterVehicle] call fn_getWaitingGroups;
				if (count _groups > 0) then { [_groups] call br_fuc_landGroupAtZone; };
			};
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