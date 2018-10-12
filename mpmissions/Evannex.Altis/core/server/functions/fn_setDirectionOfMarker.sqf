_group = _this select 0;
_marker = _this select 1;

{ 
	_x setDir (markerDir _marker);
	if (!(isNull objectParent _x)) then { (vehicle _x) setDir (markerDir _marker); };
} forEach (units _group);