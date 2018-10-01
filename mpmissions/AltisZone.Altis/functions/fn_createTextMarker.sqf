_name = _this select 0;
_loc = _this select 1;
_txt = _this select 2;
_color = _this select 3;
createMarker [_name, _loc];
_name setMarkerShape "ICON"; 
_name setMarkerText _txt;
_name setMarkerType "mil_triangle";
_name setMarkerColor _color;