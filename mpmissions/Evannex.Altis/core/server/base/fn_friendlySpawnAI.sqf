private _unitChance = _this select 0;
private _aiSpawnRate = 1; // Delay in seconds
private _allSpawnedDelay = 10; // Seconds to wait untill checking if any groups died

br_fnc_spawnFriendlyAI = {
	while {True} do {
		// Spawn AI untill reached limit
		while {((count br_friendly_ground_groups)  < br_min_friendly_ai_groups)} do {
			private _group = nil;
			_rNumber = floor (random ((count _unitChance) + (count br_custom_unit_compositions_friendly) + 0.2));
			if (((count _unitChance) != 0) && (_rNumber <= (count _unitChance))) then {
				_group = [WEST, br_unit_type_compositions_friendly select 0, br_unit_type_compositions_friendly select 2, br_unit_type_compositions_friendly select 1, _unitChance, call compile preprocessFileLineNumbers "core\server\functions\fn_getGroundUnitsLocation.sqf", br_friendly_groups_waiting] call compile preprocessFileLineNumbers "core\server\functions\fn_selectRandomGroupToSpawn.sqf";
			} else {
				_group = [call compile preprocessFileLineNumbers "core\server\functions\fn_getGroundUnitsLocation.sqf", WEST, selectrandom br_custom_unit_compositions_friendly] call BIS_fnc_spawnGroup;
			};
			private _splitGroups = [_group];
			br_friendly_ground_groups pushBack _group;
			scopeName "split";
			while {TRUE} do {
				private _tempDidSplit = FALSE;
				private _splitGroupsTemp = [];
				{
					if (count (units _x) > br_max_friendly_group_size) then {
						private _tempGroup = createGroup WEST;
						[(units _x), 0, (count (units _x) / 2)] call BIS_fnc_subSelect joinSilent _tempGroup;
						_splitGroupsTemp pushBack _tempGroup;
						_splitGroupsTemp pushBack _x;
						br_friendly_ground_groups pushBack _x;
						br_friendly_groups_waiting pushBack _tempGroup;
						_group = _x;
						_tempDidSplit = TRUE;
					};
				} forEach (_splitGroups);
				_splitGroups = _splitGroupsTemp;
				if (!_tempDidSplit) then { breakOut "split" };
			};
			{ 
				br_friendly_ground_groups pushBack _x;
				if (!(_x in br_friendly_groups_waiting)) then {br_friendly_groups_waiting pushBack _x };
			} forEach (_splitGroups);
			sleep _aiSpawnRate;		
		};
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

[] call br_fnc_spawnFriendlyAI;