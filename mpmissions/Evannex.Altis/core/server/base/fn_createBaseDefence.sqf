private _vehicle = nil; // The vehicle
private _spawnPad = _this select 0; // The spawnpad for it
private _unitChance = _this select 1;

// Spawn custom units
br_fnc_createDefence = {
	// Select a random unit from the above list to spawn
	_vehicle = (selectrandom _unitChance) createVehicle (getMarkerPos _spawnPad);
	// Create its crew
	createVehicleCrew _vehicle;
	// Get the vehicle commander
	private _commander = driver _vehicle;
	// Get the group from the commander
	private _temp = group _commander;
	// If vehicle is another faction it can spawn people on the wrong side, we need them to be on our side.
	_group = createGroup WEST;
	(units _temp) joinSilent _group;
	_vehicle setDir (markerDir _spawnPad);
	{ _x setBehaviour "AWARE"; _x setSkill br_ai_skill; _x disableAI "PATH"; } forEach (units _group);
	// Apply the zone AI to the vehicle
	br_base_defences append [_vehicle];
};

br_fnc_runDefence = {
	while {True} do {
		// Spawn vehicle
		call br_fnc_createDefence;
		// Apply a refill ammo script as to not allow the machines to run out of ammo
		[_vehicle] execVM "core\server\functions\fn_refillDefenceAmmo.sqf";
		// Wait untill it dies
		waituntil{ sleep 25; (!alive _vehicle)};
		br_base_defences deleteAt (br_base_defences find _vehicle);
		// Do some cleanup cause it died
		deleteVehicle _vehicle;
	};
};

call br_fnc_runDefence;