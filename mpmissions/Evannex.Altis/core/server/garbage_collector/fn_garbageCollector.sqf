br_empty_vehicles_in_garbage_collection = []; // empty vehicles

while {TRUE} do {
	{
		if (!([getpos _x, br_garbage_collection_player_distance] call (compile preProcessFile "core\server\functions\fn_checkPlayersAround.sqf")) && (getText (configFile >>  "CfgVehicles" >> typeof _x >> "displayName")) != "zeusPlayer") then {
			deleteVehicle _x ;
		};
		sleep 0.01;
	} forEach allDead;
	{
		if ((count (crew _x)) == 0) then {
			br_empty_vehicles_in_garbage_collection pushBack _x;
		};
	} forEach br_enemy_vehicle_objects;
	_playerindex = 0;
	while {count br_empty_vehicles_in_garbage_collection > 5 && {_playerindex < (count br_empty_vehicles_in_garbage_collection)}} do {
		_veh = br_empty_vehicles_in_garbage_collection select _playerindex;
		if (!([getpos _veh, br_garbage_collection_player_distance] call (compile preProcessFile "core\server\functions\fn_checkPlayersAround.sqf"))) then {
			if (count (crew _veh) == 0) then {
				deleteVehicle _veh;
				br_empty_vehicles_in_garbage_collection deleteAt _playerindex;
			} else {
				_playerindex = _playerindex + 1;
			};
		};
		sleep 0.5;
	};
	{ 
		objectName = getText (configFile >>  "CfgVehicles" >> typeof _x >> "displayName");
		if (objectName == "Canopy") then {
			deleteVehicle _x ;
		};
	} forEach (allMissionObjects "");
	sleep br_garbage_collection_interval;
};