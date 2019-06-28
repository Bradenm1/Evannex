private _vehicle = _this select 0;
private _groups = [];
// Get some waiting groups, if any
if (count br_friendly_groups_waiting > 0) then {
	_groups = [_groups, br_friendly_groups_wating_for_evac, _vehicle] call fn_findGroupsInQueue;
	{ _x setBehaviour "SAFE"; } forEach _groups;
};
_groups;