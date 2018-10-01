this addAction ["Teleport to zone", { 
  (_this select 1) setPos ([getMarkerPos "ZONE_RADIUS", (("ZoneRadius" call BIS_fnc_getParamValue) * 1.5) * sqrt 360, 600, 1, 0, 0, 0] call BIS_fnc_findSafePos);   
}];