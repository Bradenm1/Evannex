// Number of AI to spawn each side
_aiLimit = 15; // Number of groups
_numbToSpawn = 3; // AI spawn per spawn rate
_aiSpawnRate = 1; // Delay in seconds
_minDis = 180; // Limit to spawm from center
_maxDis = 360; // Outter limit
_radius = 60; // Radius to spawn within
_groups = [];


// Types
_sides = ["EAST", "WEST"];

_types = ["OPF_F","BLU_F"];

_unitTypes = ["Infantry","Armored", "Motorized_MTP"];

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
]], [[ // WEST
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
]]];

// Gets a random location on the plaer
getLocation = {
 	player getPos [_radius * sqrt random _minDis, random _maxDis];
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
	_createdGroup = objNull;
	if (_this select 0 == "EAST") then [ { 
			_createdGroup = [[] call getLocation, EAST, (configFile >> "CfgGroups" >> _this select 0 >> _this select 1 >> _this select 2 >> _this select 3)] call BIS_fnc_spawnGroup; 
		}, { 
			_createdGroup = [[] call getLocation, WEST, (configFile >> "CfgGroups" >> _this select 0 >> _this select 1 >> _this select 2 >> _this select 3)] call BIS_fnc_spawnGroup; 
		} 
	];
	_createdGroup move position player;
	_createdGroup;
};

// Selects and spawns random units
selectRandomGroupToSpawn = {
	// Picks a random side
	_side = floor random count _sides;
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

// Endless loop
while {True} do {
	// Spawn AI untill reached limit
	while {count _groups <= _aiLimit} do {
		sleep _aiSpawnRate;
		[] call selectRandomGroupToSpawn;
	};
	// Delete groups where all units are dead
	{if ((count (units _x)) == 0) then {deleteGroup _x; _x = grpNull; _x = nil}} foreach allGroups;
	// Save memory instead of constant checking
	sleep 1;
};