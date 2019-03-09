if (isServer) then {
	// Run the gamemode
	execVM "core\server\zone\zoneCreation.sqf";
	setViewDistance (parseNumber "ViewDistance" call BIS_fnc_getParamValue);
};

// If it's a client
if (hasInterface) then {
	// Allow zeus to see spawned things
	if ("ZeusSeesAI" call BIS_fnc_getParamValue == 1) then { execVM "core\server\zeus\fn_addEditableZeus.sqf"; };
	// Disable annoying crap
	execVM "core\client\fn_setPlayerSettings.sqf";
	player addeventhandler ["respawn","_this execvm 'core\client\fn_setPlayerSettings.sqf'"];
	execVM "core\client\fn_displayStartingScreen.sqf";
	if ("VirutalSupport" call BIS_fnc_getParamValue == 1) then { br_support_module synchronizeObjectsAdd [player]; };
};