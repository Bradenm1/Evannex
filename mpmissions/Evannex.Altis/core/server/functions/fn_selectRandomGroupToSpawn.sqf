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
_group = [_sides select _side, _type, _unitTypes select _index, selectrandom _unitGroup, _location] call compile preprocessFileLineNumbers "core\server\functions\fn_spawnGroup.sqf";
_group setBehaviour "SAFE";
_mainGroup append [_group];
_group;