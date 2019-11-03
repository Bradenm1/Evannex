if (isServer) then {
	// Run the gamemode
	call compile preprocessFileLineNumbers "core\server\cache\fn_functions.sqf";
	execVM "core\server\zone\zoneCreation.sqf";
	execVM "core\server\handlers\fn_requestVehicle.sqf";
	["Initialize"] call BIS_fnc_dynamicGroups;
};

// If it's a client
if (hasInterface) then {
	// Disable annoying crap
	execVM "core\client\fn_setPlayerSettings.sqf";
	player addeventhandler ["respawn","_this execvm 'core\client\fn_setPlayerSettings.sqf'"];
	execVM "core\client\fn_displayStartingScreen.sqf";
	if ("VirutalSupport" call BIS_fnc_getParamValue == 1) then { br_support_module synchronizeObjectsAdd [player]; };
	["InitializePlayer", [player, TRUE]] call BIS_fnc_dynamicGroups; 
} else {
	setViewDistance (parseNumber "ViewDistance" call BIS_fnc_getParamValue);
	setObjectViewDistance (parseNumber "ViewDistance" call BIS_fnc_getParamValue);
};