_uniqueName = _this select 0; // Has to be unique mission will have issues if not
_displayName = _this select 1; // Display Text
_zoneRadius = _this select 2; // Radius of the zone
_objectToUse = _this select 3; // Object to use such as a building or vehicle
_objective = _this select 4; // The objective type
_deleteMarkerOnCapture = _this select 5; // If the marker is deleted on capture
_textOnTaken = _this select 6; // Text when object is completed
_groupsIfKill = _this select 7; // units to spawn at objective
_mattersToObjectiveSquad = _this select 8; // If the friendly AI will ignore this objective
_requiresCompletedToCaptureZone = _this select 9; // If the capture of the main zone requires the capture of this zone
_brushType = _this select 10;
_shapeType = _this select 11;
_position = _this select 12;
_removeOnZoneCompleted = _this select 13;

_spawnedObj = nil;
_objectivePosition = nil;
_objectiveOrigin = nil;
_groupsToKill = []; // Groups spawned at objective
_radiusName = format ["ZONE_%1_RADIUS", _uniqueName];
_textName = format ["ZONE_%1_ICON", _uniqueName];
_zoneVarName = format ["br_%1", _uniqueName]; // Used to check if objective has been completed outside this local script

// Spawn given units at a certain location
br_fnc_spawnGivenUnitsAt = {
	// Getting the params
	_group = _this select 0;
	_spawnAmount = _this select 1;
	_position = _this select 2;
	_groupunits = _this select 3;
	// Number AI to spawn
	for "_i" from 1 to _spawnAmount do  {
		{
			// Create and return the AI(s) group
			_tempGroup = [_position, side _group, [_x],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
			// Place the AI(s) in that group into another group
			units _tempGroup join _group;
		} foreach _groupunits;
	};
	_group;
};

// Spawn group
br_fnc_spawnGroups = {
	{
		_safeSpot = [_objectiveOrigin, 0, _zoneRadius * sqrt random 360, 20, 0, 20, 0] call BIS_fnc_findSafePos;
		_group = [createGroup EAST, 1, _safeSpot, [_x]] call br_fnc_spawnGivenUnitsAt;
		//{ _x setSkill br_ai_skill } forEach units _group;
		[_group] call compile preprocessFileLineNumbers "core\server\functions\fn_setRandomDirection.sqf";
		_groupsToKill append [_group];
	} forEach _groupsIfKill;
};

// Do this and wait untill done
br_fnc_DoObjectiveAndWaitTillComplete = {	
	switch (_objective) do {
		case "Destory & Kill": { call br_fnc_spawnGroups; waitUntil {!alive _spawnedObj}; { _y = _x; waitUntil {({alive _x} count units _y < 1)}; } forEach _groupsToKill};
		case "Destory": { waitUntil {!alive _spawnedObj}};
		case "Kill": { _spawnedObj allowDamage FALSE; call br_fnc_spawnGroups; { _y = _x; waitUntil {({alive _x} count units _y < 1)}; } forEach _groupsToKill};
		default { hint "Objective Error: " + _uniqueName};
	};
};

// Delete markers
br_fnc_deleteObjMarkers = {
	deleteMarker _radiusName; 
	deleteMarker _textName;
};

// Creates the Objective
br_fnc_createObjective = {
	missionNamespace setVariable [_zoneVarName, FALSE];
	// Creates center
	_objectiveOrigin = [_position, 0, br_zone_radius * sqrt br_max_radius_distance, 20, 0, br_objective_max_angle, 0] call BIS_fnc_findSafePos;
	while {count _objectiveOrigin > 2} do {
		_objectiveOrigin = [_position, 0, br_zone_radius * sqrt br_max_radius_distance, 20, 0, br_objective_max_angle, 0] call BIS_fnc_findSafePos;
		sleep 0.1;
	};
	// Gets position near center
	_objectivePosition = [_objectiveOrigin, 0, _zoneRadius * sqrt random 360, 20, 0, 20, 0] call BIS_fnc_findSafePos;
	// Place HQ near center
	_spawnedObj = _objectToUse createVehicle _objectivePosition;
	// Creates the radius
	[_radiusName, _objectiveOrigin, _zoneRadius, 360, "ColorRed", _radiusName, 1, _brushType, _shapeType] call (compile preProcessFile "core\server\markers\fn_createRadiusMarker.sqf");
	// Create text icon
	[_textName, _objectiveOrigin, _displayName, "ColorBlue", 1] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
	br_objectives append [[_uniqueName, _spawnedObj, _groupsToKill, _objective, _mattersToObjectiveSquad, _zoneVarName, _requiresCompletedToCaptureZone, _removeOnZoneCompleted]];
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
	br_objectives deleteAt (br_objectives find [_uniqueName, _spawnedObj, _groupsToKill, _objective, _mattersToObjectiveSquad, _zoneVarName, _requiresCompletedToCaptureZone, _removeOnZoneCompleted]);
	
	if (_removeOnZoneCompleted) then  {
		// Wait untill main zone is taken
		waitUntil { br_zone_taken };
	};

	[] call br_fnc_onZoneTakenAfterComplete;
};

// When zone is taken after 
br_fnc_onZoneTakenAfterComplete = {
	// Do some cleanup
	if (!_deleteMarkerOnCapture) then { [] call br_fnc_deleteObjMarkers; };
	sleep 120;
	deleteVehicle _spawnedObj;
};

[] call br_fnc_createObjective;