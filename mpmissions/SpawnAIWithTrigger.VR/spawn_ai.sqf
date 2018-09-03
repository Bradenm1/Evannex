// Number of AI to spawn each side
_numbToSpawn = 40;

// spawnAI function
spawnAI = {
	// Getting the params
	_location = _this select 0;
	_units = _this select 1;
	_group = _this select 2;
	_spawnAmount = _this select 3;
	for "_i" from 1 to _spawnAmount do  {
		// Create and return the AI(s) group
		_tempGroup = [ getMarkerPos _location, side _group, _units,[],[],[],[],[],0] call BIS_fnc_spawnGroup;
		// Place the AI(s) in that group into another group
		units _tempGroup join _group;
	};
};

// Creates a group for each side
// by defult the AI are in their own group
_westGroup = createGroup WEST;
_eastGroup = createGroup EAST;

// Units to spawn for given sides
_westUnits = ["B_Soldier_F"];
_eastUnits = ["O_Soldier_F"];

// Spawn the AI calling the spawnAI function
["spawnAIMarkerWEST", _westUnits, _westGroup, _numbToSpawn] call spawnAI;
["spawnAIMarkerEAST", _eastUnits, _eastGroup, _numbToSpawn] call spawnAI;

//_eastGroup setCombatMode "YELLOW";
//_westGroup setBehaviour "SAFE";