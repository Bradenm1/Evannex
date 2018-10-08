_spawnPad = _this select 0; // The position where the AI will spawn
_bombIndex = _this select 1; // Index when created
_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died
_objectiveGroup = nil; // The unit group
_transportVehicle = nil; // The vehicle the group is using
_getOutOfVehicleRadius = 400; // Range from objective to eject vehicle
_objective = nil; // The objective for the group

// Creat the units
br_fnc_createBombUnits = {
	_transportVehicle = "B_G_Van_01_transport_F" createVehicle getMarkerPos _spawnPad;
	// Delete if existing group
	_objectiveGroup = [WEST, "BLU_F", "Infantry", "BUS_InfAssault", getMarkerPos _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_spawnGroup.sqf";
	(leader _objectiveGroup) moveInDriver _transportVehicle;
	{ if (_x != (leader _objectiveGroup)) then { _x assignAsCargo _transportVehicle; [_x] orderGetIn true; (leader _objectiveGroup); _x moveInCargo _transportVehicle; }; } forEach (units _objectiveGroup);
	// Give each unit a sactelCharge
	{ _oldPack = unitBackpack _x; removeBackpack _x; deleteVehicle _oldPack; } forEach (units _objectiveGroup);
	{ _x addBackpack "B_Carryall_ocamo"; _x addMagazines ["SatchelCharge_Remote_Mag", 1]; } forEach (units _objectiveGroup);
	br_friendly_objective_groups append [_objectiveGroup];
	waitUntil { {_x in _transportVehicle} count (units _objectiveGroup) == {(alive _x)} count (units _objectiveGroup) };
	// Wait a second
	sleep 1;
};

// Tell the unit to touchoff the bomb
br_fnc_placeBomb = {
	_bomb = "satchelcharge_remote_ammo" createVehicle (getpos (_objective select 1));
	_bomb setDamage 1;
	(_objective select 1) setDamage 1;
};

// Kill all groups at objective
br_fnc_goKillPeople = {
	_groups = _objective select 2;
	if (count _groups > 0) then {
		for "_i" from 0 to count _groups do {
			{
				_wp = _objectiveGroup addWaypoint [group _x, 0];
				_wp setWaypointFormation "WEDGE";
				_wp setWaypointType "DESTROY";
				_wp setWaypointSpeed "FULL";
				waitUntil { !(alive _x) };
			} forEach (units (_groups select _i));
		};	
	};
};

// Do the objectives
br_fnc_DoObjective = {
	_obj = _this select 0;
	switch (_obj) do {
		case "Destory & Kill": { call br_fnc_goKillPeople; call br_fnc_placeBomb; };
		case "Destory": { call br_fnc_placeBomb; };
		case "Kill": { call br_fnc_goKillPeople; };
		default { hint "Objective Error in command group"};
	};
};

// Find objective
br_fnc_findObjective = {
	_foundObjective = FALSE;
	while {!_foundObjective} do {
		_objective = selectRandom br_objectives;
		if ( (_objective select 4) ) then { _foundObjective = TRUE; }
		else { sleep 10; };
	};
};

// AI script for the group
br_fnc_runRadioBombUnit = {
	while {TRUE} do {
		[] call br_fnc_createBombUnits;
		waitUntil { !br_zone_taken && {count br_objectives > 0}};
		// Find a objective
		[] call br_fnc_findObjective;
		// Idle group if no radio tower
		missionNamespace setVariable [(format ["br_objective_%1", _objective select 0]), FALSE];
		// Check if units are dead and radio tower is not blown up
		while {({(alive _x)} count (units _objectiveGroup) > 0) && {!(missionNamespace getVariable (format ["br_objective_%1", _objective select 0]))} && {(!br_zone_taken)} && {!(missionNamespace getVariable (_objective select 5))}} do {
			// Check if any groups are waiting
			if (count (waypoints _objectiveGroup) < 2) then {
				_wp = _objectiveGroup addWaypoint [getpos (_objective select 1), 0];
				_wp setWaypointFormation "WEDGE";
				_wp setWaypointType "DESTROY";
				_wp setWaypointSpeed "FULL";
				_wp setWaypointStatements ["true", (format ["br_objective_%1 = TRUE;", _objective select 0])];
				// Wait until group is within a given range
				waitUntil { (((getpos (leader _objectiveGroup)) distance (getpos (_objective select 1)) < _getOutOfVehicleRadius) || {missionNamespace getVariable (_objective select 5)} || {(missionNamespace getVariable (format ["br_objective_%1", _objective select 0]))} || {({(alive _x)} count (units _objectiveGroup) == 0)}); };
				// Check if objective is not completed
				if (!(missionNamespace getVariable (_objective select 5))) then { 
					// Tell group to get out of transport vehicle
					{[_x] allowGetIn false; _x action ["Eject", vehicle _x]} forEach (units _objectiveGroup); 
					// Wait untill group has reached radio tower
					waitUntil { ((missionNamespace getVariable (format ["br_objective_%1", _objective select 0])) || {missionNamespace getVariable (_objective select 5)} || {({(alive _x)} count (units _objectiveGroup) == 0)}); };
					// Touch off bomb at radio tower if still alive and radio tower not already blown up
					if (({(alive _x)} count (units _objectiveGroup) > 0) && {!(missionNamespace getVariable (_objective select 5))} && {(missionNamespace getVariable (format ["br_objective_%1", _objective select 0]))}) then  { [(_objective select 3)] call br_fnc_DoObjective; };	
				};
			}
		}; 
		br_objectives deleteAt (br_objectives find _objective);
		{ deleteVehicle _x; } forEach (units _objectiveGroup);
		deleteVehicle _transportVehicle;
		deleteGroup _objectiveGroup;
		br_friendly_objective_groups deleteAt (br_friendly_objective_groups find _objectiveGroup);
	};
};

[] call br_fnc_runRadioBombUnit;