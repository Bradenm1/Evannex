private _spawnPad = _this select 0; // Spawn position
private _recruitIndex = _this select 1; // Index

// Run the script
fn_createRecruitAI = {
  While {TRUE} do {
    _group = [getmarkerpos _spawnPad, WEST, 1] call BIS_fnc_spawnGroup;
    [_group, _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";
    _unit = (units (_group)) select 0;
    [[[_unit],"core\client\fn_createAddRecurit.sqf"],"BIS_fnc_execVM",true,true] call BIS_fnc_MP;
    waitUntil { sleep 10; count units _group == 0 };
    //sleep 120;
    //deleteVehicle _unit;
    [_unit] execVM "core\server\recruit\fn_deleteDeadRecruit.sqf";
  };
};

call fn_createRecruitAI;