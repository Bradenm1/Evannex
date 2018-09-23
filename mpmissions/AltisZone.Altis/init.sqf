// If it's server
if (isServer) then {
	execVM "zoneCreation.sqf";
};

// If it's a client
if (hasInterface) then {
	execVM "playerTasking.sqf";
	// Allow zeus to see spawned things
	execVM "addEditableZeus.sqf";
	// Enable friendly markers
	execVM "QS_icons.sqf";

	// Disable annoying crap
	player enableFatigue False;  
	player enableStamina False;
	player forceWalk False;
	player addEventHandler ["Respawn", {player enableFatigue false}];
};