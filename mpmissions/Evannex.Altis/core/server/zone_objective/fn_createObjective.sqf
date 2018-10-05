_zoneName = _this select 0; // Has to be unique mission will have issues if not
_zoneRadius = _this select 1;
_objectToUse = _this select 2;
_objective = _this select 3;
_deleteMarkerOnCapture = _this select 4;
_textOnTaken = _this select 5;
_groupsIfKill = _this select 6;
_mattersToObjectiveSquad = _this select 7;
_requiresCompletedToCaptureZone = _this select 8;

_spawnedObj = nil;
_groupsToKill = [];
_radiusName = format ["ZONE_%1_RADIUS", _zoneName];
_textName = format ["ZONE_%1_ICON", _zoneName];
_zoneVarName = format ["br_%1", _zoneName];

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

// Creates the Objective
br_fnc_createObjective = {
	missionNamespace setVariable [_zoneVarName, FALSE];
	// Creates center for HQ
	//_hqCenterPos = call (compile preprocessFileLineNumbers "functions\getRandomLocation.sqf");
	_newPos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 20, 0, 20, 0] call BIS_fnc_findSafePos;
	// Gets position near center
	_pos = [_newPos, 0, _zoneRadius * sqrt random 360, 20, 0, 20, 0] call BIS_fnc_findSafePos;
	// Place HQ near center
	_spawnedObj = _objectToUse createVehicle _pos;
	// Creates the radius
	[_radiusName, _newPos, _zoneRadius, 360, "ColorRed", _radiusName, 0.3] call (compile preProcessFile "core\server\functions\fn_createRadiusMarker.sqf");
	// Create text icon
	[_textName, _newPos, _zoneName, "ColorBlue"] call (compile preProcessFile "core\server\functions\fn_createTextMarker.sqf");
	br_objectives append [[_zoneName, _spawnedObj, _groupsToKill, _objective, _mattersToObjectiveSquad, _zoneVarName, _requiresCompletedToCaptureZone]];
	[] call br_fnc_DoObjectiveAndWaitTillComplete;
	[] call br_fnc_onTaken;
};

// Called when the HQ is taken
br_fnc_onTaken = {
	["TaskSucceeded",["", _textOnTaken]] call bis_fnc_showNotification;

	if (_deleteMarkerOnCapture) then { deleteMarker _radiusName; deleteMarker _textName; } 
	else { _radiusName setMarkerColor "ColorBlue"; };

	missionNamespace setVariable [_zoneVarName, TRUE]; 
};

[] call br_fnc_createObjective;