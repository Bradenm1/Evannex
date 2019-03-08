private _group = _this select 0;
private _vehicle = _this select 1;
private _count = 0;
{ if (_x in _vehicle) then { _count = _count + 1}; } forEach (units _group);
_count;