_vehicleGroup = nil; // The group in the vehicle
_vehicle = nil; // The vehicle
_spawnPad = _this select 0; // The spawnpad for it

// The list of things that have a chance to spawn
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
	"C_Kart_01_Red_F",
	"B_AFV_Wheeled_01_cannon_F",
	"B_T_AFV_Wheeled_01_cannon_F",
	"B_AFV_Wheeled_01_up_cannon_F",
	"B_T_AFV_Wheeled_01_up_cannon_F",
	"B_APC_Tracked_01_AA_F",
	"B_APC_Tracked_01_rcws_F",
	"B_Heli_Attack_01_F",
	"B_UGV_01_F"
];

// Spawn custom units
br_fnc_createVehicleUnit = {
	// Select a random unit from the above list to spawn
	_vehicle = selectrandom _unitChance createVehicle getMarkerPos _spawnPad;
	// Create its crew
	createVehicleCrew _vehicle;
	// Get the vehicle commander
	_commander = driver _vehicle;
	// Get the group from the commander
	_vehicleGroup = group _commander;
	// Apply the zone AI to the vehicle
	br_FriendlyAIGroups append [_vehicleGroup];
	br_friendlyvehicles append [_vehicleGroup];
};

// run the vehicle
br_fnc_runVehicleUnit = {
	while {True} do {
		// Spawn vehicle
		[] call br_fnc_createVehicleUnit;
		// Wait untill they die
		waituntil{({(alive _x)} count (units _vehicleGroup) < 1) || (!alive _vehicle)};
		// Do some cleanup cause they died
		deleteGroup _vehicleGroup; 
		deleteVehicle _vehicle;
		br_FriendlyAIGroups deleteAt (br_FriendlyAIGroups find _vehicleGroup);
		br_friendlyvehicles deleteAt (br_friendlyvehicles find _vehicleGroup);
	};
};

[] call br_fnc_runVehicleUnit;