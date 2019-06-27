private _position = _this select 0;
private _radius = _this select 1;
private _nearPlayer = FALSE;

{  
	if (_position distance (getpos _x) < _radius) then 
	{ 
		_nearPlayer = TRUE; 
	};
} forEach call BIS_fnc_listPlayers; 

_nearPlayer;