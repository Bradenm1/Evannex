br_markers_marked = [];
_marerRemovalLimit = 180; // Time before marker is removed if enemy is not seen again
_markerLimit = 6; // Markers limit

// Checks if any units in group are seen
fnc_checkUnitSeen = {
	_friendlyGroup = _this select 0;
	_enemyGroup = _this select 1;
	_knows = FALSE;
	{
		if ((_friendlyGroup knowsAbout _x) > 0) then { _knows = TRUE };
		if (_friendlyGroup knowsAbout (Vehicle _x) > 0) then { _knows = TRUE };
	} forEach (units _enemyGroup);
	_knows;
};

// Create the marker on the map
fnc_createMapMarker = {
	_marker = _this select 0;
	_group = _this select 1;
	_name = _this select 2;
	[_marker, getpos (leader _group), _name, "ColorBlack", 0.5] call (compile preProcessFile "core\server\markers\fn_createTextMarker.sqf");
};

// Create a maker given the type
fnc_createMarkerType = {
	_type = _this select 0;
	_marker = _this select 1;
	_group = _this select 2;
	switch (_type) do {
		case "Vehicle": { [_marker, _group, format ["%1 Around Here!", getText (configFile >>  "CfgVehicles" >> typeof (Vehicle (leader _group)) >> "displayName")]] call fnc_createMapMarker; };
		case "Ground Unit": { [_marker, _group, "Ground Units Around Here!"] call fnc_createMapMarker; };
		default { [_marker, _group, "Enemy Around Here!"] call fnc_createMapMarker; };
	};
};

// Check if any groups are seen
fnc_checkGroupSeen = {
	_friendlyGroup = _this select 0;
	{
		if (count br_markers_marked >= _markerLimit) exitWith {};
		// Check if group already has a marker
		//if (!(_x in br_groups_marked)) then {
			// Check if friendlys can see any units in a group
			if ([_friendlyGroup, _x] call fnc_checkUnitSeen) then {
				if (!(isNull objectParent (leader _x))) then {
					["Vehicle", groupId _x, _x] call fnc_createMarkerType;
				} else {
					["Ground Unit", groupId _x, _x] call fnc_createMarkerType;
				};
				if (!(groupId _x in br_markers_marked)) then { 
					br_markers_marked append [groupId _x]; 
					[groupId _x,time + _marerRemovalLimit] execVM "core\server\markers\fn_deleteMakerAfterGivenTime.sqf";
				}
			};
		//};
	} forEach br_ai_groups;
};

while {TRUE} do {
	if (count br_markers_marked < _markerLimit) then {
		{ [_x] call fnc_checkGroupSeen; } foreach br_friendly_ai_groups;
		{ [_x] call fnc_checkGroupSeen; } foreach br_friendly_objective_groups;
	};
	sleep 0.1;
};