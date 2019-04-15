private _groups = _this select 0;
private _objectivePos = _this select 1;
private _radius = _this select 2;

private _nDead = 0;

While {TRUE} do {
	_nDead = 0;
	{
		private _group = _x;
		if ((getpos (leader _group)) distance _objectivePos > (_radius * sqrt 360) + 100) then { // Delete objective group if too far from objective
			[_group] call br_fnc_deleteGroups; // function from zoneCreation.sqf
			_nDead = _nDead + 1;
		} else {
			if ((({alive _x} count units _group) < 1)) then {
				_groups deleteAt (_groups find _group);
			};
		};
	} forEach _groups;
	if (_nDead >= count _groups) exitWith  {
		FALSE;
	};
	sleep 30;
};