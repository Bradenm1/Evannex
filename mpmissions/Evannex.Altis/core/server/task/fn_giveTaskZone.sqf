_markerPos = getMarkerPos "ZONE_ICON";
_task = player createSimpleTask ["TAKE_THE_ZONE"];
_task setSimpleTaskDescription ["The enemy has taken a zone! You need to take it back!","Take the Zone",""];
_task setTaskState "Assigned";
_task setSimpleTaskDestination (_markerPos);
player setCurrentTask _task;
["TaskAssigned",["", "Take the zone!"]] call bis_fnc_showNotification;