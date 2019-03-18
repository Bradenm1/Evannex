	private _vehicle = _this select 0;
	private _group = [];
	{
		if (_x in _vehicle) then { _group append [_x] };
	} forEach allPlayers;	
	_group;