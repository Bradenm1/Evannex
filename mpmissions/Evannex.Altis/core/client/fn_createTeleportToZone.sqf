this addAction ["Teleport to zone", { 
  private _position = [getMarkerPos "ZONE_RADIUS", (("ZoneRadius" call BIS_fnc_getParamValue) * 1.5) * sqrt 360, 600, 1, 0, 0, 0] call BIS_fnc_findSafePos;
  _group = group (_this select 1);
  (_this select 1) setPos _position;
  { if (!(isplayer _x)) then { if (isNull objectParent _x) then { _x setPos _position; };}; } forEach (units _group)
}];