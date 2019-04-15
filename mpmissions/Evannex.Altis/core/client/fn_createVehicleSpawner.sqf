// https://forums.bohemia.net/forums/topic/180297-virtual-garage-possible-to-use-as-spawner-like-vvs/
_this select 1 removeAction (_this select 2);
disableSerialization;
uiNamespace setVariable [ "current_garage", ( _this select 0 ) ];
_fullVersion = missionNamespace getVariable [ "BIS_fnc_arsenal_fullGarage", false ];
if !( isNull ( uiNamespace getVariable [ "BIS_fnc_arsenal_cam", objNull ] ) ) exitwith { "Garage Viewer is already running" call bis_fnc_logFormat; };
{ deleteVehicle _x; } forEach nearestObjects [ getMarkerPos ( _this select 0 ), [ "AllVehicles" ], 10 ];
_veh = createVehicle [ "Land_HelipadEmpty_F", getMarkerPos ( _this select 0 ), [], 0, "CAN_COLLIDE" ];
uiNamespace setVariable [ "garage_pad", _veh ];
missionNamespace setVariable [ "BIS_fnc_arsenal_fullGarage", [ true, 0, false, [ false ] ] call bis_fnc_param ];
with missionNamespace do { BIS_fnc_garage_center = [ true, 1, _veh, [ objNull ] ] call bis_fnc_param; };
with uiNamespace do {  
  _displayMission = [] call ( uiNamespace getVariable "bis_fnc_displayMission" );
  if !( isNull findDisplay 312 ) then { _displayMission = findDisplay 312; };
  _displayMission createDisplay "RscDisplayGarage";
  uiNamespace setVariable [ "running_garage", true ];
  waitUntil { sleep 0.25; isNull ( uiNamespace getVariable [ "BIS_fnc_arsenal_cam", objNull ] ) };
  _marker = uiNamespace getVariable "current_garage";
  _pad = uiNamespace getVariable "garage_pad";
  deleteVehicle _pad;
  _veh_list = ( getMarkerPos _marker ) nearEntities 5;
  {
    _vehType = typeOf _x;
    _textures = getObjectTextures _x;
    
    _crew = crew _x;
    {
      deleteVehicle _x;
    } forEach _crew;
    deleteVehicle _x;
    sleep 0.5;
    [_vehType, _marker, _textures] remoteExec ["MP_request_vehicle", 2];
  } forEach _veh_list;
};

sleep 5;
_this select 1 addaction ["Virtual Garage", { [("garage_spawner"), _this select 0, _this select 2] call compile preprocessFileLineNumbers "core\client\fn_createVehicleSpawner.sqf"; }];