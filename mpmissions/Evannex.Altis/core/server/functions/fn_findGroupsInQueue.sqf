// Group to append to
private _groups = _this select 0;
private _groupWait = _this select 1;
private _vehicle = _this select 2;
// Number of people
private _Peps = 0;	

{
	// Get the alive units for each group
	private _unitsAlive = [_x] call br_fnc_getUnitsAlive;
	if (_unitsAlive > 0) then {
		if ((_Peps + _unitsAlive) <= _vehicle emptyPositions "cargo") then {
			_groupWait deleteAt (_groupWait find _x);
			_groups pushBack _x;
			_Peps = _Peps + _unitsAlive;
			sleep 3;
		};
	};
} forEach _groupWait;
_groups;