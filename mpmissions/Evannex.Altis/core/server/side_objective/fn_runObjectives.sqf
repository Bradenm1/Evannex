br_create_side_objective = {
	_distance = 0;
	_objectivePosition = [0,0];

	// Side objective cannot be within n of meters
	while {_distance < 1000} do {
		_objectivePosition = [[], 0, -1, 0, 0, 25, 0] call BIS_fnc_findSafePos;
		_distance = br_current_zone distance2D _objectivePosition;
	};

	["Side_Objective", 15, "O_Truck_03_device_F", "Destory", TRUE, "Side Objective Completed!", [], TRUE, FALSE, "Border", "ELLIPSE", _objectivePosition, FALSE] execVM "core\server\zone_objective\fn_createObjective.sqf";
	br_current_sides append [[_objectivePosition, "Side_Objective"]];
};

br_fn_run_sides = {
	while {true} do {
		// Check if any side mission have been completed and delete them
		{
			if (getMarkerColor (format ["ZONE_%1_ICON", _x select 1]) == "") then {
				br_current_sides deleteAt (br_current_sides find _x)
			}
		} foreach (br_current_sides);
		while {(count br_current_sides) < br_max_current_sides} do {
			call br_create_side_objective;
			sleep 0.01;
		};
		sleep 30;
	};
};

[] call br_fn_run_sides;