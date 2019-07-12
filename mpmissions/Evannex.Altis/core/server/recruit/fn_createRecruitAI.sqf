private _spawnPad = _this select 0; // Spawn position
private _recruitIndex = _this select 1; // Index
private _unitChance = _this select 2;

// Run the script
fn_createRecruitAI = {
  While {TRUE} do {
    private _grp = createGroup WEST;
    (selectrandom _unitChance) createUnit [getmarkerpos _spawnPad, _grp];
    _grp setFormDir (markerDir _spawnPad); 
    private _unit = (units (_grp)) select 0;
    [[[_unit],"core\client\fn_createAddRecurit.sqf"],"BIS_fnc_execVM",true,true] call BIS_fnc_MP;
    [_unit] call fn_objectInitEvents;
    // waits untill has recruited ai
    waitUntil { sleep 10; count units _grp == 0 }; 
  };
};

call fn_createRecruitAI;