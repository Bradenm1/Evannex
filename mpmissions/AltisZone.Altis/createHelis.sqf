// The group of units
_chopperUnits = nil;
// The helicopter
_helicopterVech = nil;
// The position where the AI will spawn
_heliPad = _this select 0;
_heliIndex = _this select 1;
// If te helicopter is a evac helicopter or not
_evacChopper = _this select 2;
// Used to tell the AI where to land
_landMarker = nil;

// Type of transport helicopters that can spawn
br_heli_units = [
	"B_Heli_Transport_03_F",
	"B_Heli_Transport_03_unarmed_F",
	"B_Heli_Transport_03_black_F",
	"B_Heli_Transport_03_unarmed_green_F",
	"B_CTRG_Heli_Transport_01_sand_F",
	"B_CTRG_Heli_Transport_01_tropic_F",
	"B_Heli_Light_01_F",
	"B_Heli_Transport_01_F",
	"B_Heli_Transport_01_camo_F",
	"I_Heli_Transport_02_F",
	"I_Heli_light_03_unarmed_F",
	"O_Heli_Light_02_v2_F",
	"O_Heli_Transport_04_bench_F",
	"O_Heli_Transport_04_covered_F"
];

// Gets a random location on the plaer
getGroundUnitLocation = {
	// Gets a random location within the zone radius
	(getMarkerPos "marker_ai_spawn_friendly_ground_units") getPos [5 * sqrt random 0, random 360];
};

// Commands groups in or out of the chopper
commandGroupIntoChopper = {
	_group = _this select 0;
	_getOut = _this select 1;
	if (_getOut) then {
		_group leaveVehicle _helicopterVech;
	} else {
		_group addVehicle _helicopterVech;
	};
	{
		//_x assignAsCargo _helicopterVech;
		if (_getOut) then { _x action ["Eject", _helicopterVech]; } else { [_x] orderGetIn true; };
	} foreach (units _group);
};

// Create a landing pad
createHeliPad = {
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", getMarkerPos _heliPad, [], 0, "CAN_COLLIDE" ];
};

// Spawn custom units
createChopperUnit = {
	_helicopterVech = (selectrandom br_heli_units) createVehicle getMarkerPos _heliPad;
	//createVehicleCrew _helicopterVech;
	[] call createHeliUnits;
	waitUntil { {_x in _helicopterVech} count (units _chopperUnits) == {(alive _x)} count (units _chopperUnits) };
	//br_helisWaiting append [_chopper];
};

deleteOldChopperUnit = {
	br_heliGroups deleteAt (br_heliGroups find _chopperUnits);
	{ deleteVehicle _x } forEach units _chopperUnits;
	deleteGroup _chopperUnits;
};

// Checks if units in chooper are dead but false is if they are alive
checkHeliDead = {
	if (({(alive _x)} count (units _chopperUnits) > 0) && (alive _helicopterVech) && (((leader _chopperUnits) distance _helicopterVech) < 30)) then { false;} else { true; };
};

// Creates the helicopter units
createHeliUnits = {
	_chopperUnits = [[] call getGroundUnitLocation, WEST, ["B_Pilot_F"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
	{_x disableAI "TARGET"; _x disableAI "AUTOTARGET" ; _x disableAI "FSM" ; _x disableAI "AUTOCOMBAT"; _x disableAI "AIMINGERROR"; _x disableAI "SUPPRESSION"; _x disableAI "MINEDETECTION" ; _x disableAI "WEAPONAIM"; _x disableAI "CHECKVISIBLE"; } forEach units _chopperUnits;
	//_chopperUnits addVehicle _helicopterVech;
	{_x moveInDriver _helicopterVech} forEach units _chopperUnits;
	{ _x setSkill 1 } forEach units _chopperUnits;
	br_heliGroups append [_chopperUnits];
};

// Gets the LZ for the zone
createLandingSpotNearZone = {
	_pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * 2) * sqrt br_max_radius_distance, 600, 24, 0, 0.25, 0] call BIS_fnc_findSafePos;
	[format ["LZ - %1", _heliIndex], _pos, format ["LZ - %1", _heliIndex], "ColorGreen"] call (compile preProcessFile "functions\createTextMarker.sqf");
	_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
	_pos;
};

// Get how many units from a group are in the chopper
getUnitsInHeli = {
	_tempGroup = _this select 0;
	_count = 0;
	{ if (_x in _helicopterVech) then {_count = _count + 1}; } forEach (units _tempGroup);
	_count;
};

// Get units alive in a group
getUnitsAlive = {
	_tempGroup = _this select 0;
	_count = 0;
	{ if (alive _x) then {_count = _count + 1}; } forEach (units _tempGroup);
	_count;
};

// Wait for a group to enter the chopper
waitForUntsToEnterChopper = {
	_tempGroup = _this select 0;
	{_x selectweapon primaryWeapon _x; _x setDamage 0} foreach (units _tempGroup);
	waitUntil { {_x in _helicopterVech} count (units _tempGroup) == {(alive _x)} count (units _tempGroup) || [] call checkHeliDead || _helicopterVech emptyPositions "cargo" == 0 };
};

// If the chopper is transport
runTransportChopper = {
	_groups = [];
	// Check if any groups are waiting
	if (count br_friendlyGroupsWaiting > 0) then {
		// Remove group from queue
		//_group = br_friendlyGroupsWaiting select 0;
		_Peps = 0;	
		{
			_unitsAlive = [_x] call getUnitsAlive;
			if (_unitsAlive > 0) then {
				if ((_Peps + _unitsAlive) <= _helicopterVech emptyPositions "cargo") then {
					br_friendlyGroupsWaiting deleteAt (br_friendlyGroupsWaiting find _x);
					_groups append [_x];
					_Peps = _Peps + _unitsAlive;
					sleep 3;
				};
			};
		} forEach br_friendlyGroupsWaiting; 
		if (count _groups > 0) then {
			// Check if group is alive
			{ br_groupsInTransit append [_x]; } forEach _groups;
			//br_groupsInTransit append [_group];
			{ [_x, false] call commandGroupIntoChopper; } forEach _groups;
			{ [_x] call waitForUntsToEnterChopper; } forEach _groups;
			//br_FriendlyAIGroups a ppend [_chopperUnits];
			//br_helis_in_transit append [_chopperUnits];
			_chopperUnits setBehaviour "CARELESS";
			_pos = [] call createLandingSpotNearZone;
			_wp = _chopperUnits addWaypoint [_pos, 0];
			_wp setWaypointType "GETOUT";
			_helicopterVech engineOn true;
			// Wait untill landed
			waitUntil {(getPos _helicopterVech select 2 > 10) || [] call checkHeliDead || !(isEngineOn _helicopterVech)};
			// Has landed
			waitUntil {(getPos _helicopterVech select 2 < 1) || [] call checkHeliDead || !(isEngineOn _helicopterVech)};
			{ [_x, true] call commandGroupIntoChopper; } forEach _groups;
			[] call deleteOldChopperUnit;
			{ waitUntil { [_x] call getUnitsInHeli == 0}; } forEach _groups;
			[] call createHeliUnits;
			// Tell group to get out of chooper, it has landed...
			{ _x setBehaviour "AWARE"; } forEach _groups;					
			//_group setCombatMode "RED";
			{ br_groupsInTransit deleteAt (br_groupsInTransit find _x); } forEach _groups;
			{ br_FriendlyAIGroups append [_x]; } forEach _groups;
			_wp = _chopperUnits addWaypoint [getMarkerPos _heliPad, 0];
			_wp setWaypointType "GETOUT";
			deleteVehicle _landMarker;
			deleteMarker format ["LZ - %1", _heliIndex];
			_helicopterVech engineOn true;
			waitUntil {(getPos _helicopterVech select 2 > 10) || [] call checkHeliDead || !(isEngineOn _helicopterVech)};
			waitUntil {(getPos _helicopterVech select 2 < 1) || [] call checkHeliDead || !(isEngineOn _helicopterVech)};
			[] call deleteOldChopperUnit;
			[] call createHeliUnits;
			_helicopterVech engineOn false;
			_helicopterVech setFuel 1;
			_helicopterVech setDamage 0;
		};		
	};
};

// If the chopper is evac
runEvacChopper = {
	if ((count br_friendlyGroupsWatingForEvac > 0)) then {
		_group = br_friendlyGroupsWatingForEvac select 0;
		br_friendlyGroupsWatingForEvac deleteAt (br_friendlyGroupsWatingForEvac find _group);
		if ({(alive _x)} count (units _group) > 0) then {
			br_groupsInTransit append [_group];
			_group setBehaviour "SAFE";	
			//br_FriendlyAIGroups append [_chopperUnits];
			//br_helis_in_transit append [_chopperUnits];
			_chopperUnits setBehaviour "CARELESS";
			_pos = [getpos (leader _group), 0, 300, 24, 0, 0.25, 0] call BIS_fnc_findSafePos;
			[format ["EVAC - %1", _heliIndex], _pos, format ["EVAC - %1", _heliIndex], "ColorGreen"] call (compile preProcessFile "functions\createTextMarker.sqf");
			_landMarker = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];
			_wp = _chopperUnits addWaypoint [_pos, 0];
			_wp setWaypointType "GETOUT";
			_helicopterVech engineOn true;
			// Wait untill landed
			waitUntil {(getPos _helicopterVech select 2 > 10) || [] call checkHeliDead};
			// Has landed
			waitUntil {(getPos _helicopterVech select 2 < 1) || [] call checkHeliDead};
			[_group, false] call commandGroupIntoChopper;
			{_x selectweapon primaryWeapon _x} foreach (units _group);
			waitUntil { {_x in _helicopterVech} count (units _group) == {(alive _x)} count (units _group) || [] call checkHeliDead || _helicopterVech emptyPositions "cargo" == 0 };
			[] call deleteOldChopperUnit;
			[] call createHeliUnits;			
			_wp = _chopperUnits addWaypoint [getMarkerPos _heliPad, 0];
			_wp setWaypointType "GETOUT";
			deleteVehicle _landMarker;
			deleteMarker format ["EVAC - %1", _heliIndex];
			waitUntil {(getPos _helicopterVech select 2 > 10) || [] call checkHeliDead};
			waitUntil {(getPos _helicopterVech select 2 < 1) || [] call checkHeliDead};
			[] call deleteOldChopperUnit;
			br_friendlyGroupsWaiting append [_group];
			[_group, true] call commandGroupIntoChopper;
			waitUntil { {_x in _helicopterVech} count (units _group) == 0};
			{_x selectweapon primaryWeapon _x; _x setDamage 0} foreach (units _group);
			_group setBehaviour "SAFE";	
			br_groupsInTransit deleteAt (br_groupsInTransit find _group);
			//br_friendlyGroupsWaiting append [_group];
			[] call createHeliUnits;
			_helicopterVech engineOn false;
			_helicopterVech setFuel 1;
			_helicopterVech setDamage 0;
		};
	};
};

// Run AI
createHelis = {
	// Create the base helipad
	[] call createHeliPad;
	while {True} do {
		// Create chopper units
		[] call createChopperUnit;
		// Check if units inside chopper are dead, or helicopter is dead or pilot ran away
		while {({(alive _x)} count (units _chopperUnits) > 0) && (alive _helicopterVech) && (((leader _chopperUnits) distance _helicopterVech) < 30);} do {
			sleep 10;
			if (_evacChopper) then { [] call runEvacChopper; } else { [] call runTransportChopper; };
		};
		sleep 15;
		// Do the below because the heli died or some bullcrap happened
		[] call deleteOldChopperUnit;
		deleteVehicle _helicopterVech;
	};
};

[] call createHelis;