_group = _this select 0;

br_fnc_getRandomDir = {
	[random 360, random 360, random 360];
};

{ 
	_x setVectorDir ([] call br_fnc_getRandomDir);  
	if (!(isNull objectParent _x)) then { (vehicle _x) setVectorDir ([] call br_fnc_getRandomDir); };
} forEach (units _group);