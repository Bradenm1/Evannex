// If it's server
if (isServer) then {
	execVM "zoneCreation.sqf";
	// Allow zeus to see spawned things
	execVM "addEditableZeus.sqf";
};

// If it's a client
if (hasInterface) then {
	// Disable annoying crap
	player enableFatigue False;  
	player enableStamina False;
	player forceWalk False;
	player setCustomAimCoef 0.3;
	player addEventHandler ["Respawn", {player enableFatigue FALSE; player forceWalk False; player enableStamina False; player setCustomAimCoef 0.3;}];
};

// Enable friendly markers
execVM "QS_icons.sqf";