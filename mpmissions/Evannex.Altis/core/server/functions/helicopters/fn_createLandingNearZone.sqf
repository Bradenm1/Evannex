private _spaceMult = 1;
private _pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * 2) * sqrt br_max_radius_distance, 600 * _spaceMult, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
// We also find another position if it's too far from the zone
while {count _pos > 2 || _pos distance br_current_zone > (br_max_ai_distance_before_delete - 50)} do {
	_pos = [getMarkerPos "ZONE_RADIUS", (br_zone_radius * 2) * sqrt br_max_radius_distance, 600 * _spaceMult, 24, 0, br_heli_land_max_angle, 0] call BIS_fnc_findSafePos;
	_spaceMult = _spaceMult + 0.1;
	sleep 0.1;
};
_pos;