// The side number
private _side = _this select 0;
private _sideTypes = _this select 1;
private _unitTypes = _this select 2;
private _types = _this select 3;
private _units = _this select 4;
private _location = _this select 5;
private _mainGroup = _this select 6;

// Picks random type of units
private _index = floor random count _unitTypes;
// Selects unit side given the side
private _type = _types select _index;
private _typeSide = _sideTypes select _index;
// Selects group side from the units array
private _groups = _units select _index;
private _group = [_side, _typeSide, _type, _unitTypes select _index, selectrandom _groups, _location] call fn_spawnGroup;
//_group setBehaviour "SAFE";
_mainGroup pushBack _group;
_group;