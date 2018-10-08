while {TRUE} do {
	{
		deleteVehicle _x;
		sleep 0.01;
	} forEach allDead;
	{
		if ((count (crew _x)) == 0) then {
			br_empty_vehicles_in_garbage_collection append [_x];
		};
	} forEach br_enemy_vehicle_objects;
	if ((count br_empty_vehicles_in_garbage_collection) > 5) then {
		for [{_i=0}, {_i < 5}, {_i=_i+1}] do {
			deleteVehicle (br_empty_vehicles_in_garbage_collection select _i);
			br_empty_vehicles_in_garbage_collection deleteAt _i;
			sleep 0.01;
		};
	};
	sleep 60;
};