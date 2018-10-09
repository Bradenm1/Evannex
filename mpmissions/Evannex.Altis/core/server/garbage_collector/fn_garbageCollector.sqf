br_empty_vehicles_in_garbage_collection = []; // empty vehicles

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
	_playerindex = 0;
	while {count br_empty_vehicles_in_garbage_collection > 5 && {_playerindex < (count br_empty_vehicles_in_garbage_collection)}} do {
		_veh = br_empty_vehicles_in_garbage_collection select _playerindex;
		if (count (crew _veh) == 0) then {
			deleteVehicle _veh;
			br_empty_vehicles_in_garbage_collection deleteAt _playerindex;
		} else {
			_playerindex = _playerindex + 1;
		};
		sleep 0.01;
	};
	sleep 60;
};