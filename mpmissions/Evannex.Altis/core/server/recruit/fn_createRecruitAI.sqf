private _spawnPad = _this select 0; // Spawn position
private _recruitIndex = _this select 1; // Index
private _unitChance = _this select 2;

// Run the script
fn_createRecruitAI = {
  While {TRUE} do {
    private _grp = createGroup WEST;
    (selectrandom _unitChance) createUnit [getmarkerpos _spawnPad, _grp];
    [_grp, _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";
    private _unit = (units (_grp)) select 0;
    [[[_unit],"core\client\fn_createAddRecurit.sqf"],"BIS_fnc_execVM",true,true] call BIS_fnc_MP;
    waitUntil { sleep 10; count units _grp == 0 };
    //sleep 120;
    //deleteVehicle _unit;
    [_unit] execVM "core\server\recruit\fn_deleteDeadRecruit.sqf";
  };
};

call fn_createRecruitAI;