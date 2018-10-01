this addAction ["Open God Garage",{   
  { deleteVehicle _x; } foreach (vehicles inAreaArray removeGodTrigger); 
  _pos = getmarkerPos "garage_spawner";  
  BIS_fnc_garage_center = createVehicle [ "Land_HelipadEmpty_F", _pos, [], 0, "CAN_COLLIDE" ];   
  [ "Open", true ] call BIS_fnc_garage;   
}];