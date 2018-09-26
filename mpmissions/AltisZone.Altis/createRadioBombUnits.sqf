_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died
touchOffBomb = FALSE;
_bombGroup = nil;
_spawnPad = _this select 0;
_bombIndex = _this select 1;
_transportVech = nil;

// Creat the units
createBombUnits = {
	_transportVech = "B_G_Van_01_transport_F" createVehicle getMarkerPos _spawnPad;
	// Delete if existing group
	_bombGroup = [WEST, "BLU_F", "Infantry", "BUS_InfAssault", getMarkerPos _spawnPad] call compile preprocessFileLineNumbers "functions\spawnGroup.sqf";
	(leader _bombGroup) moveInDriver _transportVech;
	{ if (_x != (leader _bombGroup)) then { _x assignAsCargo _transportVech; [_x] orderGetIn true; }; } forEach (units _bombGroup);
	// Give each unit a sactelCharge
	{ _x addBackpack "B_Carryall_ocamo"; _x addMagazines ["SatchelCharge_Remote_Mag", 1]; } forEach (units _bombGroup);
	br_friendlyRadioBombers append [_bombGroup];
	waitUntil { {_x in _transportVech} count (units _bombGroup) == {(alive _x)} count (units _bombGroup) };
};

// Tell the unit to place and touchoff the bomb
placeBomb = {
	_bomb = "satchelcharge_remote_ammo" createVehicle getPos br_radio_tower;
	_bomb setDamage 1;
};

runRaidoBombUnit = {
	while {TRUE} do {
		touchOffBomb = FALSE;
		[] call createBombUnits;
		waitUntil { br_radio_tower_destoryed == 0 };
		// Check if units inside chopper are dead
		while {({(alive _x)} count (units _bombGroup) > 0) && (br_radio_tower_destoryed == 0)} do {
			// Check if any groups are waiting
			if (count (waypoints _bombGroup) < 2) then {
				_wp = _bombGroup addWaypoint [getpos br_radio_tower, 0];
				_wp setWaypointFormation "WEDGE";
				_wp setWaypointType "MOVE";
				_wp setWaypointSpeed "FULL";
				_wp setWaypointStatements ["true", "touchOffBomb = TRUE;"];
				waitUntil { (getpos (leader _bombGroup)) distance (getpos br_radio_tower) < 1500 };
				{[_x] allowGetIn false; _x action ["Eject", vehicle _x]} forEach (units _bombGroup);
				waitUntil { (touchOffBomb || br_radio_tower_destoryed == 0 || {(alive _x)} count (units _bombGroup) == 0); };
				[] call placeBomb;;
			}
			//sleep 10;
		};
		{ deleteVehicle _x; } forEach (units _bombGroup);
		deleteVehicle _transportVech;
		deleteGroup _bombGroup;
		br_friendlyRadioBombers deleteAt (br_friendlyRadioBombers find _bombGroup);
	};
};

[] call runRaidoBombUnit;