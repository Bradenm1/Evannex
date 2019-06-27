private _group = _this select 0;

{ 
	_x setVectorDir call fn_getRandomVector;  
	if (!(isNull objectParent _x)) then { (vehicle _x) setVectorDir call fn_getRandomVector; };
} forEach (units _group);