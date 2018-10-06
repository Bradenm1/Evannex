	{ _x setTaskState "Succeeded"; } forEach (simpleTasks player);
	{ player removeSimpleTask _x; } forEach (simpleTasks player);