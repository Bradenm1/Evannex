_delayForAssignment = 5;

// Creates a task for the player
createPlayerTask = {
	_markerPos = getMarkerPos "ZONE_ICON";
	task1 = player createSimpleTask ["TAKE_THE_ZONE"];
	task1 setSimpleTaskDescription ["The enemy has taken a zone! You need to take it back!","Take the Zone",""];
	task1 setTaskState "Assigned";
	task1 setSimpleTaskDestination (_markerPos);
	player setCurrentTask task1;
	["TaskAssigned",["", "Take the zone!"]] call bis_fnc_showNotification;
};

// Allows zone to be created before an assignment can happen if host.
sleep _delayForAssignment;

[] call createPlayerTask;