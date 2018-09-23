//_numbToSpawn = 3;  AI spawn per spawn rate
_aiSpawnRate = 0; // Delay in seconds
_allSpawnedDelay = 1; // Seconds to wait untill checking if any groups died

_spawnFriendlyGroundUnitsLocation = getMarkerPos "marker_ai_spawn_friendly_ground_units";

// Types
_sides = [EAST, WEST];

_types = ["OPF_F","BLU_F"];

//_unitTypes = ["Infantry","Armored", "Motorized_MTP", "Mechanized", "SpecOps"];
_unitTypes = ["Infantry"];

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
	"B_MRAP_01_gmg_F",
	"B_MRAP_01_hmg_F",
	"B_G_Offroad_01_armed_F",
	"B_MBT_01_cannon_F",
	"B_APC_Tracked_01_AA_F",
	"B_UGV_01_rcws_F"
];

// Gets a random location on the plaer
getGroundUnitLocation = {
	// Gets a random location within the zone radius
	(getMarkerPos "marker_ai_spawn_friendly_ground_units") getPos [5 * sqrt random 0, random 360];
};

// Spawn custom units
createCustomUnitsFriendly = {
	//([createGroup WEST, 1, getMarkerPos "helicopter_transport_01", ["B_Heli_Transport_03_F"], 0, [0,0,0]] call spawnGivenUnitsAt);
	//_transportChopper = "B_Heli_Transport_03_F" createVehicle getMarkerPos "helicopter_transport_01";
	//_chopGroup = [[] call getGroundUnitLocation, WEST, ["B_Pilot_F"],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
	//br_FriendlyAIGroups append [_chopGroup];
	//_chopGroup = [[] call getGroundUnitLocation, WEST, 5] call BIS_fnc_spawnGroup;
	//_chopGroup addVehicle _transportChopper;
	//{
	//	_x assignAsCargo _transportChopper;
	//	[_x] orderGetIn true;
	//} foreach (units _chopGroup);
};

spawnFriendlyAI = {
	// Spawn custom units
	//[] call createCustomUnitsFriendly;
	while {True} do {
		// Spawn AI untill reached limit
		while {((count br_friendlyGroupsWaiting) < br_min_friendly_ai_groups)} do {
			//sleep _aiSpawnRate;
			[_sides, 1, _unitTypes, _types, _units, [] call getGroundUnitLocation, br_friendlyGroupsWaiting] call compile preprocessFileLineNumbers "functions\selectRandomGroupToSpawn.sqf";
			
		};
		//hint format ["Group Spawned - Total:  %1", count br_AIGroups];
		// Delete groups where all units are dead
		{	// Add waypoint to group (Will do for all groups)
			_y = _x;
			// Check number of waypoints, if less then 3 add more.
			if (count (waypoints _y) < 3) then {
				//_pos = [] call getLocation;
				_pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
				_wp = _y addWaypoint [_pos, 0];
				_wp setWaypointStatements ["true","deleteWaypoint [group this, currentWaypoint (group this)]"];
			};
			// Check group is empty, remove it from groups and delete it
			if (({alive _x} count units _y) < 1) then { br_FriendlyAIGroups deleteAt (br_FriendlyAIGroups find _y); deleteGroup _y;  _y = grpNull; _y = nil; };
		} foreach br_FriendlyAIGroups;
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

[] call spawnFriendlyAI;