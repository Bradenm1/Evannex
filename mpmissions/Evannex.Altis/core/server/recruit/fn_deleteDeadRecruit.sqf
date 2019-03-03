private _unit = _this select 0;

waitUntil { !(alive _unit); };
sleep 120;
deleteVehicle _unit;