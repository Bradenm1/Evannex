while {TRUE} do {
	{
		_x addCuratorEditableObjects [allUnits,true];
		_x addCuratorEditableObjects [vehicles,true];
	} forEach allCurators;
	sleep 10;
};