private _vehicle = _this select 0;
private _groups = _this select 1;

private _tempTime = 0;
{
	private _y = _x; 
	_tempTime = time + br_groupsStuckTeleportDelay;
	waitUntil { sleep 1; [_vehicle, TRUE] call fn_ejectUnits; {_x in _vehicle} count (units _y) == 0 || time > _tempTime}; 
	// Move group to waiting groups
	private _playerCount = ({isPlayer _x} count (units _y));
	if (_playerCount == 0) then {
		br_friendly_groups_waiting pushBack _y;
	};
} forEach _groups;