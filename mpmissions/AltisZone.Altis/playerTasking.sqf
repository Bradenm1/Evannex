_delayForAssignment = 5;
task = nil;

// Creates a task for the player
br_fnc_createPlayerTask = {
	_markerPos = getMarkerPos "ZONE_ICON";
	{
		task = _x createSimpleTask ["TAKE_THE_ZONE"];
		task setSimpleTaskDescription ["The enemy has taken a zone! You need to take it back!","Take the Zone",""];
		task setTaskState "Assigned";
		task setSimpleTaskDestination (_markerPos);
		_x setCurrentTask task;
		["TaskAssigned",["", "Take the zone!"]] call bis_fnc_showNotification;
	} forEach allplayers;
};

// Allows zone to be created before an assignment can happen if host.
sleep _delayForAssignment;

[] call br_fnc_createPlayerTask;