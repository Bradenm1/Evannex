//_numbToSpawn = 3;  AI spawn per spawn rate
_aiSpawnRate = 0; // Delay in seconds
_allSpawnedDelay = 30; // Seconds to wait untill checking if any groups died

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
	"O_Heli_Transport_04_box_F",
	"O_Mortar_01_F",
	"O_G_Mortar_01_F",
	"O_UAV_02_F",
	"O_UAV_02_CAS_F",
	"O_UGV_01_F",
	"O_Truck_03_transport_F",
	"O_Truck_03_ammo_F",
	"O_Truck_03_device_F",
	"O_Static_Designator_02_F",
	"O_T_UAV_04_CAS_F",
	"O_Plane_Fighter_02_F",
	"O_Plane_CAS_02_Cluster_F",
	"O_Plane_Fighter_02_Cluster_F",
	"O_MBT_04_cannon_F",
	"O_T_MBT_04_cannon_F",
	"O_MBT_04_command_F",
	"O_T_MBT_04_command_F",
	"O_Radar_System_02_F",
	"O_SAM_System_04_F",
	"O_Plane_Fighter_02_Stealth_F",
	"I_MRAP_03_gmg_F",
	"I_MRAP_03_hmg_F",
	"C_Kart_01_yellow_F"
];

// Gets a safe zone within the zone
br_fnc_getGroupEnemySpawn = {
	[getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 5, 0, 60, 0] call BIS_fnc_findSafePos;
};

// Spawn given units at a certain location
br_fnc_spawnGivenUnitsAt = {
	// Getting the params
	_group = _this select 0;
	_spawnAmount = _this select 1;
	_position = _this select 2;
	_groupunits = _this select 3;
	_vectorAdd = _this select 4; // Adds to the spawn position each spawn, allows vehicles to not spawn inside one another...
	// Number AI to spawn
	for "_i" from 1 to _spawnAmount do  {
		{
			// Create and return the AI(s) group
			_tempGroup = [_position, side _group, [_x],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
			// Place the AI(s) in that group into another group
			units _tempGroup join _group;
			//_position = _position vectorAdd _vectorAdd;
		} foreach _groupunits;
	};
	_group;
};

// Spawn custom units
br_fnc_createCustomUnits = {
	
};

br_fnc_spawnAI = {
	// Delete existing units 
	//[] call deleteAllAI;
	// Spawn custom units
	[] call br_fnc_createCustomUnits;
	while {!br_zone_taken} do {
		// Spawn AI untill reached limit
		while {(count br_AIGroups <= br_min_ai_groups) and (getMarkerColor "ZONE_RADIOTOWER_RADIUS" == "ColorRed")} do {
			sleep _aiSpawnRate;
			_newPos = [] call br_fnc_getGroupEnemySpawn;
			_group = [_sides, 0, _unitTypes, _types, _units, _newPos, br_AIGroups] call compile preprocessFileLineNumbers "functions\selectRandomGroupToSpawn.sqf";
			{ _x setSkill 1 } forEach units _group;
			//hint format ["Group Spawned - Total:  %1", count br_AIGroups];
		};
		// Spawn spawn special units untill 
		while {(count br_special_ai_groups <= br_min_special_groups) and (getMarkerColor "ZONE_RADIOTOWER_RADIUS" == "ColorRed")} do {
			_newPos = [] call br_fnc_getGroupEnemySpawn;
			_group = [createGroup EAST, 1, _newPos, [selectRandom _unitChance], 1, [0,0,0]] call br_fnc_spawnGivenUnitsAt;
			{ _x setSkill 1 } forEach units _group;
			br_special_ai_groups append [_group];
			br_AIGroups append [_group];
		};
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

[] call br_fnc_spawnAI;