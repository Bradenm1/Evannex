private _uniqueName = _this select 0; // Has to be unique mission will have issues if not
private _displayName = _this select 1; // Display Text
private _zoneRadius = _this select 2; // Radius of the zone
private _objectToUse = _this select 3; // Object to use such as a building or vehicle
private _objective = _this select 4; // The objective type
private _deleteMarkerOnCapture = _this select 5; // If the marker is deleted on capture
private _textOnTaken = _this select 6; // Text when object is completed
private _groupsIfKill = _this select 7; // units to spawn at objective
private _mattersToObjectiveSquad = _this select 8; // If the friendly AI will ignore this objective
private _requiresCompletedToCaptureZone = _this select 9; // If the capture of the main zone requires the capture of this zone
private _brushType = _this select 10;
private _shapeType = _this select 11;
private _position = _this select 12;
private _removeOnZoneCompleted = _this select 13;
private _aiStates = _this select 14;
private _garrison = _this select 15;

private _spawnedObj = nil;
private _objectivePosition = nil;
private _objectiveOrigin = nil;
private _groupsToKill = []; // Groups spawned at objective
private _radiusName = format ["ZONE_%1_RADIUS", _uniqueName];
private _textName = format ["ZONE_%1_ICON", _uniqueName];
private _zoneVarName = format ["br_%1", _uniqueName]; // Used to check if objective has been completed outside this local script
private _objectiveLocation = format ["ZONE_%1_OBJ", _uniqueName];
private _objects = [];

// Spawn given units at a certain location
br_fnc_spawnGivenUnitsAt = {
	// Getting the params
	private _group = _this select 0;
	private _spawnAmount = _this select 1;
	private _position = _this select 2;
	private _groupunits = _this select 3;
	// Number AI to spawn
	for "_i" from 1 to _spawnAmount do  {
		{
			// Create and return the AI(s) group
			private _tempGroup = [_position, side _group, [_x],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
			// Place the AI(s) in that group into another group
			units _tempGroup join _group;
		} foreach _groupunits;
	};
	_group;
};

br_ai_state = {
	private _group = _this select 0;
	private _state = _this select 1;
	private _desure = _this select 2;

	{
		if (_desure) then {
			_x enableAI _state; 
		} else {
			_x disableAI _state; 
		}; 
	} forEach (units _group);
};

br_set_states = {
	private _group = _this select 0;
	{ 
		[_group, _x select 0, _x select 1] call br_ai_state;
	} forEach _aiStates;
};

// Spawn group
br_fnc_spawnGroups = {
	{
		private  _safeSpot = [_objectiveOrigin, 0, _zoneRadius * sqrt random 360, 20, 0, 20, 0] call BIS_fnc_findSafePos;
		_group = [createGroup EAST, 1, _safeSpot, [_x]] call br_fnc_spawnGivenUnitsAt;
		//{ _x setSkill br_ai_skill } forEach units _group;
		[_group] call compile preprocessFileLineNumbers "core\server\functions\fn_setRandomDirection.sqf";
		_groupsToKill append [_group];
		if (_garrison) then { _garrison = [leader _group, _objectiveLocation, 100] call SBGF_fnc_groupGarrison; };
		if (!_garrison) then { [_group, _safeSpot, _zoneRadius] execVM "core\server\zone_objective\fn_groupRoam.sqf"; };
		[_group] call br_set_states;
	} forEach _groupsIfKill;
};

// Do this and wait untill done
br_fnc_DoObjectiveAndWaitTillComplete = {	
	switch (_objective) do {
		case "Destory & Kill": { call br_fnc_spawnGroups; { waitUntil { sleep 1; !alive _x} } foreach _objects; { _y = _x; waitUntil { sleep 1; ({alive _x} count units _y < 1)}; } forEach _groupsToKill};
		case "Destory": { { sleep 5; waitUntil { sleep 1; !alive _x} } foreach _objects; };
		case "Kill": { { _x allowDamage FALSE; } foreach _objects; call br_fnc_spawnGroups; { _y = _x; waitUntil { sleep 1; ({alive _x} count units _y < 1)}; } forEach _groupsToKill};
		default { hint "Objective Error: " + _uniqueName};
	};
};

// Delete markers
br_fnc_deleteObjMarkers = {
	deleteMarker _radiusName; 
	deleteMarker _textName;
	deleteMarker _objectiveLocation;
};

br_set_composition = {
	private _source = _this select 0;
	private _composition = _this select 1;

	{
		private _type = _x select 0;
		private _offset = _x select 1;
		private _newDir = _x select 2;
		private _obj = createVehicle [_type, [0,0,1], [], 0, "CAN_COLLIDE"];
		_objects append [_obj];
		[_source, _obj, _offset, _newDir] call BIS_fnc_relPosObject;
		_obj setPosASL [getPos _obj select 0, getPos _obj select 1, getTerrainHeightASL getPos _obj];
		_obj setVectorUp (surfaceNormal (getPosATL _obj));
	} forEach _composition;
};

// Creates the Objective
br_fnc_createObjective = {
	missionNamespace setVariable [_zoneVarName, FALSE];
	// Creates center
	private _maxGrad = 20;
	_objectiveOrigin = [];
	while {count _objectiveOrigin < 2} do {
		_objectiveOrigin = [_position, 0, br_zone_radius * sqrt br_max_radius_distance, _maxGrad, 0, br_objective_max_angle, 0] call BIS_fnc_findSafePos;
		_maxGrad = _maxGrad + 1;
		sleep 0.1;
	};
	// Gets position near center
	_objectivePosition = [_objectiveOrigin, 0, _zoneRadius * sqrt random 360, 20, 0, 10, 0] call BIS_fnc_findSafePos;
	// Place near center
	_spawnedObj = "Land_LampAirport_F" createVehicle _objectivePosition;
	_spawnedObj hideObjectGlobal true;
	_spawnedObj enableSimulationGlobal false;
	if (count _objectToUse != 0) then { [_spawnedObj, _objectToUse] call br_set_composition; };
	// Creates the radius
	[_radiusName, _objectiveOrigin, _zoneRadius, 360, "ColorRed", _radiusName, 1, _brushType, _shapeType] call (compile preProcessFile "core\server\markers\fn_createRadiusMarker.sqf");
	// Create text icon
	[_textName, _objectiveOrigin, _displayName, "ColorBlue", 1] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
	[_objectiveLocation, _objectivePosition, "", "ColorBlue", 0] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
	br_objectives append [[_uniqueName, _spawnedObj, _groupsToKill, _objective, _mattersToObjectiveSquad, _zoneVarName, _requiresCompletedToCaptureZone, _removeOnZoneCompleted, _objectiveOrigin, _zoneRadius]];
	// Wait untill objective is completed
	[] call br_fnc_DoObjectiveAndWaitTillComplete;
	// Take the objective
	[] call br_fnc_onTaken;
};

// Called when the objective is taken
br_fnc_onTaken = {
	[[[_textOnTaken],"core\client\task\fn_completeObjective.sqf"],"BIS_fnc_execVM",true,true] call BIS_fnc_MP;

	if (_deleteMarkerOnCapture) then { [] call br_fnc_deleteObjMarkers; } 
	else { _radiusName setMarkerColor "ColorBlue"; };

	// Set objective as taken
	missionNamespace setVariable [_zoneVarName, TRUE]; 
	br_objectives deleteAt (br_objectives find [_uniqueName, _spawnedObj, _groupsToKill, _objective, _mattersToObjectiveSquad, _zoneVarName, _requiresCompletedToCaptureZone, _removeOnZoneCompleted, _objectiveOrigin, _zoneRadius]);
	
	if (_removeOnZoneCompleted) then  {
		// Wait untill main zone is taken
		waitUntil { sleep 2; br_zone_taken };
	};

	[] call br_fnc_onZoneTakenAfterComplete;
};

// When zone is taken after 
br_fnc_onZoneTakenAfterComplete = {
	// Do some cleanup
	if (!_deleteMarkerOnCapture) then { [] call br_fnc_deleteObjMarkers; };
	sleep 120;
	{ deleteVehicle _x } foreach _objects;
	deleteVehicle _spawnedObj;
};

[] call br_fnc_createObjective;