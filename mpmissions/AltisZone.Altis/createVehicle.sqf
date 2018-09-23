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
	"B_LSV_01_armed_olive_F",
	"B_T_LSV_01_armed_black_F",
	"B_T_LSV_01_armed_olive_F",
	"B_T_LSV_01_armed_sand_F",
	"B_T_MRAP_01_gmg_F",
	"B_T_MRAP_01_hmg_F",
	"B_T_UAV_03_F"
];

// Spawn custom units
createVehicleUnit = {
	_vehicle = selectrandom _unitChance createVehicle getMarkerPos _spawnPad;
	createVehicleCrew _vehicle;
	_commander = driver _vehicle;
	_vehicleGroup = group _commander;
	br_FriendlyAIGroups append [_vehicleGroup];
};

runVehicleUnit = {
	[] call createVehicleUnit;
	while {True} do {
		sleep _allSpawnedDelay;
	};
};

//[] call runVehicleUnit;
[] call createVehicleUnit;