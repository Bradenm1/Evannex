br_empty_vehicles_in_garbage_collection = []; // empty vehicles

while {TRUE} do {
	{
		if (!([getpos _x, br_garbage_collection_player_distance] call fn_checkPlayersAround)) then {
			br_dead_objects deleteAt (br_dead_objects find _x); 
			deleteVehicle _x ;
		};
	} forEach br_dead_objects;
	{
		if (!([getpos _x, br_garbage_collection_player_distance] call fn_checkPlayersAround) && (count (crew _x)) == 0) then {
			br_empty_vehicles_in_garbage_collection pushBack _x;
		};
	} forEach br_enemy_vehicle_objects;
	_playerindex = 0;
	while {count br_empty_vehicles_in_garbage_collection > 5 && _playerindex < (count br_empty_vehicles_in_garbage_collection)} do {
		_veh = br_empty_vehicles_in_garbage_collection select _playerindex;
		if (!([getpos _veh, br_garbage_collection_player_distance] call fn_checkPlayersAround)) then {
			if (count (crew _veh) == 0) then {
				deleteVehicle _veh;
				br_empty_vehicles_in_garbage_collection deleteAt _playerindex;
			} else {
				_playerindex = _playerindex + 1;
			};
		};
		sleep 0.5;
	};
	sleep br_garbage_collection_interval;
};