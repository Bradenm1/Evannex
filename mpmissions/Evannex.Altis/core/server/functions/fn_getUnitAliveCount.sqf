private _tempGroup = _this select 0;
private _count = 0;
{ if (alive _x) then {_count = _count + 1}; } forEach (units _tempGroup);
_count;