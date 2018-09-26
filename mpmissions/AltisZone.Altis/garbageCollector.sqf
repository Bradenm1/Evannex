while {TRUE} do {
	{
		deleteVehicle _x;
		sleep 0.01;
	} forEach allDead;
	sleep 600;
};