While {TRUE} do {
	{
		_y = _x; if (({alive _x} count units _y) < 1) then { br_AIGroups deleteAt (br_AIGroups find _y); { deleteVehicle _x } forEach units _y; deleteGroup _y;  _y = grpNull; _y = nil; };
	} foreach br_AIGroups;
	{
		_y = _x; if (({alive _x} count units _y) < 1) then { br_FriendlyGroundGroups deleteAt (br_FriendlyGroundGroups find _y); { deleteVehicle _x } forEach units _y; deleteGroup _y;  _y = grpNull; _y = nil; };
	} foreach br_FriendlyGroundGroups;
	{
		_y = _x; if (({alive _x} count units _y) < 1) then { br_friendlyvehicles deleteAt (br_friendlyvehicles find _y); { deleteVehicle _x } forEach units _y; deleteGroup _y;  _y = grpNull; _y = nil; };
	} foreach br_friendlyvehicles;
	{
		_y = _x; if (({alive _x} count units _y) < 1) then { br_heliGroups deleteAt (br_heliGroups find _y); { deleteVehicle _x } forEach units _y; deleteGroup _y;  _y = grpNull; _y = nil; };
	} foreach br_heliGroups;
	sleep 30;
}