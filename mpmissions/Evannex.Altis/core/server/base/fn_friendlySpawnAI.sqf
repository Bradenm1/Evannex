private _unitChance = _this select 0;
private _aiSpawnRate = 1; // Delay in seconds
private _allSpawnedDelay = 10; // Seconds to wait untill checking if any groups died

br_fnc_spawnFriendlyAI = {
	while {True} do {
		// Spawn AI untill reached limit
		while {((count br_friendly_ground_groups)  < br_min_friendly_ai_groups)} do {
			private _group = nil;
			_rNumber = floor (random ((count _unitChance) + (count br_custom_unit_compositions_friendly) + br_custom_units_chosen_offset));
			if (((count _unitChance) != 0) && (_rNumber <= (count _unitChance))) then {
				_group = [WEST, br_unit_type_compositions_friendly select 0, br_unit_type_compositions_friendly select 2, br_unit_type_compositions_friendly select 1, _unitChance, call fn_getGroundUnitsLocation, call br_fnc_setInitCommandGroup] call fn_selectRandomGroupToSpawn;
			} else {
				_group = [call fn_getGroundUnitsLocation, WEST, selectrandom br_custom_unit_compositions_friendly] call BIS_fnc_spawnGroup;
				(call br_fnc_setInitCommandGroup) pushback _group;
			};
			{ 
				[_x] call fn_objectInitEvents; 
			} forEach units _group;
			// Now split the groups
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
						(call br_fnc_setInitCommandGroup) pushback _tempGroup;
						_group = _x;
						_tempDidSplit = TRUE;
					};
				} forEach (_splitGroups);
				_splitGroups = _splitGroupsTemp;
				if (!_tempDidSplit) then { breakOut "split" };
			};
			sleep _aiSpawnRate;		
		};
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

// Sets the init commanding group
br_fnc_setInitCommandGroup = {
	if (br_friendlies_use_transport) then {
		br_friendly_groups_waiting;
	} else {
		br_friendly_ground_on_foot_to_zone;
	};
};

[] call br_fnc_spawnFriendlyAI;