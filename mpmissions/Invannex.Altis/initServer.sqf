// Run the gamemode
execVM "core\server\zone\zoneCreation.sqf";
// Allow zeus to see spawned things
execVM "core\server\zeus\fn_addEditableZeus.sqf";
// Set random weather/time
if ("RandomTimeWeatherEnable" call BIS_fnc_getParamValue == 1) then { execVM "core\server\setRandomWeather.sqf"; };