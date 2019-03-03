private _name = _this select 0;
private _loc = _this select 1;
private _radi = _this select 2;
private _maxD = _this select 3;
private _color = _this select 4;
private _txt = _this select 5;
private _alpha = _this select 6;
private _brush = _this select 7;
private _shape = _this select 8;

createMarker [_name, _loc]; 
_name setMarkerSize [_radi * sqrt _maxD, _radi * sqrt _maxD];
_name setMarkerBrush _brush;
_name setMarkerShape _shape;
_name setMarkerColor _color;
_name setMarkerText _txt;
_name setMarkerAlpha _alpha;