private _object = _this select 0;
private _position = _object getVariable "checkPosition";

if (isNil "_position") then {
	_object setVariable ["checkPosition", getPos _object];	
} else {
	if ((_position distance (getPos _object)) <= 0.5) then {
		_object setDamage 1;
	} else {
		_object setVariable ["checkPosition", getPos _object];	
	};
};