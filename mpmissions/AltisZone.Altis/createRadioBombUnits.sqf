_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died
touchOffBomb = FALSE;
_bombGroup = nil;

// Creat the units
createBombUnits = {
	// Delete if existing group
	_bombGroup = [WEST, "BLU_F", "Infantry", "BUS_InfAssault", [] call getLocation] call compile preprocessFileLineNumbers "functions\spawnGroup.sqf";
	// Give each unit a sactelCharge
	{ _x addBackpack "B_Carryall_ocamo"; _x addMagazines ["SatchelCharge_Remote_Mag", 1]; } forEach (units _bombGroup);
	br_friendlyRadioBombers append [_bombGroup];
};

// Tell the unit to place and touchoff the bomb
placeBomb = {
	//_unitToPlaceBomb = (leader _bombGroup);
	//_unitToPlaceBomb fire ["pipebombmuzzle", "pipebombmuzzle", "SatchelCharge_Remote_Mag"];
	//_unitToPlaceBomb action ["TOUCHOFF", _unitToPlaceBomb];
	_bomb = "satchelcharge_remote_ammo" createVehicle getPos br_radio_tower;
	_bomb setDamage 1;
};

runRaidoBombUnit = {
	while {br_radio_tower_destoryed == 0} do {
		[] call createBombUnits;
		// Check if units inside chopper are dead
		while {({(alive _x)} count (units _bombGroup) > 0) && (br_radio_tower_destoryed == 0)} do {
			// Check if any groups are waiting
			_wp = _bombGroup addWaypoint [getpos br_radio_tower, 0];
			_wp setWaypointFormation "WEDGE";
			_wp setWaypointType "MOVE";
			_wp setWaypointSpeed "FULL";
			_wp setWaypointStatements ["true", "touchOffBomb = TRUE;"];
			waitUntil { (touchOffBomb && br_radio_tower_destoryed == 0); };
			[] call placeBomb;
			//sleep 10;
		};
		//{ deleteVehicle _x; } forEach (units _bombGroup);
		//deleteGroup _bombGroup;
		br_friendlyRadioBombers deleteAt (br_friendlyRadioBombers find _bombGroup);
	};
	//{ deleteVehicle _x; } forEach (units _bombGroup);
	//deleteGroup _bombGroup;
	br_AIGroups append [_bombGroup];
	br_friendlyRadioBombers deleteAt (br_friendlyRadioBombers find _bombGroup);
};

[] call runRaidoBombUnit;