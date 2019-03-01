private _source = _this select 0;
private _radius = _this select 1;

_objArray = []; 
_sourcePos = getPos _source; 
_sourceDir = getDir _source; 
{ 
    if !(_x isEqualTo _source && _x isEqualTo player) then 
    { 
        _pos = getPos _x;
        _dir = getDir _x;
        _type = typeOf _x;
        _offset = [(_pos select 0) - (_sourcePos select 0),(_pos select 1) - (_sourcePos select 1),(_pos select 2) - (_sourcePos select 2)]; 
        _dirOffset = (_dir + 360 - _sourceDir) % 360; 
        _objArray pushBack [_type, _offset, _dirOffset];
}; 
} forEach nearestObjects [_source, [], _radius]; 
copyToClipboard str _objArray;

_objArray