// If it's a client
if (hasInterface) then {
	// Disable annoying crap
	execVM "fn_setPlayerSettings.sqf";
};

// Enable friendly markers
execVM "QS_icons.sqf";