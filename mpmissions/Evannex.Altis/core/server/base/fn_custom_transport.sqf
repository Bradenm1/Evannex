private _driver = _this select 0;
private _vehicle = _this select 1;
private _id = format["CTV-%1", getPlayerUID _driver];

// Check the status of the driver
br_checkDriverStatus = {
	private _status = TRUE;
	if ((isNull driver _vehicle) || !(alive (driver _vehicle))) then {
		_status = FALSE;
	};
	_status;
};

// Do this while running
br_runningCustomTransport = {
	private _groups = _this select 0;
	/*player addAction ["Eject Units", {
		missionNamespace setVariable [_id, TRUE];
		removeAllActions (_this select 1);
	}];*/
	{ br_groups_in_transit pushBack _x; } forEach _groups;
	{ [_x, FALSE, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_commandGroupIntoVehicle.sqf"; } forEach _groups;
	waitUntil { sleep 3; (!(call br_checkDriverStatus) || !(missionNamespace getVariable _id)) };
	{ 
		private _y = _x;
		private _playerCount = ({isPlayer _x} count (units _y));
		if (_playerCount == 0) then {
			br_friendly_ai_groups pushBack _y; 
		};
		br_groups_in_transit deleteAt (br_groups_in_transit find _x);
	} forEach _groups;
	// Eject all groups within the vehicle
	{ [units _x] call compile preprocessFileLineNumbers "core\server\functions\fn_ejectUnits.sqf"; } forEach _groups;
	missionNamespace setVariable [_id, FALSE];
};

// If the Vehicle is transport
br_runCustomTransport = {
	// Check if any groups are waiting
	if (count br_friendly_groups_waiting > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_waiting, _vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_findGroupsInQueue.sqf"; 
		if (count _groups > 0) then {
			[_groups] call br_runningCustomTransport;
		};	
	} else { 
		// Check if any players are waiting in helicopter
		_playersGroups = [_vehicle] call compile preprocessFileLineNumbers "core\server\functions\fn_getPlayersInVehicle.sqf";
		if (count _playersGroups > 0) then {
			[_playersGroups] call br_runningCustomTransport;
		};
	};
};

// run the vehicle
br_startCustomTransport = {
	missionNamespace setVariable [_id, TRUE];
	while { ((call br_checkDriverStatus) && (missionNamespace getVariable _id)) } do {
		call br_runCustomTransport;
		sleep 1;
	};
};

call br_startCustomTransport;