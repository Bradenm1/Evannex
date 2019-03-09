private _unit = _this select 0;

waitUntil { sleep 10; !(alive _unit); };
sleep 120;
deleteVehicle _unit;