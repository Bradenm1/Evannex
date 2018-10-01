this addAction ["Teleport to zone", { 
  (_this select 1) setPos ([getMarkerPos "ZONE_RADIUS", (br_zone_radius * 1.5) * sqrt br_max_radius_distance, 600, 1, 0, 0, 0] call BIS_fnc_findSafePos);   
}];