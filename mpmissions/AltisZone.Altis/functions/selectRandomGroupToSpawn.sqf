
//_eastCount = 0;
//_westCount = 0;
// Check number of groups for each side
//{ if (side _x == EAST) then [{ _eastCount = _eastCount + 1 }, { _westCount = _westCount + 1 }];
//} foreach br_AIGroups;
// Check what side should be spawned given the group amounts for each side
//_side = if (((_eastCount >= (br_min_ai_groups / 2)) or (_eastCount > _westCount)) and ((_westCount <= (br_min_ai_groups / 2) or (_eastCount < _westCount)))) then [{ 1 }, { 0 }];

// The side number
_sides = _this select 0;
_side = _this select 1;
_unitTypes = _this select 2;
_types = _this select 3;
_units = _this select 4;
_location = _this select 5;
_mainGroup = _this select 6;

// Picks random type of units
_index = floor random count _unitTypes;
// Selects unit side given the side
_type = _types select _side;
// Selects group side from the units array
_AIGroupside = _units select _side;
// Selects the type of units to spawn
_unitGroup = _AIGroupside select _index;
_group = [_sides select _side, _type, _unitTypes select _index, selectrandom _unitGroup, _location] call compile preprocessFileLineNumbers "functions\spawnGroup.sqf";
_group setBehaviour "SAFE";
_mainGroup append [_group];
_group;