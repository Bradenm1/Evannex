private _attackVehicleGroup = nil; // The group in the vehicle
private _attackVehicle = nil; // The vehicle
private _spawnPad = _this select 0; // The spawnpad for it
private _unitChance = _this select 1;

// Spawn custom units
br_fnc_createAttackVehicle = {
	// Select a random unit from the above list to spawn
	_attackVehicle = (selectrandom _unitChance) createVehicle (getMarkerPos _spawnPad);
	//_attackVehicleGroup = [_attackVehicle] call fn_createVehicleCrew;
	// Create its crew
	createVehicleCrew _attackVehicle;
	// If vehicle is another faction it can spawn people on the wrong side, we need them to be on our side.
	_attackVehicleGroup = createGroup WEST;
	(units (group ((crew _attackVehicle) select 0))) joinSilent _attackVehicleGroup;
	{ 
		[_x] call fn_objectInitEvents; 
	} forEach crew _attackVehicle + units _attackVehicleGroup;
	[_attackVehicle] call fn_objectInitEvents;
	[_attackVehicleGroup, _spawnPad] call fn_setDirectionOfMarker;
	// Apply the zone AI to the vehicle
	br_friendly_ai_groups pushBack _attackVehicleGroup;
	br_friendly_vehicles pushBack _attackVehicleGroup;
	//br_headquarters sideChat format ["%1 - Ready for action!", getText (configFile >>  "CfgVehicles" >> typeof (Vehicle (leader _attackVehicleGroup)) >> "displayName")]
};

// What to do if the vehicle is dead but some units controlling the vehicle are alive
br_fnc_noVehicle = {
	while {(count (waypoints _attackVehicleGroup)) > 0} do {
		deleteWaypoint ((waypoints _attackVehicleGroup) select 0);
	};
	br_friendly_ai_groups pushBack _attackVehicleGroup;
};

// run the vehicle
br_fnc_runVehicleUnit = {
	while {True} do {
		// Spawn vehicle
		[] call br_fnc_createAttackVehicle;
		// Wait untill they die
		waituntil{ sleep 5; ({(alive _x)} count (units _attackVehicleGroup) == 0) || (!alive _attackVehicle) || (fuel _attackVehicle == 0)};
		// Do some cleanup cause they died
		if (!alive _attackVehicle && fuel _attackVehicle == 0) then { deleteVehicle _attackVehicle; } else { br_empty_vehicles_in_garbage_collection pushBack _attackVehicle; };
		if (({(alive _x)} count (units _attackVehicleGroup) < 1)) then 
		{ 
			br_friendly_ai_groups deleteAt (br_friendly_ai_groups find _attackVehicleGroup); 
		} else {
			// What to do if the units are alive somehow
			call br_fnc_noVehicle;
		};
		br_friendly_vehicles deleteAt (br_friendly_vehicles find _attackVehicleGroup);
		deleteGroup _attackVehicleGroup;
	};
};

[] call br_fnc_runVehicleUnit;