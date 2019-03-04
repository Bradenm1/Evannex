br_create_side_objective = {
	private _distance = 0;
	private _objectivePosition = [0,0];

	// Side objective cannot be within n of meters
	while {_distance < 1500} do {
		_objectivePosition = [[], 0, -1, 0, 0, 25, 0] call BIS_fnc_findSafePos;
		_distance = br_current_zone distance2D _objectivePosition;
	};

	_sideObjectName = (format ["Side_Objective_%1", count br_current_sides]);

	_selected = selectrandom (call compile preprocessFileLineNumbers "core\savedassets\side_missions.sqf");
	[_sideObjectName, _selected select 0, _selected select 4, _selected select 2, "Kill", TRUE, _selected select 1, _selected select 3, TRUE, FALSE, "Border", "ELLIPSE", _objectivePosition, FALSE, [], _selected select 5] execVM "core\server\zone_objective\fn_createObjective.sqf";
	br_current_sides append [[_objectivePosition, _sideObjectName]];
};

br_fn_run_sides = {
	while {true} do {
		// Check if any side mission have been completed and delete them
		{
			if (missionNamespace getVariable (format ["br_%1", _x select 1])) then {
				br_current_sides deleteAt (br_current_sides find _x)
			}
		} foreach (br_current_sides);
		sleep 1;
		while {(count br_current_sides) < br_max_current_sides} do {
			call br_create_side_objective;
			sleep 1;
		};
		sleep 30;
	};
};

[] call br_fn_run_sides;