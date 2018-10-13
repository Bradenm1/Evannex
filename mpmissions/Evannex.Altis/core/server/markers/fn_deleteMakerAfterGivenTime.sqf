_marker = _this select 0; // The marker
_time = _this select 1; // Future time

waitUntil { time >= _time || getMarkerColor _marker == ""; };

if (getMarkerColor _marker != "") then { deleteMarker _marker; };
br_groups_marked deleteAt (br_groups_marked find _marker);