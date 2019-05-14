private _position = _this select 0;
private _radius = _this select 1;
private _nearPlayer = FALSE;

{  
	if (_position distance (getpos _x) < _radius * sqrt 360) then { _nearPlayer = TRUE; };
} forEach allPlayers; 

_nearPlayer;