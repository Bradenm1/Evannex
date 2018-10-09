_zoneName = _this select 0; // Has to be unique mission will have issues if not
_zoneRadius = _this select 1; // Radius of the zone
_objectToUse = _this select 2; // Object to use such as a building or vehicle
_objective = _this select 3; // The objective type
_deleteMarkerOnCapture = _this select 4; // If the marker is deleted on capture
_textOnTaken = _this select 5; // Text when object is completed
_groupsIfKill = _this select 6; // units to spawn at objective
_mattersToObjectiveSquad = _this select 7; // If the friendly AI will ignore this objective
_requiresCompletedToCaptureZone = _this select 8; // If the capture of the main zone requires the capture of this zone

_spawnedObj = nil;
_groupsToKill = []; // Groups spawned at objective
_radiusName = format ["ZONE_%1_RADIUS", _zoneName];
_textName = format ["ZONE_%1_ICON", _zoneName];
_zoneVarName = format ["br_%1", _zoneName]; // Used to check if objective has been completed outside this local script

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
		_group = [createGroup EAST, 1, getpos _spawnedObj, [_x]] call br_fnc_spawnGivenUnitsAt;
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
		default { hint "Objective Error: " + _zoneName};
	};
};

// Delete markers
br_fnc_deleteObjMarkers = {
	deleteMarker _radiusName; deleteMarker _textName;
};

// Creates the Objective
br_fnc_createObjective = {
	missionNamespace setVariable [_zoneVarName, FALSE];
	// Creates center for HQ
	_newPos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 20, 0, br_objective_max_angle, 0] call BIS_fnc_findSafePos;
	// Gets position near center
	_pos = [_newPos, 0, _zoneRadius * sqrt random 360, 20, 0, 20, 0] call BIS_fnc_findSafePos;
	// Place HQ near center
	_spawnedObj = _objectToUse createVehicle _pos;
	// Creates the radius
	[_radiusName, _newPos, _zoneRadius, 360, "ColorRed", _radiusName, 0.3] call (compile preProcessFile "core\server\markers\fn_createRadiusMarker.sqf");
	// Create text icon
	[_textName, _newPos, _zoneName, "ColorBlue"] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
	br_objectives append [[_zoneName, _spawnedObj, _groupsToKill, _objective, _mattersToObjectiveSquad, _zoneVarName, _requiresCompletedToCaptureZone]];
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

	// Wait untill main zone is taken
	waitUntil { br_zone_taken };

	[] call br_fnc_onZoneTakenAfterComplete;
};

// When zone is taken after 
br_fnc_onZoneTakenAfterComplete = {
	// Do some cleanup
	[] call br_fnc_deleteObjMarkers;
	sleep 120;
	deleteVehicle _spawnedObj;
};

[] call br_fnc_createObjective;