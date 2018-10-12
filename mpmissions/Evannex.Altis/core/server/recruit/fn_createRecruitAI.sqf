_spawnPad = _this select 0; // Spawn position
_recruitIndex = _this select 1; // Index

// Add recruit action to AI
fn_addRecruitAction = {
  _ai = _this select 0;
  _ai addAction ["Recruit", { 
    [_this select 0] join group (_this select 1);
    (_this select 0) removeAction (_this select 2);
  }];
};

// Run the script
fn_createRecruitAI = {
  While {TRUE} do {
    _group = [getmarkerpos _spawnPad, WEST, 1] call BIS_fnc_spawnGroup;
    [_group, _spawnPad] call compile preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";
    _unit = (units (_group)) select 0;
    [[[_unit],"core\client\fn_createAddRecurit.sqf"],"BIS_fnc_execVM",true,true] call BIS_fnc_MP;
    //[_unit] call fn_addRecruitAction;
    waitUntil { !(alive _unit); };
    sleep 120;
    deleteVehicle _unit;
  };
};

call fn_createRecruitAI;