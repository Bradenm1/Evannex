//_numbToSpawn = 3;  AI spawn per spawn rate
_aiSpawnRate = 0; // Delay in seconds
_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died

// Types
_sides = [EAST, WEST];

_types = ["OPF_F","BLU_F"];

//_unitTypes = ["Infantry","Armored", "Motorized_MTP", "Mechanized", "SpecOps"];
_unitTypes = ["Infantry", "Motorized_MTP", "Mechanized", "SpecOps"];

// Below units are in-order below given the _sides and _unitTypes positions 
_units = [[[ // EAST
	"OI_reconPatrol",
	"OI_reconSentry",
	"OI_reconTeam",
	//"OI_SniperTeam",
	"OIA_InfAssault",
	"OIA_InfSentry",
	"OIA_InfSquad",
	"OIA_InfSquad_Weapons",
	"OIA_InfTeam",
	"OIA_InfTeam_AA",
	"OIA_InfTeam_AT",
	"OIA_ReconSquad"
],[
	//"OIA_SPGPlatoon_Scorcher",
	//"OIA_SPGSection_Scorcher",
	"OIA_TankPlatoon",
	"OIA_TankPlatoon_AA",
	"OIA_TankSection"
],[
	"OIA_MotInf_AA",
	"OIA_MotInf_AT",
	"OIA_MotInf_GMGTeam",
	"OIA_MotInf_MGTeam",
	"OIA_MotInf_MortTeam",
	"OIA_MotInf_Team"
], [
	"OIA_MechInf_AA",
	"OIA_MechInf_AT",
	"OIA_MechInf_Support",
	"OIA_MechInfSquad"
], [
	"OI_AttackTeam_UAV",
	"OI_AttackTeam_UGV",
	//"OI_diverTeam",
	//"OI_diverTeam_Boat",
	//"OI_diverTeam_SDV",
	"OI_ReconTeam_UAV",
	"OI_ReconTeam_UGV",
	"OI_SmallTeam_UAV"
]], 
[[ // WEST
	"BUS_InfSentry",
	"BUS_InfSquad",
	"BUS_InfAssault",
	"BUS_InfSquad_Weapons",
	"BUS_InfTeam",
	"BUS_InfTeam_AA",
	"BUS_InfTeam_AT",
	"BUS_ReconPatrol",
	"BUS_ReconSentry",
	"BUS_ReconTeam",
	"BUS_ReconSquad",
	"BUS_SniperTeam"
],[
	"BUS_SPGPlatoon_Scorcher",
	"BUS_SPGSection_MLRS",
	"BUS_SPGSection_Scorcher",
	"BUS_TankPlatoon",
	"BUS_TankPlatoon_AA",
	"BUS_TankSection"
],[
	"BUS_MotInf_AA",
	"BUS_MotInf_AT",
	"BUS_MotInf_GMGTeam",
	"BUS_MotInf_MGTeam",
	"BUS_MotInf_MortTeam",
	"BUS_MotInf_Team"
], [
	"BUS_MechInf_AA",
	"BUS_MechInf_AT",
	"BUS_MechInf_Support",
	"BUS_MechInfSquad"
], [
	"BUS_AttackTeam_UAV",
	"BUS_AttackTeam_UGV",
	"BUS_diverTeam",
	"BUS_diverTeam_Boat",
	"BUS_diverTeam_SDV",
	"BUS_ReconTeam_UAV",
	"BUS_ReconTeam_UGV",
	"BUS_SmallTeam_UAV"
]]];

_unitChance = [
	"O_Heli_Light_02_dynamicLoadout_F",
	"I_LT_01_AT_F",
	"O_Plane_CAS_02_dynamicLoadout_F",
	"O_Truck_02_box_F",
	"O_APC_Tracked_02_AA_F",
	"O_MBT_02_cannon_F",
	"O_Heli_Attack_02_F",
	"O_MBT_02_arty_F",
	"O_G_Offroad_01_armed_F",
	"O_MRAP_02_gmg_F",
	"O_Truck_02_medical_F",
	"O_Truck_02_fuel_F",
	"O_static_AT_F",
	"O_static_AA_F",
	"O_T_LSV_02_armed_F",
	"I_GMG_01_high_F",
	"I_HMG_01_A_F",
	"I_HMG_01_high_F",
	"I_HMG_01_F",
	"I_G_Offroad_01_repair_F",
	"I_MRAP_03_F",
	"I_Heli_light_03_F",
	"O_Quadbike_01_F",
	"O_G_Van_01_transport_F",
	"O_APC_Wheeled_02_rcws_F",
	"O_UAV_01_F",
	"O_UGV_01_rcws_F",
	"O_Heli_Transport_04_box_F"
];

// Gets a random location on the plaer
getLocation = {
	_fun = compile preprocessFileLineNumbers "functions\getRandomLocation.sqf";
	[] call _fun;
};

// Spawn given units at a certain location
spawnGivenUnitsAt = {
	// Getting the params
	_group = _this select 0;
	_spawnAmount = _this select 1;
	_position = _this select 2;
	_groupunits = _this select 3;
	_applyToMainGroup = _this select 4;
	_vectorAdd = _this select 5; // Adds to the spawn position each spawn, allows vehicles to not spawn inside one another...
	// Number AI to spawn
	for "_i" from 1 to _spawnAmount do  {
		{
			// Create and return the AI(s) group
			_tempGroup = [_position, side _group, [_x],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
			// Place the AI(s) in that group into another group
			units _tempGroup join _group;
			_position = _position vectorAdd _vectorAdd;
		} foreach _groupunits;
	};
	if (_applyToMainGroup == 1) then {br_AIGroups append [_group]};
	_group;
};

// Single unit spawning at a certain location
spawnRandomAIAt = {
	// Getting the params
	_group = _this select 0;
	_spawnAmount = _this select 1;
	_position = _this select 2;
	_applyToMainGroup = _this select 3;
	// Number AI to spawn
	for "_i" from 1 to _spawnAmount do  {
		// Create and return the AI(s) group
		_tempGroup = [_position, side _group, 1] call BIS_fnc_spawnGroup;
		// Place the AI(s) in that group into another group
		units _tempGroup join _group;
	};
	if (_applyToMainGroup == 1) then {br_AIGroups append [_group]};
	_group;
};

// Spawns a group
spawnGroup = {
	_createdGroup = [[] call getLocation, _this select 0, (configFile >> "CfgGroups" >> str(_this select 0) >> _this select 1 >> _this select 2 >> _this select 3)] call BIS_fnc_spawnGroup;
	// Get position for the waypoint
	//_pos = [] call getLocation;
	//_createdGroup addWaypoint [_pos, 0];
	_createdGroup;
};

// Selects and spawns random units
selectRandomGroupToSpawn = {
	//_eastCount = 0;
	//_westCount = 0;
	// Check number of groups for each side
	//{ if (side _x == EAST) then [{ _eastCount = _eastCount + 1 }, { _westCount = _westCount + 1 }];
	//} foreach br_AIGroups;
	// Check what side should be spawned given the group amounts for each side
	//_side = if (((_eastCount >= (br_min_ai_groups / 2)) or (_eastCount > _westCount)) and ((_westCount <= (br_min_ai_groups / 2) or (_eastCount < _westCount)))) then [{ 1 }, { 0 }];
	_side = 0;
	// Picks random type of units
	_index = floor random count _unitTypes;
	// Selects unit side given the side
	_type = _types select _side;
	// Selects group side from the units array
	br_AIGroupside = _units select _side;
	// Selects the type of units to spawn
	_unitGroup = br_AIGroupside select _index;
	_group = [_sides select _side, _type, _unitTypes select _index, selectrandom _unitGroup] call spawnGroup;
	_group setBehaviour "SAFE";
	br_AIGroups append [_group];
};

// Spawn custom units
createCustomUnits = {
	// Chance to spawn some unit
	for "_i" from 1 to (random ((count _unitChance) / 2)) do  {
		([createGroup EAST, 1, [] call getLocation, [selectRandom _unitChance], 1, [0,0,0]] call spawnGivenUnitsAt) setBehaviour "SAFE";
	};
	//[createGroup EAST, 1, [] call getLocation, ["O_Heli_Light_02_dynamicLoadout_F"], 1, [0,15,15]] call spawnGivenUnitsAt;
	//[createGroup EAST, 1, [] call getLocation, ["I_LT_01_AT_F"], 1, [0,15,0]] call spawnGivenUnitsAt;
	//[createGroup EAST, 1, [] call getLocation, ["O_Plane_CAS_02_dynamicLoadout_F"], 1, [0,15,0]] call spawnGivenUnitsAt;
	//[createGroup EAST, 1, [] call getLocation, ["O_Truck_02_box_F"], 1, [0,15,0]] call spawnGivenUnitsAt;
	//[createGroup EAST, 1, [] call getLocation, ["O_APC_Tracked_02_AA_F"], 1, [0,15,0]] call spawnGivenUnitsAt;
	//[createGroup EAST, 1, [] call getLocation, ["O_MBT_02_cannon_F"], 1, [0,15,0]] call spawnGivenUnitsAt;
	([EAST, "OPF_F", "Infantry", "OI_SniperTeam"] call spawnGroup) setBehaviour "STEALTH";
	([EAST, "OPF_F", "Infantry", "OI_SniperTeam"] call spawnGroup) setBehaviour "STEALTH";
};

spawnAI = {
	// Spawn custom units
	[] call createCustomUnits;
	while {br_zone_taken == 0} do {
		// Spawn AI untill reached limit
		while {(count br_AIGroups <= br_min_ai_groups) and (getMarkerColor "ZONE_RADIOTOWER_RADIUS" == "ColorRed")} do {
			sleep _aiSpawnRate;
			//[] call selectRandomGroupToSpawn;
			br_total_groups_spawed = br_total_groups_spawed + 1;
			//hint format ["Group Spawned - Total:  %1", count br_AIGroups];
		};
		//hint format ["Group Spawned - Total:  %1", count br_AIGroups];
		// Delete groups where all units are dead
		{	// Add waypoint to group (Will do for all groups)
			_y = _x;
			// Check number of waypoints, if less then 3 add more.
			if (count (waypoints _y) < 3) then {
				_pos = [] call getLocation;
				_wp = _y addWaypoint [_pos, 0];
				_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
			};
			// Check group is empty, remove it from groups and delete it
			if (({alive _x} count units _y) < 1) then { br_AIGroups deleteAt (br_AIGroups find _y); deleteGroup _y;  _y = grpNull; _y = nil; };
		} foreach br_AIGroups;
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

[] call spawnAI;