private _vehicle = _this select 0;
private _group = [];

/*{
	if (_x in _vehicle && !(group _x in _group)) then { _group pushBack group _x };
} forEach switchableUnits;

{
	if (_x in _vehicle && !(group _x in _group)) then { _group pushBack group _x };
} forEach playableUnits;*/

{
	if (_x in _vehicle && !(group _x in _group)) then { _group pushBack group _x };
} forEach allPlayers;

_group;