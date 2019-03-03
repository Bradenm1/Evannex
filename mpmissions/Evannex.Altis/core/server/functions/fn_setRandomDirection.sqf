private _group = _this select 0;

{ 
	_x setVectorDir (call compile preprocessFileLineNumbers "core\server\functions\fn_gerRandomVector.sqf");  
	if (!(isNull objectParent _x)) then { (vehicle _x) setVectorDir (call compile preprocessFileLineNumbers "core\server\functions\fn_gerRandomVector.sqf"); };
} forEach (units _group);