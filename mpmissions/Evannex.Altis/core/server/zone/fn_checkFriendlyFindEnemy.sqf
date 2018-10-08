br_groups_marked = [];

fnc_checkUnitSeen = {
	_friendlyGroup = _this select 0;
	_enemyGroup = _this select 1;
	_knows = FALSE;

	{
		if ((_friendlyGroup knowsAbout _x) > 0.1) then { _knows = TRUE };
	} forEach (units _enemyGroup);
	_knows;
};

fnc_checkGroupSeen = {
	_friendlyGroup = _this select 0;
	{
		if (!(_x in br_groups_marked)) then {
			if ([_friendlyGroup, _x] call fnc_checkUnitSeen) then {
				[format ["a_%1", count br_groups_marked], getpos (leader _x), "Enemy", "ColorBlack"] call (compile preProcessFile "core\server\functions\fn_createTextMarker.sqf");
				[format ["a_%1", count br_groups_marked],time + 30, _x] execVM "core\server\functions\fn_deleteMakerAfterGivenTime.sqf";
				br_groups_marked append [_x];
			};
		};
	} forEach br_ai_groups;
};

while {TRUE} do {
	{
		[_x] call fnc_checkGroupSeen;
	} foreach br_friendly_ai_groups;
	sleep 10;
};