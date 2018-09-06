// Number of AI to spawn each side
_aiLimit = 15; // Number of groups
//_numbToSpawn = 3;  AI spawn per spawn rate
_aiSpawnRate = 0; // Delay in seconds
_allSpawnedDelay = 10; // Seconds to wait untill checking if any groups died
_minDis = 180; // Limit to spawm from center
_maxDis = 360; // Outter limit
_radius = 55; // Radius to spawn within
_totalSpawned = 0; // Total groups spawned
_groups = []; // All spawned groups

// Zone Locations
//_zones = [position player, getMarkerPos "zone_01"];
_zones = [position player];
// Current zone
_zone = objnull;

// Types
_sides = [EAST, WEST];

_types = ["OPF_F","BLU_F"];

_unitTypes = ["Infantry","Armored", "Motorized_MTP", "Mechanized", "SpecOps"];

// Below units are in-order below given the _sides and _unitTypes positions 
_units = [[[ // EAST
	"OI_reconPatrol",
	"OI_reconSentry",
	"OI_reconTeam",
	"OI_SniperTeam",
	"OIA_InfAssault",
	"OIA_InfSentry",
	"OIA_InfSquad",
	"OIA_InfSquad_Weapons",
	"OIA_InfTeam",
	"OIA_InfTeam_AA",
	"OIA_InfTeam_AT",
	"OIA_ReconSquad"
],[
	"OIA_SPGPlatoon_Scorcher",
	"OIA_SPGSection_Scorcher",
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
	"OI_diverTeam",
	"OI_diverTeam_Boat",
	"OI_diverTeam_SDV",
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

// Gets a random location on the plaer
getLocation = {
	_location = _zones select _zone;
 	_location getPos [_radius * sqrt random _minDis, random _maxDis];
};

// Single unit spawning
spawnAI = {
	// Getting the params
	_group = _this select 0;
	_spawnAmount = _this select 1;
	// Number AI to spawn
	for "_i" from 1 to _spawnAmount do  {
		// Create and return the AI(s) group
		_tempGroup = [[] call getLocation, side _group, 1] call BIS_fnc_spawnGroup;
		// Place the AI(s) in that group into another group
		units _tempGroup join _group;
	};
};

// Spawns a group
spawnGroup = {
	_createdGroup = [[] call getLocation, _this select 0, (configFile >> "CfgGroups" >> str(_this select 0) >> _this select 1 >> _this select 2 >> _this select 3)] call BIS_fnc_spawnGroup;
	// Get position for the waypoint
	_pos = [] call getLocation;
	_createdGroup addWaypoint [_pos, 0];
	_createdGroup;
};

// Selects and spawns random units
selectRandomGroupToSpawn = {
	_eastCount = 0;
	_westCount = 0;
	// Check number of groups for each side
	{ if (side _x == EAST) then [{ _eastCount = _eastCount + 1 }, { _westCount = _westCount + 1 }];
	} foreach _groups;
	// Check what side should be spawned given the group amounts for each side
	_side = if (((_eastCount >= (_aiLimit / 2)) or (_eastCount > _westCount)) and ((_westCount <= (_aiLimit / 2) or (_eastCount < _westCount)))) then [{ 1 }, { 0 }];
	// Picks random type of units
	_index = floor random count _unitTypes;
	// Selects unit side given the side
	_type = _types select _side;
	// Selects group side from the units array
	_groupSide = _units select _side;
	// Selects the type of units to spawn
	_unitGroup = _groupSide select _index;
	_groups append [[_sides select _side, _type, _unitTypes select _index, selectrandom _unitGroup] call spawnGroup];
};

// Creates the zone
createZone = {
	_zone = floor random count _zones;
	_location = _zones select _zone;
	// Creates the radius
	createMarker ["Radius", _location]; 
	"Radius" setMarkerSize [_radius * sqrt _maxDis, _radius * sqrt _maxDis];
	"Radius" setMarkerBrush "FDiagonal";
	"Radius" setMarkerShape "ELLIPSE";
	"Radius" setMarkerColor "ColorBlue";
	"Radius" setMarkerText "Enemy Zone";
	"Radius" setMarkerAlpha 0.5;

	// Create text icon
	createMarker ["Icon", _location];
	"Icon" setMarkerShape "ICON"; 
	"Icon" setMarkerText "Enemy Zone";
	"Icon" setMarkerType "mil_triangle";
	"Icon" setMarkerColor "ColorGreen";
};

// Creates the HQ
createHQ = {
	_hqCenterPos = [] call getLocation;
	_hqPos = _hqCenterPos getPos [10 * sqrt random 180, random 360];
	"Land_Cargo_HQ_V1_F" createVehicle _hqPos;

	// Creates the radius
	createMarker ["HQ_RADIUS", _hqCenterPos]; 
	"HQ_RADIUS" setMarkerSize [10 * sqrt 360, 10 * sqrt 360];
	"HQ_RADIUS" setMarkerBrush "FDiagonal";
	"HQ_RADIUS" setMarkerShape "ELLIPSE";
	"HQ_RADIUS" setMarkerColor "ColorGreen";
	"HQ_RADIUS" setMarkerText "Enemy Zone";
	"HQ_RADIUS" setMarkerAlpha 0.6;

	// Create text icon
	createMarker ["HQ_ICON", _hqCenterPos];
	"HQ_ICON" setMarkerShape "ICON"; 
	"HQ_ICON" setMarkerText "HQ";
	"HQ_ICON" setMarkerType "mil_triangle";
	"HQ_ICON" setMarkerColor "ColorGreen";
};

main = {
	// Create a zone
	[] call createZone;
	[] call createHQ;
	// Endless loop
	while {True} do {
		// Spawn AI untill reached limit
		while {count _groups <= _aiLimit} do {
			sleep _aiSpawnRate;
			[] call selectRandomGroupToSpawn;
			_totalSpawned = _totalSpawned + 1;
			hint format ["Group Spawned - Total:  %1", _totalSpawned];
		};
		// Delete groups where all units are dead
		{	// Add waypoint to group (Will do for all groups)
			_pos = [] call getLocation;
			_x addWaypoint [_pos, 0];
			// Check group is empty, remove it from groups and delete it
			if ((count (units _x)) == 0) then { _groups deleteAt (_groups find _x); deleteGroup _x;  _x = grpNull; _x = nil; };
		} foreach _groups;
		// Save memory instead of constant checking
		sleep _allSpawnedDelay;
	};
};

// Run main
[] call main;