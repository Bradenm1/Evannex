_maker = _this select 0;
_time = _this select 1;
_group = _this select 2;

waitUntil { time >= _time; };

deleteMarker _maker;
br_groups_marked deleteAt (br_groups_marked find _group);