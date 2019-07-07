private _spawningMarker = _this select 0; // The marker which spawns the AI if active
private _speicalChance = _this select 1; // The list of units that have a chance to spawn
private _unitChance = _this select 2;

private _aiSpawnRate = 0; // Delay in seconds
private _allSpawnedDelay = 30; // Seconds to wait untill checking if any groups died
private _currentGarrisons = 0;

// Gets a safe zone within the zone
br_fnc_getGroupEnemySpawn = {
	[getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 5, 0, 60, 0] call BIS_fnc_findSafePos;
};

// Spawn given units at a certain location
br_fnc_spawnGivenUnitsAt = {
	// Getting the params
	params ["_group", "_spawnAmount","_position", "_groupunits"];
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
	while {!br_zone_taken} do {
		// Spawn AI untill reached limit
		while {(count br_ai_groups <= br_min_ai_groups) && (getMarkerColor _spawningMarker == "ColorRed" || !br_radio_tower_enabled)} do {
			_newPos = [] call br_fnc_getPositionNearNoPlayersAtZone;
			_rNumber = floor (random ((count _unitChance) + (count br_custom_unit_compositions_enemy) + br_custom_units_chosen_offset));
			private _group = nil;
			if (((count _unitChance) != 0) && (_rNumber <= (count _unitChance))) then {
				_group = [EAST, br_unit_type_compositions_enemy select 0, br_unit_type_compositions_enemy select 2, br_unit_type_compositions_enemy select 1, _unitChance, _newPos, br_ai_groups] call fn_selectRandomGroupToSpawn;
			} else {
				_group = [_newPos, EAST, selectrandom br_custom_unit_compositions_enemy] call BIS_fnc_spawnGroup;
				br_ai_groups pushBack _group;
			};
			[_group] call fn_setRandomDirection;
			{ [_x] call fn_objectInitEvents; } forEach units _group;
			if (_currentGarrisons < br_max_garrisons) then {
				private _completed = [leader _group, "ZONE_RADIUS", br_zone_radius * sqrt br_max_radius_distance] call SBGF_fnc_groupGarrison;
				private _tempGroup = createGroup EAST;
				if (_completed) then {  
					{ 
						_x disableAI "PATH"; 
						[_x] joinSilent _tempGroup;
						br_groups_in_buildings append [_tempGroup];
					} forEach (units _group);
					_currentGarrisons = _currentGarrisons + 1;
				};
			};
			sleep 0.5;
		};
		// Spawn spawn special units untill 
		while {(count br_special_ai_groups <= br_min_special_groups) && (getMarkerColor _spawningMarker == "ColorRed" || !br_radio_tower_enabled)} do {
			_newPos = [] call br_fnc_getPositionNearNoPlayersAtZone;
			_group = [createGroup EAST, 1, _newPos, [selectRandom _speicalChance], 1] call br_fnc_spawnGivenUnitsAt;
			[_group] call fn_setRandomDirection;
			{ 
				_x setSkill br_ai_skill; 
				[_x] call fn_setRandomDirection;
			} forEach (units _group);
			br_special_ai_groups pushBack _group;
			br_ai_groups pushBack _group;
			// Add all vehicles in the group to a list
			{  
				_vehicle = (vehicle _x);
				// Check if vehicle is null
				if (!(isNull _vehicle)) then {
					br_enemy_vehicle_objects pushBack _vehicle;
					[_vehicle] call fn_objectInitEvents;
					{ [_x] call fn_objectInitEvents; } forEach (crew _vehicle);
					switch ((_vehicle call BIS_fnc_objectType) select 1) do {
						case "Helicopter";
						case "Plane": { _vehicle setPosASL [getPosASL _vehicle select 0, getPosASL _vehicle select 1, getTerrainHeightASL (position _vehicle) + 100 + random 500]; };
						case "Ship": {  
							private _waterPos = [getMarkerPos "ZONE_RADIUS", 0, (br_zone_radius * 1.8) * sqrt br_max_radius_distance, 5, 2] call BIS_fnc_findSafePos;
							if (count _waterPos != 3 && surfaceIsWater _waterPos) then {
								_vehicle setpos _waterPos;
							} else {
								br_enemy_vehicle_objects deleteAt (br_enemy_vehicle_objects find _vehicle);
								br_special_ai_groups deleteAt (br_special_ai_groups find _group);
								br_ai_groups deleteAt (br_ai_groups find _group);
								deleteVehicle _vehicle;
								[_group] call br_fnc_deleteGroups;
							};
						};
						default {};
					};
				};
			} forEach (units _group);
			sleep 0.01;
		};
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

sleep 1;
[] call br_fnc_spawnAI;