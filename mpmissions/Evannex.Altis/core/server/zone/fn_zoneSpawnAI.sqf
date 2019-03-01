_spawningMarker = _this select 0; // The marker which spawns the AI if active
_unitChance = _this select 1; // The list of units that have a chance to spawn

_aiSpawnRate = 0; // Delay in seconds
_allSpawnedDelay = 30; // Seconds to wait untill checking if any groups died
_currentGarrisons = 0;
_tempbr_min_ai_groups = 0;

_unitTypes = ["Infantry"];

// Gets a safe zone within the zone
br_fnc_getGroupEnemySpawn = {
	[getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 5, 0, 60, 0] call BIS_fnc_findSafePos;
};

// Spawn given units at a certain location
br_fnc_spawnGivenUnitsAt = {
	// Getting the params
	_group = _this select 0;
	_spawnAmount = _this select 1;
	_position = _this select 2;
	_groupunits = _this select 3;
	_vectorAdd = _this select 4; // Adds to the spawn position each spawn, allows vehicles to not spawn inside one another...
	// Number AI to spawn
	for "_i" from 1 to _spawnAmount do  {
		{
			// Create and return the AI(s) group
			_tempGroup = [_position, side _group, [_x],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
			// Place the AI(s) in that group into another group
			units _tempGroup join _group;
			//_position = _position vectorAdd _vectorAdd;
		} foreach _groupunits;
	};
	_group;
};

// Gets a position near no players
br_fnc_getPositionNearNoPlayersAtZone = {
	_newPos = nil;
	_aroundnoPlayers = TRUE;
	_distance = br_spawn_enemy_to_player_dis;
	while {_aroundNoPlayers} do {
		_newPos = [] call br_fnc_getGroupEnemySpawn;
		_nearAPlayer = FALSE;
		{  if (_newPos distance (getpos _x) < _distance ) then { _nearAPlayer = TRUE; }; } forEach allPlayers; 
		if (_nearAPlayer) then { _aroundNoPlayers = TRUE; } else { _aroundNoPlayers = FALSE; };
		_distance = _distance - 15;
	};
	_newPos;
};

// run main
br_fnc_spawnAI = {
	_tempbr_min_ai_groups = br_min_ai_groups;
	while {!br_zone_taken} do {
		// Spawn AI untill reached limit
		while {(count br_ai_groups <= br_min_ai_groups) && {(getMarkerColor _spawningMarker == "ColorRed")}} do {
			//sleep _aiSpawnRate;
			_newPos = [] call br_fnc_getPositionNearNoPlayersAtZone;
			_group = [br_sides, 0, _unitTypes, br_side_types, br_units, _newPos, br_ai_groups] call compile preprocessFileLineNumbers "core\server\functions\fn_selectRandomGroupToSpawn.sqf";
			[_group] call compile preprocessFileLineNumbers "core\server\functions\fn_setRandomDirection.sqf";
			if (_currentGarrisons < br_max_garrisons) then {
				_completed = [leader _group, "ZONE_RADIUS", br_zone_radius * sqrt br_max_radius_distance] call SBGF_fnc_groupGarrison;
				if (_completed) then {  
					{ 
						_x disableAI "PATH"; 
						_tempGroup = createGroup EAST;
						[_x] joinSilent _tempGroup;
						br_ai_groups append [_tempGroup];
						br_groups_in_buildings append [_tempGroup];
					} forEach (units _group);
					_currentGarrisons = _currentGarrisons + 1;
					br_min_ai_groups = br_min_ai_groups + 1;
				};
			};
			sleep 0.01;
		};
		// Spawn spawn special units untill 
		while {(count br_special_ai_groups <= br_min_special_groups) && {(getMarkerColor _spawningMarker == "ColorRed")}} do {
			_newPos = [] call br_fnc_getPositionNearNoPlayersAtZone;
			_group = [createGroup EAST, 1, _newPos, [selectRandom _unitChance], 1, [0,0,0]] call br_fnc_spawnGivenUnitsAt;
			[_group] call compile preprocessFileLineNumbers "core\server\functions\fn_setRandomDirection.sqf";
			{ _x setSkill br_ai_skill; } forEach (units _group);
			// Add all vehicles in the group to a list
			{  
				_vehicle = (vehicle _x);
				// Check if vehicle is null
				if (!(isNull _vehicle)) then {
					br_enemy_vehicle_objects append [_vehicle];
				};
			} forEach (units _group);
			br_special_ai_groups append [_group];
			br_ai_groups append [_group];
			sleep 0.01;
		};
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
	br_min_ai_groups = _tempbr_min_ai_groups;
};

[] call br_fnc_spawnAI;