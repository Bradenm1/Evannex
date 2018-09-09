// If it's server
if (isServer) then {
	null = execVM "zoneCreation.sqf";
};

// If it's a client
if (hasInterface) then {
	null = execVM "playerTasking.sqf";
};

while {true} do {
	{
		_x addCuratorEditableObjects [allUnits,true];
		_x addCuratorEditableObjects [vehicles,true];
	} forEach allCurators;
	sleep 3;
};