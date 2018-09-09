// If it's server
if (isServer) then {
	null = execVM "zoneCreation.sqf";
};

// If it's a client
if (hasInterface) then {
	null = execVM "playerTasking.sqf";
	// Allow zeus to see spawned things
	null = execVM "addEditableZeus.sqf";
};