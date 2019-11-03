private _spawnPad = _this select 0; // The position where the AI will spawn
private _bombIndex = _this select 1; // Index when created
private _vehicleChance = _this select 2;
private _unitChance = _this select 3;
private _allSpawnedDelay = 1; // Seconds to wait untill checking if any groups diedg
private _getOutOfVehicleRadius = 400; // Range from objective to eject vehicle
private _objectiveGroup = createGroup WEST; // The unit group
private _transportVehicle = nil; // The vehicle the group is usin
private _objective = nil; // The objective for the group

// Creat the units
br_fnc_createBombUnits = {
	_transportVehicle = (selectrandom _vehicleChance) createVehicle getMarkerPos _spawnPad;
	[_transportVehicle] call fn_addToZeus;
	// Delete if existing group
	//_objectiveGroup = [WEST, _types select 0, _types select 2, _types select 1, selectrandom _unitChance, getMarkerPos _spawnPad] call fn_spawnGroup;
	while {{(alive _x)} count (units _objectiveGroup) == 0} do {
		_rNumber = floor (random ((count _unitChance) + (count br_custom_unit_compositions_friendly) + br_custom_units_chosen_offset));
		if (((count _unitChance) != 0) && (_rNumber <= (count _unitChance))) then {
			_objectiveGroup = [WEST, br_unit_type_compositions_friendly select 0, br_unit_type_compositions_friendly select 2, br_unit_type_compositions_friendly select 1, _unitChance, getMarkerPos _spawnPad, []] call fn_selectRandomGroupToSpawn;
		} else {
			_objectiveGroup = [getMarkerPos _spawnPad, WEST, selectrandom br_custom_unit_compositions_friendly] call BIS_fnc_spawnGroup;
		};
	};
	(leader _objectiveGroup) moveInAny _transportVehicle;
	{ if (_x != (leader _objectiveGroup)) then { if (!(_x moveInAny _transportVehicle)) then { deleteVehicle _x; }; }; } forEach (units _objectiveGroup);
	// Give each unit a sactelCharge
	{ 
		_oldPack = unitBackpack _x; removeBackpack _x; deleteVehicle _oldPack;
		_x addBackpack "B_Carryall_ocamo"; _x addMagazines ["SatchelCharge_Remote_Mag", 1];
		_x setBehaviour "SAFE";
		[_x] call fn_objectInitEvents; 
	} forEach (units _objectiveGroup);
	[_transportVehicle, _spawnPad] call fn_setDirectionOfMarker;
	//br_friendly_objective_groups pushBack _objectiveGroup;
	//sleep 5;
	waitUntil { sleep 1; {_x in _transportVehicle} count (units _objectiveGroup) == {(alive _x)} count (units _objectiveGroup) || !(alive _transportVehicle) || {({(alive _x)} count (units _objectiveGroup) == 0)} };
	_transportVehicle setUnloadInCombat [FALSE, FALSE];
	// Wait a second
	sleep 1;
};

// Tell the unit to touchoff the bomb
br_fnc_placeBomb = {
	private _bomb = "satchelcharge_remote_ammo" createVehicle (getpos (_objective select 1));
	_bomb setDamage 1;
	(_objective select 1) setDamage 1;
};

br_near_players = {
	private _nearAPlayer = FALSE;
	{  if (getpos (_objective select 1) distance (getpos _x) < _getOutOfVehicleRadius ) then { _nearAPlayer = TRUE; }; } forEach allPlayers; 
	_nearAPlayer;
};

br_fn_killGivenGroup = {
	private _group = _this select 0;
	timeToComplete = time + 600;
	{
		_wp = _objectiveGroup addWaypoint [getpos _x, 0];
		_wp setWaypointType "DESTROY";
		_wp setWaypointSpeed "FULL";
		waitUntil { sleep 5; ((timeToComplete < time) && !([] call br_near_players)) || !(alive _x) || {({(alive _x)} count (units _objectiveGroup) == 0)}; };
		if (timeToComplete < time) then { _x setDamage 1; }
		call br_fnc_deleteWayPoints;
	} forEach (units _group);
};

// Kill all groups at objective
br_fnc_goKillPeople = {
	private _groups = _this select 0;
	if (count _groups > 0) then {
		{
			[_x] call br_fn_killGivenGroup;
		} forEach (_groups);	
	};
};

// Do the objectives
br_fnc_DoObjective = {
	private _obj = _this select 0;
	switch (_obj) do {
		case "Destory & Kill": { [_objective select 2] call br_fnc_goKillPeople; call br_fnc_placeBomb; };
		case "Destory": { call br_fnc_placeBomb; };
		case "Kill": { [_objective select 2] call br_fnc_goKillPeople; };
		default { hint "Objective Error in command group"};
	};
};

// Find objective
br_fnc_findObjective = {
	private _foundObjective = FALSE;
	// Try find an objective
	while {!_foundObjective} do {
		_objective = selectRandom br_objectives;
		if ( (_objective select 4) ) then { _foundObjective = TRUE; }
		else { sleep 10; };
	};
	_foundObjective
};

// Delete waypoints
br_fnc_deleteWayPoints = {
	while {(count (waypoints _objectiveGroup)) > 0} do {
		deleteWaypoint ((waypoints _objectiveGroup) select 0);
	};
};

// AI script for the group
br_fnc_runRadioBombUnit = {
	call br_fnc_createBombUnits;
	while {TRUE} do {
		waitUntil { sleep 5; !br_zone_taken && {count br_objectives > 0} || {(alive _x)} count (units _objectiveGroup) == 0 || !(alive _transportVehicle)};
		// Find a objective
		call br_fnc_findObjective;
		missionNamespace setVariable [(format ["br_objective_%1", _objective select 0]), FALSE];
		// Get position to exit vehicle
		if (br_friendlies_use_transport) then {
			br_friendly_objective_groups pushBack _objectiveGroup;
			private _getPos = [getpos (_objective select 1), _getOutOfVehicleRadius, 50, 1, 0, 60, 0] call BIS_fnc_findSafePos;
			while {count _getPos > 2} do {
				_getPos = [getpos (_objective select 1), 0, 50, 1, 0, 60, 0] call BIS_fnc_findSafePos;
				sleep 0.1;
			};
			private _wp = _objectiveGroup addWaypoint [_getPos, 0];
			_wp setWaypointType "GETOUT";
			_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
			// Wait until group is within a given range
			waitUntil { sleep 5; (count (waypoints _objectiveGroup)) == 0 || missionNamespace getVariable (_objective select 5) || (missionNamespace getVariable (format ["br_objective_%1", _objective select 0])) || !(alive _transportVehicle) || {(alive _x)} count (units _objectiveGroup) == 0};
			_transportVehicle setUnloadInCombat [TRUE, TRUE];
			call br_fnc_deleteWayPoints;
		} else {
			[_transportVehicle, FALSE] call fn_ejectUnits;
			call br_fnc_deleteWayPoints;
		};
		// Tell group to get out of transport vehicle
		if (!(missionNamespace getVariable (_objective select 5))) then {
			//{[_x] allowGetIn false; unassignVehicle _x; _x action ["Eject", _transportVehicle]; _x action ["GetOut", _transportVehicle];} forEach (crew _transportVehicle);
			waitUntil { sleep 2; missionNamespace getVariable (_objective select 5) || (missionNamespace getVariable (format ["br_objective_%1", _objective select 0])) || ({_x in _transportVehicle} count (units _objectiveGroup) == 0) || {(alive _x)} count (units _objectiveGroup) == 0 };
			// Move the units to the objective
			private _getPos = [getpos (_objective select 1), 0, 50, 1, 0, 60, 0] call BIS_fnc_findSafePos;
			while {count _getPos > 2} do {
				_getPos = [getpos (_objective select 1), 0, 50, 1, 0, 60, 0] call BIS_fnc_findSafePos;
				sleep 0.1;
			};
			private _wp = _objectiveGroup addWaypoint [_getPos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointBehaviour "AWARE";
			_wp setWaypointStatements ["true",(format ["deleteWaypoint [group this, currentWaypoint (group this)]; br_objective_%1 = TRUE;", _objective select 0])];
			timeToComplete = time + 600;
			waitUntil { sleep 2; ((timeToComplete < time) && !([] call br_near_players)) || missionNamespace getVariable (_objective select 5) || (missionNamespace getVariable (format ["br_objective_%1", _objective select 0])) || {(alive _x)} count (units _objectiveGroup) == 0; };
			// Check if objective is not completed
			if (!(missionNamespace getVariable (_objective select 5)) && (missionNamespace getVariable (format ["br_objective_%1", _objective select 0]))) then { 	
				// Wait untill group has reached radio tower
				waitUntil { sleep 1; (((timeToComplete < time) && !([] call br_near_players)) || (missionNamespace getVariable (format ["br_objective_%1", _objective select 0])) || missionNamespace getVariable (_objective select 5) || {(alive _x)} count (units _objectiveGroup) == 0); };
				// Touch off bomb at radio tower if still alive and radio tower not already blown up
				if (({(alive _x)} count (units _objectiveGroup) > 0) && {!(missionNamespace getVariable (_objective select 5))} && {(missionNamespace getVariable (format ["br_objective_%1", _objective select 0]))}) then 
				{ 
					[(_objective select 3)] call br_fnc_DoObjective; 
				};	
			};
		};
		if (count br_objectives == 0 || ({(alive _x)} count (units _objectiveGroup) == 0)) then {
			{ deleteVehicle _x; } forEach (units _objectiveGroup);
			deleteVehicle _transportVehicle;
			deleteGroup _objectiveGroup;
			br_friendly_objective_groups deleteAt (br_friendly_objective_groups find _objectiveGroup);
			call br_fnc_createBombUnits;
		};
		call br_fnc_deleteWayPoints;
	};
};

[] call br_fnc_runRadioBombUnit;