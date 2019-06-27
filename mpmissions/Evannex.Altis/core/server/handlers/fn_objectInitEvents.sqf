private _object = _this select 0;

_object addEventHandler ["killed", "br_dead_objects pushBack (_this select 0);"];
[_object] call fn_addToZeus;