// Run the gamemode
execVM "zoneCreation.sqf";
// Allow zeus to see spawned things
execVM "fn_addEditableZeus.sqf";
// Set random weather/time
if ("RandomTimeWeatherEnable" call BIS_fnc_getParamValue == 1) then { execVM "setRandomWeather.sqf"; };