[
	["EMP", "EMP", 6, [], "Kill", TRUE, "EMP Destroyed!", ["O_Truck_03_device_F"], TRUE, TRUE, "Border", "ELLIPSE", getMarkerPos "ZONE_RADIUS", TRUE, [], FALSE],
	["Helicopter", "Helicopter", 6, [], "Kill", TRUE, "Attack Helicopter Destroyed!", ["O_Heli_Attack_02_F"], TRUE, TRUE, "Border", "ELLIPSE", getMarkerPos "ZONE_RADIUS", TRUE, [], FALSE],
	["AA_Zone", "AA", 4, [], "Kill", TRUE, "AA Destroyed!", ["O_APC_Tracked_02_AA_F"], TRUE, TRUE, "Border", "ELLIPSE", getMarkerPos "ZONE_RADIUS", TRUE, [], FALSE],
	["Enemy_Camp", "Enemy Camp", 2, selectrandom (call compile preprocessFileLineNumbers "core\savedassets\small_bases.sqf"), "Kill", TRUE, "Enemy Base Taken!", ["O_officer_F", "O_Soldier_F", "O_Soldier_AT_F", "O_Soldier_AA_F", "O_Soldier_F"], TRUE, TRUE, "Border", "ELLIPSE", getMarkerPos "ZONE_RADIUS", TRUE, [["PATH", FALSE]], FALSE],
	["Enemy_Mortors", "Enemy Mortors", 5, [], "Kill", TRUE, "Mortors Killed!", ["O_Mortar_01_F", "O_Mortar_01_F", "O_Mortar_01_F", "O_Mortar_01_F"] , TRUE, TRUE, "Border", "ELLIPSE", getMarkerPos "ZONE_RADIUS", TRUE, [["PATH", FALSE]], FALSE ]
	//["Enemy_Mine_Field", "Mine Field", 2, selectrandom (call compile preprocessFileLineNumbers "core\compositions\mine_fields.sqf"), "Kill", TRUE, "AA Destroyed!", [], TRUE, TRUE, "Border", "ELLIPSE", getMarkerPos "ZONE_RADIUS", TRUE, [], FALSE]
]