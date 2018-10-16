_vehicleGroup = nil; // The group in the vehicle
_vehicle = nil; // The vehicle
_spawnPad = _this select 0; // The spawnpad for it
_unitChance = _this select 1;

// Spawn custom units
br_fnc_createVehicleUnit = {
	// Select a random unit from the above list to spawn
	_vehicle = (selectrandom _unitChance) createVehicle (getMarkerPos _spawnPad);
	// Create its crew
	createVehicleCrew _vehicle;
	// Get the vehicle commander
	_commander = driver _vehicle;
	// Get the group from the commander
	_temp = group _commander;
	// If vehicle is another faction it can spawn people on the wrong side, we need them to be on our side.
	_vehicleGroup = createGroup WEST;
	(units _temp) joinSilent _vehicleGroup;
	[_vehicleGroup, _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";
	{ _x setBehaviour "SAFE"; _x setSkill br_ai_skill; } forEach (units _vehicleGroup);
	// Apply the zone AI to the vehicle
	br_friendly_ai_groups append [_vehicleGroup];
	br_friendly_vehicles append [_vehicleGroup];
};

// run the vehicle
br_fnc_runVehicleUnit = {
	while {True} do {
		// Spawn vehicle
		[] call br_fnc_createVehicleUnit;
		// Wait untill they die
		waituntil{({(alive _x)} count (units _vehicleGroup) < 1) || (!alive _vehicle)};
		// Do some cleanup cause they died
		if (!alive _vehicle) then { deleteVehicle _vehicle; } else { br_empty_vehicles_in_garbage_collection append [_vehicle]; };
		//br_friendly_ai_groups deleteAt (br_friendly_ai_groups find _vehicleGroup);
		br_friendly_vehicles deleteAt (br_friendly_vehicles find _vehicleGroup);
		deleteGroup _vehicleGroup; 
	};
};

[] call br_fnc_runVehicleUnit;