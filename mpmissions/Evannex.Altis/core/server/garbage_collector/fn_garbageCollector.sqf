_emptyEnemyVehicles = [];

while {TRUE} do {
	{
		deleteVehicle _x;
		sleep 0.01;
	} forEach allDead;
	{
		if ((count (crew _x)) == 0) then {
			_emptyEnemyVehicles append [_x];
		};
	} forEach br_enemy_vehicle_objects;
	for [{_i=(count _emptyEnemyVehicles)}, {_i > 5}, {_i=_i-1}] do {
		deleteVehicle (_emptyEnemyVehicles select _i);
		_emptyEnemyVehicles deleteAt _i;
		sleep 0.01;
	};
	sleep 60;
};