while {TRUE} do {
	sleep 5;
	{
		_x addCuratorEditableObjects [allUnits,true];
		_x addCuratorEditableObjects [vehicles,true];
		if (!isnull (getassignedcuratorunit _x)) then {
			_unit = getassignedcuratorunit _x;
			if (isnull (getassignedcuratorlogic _unit)) then {
				unassignCurator _x;
				sleep 1;
				_unit assignCurator _x;
			};
		};
	} forEach allCurators;
	sleep 5;
};