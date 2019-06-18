private _position = _this select 0;

// run the vehicle
br_startCustomTransport = {
	while {TRUE} do {
		_entList = _position nearEntities 5;
		{
			private _driver = driver _x;
			if !(isNull _driver) then {
				if (isPlayer _driver) then {
					[_driver, _x] execVM "core\server\base\fn_customTransportRun.sqf";
				};
			};
		} forEach _entList;
		sleep 5;
	};
};

call br_startCustomTransport;