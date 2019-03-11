private _spawnPad = _this select 0; // The position where the AI will spawn
private _bombIndex = _this select 1; // Index when created
private _allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died
private _objectiveGroup = nil; // The unit group
private _transportVehicle = nil; // The vehicle the group is using
private _getOutOfVehicleRadius = 400; // Range from objective to eject vehicle
private _objective = nil; // The objective for the group

// Creat the units
br_fnc_createBombUnits = {
	_transportVehicle = "B_G_Van_01_transport_F" createVehicle getMarkerPos _spawnPad;
	// Delete if existing group
	_objectiveGroup = [WEST, "BLU_F", "Infantry", "BUS_InfAssault", getMarkerPos _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_spawnGroup.sqf";
	(leader _objectiveGroup) moveInDriver _transportVehicle;
	{ if (_x != (leader _objectiveGroup)) then { _x assignAsCargo _transportVehicle; (leader _objectiveGroup); _x moveInCargo _transportVehicle; }; } forEach (units _objectiveGroup);
	// Give each unit a sactelCharge
	{ _oldPack = unitBackpack _x; removeBackpack _x; deleteVehicle _oldPack; } forEach (units _objectiveGroup);
	{ _x addBackpack "B_Carryall_ocamo"; _x addMagazines ["SatchelCharge_Remote_Mag", 1]; } forEach (units _objectiveGroup);
	{ _x setBehaviour "SAFE"; } forEach (units _objectiveGroup);
	[_transportVehicle, _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";
	br_friendly_objective_groups append [_objectiveGroup];
	waitUntil { sleep 1; {_x in _transportVehicle} count (units _objectiveGroup) == {(alive _x)} count (units _objectiveGroup) };
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
	private _aroundNoPlayers = FALSE;
	private _nearAPlayer = FALSE;
	{  if (getpos (_objective select 1) distance (getpos _x) < _getOutOfVehicleRadius ) then { _nearAPlayer = TRUE; }; } forEach allPlayers; 
	if (_nearAPlayer) then { _aroundNoPlayers = TRUE; } else { _aroundNoPlayers = FALSE; };
	_aroundNoPlayers;
};

// Kill all groups at objective
br_fnc_goKillPeople = {
	private _groups = _objective select 2;
	timeToComplete = time + 600;
	if (count _groups > 0) then {
		for "_i" from 0 to count _groups do {
			{
				_wp = _objectiveGroup addWaypoint [group _x, 0];
				_wp setWaypointFormation "WEDGE";
				_wp setWaypointType "DESTROY";
				_wp setWaypointSpeed "FULL";
				waitUntil { sleep 5; ((timeToComplete < time) && !([] call br_near_players)) || !(alive _x) };
				_x setDamage 1;
			} forEach (units (_groups select _i));
		};	
	};
};

// Do the objectives
br_fnc_DoObjective = {
	private _obj = _this select 0;
	switch (_obj) do {
		case "Destory & Kill": { call br_fnc_goKillPeople; call br_fnc_placeBomb; };
		case "Destory": { call br_fnc_placeBomb; };
		case "Kill": { call br_fnc_goKillPeople; };
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
	_transportVehicle setUnloadInCombat [FALSE, FALSE];
	while {TRUE} do {
		waitUntil { sleep 5; !br_zone_taken && {count br_objectives > 0}};
		// Find a objective
		[] call br_fnc_findObjective;
		// Idle group if no radio tower
		missionNamespace setVariable [(format ["br_objective_%1", _objective select 0]), FALSE];
		// Check if any groups are waiting
		private _getPos = [getpos (_objective select 1), _getOutOfVehicleRadius, 50, 1, 0, 60, 0] call BIS_fnc_findSafePos;
		private _wp = _objectiveGroup addWaypoint [_getPos, 0];
		_wp setWaypointType "GETOUT";
		_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
		// Wait until group is within a given range
		waitUntil { sleep 5; (count (waypoints _objectiveGroup)) == 0 || missionNamespace getVariable (_objective select 5) || (missionNamespace getVariable (format ["br_objective_%1", _objective select 0])) || {(!alive (driver _transportVehicle))}};
		_transportVehicle setUnloadInCombat [TRUE, TRUE];
		[] call br_fnc_deleteWayPoints;
		// Tell group to get out of transport vehicle
		if (!(missionNamespace getVariable (_objective select 5))) then {
			//{[_x] allowGetIn false; unassignVehicle _x; _x action ["Eject", _transportVehicle]; _x action ["GetOut", _transportVehicle];} forEach (crew _transportVehicle);
			waitUntil { sleep 2; missionNamespace getVariable (_objective select 5) || (missionNamespace getVariable (format ["br_objective_%1", _objective select 0])) || ({_x in _transportVehicle} count (units _objectiveGroup) == 0) };
			private _getPos = [getpos (_objective select 1), 0, 50, 1, 0, 60, 0] call BIS_fnc_findSafePos;
			private _wp = _objectiveGroup addWaypoint [_getPos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointStatements ["true", (format ["br_objective_%1 = TRUE;", _objective select 0])];
			timeToComplete = time + 600;
			waitUntil { sleep 2; ((timeToComplete < time) && !([] call br_near_players)) || missionNamespace getVariable (_objective select 5) || (missionNamespace getVariable (format ["br_objective_%1", _objective select 0])) || {({(alive _x)} count (units _objectiveGroup) == 0)}; };
			// Check if objective is not completed
			if (!(missionNamespace getVariable (_objective select 5)) && (missionNamespace getVariable (format ["br_objective_%1", _objective select 0]))) then { 	
				// Wait untill group has reached radio tower
				waitUntil { sleep 1; (((timeToComplete < time) && !([] call br_near_players)) || (missionNamespace getVariable (format ["br_objective_%1", _objective select 0])) || {missionNamespace getVariable (_objective select 5)} || {({(alive _x)} count (units _objectiveGroup) == 0)}); };
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
			[] call br_fnc_createBombUnits;
			_transportVehicle setUnloadInCombat [FALSE, FALSE];
		};
		[] call br_fnc_deleteWayPoints;
	};
};

[] call br_fnc_runRadioBombUnit;