// If it's a client
if (hasInterface) then {
	// Disable annoying crap
	execVM "core\client\fn_setPlayerSettings.sqf";
};

// Enable friendly markers
execVM "core\client\QS_icons.sqf";