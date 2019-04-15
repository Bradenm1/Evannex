fn_place_mines = {
	private _nMines = random 100;
	private _minesPlaced = 0;
	while {_minesPlaced < _nMines} do {
		private _pos = [getMarkerPos "ZONE_RADIUS", 0, br_zone_radius * sqrt br_max_radius_distance, 2, 0, 60, 0] call BIS_fnc_findSafePos;
		private _mine = createMine [selectrandom ["ATMine", "APERSMine", "APERSBoundingMine", "SLAMDirectionalMine", "APERSTripMine", "Claymore_F", "IEDLandBig_F", "IEDLandSmall_F"], _pos, [], 0];
		br_placed_mines pushBack _mine;
		_minesPlaced = _minesPlaced + 1;
	};
};

call fn_place_mines;