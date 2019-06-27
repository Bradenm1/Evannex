// Group to append to
private _groups = _this select 0;
private _groupWait = _this select 1;
private _vehicle = _this select 2;
// Number of people
private _Peps = 0;	

{
	// Get the alive units for each group
	private _unitsAlive = [_x] call fn_getUnitAliveCount;
	if (_unitsAlive > 0) then {
		private _emptyPositions = ((_vehicle emptyPositions "Cargo") + (_vehicle emptyPositions "Gunner") + (_vehicle emptyPositions "Commander") + (_vehicle emptyPositions "Driver") + (count (allTurrets [_vehicle, true])));
		if ((_Peps + _unitsAlive) <= _emptyPositions) then {
			_groupWait deleteAt (_groupWait find _x);
			_groups pushBack _x;
			_Peps = _Peps + _unitsAlive;
			sleep 3;
		};
	};
} forEach _groupWait;
_groups;