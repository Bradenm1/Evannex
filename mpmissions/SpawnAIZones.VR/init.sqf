// If it's server
if (isServer) then {
	null = execVM "zoneCreation.sqf";
};

// If it's a client
if (hasInterface) then {
	null = execVM "playerTasking.sqf";
};