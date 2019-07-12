private _player = _this select 0;
private _vehicle = _this select 1;
private _id = format["CTV-%1", getPlayerUID _player];
private _hasEjectAction = format["HEA-%1", getPlayerUID _player];

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
	[_vehicle, "Group(s) found!"] remoteExec ["vehicleChat"];
	private _ejectAction = -1;
	// Check if player already has eject option
	if !(_player getVariable[_hasEjectAction, FALSE]) then {
		_ejectAction = _player addAction ["Eject Units", {
			params ["_object", "_caller", "_id", "_args"];
			_args params ["_playerID", "_hasEject"];
			_object setVariable [_playerID, FALSE];
			_object setVariable [_hasEject, FALSE];
			_object removeAction _id;
		}, [_id, _hasEjectAction]];
		_player setVariable [_hasEjectAction, TRUE];
	};
	{ [_x, FALSE, _vehicle] call fn_commandGroupIntoVehicle; } forEach _groups;
	_vehicle setUnloadInCombat [FALSE, FALSE];
	waitUntil { sleep 3; (!(call br_checkDriverStatus) || !(_player getVariable _id)) };
	_vehicle setUnloadInCombat [TRUE, TRUE];
	// Check if the player ejected with units still within the vehicle
	if (_ejectAction != -1) then {
		_player removeAction _ejectAction;
	};
	// Add them to the zone group
	{ 
		private _y = _x;
		private _playerCount = ({isPlayer _x} count (units _y));
		if (_playerCount == 0) then {
			br_friendly_ai_groups pushBack _y; 
		};
	} forEach _groups;
	{ _x setBehaviour "AWARE"; [_x, _vehicle] call fn_ejectGroup; } forEach _groups;
};

br_runCustomTransport = {
	[_vehicle, "Checking if any groups are waiting..."] remoteExec ["vehicleChat"];
	// Check if any groups are waiting
	if (count br_friendly_groups_waiting > 0) then {
		private _groups = [];
		// Get some waiting groups, if any
		_groups = [_groups, br_friendly_groups_waiting, _vehicle] call fn_findGroupsInQueue; 
		if (count _groups > 0) then {
			_player setVariable [_id, TRUE];
			[_groups] call br_runningCustomTransport;
		} else {
			[_vehicle, "No groups waiting or not enough seats..."] remoteExec ["vehicleChat"];
		};	
	} else { 
		[_vehicle, "No groups waiting or not enough seats..."] remoteExec ["vehicleChat"];
	};
};

call br_runCustomTransport;