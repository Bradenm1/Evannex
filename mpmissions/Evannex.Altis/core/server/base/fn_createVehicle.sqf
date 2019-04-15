private _attackVehicleGroup = nil; // The group in the vehicle
private _attackVehicle = nil; // The vehicle
private _spawnPad = _this select 0; // The spawnpad for it
private _unitChance = _this select 1;

// Spawn custom units
br_fnc_createAttackVehicle = {
	// Select a random unit from the above list to spawn
	_attackVehicle = (selectrandom _unitChance) createVehicle (getMarkerPos _spawnPad);
	// Create its crew
	createVehicleCrew _attackVehicle;
	// Get the vehicle commander
	private _commander = driver _attackVehicle;
	// Get the group from the commander
	private _temp = group _commander;
	// If vehicle is another faction it can spawn people on the wrong side, we need them to be on our side.
	_attackVehicleGroup = createGroup WEST;
	(units _temp) joinSilent _attackVehicleGroup;
	[_attackVehicleGroup, _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";
	{ _x setBehaviour "AWARE"; _x setSkill br_ai_skill; } forEach (units _attackVehicleGroup);
	// Apply the zone AI to the vehicle
	br_friendly_ai_groups pushBack _attackVehicleGroup;
	br_friendly_vehicles pushBack _attackVehicleGroup;
};

// run the vehicle
br_fnc_runVehicleUnit = {
	while {True} do {
		// Spawn vehicle
		[] call br_fnc_createAttackVehicle;
		// Wait untill they die
		waituntil{ sleep 5; ({(alive _x)} count (units _attackVehicleGroup) < 1) || (!alive _attackVehicle) || (fuel _attackVehicle == 0)};
		// Do some cleanup cause they died
		if (!alive _attackVehicle && fuel _attackVehicle == 0) then { deleteVehicle _attackVehicle; } else { br_empty_vehicles_in_garbage_collection pushBack _attackVehicle; };
		br_friendly_ai_groups deleteAt (br_friendly_ai_groups find _attackVehicleGroup);
		br_friendly_vehicles deleteAt (br_friendly_vehicles find _attackVehicleGroup);
		deleteGroup _attackVehicleGroup;
		//deleteVehicle _attackVehicle;
	};
};

[] call br_fnc_runVehicleUnit;