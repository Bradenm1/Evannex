_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died
_vehicleGroup = nil;
_vehicle = nil;
_spawnPad = _this select 0;

_unitChance = [
	"B_MRAP_01_gmg_F",
	"B_MRAP_01_hmg_F",
	"B_G_Offroad_01_armed_F",
	"B_MBT_01_cannon_F",
	"B_APC_Tracked_01_AA_F",
	"B_UGV_01_rcws_F",
	"B_APC_Tracked_01_CRV_F",
	"B_Truck_01_medical_F",
	"B_Truck_01_fuel_F",
	"B_Truck_01_ammo_F",
	"B_Truck_01_Repair_F",
	"B_APC_Wheeled_01_cannon_F",
	"B_MBT_01_TUSK_F",
	"B_APC_Wheeled_03_cannon_F",
	"B_T_LSV_01_armed_F",
	"B_T_LSV_01_armed_CTRG_F",
	"B_LSV_01_armed_F",
	"B_LSV_01_AT_F",
	"B_LSV_01_armed_black_F",
	"B_T_LSV_01_armed_black_F",
	"B_T_MRAP_01_gmg_F",
	"B_T_MRAP_01_hmg_F",
	"B_T_UAV_03_F",
	"B_G_Quadbike_01_F",
	"B_Heli_Light_01_armed_F",
	"I_APC_tracked_03_cannon_F",
	"I_LT_01_cannon_F",
	"I_LT_01_AA_F",
	"I_LT_01_scout_F",
	"I_LT_01_AT_F",
	"C_Kart_01_Red_F"
];

// Spawn custom units
createVehicleUnit = {
	_vehicle = selectrandom _unitChance createVehicle getMarkerPos _spawnPad;
	createVehicleCrew _vehicle;
	_commander = driver _vehicle;
	_vehicleGroup = group _commander;
	br_FriendlyAIGroups append [_vehicleGroup];
	br_friendlyvehicles append [_vehicleGroup];
};

runVehicleUnit = {
	while {True} do {
		[] call createVehicleUnit;
		waituntil{({(alive _x)} count (units _vehicleGroup) < 1) || (!alive _vehicle)};
		deleteGroup _vehicleGroup; 
		deleteVehicle _vehicle;
		br_FriendlyAIGroups deleteAt (br_FriendlyAIGroups find _vehicleGroup);
		br_friendlyvehicles deleteAt (br_friendlyvehicles find _vehicleGroup);
	};
};

//[] call runVehicleUnit;
[] call runVehicleUnit;