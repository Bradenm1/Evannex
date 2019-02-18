_name = _this select 0;
_loc = _this select 1;
_radi = _this select 2;
_maxD = _this select 3;
_color = _this select 4;
_txt = _this select 5;
_alpha = _this select 6;
_brush = _this select 7;
_shape = _this select 8;

createMarker [_name, _loc]; 
_name setMarkerSize [_radi * sqrt _maxD, _radi * sqrt _maxD];
_name setMarkerBrush _brush;
_name setMarkerShape _shape;
_name setMarkerColor _color;
_name setMarkerText _txt;
_name setMarkerAlpha _alpha;