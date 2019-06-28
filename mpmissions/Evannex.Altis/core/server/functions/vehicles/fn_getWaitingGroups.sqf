private _vehicle = _this select 0;
private _groups = [];
// Check if any groups are waiting
if (count br_friendly_groups_waiting > 0) then {
	// Get some waiting groups, if any
	_groups = [_groups, br_friendly_groups_waiting, _vehicle] call fn_findGroupsInQueue; 
} else { 
	// Check if any players are waiting in helicopter
	_groups = [_vehicle] call fn_getPlayersInVehicle;
};
_groups;