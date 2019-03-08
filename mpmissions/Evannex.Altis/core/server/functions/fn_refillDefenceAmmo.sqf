private _vehicle = _this select 0;

while {alive _vehicle} do {
	_vehicle setVehicleAmmo 1;
	sleep 120;
};